import Charts
import SwiftUI

struct MetricCard<Content: View>: View {
    let title: String
    let systemImage: String
    var tint: Color = .accentColor
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: systemImage)
                .font(.headline)
                .foregroundStyle(tint)
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .glassEffect(.regular.tint(tint.opacity(0.35)).interactive(), in: .rect(cornerRadius: 26))
    }
}

struct GlassBackdrop: View {
    var body: some View {
        ZStack {
            Color(.systemBackground)
            Circle().fill(.blue.opacity(0.45)).frame(width: 320).blur(radius: 30).offset(x: -120, y: -280)
            Circle().fill(.purple.opacity(0.35)).frame(width: 280).blur(radius: 40).offset(x: 150, y: 40)
            Circle().fill(.teal.opacity(0.30)).frame(width: 260).blur(radius: 36).offset(x: -60, y: 460)
            Circle().fill(.orange.opacity(0.22)).frame(width: 220).blur(radius: 40).offset(x: 130, y: 720)
        }
        .ignoresSafeArea()
    }
}

struct UsageBar: View {
    let fraction: Double
    var tint: Color = .accentColor

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule().fill(.quaternary)
                Capsule()
                    .fill(tint.gradient)
                    .frame(width: proxy.size.width * min(max(fraction, 0), 1))
            }
        }
        .frame(height: 8)
        .animation(.easeOut(duration: 0.4), value: fraction)
    }
}

struct ValueRow: View {
    let label: String
    let value: String

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .firstTextBaseline) {
                Text(label).foregroundStyle(.secondary).fixedSize()
                Spacer(minLength: 8)
                Text(value).monospacedDigit().fixedSize()
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(label).foregroundStyle(.secondary)
                Text(value).monospacedDigit().frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
        .font(.subheadline)
    }
}

struct HistoryChart: View {
    let points: [HistoryPoint]
    var secondary: [HistoryPoint] = []
    var tint: Color = .accentColor
    var secondaryTint: Color = .orange
    var maxValue: Double? = nil

    var body: some View {
        Chart {
            ForEach(points) { point in
                AreaMark(x: .value("t", point.id), y: .value("v", point.value), series: .value("s", "a"))
                    .foregroundStyle(tint.opacity(0.25).gradient)
                LineMark(x: .value("t", point.id), y: .value("v", point.value), series: .value("s", "a"))
                    .foregroundStyle(tint)
            }
            ForEach(secondary) { point in
                LineMark(x: .value("t", point.id), y: .value("v", point.value), series: .value("s", "b"))
                    .foregroundStyle(secondaryTint)
            }
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .chartXScale(domain: xDomain)
        .chartYScale(domain: 0...(maxValue ?? max(points.map(\.value).max() ?? 1, secondary.map(\.value).max() ?? 1, 1)))
        .frame(height: 64)
    }

    private var xDomain: ClosedRange<Int> {
        let last = points.last?.id ?? 0
        return max(last - LiveMonitor.historyLength + 1, 0)...max(last, 1)
    }
}
