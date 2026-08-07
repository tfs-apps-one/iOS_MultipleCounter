//
//  ContentView.swift
//  MultipleCounter
//
//  Created by 古川貴史 on 2026/05/04.
//
//  最大20個のラベルをグリッド表示し、タップで＋1、長押しで－1。
//  ・全リセットボタン：すべてのカウント数を0に戻す
//  ・一覧ボタン：すべての名前とカウント数を1画面で確認・編集
//  ・名前とカウント数はアプリを閉じても保存される（UserDefaults）
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var store: CounterStore
    @State private var showingList = false
    @State private var showingResetAlert = false
    @State private var showingHelp = false
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.dismiss) private var dismiss

    // 画面幅に応じて2〜3列で並ぶよう自動調整。
    // 20個入らない場合は縦スクロール。
    private let columns: [GridItem] = [
        GridItem(.adaptive(minimum: 150), spacing: 12)
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                // 白ベースのやさしいグラデーション背景
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.white,
                        Color(red: 0.96, green: 0.97, blue: 1.00),
                        Color(red: 0.90, green: 0.93, blue: 0.99)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(store.items) { item in
                            CounterCell(
                                item: item,
                                color: store.color(for: item.id),
                                onIncrement: { store.increment(id: item.id) },
                                onDecrement: { store.decrement(id: item.id) }
                            )
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(String(localized: "nav_title_counter"))
            .navigationBarTitleDisplayMode(.inline)
            // ナビゲーションバー（リセット／一覧／タイトル）の背景をグレーに固定
            .toolbarBackground(Color(.systemGray4), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Label(String(localized: "btn_back_to_menu"), systemImage: "chevron.backward")
                    }
                    .accessibilityLabel(String(localized: "accessibility_back_to_menu"))
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showingResetAlert = true
                    } label: {
                        Label(String(localized: "btn_reset_all"), systemImage: "arrow.counterclockwise.circle")
                    }
                    .tint(.red)
                    .accessibilityLabel(String(localized: "accessibility_reset_all"))
                }
                ToolbarItem(placement: .principal) {
                    // タイトル中央付近に「?」ヘルプボタンを配置
                    HStack(spacing: 6) {
                        Text(String(localized: "nav_title_counter")).font(.headline)
                        Button {
                            showingHelp = true
                        } label: {
                            Image(systemName: "questionmark.circle")
                                .font(.system(size: 18, weight: .semibold))
                        }
                        .accessibilityLabel(String(localized: "accessibility_show_help"))
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingList = true
                    } label: {
                        Label(String(localized: "btn_list"), systemImage: "list.bullet.rectangle")
                    }
                    .accessibilityLabel(String(localized: "accessibility_show_list"))
                }
            }
            .sheet(isPresented: $showingList) {
                CounterListView(store: store)
            }
            .sheet(isPresented: $showingHelp) {
                HelpView()
            }
            .alert(String(localized: "alert_reset_title"), isPresented: $showingResetAlert) {
                Button(String(localized: "btn_cancel"), role: .cancel) {}
                Button(String(localized: "btn_reset"), role: .destructive) {
                    store.resetAll()
                }
            } message: {
                Text(String(localized: "alert_reset_message"))
            }
            .onChange(of: scenePhase) { _, newPhase in
                // バックグラウンド/非アクティブ移行時に念のため保存
                if newPhase != .active {
                    store.save()
                }
            }
        }
    }
}

#Preview {
    ContentView(store: CounterStore())
}
