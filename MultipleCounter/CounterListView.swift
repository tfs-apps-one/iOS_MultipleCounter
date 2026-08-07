//
//  CounterListView.swift
//  MultipleCounter
//
//  全カウンターを一画面で確認・名前編集／カウント数編集できるシート画面
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct CounterListView: View {
    @ObservedObject var store: CounterStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                ForEach($store.items) { $item in
                    HStack(spacing: 10) {
                        // 色チップ
                        RoundedRectangle(cornerRadius: 4)
                            .fill(store.color(for: item.id).background)
                            .frame(width: 14, height: 28)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.gray.opacity(0.4), lineWidth: 0.5)
                            )

                        // 名前入力
                        TextField(String(localized: "placeholder_name"), text: $item.name)
                            .textFieldStyle(.roundedBorder)
                            .submitLabel(.done)
                            .onSubmit { store.save() }

                        // カウント数入力（数字キーパッド）
                        TextField("0", value: $item.count, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .textFieldStyle(.roundedBorder)
                            .monospacedDigit()
                            .frame(width: 72)
                            .submitLabel(.done)
                            .onSubmit { store.save() }
                    }
                    // 行間をぐっと詰める
                    .listRowInsets(EdgeInsets(top: 4, leading: 14, bottom: 4, trailing: 14))
                    .listRowSeparator(.visible)
                }
            }
            .listStyle(.plain)
            .navigationTitle(String(localized: "list_nav_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // キーボードの上に「閉じる」ボタンを出して数値入力を確定しやすくする
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button(String(localized: "btn_close")) {
                        UIApplication.shared.sendAction(
                            #selector(UIResponder.resignFirstResponder),
                            to: nil, from: nil, for: nil
                        )
                        store.save()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "btn_done")) {
                        store.save()
                        dismiss()
                    }
                }
            }
            .onDisappear {
                store.save()
            }
        }
    }
}

#Preview {
    CounterListView(store: CounterStore())
}
