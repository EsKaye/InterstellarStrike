import SpriteKit
import GameplayKit

class GameScene: SKScene {
    // MARK: - Properties
    private var player: SKSpriteNode!
    private var scoreLabel: SKLabelNode!
    private var pauseButton: ButtonNode!
    
    // Physics Categories
    private let playerCategory: UInt32 = 0x1 << 0
    private let enemyCategory: UInt32 = 0x1 << 1
    private let laserCategory: UInt32 = 0x1 << 2
    
    // MARK: - Scene Setup
    override func didMove(to view: SKView) {
        setupPhysicsWorld()
        setupPlayer()
        setupScore()
        setupPauseButton()
        startEnemySpawning()
    }
    
    private func setupPhysicsWorld() {
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
    }
    
    private func setupPlayer() {
        // Create player sprite (placeholder)
        player = SKSpriteNode(color: .blue, size: CGSize(width: 50, height: 50))
        player.position = CGPoint(x: frame.midX, y: frame.minY + 100)
        player.name = "player"
        
        // Setup physics body
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.categoryBitMask = playerCategory
        player.physicsBody?.contactTestBitMask = enemyCategory
        player.physicsBody?.collisionBitMask = 0
        player.physicsBody?.isDynamic = false
        
        addChild(player)
    }
    
    private func setupScore() {
        scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 24
        scoreLabel.position = CGPoint(x: frame.minX + 100, y: frame.maxY - 50)
        addChild(scoreLabel)
    }
    
    private func setupPauseButton() {
        pauseButton = ButtonNode(text: "Pause", size: CGSize(width: 100, height: 40)) { [weak self] in
            GameManager.shared.transition(to: .paused, in: self!)
        }
        pauseButton.position = CGPoint(x: frame.maxX - 70, y: frame.maxY - 30)
        addChild(pauseButton)
    }
    
    // MARK: - Game Logic
    private func startEnemySpawning() {
        let spawnAction = SKAction.run { [weak self] in
            self?.spawnEnemy()
        }
        let waitAction = SKAction.wait(forDuration: 1.5)
        let sequence = SKAction.sequence([spawnAction, waitAction])
        run(SKAction.repeatForever(sequence))
    }
    
    private func spawnEnemy() {
        let enemy = SKSpriteNode(color: .red, size: CGSize(width: 40, height: 40))
        let randomX = CGFloat.random(in: enemy.size.width...(frame.width - enemy.size.width))
        enemy.position = CGPoint(x: randomX, y: frame.maxY + enemy.size.height)
        enemy.name = "enemy"
        
        // Setup physics body
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        enemy.physicsBody?.categoryBitMask = enemyCategory
        enemy.physicsBody?.contactTestBitMask = laserCategory | playerCategory
        enemy.physicsBody?.collisionBitMask = 0
        
        addChild(enemy)
        
        let moveDown = SKAction.moveBy(x: 0, y: -frame.height - enemy.size.height, duration: 4.0)
        let remove = SKAction.removeFromParent()
        enemy.run(SKAction.sequence([moveDown, remove]))
    }
    
    private func shootLaser() {
        let laser = SKSpriteNode(color: .green, size: CGSize(width: 4, height: 20))
        laser.position = CGPoint(x: player.position.x, y: player.position.y + player.size.height/2)
        laser.name = "laser"
        
        // Setup physics body
        laser.physicsBody = SKPhysicsBody(rectangleOf: laser.size)
        laser.physicsBody?.categoryBitMask = laserCategory
        laser.physicsBody?.contactTestBitMask = enemyCategory
        laser.physicsBody?.collisionBitMask = 0
        
        addChild(laser)
        
        let moveUp = SKAction.moveBy(x: 0, y: frame.height, duration: 1.0)
        let remove = SKAction.removeFromParent()
        laser.run(SKAction.sequence([moveUp, remove]))
    }
    
    // MARK: - Game Reset
    func resetGame() {
        // Remove all enemies and lasers
        removeAllChildren()
        
        // Reset score
        GameManager.shared.resetScore()
        
        // Rebuild scene
        setupPhysicsWorld()
        setupPlayer()
        setupScore()
        setupPauseButton()
        startEnemySpawning()
    }
    
    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard GameManager.shared.currentState == .playing else { return }
        shootLaser()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard GameManager.shared.currentState == .playing else { return }
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let newX = min(max(location.x, player.size.width/2), frame.width - player.size.width/2)
        player.position.x = newX
    }
}

// MARK: - Physics Contact
extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if collision == laserCategory | enemyCategory {
            // Handle laser-enemy collision
            let laser = contact.bodyA.categoryBitMask == laserCategory ? contact.bodyA.node : contact.bodyB.node
            let enemy = contact.bodyA.categoryBitMask == enemyCategory ? contact.bodyA.node : contact.bodyB.node
            
            laser?.removeFromParent()
            enemy?.removeFromParent()
            
            GameManager.shared.addScore(10)
            scoreLabel.text = "Score: \(GameManager.shared.currentScore)"
            
            // TODO: Add explosion effect
            // TODO: Add sound effect
        } else if collision == playerCategory | enemyCategory {
            // Handle player-enemy collision
            GameManager.shared.transition(to: .gameOver, in: self)
        }
    }
} 