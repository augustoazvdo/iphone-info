import AVFoundation

/// One capture device as the camera screen shows it.
struct CameraEntry: Equatable {
    let position: String
    let deviceType: String
}

/// Camera list rows. An empty list shows one fixed sentence.
enum CameraInventory {
    static let emptySentence = "Nenhuma câmera"

    static func rows(for entries: [CameraEntry]) -> [SheetRow] {
        guard !entries.isEmpty else { return [SheetRow(label: "Câmeras", value: emptySentence)] }
        return entries.map { SheetRow(label: $0.position, value: $0.deviceType) }
    }

    static func current() -> [CameraEntry] {
        let session = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera, .builtInUltraWideCamera, .builtInTelephotoCamera, .builtInTrueDepthCamera],
            mediaType: .video,
            position: .unspecified)
        return session.devices.map { device in
            CameraEntry(position: positionName(device.position), deviceType: typeName(device.deviceType))
        }
    }

    private static func positionName(_ position: AVCaptureDevice.Position) -> String {
        switch position {
        case .back: "Traseira"
        case .front: "Frontal"
        default: "Indefinida"
        }
    }

    private static func typeName(_ type: AVCaptureDevice.DeviceType) -> String {
        switch type {
        case .builtInWideAngleCamera: "Grande-angular"
        case .builtInUltraWideCamera: "Ultra grande-angular"
        case .builtInTelephotoCamera: "Teleobjetiva"
        case .builtInTrueDepthCamera: "TrueDepth"
        default: "Outra"
        }
    }
}
