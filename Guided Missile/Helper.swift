//
//  Helper.swift
//  Guided Missile
//
//  Created by William Hause on 1/2/23.
//

import SpriteKit


// Struct with static helper functions


struct Helper {
    
    
    
    
    // USAGE:
    //   In the GameScene 'touchDown(atPoint pos: CGPoint)' function add code
    //   to check if the button was tapped like this:
    //     if !buttonNode.isHidden && buttonNode.frame.contains(pos) {
    //       do button stuff
    //     }
    //
    //   To create a button add code like this to the GameScene constructor
    //        let buttonPosition = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2 + 80)
    //        mPlayAgainButton = Helper.makeButton(position: buttonPosition, text: "Play Again")
    //        self.addChild(mPlayAgainButton)
    //        mPlayAgainButton.isHidden = false // Hide the button
    //
    //   To hide/show the button add code like this:
    //     theButton.isHidden = true
    // Font Samples: http://iosfonts.com
    //
    static func makeButton(position: CGPoint, text: String) -> SKShapeNode {
//        let buttonLabelNode = SKLabelNode(fontNamed: "Copperplate") // Pretty GOOD - Caps theme
//        let buttonLabelNode = SKLabelNode(fontNamed: "Futura-Medium") // OK.
//        let buttonLabelNode = SKLabelNode(fontNamed: "Helvetica") // I think this is the default
//        let buttonLabelNode = SKLabelNode(fontNamed: "TrebuchetMS") // plane and simple
        let buttonLabelNode = SKLabelNode(fontNamed: "Copperplate") // Pretty GOOD - Caps theme

        
        // Game Center Leaderboard Button
        buttonLabelNode.text = text
        buttonLabelNode.fontSize = CGFloat(20)
        buttonLabelNode.lineBreakMode = NSLineBreakMode.byWordWrapping
        buttonLabelNode.numberOfLines = 0
//        buttonLabelNode.preferredMaxLayoutWidth = theGameScene.frame.size.width * 4 / 5
        buttonLabelNode.preferredMaxLayoutWidth = 300 // Limit the max width of the button

        // NOTE: For some reason SKLabelNodes Y position is not centerered so must
        // adjust move it down half it's height to center it.
        let labelPosition = CGPoint(x: 0, y: -buttonLabelNode.frame.height/2)
        buttonLabelNode.position = labelPosition

        
        // Add button frame around the label
        let leaderboardButtonSize = CGSize(width:buttonLabelNode.frame.width+20, height: buttonLabelNode.frame.height)
        let buttonFrameNode = SKShapeNode.init(rectOf: leaderboardButtonSize, cornerRadius: 10)
        buttonFrameNode.lineWidth = 2
        buttonFrameNode.position = position
        buttonFrameNode.strokeColor = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
    
        buttonFrameNode.addChild(buttonLabelNode)
        
        return buttonFrameNode
    }
    
}

//class ButtonNode: SKNode {
//    private var saveAlpha = 1.0
//    private var isHidden = false
//    func hide() {
//        guard (isHidden == false) else {
//            return // Nothing to do, it's already hidden
//        }
//        saveAlpha = self.alpha //  save the previous alpha to restore later
//        self.alpha = 0.0 // Hide the button
//    }
//    func show {
//        self.alpha = saveAlpha // Hide the button
//    }
//}


