import SwiftUI

struct SensorsView: View {
    @State private var motion = MotionMonitor()

    private var sections: [SheetSection] {
        SensorSheet.make(
            hasDeviceMotion: motion.hasDeviceMotion,
            hasMagnetometer: motion.hasMagnetometer,
            hasBarometer: motion.hasBarometer,
            acceleration: motion.acceleration,
            rotationRate: motion.rotationRate,
            magneticField: motion.magneticField,
            pitch: motion.pitch,
            roll: motion.roll,
            yaw: motion.yaw,
            pressureKPa: motion.pressureKPa,
            relativeAltitude: motion.relativeAltitude)
    }

    var body: some View {
        List {
            ForEach(sections, id: \.title) { section in
                Section(section.title) {
                    ForEach(section.rows, id: \.label) { row in
                        ValueRow(label: row.label, value: row.value)
                    }
                }
            }
        }
        .navigationTitle("Sensores")
        .scrollContentBackground(.hidden)
        .background { GlassBackdrop() }
        .onAppear { motion.start() }
        .onDisappear { motion.stop() }
    }
}
