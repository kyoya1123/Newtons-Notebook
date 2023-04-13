//
//  ViewController.swift
//  SketchPuzzle
//
//  Created by Kyoya Yamaguchi on 2023/04/12.
//

import UIKit
import PencilKit
import SpriteKit

class DrawingViewController: UIViewController, UIPencilInteractionDelegate {

    private var canvasView: PKCanvasView!
    private var skView: SKView!
    private var scene: SKScene!

    let blackInk = PKInkingTool(ink: PKInk(.pen, color: .black), width: 5)

    private var itemCount = 0
    var ballNode: SKSpriteNode!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSpriteKitView()
        setupCanvasView()
        setupAddBallButton()
        setupClearButton()
    }

    private func setupCanvasView() {
        canvasView = PKCanvasView(frame: view.bounds)
        canvasView.backgroundColor = .clear
        canvasView.delegate = self
        canvasView.drawingPolicy = .anyInput
        canvasView.tool = blackInk
        let pencilInteraction = UIPencilInteraction()
        pencilInteraction.delegate = self
        view.addInteraction(pencilInteraction)
        view.addSubview(canvasView)
    }

    private func setupSpriteKitView() {
        guard let myScene = SKScene(fileNamed: "MyScene") else { return }
        scene = myScene
        scene.size = view.bounds.size
        scene.scaleMode = .aspectFit
        scene.physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
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
        let location = CGPoint(x: scene.frame.width / 2, y: 0)
        let ball = SKShapeNode(circleOfRadius: 20)
        ball.position = location
        ball.fillColor = .red
        ball.physicsBody = SKPhysicsBody(circleOfRadius: 20)
        ball.setup(with: .ball)
        scene.addChild(ball)
    }

    func setupClearButton() {
        let clearButton = UIButton(type: .system)
        clearButton.setTitle("Clear", for: .normal)
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
            nodeB?.removeFromParent()
            print("MISS")
        case NodeType.goal.name:
            nodeB?.removeFromParent()
            print("GOAL!!")
        case NodeType.item.name:
            nodeA?.removeFromParent()
            itemCount += 1
            print("Collect item!: \(itemCount)")
        default: break
        }
    }

    func update(_ currentTime: TimeInterval, for scene: SKScene) {
        if isBallOutsideScreen {
            ballNode.removeFromParent()
        }
    }

    var isBallOutsideScreen: Bool {
        let sceneSize = scene.size
        let ballPosition = ballNode.position
        return ballPosition.x < 0 || ballPosition.x > sceneSize.width ||
        ballPosition.y < 0 || ballPosition.y > sceneSize.height
    }
}

extension DrawingViewController: PKCanvasViewDelegate {
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

            DispatchQueue.main.async {
                self.scene.addChild(lineNode)
                var updatedDrawing = canvasView.drawing
                updatedDrawing.strokes.removeAll()
                canvasView.drawing = updatedDrawing
            }
        }
    }
}
