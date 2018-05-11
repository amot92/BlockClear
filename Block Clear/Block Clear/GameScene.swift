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
    var selectedBlock: Block?
    
    var level: Level!
    
    let blocksLayer = SKNode()
    
    var spriteSize: CGSize?
    
    let tileNode = SKSpriteNode(imageNamed: "Tile")
    
    var brickNode:SKShapeNode?
    
    var switchHandler: ((Swap) -> Void)?
    var updateHandler: (() -> Void)?
    var moveHandler: ((Block, Int) -> Void)?
    
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
        //need to do this in controller
        
        self.spriteSize = CGSize(width: blockSize, height: blockSize)
        self.brickNode = SKShapeNode.init(rectOf: CGSize.init(width: blockSize, height: blockSize), cornerRadius: blockSize * 0.3)
        
        let playSize = CGSize(width: blockSize * CGFloat(level.columns() - 2), height: size.height * 0.9)
        let position = CGPoint(x: size.width/2, y: playSize.height/2)
        
       
        tileNode.size = playSize
        tileNode.position = position
        
        addChild(tileNode)
        addChild(blocksLayer)

        level.cieling = Float(tileNode.size.height / blockSize)
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
    
    func animateFalls(falls: [Fall]){
        for fall in falls {
            let realDest = pointFor(yPos: Float(fall.toRow) + level.deltaY, column: fall.block.column)
            fall.block.sprite?.run(SKAction.move(to: realDest!, duration: 0.3), completion: {
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
    
        if let handler = switchHandler,
         let swap = swap {
            handler(swap)
        }
    }
    

//////////////// USER INPUT HANDLING -- NEED TO USE GCD TO SEPERATE THREADS?? /////////////////////

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

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}


