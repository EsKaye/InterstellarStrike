import XCTest
import SpriteKit
@testable import InterstellarStrike

class PlayerTests: XCTestCase {
    var player: Player!
    var gameScene: GameScene!
    
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
    
    func testPlayerInitialization() {
        XCTAssertNotNil(player, "Player should be initialized")
        XCTAssertEqual(player.health, GameConfig.PlayerSettings.maxHealth, "Player should start with max health")
        XCTAssertEqual(player.energy, GameConfig.PlayerSettings.maxEnergy, "Player should start with max energy")
        XCTAssertEqual(player.moveSpeed, GameConfig.PlayerSettings.moveSpeed, "Player should have correct move speed")
    }
    
    func testPlayerMovement() {
        let initialPosition = player.position
        let moveAction = SKAction.moveBy(x: 100, y: 0, duration: 1.0)
        
        player.run(moveAction)
        gameScene.update(1.0)
        
        XCTAssertNotEqual(player.position, initialPosition, "Player should move from initial position")
    }
    
    func testPlayerFiring() {
        let initialLaserCount = gameScene.children.filter { $0 is Laser }.count
        player.fire()
        let newLaserCount = gameScene.children.filter { $0 is Laser }.count
        
        XCTAssertEqual(newLaserCount, initialLaserCount + 1, "Player should fire a laser")
    }
    
    func testPlayerDamage() {
        let initialHealth = player.health
        player.takeDamage(20)
        
        XCTAssertEqual(player.health, initialHealth - 20, "Player should take correct damage")
    }
    
    func testPlayerDeath() {
        player.takeDamage(GameConfig.PlayerSettings.maxHealth)
        
        XCTAssertEqual(player.health, 0, "Player should die when health reaches 0")
        XCTAssertTrue(player.isDead, "Player should be marked as dead")
    }
    
    func testPlayerEnergyRegeneration() {
        player.energy = 50
        let initialEnergy = player.energy
        
        gameScene.update(1.0)
        
        XCTAssertGreaterThan(player.energy, initialEnergy, "Player energy should regenerate")
    }
    
    func testPlayerPhaseShift() {
        let initialEnergy = player.energy
        player.activatePhaseShift()
        
        XCTAssertTrue(player.isPhaseShifted, "Player should be in phase shift mode")
        XCTAssertLessThan(player.energy, initialEnergy, "Phase shift should consume energy")
    }
    
    func testPlayerPowerUpCollection() {
        let powerUp = PowerUpNode(type: .shield)
        let initialHealth = player.health
        
        player.collectPowerUp(powerUp)
        
        XCTAssertTrue(player.activePowerUps.contains(.shield), "Player should have shield power-up")
        XCTAssertGreaterThan(player.health, initialHealth, "Shield power-up should increase health")
    }
    
    func testPlayerBoundaryConstraints() {
        // Test left boundary
        player.position = CGPoint(x: -100, y: 0)
        gameScene.update(0.1)
        XCTAssertGreaterThanOrEqual(player.position.x, 0, "Player should not go beyond left boundary")
        
        // Test right boundary
        player.position = CGPoint(x: gameScene.size.width + 100, y: 0)
        gameScene.update(0.1)
        XCTAssertLessThanOrEqual(player.position.x, gameScene.size.width, "Player should not go beyond right boundary")
        
        // Test bottom boundary
        player.position = CGPoint(x: 0, y: -100)
        gameScene.update(0.1)
        XCTAssertGreaterThanOrEqual(player.position.y, 0, "Player should not go beyond bottom boundary")
        
        // Test top boundary
        player.position = CGPoint(x: 0, y: gameScene.size.height + 100)
        gameScene.update(0.1)
        XCTAssertLessThanOrEqual(player.position.y, gameScene.size.height, "Player should not go beyond top boundary")
    }
    
    func testPlayerCollisionHandling() {
        let enemy = EnemyNode(type: .standard)
        enemy.position = player.position
        
        let contact = SKPhysicsContact(bodyA: player.physicsBody!, bodyB: enemy.physicsBody!)
        player.didBeginContact(contact)
        
        XCTAssertLessThan(player.health, GameConfig.PlayerSettings.maxHealth, "Player should take damage from enemy collision")
    }
    
    func testPlayerPerformance() {
        measure {
            for _ in 0..<100 {
                player.update(1/60)
            }
        }
    }
} 