//
//  SCNNodeExtension.swift
//  SketchMaze
//
//  Created by Kyoya Yamaguchi on 2023/04/14.
//

import SpriteKit

extension SKNode {
    func setup(with nodeType: NodeType) {
        if nodeType != .item {
            name = nodeType.name
        }
        physicsBody?.categoryBitMask = nodeType.categoryBitMask
        physicsBody?.collisionBitMask = nodeType.collisionBitMask
        physicsBody?.contactTestBitMask = nodeType.contactTestBitMask
        physicsBody?.restitution = nodeType.restitution
    }
}
