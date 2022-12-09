//
//  Motion.swift
//  BreakoutDemo
//
//  Created by Bill on 8/20/20.
//  Copyright © 2020 Bill. All rights reserved.
//

import Foundation
import CoreMotion   // Accelerometer data


// Motion Singleton - Get Accelerometer data
//   To get acceleration us the x,y and z parameters
//   Apple Docs: https://developer.apple.com/documentation/coremotion/cmmotionmanager
//
//    Access Example:
//         Motion.shared.x
//
class Motion {
    static let shared = Motion()
    private let theMotionManager = CMMotionManager() // Apple says to only create one instance of CMMotionManager in an app
    

    // Constructor is private so that people can't make more instances of this class
    private init() {
        // Start Acceleromiter
        if theMotionManager.isAccelerometerAvailable {
            theMotionManager.startAccelerometerUpdates()
        }
        
        // Start Motion Detection
        if theMotionManager.isDeviceMotionAvailable {
            theMotionManager.startDeviceMotionUpdates()
        }
    }
    
    var yaw: Double {
        get { return theMotionManager.deviceMotion?.attitude.yaw ?? 0.0 }
    }
    
    var roll: Double {
        get { return theMotionManager.deviceMotion?.attitude.roll ?? 0.0 }
    }
    
    var pitch: Double {
        get { return theMotionManager.deviceMotion?.attitude.pitch ?? 0.0 }
    }

    // Reference:
    // https://stackoverflow.com/questions/10692344/cmdevicemotion-yaw-values-unstable-when-iphone-is-vertical
    // Return iPhone Yaw value in degrees from 0.0 to 360.0 increasing in clockwise direction to match compass behavior
    var yaw360: Double {
        var theYaw = yaw // Yaw between -PI and PI (Increasing counter-clockwise)
        theYaw *= (180/Double.pi)      // Convert from radians to degrees
        theYaw *= -1                   // Change to increase in clock-wise direction with values from -360 up to 0
        
        if theYaw < 0 {
            theYaw += 360
        }
        return theYaw
    }

    // Return iPhone Roll value in degrees from 0.0 to 360.0 increasing in clockwise direction to match compass behavior
    var roll360: Double {
        var theRoll = roll // Roll between -PI and PI (Increasing counter-clockwise)
        theRoll *= (180/Double.pi)      // Convert from radians to degrees
        theRoll *= -1                   // Change to increase in clock-wise direction with values from -360 up to 0
        
        if theRoll < 0 {
            theRoll += 360
        }
        return theRoll
    }

    // Return iPhone Pitch value in degrees from 0.0 to 360.0 increasing in clockwise direction to match compass behavior
    var pitch360: Double {
        var thePitch = pitch // Roll between -PI and PI (Increasing counter-clockwise)
        thePitch *= (180/Double.pi)      // Convert from radians to degrees
        thePitch *= -1                   // Change to increase in clock-wise direction with values from -360 up to 0
        
        if thePitch < 0 {
            thePitch += 360
        }
        return thePitch
    }


    
    
    var xGravity: Double {
        get { return theMotionManager.accelerometerData?.acceleration.x ?? 0.0  }
    }
    var yGravity: Double {
        get {
            return theMotionManager.accelerometerData?.acceleration.y ?? 0.0
        }
    }
    var zGravity: Double {
        get { return theMotionManager.accelerometerData?.acceleration.z ?? 0.0  }
    }
    
    var xMotion: Double {
        get { return theMotionManager.deviceMotion?.userAcceleration.x ?? 0.0}
    }

    var yMotion: Double {
        get { return theMotionManager.deviceMotion?.userAcceleration.y ?? 0.0}
    }

    var zMotion: Double {
        get { return theMotionManager.deviceMotion?.userAcceleration.z ?? 0.0}
    }


}


