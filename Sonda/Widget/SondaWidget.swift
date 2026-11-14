import SwiftUI
import WidgetKit

struct SondaEntry: TimelineEntry {
    let date: Date
    let snapshot: WidgetSnapshot?
}

struct SondaProvider: TimelineProvider {
    func placeholder(in context: Context) -> SondaEntry {
        SondaEntry(date: .now, snapshot: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (SondaEntry) -> Void) {
        completion(SondaEntry(date: .now, snapshot: WidgetSnapshot.load()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SondaEntry>) -> Void) {
        let entry = SondaEntry(date: .now, snapshot: WidgetSnapshot.load())
        completion(Timeline(entries: [entry], policy: .after(.now.addingTimeInterval(900))))
    }
}

struct SondaWidgetView: View {
    let entry: SondaEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            row("CPU", entry.snapshot?.cpuPercent)
            row("Bateria", entry.snapshot?.batteryPercent)
            Text(entry.snapshot?.wattsText ?? "—")
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .containerBackground(.fill.tertiary, for: .widget)
    }

    private func row(_ title: String, _ value: String?) -> some View {
        HStack {
            Text(title).font(.caption).foregroundStyle(.secondary)
            Spacer()
            Text(value ?? "—").font(.title3.weight(.bold)).monospacedDigit()
        }
    }
}

struct SondaWidget: Widget {
    let kind = "SondaWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SondaProvider()) { entry in
            SondaWidgetView(entry: entry)
        }
        .configurationDisplayName("Sonda")
        .description("CPU, bateria e potência estimada.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

@main
struct SondaWidgetBundle: WidgetBundle {
    var body: some Widget {
        SondaWidget()
    }
}
