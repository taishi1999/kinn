import SwiftUI
import FamilyControls

struct パーツ_アプリ選択: View {
    @Binding var isPresented: Bool
    @Binding var selection: FamilyActivitySelection

    var body: some View {
        Button {
            isPresented = true
        } label: {
            HStack {
                Text("ブロックするアプリ")
                    .foregroundColor(.primary)
                Spacer()
                Text("選択")
                    .foregroundColor(Color(.gray))
                Image(systemName: "chevron.down")
                    .font(.system(size: 16, weight: .medium))
                    .fontWeight(.regular)
                    .foregroundColor(Color(.systemGray2))
                    .frame(width: 20, height: 20)
            }
            .padding(.vertical,8)
        }
        .familyActivityPicker(
            isPresented: $isPresented,
            selection: $selection
        )
    }
}
