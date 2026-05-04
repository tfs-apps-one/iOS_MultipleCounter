//
//  MultipleCounterApp.swift
//  MultipleCounter
//
//  Created by 古川貴史 on 2026/05/04.
//

import SwiftUI

@main
struct MultipleCounterApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                // アプリ全体をライトモード固定（ダークモード無効）
                .preferredColorScheme(.light)
        }
    }
}
