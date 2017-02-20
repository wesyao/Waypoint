//
//  WPTHudNode.swift
//  Waypoint
//
//  Created by Cameron Taylor on 2/14/17.
//  Copyright © 2017 cpe436group. All rights reserved.
//

import SpriteKit

class WPTHudNode: SKNode, WPTUpdatable {
    
    let top: WPTHudTopNode
    let bottom: WPTHudBottomNode
    let pauseShroud: SKShapeNode
    let pauseMenu: WPTPauseMenuNode
    
    init(player: WPTLevelPlayerNode) {
        self.top = WPTHudTopNode(player: player.player)
        self.bottom = WPTHudBottomNode()
        self.pauseShroud = SKShapeNode(rect: CGRect(origin: CGPoint.zero, size: WPTValues.screenSize))
        self.pauseMenu = WPTPauseMenuNode()
        super.init()
        self.isUserInteractionEnabled = true
        
        // top/bottom nodes
        self.addChild(top)
        self.bottom.onStartPress = player.fireCannons
        self.addChild(bottom)
        
        // shroud
        self.pauseShroud.fillColor = UIColor.black
        self.pauseShroud.strokeColor = UIColor.black
        self.pauseShroud.zPosition = WPTValues.pauseShroudZPosition
        self.pauseShroud.alpha = 0.6
        
        // pause menu
        self.pauseMenu.zPosition = WPTValues.pauseShroudZPosition + 1
        self.pauseMenu.position = CGPoint(x: WPTValues.screenSize.width / 2.0, y: WPTValues.screenSize.height / 2.0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(_ currentTime: TimeInterval, _ deltaTime: TimeInterval) {
        self.top.update(currentTime, deltaTime)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let touchPos = touch.location(in: self)
        var paused = false
        let scene = self.scene as? WPTLevelScene
        if scene != nil {
            paused = scene!.levelPaused
        }
        
        if paused {
            if !self.pauseMenu.contains(touchPos) {
                // the background was touched, unpause
                scene?.levelPaused = false
                self.toggleShroud(false)
            }
        } else {
            if self.top.pause.contains(touchPos) {
                scene?.levelPaused = true
                self.toggleShroud(true)
            }
        }
    }
    
    private func toggleShroud(_ isPaused: Bool) {
        if isPaused {
            self.pauseMenu.levelName = (self.scene as! WPTLevelScene).level.name
            
            self.addChild(self.pauseShroud)
            self.addChild(self.pauseMenu)
        } else {
            self.pauseShroud.removeFromParent()
            self.pauseMenu.removeFromParent()
        }
    }
}

