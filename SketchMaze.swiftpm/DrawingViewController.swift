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

class DrawingViewController: UIViewController, UIPencilInteractionDelegate {

    @IBOutlet var canvasView: PKCanvasView!
    @IBOutlet var skView: SKView!
    private var scene: SKScene!
    private var retryButton = UIButton()

    var pencilAudioPlayer: AVAudioPlayer!
    var itemAudioPlayer: AVAudioPlayer!


    let blackInk = PKInkingTool(ink: PKInk(.pencil, color: .black), width: 5)

    private var itemCount = 0
    var ballNode: SKSpriteNode!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSpriteKitView()
        setupCanvasView()
        setupAddBallButton()
        setupClearButton()
        setupAudioPlayer()
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
        guard let myScene = SKScene(fileNamed: "stage1") else { return }
        scene = myScene
        scene.size = view.bounds.size
        scene.scaleMode = .aspectFit
        scene.physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        scene.delegate = self
        scene.physicsWorld.contactDelegate = self
        [NodeType.fire, NodeType.goal, NodeType.item].forEach { nodeType in
            scene.enumerateChildNodes(withName: nodeType.name) { node, _ in
                let texture = SKTexture(imageNamed: nodeType.name)
                node.physicsBody = SKPhysicsBody(texture: texture, size: node.frame.size)
                node.physicsBody?.affectedByGravity = false
                node.physicsBody?.isDynamic = false
                node.setup(with: nodeType)
            }
        }
        skView = SKView(frame: view.bounds)
        skView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        skView.presentScene(scene)
        skView.preferredFramesPerSecond = 120
        skView.ignoresSiblingOrder = true
        view.addSubview(skView)
    }

    func setupAddBallButton() {
        let addButton = UIButton(type: .system)
        addButton.setTitle("Add Ball", for: .normal)
        addButton.addTarget(self, action: #selector(addBall), for: .touchUpInside)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(addButton)

        NSLayoutConstraint.activate([
            addButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            addButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8)
        ])
    }

    @IBAction func addBall() {
        let location = CGPoint(x: 200, y: 0)
        let ball = SKSpriteNode(texture: SKTexture(imageNamed: NodeType.ball.name), size: CGSize(width: 40, height: 40))
        ball.position = location
        ball.physicsBody = SKPhysicsBody(circleOfRadius: 20)
        ball.setup(with: .ball)
        ball.zPosition = 1
        ballNode = ball
        scene.addChild(ballNode)
    }

    func setupClearButton() {
        let clearButton = UIButton(type: .system)
        clearButton.setTitle("Reset", for: .normal)
        clearButton.addTarget(self, action: #selector(clearAll), for: .touchUpInside)
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(clearButton)

        NSLayoutConstraint.activate([
            clearButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            clearButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8)
        ])
    }

    @IBAction func clearAll() {
        skView.removeFromSuperview()
        setupSpriteKitView()
        view.sendSubviewToBack(skView)
        canvasView.drawing = PKDrawing()
    }
}

extension DrawingViewController: SKPhysicsContactDelegate, SKSceneDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        let nodeA = contact.bodyA.node
        let nodeB = contact.bodyB.node
        guard let nodeNameA = nodeA?.name else { return }
        switch nodeNameA {
        case NodeType.fire.name:
            missedBall()
        case NodeType.goal.name:
            nodeB?.removeFromParent()
            print("GOAL!!")
        case NodeType.item.name:
            getItem(node: nodeA)
        default: break
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
        ballNode.removeFromParent()
        ballNode = nil
        print("MISS")
        clearAll()
    }

    func getItem(node: SKNode?) {
        node?.removeFromParent()
        itemCount += 1
        print("Collect item!: \(itemCount)")
        itemAudioPlayer.currentTime = 0
        DispatchQueue.global(qos: .userInitiated).async {
            self.itemAudioPlayer.play()
        }
    }
}

extension DrawingViewController: PKCanvasViewDelegate {
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        pencilAudioPlayer.stop()
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

    func canvasViewDidBeginUsingTool(_ canvasView: PKCanvasView) {
        self.scene.physicsWorld.speed = 0.3
        DispatchQueue.global(qos: .userInitiated).async {
            self.pencilAudioPlayer.play()
        }
    }
}
