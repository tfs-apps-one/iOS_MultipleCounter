//
//  CounterModels.swift
//  MultipleCounter
//
//  カウンターのデータモデル、永続化、配色定義
//

import Foundation
import SwiftUI

// MARK: - データモデル

/// 1つ分のカウンター情報
struct CounterItem: Identifiable, Codable, Equatable {
    var id: Int       // 0..<20 の固定インデックス（色の対応にも使う）
    var name: String  // ラベル名
    var count: Int    // 現在のカウント数
}

// MARK: - 配色

/// ラベル1個分の配色
struct CounterColor {
    let background: Color
    let foreground: Color
    let displayName: String
}

/// 20色分のパレット。代表的な色を割り当てる（すべて異なる色）。
/// 文字色は背景色に対する視認性で決定している。
let counterColors: [CounterColor] = [
    CounterColor(background: Color(red: 0.90, green: 0.20, blue: 0.20), foreground: .white, displayName: "赤"),
    CounterColor(background: Color(red: 0.10, green: 0.45, blue: 0.95), foreground: .white, displayName: "青"),
    CounterColor(background: Color(red: 0.15, green: 0.70, blue: 0.30), foreground: .white, displayName: "緑"),
    CounterColor(background: Color(red: 1.00, green: 0.85, blue: 0.10), foreground: .black, displayName: "黄"),
    CounterColor(background: Color(red: 1.00, green: 0.55, blue: 0.10), foreground: .white, displayName: "オレンジ"),
    CounterColor(background: Color(red: 0.60, green: 0.25, blue: 0.75), foreground: .white, displayName: "紫"),
    CounterColor(background: Color(red: 1.00, green: 0.55, blue: 0.75), foreground: .black, displayName: "ピンク"),
    CounterColor(background: Color(red: 0.20, green: 0.80, blue: 0.85), foreground: .black, displayName: "シアン"),
    CounterColor(background: Color(red: 0.55, green: 0.90, blue: 0.65), foreground: .black, displayName: "ミント"),
    CounterColor(background: Color(red: 0.30, green: 0.30, blue: 0.65), foreground: .white, displayName: "インディゴ"),
    CounterColor(background: Color(red: 0.05, green: 0.55, blue: 0.55), foreground: .white, displayName: "ティール"),
    CounterColor(background: Color(red: 0.60, green: 0.40, blue: 0.20), foreground: .white, displayName: "茶"),
    CounterColor(background: Color(red: 0.55, green: 0.55, blue: 0.55), foreground: .white, displayName: "グレー"),
    CounterColor(background: Color(red: 0.05, green: 0.05, blue: 0.05), foreground: .white, displayName: "黒"),
    CounterColor(background: Color(red: 1.00, green: 1.00, blue: 1.00), foreground: .black, displayName: "白"),
    CounterColor(background: Color(red: 0.85, green: 0.70, blue: 0.10), foreground: .black, displayName: "ゴールド"),
    CounterColor(background: Color(red: 0.75, green: 0.75, blue: 0.78), foreground: .black, displayName: "シルバー"),
    CounterColor(background: Color(red: 0.50, green: 0.00, blue: 0.10), foreground: .white, displayName: "ワインレッド"),
    CounterColor(background: Color(red: 0.05, green: 0.10, blue: 0.40), foreground: .white, displayName: "ネイビー"),
    CounterColor(background: Color(red: 0.55, green: 0.85, blue: 0.10), foreground: .black, displayName: "ライム")
]

/// カウンターの個数（要件: 最大20個）
let counterTotal: Int = 20

// MARK: - 永続化付きストア

/// UserDefaults を使って状態を永続化するストア。
/// アプリを閉じても名前とカウント数が保存される。
final class CounterStore: ObservableObject {

    @Published var items: [CounterItem] = []

    /// 試合モードのAグループ／Bグループの表示名（編集可能・永続化対象）
    @Published var groupAName: String = ""
    @Published var groupBName: String = ""

    private let storageKey = "MultipleCounter.items.v1"
    private let groupANameKey = "MultipleCounter.groupAName.v1"
    private let groupBNameKey = "MultipleCounter.groupBName.v1"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        load()
    }

    // MARK: 永続化

    private func load() {
        if let data = defaults.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([CounterItem].self, from: data),
           decoded.count == counterTotal {
            items = decoded
        } else {
            items = (0..<counterTotal).map { idx in
                CounterItem(id: idx, name: String(format: NSLocalizedString("default_label_format", comment: ""), idx + 1), count: 0)
            }
            save()
        }

        groupAName = defaults.string(forKey: groupANameKey) ?? NSLocalizedString("match_group_a_title", comment: "")
        groupBName = defaults.string(forKey: groupBNameKey) ?? NSLocalizedString("match_group_b_title", comment: "")
    }

    func save() {
        if let data = try? JSONEncoder().encode(items) {
            defaults.set(data, forKey: storageKey)
        }
        defaults.set(groupAName, forKey: groupANameKey)
        defaults.set(groupBName, forKey: groupBNameKey)
    }

    // MARK: 操作

    func increment(id: Int) {
        guard let idx = items.firstIndex(where: { $0.id == id }) else { return }
        items[idx].count &+= 1
        save()
    }

    func decrement(id: Int) {
        guard let idx = items.firstIndex(where: { $0.id == id }) else { return }
        items[idx].count &-= 1
        save()
    }

    func resetAll() {
        for i in items.indices {
            items[i].count = 0
        }
        save()
    }

    func updateName(id: Int, name: String) {
        guard let idx = items.firstIndex(where: { $0.id == id }) else { return }
        items[idx].name = name
        save()
    }

    /// indexに対応する配色を返す
    func color(for id: Int) -> CounterColor {
        counterColors[id % counterColors.count]
    }

    // MARK: - 試合モード用グループ集計

    /// Aグループ（ラベル1〜10 / index 0〜9）の合計値
    var groupASum: Int {
        items.filter { matchGroupARange.contains($0.id) }.reduce(0) { $0 + $1.count }
    }

    /// Bグループ（ラベル11〜20 / index 10〜19）の合計値
    var groupBSum: Int {
        items.filter { matchGroupBRange.contains($0.id) }.reduce(0) { $0 + $1.count }
    }

    /// Aグループに属するアイテム（ラベル1〜10）
    var groupAItems: [CounterItem] {
        items.filter { matchGroupARange.contains($0.id) }
    }

    /// Bグループに属するアイテム（ラベル11〜20）
    var groupBItems: [CounterItem] {
        items.filter { matchGroupBRange.contains($0.id) }
    }
}

/// Aグループのindex範囲（ラベル1〜10）
let matchGroupARange: Range<Int> = 0..<10
/// Bグループのindex範囲（ラベル11〜20）
let matchGroupBRange: Range<Int> = 10..<20
