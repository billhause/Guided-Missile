//
//  GameScene.swift
//  Guided Missile
//
//  Created by William Hause on 12/8/22.
//
//
// DIRECTIONS: How to create an app preview with iMovie
//    https://developer.apple.com/support/imovie/
//
// Icon Builder Website:
//  https://appicon.co
//
// Screen Shots
//   - 4 shots using iPhone "8 Plus" simulator
//   - 4 shots using iPhone "11 Pro Max" simulator
//
// Game Center Leader Boards - Apple Docs  https://developer.apple.com/library/archive/documentation/NetworkingInternet/Conceptual/GameKit_Guide/Introduction/Introduction.html#//apple_ref/doc/uid/TP40008304
//
//  Some Leaderboard Tutorial
//    Use this example: https://medium.com/swlh/how-to-integrate-gamekit-ios-794061428197
//    Use this Video Tutorial: https://www.google.com/search?q=game+center+leaderboard+swift+tutorial&newwindow=1&sxsrf=ALeKk01Bg1uOrX6PizEaPXXrfCtJHlbZBA:1600966767114&source=lnms&sa=X&ved=0ahUKEwisus37oYLsAhWYXM0KHV0kBV04ChD8BQgKKAA&biw=1688&bih=1236&dpr=2#kpvalbx=_gdBsX-TSAtaDtQaHtpDoBQ42
//   Another Leaderboard Example:  https://code.tutsplus.com/tutorials/game-center-and-leaderboards-for-your-ios-app--cms-27488
//
import SwiftUI // Needed for Image struct
import SpriteKit
//import GameplayKit




class GameScene: SKScene {
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    private var theShapeNode: SKShapeNode?
    private var theYaw2Point = Yaw2Point(minPixel: 0, maxPixel: 100, degreeRange: 25)
    private var theRoll2Point = Roll2Point(minPixel: 0, maxPixel: 100, degreeRange: 25)

    // vvvvvvvvvvvvvv
    // This code is needed because isPaused automatically sets to true when returning from the background.
    // If the users pauses before going to the background, I want it paused when returning from the backround
    // https://stackoverflow.com/questions/25351709/how-to-keep-spritekit-scene-paused-when-app-becomes-active
    var realPaused: Bool = false {
        didSet {
            self.isPaused = realPaused
        }
    }
    override var isPaused: Bool {
        didSet {
            if (self.isPaused == false && self.realPaused == true) {
                self.isPaused = true
            }
        }
    }
    // ^^^^^^^^^^^^^^^
    
    // Added by wdh
    // This gets called before the didMove(to:) function gets called.
    override init(size: CGSize) {
        MyLog.debug("GameScene.init(size:) called wdh")
        super.init(size: size)
    }
    
    
    // SKScene has a 'required' initializer for an NSCoder parameter
    // Therefore we muast have one in case it ever gets called on the base class.
    required init?(coder aDecoder: NSCoder) {
        MyLog.debug("GameScene.init?(coder:) called")
        super.init(coder: aDecoder)
    }


    
    // Tells you when the scene is presented by a view.
    //
    // This method is intended to be overridden in a subclass.
    // You can use this method to implement any custom behavior for your scene when
    // it is about to be presented by a view. For example, you might use this method
    // to create the scene’s contents.
    // the 'view' is the SKView that is presenting the SKScene
    //
    var mLabel1 = SKLabelNode(fontNamed: "Courier") // label for debugging
    var mLabel2 = SKLabelNode(fontNamed: "Courier")
    var mLabel3 = SKLabelNode(fontNamed: "Courier")

    override func didMove(to view: SKView) {
        setBackground(gameLevelNumber: 4) // Pass a different number for different backgrounds - Best: 4 (space4.jpg) with alpha of 0.5
        MyLog.debug("GameScene.didMove() called wdh")
        
        MyLog.debug("Screen Size: \(self.frame.size)")
        
        // Create the gunsite node and add it to the scene
        theShapeNode = ShapeNodeBilder.testNode()
        theShapeNode!.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2)
        self.addChild(theShapeNode!)

