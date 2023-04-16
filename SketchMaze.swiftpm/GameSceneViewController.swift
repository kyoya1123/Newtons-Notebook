//
//  ViewController.swift
//  SketchPuzzle
//
//  Created by Kyoya Yamaguchi on 2023/04/12.
//

import AVFoundation
import UIKit
import PencilKit
import SpriteKit

class GameSceneViewController: UIViewController, UIPencilInteractionDelegate {

    var coordinator: GameSceneViewRepresentable.Coordinator?

    @IBOutlet var canvasView: PKCanvasView!
    @IBOutlet var skView: SKView!
    var currentStage: Stage = .instruction
    private var scene: SKScene!

    var pencilAudioPlayer: AVAudioPlayer!
    var itemAudioPlayer: AVAudioPlayer!


    let blackInk = PKInkingTool(ink: PKInk(.pencil, color: .black), width: 5)
    

    var collectedItems = [Item]()
    var newlyCollectedItems = [Item]()
    var ballNode: SKSpriteNode!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSpriteKitView()
        setupCanvasView()
        setupAudioPlayer()
        setupScene(stage: .instruction)
    }
    
    func setupAudioPlayer() {
        if let pencilSoundDataAsset = NSDataAsset(name: "drawingSound") {
            do {
                pencilAudioPlayer = try AVAudioPlayer(data: pencilSoundDataAsset.data)
                pencilAudioPlayer.numberOfLoops = -1
                pencilAudioPlayer.volume = 0.05
                pencilAudioPlayer.prepareToPlay()
            } catch {
                print("Error loading audio file: \(error.localizedDescription)")
            }
        }

        if let itemSoundDataAsset = NSDataAsset(name: "itemSound") {
            do {
                itemAudioPlayer = try AVAudioPlayer(data: itemSoundDataAsset.data)
                itemAudioPlayer.volume = 0.2
                itemAudioPlayer.prepareToPlay()
            } catch {
                print("Error loading audio file: \(error.localizedDescription)")
            }
        }
    }
    
    private func setupCanvasView() {
        canvasView = PKCanvasView(frame: view.bounds)
        canvasView.backgroundColor = .clear
        canvasView.delegate = self
        canvasView.tool = blackInk
        //TODO: pencilOnly
        canvasView.drawingPolicy = .anyInput
        let pencilInteraction = UIPencilInteraction()
        pencilInteraction.delegate = self
        view.addInteraction(pencilInteraction)
        view.addSubview(canvasView)
    }

    private func setupSpriteKitView() {
        skView = SKView(frame: view.bounds)
        skView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        skView.preferredFramesPerSecond = 120
        skView.ignoresSiblingOrder = true
        view.addSubview(skView)
    }

    private func setupScene(stage: Stage, isRetry: Bool = false) {
        if scene != nil {
            scene.removeFromParent()
        }
        currentStage = stage
        scene = stage.scene
        scene.size = view.bounds.size
        scene.scaleMode = .aspectFit
        scene.physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        scene.delegate = self
        scene.physicsWorld.contactDelegate = self
        scene.childNode(withName: "background")?.zPosition = -1
        [NodeType.fire, NodeType.goal].forEach { nodeType in
            scene.enumerateChildNodes(withName: nodeType.name) { node, _ in
                guard let texture = (node as? SKSpriteNode)?.texture else { return }
                node.physicsBody = SKPhysicsBody(texture: texture, size: node.frame.size)
                node.physicsBody?.affectedByGravity = false
                node.physicsBody?.isDynamic = false
                node.zPosition = 1
                node.setup(with: nodeType)
            }
        }
        Item.allCases.forEach { item in
            scene.enumerateChildNodes(withName: item.name) { node, _ in
                guard let texture = (node as? SKSpriteNode)?.texture else { return }
                node.physicsBody = SKPhysicsBody(texture: texture, size: node.frame.size)
                node.physicsBody?.affectedByGravity = false
                node.physicsBody?.isDynamic = false
                node.zPosition = 1
                node.setup(with: .item)
            }
        }
        if currentStage == .instruction || isRetry {
            skView.presentScene(scene)
        } else {
            skView.presentScene(scene, transition: .push(with: .left, duration: 2))
        }
    }

    func addBall() {
        guard ballNode == nil else { return }
        let location = CGPoint(x: 200, y: 0)
        let ball = SKSpriteNode(texture: SKTexture(imageNamed: NodeType.ball.name), size: CGSize(width: 40, height: 40))
        ball.position = location
        ball.physicsBody = SKPhysicsBody(circleOfRadius: 20)
        ball.setup(with: .ball)
        ball.zPosition = 2
        ballNode = ball
        scene.addChild(ballNode)
    }

    func retry() {
        setupScene(stage: currentStage, isRetry: true)
        ballNode = nil
        newlyCollectedItems = []
        print("Collected Items: \(collectedItems)")
        canvasView.drawing = PKDrawing()
    }
}

