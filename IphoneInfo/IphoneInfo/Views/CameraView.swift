import SwiftUI

struct CameraView: View {
    @State private var entries: [CameraEntry] = []

    var body: some View {
        List {
            Section("Câmeras") {
                ForEach(CameraInventory.rows(for: entries), id: \.label) { row in
                    ValueRow(label: row.label, value: row.value)
                }
            }
        }
        .navigationTitle("Câmera")
        .scrollContentBackground(.hidden)
        .background { GlassBackdrop() }
        .onAppear { entries = CameraInventory.current() }
    }
}
