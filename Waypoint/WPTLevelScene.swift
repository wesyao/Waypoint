//
//  WPTLevelScene.swift
//  Waypoint
//
//  Created by Cameron Taylor on 2/6/17.
//  Copyright © 2017 cpe436group. All rights reserved.
//

import SpriteKit

class WPTLevelScene: WPTScene {
    static let levelNameTag = "_LEVEL"
    static let playerNameTag = "_PLAYER"
    
    let level: WPTLevel
    
    let terrain: WPTTerrainNode
    let player: WPTLevelPlayerNode
    let hud: WPTHudNode
    var cam: SKCameraNode!
    
    var levelPaused: Bool = false {
        didSet { self.pauseChanged() }
    }
    
    init(player: WPTPlayer, level: WPTLevel) {
        self.player = WPTLevelPlayerNode(player: player)
        self.level = level
        self.hud = WPTHudNode(player: self.player.player)
        self.terrain = WPTTerrainNode(level: level)
        super.init(size: CGSize(width: 0, height: 0))
        
        self.isUserInteractionEnabled = true
        
        self.scene?.backgroundColor = UIColor.black
        
        // setup the physics behavior
        self.physicsWorld.gravity = CGVector.zero
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        // camera
        cam = SKCameraNode()
        self.camera = cam
        self.addChild(cam)
        cam.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        self.hud.position = CGPoint(x: -self.cam.frame.midX, y: -self.cam.frame.midY)
        self.cam.setScale(1.0 / WPTValues.levelSceneScale)
        cam.addChild(self.hud)
        
        self.loadLevel()
        
        // breif flash of level name
        let levelName = WPTLabelNode(text: self.level.name, fontSize: WPTValues.fontSizeLarge)
        levelName.name = WPTLevelScene.levelNameTag
        levelName.position.y += 0.2 * WPTValues.screenSize.height
        levelName.alpha = 0
        levelName.fontColor = UIColor.black
        self.cam.addChild(levelName)
        WPTLabelNode.fadeInOut(levelName, 0.5, 2, 2, 2, completion: {
            levelName.removeFromParent()
        })
    }
    
    private func loadLevel() {
        // setup the player
        self.player.name = WPTLevelScene.playerNameTag
        self.player.position = self.terrain.spawnPoint
        self.terrain.addChild(self.player)
        
        // add everything to the scene
        self.addChild(self.terrain)
    }
    
    private let lastCurrentTime: TimeInterval? = nil
    override func update(_ currentTime: TimeInterval) {
        let deltaTime = lastCurrentTime == nil ? 0 : currentTime - lastCurrentTime!

        if self.levelPaused { return } // everything below this is subject to the pause
        
        self.player.update(currentTime, deltaTime)
        self.hud.update(currentTime, deltaTime)
    }
    
    override func didEvaluateActions() {
        // center the camera on the player
        let shift = self.terrain.position + self.player.position
        self.cam.position = shift
    }
        
    private func pauseChanged() {
        if let levelName = self.childNode(withName: WPTLevelScene.levelNameTag) {
            levelName.isPaused = self.levelPaused
        }
        self.physicsWorld.speed = self.levelPaused ? 0.0 : 1.0 // pause physics simulation
    }
}
