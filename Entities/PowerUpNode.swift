import SpriteKit

// MARK: - PowerUp Types
enum PowerUpType {
    case shield
    case rapidFire
    case slowTime
    
    var duration: TimeInterval {
        switch self {
        case .shield: return 5.0
        case .rapidFire: return 5.0
        case .slowTime: return 5.0
        }
    }
    
    var color: SKColor {
        switch self {
        case .shield: return .cyan
        case .rapidFire: return .orange
        case .slowTime: return .purple
        }
    }
    
    var icon: String {
        switch self {
        case .shield: return "🛡️"
        case .rapidFire: return "⚡"
        case .slowTime: return "⏰"
        }
    }
}

// MARK: - PowerUp Node
class PowerUpNode: SKSpriteNode {
    // MARK: - Properties
    private let type: PowerUpType
    private var isCollected = false
    
    // MARK: - Initialization
    init(type: PowerUpType) {
        self.type = type
        
        // Create powerup sprite
        let size = CGSize(width: 30, height: 30)
        super.init(texture: nil, color: type.color, size: size)
        
        // Setup physics body
        physicsBody = SKPhysicsBody(circleOfRadius: size.width / 2)
        physicsBody?.categoryBitMask = GameScene.powerUpCategory
        physicsBody?.contactTestBitMask = GameScene.playerCategory
        physicsBody?.collisionBitMask = 0
        
        // Add icon label
        let iconLabel = SKLabelNode(text: type.icon)
        iconLabel.fontSize = 20
        iconLabel.verticalAlignmentMode = .center
        addChild(iconLabel)
        
        // Add floating animation
        let floatUp = SKAction.moveBy(x: 0, y: 10, duration: 1.0)
        let floatDown = SKAction.moveBy(x: 0, y: -10, duration: 1.0)
        let floatSequence = SKAction.sequence([floatUp, floatDown])
        run(SKAction.repeatForever(floatSequence))
        
        // Add rotation animation
        let rotate = SKAction.rotate(byAngle: .pi * 2, duration: 3.0)
        run(SKAction.repeatForever(rotate))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - PowerUp Effects
    func applyEffect(to player: SKSpriteNode) {
        guard !isCollected else { return }
        isCollected = true
        
        switch type {
        case .shield:
            applyShield(to: player)
        case .rapidFire:
            applyRapidFire(to: player)
        case .slowTime:
            applySlowTime()
        }
        
        // Remove powerup
        removeFromParent()
    }
    
    private func applyShield(to player: SKSpriteNode) {
        // Create shield effect
        let shield = SKShapeNode(circleOfRadius: player.size.width * 0.8)
        shield.strokeColor = .cyan
        shield.lineWidth = 2
        shield.alpha = 0.5
        player.addChild(shield)
        
        // Add pulsing animation
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 0.5),
            SKAction.scale(to: 1.0, duration: 0.5)
        ])
        shield.run(SKAction.repeatForever(pulse))
        
        // Remove shield after duration
        DispatchQueue.main.asyncAfter(deadline: .now() + type.duration) {
            shield.removeFromParent()
        }
    }
    
    private func applyRapidFire(to player: SKSpriteNode) {
        // Store original fire rate
        let originalFireRate = player.userData?.value(forKey: "fireRate") as? TimeInterval ?? 0.5
        
        // Set new fire rate
        player.userData?.setValue(originalFireRate / 2, forKey: "fireRate")
        
        // Add visual effect
        let rapidFireEffect = SKEmitterNode()
        // TODO: Configure particle effect
        
        // Reset after duration
        DispatchQueue.main.asyncAfter(deadline: .now() + type.duration) {
            player.userData?.setValue(originalFireRate, forKey: "fireRate")
            rapidFireEffect.removeFromParent()
        }
    }
    
    private func applySlowTime() {
        // Slow down all enemies
        let originalSpeed = 1.0
        let slowSpeed = 0.5
        
        // Apply slow effect to all enemies
        enumerateChildNodes(withName: "enemy") { node, _ in
            node.speed = slowSpeed
        }
        
        // Add visual effect
        let slowTimeEffect = SKEmitterNode()
        // TODO: Configure particle effect
        
        // Reset after duration
        DispatchQueue.main.asyncAfter(deadline: .now() + type.duration) {
            self.enumerateChildNodes(withName: "enemy") { node, _ in
                node.speed = originalSpeed
            }
            slowTimeEffect.removeFromParent()
        }
    }
}

// MARK: - PowerUp Factory
class PowerUpFactory {
    static func createRandomPowerUp(at position: CGPoint) -> PowerUpNode? {
        // 30% chance to spawn a powerup
        guard Double.random(in: 0...1) < 0.3 else { return nil }
        
        // Randomly select powerup type
        let types: [PowerUpType] = [.shield, .rapidFire, .slowTime]
        guard let type = types.randomElement() else { return nil }
        
        let powerUp = PowerUpNode(type: type)
        powerUp.position = position
        return powerUp
    }
} 