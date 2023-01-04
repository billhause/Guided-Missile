//
//  Haptic.swift
//  Guided Missile
//
//  Created by William Hause on 1/4/23.
//

import Foundation
import UIKit
import AVFoundation // AudioServicesPlaySystemSound()

// Haptic Singleton - Get Accelerometer data
//
// Apple Docs: https://developer.apple.com/documentation/uikit/uifeedbackgenerator
//
//    Access Example:
//         Haptic.shared.impact(style: .medium)
//
class Haptic {
    
    static let shared = Haptic()
    
    public enum FeedbackStyle : Int {
        case light = 0
        case medium = 1
        case heavy = 2
        case soft = 3
        case rigid = 4
        case selection = 5
        case error = 6
        case success = 7
        case warning = 8
    }
    
    // styles choices are heavy, medium, light, rigid and soft.  Also selection, error, success and warning
    private let heavyImpactGenerator     = UIImpactFeedbackGenerator(style: .heavy)
    private let mediumImpactGenerator     = UIImpactFeedbackGenerator(style: .medium)
    private let lightImpactGenerator     = UIImpactFeedbackGenerator(style: .light)
    private let rigidImpactGenerator     = UIImpactFeedbackGenerator(style: .rigid)
    private let softImpactGenerator     = UIImpactFeedbackGenerator(style: .soft)
    private let selectionGenerator         = UISelectionFeedbackGenerator()
    private let notificationGenerator     = UINotificationFeedbackGenerator()

    
    // Constructor is private so that people can't make more instances of this class
    private init() {
        // calling prepare() in advance will allow a faster response from the generator
        // Only stays prepared for a few seconds. - Consumes energy to stay prepared
        heavyImpactGenerator.prepare()
        mediumImpactGenerator.prepare()
        lightImpactGenerator.prepare()
        rigidImpactGenerator.prepare()
        softImpactGenerator.prepare()
        selectionGenerator.prepare()
        notificationGenerator.prepare()
    }

        
    func impact(style: FeedbackStyle) {
        switch style {
        case .light:
            lightImpactGenerator.impactOccurred()
            lightImpactGenerator.prepare() // Prepare for next use.  Only stays prepared for a few seconds. - Consumes energy to stay prepared
        case .medium:
            mediumImpactGenerator.impactOccurred()
            mediumImpactGenerator.prepare()
        case .heavy:
            heavyImpactGenerator.impactOccurred()
            heavyImpactGenerator.prepare()
        case .soft:
            softImpactGenerator.impactOccurred()
            softImpactGenerator.prepare()
        case .rigid:
            rigidImpactGenerator.impactOccurred()
            rigidImpactGenerator.prepare()
        case .selection:
            selectionGenerator.selectionChanged()
            selectionGenerator.prepare()
        case .error:
            notificationGenerator.notificationOccurred(.error)
            notificationGenerator.prepare()
        case .success:
            notificationGenerator.notificationOccurred(.error)
            notificationGenerator.prepare()
        case .warning:
            notificationGenerator.notificationOccurred(.error)
            notificationGenerator.prepare()
//        default:
//            print("Bill, the Haptic impact() method was passed an invalid style")
        }
    }
    
    /// Play a short single vibration, like a tac
    func tacVibrate() {
        AudioServicesPlaySystemSound(1519) // one tack
    }

    /// Play three shorts tac vibration, like a tac tac tac
    func threeTacVibrate() {
        AudioServicesPlaySystemSound(1521)
    }

    /// Play a strong boom vibration
    func boomVibrate() {
        AudioServicesPlaySystemSound(1520)
    }

    /// Play a long vibrations trr trr, it sounds like an error
    func longVibrate() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate) // heavy tack
    }

    /// Stops the short single vibration, like a tac
    func stopTacVibrate() {
        AudioServicesDisposeSystemSoundID(1519) // one tack
    }

    /// Stops the three shorts tac vibration, like a tac tac tac
    func stopThreeTacVibrate() {
        AudioServicesDisposeSystemSoundID(1521)
    }

    /// Stops the strong boom vibration
    func stopBoomVibrate() {
        AudioServicesDisposeSystemSoundID(1520)
    }

    /// Stops the long vibrations
    func stopLongVibrate() {
        AudioServicesDisposeSystemSoundID(kSystemSoundID_Vibrate) // heavy tack
    }


}

