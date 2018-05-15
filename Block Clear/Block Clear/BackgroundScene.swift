//
//  BackgroundScene.swift
//  Block Clear
//
//  Created by Adam Oakes on 5/14/18.
//  Copyright © 2018 Bloc. All rights reserved.
//
import SpriteKit
import GameplayKit
import UIKit

class BackgroundScene: SKScene {
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder) is not used in this app")
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        
        let background = SKSpriteNode(imageNamed: "BlockBackground")
        background.size = size
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(background)
    }

}