extension GameSceneViewController: SKPhysicsContactDelegate, SKSceneDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node, let nodeB = contact.bodyB.node else { return }
        switch nodeA.name {
        case NodeType.fire.name:
            missedBall()
        case NodeType.goal.name:
            nodeB.removeFromParent()
            goal()
        default:
            if Item.allCases.map({ $0.name }).contains(nodeA.name) {
                getItem(node: nodeA)
            }
        }
    }

    func update(_ currentTime: TimeInterval, for scene: SKScene) {
        if isBallOutsideScreen {
            missedBall()
        }
    }

    var isBallOutsideScreen: Bool {
        if ballNode == nil { return false }
        let sceneSize = scene.size
        let ballPosition = ballNode.position
        let threshold: CGFloat = 20
        return ballPosition.x < -threshold || ballPosition.x > sceneSize.width + threshold ||
        ballPosition.y > threshold || ballPosition.y < -(sceneSize.height + threshold)
    }

    func missedBall() {
        if currentStage == .instruction {
            goal()
        } else {
            removeBall()
            print("MISS")
            retry()
        }
    }

    func removeBall() {
        let ballNode = scene.childNode(withName: NodeType.ball.name)
        ballNode?.removeFromParent()
        self.ballNode = nil
    }

    func getItem(node: SKNode) {
        node.removeFromParent()
        guard let item = Item(rawValue: node.name ?? "") else { return }
        newlyCollectedItems.append(item)
        print("Collected Items: \(collectedItems)")
        DispatchQueue.global(qos: .userInitiated).async {
            self.itemAudioPlayer.currentTime = 0
            self.itemAudioPlayer.play()
        }
    }

    func goal() {
        coordinator?.goal()
        removeBall()
        collectedItems += newlyCollectedItems
        newlyCollectedItems = []
        guard let nextStage = currentStage.next else {
            //ending
            return
        }
        setupScene(stage: nextStage)
    }
}

extension GameSceneViewController: PKCanvasViewDelegate {
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        let lastStrokeIndex = canvasView.drawing.strokes.count - 1
        guard lastStrokeIndex >= 0 else { return }

        let canvasViewBounds = canvasView.bounds

        DispatchQueue.global(qos: .userInitiated).async {
            let image = canvasView.drawing.image(from: canvasViewBounds, scale: UIScreen.main.scale)
            let texture = SKTexture(image: image)
            let lineNode = SKSpriteNode(texture: texture)
            lineNode.position = CGPoint(x: self.scene.frame.midX, y: self.scene.frame.midY)
            lineNode.size = canvasViewBounds.size
            lineNode.physicsBody = SKPhysicsBody(texture: texture, size: lineNode.size)
            lineNode.physicsBody?.isDynamic = false
            lineNode.physicsBody?.affectedByGravity = false
            lineNode.setup(with: .line)
            lineNode.zPosition = 1

            DispatchQueue.main.async {
                self.scene.addChild(lineNode)
                var updatedDrawing = canvasView.drawing
                updatedDrawing.strokes.removeAll()
                canvasView.drawing = updatedDrawing
                self.scene.physicsWorld.speed = 1
            }
        }
    }

    func canvasViewDidEndUsingTool(_ canvasView: PKCanvasView) {
        pencilAudioPlayer.stop()
    }

    func canvasViewDidBeginUsingTool(_ canvasView: PKCanvasView) {
        self.scene.physicsWorld.speed = 0.3
        DispatchQueue.global(qos: .userInitiated).async {
            self.pencilAudioPlayer.play()
        }
    }
}
