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
    var gameScene: GameScene!
    var backgroundScene: BackgroundScene!
    var level: Level!
    var speed:Float = 0.0

    
    @IBOutlet weak var blocksView: SKView!
    @IBOutlet weak var speedButton: UIButton!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var replayButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        pauseButton.isEnabled = false
        
        let skView = view as! SKView
        skView.isMultipleTouchEnabled = true
        
        gameScene = GameScene(size: blocksView.bounds.size)
        backgroundScene = BackgroundScene(size: skView.bounds.size)
        gameScene.scaleMode = .aspectFill
        level = Level()
        gameScene.level = level
        gameScene.updateHandler = handleUpdate
        level.gameOverHandler = gameOver
        
        paused = true
        skView.presentScene(backgroundScene)
        blocksView.presentScene(gameScene)
        
        speedButton.addTarget(self, action: #selector(speedUp), for: .touchDown)
        speedButton.addTarget(self, action: #selector(slowDown), for: .touchUpInside)
        speed = level.blockRiseSpeed
    }
    
    @objc func speedUp() {
        speed = level.blockRiseSpeed
        level.blockRiseSpeed = speed * 15
    }
    
    @objc func slowDown() {
        level.blockRiseSpeed = speed
    }
    
    func beginGame() {
        paused = false
        replayButton.isHidden = true
        replayButton.isEnabled = false
        pauseButton.isEnabled = true
        let newBlocks = level.createInitialBlocks()
        gameScene.addInitialSprites(for: newBlocks)
    }
    
    func handleUpdate() {
        if !paused {
            level.updateBlocks()
            gameScene.updateSprites(for: level.blocks(), with: level.deltaY)
            updateScore()
        }
    }
    
    func updateScore() {
        scoreLabel.text = "\(level.score)"
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
    
    @IBAction func pauseButton(_ sender: Any) {
        if !paused {
            paused = true
            gameScene.blocksLayer.removeFromParent()
            pauseButton.setTitle("Play", for: .normal)
        } else {
            paused = false
            gameScene.addChild(gameScene.blocksLayer)
            pauseButton.setTitle("Pause", for: .normal)
        }
    }
    
    @IBAction func replay(_ sender: Any) {
        replayButton.setTitle("Play Again?", for: .normal)
        gameScene.blocksLayer.removeAllChildren()
        level.deltaY = 0.0
        level.score = 0
        level.numRows = level.numStartingRows
        beginGame()
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait, .portraitUpsideDown]
    }
    
}
