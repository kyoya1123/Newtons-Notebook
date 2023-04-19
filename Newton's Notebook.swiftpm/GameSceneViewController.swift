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

    var canvasView: PKCanvasView!
    var skView: SKView!
    var currentStage: Stage = .opening
    var scene: SKScene!

    var pencilAudioPlayer: AVAudioPlayer!
    var itemAudioPlayer: AVAudioPlayer!
    var goalAudioPlayer: AVAudioPlayer!
    var bounceAudioPlayer: AVAudioPlayer!


    let blackInk = PKInkingTool(ink: PKInk(.pen, color: .gray), width: 3)
    

    var collectedItems = [Item]()
    var newlyCollectedItems = [Item]()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSpriteKitView()
        setupCanvasView()
        setupAudioPlayer()
        setupScene(stage: .opening)
    }

    func setupAudioPlayer() {
        if let pencilSoundDataAsset = NSDataAsset(name: "drawingSound") {
            do {
                pencilAudioPlayer = try AVAudioPlayer(data: pencilSoundDataAsset.data)
                pencilAudioPlayer.numberOfLoops = -1
                pencilAudioPlayer.volume = 0.2
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

        if let goalSoundDataAsset = NSDataAsset(name: "goalSound") {
            do {
                goalAudioPlayer = try AVAudioPlayer(data: goalSoundDataAsset.data)
                goalAudioPlayer.volume = 0.2
                goalAudioPlayer.prepareToPlay()
            } catch {
                print("Error loading audio file: \(error.localizedDescription)")
            }
        }

        if let  bounceSoundDataAsset = NSDataAsset(name: "bounceSound") {
            do {
                bounceAudioPlayer = try AVAudioPlayer(data: bounceSoundDataAsset.data)
                bounceAudioPlayer.volume = 0.2
                bounceAudioPlayer.prepareToPlay()
            } catch {
                print("Error loading audio file: \(error.localizedDescription)")
            }
        }
    }
    
    func setupCanvasView() {
        canvasView = PKCanvasView(frame: view.bounds)
        canvasView.backgroundColor = .clear
        canvasView.delegate = self
        canvasView.tool = blackInk
        //TODO: pencilOnly
        canvasView.drawingPolicy = .anyInput
        canvasView.isUserInteractionEnabled = false
        let pencilInteraction = UIPencilInteraction()
        pencilInteraction.delegate = self
        view.addInteraction(pencilInteraction)
        view.addSubview(canvasView)
    }

    func setupSpriteKitView() {
        skView = SKView(frame: view.bounds)
        print(view.frame)
        skView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        skView.preferredFramesPerSecond = 120
        skView.ignoresSiblingOrder = true
        view.addSubview(skView)
    }

    func setupScene(stage: Stage, isRetry: Bool = false) {
        if scene != nil {
            scene.removeFromParent()
        }
        currentStage = stage
        scene = stage.scene(screenFrame: UIScreen.main.nativeBounds)
        print(UIScreen.main.nativeBounds)
        scene.size = view.bounds.size
        scene.scaleMode = .aspectFit
        scene.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        scene.delegate = self
        scene.physicsWorld.contactDelegate = self
        scene.childNode(withName: "background")?.zPosition = -1
        [NodeType.fire, NodeType.basket].forEach { nodeType in
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
                let fadeInAction = SKAction.fadeAlpha(to: 0.3, duration: 1.0)
                let fadeOutAction = SKAction.fadeAlpha(to: 1.0, duration: 1.0)
                let fadeSequence = SKAction.sequence([fadeInAction, fadeOutAction])
                let repeatFadeAction = SKAction.repeat(fadeSequence, count: 1)
                node.run(repeatFadeAction)

            }
        }
        setupBall()
        if stage == .opening || isRetry {
            skView.presentScene(scene)
        } else {
            skView.presentScene(scene, transition: .push(with: .up, duration: 2))
            coordinator?.setPlayButtonHidden(hidden: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.canvasView.isUserInteractionEnabled = true
                self.coordinator?.setPlayButtonHidden(hidden: false)
            }
        }
    }

    func setupBall() {
        guard let ballNode = scene.childNode(withName: NodeType.ball.name) else { return }
        ballNode.physicsBody = SKPhysicsBody(circleOfRadius: 20)
        ballNode.physicsBody?.affectedByGravity = true
        ballNode.physicsBody?.isDynamic = true
        ballNode.setup(with: .ball)
        ballNode.zPosition = 2
    }

    func setGravity(enabled: Bool) {
        scene.physicsWorld.gravity = CGVector(dx: 0, dy: enabled ? -9.8 : 0)
        if currentStage == .opening {
            coordinator?.setPlayButtonHidden(hidden: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.setupNextScene()
                self.coordinator?.setReadyToPlay(isReady: true)
            }
        }
    }

    func retry() {
        setupScene(stage: currentStage, isRetry: true)
        newlyCollectedItems = []
        coordinator?.updateCollectedItems(collectedItems: collectedItems + newlyCollectedItems)
        print("Collected Items: \(collectedItems)")
        canvasView.drawing = PKDrawing()
    }
}