        let baseNode = ShapeNodeBilder.starBaseNode()
        baseNode.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height - self.frame.size.height/6)
        self.addChild(baseNode)
        
        let asteroidNode = ShapeNodeBilder.asteroidRandomNode()
        asteroidNode.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height - self.frame.size.height/3)
        self.addChild(asteroidNode)

        let missileNode = ShapeNodeBilder.missileNode()
        missileNode.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height - 2*self.frame.size.height/3)
        self.addChild(missileNode)

        let spaceShipNode = ShapeNodeBilder.spaceShipNode()
        spaceShipNode.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height - 5*self.frame.size.height/6)
        self.addChild(spaceShipNode)


        // Config display lines for debugging
        mLabel1.position = CGPoint(x: self.frame.width/2, y: 10)
        mLabel1.fontSize = CGFloat(9.0)
        self.addChild(mLabel1)
        mLabel2.position = CGPoint(x: self.frame.width/2, y: 20)
        mLabel2.fontSize = CGFloat(9.0)
        self.addChild(mLabel2)
        mLabel3.position = CGPoint(x: self.frame.width/2, y: 30)
        mLabel3.fontSize = CGFloat(9.0)
        self.addChild(mLabel3)

        // Replace the dummy Yaw2Point and Roll2Point with a correct one
        theYaw2Point = Yaw2Point(minPixel: 0.0, maxPixel: self.size.width, degreeRange: 45) // left/right
        theRoll2Point = Roll2Point(minPixel: 0.0, maxPixel: self.size.height, degreeRange: -45) // top/bottom

        
        // TODO: Remove this code that creates the spinnyNode
        // Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.05
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)

        if let spinnyNode = self.spinnyNode {
            spinnyNode.lineWidth = 2.5

            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                              SKAction.fadeOut(withDuration: 0.5),
                                              SKAction.removeFromParent()]))
        }
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
        MyLog.debug("GameScene.touchDown() called")
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.green
            self.addChild(n)
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        MyLog.debug("GameScene.touchMoved() called")
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.blue
            self.addChild(n)
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        MyLog.debug("GameScene.touchUp() called")
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.red
            self.addChild(n)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    // FRAME UPDATE
    // This gets called each frame update
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        

        theShapeNode?.run(SKAction.move(to: CGPoint(x:theYaw2Point.getPixel(), y: theRoll2Point.getPixel()), duration: 0.2))

        // Update site position based on Roll (up/down) and Yaw (left/right)
        let yaw360 = MotionForSpriteKit.yawUnlimited
        let roll360 = MotionForSpriteKit.rollUnlimited
        let pitch360 = MotionForSpriteKit.pitchUnlimited

        mLabel1.text = String(format: "wdh Yaw360:   %3.0f", yaw360)
        mLabel2.text = String(format: "wdh Roll360:  %3.0f", roll360)
        mLabel3.text = String(format: "wdh Pitch360: %3.0f", pitch360)

    }
    
    
    
    // Add a background to this GameScene based on the number passed in.
    var mBackgroundImage: SKSpriteNode?
    func setBackground(gameLevelNumber: Int) {
        let theGameScene = self
        theGameScene.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0) // Set background to black
        
        // Remove the old background imgae from the GameScene if it exists
        if mBackgroundImage != nil { // Check optional for existance
            if mBackgroundImage!.parent != nil {
                mBackgroundImage!.removeFromParent()
            }
        }
        
        let imageNumber = gameLevelNumber % 18 // Reduce the mRoundNumber number to something in our range of backgrounds

        switch imageNumber { // wdh
            case 0:
                mBackgroundImage = SKSpriteNode(imageNamed: "Space1") // OK last image since we start at Round 1 and not Round 0
            case 1:
                mBackgroundImage = SKSpriteNode(imageNamed: "Space3") // OK - FIRST STAGE - Galaxy black sky start at Round 1 and not Round 0
            case 2:
                mBackgroundImage = SKSpriteNode(imageNamed: "Space2") // OK
            case 3:
                mBackgroundImage = SKSpriteNode(imageNamed: "barnard_3") // OK
            case 4:
                mBackgroundImage = SKSpriteNode(imageNamed: "Space4") // OK - Shows up well
            case 5:
                mBackgroundImage = SKSpriteNode(imageNamed: "HubbleStellarBlast") // OK
            case 6:
                mBackgroundImage = SKSpriteNode(imageNamed: "Space5") // OK - Pretty but bright
            case 7:
                mBackgroundImage = SKSpriteNode(imageNamed: "Space6") // OK - Pretty but bright
            case 8:
                mBackgroundImage = SKSpriteNode(imageNamed: "Space7") // OK - Pretty But bright
            case 9:
                mBackgroundImage = SKSpriteNode(imageNamed: "Space8") // OK
            case 10:
                mBackgroundImage = SKSpriteNode(imageNamed: "Space9") // OK - Pretty but Bright
            case 11:
                mBackgroundImage = SKSpriteNode(imageNamed: "Space10") // Low Res
            case 12:
                mBackgroundImage = SKSpriteNode(imageNamed: "Space11") // Low Res
            case 13:
                mBackgroundImage = SKSpriteNode(imageNamed: "Space12") // Low Res
            case 14:
                mBackgroundImage = SKSpriteNode(imageNamed: "Space13") // Too low resoltuion
            case 15:
                mBackgroundImage = SKSpriteNode(imageNamed: "Space14") // Too low res
            case 16:
                mBackgroundImage = SKSpriteNode(imageNamed: "Space15") // Low Res
            case 17:
                mBackgroundImage = SKSpriteNode(imageNamed: "Space16") // Low Res
            default:
                mBackgroundImage = SKSpriteNode(imageNamed: "barnard_3")
        }

        mBackgroundImage!.zPosition = -1000 // Default zPosition is 0.0 so -1000 will put this behind the other nodes as long as they are above -1000
        mBackgroundImage!.position = CGPoint(x: theGameScene.frame.size.width/2, y: theGameScene.frame.size.height/2)
        mBackgroundImage!.scale(to: CGSize(width: theGameScene.frame.size.width, height: theGameScene.frame.size.height))
        mBackgroundImage!.alpha = 0.5
        theGameScene.addChild(mBackgroundImage!)
    }
    

    
}
