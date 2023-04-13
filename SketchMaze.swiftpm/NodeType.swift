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
    case goal = 4
    case fire = 8
    case item = 16

    var name: String {
        switch self {
        case .ball:
            return "ball"
        case .line:
            return "line"
        case .goal:
            return "goal"
        case .fire:
            return "fire"
        case .item:
            return "item"
        }
    }

    var categoryBitMask: UInt32 {
        return self.rawValue
    }

    var collisionBitMask: UInt32 {
        switch self {
        case .ball:
            return NodeType.line.categoryBitMask
        case .line:
            return NodeType.ball.categoryBitMask
        case .fire, .goal, .item:
            return 0
        }
    }

    var contactTestBitMask: UInt32 {
        switch self {
        case .ball:
            return NodeType.line.categoryBitMask | NodeType.fire.categoryBitMask | NodeType.goal.categoryBitMask
        case .line, .goal, .fire, .item:
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
