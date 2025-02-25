import FamilyControls
import Combine
import SwiftUI

class ScreenTimeAuthorizationManager: ObservableObject {
    @Published var authorizationStatus: AuthorizationStatus = .notDetermined
    private var cancellables = Set<AnyCancellable>()

    init() {
        observeAuthorizationStatus()
    }

    /// `authorizationStatus` の変更を監視する
    private func observeAuthorizationStatus() {
        AuthorizationCenter.shared.$authorizationStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newStatus in
                guard let self = self else { return }
                self.authorizationStatus = newStatus
                print("🔄 Screen Time 認証状態が変更されました: \(newStatus)")
            }
            .store(in: &cancellables)
    }

    /// 認証をリクエスト
    func requestAuthorization() async {
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            print("✅ Screen Time 認証リクエスト完了")
        } catch {
            print("⚠️ Screen Time 認証リクエスト失敗: \(error)")
        }
    }

    /// 認証を取り消し、`authorizationStatus` を更新
    func revokeAuthorization() {
        AuthorizationCenter.shared.revokeAuthorization { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("✅ Screen Time 認証解除完了")
                    self?.authorizationStatus = .denied // 🔹 強制的に `denied` に変更
                case .failure(let error):
                    print("⚠️ Screen Time 認証解除失敗: \(error)")
                }
            }
        }
    }
}
