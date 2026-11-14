import AVFoundation
import AVKit
import CoreMedia
import SwiftUI
import UIKit

/// The layer Picture in Picture reads frames from. It must stay in a window to present.
final class MeterLayerView: UIView {
    override class var layerClass: AnyClass { AVSampleBufferDisplayLayer.self }

    var displayLayer: AVSampleBufferDisplayLayer {
        layer as! AVSampleBufferDisplayLayer
    }
}

/// Draws the meter text into frames and presents them in a Picture in Picture window.
final class FloatingMeterPiP: NSObject, AVPictureInPictureControllerDelegate, AVPictureInPictureSampleBufferPlaybackDelegate {
    let hostView = MeterLayerView()
    private var controller: AVPictureInPictureController?
    private let size = CGSize(width: 320, height: 180)

    override init() {
        super.init()
        guard AVPictureInPictureController.isPictureInPictureSupported() else { return }
        let source = AVPictureInPictureController.ContentSource(
            sampleBufferDisplayLayer: hostView.displayLayer,
            playbackDelegate: self)
        controller = AVPictureInPictureController(contentSource: source)
    }

    func start(cpu: String, battery: String) {
        try? AVAudioSession.sharedInstance().setCategory(.playback)
        try? AVAudioSession.sharedInstance().setActive(true)
        update(cpu: cpu, battery: battery)
        controller?.startPictureInPicture()
    }

    func stop() {
        controller?.stopPictureInPicture()
    }

    func update(cpu: String, battery: String) {
        guard let buffer = pixelBuffer(cpu: cpu, battery: battery),
              let sample = sampleBuffer(for: buffer)
        else { return }
        hostView.displayLayer.enqueue(sample)
    }

    private func pixelBuffer(cpu: String, battery: String) -> CVPixelBuffer? {
        let image = UIGraphicsImageRenderer(size: size).image { _ in
            UIColor.black.setFill()
            UIRectFill(CGRect(origin: .zero, size: size))
            let font = UIFont.monospacedDigitSystemFont(ofSize: 44, weight: .bold)
            let attributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: UIColor.white]
            (cpu as NSString).draw(at: CGPoint(x: 20, y: 28), withAttributes: attributes)
            (battery as NSString).draw(at: CGPoint(x: 20, y: 100), withAttributes: attributes)
        }
        guard let cgImage = image.cgImage else { return nil }

        var buffer: CVPixelBuffer?
        let attributes: [CFString: Any] = [kCVPixelBufferCGImageCompatibilityKey: true,
                                           kCVPixelBufferCGBitmapContextCompatibilityKey: true]
        guard CVPixelBufferCreate(kCFAllocatorDefault, Int(size.width), Int(size.height),
                                  kCVPixelFormatType_32BGRA, attributes as CFDictionary, &buffer) == kCVReturnSuccess,
              let buffer
        else { return nil }

        CVPixelBufferLockBaseAddress(buffer, [])
        defer { CVPixelBufferUnlockBaseAddress(buffer, []) }
        guard let context = CGContext(
            data: CVPixelBufferGetBaseAddress(buffer),
            width: Int(size.width), height: Int(size.height),
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)
        else { return nil }
        context.draw(cgImage, in: CGRect(origin: .zero, size: size))
        return buffer
    }

    private func sampleBuffer(for buffer: CVPixelBuffer) -> CMSampleBuffer? {
        var description: CMVideoFormatDescription?
        guard CMVideoFormatDescriptionCreateForImageBuffer(
            allocator: kCFAllocatorDefault, imageBuffer: buffer, formatDescriptionOut: &description) == noErr,
            let description
        else { return nil }

        var timing = CMSampleTimingInfo(
            duration: .invalid,
            presentationTimeStamp: CMClockGetTime(CMClockGetHostTimeClock()),
            decodeTimeStamp: .invalid)
        var sample: CMSampleBuffer?
        guard CMSampleBufferCreateReadyWithImageBuffer(
            allocator: kCFAllocatorDefault, imageBuffer: buffer, formatDescription: description,
            sampleTiming: &timing, sampleBufferOut: &sample) == noErr
        else { return nil }
        return sample
    }

    // MARK: AVPictureInPictureSampleBufferPlaybackDelegate

    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, setPlaying playing: Bool) {}

    func pictureInPictureControllerTimeRangeForPlayback(_ pictureInPictureController: AVPictureInPictureController) -> CMTimeRange {
        CMTimeRange(start: .negativeInfinity, duration: .positiveInfinity)
    }

    func pictureInPictureControllerIsPlaybackPaused(_ pictureInPictureController: AVPictureInPictureController) -> Bool {
        false
    }

    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, didTransitionToRenderSize newRenderSize: CMVideoDimensions) {}

    func pictureInPictureController(
        _ pictureInPictureController: AVPictureInPictureController,
        skipByInterval skipInterval: CMTime,
        completion completionHandler: @escaping () -> Void
    ) {
        completionHandler()
    }
}

private struct MeterHost: UIViewRepresentable {
    let view: UIView

    func makeUIView(context: Context) -> UIView { view }
    func updateUIView(_ uiView: UIView, context: Context) {}
}

struct FloatingMeterView: View {
    let monitor: LiveMonitor

    @State private var pip = FloatingMeterPiP()
    @State private var active = false

    var body: some View {
        let lines = FloatingMeter.lines(cpuUsage: monitor.totalUsage, batteryLevel: monitor.battery.level)
        List {
            Section {
                Toggle("Janela flutuante", isOn: $active)
                    .onChange(of: active) { _, isOn in
                        if isOn {
                            pip.start(cpu: lines.cpu, battery: lines.battery)
                        } else {
                            pip.stop()
                        }
                    }
            }
            Section {
                ValueRow(label: "CPU", value: PainelSheet.percentText(monitor.totalUsage))
                ValueRow(label: "Bateria", value: monitor.battery.level.map(PainelSheet.percentText) ?? "—")
            }
        }
        .navigationTitle("Medidor flutuante")
        .scrollContentBackground(.hidden)
        .background { GlassBackdrop() }
        .background {
            MeterHost(view: pip.hostView).frame(width: 1, height: 1)
        }
        .onChange(of: monitor.totalUsage) {
            guard active else { return }
            pip.update(cpu: lines.cpu, battery: lines.battery)
        }
    }
}
