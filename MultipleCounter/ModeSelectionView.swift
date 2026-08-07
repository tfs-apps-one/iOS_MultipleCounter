//
//  ModeSelectionView.swift
//  MultipleCounter
//
//  アプリ起動時のメニュー画面。
//  「通常モード」（従来の20カウンター機能）と
//  「試合モード」（A/Bグループ集計付き）を選択できる。
//

import SwiftUI

/// メニューから遷移する先のモード
private enum AppMode: String, Identifiable {
    case normal
    case match

    var id: String { rawValue }
}

struct ModeSelectionView: View {
    @ObservedObject var store: CounterStore
    @State private var activeMode: AppMode?

    var body: some View {
        NavigationStack {
            ZStack {
                // 白ベースのやさしいグラデーション背景（他画面と統一）
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

                VStack(spacing: 28) {
                    Spacer(minLength: 12)

                    VStack(spacing: 6) {
                        Text(String(localized: "mode_selection_header_title"))
                            .font(.title2).bold()
                            .foregroundColor(.black)
                        Text(String(localized: "mode_selection_header_subtitle"))
                            .font(.subheadline)
                            .foregroundColor(.black.opacity(0.6))
                    }

                    VStack(spacing: 16) {
                        ModeCard(
                            icon: "square.grid.3x3.fill",
                            iconColor: .blue,
                            title: String(localized: "mode_normal_title"),
                            description: String(localized: "mode_normal_desc")
                        ) {
                            activeMode = .normal
                        }
                        .accessibilityLabel(String(localized: "accessibility_select_normal_mode"))

                        ModeCard(
                            icon: "sportscourt.fill",
                            iconColor: .red,
                            title: String(localized: "mode_match_title"),
                            description: String(localized: "mode_match_desc")
                        ) {
                            activeMode = .match
                        }
                        .accessibilityLabel(String(localized: "accessibility_select_match_mode"))
                    }
                    .padding(.horizontal, 20)

                    Spacer()
                }
            }
            .navigationTitle(String(localized: "mode_selection_nav_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color(.systemGray4), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .fullScreenCover(item: $activeMode) { mode in
            switch mode {
            case .normal:
                ContentView(store: store)
            case .match:
                MatchModeView(store: store)
            }
        }
    }
}

/// メニュー画面のモード選択カード
private struct ModeCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 30))
                    .foregroundColor(iconColor)
                    .frame(width: 44, height: 44)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.black)
                    Text(description)
                        .font(.footnote)
                        .foregroundColor(.black.opacity(0.6))
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.black.opacity(0.3))
            }
            .padding(16)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.black.opacity(0.08), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ModeSelectionView(store: CounterStore())
}
