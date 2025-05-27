import SpriteKit

class EnergyCore: SKSpriteNode {
    // MARK: - Properties
    private var isCollected = false
    private let phaseShiftDuration: TimeInterval = 10.0
    private let scoreMultiplier: Int = 2
    
    // MARK: - Initialization
    init() {
        let size = CGSize(width: 40, height: 40)
        super.init(texture: nil, color: .yellow, size: size)
        
        // Setup physics body
        physicsBody = SKPhysicsBody(circleOfRadius: size.width / 2)
        physicsBody?.categoryBitMask = GameScene.energyCoreCategory
        physicsBody?.contactTestBitMask = GameScene.playerCategory
        physicsBody?.collisionBitMask = 0
        
        // Add glow effect
        let glow = SKShapeNode(circleOfRadius: size.width * 0.8)
        glow.strokeColor = .yellow
        glow.lineWidth = 2
        glow.alpha = 0.5
        addChild(glow)
        
        // Add pulsing animation
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 0.5),
            SKAction.scale(to: 1.0, duration: 0.5)
        ])
        glow.run(SKAction.repeatForever(pulse))
        
        // Add rotation animation
        let rotate = SKAction.rotate(byAngle: .pi * 2, duration: 3.0)
        run(SKAction.repeatForever(rotate))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Phase Shift
    func activatePhaseShift(in scene: SKScene) {
        guard !isCollected else { return }
        isCollected = true
        
        // Store original score multiplier
        let originalMultiplier = GameManager.shared.scoreMultiplier
        
        // Apply phase shift effects
        applyPhaseShiftEffects(to: scene)
        
        // Update score multiplier
        GameManager.shared.scoreMultiplier = scoreMultiplier
        
        // Remove energy core
        removeFromParent()
        
        // Reset after duration
        DispatchQueue.main.asyncAfter(deadline: .now() + phaseShiftDuration) {
            self.removePhaseShiftEffects(from: scene)
            GameManager.shared.scoreMultiplier = originalMultiplier
        }
    }
    
    private func applyPhaseShiftEffects(to scene: SKScene) {
        // Change background
        let originalColor = scene.backgroundColor
        scene.backgroundColor = .purple
        
        // Add particle effects
        let particles = SKEmitterNode()
        // TODO: Configure phase shift particle effect
        scene.addChild(particles)
        
        // Add screen distortion effect
        let distortion = SKAction.sequence([
            SKAction.scale(to: 1.05, duration: 0.1),
            SKAction.scale(to: 1.0, duration: 0.1)
        ])
        scene.run(SKAction.repeat(distortion, count: 3))
        
        // Store original values for reset
        scene.userData?.setValue(originalColor, forKey: "originalBackgroundColor")
        scene.userData?.setValue(particles, forKey: "phaseShiftParticles")
    }
    
    private func removePhaseShiftEffects(from scene: SKScene) {
        // Restore background
        if let originalColor = scene.userData?.value(forKey: "originalBackgroundColor") as? SKColor {
            scene.backgroundColor = originalColor
        }
        
        // Remove particles
        if let particles = scene.userData?.value(forKey: "phaseShiftParticles") as? SKEmitterNode {
            particles.removeFromParent()
        }
    }
}

// MARK: - Energy Core Factory
class EnergyCoreFactory {
    static func spawnEnergyCore(in scene: SKScene) {
        let core = EnergyCore()
        
        // Position at random x, top of screen
        let randomX = CGFloat.random(in: core.size.width...(scene.size.width - core.size.width))
        core.position = CGPoint(x: randomX, y: scene.size.height + core.size.height)
        
        scene.addChild(core)
        
        // Animate entrance
        let moveDown = SKAction.moveTo(y: scene.size.height - 100, duration: 2.0)
        let hover = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 20, duration: 1.0),
            SKAction.moveBy(x: 0, y: -20, duration: 1.0)
        ])
        
        core.run(SKAction.sequence([
            moveDown,
            SKAction.repeatForever(hover)
        ]))
    }
} 