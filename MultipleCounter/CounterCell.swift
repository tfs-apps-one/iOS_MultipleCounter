//
//  CounterCell.swift
//  MultipleCounter
//
//  カウンター1個分のラベル表示。タップで+1、長押しで-1。
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct CounterCell: View {
    let item: CounterItem
    let color: CounterColor
    let onIncrement: () -> Void
    let onDecrement: () -> Void

    @State private var isPressed: Bool = false

    var body: some View {
        VStack(spacing: 6) {
            Text(item.name)
                .font(.headline)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .padding(.horizontal, 8)
            Text("\(item.count)")
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
        .foregroundStyle(color.foreground)
        .frame(maxWidth: .infinity, minHeight: 110)
        .padding(.vertical, 10)
        .background(color.background)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.black.opacity(0.20), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .animation(.easeOut(duration: 0.1), value: isPressed)
        .contentShape(Rectangle())
        // 長押しで -1
        .onLongPressGesture(minimumDuration: 0.45, maximumDistance: 20) {
            triggerHaptic(style: .heavy)
            onDecrement()
        } onPressingChanged: { pressing in
            isPressed = pressing
        }
        // タップで +1
        .onTapGesture {
            triggerHaptic(style: .light)
            onIncrement()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.name)、現在のカウント \(item.count)")
        .accessibilityHint("タップで1増やし、長押しで1減らします")
    }

    private func triggerHaptic(style: HapticStyle) {
#if canImport(UIKit)
        let generator: UIImpactFeedbackGenerator
        switch style {
        case .light:  generator = UIImpactFeedbackGenerator(style: .light)
        case .heavy:  generator = UIImpactFeedbackGenerator(style: .medium)
        }
        generator.impactOccurred()
#endif
    }

    private enum HapticStyle { case light, heavy }
}

#Preview {
    CounterCell(
        item: CounterItem(id: 0, name: "ラベル1", count: 12),
        color: counterColors[0],
        onIncrement: {},
        onDecrement: {}
    )
    .padding()
}
