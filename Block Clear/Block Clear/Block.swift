//
//  Block.swift
//  Block Clear
//
//  Created by Adam Oakes on 4/26/18.
//  Copyright © 2018 Bloc. All rights reserved.
//

import SpriteKit

enum BlockType: Int {
    
    case unknown = 0, red, blue, green, purple, orange, yellow
    
    var spriteColor: SKColor {
        let spriteColors = [
            SKColor.red,
            SKColor.blue,
            SKColor.green,
            SKColor.purple,
            SKColor.orange,
            SKColor.yellow]
        
        return spriteColors[rawValue - 1]
    }
    
    static func random() -> BlockType {
        return BlockType(rawValue: Int(arc4random_uniform(6)) + 1)!
    }
}

class Block: CustomStringConvertible, Hashable {
    
    static var numRows = 0
    
    var hashValue: Int {
        return Int(row) * 10 + column
    }
    
    static func ==(lhs: Block, rhs: Block) -> Bool {
        return lhs.column == rhs.column && lhs.row == rhs.row
        
    }
    
    var description: String {
        return "\(blockType) column:\(column) row: \(row)"
    }
    
    var column: Int
    var row: Float
    let blockType: BlockType
    var sprite: SKShapeNode?
    var delete = false
    var isFalling = false
    var toRow: Float?
    var toColumn: Int?
    
    init(column: Int, row: Float, blockType: BlockType) {
        self.column = column
        self.row = row
        self.blockType = blockType
    }
}
