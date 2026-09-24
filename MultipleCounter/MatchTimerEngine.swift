//
//  MatchTimerEngine.swift
//  MultipleCounter
//
//  試合モードのカウントダウンタイマー本体。
//  ・設定画面で決めた時間から1秒刻みでカウントダウン
//  ・開始／一時停止／リセットの操作を提供
//  ・0になったらブザー音を3回鳴らし、それぞれに合わせてバイブレーションも動作させて通知する
//

import Foundation
import Combine
import AVFoundation
import AudioToolbox
#if canImport(UIKit)
import UIKit
#endif

/// 試合モードのカウントダウンタイマーを管理するエンジン
final class MatchTimerEngine: ObservableObject {

    /// 残り時間（秒）
    @Published private(set) var remainingSeconds: Int
    /// カウントダウン中かどうか
    @Published private(set) var isRunning: Bool = false
    /// タイムアップ（0になった直後）かどうか
    @Published private(set) var didFinish: Bool = false

    /// 設定されているタイマーの合計時間（秒）
    private(set) var totalSeconds: Int
    private var timer: Timer?

    init(totalSeconds: Int = defaultMatchTimerDurationSeconds) {
        let clamped = max(totalSeconds, 0)
        self.totalSeconds = clamped
        self.remainingSeconds = clamped
    }

    deinit {
        timer?.invalidate()
    }

    /// 設定画面などで変更されたタイマー値を反映する。
    /// カウントダウン中は誤操作防止のため即座には反映せず、
    /// 停止中・リセット時のみ残り時間に反映する。
    func configure(totalSeconds newTotalSeconds: Int) {
        let clamped = max(newTotalSeconds, 0)
        totalSeconds = clamped
        if !isRunning {
            remainingSeconds = clamped
            didFinish = false
        }
    }

    /// カウントダウンを開始する
    func start() {
        guard !isRunning, remainingSeconds > 0 else { return }
        isRunning = true
        didFinish = false

        let newTimer = Timer(timeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
        RunLoop.main.add(newTimer, forMode: .common)
        timer = newTimer
    }

    /// カウントダウンを一時停止する
    func pause() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }

    /// 残り時間を設定時間まで戻す
    func reset() {
        pause()
        remainingSeconds = totalSeconds
        didFinish = false
    }

    private func tick() {
        guard remainingSeconds > 0 else {
            pause()
            return
        }
        remainingSeconds -= 1
        if remainingSeconds == 0 {
            pause()
            didFinish = true
            BuzzerSound.play()
        }
    }

    /// "分:秒" 形式（例: 03:00）にフォーマットした残り時間
    var formattedTime: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - ブザー音

/// タイムアップ時のブザー音（矩形波）を、少し間を空けながら3回はっきりと繰り返して再生するユーティリティ。
/// 3回それぞれのタイミングでバイブレーション（振動モーター＋Taptic Engine）も同時に動作させる。
/// 外部の音声ファイルは使わず、その場で音を生成して再生する。
enum BuzzerSound {

    private static var engine: AVAudioEngine?
    private static var player: AVAudioPlayerNode?

    private static let sampleRate: Double = 44100
    private static let toneFrequency: Double = 480.0
    /// 1回分のブザー音の長さ（秒）
    private static let beepDuration: Double = 0.35
    /// ブザーとブザーの間の無音時間（秒）。はっきり3回と分かるよう間隔を広めに取る。
    private static let gapDuration: Double = 0.35
    /// 繰り返し回数（1回だけだと気づきにくいため3回鳴らす）
    private static let repeatCount = 3

    /// ブザー音とバイブレーションを、間隔を空けながら3回繰り返して再生する
    static func play() {
        guard let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1),
              prepareEngine(format: format) else { return }

        let interval = beepDuration + gapDuration

        for i in 0..<repeatCount {
            let delay = interval * Double(i)
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                // ブザー音の鳴動に合わせて、その都度バイブレーションを動作させる
                triggerVibration()
                playSingleTone(format: format)
            }
        }

        let totalDuration = interval * Double(repeatCount) + 0.3
        DispatchQueue.main.asyncAfter(deadline: .now() + totalDuration) {
            stopEngine()
        }
    }

    /// 端末のバイブレーションモーターとTaptic Engineの両方を鳴らし、確実に振動を伝える
    private static func triggerVibration() {
#if canImport(UIKit)
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
#endif
    }

    private static func prepareEngine(format: AVAudioFormat) -> Bool {
#if canImport(UIKit)
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
        try? session.setActive(true)
#endif
        let newEngine = AVAudioEngine()
        let newPlayer = AVAudioPlayerNode()
        newEngine.attach(newPlayer)
        newEngine.connect(newPlayer, to: newEngine.mainMixerNode, format: format)

        do {
            try newEngine.start()
        } catch {
            return false
        }

        engine = newEngine
        player = newPlayer
        newPlayer.play()
        return true
    }

    private static func playSingleTone(format: AVAudioFormat) {
        guard let player = player,
              let buffer = toneBuffer(format: format, frequency: toneFrequency, duration: beepDuration) else { return }
        player.scheduleBuffer(buffer, completionHandler: nil)
    }

    private static func stopEngine() {
        player?.stop()
        engine?.stop()
        player = nil
        engine = nil
    }

    /// 単発の矩形波ブザー音バッファを生成する
    private static func toneBuffer(format: AVAudioFormat, frequency: Double, duration: Double) -> AVAudioPCMBuffer? {
        let rate = format.sampleRate
        let frameCount = Int(rate * duration)
        guard frameCount > 0,
              let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(frameCount)) else {
            return nil
        }
        buffer.frameLength = AVAudioFrameCount(frameCount)
        guard let channelData = buffer.floatChannelData else { return nil }

        let samples = channelData[0]
        let period = rate / frequency
        let fadeFrames = max(1, Int(rate * 0.005)) // クリックノイズ防止用のフェード

        for i in 0..<frameCount {
            let phase = Double(i).truncatingRemainder(dividingBy: period) / period
            var amplitude: Float = phase < 0.5 ? 0.7 : -0.7
            if i < fadeFrames {
                amplitude *= Float(i) / Float(fadeFrames)
            } else if i > frameCount - fadeFrames {
                amplitude *= Float(frameCount - i) / Float(fadeFrames)
            }
            samples[i] = amplitude
        }
        return buffer
    }
}
