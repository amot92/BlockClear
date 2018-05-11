//
//  Swap.swift
//  Block Clear
//
//  Created by Adam Oakes on 5/3/18.
//  Copyright © 2018 Bloc. All rights reserved.
//

import Foundation

struct Swap: CustomStringConvertible {
    let blockA: Block
    let blockB: Block?
    let toColumn: Int?
    
    init(blockA: Block, blockB: Block) {
        self.blockA = blockA
        self.blockB = blockB
        self.toColumn = nil
    }
    
    init(blockA: Block, toColumn: Int) {
        self.blockA = blockA
        self.blockB = nil
        self.toColumn = toColumn
    }
    
    var description: String {
        return "swap \(blockA) with \(blockB)"
    }
}
