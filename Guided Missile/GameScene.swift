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
import AVFoundation // Sound Player
//import GameplayKit

let INITIAL_SHIELD_LEVEL = 2
struct GameModel {
    var mLevel                = 1 // game level - Should be 1
    var mAsteroidsRemaining   = 3 // 3 - Number of asteroids that still need to be destroied for the current level
    var mScore                = 0
    var mHighScore            = 0 // Highest score achieved to date
    var mShieldLevel          = INITIAL_SHIELD_LEVEL
    var mGameOver             = false
    var mFirstRun             = true // Display instructions if it's the first run.
    
    var totalAsteroids: Int { // How many asteroids must be destroid to complete this level
        switch mLevel {
        case 1:
            return 3
        default:
            return mLevel + 2
        }
    }
    
    var maxAsteroidsInPlay: Int { // Number of asteroids to have in play at one time
        return mLevel // for now we're setting the number of asteroids to start with to be the same as the level you're on.
    }
    
    // You should set the level variable before calling this function
    // because some of the values may depend on the level.
    mutating func resetLevel() {
        mAsteroidsRemaining = totalAsteroids
        mShieldLevel = INITIAL_SHIELD_LEVEL
    }
    
    func getLevelBonus(level: Int) -> Int {
        if level <= 1 { return 0 }
        
        // Recursively calculate bonus
        let bonus = (level-1) + 2 + getLevelBonus(level: level-1)
        return bonus
    }
    
    func playAgainButton1Level() -> Int { return 1} // What level should Button 1 take us to?
    func playAgainButton2Level() -> Int { return mLevel/2} // What level should button 2 take us to?
    func playAgainButton3Level() -> Int { return mLevel}
    
    func playAgainButton1Bonus() -> Int { return getLevelBonus(level: 1) }  // What point bonus should be displayed for button 1
    func playAgainButton2Bonus() -> Int { return getLevelBonus(level: mLevel/2) } // What point bonus should be displayed for button 2
    func playAgainButton3Bonus() -> Int { return getLevelBonus(level: mLevel) }

    
    
}



class GameScene: SKScene, SKPhysicsContactDelegate {
    var theModel = GameModel()
    private var mResetMissileFlag = false  // set to true to reset the missile at the starbase

    private var mGameVM = GameViewModel()
    private var lastUpdateTime : TimeInterval = 0 // track time between frame updates in case it's needed
//    private var mStarbaseSheildLevel = 2 // Start at level 2
    
    
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


    // Call this after we beat the current level and need to move on to the next level
    func initializeNextLevel() {
        //
        theModel.mLevel += 1 // move to next level
        theModel.resetLevel()
        MyLog.debug("Starting Next Level: \(theModel.mLevel)")
        
        // Reset Shields - the star base node should still be in tact since we beat the level
        mShieldNode.run(SKAction.fadeAlpha(to: 0.8, duration: 1))
        
        // Add starting number of Asteroids to Dictionary
        let maxX = self.frame.size.width
        for _ in 0..<theModel.maxAsteroidsInPlay {
            let asteroidNode = ShapeNodeBuilder.asteroidRandomNode()
            asteroidNode.position.y = 0
            asteroidNode.position.x = Double.random(in: 0.0...maxX)
            asteroidNode.physicsBody?.velocity.dy = Double.random(in: -MAX_ASTEROID_VELOCITY...MAX_ASTEROID_VELOCITY)
            asteroidNode.physicsBody?.velocity.dx = Double.random(in: -MAX_ASTEROID_VELOCITY...MAX_ASTEROID_VELOCITY)
            self.addChild(asteroidNode)

            // Add the asteroid to the dictionary
            mAsteroidNodeDict[asteroidNode.name!] = asteroidNode
        }

        // Display Text - Warping To Asteroid Field 2 etc.  ONLY IF Field 2 or greater
        if theModel.mLevel > 1 {
            let line1Position = CGPoint(x: self.size.width/2, y: self.size.height * 0.75)
            let line2Position = CGPoint(x: self.size.width/2, y: self.size.height * 0.75 - 20)
            Helper.fadingAlert(scene: self, position: line1Position, text: "Warping to")
            Helper.fadingAlert(scene: self, position: line2Position, text: "Asteroid Field \(theModel.mLevel)")
        }

        warpAnimation() // Show starbase warping out and back in.
    }
    
