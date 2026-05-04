//
//  HelpView.swift
//  MultipleCounter
//
//  アプリの使い方を表示するシート
//

import SwiftUI

struct HelpView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    headerSection

                    Divider()
                        .background(Color.black.opacity(0.2))

                    HelpRow(
                        icon: "hand.tap.fill",
                        iconColor: .blue,
                        title: "タップで ＋1",
                        description: "メイン画面のラベルを軽くタップすると、そのカウントが1増えます。"
                    )

                    HelpRow(
                        icon: "hand.point.up.left.fill",
                        iconColor: .orange,
                        title: "長押しで －1",
                        description: "ラベルを長押し（約0.5秒）するとカウントが1減ります。マイナスの値も保存できます。"
                    )

                    HelpRow(
                        icon: "list.bullet.rectangle",
                        iconColor: .green,
                        title: "一覧でまとめて編集",
                        description: "右上の「一覧」ボタンを押すと、すべてのラベルを縦に並べて確認できます。\nラベル名はその場で書き換えられ、カウント数の数字部分をタップすれば直接編集（任意の数値に修正）も可能です。"
                    )

                    HelpRow(
                        icon: "arrow.counterclockwise.circle",
                        iconColor: .red,
                        title: "全リセット",
                        description: "左上の「全リセット」ボタンですべてのカウントを0に戻します。ラベル名は維持されます。"
                    )

                    HelpRow(
                        icon: "externaldrive.fill.badge.checkmark",
                        iconColor: .indigo,
                        title: "自動保存",
                        description: "ラベル名とカウント数はアプリを閉じても保存され、次回起動時に復元されます。"
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
            .navigationTitle("使い方")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color(.systemGray5), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("閉じる") { dismiss() }
                        .foregroundColor(.black)
                }
            }
            .preferredColorScheme(.light) // シート単位でもライト固定
        }
    }

    private var headerSection: some View {
        HStack(spacing: 12) {
            Image(systemName: "questionmark.circle.fill")
                .font(.system(size: 36))
                .foregroundColor(.blue)
            VStack(alignment: .leading, spacing: 2) {
                Text("MultipleCounter の使い方")
                    .font(.title3).bold()
                    .foregroundColor(.black)
                Text("最大20個までのカウントを管理できます")
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
    HelpView()
}
