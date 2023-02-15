//
//  GameScene.swift
//  Guided Missile -
//    Name: Asteroid Pulverizer
//    SKU:  AsteroidKiller
//  Asteroid Pulverizer on AppStoreConnect: https://appstoreconnect.apple.com/apps/1667405578/appstore/ios/version/inflight
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
import StoreKit // SKStoreReviewController is in this Framework
import GameKit  // Needed for Leaderboard
//import GameplayKit


// vvvvvvvvvv  Adjusters  vvvvvvvvvvv
// These multipliers all start at 1.0 and can be change to adjust difficulty as the game moves along
var xThrust             = 1.0     // How powerful is the missile thrust
var xAsteroidSpeed      = 1.0     // How fast do the asteroids go
var xAsteroidSize       = 1.0     // How big are the asteroids - smaller number makes smaller asteroids
var xSaucerSpeedY       = 1.0     // How fast does the saucer come down the screen
var xSaucerSpeedX       = 1.0     // How fast does the saucer move across the screen left and right
var xSaucerTime         = 1.0     // How long do we wait between saucers
// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

// vvvvvvvvv  GAME CONSTANTS vvvvvvvvvv
let FOR_RELEASE                 = false  // Set to true to turn off debugging, turn on request a review and Real Ads
let REVIEW_THRESHOLD_LEVEL      = 12     // Don't ask for a review unless the user has made it to this level or higher.
let ADMOB_THRESHOLD_LEVEL       = 14     // Don't show ads unless the user has made it to this level before.
let INITIAL_SHIELD_LEVEL        = 2
let INCREMENTAL_LEVEL_CHANGE    = 0.02   // How much to change things each leve.  E.g. % faster, smaller etc.
let TOTAL_ASTEROID_LIMIT        = 12     // Never have more than this many total asteroids in the field
let MAX_SIMULTANIOUS_ASTEROIDS  = TOTAL_ASTEROID_LIMIT - 2 // Never have more than this many asteroids at the same time
let xScreenBuffer               = 5.0    // How far off the screen does an object need to be before appearing on the other side
let yScreenBuffer               = 5.0    // How far off the screen does an object need to be before appearing on the other side
let MIN_TIME_BETWEEN_SAUCERS    = 10.0   // Minimum time between saucers at start of game
let MIN_TIME_BETWEEN_ASTEROID_AND_SAUCER = 4.0 // Minimum time between when the last asteroid was destroid and when the saucer comes out
var SAUCER_SPEED                = 0.2    // Start Speed in Both X & Y Direction for Saucer - Bigger is faster
var SAUCER_X_SPEED              = 0.025  // Start Speed in X Direction for Saucer - Bigger is faster
var POINTS_SAUCER_HIT           = 1      // Number of points for destroying a Saucer
var POINTS_ASTEROID_HIT         = 0      // Number of points for destroying an Asteroid
var MIN_LEADERBOARD_BUTTON_LEVEL = 1     // Level where we start showing the leaderboard button
// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


struct GameModel {
    var mLevel                = 1 // game level - Should be 1
    var mAsteroidsRemaining   = 3 // 3 - Number of asteroids that still need to be destroied for the current level
    var mScore                = 0
    var mHighScore            = 0 // Highest score achieved to date
    var mHighLevel            = 0 // Highest Level achived to date - Used for determining ads and review requests
    var mShieldLevel          = INITIAL_SHIELD_LEVEL
    var mGameOver             = true // Start in Game Over mode
    var mFirstRun             = true // Display instructions if it's the first run.
        
    // Load game data from disk
    private let HIGH_SCORE_KEY = "HighScore"
    private let HIGH_LEVEL_KEY = "HighLevel"
    private let LEVEL_KEY      = "Level"
    mutating func load() {
        mHighScore = UserDefaults.standard.integer(forKey: HIGH_SCORE_KEY)
        mHighLevel = UserDefaults.standard.integer(forKey: HIGH_LEVEL_KEY)
        mLevel = UserDefaults.standard.integer(forKey:     LEVEL_KEY)
    }
    
    // Save game data to disk
    func save() {
        if mGameOver {return} // Don't save if this was triggered by things that happen after the game is over.
        UserDefaults.standard.set(mHighScore, forKey: HIGH_SCORE_KEY)
        UserDefaults.standard.set(mHighLevel, forKey: HIGH_LEVEL_KEY)
        UserDefaults.standard.set(mLevel, forKey:     LEVEL_KEY)
        
        // Update the Game Center with our new personal best score
        updateLeaderBoard()
    }
    
