import SpriteKit

enum BossMovePattern {
    case voidPulse(count: Int, speed: CGFloat)
    case chronoSlam(duration: TimeInterval, damage: Double)
    case quantumSpiral(count: Int, speed: CGFloat)
    case summonMinions(count: Int)
    case voidCorruption(radius: CGFloat, duration: TimeInterval)
    
    var cooldown: TimeInterval {
        switch self {
        case .voidPulse: return 3.0
        case .chronoSlam: return 5.0
        case .quantumSpiral: return 4.0
        case .summonMinions: return 8.0
        case .voidCorruption: return 10.0
        }
    }
    
    func execute(from bossNode: SKSpriteNode, in scene: SKScene) {
        switch self {
        case .voidPulse(let count, let speed):
            executeVoidPulse(count: count, speed: speed, from: bossNode, in: scene)
        case .chronoSlam(let duration, let damage):
            executeChronoSlam(duration: duration, damage: damage, from: bossNode, in: scene)
        case .quantumSpiral(let count, let speed):
            executeQuantumSpiral(count: count, speed: speed, from: bossNode, in: scene)
        case .summonMinions(let count):
            executeSummonMinions(count: count, from: bossNode, in: scene)
        case .voidCorruption(let radius, let duration):
            executeVoidCorruption(radius: radius, duration: duration, from: bossNode, in: scene)
        }
    }
    
    // MARK: - Move Implementations
    
    private func executeVoidPulse(count: Int, speed: CGFloat, from bossNode: SKSpriteNode, in scene: SKScene) {
        // Create warning effect
        let warningCircle = SKShapeNode(circleOfRadius: 50)
        warningCircle.strokeColor = .purple
        warningCircle.lineWidth = 2
        warningCircle.position = bossNode.position
        warningCircle.alpha = 0
        scene.addChild(warningCircle)
        
        // Animate warning
        let warningSequence = SKAction.sequence([
            SKAction.fadeIn(withDuration: 0.3),
            SKAction.scale(to: 1.5, duration: 0.3),
            SKAction.fadeOut(withDuration: 0.2)
        ])
        
        warningCircle.run(warningSequence) {
            warningCircle.removeFromParent()
            
            // Create projectiles
            for i in 0..<count {
                let angle = (CGFloat(i) / CGFloat(count)) * .pi * 2
                let projectile = createProjectile(type: .void, in: scene)
                projectile.position = bossNode.position
                
                // Calculate direction
                let dx = cos(angle) * speed
                let dy = sin(angle) * speed
                let moveAction = SKAction.moveBy(x: dx, y: dy, duration: 2.0)
                
                // Add rotation
                let rotateAction = SKAction.rotate(byAngle: .pi * 2, duration: 1.0)
                let repeatRotation = SKAction.repeatForever(rotateAction)
                
                projectile.run(SKAction.group([moveAction, repeatRotation]))
            }
        }
    }
    
    private func executeChronoSlam(duration: TimeInterval, damage: Double, from bossNode: SKSpriteNode, in scene: SKScene) {
        // Create time distortion effect
        let timeDistortion = SKEffectNode()
        timeDistortion.filter = CIFilter(name: "CIMotionBlur")
        if let filter = timeDistortion.filter as? CIFilter {
            filter.setValue(20.0, forKey: "inputRadius")
            filter.setValue(0.0, forKey: "inputAngle")
        }
        scene.addChild(timeDistortion)
        
        // Slow down time
        scene.physicsWorld.speed = 0.5
        
        // Create impact warning
        let warningCircle = SKShapeNode(circleOfRadius: 100)
        warningCircle.strokeColor = .red
        warningCircle.lineWidth = 3
        warningCircle.position = bossNode.position
        warningCircle.alpha = 0
        scene.addChild(warningCircle)
        
        // Animate warning
        let warningSequence = SKAction.sequence([
            SKAction.fadeIn(withDuration: duration * 0.5),
            SKAction.scale(to: 2.0, duration: duration * 0.5),
            SKAction.run {
                // Create impact effect
                if let impactEmitter = SKEmitterNode(fileNamed: "ChronoSlamImpact") {
                    impactEmitter.position = bossNode.position
                    scene.addChild(impactEmitter)
                    
                    // Apply damage to player if in range
                    if let player = scene.childNode(withName: "player") as? SKSpriteNode {
                        let distance = hypot(
                            player.position.x - bossNode.position.x,
                            player.position.y - bossNode.position.y
                        )
                        if distance < 200 {
                            // Notify damage
                            NotificationCenter.default.post(
                                name: .playerDamaged,
                                object: nil,
                                userInfo: ["damage": damage]
                            )
                        }
                    }
                    
                    // Remove impact effect after duration
                    impactEmitter.run(SKAction.sequence([
                        SKAction.wait(forDuration: 1.0),
                        SKAction.removeFromParent()
                    ]))
                }
            },
            SKAction.fadeOut(withDuration: 0.2)
        ])
        
        warningCircle.run(warningSequence) {
            warningCircle.removeFromParent()
            timeDistortion.removeFromParent()
            scene.physicsWorld.speed = 1.0
        }
    }
    
