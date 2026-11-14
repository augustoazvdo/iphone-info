import SwiftUI

struct DeviceCheckView: View {
    @State private var outcomes: [String: CheckOutcome] = [:]

    private static let titles = [
        "display": "Tela",
        "touch": "Toque",
        "camera": "Câmera",
        "microphone": "Microfone",
        "speaker": "Alto-falante",
        "volume": "Botões de volume",
    ]

    var body: some View {
        List {
            Section("Checagem") {
                ForEach(DeviceCheck.keys, id: \.self) { key in
                    HStack {
                        Text(Self.titles[key] ?? key)
                        Spacer()
                        Menu {
                            Button("Aprovado") { outcomes[key] = .pass }
                            Button("Reprovado") { outcomes[key] = .fail }
                            Button("Indisponível") { outcomes[key] = .unavailable }
                        } label: {
                            Text(outcomes[key].map(DeviceCheck.word(for:)) ?? "Não testado")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle("Checagem")
        .scrollContentBackground(.hidden)
        .background { GlassBackdrop() }
    }
}
