
//
//  AudioPlayerManager.swift
//  ex5_polished
//
//  Created by Gemini Code Assist on 10/1/25.
//

import Foundation
import AVFoundation

class AudioPlayerManager: ObservableObject {
    private var audioPlayer: AVAudioPlayer?
    @Published var isPlaying = false

    func toggleMeditationSound() {
        if isPlaying {
            stop()
        } else {
            playSound(named: "meditation", withExtension: "mp3")
        }
    }

    private func playSound(named fileName: String, withExtension fileExt: String) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: fileExt) else {
            print("Audio file not found: \(fileName).\(fileExt). Make sure it's added to your project bundle.")
            return
        }

        do {
            // Configure audio session to allow playback even when the phone is on silent
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)

            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1 // Loop indefinitely
            audioPlayer?.play()
            isPlaying = true
        } catch {
            print("Error playing audio: \(error.localizedDescription)")
            isPlaying = false
        }
    }

    func stop() {
        audioPlayer?.stop()
        isPlaying = false
    }
}