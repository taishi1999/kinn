import SwiftUI
import FamilyControls
import ManagedSettings

class ContentViewModel: ObservableObject {
    @Published var selection = FamilyActivitySelection()

    func startBlocking() {
        let store = ManagedSettingsStore(named: ManagedSettingsStore.Name("karasaki.kinn"))
        store.application.denyAppRemoval = true
        store.shield.applicationCategories = .specific(selection.categoryTokens)
        store.shield.applications = selection.applicationTokens
    }

    func stopBlocking() {
        let store = ManagedSettingsStore(named: ManagedSettingsStore.Name("karasaki.kinn"))
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        store.clearAllSettings()
    }
}
