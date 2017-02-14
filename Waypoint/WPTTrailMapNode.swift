//
//  WPTTrailMapNode.swift
//  Waypoint
//
//  Created by Cameron Taylor on 2/7/17.
//  Copyright © 2017 cpe436group. All rights reserved.
//

import SpriteKit
import UIKit
import GameplayKit

class WPTTrailMapNode: SKNode {
    
    var trailMap: WPTTrailMap?
    private let progress: WPTPlayerProgress
    
    let trailShader = SKShader(fileNamed: "trail_shader.fsh")
    let unlockedMarkerTexture = SKTexture(imageNamed: "blue_circle")
    let lockedMarkerTexture = SKTexture(imageNamed: "red_circle")
    let treasureMarkerTexture = SKTexture(imageNamed: "x_marks_the_spot")
    
    init(progress: WPTPlayerProgress) {
        self.progress = progress
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func position(for scene: WPTScene) {
        self.removeAllChildren()
        
        let h = scene.frame.width / WPTValues.maxAspectRatio
        let ymin = (scene.frame.height - h) / 2.0;
        self.position = CGPoint(x: 0, y: ymin)
        
        self.trailMap = WPTTrailMap(mapSize: CGSize(width: scene.frame.width, height: h), progress: self.progress)
        let trail = SKShapeNode(path: self.trailMap!.toCGPath())
        trail.lineWidth = 2.5
        trail.strokeColor = .clear
        trail.strokeShader = trailShader
        
        self.addChild(trail)
        
        self.trailMap!.traversePoints({
            (index, point, isUnlocked) in
            
            var texture = isUnlocked ? unlockedMarkerTexture : lockedMarkerTexture
            
            var scale: CGSize?
            switch (index) {
            case 0:
                let scaleSize = 0.08 * WPTValues.usableScreenHeight
                scale = CGSize(width: scaleSize, height: scaleSize)
            case self.trailMap!.stopCount - 1:
                let scaleSize = 0.15 * WPTValues.usableScreenHeight
                scale = CGSize(width: scaleSize, height: scaleSize)
                texture = treasureMarkerTexture
            default:
                let scaleSize = 0.06 * WPTValues.usableScreenHeight
                scale = CGSize(width: scaleSize, height: scaleSize)
            }
            
            let marker = SKSpriteNode(texture: texture)
            marker.position = point
            marker.scale(to: scale!)
            marker.zPosition = 2
            self.addChild(marker)
        })
    }
}
