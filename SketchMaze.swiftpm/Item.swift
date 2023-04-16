//
//  Item.swift
//  SketchMaze
//
//  Created by Kyoya Yamaguchi on 2023/04/17.
//

import Foundation

enum Item: String, CaseIterable {
    case fluid
    case magnet
    case wave
    case gravity
    case sound
    case spring
    case electricity
    case atom
    case astronomy
    case pendulum

    var name: String {
        rawValue
    }
}
