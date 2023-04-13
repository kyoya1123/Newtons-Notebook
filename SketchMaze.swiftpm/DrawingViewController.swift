//
//  ViewController.swift
//  SketchPuzzle
//
//  Created by Kyoya Yamaguchi on 2023/04/12.
//

import UIKit
import PencilKit
import SpriteKit

class DrawingViewController: UIViewController, PKCanvasViewDelegate, SKPhysicsContactDelegate, UIPencilInteractionDelegate {

    private var canvasView: PKCanvasView!
    private var skView: SKView!
    private var scene: SKScene!

    let blackInk = PKInkingTool(ink: PKInk(.pen, color: .black), width: 5)

    override func viewDidLoad() {
        super.viewDidLoad()

        setupSpriteKitView()
        setupCanvasView()
        setupAddBallButton()
        setupClearButton()
        //        setupPenColorButton()
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
        [NodeType.fire, NodeType.goal].forEach { nodeType in
            scene.enumerateChildNodes(withName: nodeType.name) { node, _ in
                let texture = SKTexture(imageNamed: nodeType.name)
                node.physicsBody = SKPhysicsBody(texture: texture, size: node.frame.size)
                node.setup(with: nodeType)
            }
        }
        skView = SKView(frame: view.bounds)
        skView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        skView.presentScene(scene)
        skView.showsPhysics = true
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
        scene.children.forEach {
            if $0.name == NodeType.ball.name || $0.name == NodeType.line.name {
                $0.removeFromParent()
            }
        }
        canvasView.drawing = PKDrawing()
    }

    //    func setupPenColorButton() {
    //        let penColorButton = UIButton(type: .system)
    //        penColorButton.setTitle("Switch Pen Color", for: .normal)
    //        penColorButton.addTarget(self, action: #selector(togglePenColor), for: .touchUpInside)
    //        penColorButton.translatesAutoresizingMaskIntoConstraints = false
    //        view.addSubview(penColorButton)
    //
    //        NSLayoutConstraint.activate([
    //            penColorButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 48),
    //            penColorButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8)
    //        ])
    //    }

    //    @IBAction func togglePenColor() {
    //        canvasView.tool = canvasView.tool as! PKInkingTool == blackInk ? blueInk : blackInk
    //    }

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
        default: break
        }
    }

    //    func pencilInteractionDidTap(_ interaction: UIPencilInteraction) {
    //        togglePenColor()
    //    }
}
