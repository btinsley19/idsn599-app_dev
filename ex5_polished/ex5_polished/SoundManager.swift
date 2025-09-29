
//
//  SoundManager.swift
//  ex5_polished
//
//  Created by Gemini Code Assist on 10/1/25.
//

import Foundation
import AudioToolbox

class SoundManager {
    static let shared = SoundManager()

    enum Sound: SystemSoundID {
        case success = 1003 
    }

    private init() {}

    func playSound(_ sound: Sound) {
        AudioServicesPlaySystemSound(sound.rawValue)
    }
}