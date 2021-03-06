//
//  WPTCannonNode.swift
//  Waypoint
//
//  Created by Cameron Taylor on 2/19/17.
//  Copyright © 2017 cpe436group. All rights reserved.
//

import SpriteKit

class WPTCannonNode: SKNode {
    
    private let cannon: WPTCannon
    private weak var actor: WPTLevelActorNode!
    
    public private(set) var cannonBallSpawnPoint: CGPoint
    
    let sprite = SKSpriteNode(imageNamed: "cannon")
    
    init(_ cannon: WPTCannon, actor: WPTLevelActorNode) {
        self.actor = actor
        self.cannon = cannon
        self.cannonBallSpawnPoint = 100 * CGPoint(x: cos(cannon.angle), y: sin(cannon.angle))
        super.init()
        
        self.sprite.anchorPoint = CGPoint(x: 0.25, y: 0.5)
        self.sprite.xScale = 0.5
        self.sprite.yScale = 0.5
        self.addChild(sprite)
        
        self.zPosition = 1
        self.position = cannon.position
        self.zRotation = cannon.angle
        self.cannonBallSpawnPoint += self.position
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func fire() {
        guard let projectiles = (self.scene as? WPTLevelScene)?.projectiles else { return }
        let time = actor.actor.ship.range / actor.actor.ship.shotSpeed
        
        let size = self.actor.actor.ship.size * self.actor.actor.ship.cannonBallScale
        let ball = WPTCannonBallNode(actor.actor.cannonBall, damage: actor.actor.ship.damage, size: size)
        ball.teamBitMask = actor.teamBitMask
        ball.position = actor.convert(self.cannonBallSpawnPoint, to: projectiles)
        ball.physics.velocity = getCannonVelocity()
        projectiles.addChild(ball)
        ball.run(SKAction.wait(forDuration: Double(time)), completion: { ball.collideWithGround() })
    }
    
    private func getCannonVelocity() -> CGVector {
        let rot = actor.zRotation + self.zRotation
        let direction = CGVector(dx: cos(rot), dy: sin(rot))
        
        return actor.actor.ship.shotSpeed * direction + (actor.physicsBody?.velocity ?? CGVector.zero)
    }
}
