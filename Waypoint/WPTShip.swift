//
//  WPTShip.swift
//  Waypoint
//
//  Created by Hilary Schulz on 1/26/17.
//  Copyright © 2017 cpe436group. All rights reserved.
//

import SpriteKit

class WPTShip {
    
    public static var MAX_SHIP_NAME_LENGTH: Int = 64 // TODO: verify this when picking a name
    
    let name: String
    let playable: Bool
    let turnWhenFacing: Bool
    
    /* All stats are multipliers of base values and clamped between min/max values. */
    
    var speedScale: CGFloat = 1.0 { // determines the speed of the ship as it moves
        didSet { clamp(&speedScale, min: WPTShip.minSpeedScale, max: WPTShip.maxSpeedScale) }
    }
    var speed: CGFloat {
        get { return speedScale * WPTShip.baseSpeed }
    }
    
    var damageScale: CGFloat = 1.0 { // determines the amount of damage that the ship does
        didSet { clamp(&damageScale, min: WPTShip.minDamageScale, max: WPTShip.maxDamageScale) }
    }
    var damage: CGFloat {
        get { return damageScale * WPTShip.baseDamage }
    }
    
    var healthScale: CGFloat = 1.0 { // determines the amount of health on the ship
        didSet { clamp(&healthScale, min: WPTShip.minHealthScale, max: WPTShip.maxHealthScale) }
    }
    var health: CGFloat {
        get { return healthScale * WPTShip.baseHealth }
    }
    
    var rangeScale: CGFloat = 1.0 { // determines how far cannon shots travel before hitting the water/ground
        didSet { clamp(&rangeScale, min: WPTShip.minRangeScale, max: WPTShip.maxRangeScale) }
    }
    var range: CGFloat {
        get { return rangeScale * WPTShip.baseRange }
    }
    
    var shotSpeedScale: CGFloat = 1.0 { // determines how fast cannon shots travel through the air
        didSet { clamp(&shotSpeedScale, min: WPTShip.minShotSpeedScale, max: WPTShip.maxShotSpeedScale) }
    }
    var shotSpeed: CGFloat {
        get { return shotSpeedScale * WPTShip.baseShotSpeed }
    }
    
    var sizeScale: CGFloat = 1.0 { // determines the size of the ship on the screen
        didSet { clamp(&sizeScale, min: WPTShip.minSizeScale, max: WPTShip.maxSizeScale) }
    }
    var size: CGFloat {
        get { return sizeScale * WPTShip.baseSize }
    }
    
    var turnRateScale: CGFloat = 1.0 { // determines how quickly the ship makes turns
        didSet { clamp(&turnRateScale, min: WPTShip.minTurnRateScale, max: WPTShip.maxTurnRateScale) }
    }
    var turnRate: CGFloat {
        get { return turnRateScale * WPTShip.baseTurnRate }
    }
    
    var fireRateScale: CGFloat = 1.0 { // determines how many shots/second can be made
        didSet { clamp(&fireRateScale, min: WPTShip.minFireRateScale, max: WPTShip.maxFireRateScale) }
    }
    var fireRate: CGFloat {
        get { return fireRateScale * WPTShip.baseFireRate }
    }
    
    var itemRadiusScale: CGFloat = 1.0 {
        didSet { clamp(&itemRadiusScale, min: WPTShip.minItemRadiusScale, max: WPTShip.maxItemRadiusScale) }
    }
    var itemRadius: CGFloat {
        get { return itemRadiusScale * WPTShip.baseItemRadius; }
    }
    
    let previewImage: String
    let inGameImage: String
    let cannonSet: WPTCannonSet
    let colliderPath: CGPath
    