extension GameSceneViewController: SKPhysicsContactDelegate, SKSceneDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node, let nodeB = contact.bodyB.node else { return }
        switch nodeA.name {
        case NodeType.fire.name:
            removeBall()
        case NodeType.basket.name:
            goal()
        default:
            if Item.allCases.map({ $0.name }).contains(nodeA.name) {
                getItem(node: nodeA)
            }
        }
        if nodeA.name == NodeType.line.name || nodeB.name == NodeType.line.name {
            DispatchQueue.global(qos: . userInitiated).async {
                self.bounceAudioPlayer.currentTime = 0
                self.bounceAudioPlayer.play()
            }
        }
    }

    //    func update(_ currentTime: TimeInterval, for scene: SKScene) {
    //        if isBallOutsideScreen {
    //            missedBall()
    //        }
    //    }

    //    var isBallOutsideScreen: Bool {
    //        if ballNode == nil { return false }
    //        let sceneSize = scene.size
    //        let ballPosition = ballNode.position
    //        let threshold: CGFloat = 20
    //        return ballPosition.x < -threshold || ballPosition.x > sceneSize.width + threshold ||
    //        ballPosition.y > threshold || ballPosition.y < -(sceneSize.height + threshold)
    //    }

    //    func missedBall() {
    //        print("MISS")
    //        retry()
    //    }

    func getItem(node: SKNode) {
        node.removeFromParent()
        guard let item = Item(rawValue: node.name ?? "") else { return }
        newlyCollectedItems.append(item)
        coordinator?.updateCollectedItems(collectedItems: collectedItems + newlyCollectedItems)
        DispatchQueue.global(qos: .userInitiated).async {
            self.itemAudioPlayer.currentTime = 0
            self.itemAudioPlayer.play()
        }
    }

    func goal() {
        removeBall()
        DispatchQueue.global(qos: .background).async {
            self.goalAudioPlayer.currentTime = 0
            self.goalAudioPlayer.play()
        }
        coordinator?.showGoalConfirm()
    }

    func removeBall() {
        scene.childNode(withName: NodeType.ball.name)?.removeFromParent()
    }

    func setupNextScene() {
        collectedItems += newlyCollectedItems
        newlyCollectedItems = []
        guard let nextStage = currentStage.next else {
            showResultView()
            return
        }
        canvasView.isUserInteractionEnabled = false
        setupScene(stage: nextStage)
    }

    func showResultView() {
        coordinator?.showResultView()
    }
}

extension GameSceneViewController: PKCanvasViewDelegate {
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        let lastStrokeIndex = canvasView.drawing.strokes.count - 1
        guard lastStrokeIndex >= 0 else { return }
        guard let lastStroke = canvasView.drawing.strokes.last else { return }
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
            lineNode.physicsBody?.restitution = self.calculateRestitution(from: lastStroke)
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

    func calculateRestitution(from stroke: PKStroke) -> CGFloat {
        let path = stroke.path
        let average = path.map({ $0.force }).reduce(0, +) / CGFloat(path.count)
        if average > 1.5 {
            return 1.5
        } else {
            return average
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
