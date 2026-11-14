import AVFoundation
import SwiftUI

struct ToolsView: View {
    var body: some View {
        List {
            Section("Decibel") { DecibelTool() }
            Section("Régua") { RulerTool() }
            Section("Tom") { ToneTool() }
            Section("Regex") { RegexTool() }
        }
        .navigationTitle("Ferramentas")
        .scrollContentBackground(.hidden)
        .background { GlassBackdrop() }
    }
}

private struct DecibelTool: View {
    @State private var meter = DecibelMeter()

    var body: some View {
        Toggle(isOn: Binding(get: { meter.isRunning }, set: { meter.setRunning($0) })) {
            Text(meter.text).monospacedDigit()
        }
    }
}

private struct RulerTool: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Canvas { context, size in
                for step in stride(from: 0.0, through: size.width, by: 10) {
                    let major = Int(step) % 50 == 0
                    let height: CGFloat = major ? 28 : 14
                    var tick = Path()
                    tick.move(to: CGPoint(x: step, y: 0))
                    tick.addLine(to: CGPoint(x: step, y: height))
                    context.stroke(tick, with: .color(.primary), lineWidth: 1)
                }
            }
            .frame(height: 30)
            Text("Régua em pontos, sem calibração em centímetros.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

private struct ToneTool: View {
    @State private var tone = ToneGenerator()
    @State private var frequency = 440.0
    @State private var playing = false

    var body: some View {
        Toggle("Tocar \(Int(frequency)) Hz", isOn: $playing)
            .onChange(of: playing) { _, isOn in
                if isOn { tone.play(frequency: frequency) } else { tone.stop() }
            }
        Slider(value: $frequency, in: 200...4000, step: 10)
            .onChange(of: frequency) { _, value in
                if playing { tone.play(frequency: value) }
            }
    }
}

private struct RegexTool: View {
    @State private var pattern = "a"
    @State private var text = "banana"

    var body: some View {
        TextField("Padrão", text: $pattern)
            .textInputAutocapitalization(.never)
        TextField("Texto", text: $text)
        ValueRow(
            label: "Ocorrências",
            value: ToolBench.regexMatchCount(pattern: pattern, text: text).map(String.init) ?? "Padrão inválido")
    }
}

@MainActor
@Observable
final class DecibelMeter {
    private(set) var isRunning = false
    private(set) var text = "Parado"

    private var recorder: AVAudioRecorder?
    private var task: Task<Void, Never>?

    func setRunning(_ run: Bool) {
        if run {
            AVAudioApplication.requestRecordPermission { granted in
                Task { @MainActor in
                    if granted { self.begin() } else { self.text = "Microfone negado" }
                }
            }
        } else {
            end()
        }
    }

    private func begin() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .measurement)
            try AVAudioSession.sharedInstance().setActive(true)
            let url = FileManager.default.temporaryDirectory.appendingPathComponent("sonda-meter.caf")
            let settings: [String: Any] = [
                AVFormatIDKey: kAudioFormatLinearPCM,
                AVSampleRateKey: 44_100.0,
                AVNumberOfChannelsKey: 1,
            ]
            let recorder = try AVAudioRecorder(url: url, settings: settings)
            recorder.isMeteringEnabled = true
            recorder.record()
            self.recorder = recorder
            isRunning = true
            task = Task { [weak self] in
                while !Task.isCancelled {
                    recorder.updateMeters()
                    let power = recorder.averagePower(forChannel: 0)
                    self?.text = ToolBench.decibelText(averagePower: power)
                    try? await Task.sleep(for: .milliseconds(200))
                }
            }
        } catch {
            text = "Indisponível"
        }
    }

    private func end() {
        task?.cancel()
        task = nil
        recorder?.stop()
        recorder = nil
        isRunning = false
        text = "Parado"
    }
}

@MainActor
final class ToneGenerator {
    private final class State: @unchecked Sendable {
        var phase = 0.0
        var frequency = 440.0
        var sampleRate = 44_100.0
    }

    private let engine = AVAudioEngine()
    private var source: AVAudioSourceNode?
    private let state = State()

    func play(frequency: Double) {
        state.frequency = frequency
        guard source == nil else { return }
        let format = engine.outputNode.inputFormat(forBus: 0)
        state.sampleRate = format.sampleRate
        let state = state
        let node = AVAudioSourceNode { _, _, frameCount, audioBufferList -> OSStatus in
            let buffers = UnsafeMutableAudioBufferListPointer(audioBufferList)
            for frame in 0..<Int(frameCount) {
                let sample = Float(sin(state.phase) * 0.2)
                state.phase += 2 * .pi * state.frequency / state.sampleRate
                for buffer in buffers {
                    buffer.mData?.assumingMemoryBound(to: Float.self)[frame] = sample
                }
            }
            return noErr
        }
        engine.attach(node)
        engine.connect(node, to: engine.mainMixerNode, format: format)
        source = node
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            try engine.start()
        } catch {
            stop()
        }
    }

    func stop() {
        engine.stop()
        if let source {
            engine.detach(source)
        }
        source = nil
    }
}
