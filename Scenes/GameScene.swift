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
    
    // MARK: - Boss Properties
    private var bossAI: BossAI?
    private var bossPhaseManager: BossPhaseManager?
    private var bossNode: SKSpriteNode?
    private var phaseIndicator: SKLabelNode?
    private var healthBar: SKShapeNode?
    private var healthFill: SKShapeNode?
    
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
    
    // MARK: - Boss Setup
    private func setupBoss(_ type: BossType) {
        // Create boss node
        bossNode = SKSpriteNode(imageNamed: "\(type)_boss")
        bossNode?.position = CGPoint(x: frame.midX, y: frame.maxY - 200)
        bossNode?.zPosition = 2
        bossNode?.setScale(2.0)
        addChild(bossNode!)
        
        // Initialize boss AI
        bossAI = BossAI(type: type, health: 1000, phaseCount: 3)
        
        // Initialize phase manager
        bossPhaseManager = BossPhaseManager(bossAI: bossAI!, scene: self)
        
        // Setup health bar
        setupHealthBar()
        
        // Setup phase indicator
        setupPhaseIndicator()
        
        // Start boss battle
        startBossBattle()
    }
    
    private func setupHealthBar() {
        // Create health bar background
        healthBar = SKShapeNode(rectOf: CGSize(width: 200, height: 20))
        healthBar?.fillColor = .darkGray
        healthBar?.strokeColor = .white
        healthBar?.position = CGPoint(x: frame.midX, y: frame.maxY - 50)
        healthBar?.zPosition = 3
        addChild(healthBar!)
        
        // Create health fill
        healthFill = SKShapeNode(rectOf: CGSize(width: 200, height: 20))
        healthFill?.fillColor = .green
        healthFill?.strokeColor = .clear
        healthFill?.position = CGPoint(x: frame.midX, y: frame.maxY - 50)
        healthFill?.zPosition = 4
        addChild(healthFill!)
    }
    
    private func setupPhaseIndicator() {
        phaseIndicator = SKLabelNode(fontNamed: "AvenirNext-Bold")
        phaseIndicator?.fontSize = 24
        phaseIndicator?.fontColor = .white
        phaseIndicator?.position = CGPoint(x: frame.midX, y: frame.maxY - 80)
        phaseIndicator?.zPosition = 3
        phaseIndicator?.alpha = 0
        addChild(phaseIndicator!)
    }
    
    private func startBossBattle() {
        // Show boss introduction
        let introSequence = SKAction.sequence([
            SKAction.fadeIn(withDuration: 1.0),
            SKAction.scale(to: 1.0, duration: 0.5),
            SKAction.run { [weak self] in
                self?.showBossName()
            }
        ])
        
        bossNode?.run(introSequence)
    }
    
    private func showBossName() {
        guard let bossAI = bossAI else { return }
        
        let nameLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        nameLabel.text = bossAI.name
        nameLabel.fontSize = 32
        nameLabel.fontColor = .white
        nameLabel.position = CGPoint(x: frame.midX, y: frame.maxY - 120)
        nameLabel.zPosition = 3
        nameLabel.alpha = 0
        addChild(nameLabel)
        
        let nameSequence = SKAction.sequence([
            SKAction.fadeIn(withDuration: 0.5),
            SKAction.wait(forDuration: 2.0),
            SKAction.fadeOut(withDuration: 0.5),
            SKAction.removeFromParent()
        ])
        
        nameLabel.run(nameSequence)
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
    
    // MARK: - Update
    override func update(_ currentTime: TimeInterval) {
        // Update boss AI
        if let bossAI = bossAI, let bossNode = bossNode {
            bossAI.update(deltaTime: 1/60, bossNode: bossNode, scene: self)
            updateBossHealth()
        }
    }
    
    private func updateBossHealth() {
        guard let bossAI = bossAI, let healthFill = healthFill else { return }
        
        let healthPercentage = bossAI.health / bossAI.maxHealth
        let newWidth = 200 * CGFloat(healthPercentage)
        
        let resizeAction = SKAction.resize(toWidth: newWidth, duration: 0.2)
        healthFill.run(resizeAction)
        
        // Update health bar color based on percentage
        let colorAction = SKAction.colorize(
            with: healthColor(for: healthPercentage),
            colorBlendFactor: 1.0,
            duration: 0.2
        )
        healthFill.run(colorAction)
    }
    
    private func healthColor(for percentage: Double) -> SKColor {
        switch percentage {
        case 0.7...: return .green
        case 0.3..<0.7: return .yellow
        default: return .red
        }
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
        
        // Handle boss damage
        if let bossNode = bossNode,
           (contact.bodyA.node == bossNode || contact.bodyB.node == bossNode),
           let projectile = (contact.bodyA.node?.name == "playerProjectile" ? contact.bodyA.node : contact.bodyB.node) as? SKSpriteNode {
            
            // Apply damage to boss
            bossAI?.health -= 10
            
            // Create hit effect
            createHitEffect(at: projectile.position)
            
            // Remove projectile
            projectile.removeFromParent()
            
            // Check for boss defeat
            if bossAI?.health ?? 0 <= 0 {
                handleBossDefeat()
            }
        }
    }
    
    private func createHitEffect(at position: CGPoint) {
        if let hitEmitter = SKEmitterNode(fileNamed: "BossHit") {
            hitEmitter.position = position
            hitEmitter.zPosition = 2
            addChild(hitEmitter)
            
            let sequence = SKAction.sequence([
                SKAction.wait(forDuration: 0.2),
                SKAction.removeFromParent()
            ])
            
            hitEmitter.run(sequence)
        }
    }
    
    private func handleBossDefeat() {
        guard let bossAI = bossAI else { return }
        
        // Create defeat sequence
        let defeatSequence = SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.5),
            SKAction.run { [weak self] in
                self?.showVictoryMessage()
                self?.unlockBossLore()
            }
        ])
        
        bossNode?.run(defeatSequence)
    }
    
    private func showVictoryMessage() {
        let victoryLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        victoryLabel.text = "VICTORY"
        victoryLabel.fontSize = 48
        victoryLabel.fontColor = .yellow
        victoryLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        victoryLabel.zPosition = 5
        victoryLabel.alpha = 0
        addChild(victoryLabel)
        
        let victorySequence = SKAction.sequence([
            SKAction.fadeIn(withDuration: 0.5),
            SKAction.scale(to: 1.2, duration: 0.2),
            SKAction.scale(to: 1.0, duration: 0.2),
            SKAction.wait(forDuration: 2.0),
            SKAction.fadeOut(withDuration: 0.5),
            SKAction.run { [weak self] in
                self?.transitionToNextLevel()
            }
        ])
        
        victoryLabel.run(victorySequence)
    }
    
    private func unlockBossLore() {
        guard let bossAI = bossAI else { return }
        
        // Create lore entry for each phase
        for phase in 1...bossAI.phaseCount {
            let loreEntry = BossLoreEntry.createForBoss(bossAI.type, phase: phase)
            loreEntry.isUnlocked = true
            
            // Notify lore unlock
            NotificationCenter.default.post(
                name: .newLoreUnlocked,
                object: nil,
                userInfo: ["loreEntry": loreEntry]
            )
        }
    }
    
    private func transitionToNextLevel() {
        // Create transition effect
        let transitionNode = SKSpriteNode(color: .black, size: frame.size)
        transitionNode.position = CGPoint(x: frame.midX, y: frame.midY)
        transitionNode.zPosition = 10
        transitionNode.alpha = 0
        addChild(transitionNode)
        
        // Animate transition
        let transitionSequence = SKAction.sequence([
            SKAction.fadeIn(withDuration: 1.0),
            SKAction.run { [weak self] in
                // Load next level
                self?.loadNextLevel()
            }
        ])
        
        transitionNode.run(transitionSequence)
    }
} 