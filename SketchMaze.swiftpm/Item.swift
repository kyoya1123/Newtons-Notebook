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
    case mechanic
    case gravity
    case sound
    case electricity
    case atom
    case astronomy

    var name: String {
        rawValue
    }

    var displayName: String {
        switch self {
        case .fluid:
            return "Fluid"
        case .magnet:
            return "Magnetic Force"
        case .mechanic:
            return "Mechanic"
        case .gravity:
            return "Gravity"
        case .sound:
            return "Sound"
        case .electricity:
            return "Electricity"
        case .atom:
            return "Atom"
        case .astronomy:
            return "Astronomy"
        }
    }

    var description: String {
        switch self {
        case .fluid:
            return "Fluid description"
        case .magnet:
            return "Magnetic Force description"
        case .mechanic:
            return "Mechanic description"
        case .gravity:
            return "Gravity description"
        case .sound:
            return "Sound description"
        case .electricity:
            return "Electricity description"
        case .atom:
            return "Atom description"
        case .astronomy:
            return "Astronomy description"
        }
    }
}
