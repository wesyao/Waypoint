//
//  WPTLevelScene.swift
//  Waypoint
//
//  Created by Cameron Taylor on 2/6/17.
//  Copyright © 2017 cpe436group. All rights reserved.
//

import SpriteKit

class WPTLevelScene: WPTScene {
    
    let player: WPTLevelPlayerNode
    let level: WPTLevel
    
    init(player: WPTPlayer, level: WPTLevel) {
        self.player = WPTLevelPlayerNode(player: player)
        self.level = level
        super.init(size: CGSize(width: 0, height: 0))
        
        self.scene?.backgroundColor = UIColor.cyan
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        self.removeAllChildren()
        
        self.player.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        self.addChild(self.player)
        
        self.loadLevel()
    }
    
    private func loadLevel() {
        print("loading level: \(self.level.name)")
    }
    
}
