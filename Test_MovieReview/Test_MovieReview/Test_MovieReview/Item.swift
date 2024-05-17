//
//  Item.swift
//  Test_MovieReview
//
//  Created by jira on 13/5/2567 BE.
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