    private func executeQuantumSpiral(count: Int, speed: CGFloat, from bossNode: SKSpriteNode, in scene: SKScene) {
        // Create spiral pattern
        for i in 0..<count {
            let angle = (CGFloat(i) / CGFloat(count)) * .pi * 2
            let radius = CGFloat(i) * 20
            
            let projectile = createProjectile(type: .quantum, in: scene)
            projectile.position = CGPoint(
                x: bossNode.position.x + cos(angle) * radius,
                y: bossNode.position.y + sin(angle) * radius
            )
            
            // Calculate spiral path
            let spiralPath = UIBezierPath()
            spiralPath.move(to: .zero)
            
            for t in stride(from: 0, to: 1, by: 0.1) {
                let spiralAngle = angle + t * .pi * 4
                let spiralRadius = radius + t * 200
                let point = CGPoint(
                    x: cos(spiralAngle) * spiralRadius,
                    y: sin(spiralAngle) * spiralRadius
                )
                spiralPath.addLine(to: point)
            }
            
            // Create follow path action
            let followPath = SKAction.follow(spiralPath.cgPath, asOffset: true, orientToPath: true, duration: 3.0)
            projectile.run(followPath)
        }
    }
    
    private func executeSummonMinions(count: Int, from bossNode: SKSpriteNode, in scene: SKScene) {
        // Create summoning effect
        if let summonEmitter = SKEmitterNode(fileNamed: "MinionSummon") {
            summonEmitter.position = bossNode.position
            scene.addChild(summonEmitter)
            
            // Summon minions after effect
            let summonSequence = SKAction.sequence([
                SKAction.wait(forDuration: 1.0),
                SKAction.run {
                    for _ in 0..<count {
                        let minion = createMinion(in: scene)
                        minion.position = self.randomPosition(around: bossNode.position, radius: 100)
                        scene.addChild(minion)
                        
                        // Add minion behavior
                        self.setupMinionBehavior(minion, in: scene)
                    }
                },
                SKAction.wait(forDuration: 0.5),
                SKAction.removeFromParent()
            ])
            
            summonEmitter.run(summonSequence)
        }
    }
    
