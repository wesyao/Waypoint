//
//  WPTFleeBS.swift
//  Waypoint
//
//  Created by Cameron Taylor on 3/11/17.
//  Copyright © 2017 cpe436group. All rights reserved.
//

import SpriteKit
import GameplayKit

class WPTFleeBS: WPTBrainState {
    static let type: WPTBrainStateType = WPTBrainStateType.FLEE
    
    init() {
        super.init(name: String(describing: WPTDoNothingBS.self), type: WPTFleeBS.type)
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        enemy.anchored = false
        let towardsPlayer = CGVector(dx: player.position.x - enemy.position.x, dy: player.position.y - enemy.position.y)
        let target = CGPoint(x: enemy.position.x - towardsPlayer.dx, y: enemy.position.y - towardsPlayer.dy)
        enemy.facePoint(target)
    }
}