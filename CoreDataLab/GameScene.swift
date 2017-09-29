//
//  GameScene.swift
//  Commotion
//
//  Created by Eric Larson on 9/6/16.
//  Copyright © 2016 Eric Larson. All rights reserved.
//

import UIKit
import SpriteKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let BallCategory : UInt32 = 0x1 << 0
    let BottomCategory : UInt32 = 0x1 << 1
    let BarCategory : UInt32 = 0x1 << 2
    var ballCount = 0
    var x = 0.0
    let barName = "bar"
    let ballName = "ball"
    let defaults = UserDefaults.standard
    
    // MARK: Raw Motion Functions
    let motion = CMMotionManager()
    func startMotionUpdates(){
        if self.motion.isDeviceMotionAvailable{
            self.motion.deviceMotionUpdateInterval = 0.1
            self.motion.startDeviceMotionUpdates(to: OperationQueue.main, withHandler: self.handleMotion )
        }
    }
    
    func handleMotion(_ motionData:CMDeviceMotion?, error:Error?){
        if let gravity = motionData?.gravity {
            self.x = gravity.x
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }
        else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if firstBody.categoryBitMask == BallCategory && secondBody.categoryBitMask == BottomCategory {
            print ("Hit Bottom! Lost a life!")
            while let spriteBall = self.childNode(withName: ballName){
                spriteBall.removeFromParent()
            }
            ballCount = 0
        }
        else if firstBody.categoryBitMask == BarCategory && secondBody.categoryBitMask == BottomCategory {
            let bar2 = self.childNode(withName: barName)
            bar2?.position.y = size.height * 0.1
        }
    }
    
    // MARK: View Hierarchy Functions
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        backgroundColor = SKColor.white
        self.backgroundColor = SKColor.cyan
        
        // start motion for gravity
        self.startMotionUpdates()

        self.motion.startAccelerometerUpdates()
        self.motion.deviceMotionUpdateInterval = 0.1
        
        // make sides to the screen
        self.addSidesAndTop()
        // make the bar
        self.addBarAtPoint(CGPoint(x: size.width * 0.5, y: size.height * 0.01))
    }
    
    func processBarMotion(forUpdate currentTime: CFTimeInterval) {
        if let bar2 = childNode(withName: barName) as? SKSpriteNode {
            if let data = motion.accelerometerData {
                if fabs(data.acceleration.x) > 0.1 {
                    let xForce = (200 * CGFloat(data.acceleration.x)) //CGFloat(ballCount*25)+
                    bar2.physicsBody!.applyForce(CGVector(dx: xForce, dy: 0))
                }
            }
        }
    }
    
    // MARK: Create Sprites Functions
    func addSprite(){
        
        let sprite = SKSpriteNode()
        let colorChoice = defaults.string(forKey: "Color")
        if colorChoice == "Green" {
            sprite.color = UIColor.green
        }
        else if colorChoice == "Yellow" {
            sprite.color = UIColor.yellow
        }
        else {
            sprite.color = UIColor.red
        }
        
        sprite.size = CGSize(width: 25.0, height: 25.0)
        sprite.position = CGPoint(x: size.width * random(min: CGFloat(0.25), max: CGFloat(0.75)), y: size.height * 0.75)
        sprite.physicsBody = SKPhysicsBody(circleOfRadius: sprite.size.width / 2.0)
        sprite.physicsBody?.isDynamic = true
        sprite.physicsBody?.allowsRotation = false
        sprite.physicsBody?.mass = 0.01
        sprite.physicsBody?.restitution = 0.0
        sprite.physicsBody!.categoryBitMask = BallCategory
        sprite.physicsBody!.contactTestBitMask = BottomCategory
        sprite.physicsBody?.friction = 1.0
        sprite.name = ballName
        ballCount += 1
        self.addChild(sprite)
    }
    
    func addBarAtPoint(_ point:CGPoint){
        let bar = SKSpriteNode()
        bar.color = UIColor.black
        bar.size = CGSize(width:size.width*0.3,height:size.height * 0.025)
        bar.position = point
        
        bar.physicsBody = SKPhysicsBody(rectangleOf:bar.size)
        bar.physicsBody?.isDynamic = true
        bar.physicsBody?.affectedByGravity = false
        bar.physicsBody?.allowsRotation = false
        bar.name = barName
        bar.physicsBody!.categoryBitMask = BarCategory
        bar.physicsBody?.friction = 1.0
        self.addChild(bar)
        
    }

    func addSidesAndTop(){
        let left = SKSpriteNode()
        let right = SKSpriteNode()
        let bot = SKSpriteNode()
        
        left.size = CGSize(width:size.width*0.1,height:size.height)
        left.position = CGPoint(x:0, y:size.height*0.5)
        
        right.size = CGSize(width:size.width*0.1,height:size.height)
        right.position = CGPoint(x:size.width, y:size.height*0.5)
        
        let bottom = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: 1)
        bot.physicsBody = SKPhysicsBody(edgeLoopFrom: bottom)
        bot.physicsBody!.categoryBitMask = BottomCategory
        addChild(bot)

        for obj in [left,right]{
            obj.color = UIColor.magenta
            obj.physicsBody = SKPhysicsBody(rectangleOf:obj.size)
            obj.physicsBody?.isDynamic = true
            obj.physicsBody?.pinned = true
            obj.physicsBody?.allowsRotation = false
            self.addChild(obj)
        }
    }
    
    // MARK: UI Delegate Functions
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
            print(touches.first!.location(in: self).x)
            self.addSprite()
    }
    
    // MARK: Utility Functions (thanks ray wenderlich!)
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    override func update(_ currentTime: CFTimeInterval){
        processBarMotion(forUpdate: currentTime)
    }
}

