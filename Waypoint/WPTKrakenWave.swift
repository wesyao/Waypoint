//
//  WPTKrakenWave.swift
//  Waypoint
//
//  Created by Cameron Taylor on 3/22/17.
//  Copyright © 2017 cpe436group. All rights reserved.
//

import SpriteKit

// wave 5 in the final boss
class WPTKrakenWave: WPTTentacleWave {
    
    private var kraken: WPTLevelTentacleNode! = nil
    private let krakenLocation: CGPoint
    private let bubbleDuration: TimeInterval
    private let tentacleBubbleDuration: TimeInterval
    private var krakenIsDead: Bool = false
    
    private let tentacleSpawnRadius: CGFloat
    
    override init(_ waveDict: [String: AnyObject]) {
        let krakenLocationDict = waveDict["krakenLocation"] as! [String:CGFloat]
        self.krakenLocation = CGPoint(x: krakenLocationDict["x"]!, y: krakenLocationDict["y"]!)
        self.bubbleDuration = waveDict["bubbleDuration"] as! TimeInterval
        self.tentacleSpawnRadius = waveDict["tentacleSpawnRadius"] as! CGFloat
        self.tentacleBubbleDuration = waveDict["tentacleBubbleDuration"] as! TimeInterval
        super.init(waveDict)
    }
    
    override func setup(scene: WPTLevelScene) {
        super.setup(scene: scene, isStatic: false)
        self.spawnKraken()
        self.spawnTentacles()
    }
    
    private func spawnTentacles() {
        let spawnLocations = self.getTentacleSpawnLocations()
        assert(spawnLocations.count == self.tentacleCount)
        
        let wait = SKAction.wait(forDuration: self.tentacleBubbleDuration)
        for i in 0..<self.tentacleCount {
            self.tentacles[i].position = spawnLocations[i]
            self.tentacles[i].submerge(duration: 0)
            self.tentacles[i].setBubbles(true)
            self.scene.terrain.addEnemy(self.tentacles[i])
            
            self.tentacles[i].run(wait) {
                self.tentacles[i].surface(duration: 3.0) {
                    self.tentacles[i].brain?.start()
                }
            }
        }
    }
    
    private func getTentacleSpawnLocations() -> [CGPoint] {
        var result = [self.angleToSpawnLocation(CG_PI)]
        
        if self.tentacleCount > 1 {
            let deltaAngle = CG_PI / CGFloat(self.tentacleCount - 1)
            for i in 1..<self.tentacleCount {
                result.append(self.angleToSpawnLocation(CG_PI + CGFloat(i) * deltaAngle))
            }
        }
        
        return result
    }
    
    private func angleToSpawnLocation(_ angle: CGFloat) -> CGPoint {
        return self.krakenLocation + self.tentacleSpawnRadius * CGVector(radians: angle)
    }
    
    private func spawnKraken() {
        self.kraken = WPTLevelTentacleNode(type: WPTTentacleEnemyType.KRAKEN_HEAD, player: self.scene.player, submerged: true)
        self.kraken.position = self.krakenLocation
        self.kraken.onDeath {
            self.krakenIsDead = true
        }
        self.scene.terrain.addEnemy(self.kraken)
        
        self.kraken.run(SKAction.wait(forDuration: 3)) {
            NSLog("The Kraken rises!!!")
            self.kraken.surface(duration: 1.5)
        }
    }
    
    override func isComplete(scene: WPTLevelScene) -> Bool {
        let result = self.krakenIsDead && super.isComplete(scene: scene)
        if result {
            WPTAudioConfig.audio.playSong(song: "waypoint_victory.wav", numLoops: 0, completion: { (true) in
                WPTAudioConfig.audio.playSong(song: "level_map_theme.wav")
            })
        }
        return result
    }
}