    private func executeVoidCorruption(radius: CGFloat, duration: TimeInterval, from bossNode: SKSpriteNode, in scene: SKScene) {
        // Create corruption field
        let corruptionField = SKShapeNode(circleOfRadius: radius)
        corruptionField.fillColor = .purple
        corruptionField.strokeColor = .clear
        corruptionField.alpha = 0
        corruptionField.position = bossNode.position
        corruptionField.zPosition = -1
        scene.addChild(corruptionField)
        
        // Create corruption effect
        if let corruptionEmitter = SKEmitterNode(fileNamed: "VoidCorruption") {
            corruptionEmitter.position = bossNode.position
            scene.addChild(corruptionEmitter)
            
            // Animate corruption
            let corruptionSequence = SKAction.sequence([
                SKAction.fadeIn(withDuration: 0.5),
                SKAction.wait(forDuration: duration),
                SKAction.fadeOut(withDuration: 0.5)
            ])
            
            corruptionField.run(corruptionSequence)
            corruptionEmitter.run(corruptionSequence) {
                corruptionEmitter.removeFromParent()
            }
            
            // Apply corruption effect to player if in range
            if let player = scene.childNode(withName: "player") as? SKSpriteNode {
                let distance = hypot(
                    player.position.x - bossNode.position.x,
                    player.position.y - bossNode.position.y
                )
                if distance < radius {
                    // Notify corruption effect
                    NotificationCenter.default.post(
                        name: .playerCorrupted,
                        object: nil,
                        userInfo: ["duration": duration]
                    )
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func createProjectile(type: ProjectileType, in scene: SKScene) -> SKSpriteNode {
        let projectile = SKSpriteNode(imageNamed: "\(type)_projectile")
        projectile.size = CGSize(width: 20, height: 20)
        projectile.zPosition = 1
        
        // Add physics body
        projectile.physicsBody = SKPhysicsBody(circleOfRadius: 10)
        projectile.physicsBody?.categoryBitMask = PhysicsCategory.enemyProjectile
        projectile.physicsBody?.contactTestBitMask = PhysicsCategory.player
        projectile.physicsBody?.collisionBitMask = 0
        
        scene.addChild(projectile)
        return projectile
    }
    
    private func createMinion(in scene: SKScene) -> SKSpriteNode {
        let minion = SKSpriteNode(imageNamed: "minion")
        minion.size = CGSize(width: 30, height: 30)
        minion.zPosition = 1
        
        // Add physics body
        minion.physicsBody = SKPhysicsBody(circleOfRadius: 15)
        minion.physicsBody?.categoryBitMask = PhysicsCategory.enemy
        minion.physicsBody?.contactTestBitMask = PhysicsCategory.player | PhysicsCategory.playerProjectile
        minion.physicsBody?.collisionBitMask = 0
        
        return minion
    }
    
    private func setupMinionBehavior(_ minion: SKSpriteNode, in scene: SKScene) {
        // Add movement behavior
        let moveAction = SKAction.sequence([
            SKAction.move(to: randomPosition(around: minion.position, radius: 200), duration: 2.0),
            SKAction.wait(forDuration: 1.0)
        ])
        
        minion.run(SKAction.repeatForever(moveAction))
        
        // Add attack behavior
        let attackAction = SKAction.sequence([
            SKAction.wait(forDuration: 3.0),
            SKAction.run {
                if let player = scene.childNode(withName: "player") as? SKSpriteNode {
                    let projectile = self.createProjectile(type: .minion, in: scene)
                    projectile.position = minion.position
                    
                    let direction = CGPoint(
                        x: player.position.x - minion.position.x,
                        y: player.position.y - minion.position.y
                    )
                    let length = sqrt(direction.x * direction.x + direction.y * direction.y)
                    let normalized = CGPoint(x: direction.x / length, y: direction.y / length)
                    
                    let moveAction = SKAction.moveBy(
                        x: normalized.x * 300,
                        y: normalized.y * 300,
                        duration: 2.0
                    )
                    
                    projectile.run(moveAction)
                }
            }
        ])
        
        minion.run(SKAction.repeatForever(attackAction))
    }
    
    private func randomPosition(around center: CGPoint, radius: CGFloat) -> CGPoint {
        let angle = CGFloat.random(in: 0..<2 * .pi)
        let distance = CGFloat.random(in: 0..<radius)
        return CGPoint(
            x: center.x + cos(angle) * distance,
            y: center.y + sin(angle) * distance
        )
    }
}

// MARK: - Supporting Types
enum ProjectileType {
    case void
    case quantum
    case minion
}

// MARK: - Physics Categories
struct PhysicsCategory {
    static let none: UInt32 = 0
    static let player: UInt32 = 0b1
    static let enemy: UInt32 = 0b10
    static let playerProjectile: UInt32 = 0b100
    static let enemyProjectile: UInt32 = 0b1000
}

// MARK: - Notifications
extension Notification.Name {
    static let playerDamaged = Notification.Name("playerDamaged")
    static let playerCorrupted = Notification.Name("playerCorrupted")
} 