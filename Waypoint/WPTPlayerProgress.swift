//
//  WPTPlayerProgress.swift
//  Waypoint
//
//  Created by Cameron Taylor on 2/13/17.
//  Copyright © 2017 cpe436group. All rights reserved.
//

import Foundation

class WPTPlayerProgress {
    var completedLevels = [String]()
    
    init(completedLevels: [String]?) {
        if let cp = completedLevels {
            self.completedLevels = cp
        }
    }
}