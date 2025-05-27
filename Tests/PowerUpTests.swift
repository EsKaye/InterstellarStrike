import XCTest
import SpriteKit
@testable import InterstellarStrike

class PowerUpTests: XCTestCase {
    var gameScene: GameScene!
    var player: Player!
    
    override func setUp() {
        super.setUp()
        gameScene = GameScene(size: CGSize(width: 750, height: 1334))
        player = Player()
        gameScene.addChild(player)
    }
    
    override func tearDown() {
        player.removeFromParent()
        player = nil
        gameScene = nil
        super.tearDown()
    }
    
    func testPowerUpCreation() {
        let powerUp = PowerUpNode(type: .shield)
        
        XCTAssertNotNil(powerUp, "Power-up should be created")
        XCTAssertEqual(powerUp.type, .shield, "Power-up should be of correct type")
        XCTAssertEqual(powerUp.color, GameConfig.PowerUpSettings.Shield.color, "Power-up should have correct color")
    }
    
    func testPowerUpTypes() {
        // Test shield power-up
        let shieldPowerUp = PowerUpNode(type: .shield)
        XCTAssertEqual(shieldPowerUp.duration, GameConfig.PowerUpSettings.duration)
        
        // Test rapid fire power-up
        let rapidFirePowerUp = PowerUpNode(type: .rapidFire)
        XCTAssertEqual(rapidFirePowerUp.duration, GameConfig.PowerUpSettings.duration)
        
        // Test slow time power-up
        let slowTimePowerUp = PowerUpNode(type: .slowTime)
        XCTAssertEqual(slowTimePowerUp.duration, GameConfig.PowerUpSettings.duration)
    }
    
    func testShieldPowerUpEffect() {
        let powerUp = PowerUpNode(type: .shield)
        let initialHealth = player.health
        
        player.collectPowerUp(powerUp)
        
        XCTAssertTrue(player.activePowerUps.contains(.shield), "Player should have shield power-up")
        XCTAssertGreaterThan(player.health, initialHealth, "Shield power-up should increase health")
    }
    
    func testRapidFirePowerUpEffect() {
        let powerUp = PowerUpNode(type: .rapidFire)
        let initialFireRate = player.fireRate
        
        player.collectPowerUp(powerUp)
        
        XCTAssertTrue(player.activePowerUps.contains(.rapidFire), "Player should have rapid fire power-up")
        XCTAssertLessThan(player.fireRate, initialFireRate, "Rapid fire power-up should increase fire rate")
    }
    
    func testSlowTimePowerUpEffect() {
        let powerUp = PowerUpNode(type: .slowTime)
        
        player.collectPowerUp(powerUp)
        
        XCTAssertTrue(player.activePowerUps.contains(.slowTime), "Player should have slow time power-up")
        XCTAssertEqual(gameScene.physicsWorld.speed, GameConfig.PowerUpSettings.SlowTime.timeScale, "Slow time power-up should slow down physics world")
    }
    
    func testPowerUpDuration() {
        let powerUp = PowerUpNode(type: .shield)
        player.collectPowerUp(powerUp)
        
        gameScene.update(GameConfig.PowerUpSettings.duration + 0.1)
        
        XCTAssertFalse(player.activePowerUps.contains(.shield), "Power-up should expire after duration")
    }
    
    func testPowerUpCollection() {
        let powerUp = PowerUpNode(type: .shield)
        powerUp.position = player.position
        
        let contact = SKPhysicsContact(bodyA: player.physicsBody!, bodyB: powerUp.physicsBody!)
        player.didBeginContact(contact)
        
        XCTAssertTrue(player.activePowerUps.contains(.shield), "Player should collect power-up on contact")
        XCTAssertFalse(gameScene.children.contains(powerUp), "Power-up should be removed after collection")
    }
    
    func testMultiplePowerUps() {
        let shieldPowerUp = PowerUpNode(type: .shield)
        let rapidFirePowerUp = PowerUpNode(type: .rapidFire)
        
        player.collectPowerUp(shieldPowerUp)
        player.collectPowerUp(rapidFirePowerUp)
        
        XCTAssertTrue(player.activePowerUps.contains(.shield), "Player should have shield power-up")
        XCTAssertTrue(player.activePowerUps.contains(.rapidFire), "Player should have rapid fire power-up")
    }
    
    func testPowerUpSpawnChance() {
        var powerUpCount = 0
        let iterations = 1000
        
        for _ in 0..<iterations {
            if PowerUpNode.shouldSpawnPowerUp() {
                powerUpCount += 1
            }
        }
        
        let spawnRate = Double(powerUpCount) / Double(iterations)
        XCTAssertEqual(spawnRate, GameConfig.PowerUpSettings.spawnChance, accuracy: 0.05, "Power-up spawn chance should match configuration")
    }
    
    func testPowerUpMovement() {
        let powerUp = PowerUpNode(type: .shield)
        gameScene.addChild(powerUp)
        let initialPosition = powerUp.position
        
        gameScene.update(1.0)
        
        XCTAssertNotEqual(powerUp.position, initialPosition, "Power-up should move")
    }
    
    func testPowerUpBoundaryHandling() {
        let powerUp = PowerUpNode(type: .shield)
        gameScene.addChild(powerUp)
        
        // Test bottom boundary
        powerUp.position = CGPoint(x: 0, y: -100)
        gameScene.update(0.1)
        XCTAssertFalse(gameScene.children.contains(powerUp), "Power-up should be removed when off screen")
    }
    
    func testPowerUpPerformance() {
        measure {
            for _ in 0..<100 {
                let powerUp = PowerUpNode(type: .shield)
                gameScene.addChild(powerUp)
                for _ in 0..<10 {
                    powerUp.update(1/60)
                }
            }
        }
    }
} 