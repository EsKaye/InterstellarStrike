import XCTest
import SpriteKit
@testable import InterstellarStrike

class EnemyTests: XCTestCase {
    var gameScene: GameScene!
    var enemyAI: EnemyAI!
    
    override func setUp() {
        super.setUp()
        gameScene = GameScene(size: CGSize(width: 750, height: 1334))
        enemyAI = EnemyAI()
    }
    
    override func tearDown() {
        gameScene = nil
        enemyAI = nil
        super.tearDown()
    }
    
    func testEnemySpawn() {
        let enemy = enemyAI.spawnEnemy(type: .standard, in: gameScene)
        
        XCTAssertNotNil(enemy, "Enemy should be spawned")
        XCTAssertEqual(enemy.type, .standard, "Enemy should be of correct type")
        XCTAssertTrue(gameScene.children.contains(enemy), "Enemy should be added to scene")
    }
    
    func testEnemyTypes() {
        // Test standard enemy
        let standardEnemy = enemyAI.spawnEnemy(type: .standard, in: gameScene)
        XCTAssertEqual(standardEnemy.health, GameConfig.EnemySettings.Standard.health)
        XCTAssertEqual(standardEnemy.score, GameConfig.EnemySettings.Standard.score)
        
        // Test zigzag enemy
        let zigzagEnemy = enemyAI.spawnEnemy(type: .zigzag, in: gameScene)
        XCTAssertEqual(zigzagEnemy.health, GameConfig.EnemySettings.Zigzag.health)
        XCTAssertEqual(zigzagEnemy.score, GameConfig.EnemySettings.Zigzag.score)
        
        // Test divebomb enemy
        let divebombEnemy = enemyAI.spawnEnemy(type: .divebomb, in: gameScene)
        XCTAssertEqual(divebombEnemy.health, GameConfig.EnemySettings.Divebomb.health)
        XCTAssertEqual(divebombEnemy.score, GameConfig.EnemySettings.Divebomb.score)
        
        // Test hover enemy
        let hoverEnemy = enemyAI.spawnEnemy(type: .hover, in: gameScene)
        XCTAssertEqual(hoverEnemy.health, GameConfig.EnemySettings.Hover.health)
        XCTAssertEqual(hoverEnemy.score, GameConfig.EnemySettings.Hover.score)
        
        // Test boss enemy
        let bossEnemy = enemyAI.spawnEnemy(type: .boss, in: gameScene)
        XCTAssertEqual(bossEnemy.health, GameConfig.EnemySettings.Boss.health)
        XCTAssertEqual(bossEnemy.score, GameConfig.EnemySettings.Boss.score)
    }
    
    func testEnemyMovement() {
        let enemy = enemyAI.spawnEnemy(type: .standard, in: gameScene)
        let initialPosition = enemy.position
        
        gameScene.update(1.0)
        
        XCTAssertNotEqual(enemy.position, initialPosition, "Enemy should move from initial position")
    }
    
    func testEnemyZigzagMovement() {
        let enemy = enemyAI.spawnEnemy(type: .zigzag, in: gameScene)
        let initialX = enemy.position.x
        
        gameScene.update(GameConfig.EnemySettings.Zigzag.zigzagFrequency)
        
        XCTAssertNotEqual(enemy.position.x, initialX, "Zigzag enemy should move horizontally")
    }
    
    func testEnemyDivebombMovement() {
        let enemy = enemyAI.spawnEnemy(type: .divebomb, in: gameScene)
        let initialY = enemy.position.y
        
        gameScene.update(1.0)
        
        XCTAssertLessThan(enemy.position.y, initialY, "Divebomb enemy should move downward")
    }
    
    func testEnemyHoverBehavior() {
        let enemy = enemyAI.spawnEnemy(type: .hover, in: gameScene)
        let initialPosition = enemy.position
        
        gameScene.update(GameConfig.EnemySettings.Hover.shootInterval)
        
        XCTAssertNotEqual(enemy.position, initialPosition, "Hover enemy should move")
    }
    
    func testEnemyBossBehavior() {
        let enemy = enemyAI.spawnEnemy(type: .boss, in: gameScene)
        let initialPosition = enemy.position
        
        gameScene.update(GameConfig.EnemySettings.Boss.phaseDuration)
        
        XCTAssertNotEqual(enemy.position, initialPosition, "Boss enemy should move")
    }
    
    func testEnemyDamage() {
        let enemy = enemyAI.spawnEnemy(type: .standard, in: gameScene)
        let initialHealth = enemy.health
        
        enemy.takeDamage(1)
        
        XCTAssertEqual(enemy.health, initialHealth - 1, "Enemy should take correct damage")
    }
    
    func testEnemyDeath() {
        let enemy = enemyAI.spawnEnemy(type: .standard, in: gameScene)
        
        enemy.takeDamage(enemy.health)
        
        XCTAssertTrue(enemy.isDead, "Enemy should be marked as dead")
        XCTAssertFalse(gameScene.children.contains(enemy), "Dead enemy should be removed from scene")
    }
    
    func testEnemySpawnLimits() {
        for _ in 0..<GameConfig.EnemySettings.maxEnemies {
            _ = enemyAI.spawnEnemy(type: .standard, in: gameScene)
        }
        
        let enemyCount = gameScene.children.filter { $0 is EnemyNode }.count
        XCTAssertEqual(enemyCount, GameConfig.EnemySettings.maxEnemies, "Should not exceed maximum enemy count")
    }
    
    func testEnemyCollisionHandling() {
        let enemy = enemyAI.spawnEnemy(type: .standard, in: gameScene)
        let laser = LaserNode(from: .player)
        laser.position = enemy.position
        
        let contact = SKPhysicsContact(bodyA: enemy.physicsBody!, bodyB: laser.physicsBody!)
        enemy.didBeginContact(contact)
        
        XCTAssertLessThan(enemy.health, GameConfig.EnemySettings.Standard.health, "Enemy should take damage from laser")
    }
    
    func testEnemyPerformance() {
        measure {
            for _ in 0..<10 {
                let enemy = enemyAI.spawnEnemy(type: .standard, in: gameScene)
                for _ in 0..<100 {
                    enemy.update(1/60)
                }
            }
        }
    }
} 