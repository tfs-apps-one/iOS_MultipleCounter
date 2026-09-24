//
//  MatchModeView.swift
//  MultipleCounter
//
//  試合モード画面。
//  ・Aグループ（ラベル1〜10）／Bグループ（ラベル11〜20）の合計値を
//    スコアボード風に上部へリアルタイム表示
//  ・スコアボードの上にカウントダウンタイマーを表示（⚙️で設定した時間から開始）
//  ・タイマーが0になるとブザーを鳴らして知らせる
//  ・各セルの操作（タップ＋1／長押し－1）は通常モードと共通
//

import SwiftUI

struct MatchModeView: View {
    @ObservedObject var store: CounterStore
    @StateObject private var timerEngine = MatchTimerEngine()
    @State private var showingResetAlert = false
    @State private var showingMatchSettings = false
    @State private var showingMatchHelp = false
    @Environment(\.dismiss) private var dismiss

    private let columns: [GridItem] = [
        GridItem(.adaptive(minimum: 130), spacing: 10)
    ]

    var body: some View {
        NavigationStack {
            ZStack {
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
                    VStack(spacing: 20) {
                        timerSection

                        scoreboardSection

                        groupSection(
                            title: store.groupAName,
                            items: store.groupAItems,
                            tint: groupATint
                        )

                        groupSection(
                            title: store.groupBName,
                            items: store.groupBItems,
                            tint: groupBTint
                        )
                    }
                    .padding(.horizontal, 12)
                    .padding(.top, 14)
                    .padding(.bottom, 20)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(String(localized: "match_nav_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color(.systemGray4), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                // 左上：メニューへ戻る／全リセット（通常モードと同じ並び順・配置）
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
                    // タイトル中央付近に「?」ヘルプボタンを配置（通常モードと同様）
                    HStack(spacing: 6) {
                        Text(String(localized: "match_nav_title")).font(.headline)
                        Button {
                            showingMatchHelp = true
                        } label: {
                            Image(systemName: "questionmark.circle")
                                .font(.system(size: 18, weight: .semibold))
                        }
                        .accessibilityLabel(String(localized: "accessibility_show_match_help"))
                    }
                }
                // 右上：設定（ラベル名・グループ名・タイマー値をまとめて編集）
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingMatchSettings = true
                    } label: {
                        Label(String(localized: "btn_match_settings"), systemImage: "gearshape")
                    }
                    .accessibilityLabel(String(localized: "accessibility_match_settings"))
                }
            }
            .sheet(isPresented: $showingMatchSettings) {
                MatchSettingsView(store: store)
            }
            .sheet(isPresented: $showingMatchHelp) {
                MatchHelpView()
            }
            .alert(String(localized: "alert_reset_title"), isPresented: $showingResetAlert) {
                Button(String(localized: "btn_cancel"), role: .cancel) {}
                Button(String(localized: "btn_reset"), role: .destructive) {
                    store.resetAll()
                }
            } message: {
                Text(String(localized: "alert_reset_message"))
            }
            .onAppear {
                timerEngine.configure(totalSeconds: store.timerDurationSeconds)
            }
            .onChange(of: store.timerDurationSeconds) { _, newValue in
                timerEngine.configure(totalSeconds: newValue)
            }
        }
    }

    // MARK: - タイマー

    private var timerSection: some View {
        VStack(spacing: 10) {
            Text(timerEngine.formattedTime)
                .font(.system(size: 48, weight: .heavy, design: .rounded))
                .monospacedDigit()
                .foregroundColor(timerTextColor)
                .animation(.easeInOut(duration: 0.2), value: timerEngine.remainingSeconds)

            if timerEngine.didFinish {
                Text(String(localized: "match_timer_time_up"))
                    .font(.subheadline).bold()
                    .foregroundColor(.red)
                    .transition(.opacity)
            }

            HStack(spacing: 14) {
                Button {
                    if timerEngine.isRunning {
                        timerEngine.pause()
                    } else {
                        timerEngine.start()
                    }
                } label: {
                    Label(
                        timerEngine.isRunning ? String(localized: "btn_timer_pause") : String(localized: "btn_timer_start"),
                        systemImage: timerEngine.isRunning ? "pause.fill" : "play.fill"
                    )
                    .font(.subheadline).bold()
                }
                .buttonStyle(.borderedProminent)
                .tint(timerEngine.isRunning ? .orange : .green)
                .disabled(timerEngine.remainingSeconds == 0 && !timerEngine.isRunning)
                .accessibilityLabel(timerEngine.isRunning ? String(localized: "accessibility_timer_pause") : String(localized: "accessibility_timer_start"))

                Button {
                    timerEngine.reset()
                } label: {
                    Label(String(localized: "btn_timer_reset"), systemImage: "arrow.counterclockwise")
                        .font(.subheadline).bold()
                }
                .buttonStyle(.bordered)
                .tint(.gray)
                .accessibilityLabel(String(localized: "accessibility_timer_reset"))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.04))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.black.opacity(0.08), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(String(format: NSLocalizedString("accessibility_timer_value_format", comment: ""), timerEngine.formattedTime))
    }

    private var timerTextColor: Color {
        if timerEngine.didFinish {
            return .red
        }
        if timerEngine.remainingSeconds <= 10 && timerEngine.remainingSeconds > 0 {
            return .red
        }
        return .black.opacity(0.85)
    }

    // MARK: - スコアボード

    private var groupATint: Color { Color(red: 0.10, green: 0.45, blue: 0.95) }
    private var groupBTint: Color { Color(red: 0.90, green: 0.20, blue: 0.20) }

    private var scoreboardSection: some View {
        HStack(spacing: 10) {
            ScoreCard(
                title: store.groupAName,
                subtitle: String(localized: "match_group_a_range"),
                score: store.groupASum,
                tint: groupATint
            )

            Text("VS")
                .font(.system(size: 16, weight: .heavy, design: .rounded))
                .foregroundColor(.black.opacity(0.4))

            ScoreCard(
                title: store.groupBName,
                subtitle: String(localized: "match_group_b_range"),
                score: store.groupBSum,
                tint: groupBTint
            )
        }
    }

    // MARK: - グループごとのグリッド

    private func groupSection(title: String, items: [CounterItem], tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(tint)
                    .frame(width: 4, height: 16)
                Text(title)
                    .font(.subheadline).bold()
                    .foregroundColor(.black.opacity(0.7))
            }
            .padding(.horizontal, 4)

            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(items) { item in
                    CounterCell(
                        item: item,
                        color: store.color(for: item.id),
                        onIncrement: { store.increment(id: item.id) },
                        onDecrement: { store.decrement(id: item.id) }
                    )
                }
            }
        }
    }
}

/// スコアボード風に合計値を強調表示するカード
private struct ScoreCard: View {
    let title: String
    let subtitle: String
    let score: Int
    let tint: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.footnote).bold()
                .foregroundColor(.white.opacity(0.85))
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.6))
            Text("\(score)")
                .font(.system(size: 44, weight: .heavy, design: .rounded))
                .monospacedDigit()
                .foregroundColor(.white)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .padding(.top, 2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black.opacity(0.92),
                    tint.opacity(0.55)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(tint.opacity(0.8), lineWidth: 1.5)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: tint.opacity(0.35), radius: 8, x: 0, y: 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title) \(subtitle) \(score)")
    }
}

#Preview {
    MatchModeView(store: CounterStore())
}
