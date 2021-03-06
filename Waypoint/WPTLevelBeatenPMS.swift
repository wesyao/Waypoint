//
//  WPTLevelBeatenPMS.swift
//  Waypoint
//
//  Created by Cameron Taylor on 3/19/17.
//  Copyright © 2017 cpe436group. All rights reserved.
//

import SpriteKit
import GameplayKit

class WPTLevelBeatenPMS: GKState {
    override func didEnter(from previousState: GKState?) {
        NSLog("Started WPTLevelBeatenPMS")
        
        if let puppetMaster = self.stateMachine as? WPTPuppetMaster {
            puppetMaster.scene.port?.active = true
            if !puppetMaster.scene.levelBeaten {
                WPTAudioConfig.audio.playSong(song: "waypoint_victory.wav", numLoops: 0, completion: { (true) in
                    WPTAudioConfig.audio.playSong(song: "level_map_theme.wav")
                })
            }
            puppetMaster.scene.alert(header: "Level Complete", desc: "Dock at the port to continue.", large: true)
        }
        
        // allow the player to dock at the port
        if let port = (self.stateMachine as? WPTPuppetMaster)?.scene.port {
            port.active = true
        }
    }
}
