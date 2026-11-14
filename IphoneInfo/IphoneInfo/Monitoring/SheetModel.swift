import Foundation

/// One label and value line shown in a sheet section.
struct SheetRow: Equatable {
    let label: String
    let value: String
}

/// A titled group of rows, shared by the painel, dispositivo, sensores, rede, and tools screens.
struct SheetSection: Equatable {
    let title: String
    let rows: [SheetRow]
}
