//
//  MatchSettingsView.swift
//  MultipleCounter
//
//  試合モードの設定シート（歯車ボタンから開く）。
//  ・ラベル名称の設定（ラベル1〜20の名前をAグループ／Bグループ別に編集）
//  ・グループ名称の設定（Aグループ／Bグループの表示名を編集）
//  ・タイマー値の設定（カウントダウンタイマーの開始時間を分・秒で設定）
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct MatchSettingsView: View {
    @ObservedObject var store: CounterStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text(String(localized: "match_settings_desc"))
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }

                // MARK: ① ラベル名称の設定
                Section(String(localized: "match_settings_labels_group_a_header")) {
                    ForEach(Array(matchGroupARange), id: \.self) { idx in
                        labelNameField(for: idx)
                    }
                }

                Section(String(localized: "match_settings_labels_group_b_header")) {
                    ForEach(Array(matchGroupBRange), id: \.self) { idx in
                        labelNameField(for: idx)
                    }
                }

                // MARK: ② グループ名称の設定
                Section(String(localized: "match_settings_section_groups")) {
                    HStack {
                        Text(String(localized: "match_group_a_field_label"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(minWidth: 90, alignment: .leading)
                        TextField(String(localized: "placeholder_name"), text: $store.groupAName)
                            .submitLabel(.done)
                            .onSubmit { store.save() }
                    }
                    HStack {
                        Text(String(localized: "match_group_b_field_label"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(minWidth: 90, alignment: .leading)
                        TextField(String(localized: "placeholder_name"), text: $store.groupBName)
                            .submitLabel(.done)
                            .onSubmit { store.save() }
                    }
                }

                // MARK: ③ タイマー値の設定
                Section {
                    Text(String(localized: "match_settings_timer_desc"))
                        .font(.footnote)
                        .foregroundColor(.secondary)

                    HStack(spacing: 4) {
                        Picker(String(localized: "match_settings_timer_minutes_label"), selection: minutesBinding) {
                            ForEach(0..<60, id: \.self) { minute in
                                Text(String(format: "%02d", minute)).tag(minute)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(maxWidth: .infinity)
                        .clipped()

                        Text(String(localized: "match_settings_timer_minutes_unit"))
                            .foregroundColor(.secondary)

                        Picker(String(localized: "match_settings_timer_seconds_label"), selection: secondsBinding) {
                            ForEach(Array(stride(from: 0, to: 60, by: 5)), id: \.self) { second in
                                Text(String(format: "%02d", second)).tag(second)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(maxWidth: .infinity)
                        .clipped()

                        Text(String(localized: "match_settings_timer_seconds_unit"))
                            .foregroundColor(.secondary)
                    }
                    .frame(height: 110)
                } header: {
                    Text(String(localized: "match_settings_section_timer"))
                } footer: {
                    Text(String(format: NSLocalizedString("match_settings_timer_current_format", comment: ""), formattedTimerDuration))
                }
            }
            .navigationTitle(String(localized: "match_settings_nav_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
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

    // MARK: - ラベル名編集用の1行

    private func labelNameField(for idx: Int) -> some View {
        HStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 4)
                .fill(store.color(for: idx).background)
                .frame(width: 14, height: 24)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.gray.opacity(0.4), lineWidth: 0.5)
                )

            if let itemIndex = store.items.firstIndex(where: { $0.id == idx }) {
                TextField(String(localized: "placeholder_name"), text: $store.items[itemIndex].name)
                    .submitLabel(.done)
                    .onSubmit { store.save() }
            }
        }
    }

    // MARK: - タイマー値のバインディング（分・秒 ⇔ 合計秒数）

    private var minutesBinding: Binding<Int> {
        Binding(
            get: { store.timerDurationSeconds / 60 },
            set: { newValue in
                let seconds = store.timerDurationSeconds % 60
                store.timerDurationSeconds = newValue * 60 + seconds
                store.save()
            }
        )
    }

    private var secondsBinding: Binding<Int> {
        Binding(
            get: { store.timerDurationSeconds % 60 },
            set: { newValue in
                let minutes = store.timerDurationSeconds / 60
                store.timerDurationSeconds = minutes * 60 + newValue
                store.save()
            }
        )
    }

    private var formattedTimerDuration: String {
        let minutes = store.timerDurationSeconds / 60
        let seconds = store.timerDurationSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    MatchSettingsView(store: CounterStore())
}
