//
//  パーツ_FABボタン_タスク作成.swift
//  calendar
//
//  Created by 唐崎大志 on 2024/09/22.
//

import SwiftUI

struct パーツ_FABボタン_タスク作成: View {
    @State private var isSheetPresented = false
    @State private var isButtonPressed = false
    @State private var isLongPressed = false

    @State private var isShowPopover = false
    @State private var selectedDate = Date()
    @State private var text: String = "100"

    var body: some View {
        VStack {
            Button(action: {
                print("ボタン押した0")
                // 通常のボタン動作
                withAnimation(.easeInOut(duration: 0.1)) {
                    isButtonPressed = true
                }
                // 0.1秒後にボタンを戻す
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if isLongPressed {
                        print("ボタン押した3")
                        isSheetPresented = true
                        isLongPressed = false
                    }
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isButtonPressed = false
                    }
                    // 長押しでない場合のみシートを表示
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        isSheetPresented = true
                    }
                }
            }) {
                Image(systemName: "plus")
                    .resizable()
                    .frame(width: 20, height: 20) // ボタンを少し小さくする
            }
            .buttonStyle(ボタンスタイル_バウンド(isPressed: $isButtonPressed))
//            .padding()
//            .fullScreenCover(isPresented: $isSheetPresented) {
//                ページ_タスク作成()
//            }
//            .sheet(isPresented: $isSheetPresented) {
//                ページ_タスク作成シート()
//                    .presentationDetents([.large]) // シートの表示サイズを設定
//                    .presentationCornerRadius(32) // シートの角丸を設定
//                    .presentationDragIndicator(.visible) // ドラッグインジケータを表示
//            }

            .simultaneousGesture(
                LongPressGesture(minimumDuration: 0.2) // 長押しの最短時間を0.1秒に設定
                    .onEnded { _ in
                        isLongPressed = true
                        print("Button long pressed!")
                    }
            )
        }
    }
}
