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
    
    @IBOutlet weak var replayButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        replayButton.removeFromSuperview()
        
        let skView = view as! SKView
        skView.isMultipleTouchEnabled = true
        
        scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .aspectFill
        level = Level()
        scene.level = level
        level.gameOverHandler = gameOver
        
        scene.switchHandler = handleSwitch
        scene.updateHandler = handleUpdate
        
        skView.presentScene(scene)
        beginGame()
    }
    
    func gameOver(_ set: Set<Block>){
        for bloc in set {
            bloc.sprite?.fillColor = SKColor.white
        }
        view.isUserInteractionEnabled = false
        
//        let button = UIButton()
//        button.setTitle("Play Again?", for: .normal)
//        button.set
//        button.setTitleColor(UIColor.blue, for: .normal)
//        button.frame = CGRect(x: 15, y: -50, width: 300, height: 500)
//        button.addTarget(self, action: Selector(("pressed")), for: .touchUpInside)
//
//        self.view.addSubview(button)
//    }
//
//    func pressed(sender: UIButton!) {
//        let alertView = UIAlertView()
//        alertView.addButton(withTitle: "Ok")
//        alertView.title = "title"
//        alertView.message = "message"
//        alertView.show()
//        self.view.addSubview(replayButton)
    }
    
    func handleSwitch(_ swap: Swap) {
        if !paused {
            level.performSwap(swap)
            scene.animateSwitch()
        }
    }
    
    func handleUpdate() {
        if !paused {
            DispatchQueue.main.async { self.raiseBlocks() }
            deleteBlocks()
            DispatchQueue.global().async { self.fillHoles() }
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
