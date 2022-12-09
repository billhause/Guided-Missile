//
//  MotionForSpriteKit.swift
//  SpriteKit Test 1
//
//  Created by William Hause on 12/2/22.
//
// SpriteKit uses a framerate for updates and not MVVM or MVC
// Therefore, Motion updates need to have information about the prvious frame and not
// just the current state of the phone.
// This class is designed to provide motion information that will be usefule for SpriteKit development.
//   E.g. as the phone is rotated, don't jump back to 0 when the degrees pass 360.  Instead keep incrementing beyond 360.
//   That way whatever is being controlled by the orientation of the phone will not suddenly jump back to 0.

import Foundation

// Convert Yaw to a point to use the phone like a joystick
// NOTE: Similar to Roll2Point so fix any bugs in both structs
struct Yaw2Point {
    var maxPixel: Double
    var minPixel: Double
    var degreeRange: Double // How many degrees represent the difference between top and bottom
    var degreeOffset: Double // Offset to add to the degrees
    var pixelsPerDegree: Double
    
    init(minPixel: Double, maxPixel: Double, degreeRange: Double) {
        self.maxPixel = maxPixel
        self.minPixel = minPixel
        self.degreeRange = degreeRange
        
        // Some error handling
        if degreeRange == 0.0 {
            self.degreeRange = 25 // Avoid divide by zero
        }
        if minPixel == maxPixel {
            self.maxPixel = minPixel + 25 // Must have some range
        }
        
        // Set other member vars
        self.degreeOffset = MotionForSpriteKit.yawUnlimited - self.degreeRange/2 // set to lower bound
        self.pixelsPerDegree = (self.maxPixel-self.minPixel)/self.degreeRange
    }
    
    // This will return a pixel values between minPixel and maxPixel
    // based on changes in yaw.
    // if the yaw extends above the maxPixel, then it will recalibrate such
    // that when the yaw starts to drop, it will immedately start returning pixel
    // positions below maxPixel.  Same thing for minPixel.
    // The center will happen when the yaw is half of the degreeRange value.
    // NOTE: Fix any bugs in the Roll version also
    mutating func getPixel() -> Double {
        let rawYaw = MotionForSpriteKit.yawUnlimited
        
        var pixel = pixelsPerDegree * (rawYaw-degreeOffset)
        if pixel > maxPixel {
            pixel = maxPixel
            degreeOffset = rawYaw - degreeRange // reset the lower offset
        }
        if pixel < minPixel {
            pixel = minPixel
            degreeOffset = rawYaw // Reset the lower offset
        }
        return pixel
    }
} // Yaw2Point class

// Convert Roll to a point to use the phone like a joystick
// NOTE: Similar to Yaw2Point so fix any bugs in both structs
struct Roll2Point {
    var maxPixel: Double
    var minPixel: Double
    var degreeRange: Double // How many degrees represent the difference between top and bottom
    var degreeOffset: Double // Offset to add to the degrees
    var pixelsPerDegree: Double
    
    init(minPixel: Double, maxPixel: Double, degreeRange: Double) {
        self.maxPixel = maxPixel
        self.minPixel = minPixel
        self.degreeRange = degreeRange
        
        // Some error handling
        if degreeRange == 0.0 {
            self.degreeRange = 25 // Avoid divide by zero
        }
        if minPixel == maxPixel {
            self.maxPixel = minPixel + 25 // Must have some range
        }
        
        // Set other member vars
        self.degreeOffset = MotionForSpriteKit.rollUnlimited - self.degreeRange/2 // set to lower bound
        self.pixelsPerDegree = (self.maxPixel-self.minPixel)/self.degreeRange
    }
    
    // This will return a pixel values between minPixel and maxPixel
    // based on changes in Roll.
    // if the Roll extends above the maxPixel, then it will recalibrate such
    // that when the Roll starts to drop, it will immedately start returning pixel
    // positions below maxPixel.  Same thing for minPixel.
    // The center will happen when the Roll is half of the degreeRange value.
    // NOTE: Fix any bugs in the Yaw version also
    mutating func getPixel() -> Double {
        let rawRoll = MotionForSpriteKit.rollUnlimited
        
        var pixel = pixelsPerDegree * (rawRoll-degreeOffset)
        if pixel > maxPixel {
            pixel = maxPixel
            degreeOffset = rawRoll - degreeRange // reset the lower offset
        }
        if pixel < minPixel {
            pixel = minPixel
            degreeOffset = rawRoll // Reset the lower offset
        }
        return pixel
    }
} // Roll2Point class



class MotionForSpriteKit {
    static var previousYaw = 0.0
    static var totalYaw = 0.0
    static var previousPitch = 0.0
    static var totalPitch = 0.0
    static var previousRoll = 0.0
    static var totalRoll = 0.0

    // Return iPhone Yaw, Roll and Pitch values in degrees from increasing in clockwise direction
    // Value will increase or decrease by 360 every full rotation with no Max or Min value.
    // E.g. if you rotate your phone 1 and a half times it will be at 360+180=540
    static var yawUnlimited: Double {
        let finalYaw = Motion.shared.yaw360
        var delta = finalYaw-previousYaw
        previousYaw = finalYaw
        if delta > 180 {
            delta = delta - 360
        } else if delta < -180 {
            delta = delta + 360
        }
        
        totalYaw += delta
//        MyLog.debug("MotionForSpriteKit.yawUnlimited = \(totalYaw)")
        return totalYaw
    }
    
    static var pitchUnlimited: Double {
        let finalPitch = Motion.shared.pitch360
        var delta = finalPitch-previousPitch
        previousPitch = finalPitch
        if delta > 180 {
            delta = delta - 360
        } else if delta < -180 {
            delta = delta + 360
        }
        
        totalPitch += delta
//        MyLog.debug("MotionForSpriteKit.pitchUnlimited = \(totalPitch)")
        return totalPitch
    }

    static var rollUnlimited: Double {
        let finalRoll = Motion.shared.roll360
        var delta = finalRoll-previousRoll
        previousRoll = finalRoll
        if delta > 180 {
            delta = delta - 360
        } else if delta < -180 {
            delta = delta + 360
        }
        
        totalRoll += delta
//        MyLog.debug("MotionForSpriteKit.rollUnlimited = \(totalRoll)")
        return totalRoll
    }

}
