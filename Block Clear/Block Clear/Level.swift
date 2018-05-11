//
//  Level.swift
//  Block Clear
//
//  Created by Adam Oakes on 4/26/18.
//  Copyright © 2018 Bloc. All rights reserved.
//

import Foundation
import SpriteKit

class Level {
    let numColumns = 9
    let numStartingRows = 9
    
    var numRows = 9
    var deltaY:Float = 0.0
    
    var score = 0
    
     var gameOverHandler: ((Set<Block>) -> Void)?
    
    var acceleration:Float = 0.00001
    var blockRiseSpeed:Float = 0.01
    
    var set: Set<Block> = []
    
    //fix this
    var cieling: Float = 0.0
    
    var bottomRow: Int {
        return numStartingRows - numRows - 1
    }
    
    var topRow: Int {
        return numStartingRows - 2
    }
    
    init() {
    }
    
    func columns() -> Int {
        return numColumns
    }
    
    func rows() -> Int {
        return numRows
    }
    
    func blocks() -> Set<Block> {
        return set
    }
    
    func block(atYPos yPos: Float, column: Int) -> Block? {
        for block in set {
            if block.column == column {
                if (Float(block.row) + deltaY) <= yPos && yPos < (Float(block.row) + deltaY + 1) {
                    return block
                }
            }
        }
        return nil
    }
    
    func block(atRow row: Int, column: Int) -> Block? {
        for block in set {
            if block.column == column && block.row == row {
                    return block
                }
        }
        return nil
    }

    func createInitialBlocks() -> Set<Block> {
        for row in -1..<numRows - 1 {
            for column in 1..<numColumns - 1 {
                let blockType = getBlockType(column: column, row: row)
                let newBlock = Block(column: column, row: row, blockType: blockType)
                set.insert(newBlock)
            }
        }
        return set
    }
    
    //should this be in controller?
    func updateBlockPositions() {
        deltaY += blockRiseSpeed
//        blockRiseSpeed += acceleration
        
        if(Float(bottomRow) + deltaY >= Float(0.0)){
            createNewBlockRow()
        }
    }
    
    func createNewBlockRow(){
        for column in 1...numColumns - 2 {
            let blockType = getBlockType(column: column, row: bottomRow - 1)
            let newBlock = Block(column: column, row: bottomRow - 1, blockType: blockType)
            set.insert(newBlock)
        }
        numRows += 1
    }
    
    func getBlockType(column: Int, row: Int) -> BlockType {
        var blockType = BlockType.random()
        var badTypeForRow: BlockType?
        var badTypeForColumn: BlockType?
        
        //check for horizontal conflicts
        if let lastBlockInRow = block(atRow: row, column: column - 1),
            let blockBeforeLastInRow = block(atRow: row, column: column - 2){
            if lastBlockInRow.blockType == blockType && blockBeforeLastInRow.blockType == blockType {
                badTypeForRow = blockType
            }
        }
        
        //check for vertical conflicts
        if let lastBlockInColumn = block(atRow: row + 1 , column: column),
            let blockBeforelastInColumn = block(atRow: row + 2, column: column) {
            if lastBlockInColumn.blockType == blockType && blockBeforelastInColumn.blockType == blockType {
                badTypeForColumn = blockType
            }
        }
        
        while blockType == badTypeForColumn || blockType == badTypeForRow {
            blockType = BlockType.random()
        }
        return blockType
    }
    
    func endGame(){
        blockRiseSpeed = 0.0
        if let handler = gameOverHandler {
            handler(set)
        }
    }
    
    func performSwap(_ swap: Swap){
        if let toColumn = swap.blockB?.column {
            swap.blockB!.column = swap.blockA.column
            swap.blockA.column = toColumn
        } else if let toColumn = swap.toColumn {
            swap.blockA.column = toColumn
        }
    }
    
    //deletes all matched blocks from the model
    func findMatches() -> Set<Block>? {
        for bloc in set {
            
            if(Float(bloc.row + 1) + deltaY >= cieling){
                endGame()
            }else if (Float(bloc.row) + deltaY >= Float(0.0)){
                
                //horizontal chain
                if let lastBlockInRow = block(atRow: bloc.row, column: bloc.column - 1),
                 let blockBeforeLastInRow = block(atRow: bloc.row, column: bloc.column - 2){
                    if lastBlockInRow.blockType == bloc.blockType && blockBeforeLastInRow.blockType == bloc.blockType {
                        
                        lastBlockInRow.delete = true
                        blockBeforeLastInRow.delete = true
                        bloc.delete = true
                    }
                }

                //vertical chain
                if let lastBlockInColumn = block(atRow: bloc.row + 1, column: bloc.column),
                 let blockBeforelastInColumn = block(atRow: bloc.row + 2, column: bloc.column) {
                    if lastBlockInColumn.blockType == bloc.blockType && blockBeforelastInColumn.blockType == bloc.blockType {
                        
                        lastBlockInColumn.delete = true
                        blockBeforelastInColumn.delete = true
                        bloc.delete = true
                    }
                }
                
            }
        }
        let toDelete = set.filter { $0.delete }
        set = set.filter { !$0.delete }

        score += toDelete.count
        if !toDelete.isEmpty { return toDelete }
        return nil
    }
    
    func findHoles() -> [Fall]? {
        var falls = [Fall]()
        
        for column in 1..<numColumns - 1 {
            for row in (bottomRow ..< topRow) {
                var holeRow = row
                //1 - if hole at (column, row)
                if block(atRow: row, column: column) == nil {
                    
                    //2 - search up the column for a block
                    for lookup in (row + 1) ... topRow {
                        if let bloc = block(atRow: lookup, column: column) {
                            let fall = Fall(block: bloc, toRow: holeRow)
                            falls.append(fall)
                            holeRow += 1
                        }
                    }
                    break
                }
            }
        }
        if falls.count != 0 { return falls }
        return nil
    }
    
}
