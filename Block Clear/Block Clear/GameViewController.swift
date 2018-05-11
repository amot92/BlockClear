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
    var swap: Swap? = nil
    
    @IBOutlet weak var scoreLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        pauseButton.isEnabled = false
        
        let skView = view as! SKView
        skView.isMultipleTouchEnabled = true
        
        scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .aspectFill
        level = Level()
        scene.level = level
        level.gameOverHandler = gameOver
        
        scene.swapHandler = setSwap
        scene.updateHandler = handleUpdate
        paused = true
        skView.presentScene(scene)
    }
    
    @IBOutlet weak var pauseButton: UIButton!
    @IBAction func pauseButton(_ sender: Any) {
        if !paused {
            paused = true
            scene.blocksLayer.removeFromParent()
            pauseButton.setTitle("Play", for: .normal)
        } else {
            paused = false
            scene.addChild(scene.blocksLayer)
            pauseButton.setTitle("Pause", for: .normal)
        }
    }
    
    @IBOutlet weak var replayButton: UIButton!
    @IBAction func replay(_ sender: Any) {
        replayButton.setTitle("Play Again?", for: .normal)
        scene.blocksLayer.removeAllChildren()
        level.deltaY = 0.0
        level.score = 0
        level.numRows = level.numStartingRows
        beginGame()
    }
    
    func gameOver(_ set: Set<Block>){
        paused = true
        pauseButton.isEnabled = false
        for bloc in set {
            bloc.sprite?.fillColor = SKColor.white
        }
        replayButton.isHidden = false
        replayButton.isEnabled = true
        level.set = Set<Block>()
    }
    
    func setSwap(_ swap: Swap) {
            self.swap = swap
    }
    
    func handleUpdate() {
        if !paused {
            

            DispatchQueue.main.async { self.raiseBlocks() }
            deleteBlocks()
            DispatchQueue.main.async { self.fillHoles() }
            DispatchQueue.main.async { self.pollSwap() }
            showScore()
        }
    }
    
    func pollSwap() {
        if let swap = self.swap,
            !paused {
//            self.scene.animateSwitch(swap)
            self.scene.animateSwitch()
            self.level.performSwap(swap)
            self.swap = nil
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
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    func beginGame() {
        paused = false
        replayButton.isHidden = true
        replayButton.isEnabled = false
        pauseButton.isEnabled = true
        let newBlocks = level.createInitialBlocks()
        scene.addInitialSprites(for: newBlocks)
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait, .portraitUpsideDown]
    }
    
}
