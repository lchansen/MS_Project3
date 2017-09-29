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
    
    var x = 0.0
    let barName = "bar"
    let ballName = "ball"
    let bar = SKSpriteNode()
    let ball = SKSpriteNode()
    
    // MARK: Raw Motion Functions
    let motion = CMMotionManager()
    func startMotionUpdates(){
        // some internal inconsistency here: we need to ask the device manager for device
        
        if self.motion.isDeviceMotionAvailable{
            self.motion.deviceMotionUpdateInterval = 0.1
            self.motion.startDeviceMotionUpdates(to: OperationQueue.main, withHandler: self.handleMotion )
        }
    }
    
    func handleMotion(_ motionData:CMDeviceMotion?, error:Error?){
        if let gravity = motionData?.gravity {
//            self.physicsWorld.gravity = CGVector(dx: CGFloat(9.8*gravity.x), dy: CGFloat(9.8*gravity.y))
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
            if let sprite = self.childNode(withName: ballName) {
                sprite.removeFromParent()
            }
        }
        else if firstBody.categoryBitMask == BarCategory && secondBody.categoryBitMask == BottomCategory {
            bar.position.y = size.height * 0.1
        }
    }
    
    // MARK: View Hierarchy Functions
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        backgroundColor = SKColor.white
        
        // start motion for gravity
        self.startMotionUpdates()

        self.motion.startAccelerometerUpdates()
        self.motion.deviceMotionUpdateInterval = 0.1
        
        
        // make sides to the screen
        self.addSidesAndTop()
        
        // add some stationary blocks
//        self.addStaticBlockAtPoint(CGPoint(x: size.width * 0.1, y: size.height * 0.25))
//        self.addStaticBlockAtPoint(CGPoint(x: size.width * 0.9, y: size.height * 0.25))
        
        for i in 1...4{
            let index = CGFloat(i)/10 + 0.05
            self.addStaticBlockAtPoint(CGPoint(x:size.width * index, y: size.height * 0.9))
        }
        // add a spinning block
        //self.addBarAtPoint(CGPoint(x: size.width * 0.5, y: size.height * 0.1))
        
        
        bar.color = UIColor.black
        bar.size = CGSize(width:size.width*0.3,height:size.height * 0.025)
        bar.position = CGPoint(x: size.width * 0.5, y: size.height * 0.1)
        
        bar.physicsBody = SKPhysicsBody(rectangleOf:bar.size)
        bar.physicsBody?.isDynamic = true
        //bar.physicsBody?.pinned = true
        bar.physicsBody?.affectedByGravity = false
        bar.physicsBody?.allowsRotation = false
        bar.name = barName
        bar.physicsBody!.categoryBitMask = BarCategory
        //bar.physicsBody?.collisionBitMask = CollisionTypes.wall.rawValue
        
        self.addChild(bar)
    

        
        self.addSprite()
    }
    
    func processBarMotion(forUpdate currentTime: CFTimeInterval) {
        if let bar2 = childNode(withName: barName) as? SKSpriteNode {
            if let data = motion.accelerometerData {
                if fabs(data.acceleration.x) > 0.2 {
                    bar2.physicsBody!.applyForce(CGVector(dx: 80 * CGFloat(data.acceleration.x), dy: 0))
                }
            }
        }
    }
    
    // MARK: Create Sprites Functions
    func addSprite(){
//        let spriteA = SKSpriteNode(imageNamed: "sprite") // this is literally a sprite bottle... 😎
//
//        spriteA.size = CGSize(width:size.width*0.1,height:size.height * 0.1)
//
//        spriteA.position = CGPoint(x: size.width * random(min: CGFloat(0.1), max: CGFloat(0.9)), y: size.height * 0.75)
//
//        spriteA.physicsBody = SKPhysicsBody(rectangleOf:spriteA.size)
//        spriteA.physicsBody?.restitution = random(min: CGFloat(1.0), max: CGFloat(1.5))
//        spriteA.physicsBody?.isDynamic = true
        let sprite = childNode(withName: ballName)
        ball.color = UIColor.black
        ball.size = CGSize(width: 25.0, height: 25.0)
        ball.position = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2.0)
        ball.physicsBody?.isDynamic = true
        ball.physicsBody?.allowsRotation = false
        ball.physicsBody?.applyImpulse(CGVector(dx:2.0,dy:-2.0))
        ball.physicsBody!.categoryBitMask = BallCategory
        ball.physicsBody!.contactTestBitMask = BottomCategory
        
        self.addChild(ball)

        //self.addChild(spriteA)
    }
    
    func addBarAtPoint(_ point:CGPoint){
        let block = SKSpriteNode()
        
        block.color = UIColor.black
        block.size = CGSize(width:size.width*0.3,height:size.height * 0.025)
        block.position = point
        
        block.physicsBody = SKPhysicsBody(rectangleOf:block.size)
        block.physicsBody?.isDynamic = true
        //block.physicsBody?.pinned = true
        
        self.addChild(block)
        
    }
    
    
    
    func addStaticBlockAtPoint(_ point:CGPoint){
        let block = SKSpriteNode()
        
        block.color = UIColor.red
        block.size = CGSize(width:size.width*0.1,height:size.height * 0.05)
        
        block.position = point
        
        block.physicsBody = SKPhysicsBody(rectangleOf:block.size)
        block.physicsBody?.isDynamic = true
        block.physicsBody?.pinned = true
        block.physicsBody?.allowsRotation = false
        
        self.addChild(block)
        
    }
    
    func addSidesAndTop(){
        let left = SKSpriteNode()
        let right = SKSpriteNode()
        let top = SKSpriteNode()
        let bot = SKSpriteNode()
        
        left.size = CGSize(width:size.width*0.1,height:size.height)
        left.position = CGPoint(x:0, y:size.height*0.5)
        
        right.size = CGSize(width:size.width*0.1,height:size.height)
        right.position = CGPoint(x:size.width, y:size.height*0.5)
        
        top.size = CGSize(width:size.width,height:size.height*0.1)
        top.position = CGPoint(x:size.width*0.5, y:size.height)
        
        let bottom = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: 1)
        
        bot.physicsBody = SKPhysicsBody(edgeLoopFrom: bottom)
        bot.physicsBody!.categoryBitMask = BottomCategory
        addChild(bot)
        
        
        for obj in [left,right,top]{
            obj.color = UIColor.red
            obj.physicsBody = SKPhysicsBody(rectangleOf:obj.size)
            obj.physicsBody?.isDynamic = true
            obj.physicsBody?.pinned = true
            obj.physicsBody?.allowsRotation = false
            self.addChild(obj)
        }
    }
    
    // MARK: UI Delegate Functions
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
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

