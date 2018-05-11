//
//  GameScene.swift
//  Block Clear
//
//  Created by Adam Oakes on 4/26/18.
//  Copyright © 2018 Bloc. All rights reserved.
//

import SpriteKit
import GameplayKit

// The scene draws the block sprites, and handles swipes.
class GameScene: SKScene {
    var level: Level!
    let blocksLayer = SKNode()
    
    var spriteSize: CGSize?
    
    let tileNode = SKSpriteNode(imageNamed: "Tile")
    var brickNode:SKShapeNode?
    
    var swapHandler: ((Swap) -> Void)?
    var updateHandler: (() -> Void)?
    
    var selectedBlock: Block?
    
    var swapping = false
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder) is not used in this app")
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        self.name = "scene"
        blocksLayer.name = "blocksLayer"
        
        let background = SKSpriteNode(imageNamed: "BlockBackground")
        background.size = size
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(background)
    }
    
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.black
        let blockSize = size.width / CGFloat(level.columns())
        
        let playSize = CGSize(width: blockSize * CGFloat(level.columns() - 2), height: size.height * 0.9)
        let position = CGPoint(x: size.width/2, y: playSize.height/2)
       
        tileNode.size = playSize
        tileNode.position = position
        addChild(tileNode)
        level.cieling = Float(tileNode.size.height / blockSize)
        
        spriteSize = CGSize(width: blockSize, height: blockSize)
        brickNode = SKShapeNode.init(rectOf: CGSize.init(width: blockSize, height: blockSize), cornerRadius: blockSize * 0.3)
        addChild(blocksLayer)
    }
    
    //convert row/column cordinates to screen coorinates
    func pointFor(yPos: Float, column: Int) -> CGPoint? {
        if let size = spriteSize?.width {
            return CGPoint(
                x: CGFloat(column) * size + size / 2,
                y: CGFloat(yPos) * size + size / 2)
        }
        return nil
    }
    
    //convert screen coordinates to column/row coordinates
    private func convertPoint(_ point: CGPoint) -> (success: Bool, column: Int, yPos: Float) {
        if point.x >= (spriteSize?.width)! && point.x < CGFloat(level.numColumns - 1) * (spriteSize?.width)! &&
            point.y >= 0 && point.y < CGFloat(level.numRows) * (spriteSize?.height)! {
            return (true, Int(point.x / (spriteSize?.width)!), Float(point.y / (spriteSize?.height)!))
        } else {
            return (false, 0, 0)  // invalid location
        }
    }
    
    func addInitialSprites(for blocks: Set<Block>) {
        for block in blocks {
            addSprite(for: block, with: 0.0)
        }
    }
    
    private func addSprite(for block: Block, with deltaY: Float) {
        if let sprite = self.brickNode?.copy() as! SKShapeNode? {
            sprite.strokeColor = SKColor.black
            sprite.fillColor = block.blockType.spriteColor
            sprite.lineWidth = 5
            sprite.position = pointFor(yPos: Float(block.row) + deltaY, column: block.column)!
            blocksLayer.addChild(sprite)
            block.sprite = sprite
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
            if let handler = self.updateHandler {
                handler()
            }
    }
    
    func updateSprites(for blocks: Set<Block>, with deltaY: Float) {
        for block in blocks {
            if(block.sprite == nil){
                self.addSprite(for: block, with: deltaY)
                
            } else if !block.isFalling {
                let realDest = self.pointFor(yPos: Float(block.row) + deltaY, column: block.column)
                block.sprite?.run(SKAction.move(to: realDest!, duration: 0.0))
            }
        }
        
    }
    
    func animateSwitch() {
        selectedBlock?.sprite?.glowWidth = 0
        selectedBlock = nil
    }
    
    func animateSwitch(_ swap: Swap) {
        selectedBlock?.sprite?.glowWidth = 0
        selectedBlock = nil
        
        swapping = true
        swap.blockA.isFalling = true
        var columnForA: Int?
        
        if let toColumnForA = swap.blockB?.column {
            columnForA = toColumnForA
            swap.blockB!.isFalling = true
            let colForB = swap.blockA.column
            let destForB = pointFor(yPos: Float(swap.blockB!.row) + level.deltaY, column: colForB)
            swap.blockB!.sprite?.run(SKAction.move(to: destForB!, duration: 0.1), completion: {
                swap.blockB!.column = colForB
                swap.blockB!.isFalling = false
            })
            
        } else if let toColumnForA = swap.toColumn {
            columnForA = toColumnForA
        }
        
        let destForA = pointFor(yPos: Float(swap.blockA.row) + level.deltaY, column: columnForA!)

        swap.blockA.sprite?.run(SKAction.move(to: destForA!, duration: 0.1), completion: {
            swap.blockA.column = columnForA!
            swap.blockA.isFalling = false
            self.swapping = false
        })
    }
    
    func animateFalls(falls: [Fall]){
        for fall in falls {
            let realDest = pointFor(yPos: Float(fall.toRow) + level.deltaY, column: fall.block.column)
            let duration = Double(fall.block.row - fall.toRow) * 0.1
            fall.block.sprite?.run(SKAction.move(to: realDest!, duration: duration), completion: {
                fall.block.row = fall.toRow
                fall.block.isFalling = false
            })
        }
    }
    
    func removeSprites(for blocks: Set<Block>){
        for block in blocks {
            block.sprite?.removeFromParent()
        }
    }
    
    private func trySwap(horizontalDelta: Int) {
        var swap: Swap?
        let toColumn = selectedBlock!.column + horizontalDelta
        if let toBlock = level.block(atRow: selectedBlock!.row, column: toColumn) {
            swap = Swap(blockA: selectedBlock!, blockB: toBlock)
        } else if (toColumn >= 1 && toColumn < level.numColumns - 1) {
            swap = Swap(blockA: selectedBlock!, toColumn: toColumn)
        }
    
        if let handler = swapHandler,
         let swap = swap {
            handler(swap)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        selectedBlock?.sprite?.glowWidth = 0
        if let touch = touches.first {
            let positionInScene = touch.location(in: self)
            let convertedPoint = convertPoint(positionInScene)
            
            if let block = level.block(atYPos: convertedPoint.yPos, column: convertedPoint.column){
                block.sprite!.glowWidth = 5
                selectedBlock = block
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard selectedBlock != nil else { return }
        
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let convertedPoint = convertPoint(location)
        
        if convertedPoint.success {
            var horizontalDelta = 0
            if convertedPoint.column < selectedBlock!.column {
                horizontalDelta = -1
            } else if convertedPoint.column > selectedBlock!.column {
                horizontalDelta = 1
            }
            
            if horizontalDelta != 0  {
                trySwap(horizontalDelta: horizontalDelta)
           }
        }
    }
}


