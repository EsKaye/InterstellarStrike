import SpriteKit

class MenuScene: SKScene {
    // MARK: - Properties
    private var startButton: ButtonNode!
    private var titleLabel: SKLabelNode!
    
    // MARK: - Scene Setup
    override func didMove(to view: SKView) {
        setupBackground()
        setupTitle()
        setupStartButton()
    }
    
    private func setupBackground() {
        // TODO: Add background image
        backgroundColor = .black
    }
    
    private func setupTitle() {
        titleLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        titleLabel.text = "Interstellar Strike"
        titleLabel.fontSize = 40
        titleLabel.position = CGPoint(x: frame.midX, y: frame.midY + 100)
        addChild(titleLabel)
    }
    
    private func setupStartButton() {
        startButton = ButtonNode(text: "Start Game", size: CGSize(width: 200, height: 50)) { [weak self] in
            let gameScene = GameScene(size: self!.size)
            gameScene.scaleMode = .aspectFill
            self?.view?.presentScene(gameScene, transition: SKTransition.fade(withDuration: 0.5))
            GameManager.shared.transition(to: .playing, in: gameScene)
        }
        startButton.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(startButton)
    }
} 