//
//  MatchGroupNameEditView.swift
//  MultipleCounter
//
//  試合モードのAグループ／Bグループの表示名を編集するシート画面
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct MatchGroupNameEditView: View {
    @ObservedObject var store: CounterStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text(String(localized: "match_group_name_edit_desc"))
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }

                Section(String(localized: "match_group_a_field_label")) {
                    TextField(String(localized: "placeholder_name"), text: $store.groupAName)
                        .submitLabel(.done)
                        .onSubmit { store.save() }
                }

                Section(String(localized: "match_group_b_field_label")) {
                    TextField(String(localized: "placeholder_name"), text: $store.groupBName)
                        .submitLabel(.done)
                        .onSubmit { store.save() }
                }
            }
            .navigationTitle(String(localized: "match_group_name_edit_nav_title"))
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
}

#Preview {
    MatchGroupNameEditView(store: CounterStore())
}
