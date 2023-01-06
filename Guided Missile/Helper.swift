//
//  Helper.swift
//  Guided Missile
//
//  Created by William Hause on 1/2/23.
//

import SpriteKit


// Struct with static helper functions


let GAME_FONT = "Copperplate" // Pretty GOOD - Caps theme

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
        let buttonLabelNode = SKLabelNode(fontNamed: GAME_FONT)

        
        // Game Center Leaderboard Button
        buttonLabelNode.text = text
        buttonLabelNode.fontSize = CGFloat(30)
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

    // Display a message that fades out.  Default font size it 20
    static func fadingAlert(scene: SKScene, position: CGPoint, text: String, fontSize: CGFloat = CGFloat(30), duration: Double = 2.0) {
        let fontSize = CGFloat(fontSize)
        let alertLabel = SKLabelNode(fontNamed: GAME_FONT)
        alertLabel.fontSize = fontSize
        alertLabel.text = text
        alertLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        alertLabel.numberOfLines = 0
        alertLabel.fontColor = UIColor(cgColor: CGColor(srgbRed: 0.0, green: 0.8, blue: 1.0, alpha: 1.0))
        alertLabel.preferredMaxLayoutWidth = scene.frame.size.width * 4/5
        alertLabel.position = position
        scene.addChild(alertLabel)
        
//        let shrinkAndFadeAction = SKAction.group([SKAction.scale(to: 0.1, duration: 1.0),
//                                                  SKAction.rotate(byAngle: 2*3.141, duration: 1.0),
//                                                  SKAction.moveTo(y: alertLabel.position.y*2, duration: 1.0),
//                                                  SKAction.moveTo(x: alertLabel.position.x*2, duration: 1.0),
//                                                  SKAction.fadeOut(withDuration: 1.0)])

        
//        let shrinkAndFadeAction = SKAction.group([SKAction.scale(to: 0.1, duration: 1.0),
//                                                  SKAction.fadeOut(withDuration: 1.0)])

        let shrinkAndFadeAction = SKAction.group([SKAction.fadeOut(withDuration: 1.0)])
        alertLabel.run(SKAction.sequence([SKAction.wait(forDuration: duration),
                                         shrinkAndFadeAction,
                                         SKAction.removeFromParent()]))


    }
    
    
}