    init(dict: [String:AnyObject], playable: Bool) {
        self.playable = playable
        self.turnWhenFacing = dict["turnWhenFacing"] as! Bool
        
        self.name = dict["name"] as! String
        self.previewImage = dict["previewImage"] as! String
        self.inGameImage = dict["inGameImage"] as! String
        self.cannonSet = WPTCannonSet(dict["cannonSet"] as! [[String:AnyObject]])
        
        // collider
        let pathArr = dict["colliderPath"] as! [[CGFloat]]
        let offsetDict = dict["colliderOffset"] as! [String:CGFloat]
        let path = CGMutablePath()
        if pathArr.count > 0 {
            let offset = CGPoint(x: offsetDict["x"]!, y: offsetDict["y"]!)
            path.move(to: CGPoint(x: 2 * pathArr[0][0], y: 2 * pathArr[0][1]) + offset)
            for i in 1..<pathArr.count {
                let point = pathArr[i]
                path.addLine(to: CGPoint(x: 2 * point[0], y: 2 * point[1]) + offset)
            }
            path.closeSubpath()
        }
        colliderPath = path
        
        // stats
        if let stats = dict["stats"] as? [String:CGFloat] {
            self.speedScale = stats["speedScale"]!
            self.damageScale = stats["damageScale"]!
            self.healthScale = stats["healthScale"]!
            self.rangeScale = stats["rangeScale"]!
            self.shotSpeedScale = stats["shotSpeedScale"]!
            self.sizeScale = stats["sizeScale"]!
            self.turnRateScale = stats["turnRateScale"]!
            self.fireRateScale = stats["fireRateScale"]!
            self.itemRadiusScale = stats["itemRadiusScale"]!
        }
        else if let stats = dict["stats"] as? String {
            if stats == "max" {
                self.speedScale = WPTShip.maxSpeedScale
                self.damageScale = WPTShip.maxDamageScale
                self.healthScale = WPTShip.maxHealthScale
                self.rangeScale = WPTShip.maxRangeScale
                self.shotSpeedScale = WPTShip.maxShotSpeedScale
                self.sizeScale = WPTShip.maxSizeScale
                self.turnRateScale = WPTShip.maxTurnRateScale
                self.fireRateScale = WPTShip.maxFireRateScale
                self.itemRadiusScale = WPTShip.maxItemRadiusScale
            }
            else if stats == "min" {
                self.speedScale = WPTShip.minSpeedScale
                self.damageScale = WPTShip.minDamageScale
                self.healthScale = WPTShip.minHealthScale
                self.rangeScale = WPTShip.minRangeScale
                self.shotSpeedScale = WPTShip.minShotSpeedScale
                self.sizeScale = WPTShip.minSizeScale
                self.turnRateScale = WPTShip.minTurnRateScale
                self.fireRateScale = WPTShip.minFireRateScale
                self.itemRadiusScale = WPTShip.minItemRadiusScale
            }
        }
    }
    
    init(other: WPTShip) {
        self.name = other.name
        self.playable = other.playable
        self.turnWhenFacing = other.turnWhenFacing
        self.previewImage = other.previewImage
        self.inGameImage = other.inGameImage
        self.cannonSet = WPTCannonSet(other: other.cannonSet)
        self.colliderPath = other.colliderPath
        self.initStats(speedScale: other.speedScale, damageScale: other.damageScale, healthScale: other.healthScale, rangeScale: other.rangeScale, shotSpeedScale: other.shotSpeedScale, sizeScale: other.sizeScale, turnRateScale: other.turnRateScale, itemRadiusScale: other.itemRadiusScale)
    }
    
    func initStats(speedScale: CGFloat = 1.0, damageScale: CGFloat = 1.0, healthScale: CGFloat = 1.0, rangeScale: CGFloat = 1.0, shotSpeedScale: CGFloat = 1.0, sizeScale: CGFloat = 1.0, turnRateScale: CGFloat = 1.0, fireRateScale: CGFloat = 1.0, itemRadiusScale: CGFloat = 1.0) {
        self.speedScale = speedScale
        self.damageScale = damageScale
        self.healthScale = healthScale
        self.rangeScale = rangeScale
        self.shotSpeedScale = shotSpeedScale
        self.sizeScale = sizeScale
        self.turnRateScale = turnRateScale
        self.fireRateScale = fireRateScale
        self.itemRadiusScale = itemRadiusScale
    }
    
    func shuffleStats() {
        self.speedScale = WPTShip.randStat(min: WPTShip.minSpeedScale, max: WPTShip.maxSpeedScale)
        self.damageScale = WPTShip.randStat(min: WPTShip.minDamageScale, max: WPTShip.maxDamageScale)
        self.healthScale = WPTShip.randStat(min: WPTShip.minHealthScale, max: WPTShip.maxHealthScale)
        self.rangeScale = WPTShip.randStat(min: WPTShip.minRangeScale, max: WPTShip.maxRangeScale)
        self.shotSpeedScale = WPTShip.randStat(min: WPTShip.minShotSpeedScale, max: WPTShip.maxShotSpeedScale)
        self.sizeScale = WPTShip.randStat(min: WPTShip.minSizeScale, max: WPTShip.maxSizeScale)
        self.turnRateScale = WPTShip.randStat(min: WPTShip.minTurnRateScale, max: WPTShip.maxTurnRateScale)
        self.fireRateScale = WPTShip.randStat(min: WPTShip.minFireRateScale, max: WPTShip.maxFireRateScale)
        self.itemRadiusScale = WPTShip.randStat(min: WPTShip.minItemRadiusScale, max: WPTShip.maxItemRadiusScale)
    }
    
