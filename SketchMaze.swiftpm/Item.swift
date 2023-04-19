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
    case wave
    case electricity
    case atom
    case astronomy

    var name: String {
        rawValue
    }

    var displayName: String {
        switch self {
        case .fluid:
            return "Fluids"
        case .magnet:
            return "Magnetism"
        case .mechanic:
            return "Mechanics"
        case .gravity:
            return "Gravity"
        case .wave:
            return "Waves"
        case .electricity:
            return "Electricity"
        case .atom:
            return "Atoms"
        case .astronomy:
            return "Astronomy"
        }
    }

    var description: String {
        switch self {
        case .fluid:
            return "Fluids, like water or air, can flow and change their shape to fill up any container. They are an important part of physics that studies how liquids and gases behave."
        case .magnet:
            return "Have you ever played with a pair of magnets and felt them attract or repel each other? Magnetism is the force behind that, and it's a fascinating area of physics that deals with the behavior of magnets and magnetic materials."
        case .mechanic:
            return "When you ride a bicycle, mechanics is the part of physics that explains how the wheels, pedals, and gears work together to make you move easily. It's all about understanding motion and the forces involved."
        case .gravity:
            return " Imagine dropping a ball, and it falls to the ground. Gravity is the force that pulls the ball and everything else towards the Earth. It's just one aspect of physics that how things interact."
        case .wave:
            return "Imagine the sound you hear when someone plays a guitar or the way your radio receives signals. Waves are a way that energy moves through things like sound, electromagnetic waves (including radio waves), and light. They are an important part of physics that helps us understand how energy travels and interacts with our world."
        case .electricity:
            return "When you turn on a light or charge your iPhone, electricity powers these devices. This aspect of physics explores the movement of tiny particles called electrons and how they create the energy we use every day."
        case .atom:
            return "Everything you see and touch is made up of tiny building blocks called atoms. They are part of the branch of physics called atomic physics, which helps us understand how these tiny particles come together to create the world around us."
        case .astronomy:
            return "When you look at the stars in the night sky, you're seeing just a tiny part of our vast universe. Astronomy is the branch of physics that studies outer space and celestial objects, helping us learn more about the cosmos."
        }
    }

    static var firstFourItems: [Item] {
        [.astronomy, .gravity, .magnet, .wave]
    }

    static var lastFourItems: [Item] {
        [.mechanic, .fluid, .atom, .electricity]
    }
}
