import SwiftUI

struct DeviceView: View {
    let system: SystemInfo

    var body: some View {
        List {
            ForEach(DeviceSheet.make(system: system), id: \.title) { section in
                Section(section.title) {
                    ForEach(section.rows, id: \.label) { row in
                        ValueRow(label: row.label, value: row.value)
                    }
                }
            }
        }
        .navigationTitle("Dispositivo")
        .scrollContentBackground(.hidden)
        .background { GlassBackdrop() }
    }
}
