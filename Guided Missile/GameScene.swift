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
    private var mGameVM = GameViewModel()
    
    private var label : SKLabelNode?
    private var theShapeNode: SKShapeNode?

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
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0) // Set gravity to 0
        
        let missileNode = ShapeNodeBilder.missileNode()
        missileNode.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height - self.frame.size.height/3)
        self.addChild(missileNode)


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

    }
    
    
    func touchDown(atPoint pos : CGPoint) {
        MyLog.debug("GameScene.touchDown() called")
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        MyLog.debug("GameScene.touchMoved() called")
    }
    
    func touchUp(atPoint pos : CGPoint) {
        MyLog.debug("GameScene.touchUp() called")
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
        

//        theShapeNode?.run(SKAction.move(to: CGPoint(x:theYaw2Point.getPixel(), y: theRoll2Point.getPixel()), duration: 0.2))

        mLabel1.text = String(format: "Debug 1: %3.0f", 0.1)
        mLabel2.text = String(format: "Debug 2: %3.0f", 0.2)
        mLabel3.text = String(format: "Debug 3: %3.0f", 0.3)

    }
    
    
    
    // Add a background to this GameScene based on the number passed in.
    var mBackgroundImage: SKSpriteNode?
    func setBackground(gameLevelNumber: Int) {
        let theGameScene = self
        theGameScene.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0) // Set background to black
        
        // Remove the old background image from the GameScene if it exists
        if mBackgroundImage != nil { // Check optional for existance
            if mBackgroundImage!.parent != nil {
                mBackgroundImage!.removeFromParent()
            }
        }
        
        let imageNumber = gameLevelNumber % 18 // Reduce the mRoundNumber number to something in our range of backgrounds
        mBackgroundImage = mGameVM.getBackgroundNode(gameLevelNumber: imageNumber)

        mBackgroundImage!.zPosition = -1000 // Default zPosition is 0.0 so -1000 will put this behind the other nodes as long as they are above -1000
        mBackgroundImage!.position = CGPoint(x: theGameScene.frame.size.width/2, y: theGameScene.frame.size.height/2)
        mBackgroundImage!.scale(to: CGSize(width: theGameScene.frame.size.width, height: theGameScene.frame.size.height))
        theGameScene.addChild(mBackgroundImage!)
    }
    

    
}
