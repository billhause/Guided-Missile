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




class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private var mGameVM = GameViewModel()
    private var lastUpdateTime : TimeInterval = 0 // track time between frame updates in case it's needed

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
        
        self.physicsWorld.contactDelegate = self // IMPORTANT - cant detect colisions without this

    }
    
    
    // SKScene has a 'required' initializer for an NSCoder parameter
    // Therefore we muast have one in case it ever gets called on the base class.
    required init?(coder aDecoder: NSCoder) {
        MyLog.debug("GameScene.init?(coder:) called")
        super.init(coder: aDecoder)
    }

    // SKPhysicsContactDelegate interface callback function
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody = SKPhysicsBody()
        var secondBody = SKPhysicsBody()
                
        // Sort the two bodies by the categoryBitMask so that we can make assumptions
        // about what object they must be and what we must do.
        // Note, the Missile is the smallest BitMask so it will always be firstBody
        //
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA  // missile?
            secondBody = contact.bodyB // Asteroid, Enemy Ship, Star Base or supply ship
        } else {
            firstBody = contact.bodyB  // missile?
            secondBody = contact.bodyA // Asteroid, Enemy Ship, Star Base or supply ship
        }
        
        // Is the firstBody the Missile? - I.e. did the missile hit something?
        if firstBody.categoryBitMask == gCategoryMissile {
            // Hit Asteroid
            if secondBody.categoryBitMask == gCategoryAsteroid {
                MyLog.debug("Missile hit Asteroid")
                
                //   Explosion Tutorial
                //   https://www.youtube.com/watch?v=cJy61bOqQpg
                //   Explostions at 32:30-35:22 - https://www.youtube.com/watch?v=cJy61bOqQpg
                //   Particl Emmiter creation : 2:43 Settings at 3:58
                let explosion = SKEmitterNode(fileNamed: "ExplosionParticles")!
                explosion.position = mAsteroidNode.position
                self.addChild(explosion)
                self.run(SKAction.wait(forDuration: 2.0)) {
                    explosion.removeFromParent() // Remove the explosion after it runs
                }
                
                // Reset the missile
                Why can't i update the position?'
//                mMissileNode.position = mStarBaseNode.position
                mMissileNode.position.x = 0.0
                mMissileNode.position.y = 0.0
                mMissileNode.physicsBody?.velocity.dy = 0
                mMissileNode.physicsBody?.velocity.dx = 0
                
                
                
                
            } else if secondBody.categoryBitMask == gCategoryEnemyShip { // Hit Enemy Space Ship
                MyLog.debug("Missile hit Enemy Space Ship")
            } else if secondBody.categoryBitMask == gCategoryStarBase {  // Hit Star Base
                MyLog.debug("Missile hit Star Base")
            } else if secondBody.categoryBitMask == gCategorySupplyShip { // Hit Friendly Supply Ship
                MyLog.debug("Missile hit Friendly Supply Ship")
            } else { // Hit something unknown
                MyLog.debug("ERROR Missile Hit and UNKNOWN OBJECT - This should not happen")
            }
        } else { // Something other than a missile
            MyLog.debug("Objects Collided and neither was a missile")
        }


    }
    
    // This gets called when the colliding objects separate
    // Callback Function for SKPhysicsContactDelegate
    func didEnd(_ contact: SKPhysicsContact) {
        // MyLog.debug("didEnd(contact:) called")
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
    let mMissileNode = ShapeNodeBuilder.missileNode()
    let mSupplyShipNode = ShapeNodeBuilder.supplyShipNode()
    let mStarBaseNode = ShapeNodeBuilder.starBaseNode()
    let mEnemyShipNode = ShapeNodeBuilder.enemySpaceShipNode()
    let mAsteroidNode = ShapeNodeBuilder.asteroidRandomNode()
    override func didMove(to view: SKView) {
        setBackground(gameLevelNumber: 4) // Pass a different number for different backgrounds - Best: 4 (space4.jpg) with alpha of 0.5
        MyLog.debug("GameScene.didMove() called wdh")
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0) // Set gravity to 0
        
        mMissileNode.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height - self.frame.size.height/4)
        self.addChild(mMissileNode)
        
        mSupplyShipNode.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height - self.frame.size.height/3)
        self.addChild(mSupplyShipNode)

        mStarBaseNode.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2)
        self.addChild(mStarBaseNode)

        mAsteroidNode.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height - 3*self.frame.size.height/4)
        self.addChild(mAsteroidNode)

        mEnemyShipNode.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height - 2*self.frame.size.height/3)
        self.addChild(mEnemyShipNode)



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
    // Called before each frame is rendered
    var gUpdateCount = 0
    override func update(_ currentTime: TimeInterval) {
        
        // vvvvv Time Management - Time Between Frames vvvvv
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }
        // Calculate time since last update
        let dt = currentTime - self.lastUpdateTime
        self.lastUpdateTime = currentTime
        // ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        
        
        // Update Missile Velocity based on phone orientation gravity
        let thrustMultiplier = 1.0 // Higher numbers make thrust more sensitive
        let dx = Motion.shared.xGravity * thrustMultiplier // Change in velocity
        let dy = Motion.shared.yGravity * thrustMultiplier
        mMissileNode.physicsBody!.velocity.dx += dx // Add change to velocity
        mMissileNode.physicsBody!.velocity.dy += dy


        // Only change direction and show Thrust if the acceleration is > minThrust
        let minThrust = 0.02
        var thrust = sqrt(dx*dx+dy*dy)
        if thrust > minThrust {
            // Update Missile image orientation and velocity
            var angleRad = atan2(dy, dx)
            angleRad -= Double.pi/2 // Convert to clockwise with 0 radians pointing up
            mMissileNode.run(SKAction.rotate(toAngle: angleRad, duration: 0.2, shortestUnitArc: true))
            
            // Limit thrust to 1 (which should be max anyway) because we use it for alpha
            if thrust > 1 {
                thrust = 1.0
            }
            // Show Exaust
            let pos = mMissileNode.position
            let exaustBall = SKShapeNode.init(circleOfRadius: 1)
            exaustBall.position = pos
            exaustBall.strokeColor = UIColor(red: 1.0, green: 0.3, blue: 0.0, alpha: thrust/3)
            exaustBall.glowWidth = 5.0
            exaustBall.fillColor = UIColor(red: 1.0, green: 1.0, blue: 0.0, alpha: thrust)
    //        exaustBall.strokeColor = UIColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 0.3)
            exaustBall.physicsBody = SKPhysicsBody()
            exaustBall.physicsBody?.isDynamic = true // can move
            
            
            // Calc exaust velocity (Total V = Missile velocity + thrust velocity)
            let missileVx = (mMissileNode.physicsBody!.velocity.dx)
            let missileVy = mMissileNode.physicsBody!.velocity.dy
            let exaustVx = missileVx + -dx*500
            let exaustVy = missileVy + -dy*500
            exaustBall.physicsBody!.velocity = CGVector(dx: exaustVx, dy: exaustVy)
            self.addChild(exaustBall)
            let shrinkAndFadeAction = SKAction.group([SKAction.scale(to: 5.0, duration: 0.8),
                                                      SKAction.fadeOut(withDuration: 0.8)])
            exaustBall.run(SKAction.sequence([shrinkAndFadeAction,
                                             SKAction.removeFromParent()]))
        }
        
        
        gUpdateCount += 1
        mLabel3.text = String(format: "thrust: %3.4f", thrust)
        mLabel2.text = String(format: "dy: %3.4f", dy)
        mLabel1.text = String(format: "Update Count: %d", gUpdateCount)
    }
    
    
    
    // Add a background to this GameScene based on the number passed in.
    private var mBackgroundImage: SKSpriteNode?
    private func setBackground(gameLevelNumber: Int) {
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
