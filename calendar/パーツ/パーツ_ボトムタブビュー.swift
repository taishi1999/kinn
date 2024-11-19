import SwiftUI
import SwiftSVG

struct FixedHeaderView: View {
    var body: some View {
        ZStack(alignment: .top) {
            VStack {
                // ヘッダー
                HStack {
                    Text("ヘッダー")
                        .font(.headline)
                    Spacer()
                    Image(systemName: "gearshape")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                }
                .padding()
                .background(.ultraThinMaterial)
                .zIndex(1) // ヘッダーを前面に表示

//                Spacer()

                // コンテンツ部分
                ScrollView {
                    VStack {
                        ForEach(0..<20) { index in
                            Text("コンテンツ \(index + 1)")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue.opacity(0.2))
                                .cornerRadius(8)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.top, 60) // ヘッダー分のスペースを確保
                }
            }
        }
        .edgesIgnoringSafeArea(.top) // 安全エリアを無視
    }
}

//struct FixedHeaderView_Previews: PreviewProvider {
//    static var previews: some View {
////        FixedHeaderView()
//        ページ_日記リスト()
//    }
//}

struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var date = Date()

    @Environment(\.colorScheme) var colorScheme: ColorScheme
    var body: some View {
        ZStack{
            if selectedTab == 0 {
                ZStack{
                    VStack(spacing: 0) {
                        // 上部に固定したいヘッダー
                        HStack {
                            Text("aaa")
                            Spacer()
                            Image("setting_outlined_icon")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                        }
                        .padding(.vertical,8)
                        .padding(.horizontal)
                        .background(Color.clear)

                        // コンテンツ
//                        ページ_日記リスト()
//                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            } else if selectedTab == 1 {
                EmojiView()
            }

            VStack {
                Spacer()
                HStack(spacing: 0) {
                    // タブ1のボタン
                    Button(action: {
                        selectedTab = 0
                    }) {
                        Image(selectedTab == 0 ? "home_filled_icon" : "home_regular")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 28, height: 28)
                            .padding(.vertical, 8)
                            .foregroundColor(selectedTab == 0 ? .blue : .gray)
                            .frame(maxWidth: .infinity)
                    }
                    .disabled(selectedTab == 0)

                    // タブ2のボタン
                    Button(action: {
                        selectedTab = 1
                    }) {
                        Image(selectedTab == 1 ? "ic_fluent_person_24_filled" : "ic_fluent_person_24_regular")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 28, height: 28)
                            .padding(.vertical, 8)
                            .foregroundColor(selectedTab == 1 ? .blue : .gray)
                            .frame(maxWidth: .infinity)
                    }
                    .disabled(selectedTab == 1)
                }
                .background(.ultraThinMaterial)
            }
        }
//        .edgesIgnoringSafeArea(.top)
    }
}

struct HomeView: View {
    var body: some View {
        VStack {
            Image(systemName: "house.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
            Text("Home Screen")
                .font(.title)
                .padding()
        }
    }
}

struct EmojiView: View {
    var body: some View {
        VStack {
            Spacer()
            Text("😀")
                .font(.system(size: 100))
            Text("Emoji Screen")
                .font(.title)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.green)
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
