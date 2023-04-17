//
//  NodeType.swift
//  SketchMaze
//
//  Created by Kyoya Yamaguchi on 2023/04/14.
//

import Foundation
import SpriteKit

enum NodeType: UInt32 {
    case ball = 1
    case line = 2
    case basket = 4
    case fire = 8
    case item = 16

    var name: String {
        switch self {
        case .ball:
            return "ball"
        case .line:
            return "line"
        case .basket:
            return "basket"
        case .fire:
            return "fire"
        case .item:
            return ""
        }
    }

    var categoryBitMask: UInt32 {
        return rawValue
    }

    var collisionBitMask: UInt32 {
        switch self {
        case .ball:
            return NodeType.line.categoryBitMask
        case .line:
            return NodeType.ball.categoryBitMask
        case .fire, .basket, .item:
            return 0
        }
    }

    var contactTestBitMask: UInt32 {
        switch self {
        case .ball:
            return NodeType.line.categoryBitMask | NodeType.fire.categoryBitMask | NodeType.basket.categoryBitMask
        case .line, .basket, .fire, .item:
            return NodeType.ball.categoryBitMask
        }
    }

    var restitution: CGFloat {
        switch self {
        case .line:
            return 1.0
        case .ball:
            return 1.0
        default:
            return 0.2
        }
    }
}
