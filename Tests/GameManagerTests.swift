import XCTest
import SpriteKit
@testable import InterstellarStrike

class GameManagerTests: XCTestCase {
    var gameScene: GameScene!
    var gameManager: GameManager!
    
    override func setUp() {
        super.setUp()
        gameScene = GameScene(size: CGSize(width: 750, height: 1334))
        gameManager = GameManager.shared
    }
    
    override func tearDown() {
        gameScene = nil
        super.tearDown()
    }
    
    func testGameManagerInitialization() {
        XCTAssertNotNil(gameManager, "Game manager should be initialized")
        XCTAssertEqual(gameManager.score, 0, "Initial score should be 0")
        XCTAssertEqual(gameManager.scoreMultiplier, 1, "Initial score multiplier should be 1")
        XCTAssertFalse(gameManager.isPhaseShifted, "Game should not start in phase shift mode")
    }
    
    func testGameStateTransitions() {
        // Test playing state
        gameManager.transition(to: .playing, in: gameScene)
        XCTAssertEqual(gameManager.currentState, .playing, "Game should transition to playing state")
        
        // Test paused state
        gameManager.transition(to: .paused, in: gameScene)
        XCTAssertEqual(gameManager.currentState, .paused, "Game should transition to paused state")
        
        // Test game over state
        gameManager.transition(to: .gameOver, in: gameScene)
        XCTAssertEqual(gameManager.currentState, .gameOver, "Game should transition to game over state")
    }
    
    func testScoreManagement() {
        // Test basic score addition
        gameManager.addScore(100)
        XCTAssertEqual(gameManager.score, 100, "Score should be added correctly")
        
        // Test score multiplier
        gameManager.scoreMultiplier = 2
        gameManager.addScore(100)
        XCTAssertEqual(gameManager.score, 300, "Score should be multiplied correctly")
    }
    
    func testPowerUpManagement() {
        // Test power-up activation
        gameManager.activatePowerUp(.shield)
        XCTAssertTrue(gameManager.activePowerUps.contains(.shield), "Power-up should be activated")
        
        // Test power-up duration
        gameScene.update(GameConfig.PowerUpSettings.duration + 0.1)
        XCTAssertFalse(gameManager.activePowerUps.contains(.shield), "Power-up should expire after duration")
    }
    
    func testPhaseShiftManagement() {
        // Test phase shift activation
        gameManager.activatePhaseShift()
        XCTAssertTrue(gameManager.isPhaseShifted, "Phase shift should be activated")
        XCTAssertEqual(gameManager.scoreMultiplier, GameConfig.EnergyCoreSettings.scoreMultiplier, "Score multiplier should be applied")
        
        // Test phase shift duration
        gameScene.update(GameConfig.EnergyCoreSettings.phaseShiftDuration + 0.1)
        XCTAssertFalse(gameManager.isPhaseShifted, "Phase shift should end after duration")
        XCTAssertEqual(gameManager.scoreMultiplier, 1, "Score multiplier should return to normal")
    }
    
    func testEnemySpawnManagement() {
        // Test enemy spawn timing
        let initialTime = Date()
        var spawnCount = 0
        
        while Date().timeIntervalSince(initialTime) < GameConfig.EnemySettings.spawnInterval {
            if gameManager.shouldSpawnEnemy() {
                spawnCount += 1
            }
            gameScene.update(1.0)
        }
        
        XCTAssertEqual(spawnCount, 1, "Enemy should spawn once per interval")
    }
    
    func testGameOverHandling() {
        // Test game over state
        gameManager.transition(to: .gameOver, in: gameScene)
        
        XCTAssertEqual(gameManager.currentState, .gameOver, "Game should be in game over state")
        XCTAssertFalse(gameManager.isPhaseShifted, "Phase shift should be deactivated")
        XCTAssertEqual(gameManager.scoreMultiplier, 1, "Score multiplier should be reset")
        XCTAssertTrue(gameManager.activePowerUps.isEmpty, "All power-ups should be deactivated")
    }
    
    func testGameReset() {
        // Set up game state
        gameManager.addScore(1000)
        gameManager.activatePowerUp(.shield)
        gameManager.activatePhaseShift()
        
        // Reset game
        gameManager.reset()
        
        XCTAssertEqual(gameManager.score, 0, "Score should be reset")
        XCTAssertEqual(gameManager.scoreMultiplier, 1, "Score multiplier should be reset")
        XCTAssertFalse(gameManager.isPhaseShifted, "Phase shift should be deactivated")
        XCTAssertTrue(gameManager.activePowerUps.isEmpty, "All power-ups should be deactivated")
    }
    
    func testHighScoreManagement() {
        // Test high score update
        gameManager.addScore(1000)
        gameManager.updateHighScore()
        XCTAssertEqual(gameManager.highScore, 1000, "High score should be updated")
        
        // Test high score persistence
        gameManager.addScore(500)
        gameManager.updateHighScore()
        XCTAssertEqual(gameManager.highScore, 1000, "High score should not be updated with lower score")
    }
    
    func testGamePauseHandling() {
        // Test pause state
        gameManager.transition(to: .paused, in: gameScene)
        
        XCTAssertEqual(gameScene.physicsWorld.speed, 0, "Physics world should be paused")
        XCTAssertEqual(gameScene.isPaused, true, "Scene should be paused")
    }
    
    func testGameResumeHandling() {
        // Set up pause state
        gameManager.transition(to: .paused, in: gameScene)
        
        // Resume game
        gameManager.transition(to: .playing, in: gameScene)
        
        XCTAssertEqual(gameScene.physicsWorld.speed, 1, "Physics world should be resumed")
        XCTAssertEqual(gameScene.isPaused, false, "Scene should be resumed")
    }
    
    func testGameManagerPerformance() {
        measure {
            for _ in 0..<1000 {
                gameManager.update(1/60)
            }
        }
    }
} 