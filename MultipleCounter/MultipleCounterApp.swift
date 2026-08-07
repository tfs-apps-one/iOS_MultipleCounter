//
//  MultipleCounterApp.swift
//  MultipleCounter
//
//  Created by 古川貴史 on 2026/05/04.
//

import SwiftUI

@main
struct MultipleCounterApp: App {
    // 通常モード・試合モードで同じ20個のカウントデータを共有するため、
    // ストアはアプリのルートで1つだけ生成する。
    @StateObject private var store = CounterStore()

    var body: some Scene {
        WindowGroup {
            ModeSelectionView(store: store)
                // アプリ全体をライトモード固定（ダークモード無効）
                .preferredColorScheme(.light)
        }
    }
}
