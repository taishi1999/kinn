import SwiftUI
import FamilyControls
import ManagedSettings

class ShieldManager: ObservableObject {
    static let shared = ShieldManager()
    @Published var discouragedSelections = FamilyActivitySelection()

    private let store = ManagedSettingsStore()

    func shieldActivities() {
        // Clear to reset previous settings
        print("print_shieldActivities")
        NSLog("NSLog_shieldActivities")
        store.clearAllSettings()

        let applications = discouragedSelections.applicationTokens
        let categories = discouragedSelections.categoryTokens

        store.shield.applications = applications.isEmpty ? nil : applications
        store.shield.applicationCategories = categories.isEmpty ? nil : .specific(categories)
        store.shield.webDomainCategories = categories.isEmpty ? nil : .specific(categories)
    }
}
