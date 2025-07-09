//
//  Item.swift
//  DoNext
//
//  Created by Lenny Cheng on 2025/7/9.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
