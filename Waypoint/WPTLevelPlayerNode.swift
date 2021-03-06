//
//  WPTLevelPlayerNode.swift
//  Waypoint
//
//  Created by Cameron Taylor on 2/14/17.
//  Copyright © 2017 cpe436group. All rights reserved.
//

import SpriteKit

class WPTLevelPlayerNode: WPTLevelActorNode {
    
    var player: WPTPlayer { return self.actor as! WPTPlayer }
    var portHandler: WPTPortDockingHandler! = nil
    
    let mapScrollEffect = WPTAudioNode(effect: "map_scroll")
    let reticle = WPTReticleNode()
    var itemRad: WPTItemCollectorNode! = nil
    
    public private(set) var interactionEnabled: Bool = true
    
    override var spriteImage: String {
        return self.actor.ship.inGamePlayerImage!
    }
    
    init(player: WPTPlayer) {
        super.init(actor: player, teamBitMask: WPTConfig.values.testing ? 0 : WPTValues.playerTbm)
        if let prog = player.progress {
            self.doubloons = prog.doubloons
        }

        self.setHealth(player.progress!.healthSnapshot)
        
        // components
        portHandler = WPTPortDockingHandler(self)
        self.addChild(self.portHandler)
        
        // item collection radius
        itemRad = WPTItemCollectorNode(target: self, radius: player.ship.itemRadius)
        itemRad.setScale(1 / player.ship.size)
        self.addChild(itemRad)
        
        self.physicsBody!.collisionBitMask |= WPTValues.boundaryCbm
        
        self.addChild(mapScrollEffect)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(_ currentTime: TimeInterval, _ deltaTime: TimeInterval) {
        if let targetNode = self.targetNode {
            self.aimCannons(node: targetNode)
        } else if reticle.attached {
            self.reticle.remove()
        }
        
        if reticle.attached {
            reticle.update(currentTime, deltaTime)
        }
        
        itemRad.update(currentTime, deltaTime)
        
        if !portHandler.docked {
            super.update(currentTime, deltaTime)
        } else if let dockPos = portHandler.dockPos {
            self.position = dockPos
        }
    }
    
    public func setUserInteraction(_ value: Bool) {
        self.interactionEnabled = value
        let hud = (self.scene as! WPTLevelScene).hud
        hud.bottom.isUserInteractionEnabled = value
        if value {
            self.fireRateMgr.enable()
        } else {
            self.fireRateMgr.disable()
        }
    }
    
    func setSteeringInteration(_ value: Bool) {
        let hud = (self.scene as! WPTLevelScene).hud
        hud.bottom.wheel.enabled = value
    }
    
    override func getShipSpeed() -> CGFloat {
        if let moveTouchDist = (self.scene as? WPTLevelScene)?.hud.bottom.wheel.moveTouchDist {
            return moveTouchDist * player.ship.speed
        }
        
        return player.ship.speed
    }
    
//    func touched() {
//        if portHandler.docked {
//            self.portHandler.undock()
//        }
//    }
    
    override func doDamage(_ damage: CGFloat) {
        NSLog("Damaging player for \(damage) health")
        super.doDamage(damage)
        if let scene = (self.scene as? WPTLevelScene) {
            let alive = scene.hud.top.shipHealth.updateHealth(damage)
            
            // restart the level?
            if !WPTConfig.values.invincible && WPTConfig.values.restartLevelOnDeath && !alive {
                self.restartLevel(scene)
            }
            
            // dead
            if !alive && !WPTConfig.values.invincible {
                self.handleDeath(scene)
            }
        }
        NSLog("Player now has \(self.health) health out of \(player.ship.health)")
    }

    override func give(item: WPTItem) {
        super.give(item: item)
        
        if let top = (self.scene as? WPTLevelScene)?.hud.top {
            // update doubloons at the top
            top.updateMoney()
            
            // and health
            top.shipHealth.maxHealth = self.player.ship.health
            let _ = top.shipHealth.updateHealth(0)
            NSLog("Top Health Bar now shows \(top.shipHealth.curHealth)/\(top.shipHealth.maxHealth)")
        }

        // show description
        if let desc = item.description {
            if let scene = self.scene as? WPTLevelScene {
                scene.alert(header: item.name, desc: desc)
            }
        }
        
    }
    
    override func aimAt(node target: SKNode) {
        super.aimAt(node: target)
        self.reticle.track(node: target)
    }
    
    private func restartLevel(_ scene: WPTLevelScene) {
        self.setHealth(self.player.ship.health)
        self.doubloons = (self.scene as! WPTLevelScene).levelStartMoney
        self.player.progress = WPTPlayerProgress(playerNode: self)
        scene.level.resetWaveEnemies()
        scene.view?.presentScene(WPTLevelScene(player: self.player, level: scene.level))
    }
    
    private func handleDeath(_ scene: WPTLevelScene) {
        scene.contactDelegate = nil
        scene.levelPaused = true
        scene.hud.top.pause.isHidden = true
        scene.hud.bottom.hideBorder()
        scene.hud.pauseShroud.removeFromParent()
        scene.hud.addChild(scene.hud.pauseShroud)
        scene.hud.destroyMenu.updateMoney()
        
        mapScrollEffect.playEffect()
        WPTAudioConfig.audio.playSong(song: "level_map_theme.wav")
        scene.hud.destroyMenu.removeFromParent()
        scene.hud.addChild(scene.hud.destroyMenu)
        
        if !WPTConfig.values.restartLevelOnDeath {
            OperationQueue().addOperation {
                let storage = WPTStorage()
                // clear progress
                storage.clearPlayerProgress()
            }
        }
    }
}