    //  Some Leaderboard Tutorial
    //    Use this example: https://medium.com/swlh/how-to-integrate-gamekit-ios-794061428197
    //    Use this Video Tutorial: https://www.google.com/search?q=game+center+leaderboard+swift+tutorial&newwindow=1&sxsrf=ALeKk01Bg1uOrX6PizEaPXXrfCtJHlbZBA:1600966767114&source=lnms&sa=X&ved=0ahUKEwisus37oYLsAhWYXM0KHV0kBV04ChD8BQgKKAA&biw=1688&bih=1236&dpr=2#kpvalbx=_gdBsX-TSAtaDtQaHtpDoBQ42
    //
    //   Another Leaderboard Example
    //     https://code.tutsplus.com/tutorials/game-center-and-leaderboards-for-your-ios-app--cms-27488
    //
    func updateLeaderBoard() {
        if GKLocalPlayer.local.isAuthenticated {
            let theScore = GKScore(leaderboardIdentifier: "Scores")
            theScore.value = Int64(mHighScore)
            let theScoreArray : [GKScore] = [theScore]
            GKScore.report(theScoreArray, withCompletionHandler: nil)
            MyLog.debug("GameData updateLeaderBoard() called with new level of \(mHighScore)")
        }
    }

    
    func totalAsteroids(level: Int) -> Int {
        switch level {
        case 1:
            return 3
        default:
            var total = level + 2
            if total > TOTAL_ASTEROID_LIMIT {total = TOTAL_ASTEROID_LIMIT}
            return total
        }
    }
    
    func maxAsteroidsInPlay(level: Int) -> Int {
        var inPlay = level
        if inPlay > MAX_SIMULTANIOUS_ASTEROIDS { inPlay = MAX_SIMULTANIOUS_ASTEROIDS }
        return inPlay
    }
    
    
    // You should set the level variable before calling this function
    // because some of the values may depend on the level.
    mutating func resetLevel() {
        mAsteroidsRemaining = totalAsteroids(level: mLevel) // Calculated Var that changes based on mLevel
        mShieldLevel = INITIAL_SHIELD_LEVEL
        
        // Update the Adjusters based on the level
        var increase = 1.0
        var decrease = 1.0
        for _ in 0..<mLevel {
            increase *= (1.0 + INCREMENTAL_LEVEL_CHANGE) // Increase by some small percentage each level
            decrease *= (1.0 - INCREMENTAL_LEVEL_CHANGE)
        }
        
        // These get multiplied by the original starting level 1 values.
        xThrust = increase
        xAsteroidSize = decrease
        xAsteroidSpeed = increase
        xSaucerSpeedY = increase
        xSaucerSpeedX = increase
        xSaucerTime = decrease // Delay between saucer appeareances
    }
    
    func getLevelBonus(level: Int) -> Int {
        if level <= 1 { return 0 }
        
        // Recursively calculate bonus
        let bonus = POINTS_ASTEROID_HIT*((level-1)+2) + getLevelBonus(level: level-1)
        return bonus
    }
    
    func playAgainButton1Level() -> Int { return 1} // What level should Button 1 take us to?
    func playAgainButton2Level() -> Int { return mLevel/2} // What level should button 2 take us to?
    func playAgainButton3Level() -> Int { return mLevel}
    
//    func playAgainButton1Bonus() -> Int { return getLevelBonus(level: 1) }  // What point bonus should be displayed for button 1
    func playAgainButton2Bonus() -> Int { return getLevelBonus(level: mLevel/2) } // What point bonus should be displayed for button 2
    func playAgainButton3Bonus() -> Int { return getLevelBonus(level: mLevel) }
    
}



class GameScene: SKScene, SKPhysicsContactDelegate, GKGameCenterControllerDelegate {
        
    var theModel = GameModel()
    private var mResetMissileFlag = false  // set to true to reset the missile at the starbase
    private var mGameVM = GameViewModel()
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
//        MyLog.debug("GameScene.init(size:) called")
        super.init(size: size)
        
        self.physicsWorld.contactDelegate = self // IMPORTANT - cant detect colisions without this
        
        if FOR_RELEASE == true {
            MyLog.disable() // Turn off debugging if this is a release version
        }
        
