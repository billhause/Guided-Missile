//
//  ShapeNodeBuilder.swift
//  Guided Missile
//
//  Created by William Hause on 12/12/22.
//

import Foundation
import SpriteKit

struct ShapeNodeBilder {
    static func gunSightNode() -> SKShapeNode {
        let shapeNode = SKShapeNode(circleOfRadius: 20)
        shapeNode.name = "Gunsite"
        shapeNode.lineWidth = 3
        shapeNode.strokeColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
        return shapeNode
    }
    static func roundedRectNode() -> SKShapeNode {
        let shape = SKShapeNode()
        shape.path = UIBezierPath(roundedRect: CGRect(x: -13, y: -13, width: 26, height: 26), cornerRadius: 6).cgPath
        shape.fillColor = UIColor.blue
        shape.strokeColor = UIColor.red
        shape.lineWidth = 3
        return shape
    }
    static func shapesTestNode() -> SKShapeNode {
        let path = UIBezierPath()
        path.move(to: .zero) // Lower Left corner - X & Y to up and right in positive direction
        path.addLine(to: CGPoint(x: 50, y: 50))
        path.addLine(to: CGPoint(x: 50, y: 150))
        path.addLine(to: CGPoint(x: 150, y: 50))
        path.close() // final line back to start

        // Triangle off to the side
        path.move(to: CGPoint(x:-50, y:-50))
        path.addLine(to: CGPoint(x:-70, y:-50))
        path.addLine(to: CGPoint(x:-50, y:-70))
        path.close()

        // Add a child shape to this shape with a different stroke and texture
        // circle with Dog Texture - Note texture does not rotate with the shape
        let childPath = UIBezierPath()
        childPath.move(to: CGPoint(x:-50, y:50))
        childPath.addArc(withCenter: CGPoint(x:-(50+30), y:50), radius: 30, startAngle: 0.0, endAngle: 2*Double.pi, clockwise: true)
        childPath.close()
        let childShape = SKShapeNode()
        childShape.fillColor = UIColor.yellow
        childShape.strokeColor = UIColor.green
        childShape.lineWidth = 3.0
        childShape.path = childPath.cgPath
        if let theUIImage = UIImage(named: "Dog Cairn") {
            childShape.fillTexture = SKTexture(image: theUIImage)
        }

        let shape = SKShapeNode()
        shape.path = path.cgPath
        shape.strokeColor = UIColor.red
        shape.fillColor = UIColor.blue
        shape.glowWidth = 7.0
        shape.addChild(childShape)
        
        // Make it spin
        shape.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 10)))

        return shape
    }
    
    
    // vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
    // vvvvvvvvv     Star Base      vvvvvvvvvvv
    // vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
    private static func starBaseCircleNode(name: String, posX: Double, posY: Double, radius: Double) -> SKShapeNode {
        let shape = SKShapeNode(circleOfRadius: radius)
//        let shape = SKShapeNode(rectOf: CGSize(width:radius, height: radius*2))
        shape.name = name
        shape.lineWidth = 2
        shape.strokeColor = UIColor(red: 0.0, green: 0.8, blue: 0.8, alpha: 1.0)
        shape.fillColor = UIColor(red: 0.2, green: 0.3, blue: 0.2, alpha: 1.0)
        shape.position.x = posX
        shape.position.y = posY
        
        let light = SKShapeNode(circleOfRadius: 1.0)
        light.fillColor = UIColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 1.0)
        
        shape.addChild(light)
        return shape
    }
    
    static func starBaseNode() -> SKShapeNode {
        let scale = 1.0 // adjust the size of the starbase here.
        let delta = 18.0
        let smallRad = 10.0
        let largeRad = 17.0

        let shape = starBaseCircleNode(name: "mainCircle", posX: 0, posY: 0, radius: largeRad)
        
        // Add Starbase Circles
        let circle1 = starBaseCircleNode(name: "circle1", posX:  delta, posY:  delta, radius: smallRad)
        let circle2 = starBaseCircleNode(name: "circle2", posX: -delta, posY:  delta, radius: smallRad)
        let circle3 = starBaseCircleNode(name: "circle3", posX:  delta, posY: -delta, radius: smallRad)
        let circle4 = starBaseCircleNode(name: "circle4", posX: -delta, posY: -delta, radius: smallRad)
        circle1.zPosition = -1.0 // Put behind main circle
        circle2.zPosition = -1.0 // Put behind main circle
        circle3.zPosition = -1.0 // Put behind main circle
        circle4.zPosition = -1.0 // Put behind main circle
        shape.addChild(circle1)
        shape.addChild(circle2)
        shape.addChild(circle3)
        shape.addChild(circle4)
        
        let band = SKShapeNode(circleOfRadius: 27)
        band.strokeColor = UIColor(red: 0.0, green: 0.5, blue: 0.5, alpha: 1.0)
        band.fillColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0) // Transparent fill color
        band.lineWidth = 5
        band.zPosition = -2.0
        shape.addChild(band)
        
        shape.setScale(scale)
        
        // Must have a parent node so that it's scale can be changed independant of it's child node's scales
        let parentNode = SKShapeNode()
        parentNode.addChild(shape)
        
        // Make it spin
        parentNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 20)))

        return parentNode
    }
    // ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

    
    // vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
    // vvvvvvvvv     Missile      vvvvvvvvvvv
    // vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
    static func missileNode() -> SKShapeNode {
        let scale = 0.4 // Change this to change the size of the missile
        
        // Cyan Rocket
//        let noseConeColor   = UIColor(red: 0.0, green: 0.5, blue: 0.6, alpha: 1.0)
//        let fuselageColor   = UIColor(red: 0.0, green: 0.4, blue: 0.5, alpha: 1.0)
//        let finColor        = UIColor(red: 0.0, green: 0.5, blue: 0.6, alpha: 1.0)

        // Brown Rocket
        let noseConeColor   = UIColor(red: 0.6, green: 0.5, blue: 0.0, alpha: 1.0)
        let fuselageColor   = UIColor(red: 0.5, green: 0.4, blue: 0.0, alpha: 1.0)
        let finColor        = UIColor(red: 0.6, green: 0.5, blue: 0.0, alpha: 1.0)

        
        let exaustColor     = UIColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 1.0)
        let shape = SKShapeNode()

        // Nose Cone
        let noseConeBez = UIBezierPath()
        noseConeBez.move(to: CGPoint(x:0, y:25)) // Peak
        noseConeBez.addLine(to: CGPoint(x: -5, y:15))
        noseConeBez.addLine(to: CGPoint(x: 5, y:15))
        noseConeBez.close()
        let noseCone = SKShapeNode()
        noseCone.path = noseConeBez.cgPath
        noseCone.strokeColor = noseConeColor
        noseCone.fillColor = noseConeColor
        shape.addChild(noseCone)
        
        // Fuselage
        let fuselageBez = UIBezierPath()
        fuselageBez.move(to: CGPoint(x:5, y:15)) // Peak
        fuselageBez.addLine(to: CGPoint(x: -5,  y:  15))
        fuselageBez.addLine(to: CGPoint(x: -5,  y:  -10))
        fuselageBez.addLine(to: CGPoint(x:  5,  y:  -10))
        fuselageBez.close()
        let bodyNode = SKShapeNode()
        bodyNode.path = fuselageBez.cgPath
        bodyNode.strokeColor = fuselageColor
        bodyNode.fillColor = fuselageColor
        shape.addChild(bodyNode)
        
        
        // TailFin1
        let finBez1 = UIBezierPath()
        finBez1.move(to:    CGPoint(x:   5, y:5)) // Peak
        finBez1.addLine(to: CGPoint(x:  15,  y:  -5))
        finBez1.addLine(to: CGPoint(x:  15,  y: -10))
        finBez1.addLine(to: CGPoint(x:   5,  y: -10))
        finBez1.close()
        let finNode1 = SKShapeNode()
        finNode1.path = finBez1.cgPath
        finNode1.strokeColor = finColor
        finNode1.fillColor = finColor
        finNode1.zPosition = -1.0 // Put behind fuselage
        shape.addChild(finNode1)

        // TailFin2
        let finBez2 = UIBezierPath()
        finBez2.move(to:    CGPoint(x:   -5, y:5)) // Peak
        finBez2.addLine(to: CGPoint(x:  -15,  y:  -5))
        finBez2.addLine(to: CGPoint(x:  -15,  y: -10))
        finBez2.addLine(to: CGPoint(x:   -5,  y: -10))
        finBez2.close()
        let finNode2 = SKShapeNode()
        finNode2.path = finBez2.cgPath
        finNode2.strokeColor = finColor
        finNode2.fillColor = finColor
        finNode2.zPosition = -1.0 // Put behind fuselage
        shape.addChild(finNode2)

        // Exaust Port
        let bez = UIBezierPath()
        bez.move(to:    CGPoint(x:   2,  y: -11)) // Peak
        bez.addLine(to: CGPoint(x:  -2,  y: -11))
        bez.addLine(to: CGPoint(x:  -2,  y: -11))
        bez.addLine(to: CGPoint(x:  -2,  y: -12))
        bez.addLine(to: CGPoint(x:   2,  y: -12))
        bez.close()
        let exaust = SKShapeNode()
        exaust.path = bez.cgPath
        exaust.strokeColor = exaustColor
        exaust.fillColor = exaustColor
        exaust.glowWidth = 2.0
        shape.addChild(exaust)
        
        // Set Scale for entire Missile
        shape.setScale(scale)
        
        // Must have a parent node so that it's scale can be changed independant of it's child node's scales
        let parentNode = SKShapeNode()
        parentNode.addChild(shape)

        return parentNode
    }
    
    // ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

    
    // vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
    // vvvvvvvvv     Asteroid 1     vvvvvvvvvvv
    // vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
    static func asteroidNode1() -> SKShapeNode {
        let scale = 3.0 // Change this to change the size of the asteroid
        
        let asteroidColor   = UIColor(red: 0.6, green: 0.5, blue: 0.6, alpha: 1.0)
        
        // Asteroid
        let asteroidBez = UIBezierPath()
        asteroidBez.move(to:       CGPoint(x:  5, y: 0)) // 1
        asteroidBez.addLine(to:    CGPoint(x:  3, y: 1)) // 2
        asteroidBez.addLine(to:    CGPoint(x:  4, y: 4)) // 3
        asteroidBez.addLine(to:    CGPoint(x:  0, y: 5)) // 4
        asteroidBez.addLine(to:    CGPoint(x: -1, y: 3)) // 5
        asteroidBez.addLine(to:    CGPoint(x: -3, y: 3)) // 6
        asteroidBez.addLine(to:    CGPoint(x: -5, y: 0)) // 7
        asteroidBez.addLine(to:    CGPoint(x: -4, y:-2)) // 8
        asteroidBez.addLine(to:    CGPoint(x: -4, y:-4)) // 9
        asteroidBez.addLine(to:    CGPoint(x:  0, y:-5)) // 10
        asteroidBez.addLine(to:    CGPoint(x:  2, y:-3)) // 11
        asteroidBez.addLine(to:    CGPoint(x:  4, y:-4)) // 11
        asteroidBez.close()
        let shape = SKShapeNode()
        shape.path = asteroidBez.cgPath
        shape.strokeColor = asteroidColor
        shape.fillColor = asteroidColor

        // Set Scale for entire asteroid
        shape.setScale(scale)
        
        // Must have a parent node so that it's scale can be changed independant of it's child node's scales
        let parentNode = SKShapeNode()
        parentNode.addChild(shape)
        
        // Make it spin
        parentNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 10)))

        return parentNode
    }
    // ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    
    
    // vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
    // vvvvvvvvv   Asteroid Random  vvvvvvvvvvv
    // vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
    static func asteroidRandomNode() -> SKShapeNode {
        let scale = 3.0 // Change this to change the size of the asteroid
        
        let redRand   = 0.5 + Double.random(in: -0.1...0.1)
        let greenRand = 0.5 + Double.random(in: -0.1...0.1)
        let blueRand =  0.5 + Double.random(in: -0.1...0.1)

        let asteroidColor   = UIColor(red: redRand, green: greenRand, blue: blueRand, alpha: 1.0)
        
        
        // How random jaggedness for the asteroid shape
        let min = -1.5
        let max =  1.5
        
        // Asteroid
        let asteroidBez = UIBezierPath()
        asteroidBez.move(to:       CGPoint(x:  5, y: 0)) // 1
        var rnd1 = Double.random(in: 0...2)
        var rnd2 = Double.random(in: 0...2)
        asteroidBez.addLine(to:    CGPoint(x:  4-rnd1, y: 2-rnd2)) // 2
        rnd1 = Double.random(in: min...max)
        rnd2 = Double.random(in: min...max)
        asteroidBez.addLine(to:    CGPoint(x:  2-rnd1, y: 4-rnd2)) // 3
        rnd1 = Double.random(in: min...max)
        rnd2 = Double.random(in: min...max)
        asteroidBez.addLine(to:    CGPoint(x:  0,      y: 5-rnd2)) // 4
        rnd1 = Double.random(in: min...max)
        rnd2 = Double.random(in: min...max)
        asteroidBez.addLine(to:    CGPoint(x: -2+rnd1, y: 4-rnd2)) // 5
        rnd1 = Double.random(in: min...max)
        rnd2 = Double.random(in: min...max)
        asteroidBez.addLine(to:    CGPoint(x: -4+rnd1, y: 2-rnd2)) // 6
        rnd1 = Double.random(in: min...max)
        rnd2 = Double.random(in: min...max)
        asteroidBez.addLine(to:    CGPoint(x: -5+rnd1, y: 0)) // 7
        rnd1 = Double.random(in: min...max)
        rnd2 = Double.random(in: min...max)
        asteroidBez.addLine(to:    CGPoint(x: -4+rnd1, y:-2+rnd2)) // 8
        rnd1 = Double.random(in: min...max)
        rnd2 = Double.random(in: min...max)
        asteroidBez.addLine(to:    CGPoint(x: -2+rnd1, y:-4+rnd2)) // 9
        rnd1 = Double.random(in: min...max)
        rnd2 = Double.random(in: min...max)
        asteroidBez.addLine(to:    CGPoint(x:  0, y:-5+rnd2)) // 10
        rnd1 = Double.random(in: min...max)
        rnd2 = Double.random(in: min...max)
        asteroidBez.addLine(to:    CGPoint(x:  2-rnd1, y:-4+rnd2)) // 11
        rnd1 = Double.random(in: min...max)
        rnd2 = Double.random(in: min...max)
        asteroidBez.addLine(to:    CGPoint(x:  4-rnd1, y:-2+rnd2)) // 11
        asteroidBez.close()
        let shape = SKShapeNode()
        shape.path = asteroidBez.cgPath
        shape.strokeColor = asteroidColor
        shape.fillColor = asteroidColor

        // Set Scale for entire asteroid
        shape.setScale(scale)
        
        // Must have a parent node so that it's scale can be changed independant of it's child node's scales
        let parentNode = SKShapeNode()
        parentNode.addChild(shape)

        // Make it spin
        let spinDuration = Double.random(in: 1...10)
        let direction = Bool.random() // Clockwise or counter clockwise
        parentNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: direction ? CGFloat(Double.pi) : -CGFloat(Double.pi), duration: spinDuration)))

        
        return parentNode
    }
    // ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

    
    // vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
    // vvvvvvvvv     SpaceShip      vvvvvvvvvvv
    // vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
    static func spaceShipNode() -> SKShapeNode {
        let scale = 1.0 // Change this to change the size of the object
        
        // Cyan Theme
//        let domeStrokeColor      = UIColor(red: 0.8, green: 0.8, blue: 0.0, alpha: 1.0)
//        let domeFillColor      = UIColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 0.4)
//        let upperBodyColor = UIColor(red: 0.0, green: 0.5, blue: 0.6, alpha: 1.0)
//        let lowerBodyColor = UIColor(red: 0.0, green: 0.4, blue: 0.5, alpha: 1.0)
        
        // Red Theme
        let domeStrokeColor = UIColor(red: 0.8, green: 0.8, blue: 0.0, alpha: 1.0)
        let domeFillColor   = UIColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 0.4)
        let upperBodyColor  = UIColor(red: 0.7, green: 0.3, blue: 0.3, alpha: 1.0)
        let lowerBodyColor  = UIColor(red: 0.6, green: 0.2, blue: 0.2, alpha: 1.0)

        // Ship Upper Body
        let upperBodyBez = UIBezierPath()
        upperBodyBez.move(to:    CGPoint(x:   5, y: 5)) // 1
        upperBodyBez.addLine(to: CGPoint(x:  -5, y: 5)) // 2
        upperBodyBez.addLine(to: CGPoint(x: -15, y: 0)) // 3
        upperBodyBez.addLine(to: CGPoint(x:  15, y: 0)) // 4
        upperBodyBez.close()
        let upperBody = SKShapeNode()
        upperBody.path = upperBodyBez.cgPath
        upperBody.strokeColor = upperBodyColor
        upperBody.fillColor = upperBodyColor

        let shape = SKShapeNode()
        shape.addChild(upperBody)
        
        // Ship Lower Body
        let lowerBodyBez = UIBezierPath()
        lowerBodyBez.move(to:    CGPoint(x:  15, y: 0)) // 1
        lowerBodyBez.addLine(to: CGPoint(x: -15, y: 0)) // 2
        lowerBodyBez.addLine(to: CGPoint(x: -10, y: -2.5)) // 3
        lowerBodyBez.addLine(to: CGPoint(x:  10, y: -2.5)) // 4
        lowerBodyBez.close()
        let lowerBody = SKShapeNode()
        lowerBody.path = lowerBodyBez.cgPath
        lowerBody.strokeColor = lowerBodyColor
        lowerBody.fillColor = lowerBodyColor

        shape.addChild(lowerBody)

        // Dome
        let domeBez = UIBezierPath()
        domeBez.addArc(withCenter: CGPoint(x: 0, y: 5), radius: 4, startAngle: 0.0, endAngle: Double.pi, clockwise: true)
        let dome = SKShapeNode()
        dome.path = domeBez.cgPath
        dome.strokeColor = domeStrokeColor
        dome.glowWidth = 1.0
        dome.fillColor = domeFillColor

        shape.addChild(dome)

        // Landing Gear Legs
        let legsBez = UIBezierPath()
        legsBez.move(to:    CGPoint(x:  -3, y:  -2.5))
        legsBez.addLine(to: CGPoint(x:  -8, y: -7))
        legsBez.move(to:    CGPoint(x:   3, y:  -2.5))
        legsBez.addLine(to: CGPoint(x:   8, y: -7))
        legsBez.move(to:    CGPoint(x:   0, y:  -2.5))
        legsBez.addLine(to: CGPoint(x:   0, y: -7))

        let legs = SKShapeNode()
        legs.path = legsBez.cgPath
        legs.lineWidth = 2
        legs.strokeColor = lowerBodyColor

        shape.addChild(legs)


        // Set Scale for entire object
        shape.setScale(scale)
        
        // Must have a parent node so that it's scale can be changed independant of it's child node's scales
        let parentNode = SKShapeNode()
        parentNode.addChild(shape)
        
        return parentNode
    }
    // ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

    
    static func testNode() -> SKShapeNode {
//        let shape = fullStarBaseNode()
//        let shape = missileNode()
//        let shape = asteroidNode1()
        let shape = spaceShipNode()
        return shape
    }
}
