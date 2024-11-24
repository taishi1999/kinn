import SwiftUI
import SwiftSVG
import FamilyControls

struct CustomNavigationBar: View {
    let title: String
    let onBack: (() -> Void)?
    let onAction: (() -> Void)?

    var body: some View {
        HStack {
            if let onBack = onBack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                }
            } else {
                Spacer()
            }

            Spacer()

            Text(title)
                .font(.headline)
                .foregroundColor(.white)

            Spacer()

            if let onAction = onAction {
                Button(action: onAction) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.white)
                }
            } else {
                Spacer()
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 16) // 上下のパディングを設定
        .background(Color.blue)
    }
}

struct CustomNavigationBar_Previews: PreviewProvider {
    static var previews: some View {

        SecondView()

//            CustomNavigationBar(
//                title: "プレビュー",
//                onBack: nil,
//                onAction: nil
//            )
//            .previewDisplayName("Without Buttons")

        .previewLayout(.sizeThatFits) // サイズを内容に合わせる
    }
}

struct OnboardingView: View {
    @State private var isPresented = false
    @State private var activitySelection = FamilyActivitySelection()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Spacer()
                    .frame(height:20)
                VStack(spacing: 8) {
                    Text("ブロックしたいアプリを\n選択しましょう")
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                    Text("あとから変更できます")
                        .fontWeight(.bold)
                        .foregroundStyle(Color.secondary)
                }
                Spacer()
                    .frame(height: 40)
                ZStack {
                    Image("iPhone15_Pro_app_picker_png") // 画像ファイル名（拡張子不要）
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                    VStack(spacing:0) {
                        Spacer()
                        パーツ_ライナーグラデーション(height: 100)
                        VStack{
                            NavigationLink(destination: SecondView()) {
                                Text("ボタンテキスト") // ボタンの内容
                                    .padding(.vertical, 16)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.buttonOrange)
                                    .foregroundColor(.white)
                                    .fontWeight(.bold)
                                    .cornerRadius(12)

                            }
                            .padding(.vertical, 20)


                            Text("")
                                .foregroundStyle(.primary)

//                                .opacity(00)
                        }
                        .background(Color(.systemBackground))

                    }
                }
                Spacer()
                    .frame(height: 20)

                // 通常のボタンとして表示されるテキストボタン


                // パーツ_ボタン_メインを使用した遷移ボタン
//                NavigationLink(destination: SecondView()) {
//                    パーツ_ボタン_メイン(
//                        フラグ_日記エディタ表示: $isPresented,
//                        ボタンテキスト: "次へ"
//                    )
//                }
            }
            .toolbar {
                            ToolbarItem(placement: .principal) {
                                Text("")
                            }
                        }
            .navigationBarTitleDisplayMode(.inline)
            .padding(.horizontal, 20)

        }
    }
}

struct SecondView: View {
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height:20)
            VStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("ブロックしたい時間帯を\n設定しましょう")
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading) // 左揃えにする
                        .frame(maxWidth: .infinity, alignment: .leading) // 左寄せのフレーム設定

                    Text("あとから変更できます")
                        .fontWeight(.bold)
                        .foregroundStyle(Color.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading) // 左寄せのフレーム設定
                }

            }
            Spacer()
                .frame(height: 40)
            ZStack {
                Image("iPhone15_Pro_app_picker_png") // 画像ファイル名（拡張子不要）
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                VStack(spacing:0) {
                    Spacer()
                    パーツ_ライナーグラデーション(height: 100)
                    VStack{
                        NavigationLink(destination: SecondView()) {
                            Text("ボタンテキスト") // ボタンの内容
                                .padding(.vertical, 16)
                                .frame(maxWidth: .infinity)
                                .background(Color.buttonOrange)
                                .foregroundColor(.white)
                                .fontWeight(.bold)
                                .cornerRadius(12)

                        }
                        .padding(.vertical, 20)


                        Text("")
                            .foregroundStyle(.primary)

//                                .opacity(00)
                    }
                    .background(Color(.systemBackground))

                }
            }
            Spacer()
                .frame(height: 20)

        }
        .toolbar {
                        ToolbarItem(placement: .principal) {
                            Text("")
                        }
                    }
        .navigationBarTitleDisplayMode(.inline)
        .padding(.horizontal, 20)
    }
}



struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}


struct ビュー_ブロック状態監視: View {
    @StateObject private var 状態監視: ブロック状態監視

    init(startTime: Date, endTime: Date, repeatDaysString: String) {
        let repeatDays = repeatDaysString
            .split(separator: ",")
            .compactMap { Int($0) }

        _状態監視 = StateObject(wrappedValue: ブロック状態監視(
            startTime: startTime,
            endTime: endTime,
            repeatDays: repeatDays
        ))
    }

    var body: some View {
        VStack {
            Text("現在のブロック状態:")
                .font(.headline)

            Text(状態監視.現在の状態Text)
                .font(.largeTitle)
                .padding()

            Text("次の状態変化までの残り時間: \(状態監視.残り時間Text)")
                .font(.title2)
                .padding()

            Spacer()
        }
        .padding()
    }
}

// プレビュー用コード
struct ビュー_ブロック状態監視_Previews: PreviewProvider {
    static var previews: some View {
        ビュー_ブロック状態監視(
            startTime: Calendar.current.date(bySettingHour: 18, minute: 0, second: 0, of: Date())!,
            endTime: Calendar.current.date(bySettingHour: 16, minute: 0, second: 0, of: Date())!,
            repeatDaysString: "0,1,2,3,4,5,6"
        )
    }
}
