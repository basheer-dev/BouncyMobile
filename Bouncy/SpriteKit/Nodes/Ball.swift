//
//  Ball.swift
//  Bouncy
//
//  Created by Basheer Abdulmalik on 29/07/2024.
//

import SpriteKit

final class Ball: SKNode {
    
    var primaryShadows = [SKShapeNode]()
    var secondaryShadows = [SKShapeNode]()
    
    let size: CGSize
    let radius: CGFloat
    
    var movement = CGVector(dx: 5, dy: 5)
    let defaultMovement = CGVector(dx: 5, dy: 5)
    let movementIncreaseRate: CGFloat = 4
    
    let ballPrimaryColor = UIColor.gameLightBlue
    let ballSecondaryColor = UIColor.white
    let fastBallPrimaryColor = UIColor.red
    let fastBallSecondaryColor = UIColor.white
    
    var isBallMovingMad = false {
        didSet {
            for shadow in primaryShadows {
                shadow.fillColor = isBallMovingMad ? fastBallPrimaryColor : ballPrimaryColor
            }
            
            for shadow in secondaryShadows {
                shadow.fillColor = isBallMovingMad ? fastBallSecondaryColor : ballSecondaryColor
            }
        }
    }
    
    // MARK: - INIT
    init(size: CGSize) {
        self.size = size
        self.radius = size.width / 2
        super.init()
        
        zPosition = ZPosition.ball.rawValue
        
        setPhysicsBody()
        drawHeadNode()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - DESIGN
    private func setPhysicsBody() {
        physicsBody = SKPhysicsBody(circleOfRadius: radius)
        physicsBody?.categoryBitMask = CollisionCategory.ball.rawValue
        physicsBody?.contactTestBitMask = physicsBody?.collisionBitMask ?? 0
        physicsBody?.isDynamic = true
        physicsBody?.linearDamping = 0
        physicsBody?.affectedByGravity = false
    }
    
    private func drawHeadNode() {
        let shape = SKShapeNode(circleOfRadius: radius)
        shape.zPosition = ZPosition.ball.rawValue
        shape.fillColor = ballPrimaryColor
        shape.lineWidth = 0
        shape.position = .zero
        
        let secondaryShape = SKShapeNode(circleOfRadius: radius / 2)
        secondaryShape.zPosition = ZPosition.ballEffect.rawValue
        secondaryShape.fillColor = ballSecondaryColor
        secondaryShape.lineWidth = 0
        secondaryShape.position = .zero
        
        primaryShadows.append(shape)
        secondaryShadows.append(secondaryShape)
        
        shape.addChild(secondaryShape)
        addChild(shape)
    }
    
    private func drawTailNode() {
        // Creating a tail ball node:
        let tailBall = SKShapeNode(circleOfRadius: radius)
        tailBall.zPosition = ZPosition.ball.rawValue
        tailBall.fillColor = ballPrimaryColor
        tailBall.lineWidth = 0
        tailBall.position = position
        
        let tailSecondaryBall = SKShapeNode(circleOfRadius: radius / 2)
        tailSecondaryBall.zPosition = ZPosition.ballEffect.rawValue
        tailSecondaryBall.fillColor = ballSecondaryColor
        tailSecondaryBall.lineWidth = 0
        tailSecondaryBall.position = .zero
        
        tailBall.addChild(tailSecondaryBall)
        
        // Creating a tail line node:
        let tailLineStartingPoint = position
        let tailLineEndingPoint = CGPoint(x: position.x + movement.dx, y: position.y + movement.dy)
        
        let deltaY = tailLineStartingPoint.y - tailLineEndingPoint.y
        let deltaX = tailLineStartingPoint.x - tailLineEndingPoint.x
        let distance = sqrt(pow(deltaX, 2) + pow(deltaY, 2))
        let angle = atan2(deltaY, deltaX)
        
        let tailLine = SKShapeNode(rectOf: CGSize(width: distance, height: radius * 2))
        tailLine.zPosition = ZPosition.ball.rawValue
        tailLine.lineWidth = 0
        tailLine.fillColor = ballPrimaryColor
        tailLine.zRotation = angle
        tailLine.position = CGPoint(x: (tailLineStartingPoint.x + tailLineEndingPoint.x) / 2, y: (tailLineStartingPoint.y + tailLineEndingPoint.y) / 2)
        
        let tailSecondaryLine = SKShapeNode(rectOf: CGSize(width: distance, height: radius))
        tailSecondaryLine.zPosition = ZPosition.ballEffect.rawValue
        tailSecondaryLine.lineWidth = 0
        tailSecondaryLine.fillColor = ballSecondaryColor
        tailSecondaryLine.position = .zero
        
        tailLine.addChild(tailSecondaryLine)
        
        primaryShadows.append(tailBall)
        primaryShadows.append(tailLine)
        secondaryShadows.append(tailSecondaryBall)
        secondaryShadows.append(tailSecondaryLine)
        
        // Scaling the tail nodes down to make a disappearing tail effect:
        let shrinkBall = SKAction.scale(by: 0, duration: 0.5)
        let shrinkLine = SKAction.scaleY(to: 0, duration: 0.5)
        shrinkBall.timingMode = .linear
        shrinkLine.timingMode = .linear
        
        tailBall.run(shrinkBall) {
            tailBall.removeFromParent()
            self.primaryShadows.removeAll { $0 == tailBall }
            self.secondaryShadows.removeAll { $0 == tailSecondaryBall }
        }
        
        tailLine.run(shrinkLine) {
            tailLine.removeFromParent()
            self.primaryShadows.removeAll { $0 == tailLine }
            self.secondaryShadows.removeAll { $0 == tailSecondaryLine }
        }
        
        // Displaying the tail nodes:
        scene?.addChild(tailLine)
        scene?.addChild(tailBall)
    }
    
    // MARK: - UPDATE
    func update() {
        drawTailNode()
        
        // Updating the ball color:
        if abs(movement.dy) > defaultMovement.dy || abs(movement.dx) > defaultMovement.dx {
            isBallMovingMad = true
        } else {
            isBallMovingMad = false
        }
        
        // Updating the ball's position:
        position.x += movement.dx
        position.y += movement.dy
    }
}
