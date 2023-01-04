//
//  Sound.swift
//  Guided Missile
//
//  Created by William Hause on 1/4/23.
//

import Foundation
import AVFoundation // Needed to play sounds and music


// Download Free Sounds from here:
//   https://freesound.org/browse/
//   Login: bhause, password, non-secret
//   This class configures 4 Dictionaries each holding each sound.
//   Up to 4 copies of the same sound can be played at once
//   Different sounds can be plaied at the same time.
//
class Sound {
    static let shared = Sound()
    var duplicatePlayer: AVAudioPlayer?
    private var sounds1: [String: AVAudioPlayer]
    private var sounds2: [String: AVAudioPlayer]
    private var sounds3: [String: AVAudioPlayer]
    private var sounds4: [String: AVAudioPlayer]
    private var soundNames = ["silent_sound", "fail2", "TrekKlaxon", "laser3", "GameOver", "Boom1", "Boom2", "Boom3", "Explosion1"] //, "fail1",  "fail3", "fail4", "fail5",  "8BitBounce", "Boom1", "Boom2", "Boom3", "Explosion1", "Gunshot", "GameOver2"]
    
    
    private init() {
        sounds1 = [String: AVAudioPlayer]()
        sounds2 = [String: AVAudioPlayer]()
        sounds3 = [String: AVAudioPlayer]()
        sounds4 = [String: AVAudioPlayer]()
        for name in soundNames {
            let soundURL = Bundle.main.path(forResource: name, ofType: "wav")
            do {
                sounds1[name] = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: soundURL!))
                sounds1[name]?.numberOfLoops = 0 // set to -1 to do infinate loops, 1 will play twice
                sounds1[name]?.prepareToPlay()
                }
            catch {
                print(error)
            }
            do {
                sounds2[name] = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: soundURL!))
                sounds2[name]?.numberOfLoops = 0 // set to -1 to do infinate loops, 1 will play twice
                sounds2[name]?.prepareToPlay()
                }
            catch {
                print(error)
            }
            do {
                sounds3[name] = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: soundURL!))
                sounds3[name]?.numberOfLoops = 0 // set to -1 to do infinate loops, 1 will play twice
                sounds3[name]?.prepareToPlay()
                }
            catch {
                print(error)
            }
            do {
                sounds4[name] = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: soundURL!))
                sounds4[name]?.numberOfLoops = 0 // set to -1 to do infinate loops, 1 will play twice
                sounds4[name]?.prepareToPlay()
                }
            catch {
                print(error)
            }
        }
    }

    func play(forResource name: String) {
        if !(sounds1[name]?.isPlaying ?? true) { // If the sound is not currently planing
        DispatchQueue.global().async { // Play in background thread
            self.sounds1[name]?.play()
            }
            return
        }

        if !(sounds2[name]?.isPlaying ?? true) { // If the sound is not currently planing
        DispatchQueue.global().async { // Play in background thread
            self.sounds2[name]?.play()
            }
            return
        }

        if !(sounds3[name]?.isPlaying ?? true) { // If the sound is not currently planing
        DispatchQueue.global().async { // Play in background thread
            self.sounds3[name]?.play()
            }
            return
        }
        
        if !(sounds4[name]?.isPlaying ?? true) { // If the sound is not currently planing
        DispatchQueue.global().async { // Play in background thread
            self.sounds4[name]?.play()
            }
            return
        }

    }
    
    
}
