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
    private var soundNames = [ "silent_sound", "asteroid_explosion", "TrekKlaxon", "laser3", "GameOver", "Boom1", "Boom2", "Boom3", "Explosion1", "ExplosionSaucerSound", "ExplosionStarbaseSound", "WarpSound3", "WarpSound4"]
    

    // vvvvvvvvvv SAUCER SOUND vvvvvvvvvv
    // Load the Saucer sound and prepare to play it.
    private var saucerSoundPlayer = AVAudioPlayer()
    private var saucerIsPlaying = false
    func saucerSoundInit() {
        do {
            let urlPathString = Bundle.main.path(forResource: "flying_saucer_rumble", ofType: "wav")
            saucerSoundPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: urlPathString!))
            saucerSoundPlayer.numberOfLoops = -1 // -1 means loop forever
            saucerSoundPlayer.prepareToPlay()
            saucerIsPlaying = false
        } catch {
            print(error)
        }
    }
    
    // Start saucer sound if it's not already playing
    func saucerSoundOn() {
        let SAUCER_VOLUME: Float = 20.0
        if !saucerIsPlaying {
            saucerIsPlaying = true
            DispatchQueue.global().async { // play in background
                self.saucerSoundPlayer.play()
            }
        }
        // Adjust the volume of the sound
        saucerSoundPlayer.setVolume(SAUCER_VOLUME, fadeDuration: 0.0) // no fade in duration
    }
    
    // Stop saucer thrust sound if it's playing
    func saucerSoundOff() {
        if saucerIsPlaying {
            saucerIsPlaying = false
            saucerSoundPlayer.stop()
        }
    }
    // ^^^^^^^^^^^ SAUCER SOUND ^^^^^^^^^^^^^^^^

    
    // vvvvvvvvvv ROCKET SOUND vvvvvvvvvv
    // Load the rocket thrust sound and prepare to play it.
    private var rocketSoundPlayer = AVAudioPlayer()
    private var rocketIsPlaying = false
    func thrustSoundInit() {
        do {
            let urlPathString = Bundle.main.path(forResource: "Thrusters_20_Seconds", ofType: "wav")
            rocketSoundPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: urlPathString!))
            rocketSoundPlayer.numberOfLoops = -1 // -1 means loop forever
            rocketSoundPlayer.prepareToPlay()
            rocketIsPlaying = false
        } catch {
            print(error)
        }
    }
    
    // Start rocket thrust sound if it's not already playing
    func thrustSoundOn(volume: Float) {
        if !rocketIsPlaying {
            rocketIsPlaying = true
            DispatchQueue.global().async { // play in background
                self.rocketSoundPlayer.play()
            }
        }
        // Adjust the volume of the sound
        rocketSoundPlayer.setVolume(volume, fadeDuration: 0.0) // no fade in duration
    }
    
    // Stop rocket thrust sound if it's playing
    func thrustSoundOff() {
        if rocketIsPlaying {
            rocketIsPlaying = false
            rocketSoundPlayer.stop()
        }
    }
    // ^^^^^^^^^^^ ROCKET SOUND ^^^^^^^^^^^^^^^^

    
    // vvvvvvvvvv MUSIC SOUND vvvvvvvvvv
    // Load the rocket thrust sound and prepare to play it.
    private var musicSoundPlayer = AVAudioPlayer()
    private var musicIsPlaying = false
    func musicSoundInit(level: Int) {
        do {
            // Good music sounds:
            //   DrumLoop1  (Can stand alone as the only tune)
            //   DrumLoop2 (Only if switching every level)
            //   DrumLoop4 (Only if switching every level)
            //   DrumLoop6 (Only if switching every level)
            //   DrumLoop7 (Only if switching every level)
            //   DrumLoop9 (Only if switching every level)
            //   DrumLoop11 (Only if switching every level)
            //   DrumLoop12 (Probably Only if switching every level)
            //   DrumLoop13 (Only if switching every level)
            //   DrumLoop14 (Probably Only if switching every level)
            //   DrumLoop15 (Probbaly Only if switching every level)
            //   DrumLoop17 (Probably Only if switching every level)
            
            let loopIndex = level % 13
            MyLog.debug("wdhx Music loopIndex: \(loopIndex)")
            switch loopIndex {
            case 0:
                let urlPathString = Bundle.main.path(forResource: "DrumLoop2", ofType: "wav") // Fine but boring
                musicSoundPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: urlPathString!))
                musicSoundPlayer.setVolume(1.0, fadeDuration: 0.0) // no fade in duration
            case 1:
                let urlPathString = Bundle.main.path(forResource: "DrumLoop1", ofType: "wav") // Fine
                musicSoundPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: urlPathString!))
                musicSoundPlayer.setVolume(1.0, fadeDuration: 0.0) // no fade in duration
            case 2:
                let urlPathString = Bundle.main.path(forResource: "DrumLoop4", ofType: "wav") // Fine
                musicSoundPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: urlPathString!))
                musicSoundPlayer.setVolume(1.0, fadeDuration: 0.0) // no fade in duration
            case 3:
                let urlPathString = Bundle.main.path(forResource: "DrumLoop6", ofType: "wav") // Too Quiet
                musicSoundPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: urlPathString!))
                musicSoundPlayer.setVolume(3.0, fadeDuration: 0.0) // no fade in duration
            case 4:
                let urlPathString = Bundle.main.path(forResource: "DrumLoop7", ofType: "wav") // Too Loud
                musicSoundPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: urlPathString!))
                musicSoundPlayer.setVolume(0.6, fadeDuration: 0.0) // no fade in duration
            case 5:
                let urlPathString = Bundle.main.path(forResource: "DrumLoop9", ofType: "wav") // Fine
                musicSoundPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: urlPathString!))
                musicSoundPlayer.setVolume(1.0, fadeDuration: 0.0) // no fade in duration
            case 6:
                let urlPathString = Bundle.main.path(forResource: "DrumLoop11", ofType: "wav") // A little too quite and boaring
                musicSoundPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: urlPathString!))
                musicSoundPlayer.setVolume(2.0, fadeDuration: 0.0) // no fade in duration
            case 7:
                let urlPathString = Bundle.main.path(forResource: "DrumLoop12", ofType: "wav") // fine
                musicSoundPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: urlPathString!))
                musicSoundPlayer.setVolume(1.5, fadeDuration: 0.0) // no fade in duration
            case 8:
                let urlPathString = Bundle.main.path(forResource: "DrumLoop13", ofType: "wav") // fine but boaring
                musicSoundPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: urlPathString!))
                musicSoundPlayer.setVolume(1.0, fadeDuration: 0.0) // no fade in duration
            case 9:
                let urlPathString = Bundle.main.path(forResource: "DrumLoop14", ofType: "wav") // too quiet
                musicSoundPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: urlPathString!))
                musicSoundPlayer.setVolume(2.0, fadeDuration: 0.0) // no fade in duration
            case 10:
                let urlPathString = Bundle.main.path(forResource: "DrumLoop7", ofType: "wav") // Too Loud
                musicSoundPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: urlPathString!))
                musicSoundPlayer.setVolume(0.6, fadeDuration: 0.0) // no fade in duration
            case 11:
                let urlPathString = Bundle.main.path(forResource: "DrumLoop15", ofType: "wav") // Too Quiet
                musicSoundPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: urlPathString!))
                musicSoundPlayer.setVolume(2.6, fadeDuration: 0.0) // no fade in duration
            case 12:
                let urlPathString = Bundle.main.path(forResource: "DrumLoop17", ofType: "wav") // Fine
                musicSoundPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: urlPathString!))
                musicSoundPlayer.setVolume(1.0, fadeDuration: 0.0) // no fade in duration
            default:
                let urlPathString = Bundle.main.path(forResource: "DrumLoop2", ofType: "wav") // Fine
                musicSoundPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: urlPathString!))
                musicSoundPlayer.setVolume(1.0, fadeDuration: 0.0) // no fade in duration
            }
            
//            let urlPathString = Bundle.main.path(forResource: "DrumLoop1", ofType: "wav")
//            musicSoundPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: urlPathString!))
            musicSoundPlayer.numberOfLoops = -1 // -1 means loop forever
            musicSoundPlayer.prepareToPlay()
            musicIsPlaying = false
        } catch {
            print(error)
        }
    }
    
    // Start music sound if it's not already playing
    //func musicSoundOn(volume: Float = 1.0) {
    func musicSoundOn() {
        if !musicIsPlaying {
            musicIsPlaying = true
            DispatchQueue.global().async { // play in background
                self.musicSoundPlayer.play()
            }
        }
        // Adjust the volume of the sound
//        musicSoundPlayer.setVolume(volume, fadeDuration: 0.0) // no fade in duration
    }
    
    // Stop music sound if it's playing
    func musicSoundOff() {
        if musicIsPlaying {
            musicIsPlaying = false
            musicSoundPlayer.stop()
        }
    }
    // ^^^^^^^^^^^ MUSIC SOUND ^^^^^^^^^^^^^^^^

    
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
        
        thrustSoundInit() // init rocket thrust sound player
        saucerSoundInit()
        musicSoundInit(level: 1)
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
