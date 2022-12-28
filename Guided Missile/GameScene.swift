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
//    private var mResetAsteroidFlag = false
    private var mResetMissileFlag = false  // set to true to reset the missile at the starbase

    private var mGameVM = GameViewModel()
    private var lastUpdateTime : TimeInterval = 0 // track time between frame updates in case it's needed
    private var mStarbaseSheildLevel = 2 // Start at level 2
    
//    private var label : SKLabelNode?
//    private var theShapeNode: SKShapeNode?
    
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
    
    // Added by Bill
    // This gets called before the didMove(to:) function gets called.
    override init(size: CGSize) {
        MyLog.debug("GameScene.init(size:) called")
        super.init(size: size)
        
        self.physicsWorld.contactDelegate = self // IMPORTANT - cant detect colisions without this

    }
    
    
    // SKScene has a 'required' initializer for an NSCoder parameter
    // Therefore we muast have one in case it ever gets called on the base class.
    required init?(coder aDecoder: NSCoder) {
        MyLog.debug("GameScene.init?(coder:) called")
        super.init(coder: aDecoder)
    }

    
    // MISSILE HITS ASTEROID - Call this when an asteroid and the missile collide
    // Pass in the Asteroid node.  Since there is only one missile node we don't need it passed in.
    func handleCollision_Asteroid_and_Missile(theAsteroidNode: SKShapeNode) {
        MyLog.debug("Missile hit Asteroid")
        processDestroidAsteroid(theAsteroidNode: theAsteroidNode)
        mResetMissileFlag = true // trigger missile reset later in the frame update
    }
    
    
    // ASTEROID hits STARBASE- Call this when an asteroid and the starbase collide
    // Pass in the Asteroid node.  Since there is only one starbase node we don't need it passed in.
    
    func handleCollision_Asteroid_and_Starbase(theAsteroidNode: SKShapeNode) {
        MyLog.debug("Missile hit Starbase")
        processDestroidAsteroid(theAsteroidNode: theAsteroidNode)
        
        // Reduce Starbase shield level
        mStarbaseSheildLevel -= 1
        
        if mStarbaseSheildLevel >= 2 {
            mShieldNode.strokeColor = UIColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 0.8)
        } else if mStarbaseSheildLevel == 1 {
//            mShieldNode.strokeColor = UIColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 0.5)
            mShieldNode.run(SKAction.fadeAlpha(to: 0.5, duration: 1))
        } else if mStarbaseSheildLevel == 0 {
            // Show NO shields - set alpha to 0
//            mShieldNode.strokeColor = UIColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 0.0)
            mShieldNode.run(SKAction.fadeAlpha(to: 0.0, duration: 1))
        } else {
            // DESTROIED - if the shiends are negative the starbase is destroide
            
        }
    }

    // ASTEROID DESTROIED - Process the destroid asteroid by exploding it and adding a new
    // asteroid if necessary
    func processDestroidAsteroid(theAsteroidNode: SKShapeNode) {

        //   Explosion Tutorial
        //   https://www.youtube.com/watch?v=cJy61bOqQpg
        //   Explostions at 32:30-35:22 - https://www.youtube.com/watch?v=cJy61bOqQpg
        //   Particl Emmiter creation : 2:43 Settings at 3:58
        let explosion = SKEmitterNode(fileNamed: "ExplosionParticles")!
        explosion.position = theAsteroidNode.position
        self.addChild(explosion)
        self.run(SKAction.wait(forDuration: 2.0)) {
            explosion.removeFromParent() // Remove the explosion after it runs
        }
        
        // Remove the destroied asteroid from everyplace that references it (the parent and the dictionary)
        theAsteroidNode.removeFromParent()
        mAsteroidNodeDict.removeValue(forKey: theAsteroidNode.name!)
        
        // vvvvv Add replacement asteroid vvvvv
        let newAsteroid = ShapeNodeBuilder.asteroidRandomNode()
        newAsteroid.position.y = 0
        let maxX = self.frame.size.width
        newAsteroid.position.x = Double.random(in: 0.0...maxX)
        newAsteroid.physicsBody?.velocity.dy = Double.random(in: -MAX_ASTEROID_VELOCITY...MAX_ASTEROID_VELOCITY)
        newAsteroid.physicsBody?.velocity.dx = Double.random(in: -MAX_ASTEROID_VELOCITY...MAX_ASTEROID_VELOCITY)
        mAsteroidNodeDict[newAsteroid.name!] = newAsteroid
        self.addChild(newAsteroid)
        // ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    }

    // SKPhysicsContactDelegate interface callback function
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody = SKPhysicsBody()
        var secondBody = SKPhysicsBody()
        
        // Sort the two bodies by the categoryBitMask so that we can make assumptions
        // about what object they must be and what we must do.
        // Note, the Missile is the smallest BitMask so it will always be firstBody
        // Sort Order is as follows
        //    let gCategoryMissile:    UInt32 = 0x1 << 0  // 1
        //    let gCategoryStarbase:   UInt32 = 0x1 << 1  // 2
        //    let gCategorySupplyShip: UInt32 = 0x1 << 2  // 4
        //    let gCategoryEnemyShip:  UInt32 = 0x1 << 3  // 8
        //    let gCategoryAsteroid:   UInt32 = 0x1 << 4  // 16

        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA  // missile?
            secondBody = contact.bodyB // Asteroid, Enemy Ship, Starbase or supply ship
        } else {
            firstBody = contact.bodyB  // missile?
            secondBody = contact.bodyA // Asteroid, Enemy Ship, Starbase or supply ship
        }
        
        // ERROR CHECK - It's possible that an object could contact TWO other objects in the same frame update.
        // E.g. An asteroid could hit the starbase in the same frame that the missile hits the asteroid.
        // If that happens, then the processing for the first contact could have resulted in a node being removed
        // Therefore, we must check if each node still exists before trying to process it here.
        guard firstBody.node != nil else {
            return // Nothing to do, the node was removed by a previous collision during this same frame update
        }
        guard secondBody.node != nil else {
            return // Nothing to do, the node was removed by a previous collision during this same frame update
        }

        
        // MISSILE Collision
        if firstBody.categoryBitMask == gCategoryMissile {
            // Hit Asteroid
            if secondBody.categoryBitMask == gCategoryAsteroid {
                let theAsteroidNode = secondBody.node as! SKShapeNode
                handleCollision_Asteroid_and_Missile(theAsteroidNode: theAsteroidNode)
            } else if secondBody.categoryBitMask == gCategoryEnemyShip { // Hit Enemy Space Ship
                MyLog.debug("Missile hit Enemy Space Ship")
            }
        
        // STARBASE - Check for Starbase Hit
        } else if firstBody.categoryBitMask == gCategoryStarbase {
            // Something Hit the Starbase
            if secondBody.categoryBitMask == gCategoryAsteroid {
                // Asteroid Hit the Starbase
                let theAsteroidNode = secondBody.node as! SKShapeNode
                handleCollision_Asteroid_and_Starbase(theAsteroidNode: theAsteroidNode)
            } else if secondBody.categoryBitMask == gCategoryEnemyShip {
                // Enemy Ship Hit the Starbase
                let theEnemyShipNode = secondBody.node as! SKShapeNode
                MyLog.debug("Enemy Ship hit Starbase")
            }

        // SUPPLY SHIP - Check for Supply Ship Hit
        } else if firstBody.categoryBitMask == gCategorySupplyShip {
            // Something Hit the Supply Ship
            if secondBody.categoryBitMask == gCategoryAsteroid {
                // Asteroid Hit the supply ship
                let theAsteroidNode = secondBody.node as! SKShapeNode
                MyLog.debug("Asteroid hit Supply Ship")
            } else if secondBody.categoryBitMask == gCategoryEnemyShip {
                // Enemy Ship Hit the Supply Ship
                let theEnemyShipNode = secondBody.node as! SKShapeNode
                MyLog.debug("Enemy Ship hit Supply Ship")
            }

        // ENEMY SHIP - Check for Enemy Ship Hit
        } else if firstBody.categoryBitMask == gCategoryEnemyShip {
            // Something Hit the Enemy Ship
            if secondBody.categoryBitMask == gCategoryAsteroid {
                // Asteroid Hit the enemy ship
                let theAsteroidNode = secondBody.node as! SKShapeNode
                MyLog.debug("Asteroid hit Enemy Ship")
            }
        } else { // Some other collision that we don't need to handle
            MyLog.debug("Unhandled collision type of some sort.  No Worries...")
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
    let (mStarbaseNode, mShieldNode) = ShapeNodeBuilder.starBaseNode() // Returns a tuple with the starbase node and the shield node
    let mEnemyShipNode = ShapeNodeBuilder.enemySpaceShipNode()
    var mAsteroidNodeDict = [String: SKShapeNode]() // Dictionary of Asteroids using the node name as key.
    override func didMove(to view: SKView) {
        setBackground(gameLevelNumber: 4) // Pass a different number for different backgrounds - Best: 4 (space4.jpg) with alpha of 0.5
        MyLog.debug("GameScene.didMove() called")
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0) // Set gravity to 0
        
        mMissileNode.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height - self.frame.size.height/4)
        self.addChild(mMissileNode)
        
        mSupplyShipNode.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height - self.frame.size.height/3)
        self.addChild(mSupplyShipNode)

        mStarbaseNode.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2)
        self.addChild(mStarbaseNode)

        mEnemyShipNode.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height - 2*self.frame.size.height/3)
        self.addChild(mEnemyShipNode)

        // Create Asteroid Nodes
        let maxX = self.frame.size.width
        for _ in 0..<4 {
            let asteroidNode = ShapeNodeBuilder.asteroidRandomNode()
            asteroidNode.position.y = 0
            asteroidNode.position.x = Double.random(in: 0.0...maxX)
            asteroidNode.physicsBody?.velocity.dy = Double.random(in: -MAX_ASTEROID_VELOCITY...MAX_ASTEROID_VELOCITY)
            asteroidNode.physicsBody?.velocity.dx = Double.random(in: -MAX_ASTEROID_VELOCITY...MAX_ASTEROID_VELOCITY)
            self.addChild(asteroidNode)

            // Add the asteroid to the dictionary
            mAsteroidNodeDict[asteroidNode.name!] = asteroidNode
        }


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
        
        // PAUSE / UNPAUSE Game
        realPaused = !realPaused
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
        let THRUST_MULTIPLIER = 3.0
        let MINIMUM_THRUST = 0.15 * THRUST_MULTIPLIER // How much thrust is needed before we start applying thrust
        let ROTATION_SENSITIVITY = 0.05 // How much phone tilt is needed to change missile orientation
        let EXAUST_MULTIPLIER = 100.0 // How fast should the exaust come out

        // vvvvv Time Management - Time Between Frames vvvvv
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }
        // Calculate time since last update
        let dt = currentTime - self.lastUpdateTime
        self.lastUpdateTime = currentTime
        // ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        
        
        // Update Missile Velocity based on phone orientation gravity
        let dx = Motion.shared.xGravity * THRUST_MULTIPLIER // Change in velocity
        
        let dy = (Motion.shared.yGravity + 0.3) * THRUST_MULTIPLIER // TODO use inverse sine to adjust the angle, then convert back instead of just adding something to the dy
        

        // Only change direction and show Thrust if the acceleration is > minThrust
        var thrust = sqrt(dx*dx+dy*dy)
        
        // Update Missile image orientation and velocity
        if thrust > ROTATION_SENSITIVITY {
            var angleRad = atan2(dy, dx)
            angleRad -= Double.pi/2 // Convert to clockwise with 0 radians pointing up
            mMissileNode.run(SKAction.rotate(toAngle: angleRad, duration: 0.2, shortestUnitArc: true))
        }

        if thrust > MINIMUM_THRUST {
            // Apply thrust to the missile
            mMissileNode.physicsBody!.velocity.dx += dx // Add change to velocity
            mMissileNode.physicsBody!.velocity.dy += dy

            // Limit thrust to 1 (which should be max anyway) because we use it for alpha
            if thrust > 1 {
                thrust = 1.0
            }
            

            // Show Exaust
            let pos = mMissileNode.position
            let exaustBall = SKShapeNode.init(circleOfRadius: 1)
            exaustBall.position = pos
            exaustBall.strokeColor = UIColor(red: 1.0, green: 0.3, blue: 0.0, alpha: thrust/5)
            exaustBall.glowWidth = 5.0
            exaustBall.fillColor = UIColor(red: 1.0, green: 1.0, blue: 0.0, alpha: thrust/2)
    //        exaustBall.strokeColor = UIColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 0.3)
            exaustBall.physicsBody = SKPhysicsBody()
            exaustBall.physicsBody?.isDynamic = true // can move
            
            
            // Calc exaust velocity (Total V = Missile velocity + thrust velocity)
            let missileVx = (mMissileNode.physicsBody!.velocity.dx)
            let missileVy = mMissileNode.physicsBody!.velocity.dy
            let exaustVx = missileVx + -dx*EXAUST_MULTIPLIER
            let exaustVy = missileVy + -dy*EXAUST_MULTIPLIER
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
    
    

    func correctMissilePosition() {
        if mResetMissileFlag { // reset the missile back at the starbase
            mMissileNode.position = mStarbaseNode.position
            mMissileNode.physicsBody?.velocity.dy = 0
            mMissileNode.physicsBody?.velocity.dx = 0
            mResetMissileFlag = false
        }

        // Move back on screen if out of bounds in X direction
        let maxX = self.frame.size.width
        if mMissileNode.position.x > maxX + xBuffer {
            mMissileNode.position.x = 0
        } else if mMissileNode.position.x < -xBuffer {
            mMissileNode.position.x = maxX
        }

        // Move back on screen if out of bounds in X direction
        let maxY = self.frame.size.height
        if mMissileNode.position.y > maxY + yBuffer {
            mMissileNode.position.y = 0
        } else if mMissileNode.position.y < -yBuffer {
            mMissileNode.position.y = maxY
        }
    }
    
    private let MAX_ASTEROID_VELOCITY = 50.0
    func correctAsteroidPositions() {
        let maxX = self.frame.size.width
        let maxY = self.frame.size.height
        
        // Iterate throuth the asteroids and update positions to keep them on the screen.
        for (_, node) in mAsteroidNodeDict { // key value is _ to avoid compiler warining
            // Move back on screen if out of bounds in X direction
            if node.position.x > maxX + xBuffer {
                node.position.x = 0
            } else if node.position.x < -xBuffer {
                node.position.x = maxX
            }

            // Move back on screen if out of bounds in X direction
            if node.position.y > maxY + yBuffer {
                node.position.y = 0
            } else if node.position.y < -yBuffer {
                node.position.y = maxY
            }
        }
    }

    /**
     Override this to perform game logic. Called exactly once per frame after any actions have been evaluated but before any physics are simulated. Any additional actions applied is not evaluated until the next update.
     */
    // Called every frame update after update() function is called
    let xBuffer = 20.0
    let yBuffer = 20.0
    override func didEvaluateActions() {
//        MyLog.debug("didEvaluateActions() called")
        
        correctMissilePosition()
        correctAsteroidPositions()
        
    }
    
    
    /**
     Override this to perform game logic. Called exactly once per frame after any actions have been evaluated and any physics have been simulated. Any additional actions applied is not evaluated until the next update. Any changes to physics bodies is not simulated until the next update.
     */
    // Called every frame update after didEvaluateActions() function is called
    override func didSimulatePhysics() {
//        MyLog.debug("didSimulatePhysics() called")
    }
    
    
    /**
     Override this to perform game logic. Called exactly once per frame after any enabled constraints have been applied. Any additional actions applied is not evaluated until the next update. Any changes to physics bodies is not simulated until the next update. Any changes to constraints will not be applied until the next update.
     */
    // Called every frame update after didApplyConstraints() function is called
    override func didApplyConstraints() {
//        MyLog.debug("didApplyConstraints() called")
    }
    
    /**
     Override this to perform game logic. Called after all update logic has been completed. Any additional actions applied are not evaluated until the next update. Any changes to physics bodies are not simulated until the next update. Any changes to constraints will not be applied until the next update.
     
     No futher update logic will be applied to the scene after this call. Any values set on nodes here will be used when the scene is rendered for the current frame.
     */
    // Called every frame update after didApplyConstraints() function is called
    override func didFinishUpdate() {
//        MyLog.debug("didFinishUpdate() called")
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
