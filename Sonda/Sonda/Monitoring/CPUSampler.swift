import Darwin

final class CPUSampler {
    private var previousTicks: [[UInt32]] = []

    /// Returns the busy fraction (0...1) of each logical core since the previous call.
    func sample() -> [Double] {
        var coreCount: natural_t = 0
        var info: processor_info_array_t?
        var infoCount: mach_msg_type_number_t = 0
        let result = host_processor_info(
            mach_host_self(), PROCESSOR_CPU_LOAD_INFO, &coreCount, &info, &infoCount)
        guard result == KERN_SUCCESS, let info else { return [] }
        defer {
            let size = vm_size_t(Int(infoCount) * MemoryLayout<integer_t>.stride)
            vm_deallocate(mach_task_self_, vm_address_t(bitPattern: info), size)
        }

        let states = Int(CPU_STATE_MAX)
        let ticks: [[UInt32]] = (0..<Int(coreCount)).map { core in
            (0..<states).map { UInt32(bitPattern: info[core * states + $0]) }
        }
        defer { previousTicks = ticks }
        guard previousTicks.count == ticks.count else { return ticks.map { _ in 0 } }

        return zip(ticks, previousTicks).map { now, before in
            let delta = (0..<states).map { Double(now[$0] &- before[$0]) }
            let busy = delta[Int(CPU_STATE_USER)] + delta[Int(CPU_STATE_SYSTEM)] + delta[Int(CPU_STATE_NICE)]
            let total = busy + delta[Int(CPU_STATE_IDLE)]
            return total > 0 ? busy / total : 0
        }
    }
}
