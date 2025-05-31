//
//  Item.swift
//  WillDo
//
//  Created by 高野　泰生 on 2025/05/31.
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