        theModel.load() // Load saved model data from disk
    }
    
    
    // SKScene has a 'required' initializer for an NSCoder parameter
    // Therefore we muast have one in case it ever gets called on the base class.
    required init?(coder aDecoder: NSCoder) {
        MyLog.debug("GameScene.init?(coder:) called")
        super.init(coder: aDecoder)
    }


    func requestReview() {
        if FOR_RELEASE == false { return } // Don't request a review if this is not a release version.
        
        if theModel.mLevel > REVIEW_THRESHOLD_LEVEL {
        // NOTE: If not connected to Internet, then requestReview will lock the interface
            let reachability = try? Reachability() // Return nil if throws an error
            if reachability?.connection == .wifi {
                SKStoreReviewController.requestReview()
            } else if reachability?.connection == .cellular {
                SKStoreReviewController.requestReview()
            }
        }
    }

    // Call this after we beat the current level and need to move on to the next level
    func initializeNextLevel() {
        theModel.save()  // Save max level reached.
        theModel.mLevel += 1 // move to next level
        theModel.resetLevel()

        stopSaucer() // reset the saucer for next deployment
        
        // Reset Saucer Count
        mSaucerCount = 0 // count number of saucers launced on this level
        
        // Reset Shields - the star base node should still be in tact since we beat the level
        mShieldNode.run(SKAction.fadeAlpha(to: 0.8, duration: 1))
        
        // Add starting number of Asteroids to Dictionary
        let maxX = self.frame.size.width
        for _ in 0..<theModel.maxAsteroidsInPlay(level: theModel.mLevel) {
            let asteroidNode = ShapeNodeBuilder.asteroidRandomNode()
            asteroidNode.position.y = 0
            asteroidNode.position.x = Double.random(in: 0.0...maxX)
            asteroidNode.physicsBody?.velocity.dy = xAsteroidSpeed * Double.random(in: -MAX_ASTEROID_VELOCITY...MAX_ASTEROID_VELOCITY)
            asteroidNode.physicsBody?.velocity.dx = xAsteroidSpeed * Double.random(in: -MAX_ASTEROID_VELOCITY...MAX_ASTEROID_VELOCITY)
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
        Sound.shared.play(forResource: "WarpSound4") // WarpSound4 and WarpSound3 are the best.
    }
    
    // MISSILE HITS ASTEROID - Call this when an asteroid and the missile collide
    // Pass in the Asteroid node.  Since there is only one missile node we don't need it passed in.
    func handleCollision_Asteroid_and_Missile(theAsteroidNode: SKShapeNode) {
//        MyLog.debug("Missile hit Asteroid")
        processDestroidAsteroid(theAsteroidNode: theAsteroidNode)
        theModel.mScore += POINTS_ASTEROID_HIT
        mResetMissileFlag = true // move missile back to center of starbase later in the frame update
        
        if theModel.mAsteroidsRemaining < 1 {
            // We beat the level so reset and start the next level
            initializeNextLevel()
        }

    }

    // ASTEROID hits STARBASE- Call this when an asteroid and the starbase collide
    // Pass in the Asteroid node.  Since there is only one starbase node we don't need it passed in.
    func handleCollision_Asteroid_and_Starbase(theAsteroidNode: SKShapeNode) {
//        MyLog.debug("Missile hit Starbase")
        
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.displayPlayAgainButtons()
            }

            theModel.save()
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
    

    // ASTEROID DESTROIED - Process the destroid asteroid by exploding it and adding a new
    // asteroid if necessary
    func processDestroidAsteroid(theAsteroidNode: SKShapeNode) {

        theModel.mAsteroidsRemaining -= 1
        mLastAsteroidTime = mCurrentTime // remember when the last asteroid was destroid
        
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
        if theModel.mAsteroidsRemaining >= theModel.maxAsteroidsInPlay(level: theModel.mLevel) {
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
        //    let gCategorySaucer:     UInt32 = 0x1 << 3  // 8
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
                handleCollision_Saucer_and_Missile()
            } else if secondBody.categoryBitMask == gCategorySupplyShip { // Missile hit supply ship
                handleCollision_SupplyShip_and_Missile()
            }
        
        // STARBASE - Check for Starbase Hit
        } else if firstBody.categoryBitMask == gCategoryStarbase {
            // Something Hit the Starbase
            if secondBody.categoryBitMask == gCategoryAsteroid {
                // Asteroid Hit the Starbase
                let theAsteroidNode = secondBody.node as! SKShapeNode
                handleCollision_Asteroid_and_Starbase(theAsteroidNode: theAsteroidNode)
            } else if secondBody.categoryBitMask == gCategorySaucer {
                // Saucer Hit the Starbase
                handleCollision_Saucer_and_Starbase()
            } else if secondBody.categoryBitMask == gCategorySupplyShip {
                handleCollision_Starbase_and_SupplyShip()
                MyLog.debug("Starbase - Supply Ship")
            }

        // SUPPLY SHIP - Check for Supply Ship Hit
        } else if firstBody.categoryBitMask == gCategorySupplyShip {
            // Something Hit the Supply Ship
            if secondBody.categoryBitMask == gCategoryAsteroid {
                // Asteroid Hit the supply ship
            } else if secondBody.categoryBitMask == gCategorySaucer {
                // Saucer Hit the Supply Ship
            }

        // SAUCER - Check for Enemy Ship Hit
        } else if firstBody.categoryBitMask == gCategorySaucer {
            // Something Hit the Enemy Ship
            if secondBody.categoryBitMask == gCategoryAsteroid {
                // Asteroid Hit the enemy ship
                let theAsteroidNode = secondBody.node as! SKShapeNode
                handleCollision_Saucer_and_Asteroid(theAsteroidNode: theAsteroidNode)
            }
        } else { // Some other collision that we don't need to handle like two asteroids hitting each other
            //MyLog.debug("Unknown \(firstBody.node?.name) - Unknown \(secondBody.node?.name) Collision")
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
    var mLeaderboardButton = SKShapeNode()
    var mPlayAgainButton1 = SKShapeNode()
    var mPlayAgainButton2 = SKShapeNode()
    var mPlayAgainButton3 = SKShapeNode()
    let mMissileNode = ShapeNodeBuilder.missileNode()
    let mSupplyShipNode = ShapeNodeBuilder.supplyShipNode()
    let (mStarbaseNode, mShieldNode) = ShapeNodeBuilder.starBaseNode() // Returns a tuple with the starbase node and the shield node
    let mSaucerNode = ShapeNodeBuilder.SaucerNode()
    var mAsteroidNodeDict = [String: SKShapeNode]() // Dictionary of Asteroids using the node name as key.
    var mCurrentTime : Double = 0                   // current Time in seconds
    override func didMove(to view: SKView) {
        setBackground(gameLevelNumber: 4) // Pass a different number for different backgrounds - Best: 4 (space4.jpg) with alpha of 0.5
//        MyLog.debug("GameScene.didMove() called")
        
        // Initialize Sound Player - Force singleton load by playing silent sound
        Sound.shared.play(forResource: "silent_sound")
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0) // Set gravity to 0
        
        
        mSupplyShipNode.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height - self.frame.size.height/3)
        self.addChild(mSupplyShipNode)
        if FOR_RELEASE { mSupplyShipNode.isHidden = true } // Don't display the supply ship in the release version

        mStarbaseNode.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2)
        self.addChild(mStarbaseNode)

        mMissileNode.position = mStarbaseNode.position
        self.addChild(mMissileNode)

        self.addChild(mSaucerNode)
        startSaucer()

        theModel.mScore = 0
        initializeNextLevel() // Add asteroids to the scene, increment level, reset shields, score etc.
        
        // Config display lines for debugging
        mLabel1.position = CGPoint(x: self.frame.width/2, y: 10)
        mLabel1.fontSize = CGFloat(12.0)
        self.addChild(mLabel1)
        mLabel2.position = CGPoint(x: self.frame.width/2, y: 23)
        mLabel2.fontSize = CGFloat(12.0)
        self.addChild(mLabel2)
        mLabel3.position = CGPoint(x: self.frame.width/2, y: 36)
        mLabel3.fontSize = CGFloat(12.0)
        self.addChild(mLabel3)

        displayInstructions()
        
        displayPlayAgainButtons()
        
        gamePausedInit()
    }
    
    func displayInstructions() {
        if theModel.mLevel > 1 {return} // only show instructions if this is level 1
        
        // Display instructions if this is the first run of the game.
        let line1Position = CGPoint(x: self.size.width/2, y: self.size.height * 0.81)
        let line2Position = CGPoint(x: self.size.width/2, y: self.size.height * 0.72) // 72 to low
        let line3Position = CGPoint(x: self.size.width/2, y: self.size.height * 0.66) // 62 too low

        let instructions1 = "Guide the missile by tilting your phone as if you were rolling a marble on the surface of your phone."
        let instructions2 = "Destroy all asteroids!"
        let instructions3 = ""

        Helper.fadingAlert(scene: self, position: line1Position, text: instructions1, fontSize: CGFloat(18), duration: 5)
        Helper.fadingAlert(scene: self, position: line2Position, text: instructions2, fontSize: CGFloat(18), duration: 5, delay: 5)
        Helper.fadingAlert(scene: self, position: line3Position, text: instructions3, fontSize: CGFloat(18), duration: 5, delay: 10)
    }
    
    // Remove and Add Play Again buttons with proper text for the current level
    func displayPlayAgainButtons() {
        requestReview() // Request a review if the criteria are met
        
        let leaderboardButtonPosition = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height*0.8)
        let buttonPosition1 = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height*0.4)
        let buttonPosition2 = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height*0.275)
        let buttonPosition3 = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height*0.15)

        // Remove from parent if necessary
        if mPlayAgainButton1.parent != nil { mPlayAgainButton1.removeFromParent() }
        if mPlayAgainButton2.parent != nil { mPlayAgainButton2.removeFromParent() }
        if mPlayAgainButton3.parent != nil { mPlayAgainButton3.removeFromParent() }
        
        
        // Play Again Buttons
        self.mPlayAgainButton1 = Helper.makeButton(position: buttonPosition1,
                                                   text: "Play", fontSize: CGFloat(50))
        self.addChild(self.mPlayAgainButton1)
        self.mPlayAgainButton1.isHidden = false // Show the button

        if theModel.mLevel > 4 { // Only show the other two buttons if the level is high enough
            self.mPlayAgainButton2 = Helper.makeButton(position: buttonPosition2,
                                                       text: "Resume Play\nAt Level \(theModel.mLevel/2)\nBonus: \(theModel.playAgainButton2Bonus())")
            self.addChild(self.mPlayAgainButton2)
            self.mPlayAgainButton2.isHidden = false // Show the button

            self.mPlayAgainButton3 = Helper.makeButton(position: buttonPosition3,
                                                       text: "Resume Play\nAt Level \(theModel.mLevel)\nBonus: \(theModel.playAgainButton3Bonus())")
            self.addChild(self.mPlayAgainButton3)
            self.mPlayAgainButton3.isHidden = false // Show the button
        }
        

        // Leaderboard Button
        if theModel.mLevel >= MIN_LEADERBOARD_BUTTON_LEVEL { // Only show the leaderboard button if they got to this level
            if mLeaderboardButton.parent != nil { mLeaderboardButton.removeFromParent() }
            self.mLeaderboardButton = Helper.makeButton(position: leaderboardButtonPosition, text: "Leaderboard", fontSize: 30)
            self.addChild(self.mLeaderboardButton)
            self.mLeaderboardButton.isHidden = false // show the button
        }

    }

    
    // Rest the game when the use clicks Play Again
    func resetGame(level: Int) {
        
        if theModel.mLevel > theModel.mHighLevel {
            theModel.mHighLevel = theModel.mLevel
        }
        
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
        displayInstructions() // Display instructions if at level 1

        // Reset the Starbase
        if mStarbaseNode.parent != nil {
            mStarbaseNode.removeFromParent()
        }
        self.addChild(mStarbaseNode)
        
        // Reset the Missile
        if mMissileNode.parent != nil {
            mMissileNode.removeFromParent()
        }
        self.addChild(mMissileNode)
        mMissileNode.position = mStarbaseNode.position
        mMissileNode.physicsBody?.velocity.dy = 0
        mMissileNode.physicsBody?.velocity.dx = 0

    }
    
    private func hidePlayAgainButtons() {
        mPlayAgainButton1.isHidden = true
        mPlayAgainButton2.isHidden = true
        mPlayAgainButton3.isHidden = true
        mLeaderboardButton.isHidden = true
    }
    
    func togglePause() {
        // NOTE: Must show the Game Paused message BEFORE Pausing
        if !realPaused {
            showGamePausedMessage()
        } else {
            hideGamePausedMessage()
        }

        // PAUSE / UNPAUSE Game
        realPaused = !realPaused
        if realPaused {
            Sound.shared.thrustSoundOff() // Stop thrust sound
            Sound.shared.saucerSoundOff()
        }
    }
    
    func touchDown(atPoint pos : CGPoint) {
        
        // Check Play Again Buttons
        if !mPlayAgainButton1.isHidden && mPlayAgainButton1.frame.contains(pos) {
            hidePlayAgainButtons()
            resetGame(level: theModel.playAgainButton1Level()) // Reset to level 1
            showInterstitialAdMobAd()
        } else if !mPlayAgainButton2.isHidden && mPlayAgainButton2.frame.contains(pos) {
            hidePlayAgainButtons()
            resetGame(level: theModel.playAgainButton2Level()) // Reset to mid level
            showInterstitialAdMobAd()
        } else if !mPlayAgainButton3.isHidden && mPlayAgainButton3.frame.contains(pos) {
            hidePlayAgainButtons()
            resetGame(level: theModel.playAgainButton3Level()) // Reset to highest level achieved
            showInterstitialAdMobAd()
        } else if !mLeaderboardButton.isHidden && mLeaderboardButton.frame.contains(pos) { // Leaderboard Button Tap
            handleLeaderboardButtonTap()
            
        // Check Pause / Unpause
        } else {
            togglePause()
        }

    }
    
    func touchMoved(toPoint pos : CGPoint) {
        //MyLog.debug("GameScene.touchMoved() called")
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
        mCurrentTime = currentTime // Keep track of the time
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
                mMissileNode.physicsBody!.velocity.dx += dx*xThrust // Add change to velocity
                mMissileNode.physicsBody!.velocity.dy += dy*xThrust

                
                // Show Exaust
                let pos = mMissileNode.position
                let exaustBall = SKShapeNode.init(circleOfRadius: 1)
                exaustBall.position = pos
                exaustBall.strokeColor = UIColor(red: 1.0, green: 0.3, blue: 0.0, alpha: 0.1)
                exaustBall.glowWidth = 5.0
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
        if mMissileNode.position.x > maxX + xScreenBuffer {
            mMissileNode.position.x = 0
        } else if mMissileNode.position.x < -xScreenBuffer {
            mMissileNode.position.x = maxX
        }

        // Move back on screen if out of bounds in X direction
        let maxY = self.frame.size.height
        if mMissileNode.position.y > maxY + yScreenBuffer {
            mMissileNode.position.y = 0
        } else if mMissileNode.position.y < -yScreenBuffer {
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
            if node.position.x > maxX + xScreenBuffer {
                node.position.x = 0
            } else if node.position.x < -xScreenBuffer {
                node.position.x = maxX
            }

            // Move back on screen if out of bounds in X direction
            if node.position.y > maxY + yScreenBuffer {
                node.position.y = 0
            } else if node.position.y < -yScreenBuffer {
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
    private var mResetSaucerFlag = true   // set to true to reset the saucer position after being destroid

    // Start the Enemy flying saucer
    
    var mLastSaucerTime     = 0.0   // When was the last Saucer destroid
    var mLastAsteroidTime   = 0.0   // When was the last asteroid destroid
    var mSaucerCount        = 0     // How many saucers have been launched this level
    func startSaucer() {
        
        // Has enough time elapsed since the previous saucer was destroied?
        if mLastSaucerTime == 0.0 { mLastSaucerTime = mCurrentTime }
        if mCurrentTime - mLastSaucerTime < MIN_TIME_BETWEEN_SAUCERS * xSaucerTime { return }
        
        // Has enough time elapsed since the previous asteroid was destroied?
        if mCurrentTime - mLastAsteroidTime < MIN_TIME_BETWEEN_ASTEROID_AND_SAUCER * xSaucerTime { return }

        //
        // === LAUNCH THE SAUCER ===
        //
        mSaucerCount += 1 // Track how many saucers have been launched on this level
        
        // Random Start Location X
        mRandomSaucerDegreeOffset = Double.random(in: 0.0...180.0) // Random degree offset to make saucer start at random X
        
        // Random Direciton (up or down) - positive is down
        mRandomSaucerDirection = Bool.random() ? 1.0 : -1.0
        
        mResetSaucerFlag = false // Don't reset it now that it's been started
        mSaucerNode.position.y = self.frame.size.height    // Top of screen
        mSaucerNode.position.x = self.frame.size.width/2  // Center of screen
        mSaucerNode.isHidden = false
        Sound.shared.saucerSoundOn()
    }
    
    func stopSaucer() {
        Sound.shared.saucerSoundOff()
        mSaucerNode.isHidden = true
        mResetSaucerFlag = true         // Move back to top later in the frame
        mLastSaucerTime = mCurrentTime  // Remember when the saucer was destroied
    }
    
    // Update the Saucer one frame
    var mRandomSaucerDegreeOffset = 0.0 // Random value to add to the Y offset when calculateing the X position
    var mRandomSaucerDirection = -1.0 // 1 or negative 1:  This is multiplied times the Y incrementor step size
    func updateSaucerFrame() {
        if mSaucerNode.isHidden {return} // Nothing to do
        
        // Speed up each consecutive saucer on a given level
        let speedX = xSaucerSpeedX * Double(mSaucerCount)
        let speedY = xSaucerSpeedY * Double(mSaucerCount)
        
        var posY = mSaucerNode.position.y
        posY -= SAUCER_SPEED * speedY * mRandomSaucerDirection  // How fast does it move down the screen?
        mSaucerNode.position.y = posY
        
        // Calc X postition
        let xInput = (posY+mRandomSaucerDegreeOffset) * SAUCER_X_SPEED  // Bigger is faster
        let xOffset = self.frame.size.width / 2 // Center the saucer on the screen
        let xPos = (xOffset * 0.9) * sin(speedX * xInput/speedY) + xOffset
        mSaucerNode.position.x = xPos
    }
    
    
    func correctSaucerPosition() {
        if mResetSaucerFlag { // reset the saucer back to it's starrting position
            startSaucer()
        }
        
        if mSaucerNode.isHidden { return } // Nothing to do
        
        var posY = mSaucerNode.position.y
        if posY < 0 - yScreenBuffer {   // Move back to Top of screen
            posY = self.frame.size.height
            mSaucerNode.position.y = posY
        } else if posY > self.frame.size.height + yScreenBuffer {
            posY = 0.0 // move back to the bottom of the screen
            mSaucerNode.position.y = posY
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
        Sound.shared.play(forResource: "ExplosionSaucerSound")
        Haptic.shared.boomVibrate()
        
        stopSaucer()
    }

    // Collision Saucer & Missile
    func handleCollision_Saucer_and_Missile() {
        if mSaucerNode.isHidden {return} // Nothing to do
        
        theModel.mScore += POINTS_SAUCER_HIT * mSaucerCount // More poits for faster saucers.
        
        Helper.fadingAlert(scene: self, position: mSaucerNode.position, text: "\(POINTS_SAUCER_HIT * mSaucerCount)pts", fontSize: 25, duration: 1, delay: 0)
        
        processDestroidSaucer()
        mResetMissileFlag = true // move missile back to center of starbase later in the frame update
    }

    // Collision Saucer & SupplyShip
    func handleCollision_SupplyShip_and_Missile() {
        //MyLog.debug("Missile Hit SupplyShip")
    }

    // Collision Starbase & SupplyShip
    func handleCollision_Starbase_and_SupplyShip() {
        //MyLog.debug("SupplyShip hit Starbase")
    }

    // Collision Saucer & Asteroid
    func handleCollision_Saucer_and_Asteroid(theAsteroidNode: SKShapeNode) {
        if mSaucerNode.isHidden {return} // Nothing to do
        
        processDestroidSaucer()
        
        // Process Asteroid
        processDestroidAsteroid(theAsteroidNode: theAsteroidNode)
        
        if theModel.mAsteroidsRemaining < 1 {
            // We beat the level so reset and start the next level
            initializeNextLevel()
        }
    }

    
    // SAUCER hits STARBASE- Call this when the saucer and the starbase collide
    func handleCollision_Saucer_and_Starbase() {
        if mSaucerNode.isHidden {return} // Nothing to do

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
            
            
            // REMOVE THE Starbase and the Saucer
            mStarbaseNode.removeFromParent()
            theModel.mGameOver = true
            
            // Wait 2 seconds for starbase explosion to finish then show Play Again buttons
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.displayPlayAgainButtons()
            }
            
            theModel.save() // save high score etc.
        }

        processDestroidSaucer()
    }

    
    //
    // MARK: Leaderboard Code
    //
    
    var LEADERBOARD_ID = "Scores" // What you provided in AppStoreConnect
    // Needed for Leaderboard and GKGameCenterControllerDelegate
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        MyLog.debug("GameScene gameCenterViewControllerDidFinish() called")
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
    
    // Call this when the user taps the "Leaderboard" button
    func handleLeaderboardButtonTap() {
        // If Authenticated, then show the leader board
        if GKLocalPlayer.local.isAuthenticated {
            if !self.realPaused {
                togglePause()
            }
            showLeaderBoard()
        } else {
            gameCenterAlertMessage() // Tell user they need Game Center to see the leaderboard
        }
    }
    
    // Dispaly an AdMob InterstitialAd
    func showInterstitialAdMobAd() {
        MyLog.debug("HighLevel: \(theModel.mHighLevel)")
        
        // Don't show ads unless the user has made it to the threshold level at some time in the past
        if theModel.mHighLevel < ADMOB_THRESHOLD_LEVEL {
            return
        }
        
        if gInterstitial != nil { // Check if an ad has been loaded
            let viewController = self.view!.window!.rootViewController
            if viewController != nil {
                // Pause Game if Necessary
                if !self.realPaused { togglePause() }
                
                // Show the AdMob Ad
                gInterstitial!.present(fromRootViewController: viewController!)
            } else {
                MyLog.debug("ERROR: AdMob - Unable to get rootViewController in showInterstitialAdMobAd() function")
            }
        } else {
            MyLog.debug("AdMob - Ad wasn't ready")
        }
    }
    
    func showLeaderBoard() { // wdh added
        let viewController = self.view!.window!.rootViewController
        let gcvc = GKGameCenterViewController()
        gcvc.gameCenterDelegate = self
        viewController?.present(gcvc, animated: true, completion: nil)
    }

    func gameCenterAlertMessage() {
        let messageTitle = "Apple Game Center Required"
        let messageBody = "To View Leaderboards, Restart the game and log into 'Game Center'"
        let dialogMessage = UIAlertController(title: messageTitle, message: messageBody, preferredStyle: .alert)

        let okButtonText = "OK"
        let ok = UIAlertAction(title: okButtonText, style: .default, handler: nil)
        dialogMessage.addAction(ok)

        // Present dialog message to user
        let rootViewController = self.view!.window!.rootViewController
        rootViewController!.present(dialogMessage, animated: true, completion: nil)
    }
    
    
    //
    // MARK: Game Paused Alert code
    //
    var mGamePausedAlertMainNode = SKLabelNode(fontNamed: GAME_FONT)
    var mGamePausedAlertSmallNode = SKLabelNode(fontNamed: GAME_FONT)
    
    func gamePausedInit() {
        let position = CGPoint(x: self.frame.width/2, y: self.frame.height*0.6)
        let color = UIColor(cgColor: CGColor(srgbRed: 1.0, green: 0.2, blue: 0.2, alpha: 1.0))
        
        mGamePausedAlertMainNode.fontSize = 30.0
        mGamePausedAlertMainNode.text = "Game Paused"
        mGamePausedAlertMainNode.isHidden = true // Start out hidden
        mGamePausedAlertMainNode.lineBreakMode = NSLineBreakMode.byWordWrapping
        mGamePausedAlertMainNode.numberOfLines = 0
        mGamePausedAlertMainNode.fontColor = color
        mGamePausedAlertMainNode.preferredMaxLayoutWidth = self.frame.size.width * 4/5
        mGamePausedAlertMainNode.position = position
        if mGamePausedAlertMainNode.parent == nil { // Just in case it somehow was already added
            self.addChild(mGamePausedAlertMainNode)
        }
        
        mGamePausedAlertSmallNode.fontSize = 15.0
        mGamePausedAlertSmallNode.text = "Tap Screen To Unpause"
        mGamePausedAlertSmallNode.isHidden = true // start out hidden
        mGamePausedAlertSmallNode.lineBreakMode = NSLineBreakMode.byWordWrapping
        mGamePausedAlertSmallNode.numberOfLines = 0
        mGamePausedAlertSmallNode.fontColor = color
        mGamePausedAlertSmallNode.preferredMaxLayoutWidth = self.frame.size.width * 4/5
        mGamePausedAlertSmallNode.position = position
        mGamePausedAlertSmallNode.position.y -= mGamePausedAlertSmallNode.frame.height
        if mGamePausedAlertSmallNode.parent == nil { // Just in case it somehow was already added
            self.addChild(mGamePausedAlertSmallNode)
        }
    }
    
    func showGamePausedMessage() {
        mGamePausedAlertMainNode.isHidden = false
        mGamePausedAlertSmallNode.isHidden = false
    }
    
    func hideGamePausedMessage() {
        mGamePausedAlertMainNode.isHidden = true
        mGamePausedAlertSmallNode.isHidden = true
    }


    
}
