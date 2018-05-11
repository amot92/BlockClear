//
//  GameViewController.swift
//  Block Clear
//
//  Created by Adam Oakes on 4/26/18.
//  Copyright © 2018 Bloc. All rights reserved.
//

import UIKit
import SpriteKit
import AVFoundation

class GameViewController: UIViewController {
    
    var paused = false
    var scene: GameScene!
    var level: Level!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBAction func pauseButton(_ sender: Any) {
        if !paused {
            paused = true
            scene.blocksLayer.removeFromParent()
        } else {
            paused = false
            scene.addChild(scene.blocksLayer)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let skView = view as! SKView
        skView.isMultipleTouchEnabled = true
        
        scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .aspectFill
        level = Level()
        scene.level = level
        level.gameOverHandler = gameOver
        
        scene.switchHandler = handleSwitch
        scene.moveHandler = handleMove
        scene.updateHandler = handleUpdate
        
        skView.presentScene(scene)
        beginGame()
    }
    
    func gameOver(_ set: Set<Block>){
        for bloc in set {
            bloc.sprite?.fillColor = SKColor.white
        }
        view.isUserInteractionEnabled = false
    }
    
    func handleUpdate() {
        if !paused {
            raiseBlocks()
            deleteBlocks()
            fillHoles()
            showScore()
        }
    }
    
    func showScore() {
        scoreLabel.text = "\(level.score)"
    }
    
    func raiseBlocks() {
        level.updateBlockPositions()
        scene.updateSprites(for: level.blocks(), with: level.deltaY)
    }
    
    func deleteBlocks() {
        if let toDelete = level.findMatches() {
            scene.removeSprites(for: toDelete)
        }
    }
    
    func fillHoles() {
        if let toFall = level.findHoles() {
            scene.animateFalls(falls: toFall)
        }
    }
    
    func handleSwitch(_ swap: Swap) {
        if !paused {
            level.performSwap(swap)
            scene.animateSwitch()
        }
    }
    
    //moves a block to an empty space
    func handleMove(_ block: Block, to column: Int) {
        level.move(block, to: column)
        scene.animateSwitch()
    }
    
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    func beginGame() {
        let newBlocks = level.createInitialBlocks()
        scene.addInitialSprites(for: newBlocks)
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait, .portraitUpsideDown]
    }
    
}
