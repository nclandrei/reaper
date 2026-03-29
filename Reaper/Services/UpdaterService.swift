import Foundation
import os
import Sparkle

private let logger = Logger(subsystem: "com.reaper.app", category: "Updater")

@MainActor
final class UpdaterService: NSObject, ObservableObject, SPUUpdaterDelegate {
    private var updaterController: SPUStandardUpdaterController?

    @Published var canCheckForUpdates = false

    var lastUpdateCheckDate: Date? {
        updaterController?.updater.lastUpdateCheckDate
    }

    var automaticallyChecksForUpdates: Bool {
        get { updaterController?.updater.automaticallyChecksForUpdates ?? true }
        set { updaterController?.updater.automaticallyChecksForUpdates = newValue }
    }

    override init() {
        super.init()

        let key = Bundle.main.object(forInfoDictionaryKey: "SUPublicEDKey") as? String ?? ""
        let hasValidKey = !key.isEmpty && !key.contains("PLACEHOLDER")

        if hasValidKey {
            let controller = SPUStandardUpdaterController(
                startingUpdater: true,
                updaterDelegate: self,
                userDriverDelegate: nil
            )
            self.updaterController = controller
            if UserDefaults.standard.object(forKey: "SUEnableAutomaticChecks") == nil {
                controller.updater.automaticallyChecksForUpdates = true
            }
            controller.updater.publisher(for: \.canCheckForUpdates)
                .assign(to: &$canCheckForUpdates)
        } else {
            logger.error("Sparkle updater NOT initialized – SUPublicEDKey is missing or placeholder")
        }
    }

    func checkForUpdates() {
        updaterController?.checkForUpdates(nil)
    }

    // MARK: - SPUUpdaterDelegate

    nonisolated func updater(_ updater: SPUUpdater, didAbortWithError error: any Error) {
        logger.error("Sparkle aborted: \(error.localizedDescription, privacy: .public)")
    }

    nonisolated func updater(_ updater: SPUUpdater, didFinishUpdateCycleFor updateCheck: SPUUpdateCheck, error: (any Error)?) {
        if let error {
            logger.error("Sparkle update cycle error: \(error.localizedDescription, privacy: .public)")
        } else {
            logger.info("Sparkle update cycle finished OK")
        }
    }
}
