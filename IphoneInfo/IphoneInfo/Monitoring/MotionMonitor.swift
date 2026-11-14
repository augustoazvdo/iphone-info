import CoreMotion
import Observation

struct Vector3 {
    var x = 0.0
    var y = 0.0
    var z = 0.0

    var magnitude: Double { (x * x + y * y + z * z).squareRoot() }
}

@Observable
@MainActor
final class MotionMonitor {
    private(set) var acceleration: Vector3?
    private(set) var rotationRate: Vector3?
    private(set) var magneticField: Vector3?
    private(set) var pitch = 0.0
    private(set) var roll = 0.0
    private(set) var yaw = 0.0
    private(set) var pressureKPa: Double?
    private(set) var relativeAltitude: Double?

    let hasDeviceMotion: Bool
    let hasMagnetometer: Bool
    let hasBarometer: Bool

    private let manager = CMMotionManager()
    private let altimeter = CMAltimeter()

    init() {
        hasDeviceMotion = manager.isDeviceMotionAvailable
        hasMagnetometer = manager.isMagnetometerAvailable
        hasBarometer = CMAltimeter.isRelativeAltitudeAvailable()
    }

    func start() {
        if hasDeviceMotion, !manager.isDeviceMotionActive {
            manager.deviceMotionUpdateInterval = 0.1
            manager.startDeviceMotionUpdates(to: .main) { [weak self] motion, _ in
                guard let motion else { return }
                MainActor.assumeIsolated { self?.apply(motion) }
            }
        }
        if hasMagnetometer, !manager.isMagnetometerActive {
            manager.magnetometerUpdateInterval = 0.1
            manager.startMagnetometerUpdates(to: .main) { [weak self] data, _ in
                guard let field = data?.magneticField else { return }
                MainActor.assumeIsolated {
                    self?.magneticField = Vector3(x: field.x, y: field.y, z: field.z)
                }
            }
        }
        if hasBarometer {
            altimeter.startRelativeAltitudeUpdates(to: .main) { [weak self] data, _ in
                guard let data else { return }
                MainActor.assumeIsolated {
                    self?.pressureKPa = data.pressure.doubleValue
                    self?.relativeAltitude = data.relativeAltitude.doubleValue
                }
            }
        }
    }

    func stop() {
        manager.stopDeviceMotionUpdates()
        manager.stopMagnetometerUpdates()
        altimeter.stopRelativeAltitudeUpdates()
    }

    private func apply(_ motion: CMDeviceMotion) {
        let gravity = motion.gravity
        let user = motion.userAcceleration
        acceleration = Vector3(x: gravity.x + user.x, y: gravity.y + user.y, z: gravity.z + user.z)
        rotationRate = Vector3(x: motion.rotationRate.x, y: motion.rotationRate.y, z: motion.rotationRate.z)
        pitch = motion.attitude.pitch
        roll = motion.attitude.roll
        yaw = motion.attitude.yaw
    }
}