    static func randStat(min: CGFloat, max: CGFloat) -> CGFloat {
        let rand = CGFloat(arc4random()) / CGFloat(UInt32.max)
        return (max - min) * rand + min
    }
    
    func upgrade(with item: WPTItem) {
        self.speedScale += item.speedModifier ?? 0
        self.damageScale += item.damageModifier ?? 0
        self.healthScale += item.healthModifier ?? 0
        self.rangeScale += item.rangeModifier ?? 0
        self.shotSpeedScale += item.shotSpeedModifier ?? 0
        self.sizeScale += item.sizeModifier ?? 0
        self.turnRateScale += item.turnRateModifier ?? 0
        self.fireRateScale += item.fireRateModifier ?? 0
        self.itemRadiusScale += item.itemRadiusModifier ?? 0
    }
}

extension WPTShip {
    static let minSpeedScale: CGFloat = 0.4
    static let maxSpeedScale: CGFloat = 10.0
    static let baseSpeed: CGFloat = 3500.0
    static let minSpeed: CGFloat = WPTShip.baseSpeed * WPTShip.minSpeedScale
    static let maxSpeed: CGFloat = WPTShip.baseSpeed * WPTShip.maxSpeedScale
    
    static let minDamageScale: CGFloat = 0.5
    static let maxDamageScale: CGFloat = 20.0
    static let baseDamage: CGFloat = 20.0
    static let minDamage: CGFloat = WPTShip.baseDamage * WPTShip.minDamageScale
    static let maxDamage: CGFloat = WPTShip.baseDamage * WPTShip.maxDamageScale
    
    static let minHealthScale: CGFloat = 0.5
    static let maxHealthScale: CGFloat = 50.0
    static let baseHealth: CGFloat = 100
    static let minHealth: CGFloat = WPTShip.baseHealth * WPTShip.minHealthScale
    static let maxHealth: CGFloat = WPTShip.baseHealth * WPTShip.maxHealthScale
    
    static let minRangeScale: CGFloat = 0.2
    static let maxRangeScale: CGFloat = 50.0
    static let baseRange: CGFloat = 350
    static let minRange: CGFloat = WPTShip.baseRange * WPTShip.minRangeScale
    static let maxRange: CGFloat = WPTShip.baseRange * WPTShip.maxRangeScale
    
    static let minShotSpeedScale: CGFloat = 0.1
    static let maxShotSpeedScale: CGFloat = 5.0
    static let baseShotSpeed: CGFloat = 1000.0
    static let minShotSpeed: CGFloat = WPTShip.baseShotSpeed * WPTShip.minShotSpeedScale
    static let maxShotSpeed: CGFloat = WPTShip.baseShotSpeed * WPTShip.maxShotSpeedScale
    
    static let minSizeScale: CGFloat = 0.5
    static let maxSizeScale: CGFloat = 2.5
    static let baseSize: CGFloat = 0.3
    static let minSize: CGFloat = WPTShip.baseSize * WPTShip.minSizeScale
    static let maxSize: CGFloat = WPTShip.baseSize * WPTShip.maxSizeScale
    
    static let minTurnRateScale: CGFloat = 0.4
    static let maxTurnRateScale: CGFloat = 10
    static let baseTurnRate: CGFloat = 1.0
    static let minTurnRate: CGFloat = WPTShip.baseTurnRate * WPTShip.minTurnRateScale
    static let maxTurnRate: CGFloat = WPTShip.baseTurnRate * WPTShip.maxTurnRateScale
    
    static let minFireRateScale: CGFloat = 0.2
    static let maxFireRateScale: CGFloat = 10
    static let baseFireRate: CGFloat = 2
    static let minFireRate: CGFloat = WPTShip.baseFireRate * WPTShip.minFireRateScale
    static let maxFireRate: CGFloat = WPTShip.baseFireRate * WPTShip.maxFireRateScale
    
    static let minItemRadiusScale: CGFloat = 1.0
    static let maxItemRadiusScale: CGFloat = 100.0
    static let baseItemRadius: CGFloat = 250
    static let minItemRadius: CGFloat = WPTShip.baseItemRadius * WPTShip.minItemRadiusScale
    static let maxItemRadius: CGFloat = WPTShip.baseItemRadius * WPTShip.maxItemRadiusScale
}
