import SwiftUI

/// Voltage, wattage, and the two current rows opened from the battery card.
struct BatteryDetailView: View {
    let section: SheetSection

    var body: some View {
        List {
            Section(section.title) {
                ForEach(section.rows, id: \.label) { row in
                    ValueRow(label: row.label, value: row.value)
                }
            }
        }
        .navigationTitle("Bateria")
        .scrollContentBackground(.hidden)
        .background { GlassBackdrop() }
    }
}