    // MISSILE HITS ASTEROID - Call this when an asteroid and the missile collide
    // Pass in the Asteroid node.  Since there is only one missile node we don't need it passed in.
    func handleCollision_Asteroid_and_Missile(theAsteroidNode: SKShapeNode) {
//        MyLog.debug("Missile hit Asteroid")
        processDestroidAsteroid(theAsteroidNode: theAsteroidNode)
        theModel.mScore += 1
        mResetMissileFlag = true // move missile back to center of starbase later in the frame update
        
        if theModel.mAsteroidsRemaining < 1 {
            // We beat the level so reset and start the next level
            initializeNextLevel()
        }

    }

    // ASTEROID hits STARBASE- Call this when an asteroid and the starbase collide
    // Pass in the Asteroid node.  Since there is only one starbase node we don't need it passed in.
    func handleCollision_Asteroid_and_Starbase(theAsteroidNode: SKShapeNode) {
        MyLog.debug("Missile hit Starbase")
        
        // Reduce Starbase shield level
        theModel.mShieldLevel -= 1
        
        
        if theModel.mShieldLevel >= 2 {
            mShieldNode.strokeColor = UIColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 0.8)
        } else if theModel.mShieldLevel == 1 {
            mShieldNode.run(SKAction.fadeAlpha(to: 0.5, duration: 1))
        } else if theModel.mShieldLevel == 0 {
            // Show NO shields - set alpha to 0
            mShieldNode.run(SKAction.fadeAlpha(to: 0.0, duration: 1))
        } else {
            // DESTROIED - if the shields are negative then the starbase is destroide
            Sound.shared.play(forResource: "ExplosionStarbaseSound")   // Good Starbase Explosion Sound
            
            Haptic.shared.longVibrate() // Long vibration like Error vibrate
            
            let explosion = SKEmitterNode(fileNamed: "ExplosionStarbase")!
            explosion.position = mStarbaseNode.position
            self.addChild(explosion)
            self.run(SKAction.wait(forDuration: 2.0)) {
                explosion.removeFromParent() // Remove the explosion after it runs
            }
            
            
            // REMOVE THE Starbase and the missile
            mStarbaseNode.removeFromParent()
            mMissileNode.removeFromParent()
            Sound.shared.thrustSoundOff() // Stop thrust sound
            theModel.mGameOver = true
            
            // Wait 2 seconds for starbase explosion to finish then show Play Again buttons
            updatePlayAgainButtonText()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.mPlayAgainButton1.isHidden = false // show the button
                self.mPlayAgainButton2.isHidden = false // show the button
                self.mPlayAgainButton3.isHidden = false // show the button
            }

        }

        processDestroidAsteroid(theAsteroidNode: theAsteroidNode)
        
        // If this was the last asteroid and the base is not destroid, then we beat the
        // level even though the starbase destroied the last asteroid in the collision
        if (theModel.mAsteroidsRemaining < 1) && (theModel.mShieldLevel >= 0) {
            initializeNextLevel()
        }
    }

    
    func warpAnimation() {
        let WARP_DURATION = 1.0
        let warpOutAction = SKAction.group([SKAction.rotate(byAngle: 2*3.141, duration: WARP_DURATION/2),
                                            SKAction.scale(to: 0.01, duration: WARP_DURATION/2)
                                            ])
        let warpInAction = SKAction.group([SKAction.rotate(byAngle: 2*3.141, duration: WARP_DURATION/2),
                                           SKAction.scale(to: 1.0, duration: WARP_DURATION/2)
                                          ])
        let actionSequence = SKAction.sequence([warpOutAction, warpInAction])
        mStarbaseNode.run(actionSequence)

    }
    
    // Update the Play Again button text based on max level achieved
    private func updatePlayAgainButtonText() {
        // vvvvv Add Play Again Buttons vvvvv
        let buttonPosition1 = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height*0.8)
        let buttonPosition2 = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height*0.6)
        let buttonPosition3 = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height*0.4)

        // Remove from parent if necessary
        if mPlayAgainButton1.parent != nil { mPlayAgainButton1.removeFromParent() }
        if mPlayAgainButton2.parent != nil { mPlayAgainButton2.removeFromParent() }
        if mPlayAgainButton3.parent != nil { mPlayAgainButton3.removeFromParent() }

        
        self.mPlayAgainButton1 = Helper.makeButton(position: buttonPosition1,
                                                   text: "Play Again\nLevel 1\nBonus: \(theModel.playAgainButton1Bonus())")
        self.addChild(self.mPlayAgainButton1)
        self.mPlayAgainButton1.isHidden = true // Hide the button

        if theModel.mLevel > 4 { // Only show the other two buttons if the level is high enough
            self.mPlayAgainButton2 = Helper.makeButton(position: buttonPosition2,
                                                       text: "Play Again\nLevel \(theModel.mLevel/2)\nBonus: \(theModel.playAgainButton2Bonus())")
            self.addChild(self.mPlayAgainButton2)
            self.mPlayAgainButton2.isHidden = true // Hide the button
            
            self.mPlayAgainButton3 = Helper.makeButton(position: buttonPosition3,
                                                       text: "Play Again\nLevel \(theModel.mLevel)\nBonus: \(theModel.playAgainButton3Bonus())")
            self.addChild(self.mPlayAgainButton3)
            self.mPlayAgainButton3.isHidden = true // Hide the button
        }
        // ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    }
    

    // ASTEROID DESTROIED - Process the destroid asteroid by exploding it and adding a new
    // asteroid if necessary
    func processDestroidAsteroid(theAsteroidNode: SKShapeNode) {

        theModel.mAsteroidsRemaining -= 1
        
        //   Explosion Tutorial
        //   https://www.youtube.com/watch?v=cJy61bOqQpg
        //   Explostions at 32:30-35:22 - https://www.youtube.com/watch?v=cJy61bOqQpg
        //   Particl Emmiter creation : 2:43 Settings at 3:58
        let explosion = SKEmitterNode(fileNamed: "ExplosionParticles")!
        // let explosion = SKEmitterNode(fileNamed: "ExplosionStarbase")!
        
        explosion.position = theAsteroidNode.position
        self.addChild(explosion)
        self.run(SKAction.wait(forDuration: 2.0)) {
            explosion.removeFromParent() // Remove the explosion after it runs
        }
        
        // Play Sound - Asteroid Explosion
        Sound.shared.play(forResource: "asteroid_explosion") // Good Asteroid Explosion Sound - Short Bang

        Haptic.shared.boomVibrate()
        
        
        // Remove the destroied asteroid from everyplace that references it (the parent and the dictionary)
        theAsteroidNode.removeFromParent()
        mAsteroidNodeDict.removeValue(forKey: theAsteroidNode.name!)
        
        // vvvvv Add replacement asteroid vvvvv
        if theModel.mAsteroidsRemaining >= theModel.maxAsteroidsInPlay {
            let newAsteroid = ShapeNodeBuilder.asteroidRandomNode()
            newAsteroid.position.y = 0
            let maxX = self.frame.size.width
            newAsteroid.position.x = Double.random(in: 0.0...maxX)
            newAsteroid.physicsBody?.velocity.dy = Double.random(in: -MAX_ASTEROID_VELOCITY...MAX_ASTEROID_VELOCITY)
            newAsteroid.physicsBody?.velocity.dx = Double.random(in: -MAX_ASTEROID_VELOCITY...MAX_ASTEROID_VELOCITY)
            mAsteroidNodeDict[newAsteroid.name!] = newAsteroid
            self.addChild(newAsteroid)
        }
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
        //    let gCategorySaucer:  UInt32 = 0x1 << 3  // 8
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
            } else if secondBody.categoryBitMask == gCategorySaucer { // Hit Enemy Space Ship
                handleCollision_Spaceship_and_Missile()
            }
        
        // STARBASE - Check for Starbase Hit
        } else if firstBody.categoryBitMask == gCategoryStarbase {
            // Something Hit the Starbase
            if secondBody.categoryBitMask == gCategoryAsteroid {
                // Asteroid Hit the Starbase
                let theAsteroidNode = secondBody.node as! SKShapeNode
                handleCollision_Asteroid_and_Starbase(theAsteroidNode: theAsteroidNode)
            } else if secondBody.categoryBitMask == gCategorySaucer {
                // Enemy Ship Hit the Starbase
                MyLog.debug("Enemy Ship hit Starbase")
            }

        // SUPPLY SHIP - Check for Supply Ship Hit
        } else if firstBody.categoryBitMask == gCategorySupplyShip {
            // Something Hit the Supply Ship
            if secondBody.categoryBitMask == gCategoryAsteroid {
                // Asteroid Hit the supply ship
                MyLog.debug("Asteroid hit Supply Ship")
            } else if secondBody.categoryBitMask == gCategorySaucer {
                // Enemy Ship Hit the Supply Ship
                MyLog.debug("Enemy Ship hit Supply Ship")
            }

        // ENEMY SHIP - Check for Enemy Ship Hit
        } else if firstBody.categoryBitMask == gCategorySaucer {
            // Something Hit the Enemy Ship
            if secondBody.categoryBitMask == gCategoryAsteroid {
                // Asteroid Hit the enemy ship
                MyLog.debug("Asteroid hit Enemy Ship")
                let theAsteroidNode = secondBody.node as! SKShapeNode
                handleCollision_Spaceship_and_Asteroid(theAsteroidNode: theAsteroidNode)

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
    // MARK: Member Variables and Nodes
    var mLabel1 = SKLabelNode(fontNamed: "Courier") // label for debugging
    var mLabel2 = SKLabelNode(fontNamed: "Courier")
    var mLabel3 = SKLabelNode(fontNamed: "Courier")
    var mPlayAgainButton1 = SKShapeNode()
    var mPlayAgainButton2 = SKShapeNode()
    var mPlayAgainButton3 = SKShapeNode()
    let mMissileNode = ShapeNodeBuilder.missileNode()
    let mSupplyShipNode = ShapeNodeBuilder.supplyShipNode()
    let (mStarbaseNode, mShieldNode) = ShapeNodeBuilder.starBaseNode() // Returns a tuple with the starbase node and the shield node
    let mSaucerNode = ShapeNodeBuilder.enemySpaceShipNode()
    var mAsteroidNodeDict = [String: SKShapeNode]() // Dictionary of Asteroids using the node name as key.
    override func didMove(to view: SKView) {
        setBackground(gameLevelNumber: 4) // Pass a different number for different backgrounds - Best: 4 (space4.jpg) with alpha of 0.5
        MyLog.debug("GameScene.didMove() called")
        
        // Initialize Sound Player - Force singleton load by playing silent sound
        Sound.shared.play(forResource: "silent_sound")
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0) // Set gravity to 0
        
        mMissileNode.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height - self.frame.size.height/4)
        self.addChild(mMissileNode)
        
        mSupplyShipNode.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height - self.frame.size.height/3)
        self.addChild(mSupplyShipNode)

        mStarbaseNode.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2)
        self.addChild(mStarbaseNode)

        self.addChild(mSaucerNode)
        startSaucer()

        theModel.mScore = 0
        theModel.mLevel = 0   // wdh start at 0 because it will be incremented to 1 by initializeNextLevel() on next line
        initializeNextLevel() // Add asteroids to the scene, increment level, reset shields, score etc.
        
        
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

        if theModel.mFirstRun {
            // Display instructions if this is the first run of the game.
            let line1Position = CGPoint(x: self.size.width/2, y: self.size.height * 0.85)
            let line2Position = CGPoint(x: self.size.width/2, y: self.size.height * 0.72)
            let line3Position = CGPoint(x: self.size.width/2, y: self.size.height * 0.62)

            let instructions1 = "Hold Phone Flat \n\nTilt phone slightly forward to guid missile UP"
            let instructions2 = "Tilt phone slightly back to guid missile down"
            let instructions3 = "Destroy all asteroids!"

            Helper.fadingAlert(scene: self, position: line1Position, text: instructions1, fontSize: CGFloat(18), duration: 5)
            Helper.fadingAlert(scene: self, position: line2Position, text: instructions2, fontSize: CGFloat(18), duration: 5, delay: 5)
            Helper.fadingAlert(scene: self, position: line3Position, text: instructions3, fontSize: CGFloat(18), duration: 5, delay: 10)
        }
        
    }
    
    // Rest the game when the use clicks Play Again
    func resetGame(level: Int) {
        
        if theModel.mScore > theModel.mHighScore {
            theModel.mHighScore = theModel.mScore
        }
        theModel.mScore = theModel.getLevelBonus(level: level)
        
        theModel.mGameOver = false // we're playing agian.
        
        // Clear out the Asteroid Dictionary
        for (_, node) in mAsteroidNodeDict {
            node.removeFromParent() // Remove all asteroids from parent
        }
        mAsteroidNodeDict.removeAll()

        theModel.mLevel = level-1 // initializeNextLevel() will increment the level to 1
        initializeNextLevel()

        // Reset the Starbase
        self.addChild(mStarbaseNode)
        
        // Reset the Missile
        self.addChild(mMissileNode)
        mMissileNode.position = mStarbaseNode.position
        mMissileNode.physicsBody?.velocity.dy = 0
        mMissileNode.physicsBody?.velocity.dx = 0

    }
    
    private func hidePlayAgainButtons() {
        mPlayAgainButton1.isHidden = true
        mPlayAgainButton2.isHidden = true
        mPlayAgainButton3.isHidden = true
    }
    
    func touchDown(atPoint pos : CGPoint) {
        MyLog.debug("GameScene.touchDown() called")
        
        // Check Play Again Buttons
        if !mPlayAgainButton1.isHidden && mPlayAgainButton1.frame.contains(pos) {
            hidePlayAgainButtons()
            resetGame(level: theModel.playAgainButton1Level()) // Reset to level 1
        } else if !mPlayAgainButton2.isHidden && mPlayAgainButton2.frame.contains(pos) {
            hidePlayAgainButtons()
            resetGame(level: theModel.playAgainButton2Level()) // Reset to mid level
        } else if !mPlayAgainButton3.isHidden && mPlayAgainButton3.frame.contains(pos) {
            hidePlayAgainButtons()
            resetGame(level: theModel.playAgainButton3Level()) // Reset to highest level achieved
            
        // Check Pause / Unpause
        } else {
            // PAUSE / UNPAUSE Game
            realPaused = !realPaused
            if realPaused {
                Sound.shared.thrustSoundOff() // Stop thrust sound
            }
        }

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
        // let dt = currentTime - self.lastUpdateTime
        let _ = currentTime - self.lastUpdateTime
        self.lastUpdateTime = currentTime
        // ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        
        updateMissileFrame()
        updateSaucerFrame()
        
        gUpdateCount += 1
        mLabel3.text = String(format: "Score: %d", theModel.mScore)
        mLabel2.text = String(format: "Level: %d", theModel.mLevel)  // %3.4f", dy)
        mLabel1.text = String(format: "High Score: %d", theModel.mHighScore)
    }
    
    /**
     Override this to perform game logic. Called exactly once per frame after any actions have been evaluated but before any physics are simulated. Any additional actions applied is not evaluated until the next update.
     */
    // Called every frame update after update() function is called
    let xBuffer = 10.0 // How far off the screen does an asteroid need to be before appearing on the other side
    let yBuffer = 10.0
    override func didEvaluateActions() {
        correctMissilePosition()
        correctAsteroidPositions()
        correctSaucerPosition()
    }

    
    
    
    // limit must be a positive number.  Else the input will be returend as the result
    func vectorClamp(dx: Double, dy: Double, limit: Double) -> (dx: Double, dy: Double) {
        // Get the Unit Vector components in x and y directions
        let mag = sqrt(dx*dx+dy*dy)
        if (mag <= limit) || (limit <= 0.0) || (mag == 0.0) {
            return (dx, dy) // Nothing to do
        }
        
        let unitX = dx/mag
        let unitY = dy/mag
        
        let newX = unitX * limit
        let newY = unitY * limit
        
        return (newX, newY)
    }
    
    
    func updateMissileFrame() {
        // NOTES:
        // GravityX and GravityY raw values are between -1.0 and 1.0
        // We add an offset to GravityY so that the zero point is at about a 30 degree angle so that
        // the user can hold the phone comfortably without accelerating the missile.
        // We want to limit how much the user tilts the phone so we limit maximum thrust long before
        // the phone is tilted on its side or vertical
        // To get the thrust in a fun range we multiply it by THRUST_MULTIPLIER
        // A good fast acceleration is about 1.0 so let's limit it to about that
        // Make THRUST_MULTIPLIER around 5 so that we reach MAX_THRUST long before tilting the phone verticle
        //
        //
        let THRUST_MULTIPLIER = 4.0
        let MAX_THRUST = 1.0 // We don't want full phone tilting by user
        let MINIMUM_THRUST = 0.3 // How much thrust is needed before we start applying thrust
        let ROTATION_SENSITIVITY = 0.0 //0.05 // How much phone tilt is needed to change missile orientation
        let EXAUST_MULTIPLIER = 120.0 // How fast should the exaust come out

        if !theModel.mGameOver {
            // Update Missile Velocity based on phone orientation gravity
            var dx = Motion.shared.xGravity * THRUST_MULTIPLIER // Change in velocity
            var dy = (Motion.shared.yGravity + 0.4) * THRUST_MULTIPLIER // TODO use inverse sine to adjust the angle, then convert back instead of just adding something to the dy
            
            let thrust = sqrt(dx*dx+dy*dy)
            
            // Limit thrust to MAX_THRUST value
            if thrust > MAX_THRUST {
                let thrustVector = vectorClamp(dx: dx, dy: dy, limit: MAX_THRUST) // Reduce vector magnitude to MAX_THRUST
                dx = thrustVector.dx
                dy = thrustVector.dy
            }
            
            // Update Missile image orientation and velocity
            if thrust > ROTATION_SENSITIVITY {
                var angleRad = atan2(dy, dx)
                angleRad -= Double.pi/2 // Convert to clockwise with 0 radians pointing up
                mMissileNode.run(SKAction.rotate(toAngle: angleRad, duration: 0.2, shortestUnitArc: true))
            }

            // Only apply Thrust if the acceleration is > minThrust
            if thrust > MINIMUM_THRUST {
                // Apply thrust to the missile
                mMissileNode.physicsBody!.velocity.dx += dx // Add change to velocity
                mMissileNode.physicsBody!.velocity.dy += dy

                
                // Show Exaust
                let pos = mMissileNode.position
                let exaustBall = SKShapeNode.init(circleOfRadius: 1)
                exaustBall.position = pos
//                exaustBall.strokeColor = UIColor(red: 1.0, green: 0.3, blue: 0.0, alpha: 0.2) // 0.2 // orange
                exaustBall.strokeColor = UIColor(red: 1.0, green: 0.3, blue: 0.0, alpha: 0.1)
                exaustBall.glowWidth = 5.0
//                exaustBall.fillColor = UIColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 0.5) // 0.5 yellow
                exaustBall.fillColor = UIColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 0.6)
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
//                Sound.shared.saucerSoundOn()
                Sound.shared.thrustSoundOn(volume: Float((thrust-MINIMUM_THRUST)/1.5)) // Thrust louder if stronger.  divide to adjust nominal volume
            } else {
                Sound.shared.thrustSoundOff() // Stop thrust sound if not thrusting
            }
        }
        // ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
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
    
    
    
    
    // MARK: Saucer Code
    private var mResetSaucerFlag = false   // set to true to reset the saucer position after being destroid

    // Start the Enemy flying saucer
    func startSaucer() {
        mSaucerNode.position.y = self.frame.size.height    // Top of screen
        mSaucerNode.position.x = self.frame.size.width/2  // Center of screen
        mSaucerNode.isHidden = false
        Sound.shared.saucerSoundOn()
    }
    
    // Update the Enemy Spaceship one frame
    func updateSaucerFrame() {
        var posY = mSaucerNode.position.y
        posY -= 0.2 // How fast does it move down the screen?  Bigger numbers are faster
        mSaucerNode.position.y = posY
        
        // Calc X postition
        let xInput = posY/40  // How fast does it move back and forth - Bigger Denominator is slower
        let xOffset = self.frame.size.width / 2 // Center of screen
        let xPos = (xOffset * 0.9) * sin(xInput) + xOffset
        mSaucerNode.position.x = xPos
    }
    
    
    func correctSaucerPosition() {
        var posY = mSaucerNode.position.y
        if posY < 0 {   // Move back to Top of screen
            posY = self.frame.size.height
            mSaucerNode.position.y = posY
        }
        
        if mResetSaucerFlag { // reset the saucer back to it's starrting position
            startSaucer()
            mResetSaucerFlag = false
        }

    }
    
    // SAUCER DESTROIED - Process the destroid Saucer by exploding
    func processDestroidSaucer() {
        //   Explosion Tutorial
        //   https://www.youtube.com/watch?v=cJy61bOqQpg
        //   Explostions at 32:30-35:22 - https://www.youtube.com/watch?v=cJy61bOqQpg
        //   Particl Emmiter creation : 2:43 Settings at 3:58
        let explosion = SKEmitterNode(fileNamed: "ExplosionSaucer")!
        explosion.position = mSaucerNode.position
        self.addChild(explosion)
        self.run(SKAction.wait(forDuration: 2.0)) {
            explosion.removeFromParent() // Remove the explosion after it runs
        }
        Sound.shared.saucerSoundOff()
        Sound.shared.play(forResource: "ExplosionSaucerSound")
        Haptic.shared.boomVibrate()
        mSaucerNode.isHidden = true
        
        mResetSaucerFlag = true // Move back to top later in the frame
    }

    // Collision Saucer & Missile
    func handleCollision_Spaceship_and_Missile() {
        MyLog.debug("Missile hit Spaceship")
        
        if mSaucerNode.isHidden == true { // Nothing to do
            return
        }
        
        theModel.mScore += 1
        processDestroidSaucer()
        mResetMissileFlag = true // move missile back to center of starbase later in the frame update
    }

    // Collision Saucer & Asteroid
    func handleCollision_Spaceship_and_Asteroid(theAsteroidNode: SKShapeNode) {
        MyLog.debug("Missile hit Asteroid")
        
        if mSaucerNode.isHidden == true { // Nothing to do
            return
        }
        
        processDestroidSaucer()
        
        // Process Asteroid
        processDestroidAsteroid(theAsteroidNode: theAsteroidNode)
        
        if theModel.mAsteroidsRemaining < 1 {
            // We beat the level so reset and start the next level
            initializeNextLevel()
        }

    }

    
}
