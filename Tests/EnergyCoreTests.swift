import XCTest
import SpriteKit
@testable import InterstellarStrike

class EnergyCoreTests: XCTestCase {
    var gameScene: GameScene!
    var player: Player!
    var gameManager: GameManager!
    
    override func setUp() {
        super.setUp()
        gameScene = GameScene(size: CGSize(width: 750, height: 1334))
        player = Player()
        gameManager = GameManager.shared
        gameScene.addChild(player)
    }
    
    override func tearDown() {
        player.removeFromParent()
        player = nil
        gameScene = nil
        super.tearDown()
    }
    
    func testEnergyCoreCreation() {
        let energyCore = EnergyCoreFactory.spawnEnergyCore(in: gameScene)
        
        XCTAssertNotNil(energyCore, "Energy core should be created")
        XCTAssertEqual(energyCore.color, GameConfig.EnergyCoreSettings.color, "Energy core should have correct color")
        XCTAssertTrue(gameScene.children.contains(energyCore), "Energy core should be added to scene")
    }
    
    func testEnergyCoreCollection() {
        let energyCore = EnergyCoreFactory.spawnEnergyCore(in: gameScene)
        energyCore.position = player.position
        
        let contact = SKPhysicsContact(bodyA: player.physicsBody!, bodyB: energyCore.physicsBody!)
        player.didBeginContact(contact)
        
        XCTAssertTrue(gameManager.isPhaseShifted, "Game should enter phase shift mode")
        XCTAssertFalse(gameScene.children.contains(energyCore), "Energy core should be removed after collection")
    }
    
    func testPhaseShiftEffects() {
        let energyCore = EnergyCoreFactory.spawnEnergyCore(in: gameScene)
        energyCore.position = player.position
        
        let contact = SKPhysicsContact(bodyA: player.physicsBody!, bodyB: energyCore.physicsBody!)
        player.didBeginContact(contact)
        
        XCTAssertTrue(player.isPhaseShifted, "Player should be in phase shift mode")
        XCTAssertEqual(gameManager.scoreMultiplier, GameConfig.EnergyCoreSettings.scoreMultiplier, "Score multiplier should be applied")
    }
    
    func testPhaseShiftDuration() {
        let energyCore = EnergyCoreFactory.spawnEnergyCore(in: gameScene)
        energyCore.position = player.position
        
        let contact = SKPhysicsContact(bodyA: player.physicsBody!, bodyB: energyCore.physicsBody!)
        player.didBeginContact(contact)
        
        gameScene.update(GameConfig.EnergyCoreSettings.phaseShiftDuration + 0.1)
        
        XCTAssertFalse(gameManager.isPhaseShifted, "Phase shift should end after duration")
        XCTAssertEqual(gameManager.scoreMultiplier, 1, "Score multiplier should return to normal")
    }
    
    func testEnergyCoreSpawnInterval() {
        let initialTime = Date()
        var spawnCount = 0
        
        while Date().timeIntervalSince(initialTime) < GameConfig.EnergyCoreSettings.spawnInterval {
            if EnergyCoreFactory.shouldSpawnEnergyCore() {
                spawnCount += 1
            }
            gameScene.update(1.0)
        }
        
        XCTAssertEqual(spawnCount, 1, "Energy core should spawn once per interval")
    }
    
    func testEnergyCoreMovement() {
        let energyCore = EnergyCoreFactory.spawnEnergyCore(in: gameScene)
        let initialPosition = energyCore.position
        
        gameScene.update(1.0)
        
        XCTAssertNotEqual(energyCore.position, initialPosition, "Energy core should move")
    }
    
    func testEnergyCoreBoundaryHandling() {
        let energyCore = EnergyCoreFactory.spawnEnergyCore(in: gameScene)
        
        // Test bottom boundary
        energyCore.position = CGPoint(x: 0, y: -100)
        gameScene.update(0.1)
        XCTAssertFalse(gameScene.children.contains(energyCore), "Energy core should be removed when off screen")
    }
    
    func testEnergyCoreVisualEffects() {
        let energyCore = EnergyCoreFactory.spawnEnergyCore(in: gameScene)
        
        XCTAssertNotNil(energyCore.particleEmitter, "Energy core should have particle effects")
        XCTAssertTrue(energyCore.hasActions(), "Energy core should have animations")
    }
    
    func testEnergyCorePhysics() {
        let energyCore = EnergyCoreFactory.spawnEnergyCore(in: gameScene)
        
        XCTAssertNotNil(energyCore.physicsBody, "Energy core should have physics body")
        XCTAssertEqual(energyCore.physicsBody?.categoryBitMask, GameConfig.PhysicsCategories.energyCore, "Energy core should have correct physics category")
    }
    
    func testEnergyCorePerformance() {
        measure {
            for _ in 0..<100 {
                let energyCore = EnergyCoreFactory.spawnEnergyCore(in: gameScene)
                for _ in 0..<10 {
                    energyCore.update(1/60)
                }
            }
        }
    }
    
    func testMultipleEnergyCores() {
        let energyCore1 = EnergyCoreFactory.spawnEnergyCore(in: gameScene)
        let energyCore2 = EnergyCoreFactory.spawnEnergyCore(in: gameScene)
        
        XCTAssertTrue(gameScene.children.contains(energyCore1), "First energy core should be in scene")
        XCTAssertTrue(gameScene.children.contains(energyCore2), "Second energy core should be in scene")
    }
    
    func testEnergyCoreScoreMultiplier() {
        let energyCore = EnergyCoreFactory.spawnEnergyCore(in: gameScene)
        energyCore.position = player.position
        
        let contact = SKPhysicsContact(bodyA: player.physicsBody!, bodyB: energyCore.physicsBody!)
        player.didBeginContact(contact)
        
        let initialScore = gameManager.score
        gameManager.addScore(100)
        
        XCTAssertEqual(gameManager.score - initialScore, 100 * GameConfig.EnergyCoreSettings.scoreMultiplier, "Score should be multiplied during phase shift")
    }
} 