//
//  GameViewModel.swift
//  Guided Missile
//
//  Created by William Hause on 12/16/22.
//

import Foundation
import SwiftUI // Needed for Image struct
import SpriteKit
import GameKit // Needed for Leaderboard


class GameViewModel {
    
    func getBackgroundNode(gameLevelNumber: Int) -> SKSpriteNode {
        let imageNumber = gameLevelNumber % 18 // Reduce the mRoundNumber number to something in our range of backgrounds

        var theImage = SKSpriteNode()
        switch imageNumber {
            case 0:
                theImage = SKSpriteNode(imageNamed: "Space1") // OK last image since we start at Round 1 and not Round 0
            case 1:
                theImage = SKSpriteNode(imageNamed: "Space3") // OK - FIRST STAGE - Galaxy black sky start at Round 1 and not Round 0
            case 2:
                theImage = SKSpriteNode(imageNamed: "Space2") // OK
            case 3:
                theImage = SKSpriteNode(imageNamed: "barnard_3") // OK
            case 4:
                theImage = SKSpriteNode(imageNamed: "Space4") // OK - Shows up well
            case 5:
                theImage = SKSpriteNode(imageNamed: "HubbleStellarBlast") // OK
            case 6:
                theImage = SKSpriteNode(imageNamed: "Space5") // OK - Pretty but bright
            case 7:
                theImage = SKSpriteNode(imageNamed: "Space6") // OK - Pretty but bright
            case 8:
                theImage = SKSpriteNode(imageNamed: "Space7") // OK - Pretty But bright
            case 9:
                theImage = SKSpriteNode(imageNamed: "Space8") // OK
            case 10:
                theImage = SKSpriteNode(imageNamed: "Space9") // OK - Pretty but Bright
            case 11:
                theImage = SKSpriteNode(imageNamed: "Space10") // Low Res
            case 12:
                theImage = SKSpriteNode(imageNamed: "Space11") // Low Res
            case 13:
                theImage = SKSpriteNode(imageNamed: "Space12") // Low Res
            case 14:
                theImage = SKSpriteNode(imageNamed: "Space13") // Too low resoltuion
            case 15:
                theImage = SKSpriteNode(imageNamed: "Space14") // Too low res
            case 16:
                theImage = SKSpriteNode(imageNamed: "Space15") // Low Res
            case 17:
                theImage = SKSpriteNode(imageNamed: "Space16") // Low Res
            default:
                theImage = SKSpriteNode(imageNamed: "barnard_3")
        }

        theImage.alpha = 0.5
        return theImage
    }

}


