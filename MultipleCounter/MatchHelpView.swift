//
//  MatchHelpView.swift
//  MultipleCounter
//
//  試合モードの使い方を表示するシート
//

import SwiftUI

struct MatchHelpView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    headerSection

                    Divider()
                        .background(Color.black.opacity(0.2))

                    HelpRow(
                        icon: "square.split.2x1.fill",
                        iconColor: .blue,
                        title: String(localized: "match_help_group_title"),
                        description: String(localized: "match_help_group_desc")
                    )

                    HelpRow(
                        icon: "timer",
                        iconColor: .green,
                        title: String(localized: "match_help_timer_title"),
                        description: String(localized: "match_help_timer_desc")
                    )

                    HelpRow(
                        icon: "hand.tap.fill",
                        iconColor: .blue,
                        title: String(localized: "help_tap_title"),
                        description: String(localized: "help_tap_desc")
                    )

                    HelpRow(
                        icon: "hand.point.up.left.fill",
                        iconColor: .orange,
                        title: String(localized: "help_longpress_title"),
                        description: String(localized: "help_longpress_desc")
                    )

                    HelpRow(
                        icon: "gearshape.fill",
                        iconColor: .purple,
                        title: String(localized: "match_help_settings_title"),
                        description: String(localized: "match_help_settings_desc")
                    )

                    HelpRow(
                        icon: "arrow.counterclockwise.circle",
                        iconColor: .red,
                        title: String(localized: "btn_reset_all"),
                        description: String(localized: "help_reset_desc")
                    )

                    HelpRow(
                        icon: "chevron.backward",
                        iconColor: .indigo,
                        title: String(localized: "btn_back_to_menu"),
                        description: String(localized: "match_help_back_desc")
                    )
                }
                .padding(20)
                .foregroundColor(.black) // 全文字を黒色に固定
            }
            .background(
                // 白ベースのやさしいグラデーション
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.white,
                        Color(red: 0.96, green: 0.97, blue: 1.00),
                        Color(red: 0.92, green: 0.94, blue: 0.99)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .scrollContentBackground(.hidden)
            .navigationTitle(String(localized: "match_help_nav_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color(.systemGray5), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "btn_close")) { dismiss() }
                        .foregroundColor(.black)
                }
            }
            .preferredColorScheme(.light) // シート単位でもライト固定
        }
    }

    private var headerSection: some View {
        HStack(spacing: 12) {
            Image(systemName: "sportscourt.fill")
                .font(.system(size: 36))
                .foregroundColor(.red)
            VStack(alignment: .leading, spacing: 2) {
                Text(String(localized: "match_help_header_title"))
                    .font(.title3).bold()
                    .foregroundColor(.black)
                Text(String(localized: "match_help_header_subtitle"))
                    .font(.footnote)
                    .foregroundColor(.black.opacity(0.7))
            }
            Spacer()
        }
    }
}

private struct HelpRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(iconColor)
                .frame(width: 32, height: 32)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.black)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.black) // 黒色で固定
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

#Preview {
    MatchHelpView()
}
