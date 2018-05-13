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
    
    var blockRiseSpeed:Float = 0.001
    let blockFallSpeed:Float = 0.15
    let blockSwitchSpeed:Float = 0.1
    
    var numRows = 9
    var deltaY:Float = 0.0
    var cieling: Float = 0.0
    
    var score = 0
    
    var gameOverHandler: ((Set<Block>) -> Void)?
    
    var isFalling = false
    var isSwapping = false
    
    var set: Set<Block> = []
    
    var addedVelocity: Float {
        return Float(score) * 0.00001
    }
    
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
            if Int(block.column) == column {
                if (Float(block.row) + deltaY) <= yPos && yPos < (Float(block.row) + deltaY + 1) {
                    return block
                }
            }
        }
        return nil
    }
    
    func block(atRow row: Int, column: Int) -> Block? {
        for block in set {
            if Int(block.fromColumn) == column && Int(block.row) == row {
                    return block
                }
        }
        return nil
    }

    func createInitialBlocks() -> Set<Block> {
        for row in -1..<numStartingRows - 1 {
            for column in 1..<numColumns - 1 {
                let blockType = getBlockType(column: column, row: row)
                let newBlock = Block(column: Float(column), row: Float(row), blockType: blockType)
                set.insert(newBlock)
            }
        }
        return set
    }
    
    func updateBlocks() {
        if self.isSwapping { swapBlocks() }
        else if self.isFalling { dropBlocks() }
        else {
            findHoles()
            
            //turn this into a handler?
            if let toDelete = findMatches() {
                for bloc in toDelete {
                    bloc.sprite?.removeFromParent()
                }
            }
        }
        raiseBlocks()
    }
    
    func raiseBlocks() {
        deltaY += (blockRiseSpeed + addedVelocity)
        
        if(Float(bottomRow) + deltaY >= Float(0.0)){
            createNewBlockRow()
        }
    }
    
    func swapBlocks() {
        var somethingSwapped = false
        for bloc in set {
            if bloc.isSwapping {
                if let toColumn = bloc.toColumn {
                    if bloc.fromColumn < toColumn {
                        if bloc.column >= Float(toColumn) {
                            bloc.column = Float(toColumn)
                            bloc.fromColumn = toColumn
                            bloc.isSwapping = false
                        } else {
                            bloc.column += blockSwitchSpeed
                            somethingSwapped = true
                        }
                    } else if bloc.fromColumn > toColumn {
                        if bloc.column <= Float(toColumn) {
                            bloc.column = Float(toColumn)
                            bloc.fromColumn = toColumn
                            bloc.isSwapping = false
                        } else {
                            bloc.column -= blockSwitchSpeed
                            somethingSwapped = true
                        }
                    }
                }
            }
        }
        self.isSwapping = somethingSwapped
    }
    
    func dropBlocks() {
        var somethingFell = false
        for bloc in set {
            if bloc.isFalling {
                if let row = bloc.toRow {
                    if bloc.row <= row {
                        bloc.row = row
                        bloc.isFalling = false
                    } else {
                        bloc.row -= blockFallSpeed
                        somethingFell = true
                    }
                }
            }
        }
        self.isFalling = somethingFell
    }
    
    func createNewBlockRow(){
        for column in 1...numColumns - 2 {
            let blockType = getBlockType(column: column, row: bottomRow - 1)
            let newBlock = Block(column: Float(column), row: Float(bottomRow - 1), blockType: blockType)
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
    
    func findMatches() -> Set<Block>? {
        for bloc in set {
            
            if(Float(bloc.row + 1) + deltaY >= cieling){
                if let handler = gameOverHandler {
                    handler(set)
                }
            }else if (Float(bloc.row) + deltaY >= Float(0.0)){
                
                //horizontal chain
                if let lastBlockInRow = block(atRow: Int(bloc.row), column: Int(bloc.column) - 1),
                 let blockBeforeLastInRow = block(atRow: Int(bloc.row), column: Int(bloc.column) - 2),
                     lastBlockInRow.blockType == bloc.blockType && blockBeforeLastInRow.blockType == bloc.blockType && !lastBlockInRow.isFalling && !blockBeforeLastInRow.isFalling && !bloc.isFalling && !lastBlockInRow.isSwapping && !blockBeforeLastInRow.isSwapping && !bloc.isSwapping {
                        
                            lastBlockInRow.delete = true
                            blockBeforeLastInRow.delete = true
                            bloc.delete = true
                }

                //vertical chain
                if let lastBlockInColumn = block(atRow: Int(bloc.row) + 1, column: Int(bloc.column)),
                 let blockBeforelastInColumn = block(atRow: Int(bloc.row) + 2, column: Int(bloc.column)),
                  lastBlockInColumn.blockType == bloc.blockType && blockBeforelastInColumn.blockType == bloc.blockType && !lastBlockInColumn.isFalling && !blockBeforelastInColumn.isFalling && !bloc.isFalling && !lastBlockInColumn.isSwapping && !blockBeforelastInColumn.isSwapping && !bloc.isSwapping {
                            
                            lastBlockInColumn.delete = true
                            blockBeforelastInColumn.delete = true
                            bloc.delete = true
                }
            }
        }
        let toDelete = set.filter { $0.delete }
        set = set.filter { !$0.delete }

        score += toDelete.count
        if !toDelete.isEmpty { return toDelete }
        return nil
    }
    
    func findHoles() {
        for column in 1..<numColumns - 1 {
            for row in (bottomRow ..< topRow) {
                var holeRow = row
                //1 - if hole at (column, row)
                if block(atRow: row, column: column) == nil {
                    
                    //2 - search up the column for a block
                    for lookup in (row + 1) ... topRow {
                        if let bloc = block(atRow: lookup, column: column) {
                            bloc.isFalling = true
                            self.isFalling = true
                            bloc.toRow = Float(holeRow)
                            
                            //next block up needs to end up one row up
                            holeRow += 1
                        }
                    }
                    break
                }
            }
        }
    }
    
}
