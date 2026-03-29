import Foundation
import Sparkle

@MainActor
final class UpdaterService: ObservableObject {
    private let updaterController: SPUStandardUpdaterController?

    @Published var canCheckForUpdates = false

    var lastUpdateCheckDate: Date? {
        updaterController?.updater.lastUpdateCheckDate
    }

    var automaticallyChecksForUpdates: Bool {
        get { updaterController?.updater.automaticallyChecksForUpdates ?? true }
        set { updaterController?.updater.automaticallyChecksForUpdates = newValue }
    }

    init() {
        let key = Bundle.main.object(forInfoDictionaryKey: "SUPublicEDKey") as? String ?? ""
        let hasValidKey = !key.isEmpty && !key.contains("PLACEHOLDER")

        if hasValidKey {
            let controller = SPUStandardUpdaterController(
                startingUpdater: true,
                updaterDelegate: nil,
                userDriverDelegate: nil
            )
            self.updaterController = controller
            // Ensure automatic checks default to ON; Sparkle may default to false
            // until the user has explicitly changed the preference.
            if UserDefaults.standard.object(forKey: "SUEnableAutomaticChecks") == nil {
                controller.updater.automaticallyChecksForUpdates = true
            }
            controller.updater.publisher(for: \.canCheckForUpdates)
                .assign(to: &$canCheckForUpdates)
        } else {
            self.updaterController = nil
        }
    }

    func checkForUpdates() {
        updaterController?.checkForUpdates(nil)
    }
}
