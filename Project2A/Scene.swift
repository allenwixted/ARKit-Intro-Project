//
//  Scene.swift
//  Project2A
//
//  Created by Allen Wixted on 15/06/2017.
//  Copyright © 2017 Wixted. All rights reserved.
//

import SpriteKit
import ARKit
import GameplayKit

class Scene: SKScene {
    
    let remainingLabel = SKLabelNode()
    var timer:Timer?
    var targetsCreated = 0
    var targetCount = 0 {
        didSet {
            remainingLabel.text = "Remaining: \(targetCount)"
        }
    }
    let startTime = Date()
    
    override func didMove(to view: SKView) {
        // Setup your scene here  
        
        remainingLabel.fontSize = 36
        remainingLabel.color = .white
        remainingLabel.fontName = "Comic Sans"
        //place the label in the top middle of the current frame
        remainingLabel.position = CGPoint(x: 0, y: view.frame.midY)
        
        //let's create a new target every two seconds
        timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) {
            timer in self.createTarget()
        }
    }
    
    func createTarget() {
        if targetsCreated == 20 {
            timer?.invalidate()
            timer = nil
            return
        }
        targetsCreated += 1
        targetCount += 1
        
        //double check the AR Scene exists
        guard let sceneView = self.view as? ARSKView else { return }
        
        let random = GKRandomSource.sharedRandom()
        
        //create random X rotation
        //converts scene matrix to simd_float4x4 //get full circle ➗ random
        let xRotation = SCNMatrix4ToMat4(SCNMatrix4MakeRotation(Float.pi * 2 * random.nextUniform(), 1, 0, 0))
        let yRotation = SCNMatrix4ToMat4(SCNMatrix4MakeRotation(Float.pi * 2 * random.nextUniform(), 0, 1, 0))
        
        //combine the matrices
        let rotation = simd_mul(xRotation, yRotation)
        
        //move away 1.5m like before
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -1.5
        
        //combine those two
        let transform = simd_mul(rotation, translation)
        
        //create our anchor
        let anchor = ARAnchor(transform: transform)
        sceneView.session.add(anchor: anchor)
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let sceneView = self.view as? ARSKView else {
//            return
//        }
//
//        // Create anchor using the camera's current position
//        if let currentFrame = sceneView.session.currentFrame {
//
//            // Create a transform with a translation of 0.2 meters in front of the camera
//            var translation = matrix_identity_float4x4
//            translation.columns.3.z = -0.2
//            let transform = simd_mul(currentFrame.camera.transform, translation)
//
//            // Add a new anchor to the session
//            let anchor = ARAnchor(transform: transform)
//            sceneView.session.add(anchor: anchor)
//        }
        
        //grab the touch
        guard let touch = touches.first else { return }
        //check its location
        let location = touch.location(in: self)
        //check what nodes are affected
        let hit = nodes(at: location)
        
        //if there is one then let's get rid of it nicely
        if let sprite = hit.first {
            let scaleOut = SKAction.scale(by: 2, duration: 0.2)
            let fadeOut = SKAction.fadeOut(withDuration: 0.2)
            let group = SKAction.group([scaleOut, fadeOut])
            let sequence = SKAction.sequence([group, SKAction.removeFromParent()])
            sprite.run(sequence)
            
            targetCount -= 1
            
            if targetCount == 0 && targetsCreated == 20 {
                gameOver()
            }
        }
    }
    
    func gameOver() {
        remainingLabel.removeFromParent()
        
        let gameOver = SKSpriteNode(imageNamed: "gameOver")
        addChild(gameOver)
        
        let timeTaken = Date().timeIntervalSince(startTime)
        let timeLabel = SKLabelNode(text: "Time Taken: \(Int(timeTaken)) seconds")
        timeLabel.fontName = "Comic Sans"
        timeLabel.fontSize = 36
        timeLabel.fontColor = .white
        timeLabel.position = CGPoint(x: 0, y: frame.midY)
        
        addChild(timeLabel)
    }
}
