import XCTest
import SpriteKit
@testable import InterstellarStrike

class GameTests: XCTestCase {
    // MARK: - Properties
    var gameScene: GameScene!
    var assetManager: AssetManager!
    var audioManager: AudioManager!
    
    // MARK: - Setup
    override func setUp() {
        super.setUp()
        gameScene = GameScene(size: CGSize(width: 750, height: 1334))
        assetManager = AssetManager.shared
        audioManager = AudioManager.shared
    }
    
    override func tearDown() {
        gameScene = nil
        super.tearDown()
    }
    
    // MARK: - Asset Manager Tests
    func testAssetLoading() {
        // Test texture loading
        let playerTexture = assetManager.getTexture("player_ship")
        XCTAssertNotNil(playerTexture, "Player ship texture should load successfully")
        
        // Test sound loading
        let laserSound = assetManager.getSound("sfx_laser")
        XCTAssertNotNil(laserSound, "Laser sound should load successfully")
        
        // Test particle effect loading
        let explosionEffect = assetManager.getParticleEffect("explosion_particles")
        XCTAssertNotNil(explosionEffect, "Explosion particles should load successfully")
    }
    
    // MARK: - Audio Manager Tests
    func testAudioPlayback() {
        // Test background music
        audioManager.playBackgroundMusic("bgm_main")
        XCTAssertNotNil(audioManager.currentMusic, "Background music should be playing")
        
        // Test sound effects
        audioManager.playSoundEffect("sfx_laser")
        // Note: We can't directly test if sound is playing, but we can test if it doesn't crash
    }
    
    // MARK: - Game Config Tests
    func testGameConfiguration() {
        // Test player settings
        XCTAssertEqual(GameConfig.PlayerSettings.maxHealth, 100)
        XCTAssertEqual(GameConfig.PlayerSettings.moveSpeed, 300)
        
        // Test enemy settings
        XCTAssertEqual(GameConfig.EnemySettings.maxEnemies, 20)
        XCTAssertEqual(GameConfig.EnemySettings.Standard.health, 1)
        
        // Test power-up settings
        XCTAssertEqual(GameConfig.PowerUpSettings.duration, 5.0)
        XCTAssertEqual(GameConfig.PowerUpSettings.Shield.damageReduction, 0.5)
    }
    
    // MARK: - Physics Tests
    func testPhysicsCategories() {
        // Test category bitmasks
        XCTAssertEqual(GameConfig.PhysicsCategories.player, 0b1)
        XCTAssertEqual(GameConfig.PhysicsCategories.enemy, 0b10)
        XCTAssertEqual(GameConfig.PhysicsCategories.laser, 0b100)
        
        // Test category combinations
        let playerLaserCategory = GameConfig.PhysicsCategories.player | GameConfig.PhysicsCategories.laser
        XCTAssertEqual(playerLaserCategory, 0b101)
    }
    
    // MARK: - Visual Effects Tests
    func testScreenShake() {
        let camera = SKCameraNode()
        let screenShake = ScreenShake(camera: camera)
        
        // Test shake intensity
        screenShake.shake(intensity: 10.0, duration: 0.5)
        XCTAssertTrue(screenShake.isShaking, "Screen should be shaking")
    }
    
    func testParallaxBackground() {
        let background = ParallaxBackground(size: CGSize(width: 750, height: 1334))
        
        // Test layer count
        XCTAssertEqual(background.layers.count, GameConfig.VisualEffectsSettings.ParallaxBackground.layerCount)
        
        // Test update
        background.update(deltaTime: 1/60)
        // Note: We can't directly test visual updates, but we can test if it doesn't crash
    }
    
    // MARK: - Particle System Tests
    func testParticleEffects() {
        // Test explosion particles
        let explosion = ParticleFactory.createEnemyExplosion(at: CGPoint(x: 100, y: 100))
        XCTAssertNotNil(explosion, "Explosion particles should be created")
        
        // Test power-up particles
        let powerUp = ParticleFactory.createPowerUpBurst(at: CGPoint(x: 100, y: 100), color: .cyan)
        XCTAssertNotNil(powerUp, "Power-up particles should be created")
    }
    
    // MARK: - Game State Tests
    func testGameStateTransitions() {
        let gameManager = GameManager.shared
        
        // Test state transitions
        gameManager.transition(to: .playing, in: gameScene)
        XCTAssertEqual(gameManager.currentState, .playing)
        
        gameManager.transition(to: .paused, in: gameScene)
        XCTAssertEqual(gameManager.currentState, .paused)
    }
    
    // MARK: - Performance Tests
    func testPerformance() {
        measure {
            // Test particle system performance
            for _ in 0..<100 {
                _ = ParticleFactory.createEnemyExplosion(at: CGPoint(x: 100, y: 100))
            }
        }
    }
} 