import SpriteKit

// MARK: - Enemy Types
enum EnemyType {
    case standard    // Basic movement
    case zigzag     // Side-to-side movement
    case divebomb   // Fast dive toward player
    case hover      // Hover and shoot
    case boss       // Complex pattern with multiple phases
    
    var health: Int {
        switch self {
        case .standard: return 1
        case .zigzag: return 2
        case .divebomb: return 1
        case .hover: return 3
        case .boss: return 10
        }
    }
    
    var score: Int {
        switch self {
        case .standard: return 10
        case .zigzag: return 20
        case .divebomb: return 15
        case .hover: return 25
        case .boss: return 100
        }
    }
}

// MARK: - Enemy Behavior Protocol
protocol EnemyBehavior {
    func update(deltaTime: TimeInterval, enemy: SKSpriteNode, player: SKSpriteNode)
    func onSpawn(enemy: SKSpriteNode)
}

// MARK: - Behavior Implementations
class StandardBehavior: EnemyBehavior {
    func update(deltaTime: TimeInterval, enemy: SKSpriteNode, player: SKSpriteNode) {
        let moveDown = SKAction.moveBy(x: 0, y: -100 * CGFloat(deltaTime), duration: 0)
        enemy.run(moveDown)
    }
    
    func onSpawn(enemy: SKSpriteNode) {}
}

class ZigzagBehavior: EnemyBehavior {
    private var direction: CGFloat = 1.0
    private var timeElapsed: TimeInterval = 0
    
    func update(deltaTime: TimeInterval, enemy: SKSpriteNode, player: SKSpriteNode) {
        timeElapsed += deltaTime
        
        // Change direction every 1 second
        if timeElapsed >= 1.0 {
            direction *= -1
            timeElapsed = 0
        }
        
        let moveHorizontal = SKAction.moveBy(x: 100 * CGFloat(direction) * CGFloat(deltaTime), y: 0, duration: 0)
        let moveDown = SKAction.moveBy(x: 0, y: -50 * CGFloat(deltaTime), duration: 0)
        enemy.run(SKAction.group([moveHorizontal, moveDown]))
    }
    
    func onSpawn(enemy: SKSpriteNode) {}
}

class DivebombBehavior: EnemyBehavior {
    private var hasDived = false
    private var diveSpeed: CGFloat = 400
    
    func update(deltaTime: TimeInterval, enemy: SKSpriteNode, player: SKSpriteNode) {
        if !hasDived {
            // Move normally until reaching dive point
            let moveDown = SKAction.moveBy(x: 0, y: -50 * CGFloat(deltaTime), duration: 0)
            enemy.run(moveDown)
            
            // Check if we should start diving
            if enemy.position.y < 500 {
                hasDived = true
            }
        } else {
            // Calculate direction to player
            let dx = player.position.x - enemy.position.x
            let dy = player.position.y - enemy.position.y
            let angle = atan2(dy, dx)
            
            // Move toward player
            let moveX = cos(angle) * diveSpeed * CGFloat(deltaTime)
            let moveY = sin(angle) * diveSpeed * CGFloat(deltaTime)
            enemy.position.x += moveX
            enemy.position.y += moveY
        }
    }
    
    func onSpawn(enemy: SKSpriteNode) {}
}

class HoverBehavior: EnemyBehavior {
    private var timeElapsed: TimeInterval = 0
    private var shootInterval: TimeInterval = 1.0
    
    func update(deltaTime: TimeInterval, enemy: SKSpriteNode, player: SKSpriteNode) {
        timeElapsed += deltaTime
        
        // Hover in place
        if enemy.position.y > 400 {
            let moveDown = SKAction.moveBy(x: 0, y: -20 * CGFloat(deltaTime), duration: 0)
            enemy.run(moveDown)
        }
        
        // Shoot at intervals
        if timeElapsed >= shootInterval {
            shoot(enemy: enemy, at: player)
            timeElapsed = 0
        }
    }
    
    private func shoot(enemy: SKSpriteNode, at target: SKSpriteNode) {
        // TODO: Implement enemy shooting
    }
    
    func onSpawn(enemy: SKSpriteNode) {}
}

// MARK: - Enemy Factory
class EnemyFactory {
    static func createEnemy(type: EnemyType, at position: CGPoint) -> SKSpriteNode {
        let enemy = SKSpriteNode(color: .red, size: CGSize(width: 40, height: 40))
        enemy.position = position
        enemy.name = "enemy"
        
        // Setup physics body
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        enemy.physicsBody?.categoryBitMask = GameScene.enemyCategory
        enemy.physicsBody?.contactTestBitMask = GameScene.laserCategory | GameScene.playerCategory
        enemy.physicsBody?.collisionBitMask = 0
        
        // Add behavior component
        let behavior: EnemyBehavior
        switch type {
        case .standard:
            behavior = StandardBehavior()
        case .zigzag:
            behavior = ZigzagBehavior()
        case .divebomb:
            behavior = DivebombBehavior()
        case .hover:
            behavior = HoverBehavior()
        case .boss:
            behavior = StandardBehavior() // TODO: Implement boss behavior
        }
        
        // Store behavior and type in userData
        enemy.userData = NSMutableDictionary()
        enemy.userData?.setValue(behavior, forKey: "behavior")
        enemy.userData?.setValue(type, forKey: "type")
        
        return enemy
    }
} 