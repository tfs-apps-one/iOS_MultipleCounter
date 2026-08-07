//
//  MultipleCounterTests.swift
//  MultipleCounterTests
//
//  Created by 古川貴史 on 2026/05/04.
//

import Testing
@testable import MultipleCounter

struct MultipleCounterTests {

    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    }

    // MARK: - 試合モード：A/Bグループ合計

    @Test func groupSumsStartAtZero() async throws {
        let store = CounterStore(defaults: Self.makeIsolatedDefaults())
        #expect(store.groupASum == 0)
        #expect(store.groupBSum == 0)
    }

    @Test func groupASumMatchesSpecExample() async throws {
        // ラベル1=3, ラベル5=5 の場合 ➔ Aグループ合計 = 8
        let store = CounterStore(defaults: Self.makeIsolatedDefaults())
        for _ in 0..<3 { store.increment(id: 0) }  // ラベル1 (index 0)
        for _ in 0..<5 { store.increment(id: 4) }  // ラベル5 (index 4)
        #expect(store.groupASum == 8)
        #expect(store.groupBSum == 0)
    }

    @Test func groupBSumMatchesSpecExample() async throws {
        // ラベル13=3, ラベル15=5, ラベル19=12 の場合 ➔ Bグループ合計 = 20
        let store = CounterStore(defaults: Self.makeIsolatedDefaults())
        for _ in 0..<3 { store.increment(id: 12) }  // ラベル13 (index 12)
        for _ in 0..<5 { store.increment(id: 14) }  // ラベル15 (index 14)
        for _ in 0..<12 { store.increment(id: 18) } // ラベル19 (index 18)
        #expect(store.groupASum == 0)
        #expect(store.groupBSum == 20)
    }

    @Test func groupSumsUpdateOnDecrementAndReset() async throws {
        let store = CounterStore(defaults: Self.makeIsolatedDefaults())
        store.increment(id: 0)
        store.increment(id: 0)
        store.decrement(id: 0)
        #expect(store.groupASum == 1)

        store.increment(id: 19)
        #expect(store.groupBSum == 1)

        store.resetAll()
        #expect(store.groupASum == 0)
        #expect(store.groupBSum == 0)
    }

    // MARK: - 試合モード：グループ名編集・永続化

    @Test func groupNamesDefaultToLocalizedTitles() async throws {
        let store = CounterStore(defaults: Self.makeIsolatedDefaults())
        #expect(store.groupAName == NSLocalizedString("match_group_a_title", comment: ""))
        #expect(store.groupBName == NSLocalizedString("match_group_b_title", comment: ""))
    }

    @Test func groupNamesPersistAcrossStoreInstances() async throws {
        let defaults = Self.makeIsolatedDefaults()
        let store1 = CounterStore(defaults: defaults)
        store1.groupAName = "赤組"
        store1.groupBName = "白組"
        store1.save()

        let store2 = CounterStore(defaults: defaults)
        #expect(store2.groupAName == "赤組")
        #expect(store2.groupBName == "白組")
    }

    /// テスト間で永続化データが共有されないよう、実行ごとに独立した UserDefaults を用意する。
    private static func makeIsolatedDefaults() -> UserDefaults {
        let suiteName = "MultipleCounterTests.\(UUID().uuidString)"
        return UserDefaults(suiteName: suiteName)!
    }

}
