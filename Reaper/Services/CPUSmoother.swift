import Foundation

/// Exponential moving average smoother for per-process CPU readings.
/// Dampens transient spikes while tracking sustained changes.
struct CPUSmoother {
    private var history: [pid_t: Double] = [:]
    /// EMA alpha — higher = more responsive, lower = smoother.
    private let alpha: Double = 0.4

    /// Returns a smoothed CPU value for the given process.
    /// First call for a PID returns the raw value.
    mutating func smooth(pid: pid_t, rawCPU: Double) -> Double {
        guard let prev = history[pid] else {
            history[pid] = rawCPU
            return rawCPU
        }
        let smoothed = alpha * rawCPU + (1 - alpha) * prev
        history[pid] = smoothed
        return smoothed
    }

    /// Remove history for PIDs no longer active.
    mutating func purge(keeping activePIDs: Set<pid_t>) {
        history = history.filter { activePIDs.contains($0.key) }
    }
}
