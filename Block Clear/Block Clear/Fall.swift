//
//  Fall.swift
//  Block Clear
//
//  Created by Adam Oakes on 5/8/18.
//  Copyright © 2018 Bloc. All rights reserved.
//

import Foundation

struct Fall: CustomStringConvertible {
    let block: Block
    let toRow: Int
    
    init(block: Block, toRow: Int) {
        self.block = block
        self.toRow = toRow
        block.isFalling = true
//        print(self.description)
    }
    
    var description: String {
        return "\(block) is falling to \(toRow)"
    }
}
