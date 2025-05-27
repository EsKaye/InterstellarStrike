import XCTest
import SpriteKit
@testable import InterstellarStrike

class VisualEffectsTests: XCTestCase {
    var gameScene: GameScene!
    var camera: SKCameraNode!
    
    override func setUp() {
        super.setUp()
        gameScene = GameScene(size: CGSize(width: 750, height: 1334))
        camera = SKCameraNode()
        gameScene.camera = camera
        gameScene.addChild(camera)
    }
    
    override func tearDown() {
        gameScene = nil
        super.tearDown()
    }
    
    // MARK: - Screen Shake Tests
    func testScreenShakeCreation() {
        let screenShake = ScreenShake(camera: camera)
        
        XCTAssertNotNil(screenShake, "Screen shake should be created")
        XCTAssertEqual(screenShake.camera, camera, "Screen shake should have correct camera reference")
    }
    
    func testScreenShakeIntensity() {
        let screenShake = ScreenShake(camera: camera)
        let initialPosition = camera.position
        
        screenShake.shake(intensity: 10.0, duration: 0.5)
        
        XCTAssertNotEqual(camera.position, initialPosition, "Camera should move during shake")
        XCTAssertTrue(screenShake.isShaking, "Screen should be shaking")
    }
    
    func testScreenShakeDuration() {
        let screenShake = ScreenShake(camera: camera)
        let initialPosition = camera.position
        
        screenShake.shake(intensity: 10.0, duration: 0.5)
        gameScene.update(0.6)
        
        XCTAssertEqual(camera.position, initialPosition, "Camera should return to initial position after shake")
        XCTAssertFalse(screenShake.isShaking, "Screen should not be shaking")
    }
    
    func testScreenShakePresets() {
        let screenShake = ScreenShake(camera: camera)
        
        // Test enemy death shake
        screenShake.shakeEnemyDeath()
        XCTAssertTrue(screenShake.isShaking, "Screen should shake for enemy death")
        
        // Test player damage shake
        screenShake.shakePlayerDamage()
        XCTAssertTrue(screenShake.isShaking, "Screen should shake for player damage")
        
        // Test energy core shake
        screenShake.shakeEnergyCore()
        XCTAssertTrue(screenShake.isShaking, "Screen should shake for energy core")
        
        // Test phase shift shake
        screenShake.shakePhaseShift()
        XCTAssertTrue(screenShake.isShaking, "Screen should shake for phase shift")
    }
    
    // MARK: - Parallax Background Tests
    func testParallaxBackgroundCreation() {
        let background = ParallaxBackground(size: gameScene.size)
        
        XCTAssertNotNil(background, "Parallax background should be created")
        XCTAssertEqual(background.layers.count, GameConfig.VisualEffectsSettings.ParallaxBackground.layerCount, "Background should have correct number of layers")
    }
    
    func testParallaxBackgroundMovement() {
        let background = ParallaxBackground(size: gameScene.size)
        gameScene.addChild(background)
        
        let initialPositions = background.layers.map { $0.position }
        
        gameScene.update(1.0)
        
        for (index, layer) in background.layers.enumerated() {
            XCTAssertNotEqual(layer.position, initialPositions[index], "Layer should move")
        }
    }
    
    func testParallaxBackgroundOscillation() {
        let background = ParallaxBackground(size: gameScene.size)
        gameScene.addChild(background)
        
        let initialY = background.layers[0].position.y
        
        gameScene.update(GameConfig.VisualEffectsSettings.ParallaxBackground.oscillationFrequency)
        
        XCTAssertNotEqual(background.layers[0].position.y, initialY, "Layer should oscillate vertically")
    }
    
    func testParallaxBackgroundPhaseShift() {
        let background = ParallaxBackground(size: gameScene.size)
        gameScene.addChild(background)
        
        background.applyPhaseShiftEffects()
        
        for layer in background.layers {
            XCTAssertNotEqual(layer.color, .white, "Layer color should change during phase shift")
        }
    }
    
    // MARK: - Particle System Tests
    func testParticleFactory() {
        // Test explosion particles
        let explosion = ParticleFactory.createEnemyExplosion(at: CGPoint(x: 100, y: 100))
        XCTAssertNotNil(explosion, "Explosion particles should be created")
        XCTAssertEqual(explosion.particleCount, GameConfig.VisualEffectsSettings.Particles.explosionParticleCount, "Explosion should have correct particle count")
        
        // Test power-up particles
        let powerUp = ParticleFactory.createPowerUpBurst(at: CGPoint(x: 100, y: 100), color: .cyan)
        XCTAssertNotNil(powerUp, "Power-up particles should be created")
        XCTAssertEqual(powerUp.particleCount, GameConfig.VisualEffectsSettings.Particles.powerUpParticleCount, "Power-up should have correct particle count")
        
        // Test phase shift particles
        let phaseShift = ParticleFactory.createPhaseShiftSparkles(in: gameScene)
        XCTAssertNotNil(phaseShift, "Phase shift particles should be created")
        XCTAssertEqual(phaseShift.particleCount, GameConfig.VisualEffectsSettings.Particles.phaseShiftParticleCount, "Phase shift should have correct particle count")
        
        // Test player death particles
        let playerDeath = ParticleFactory.createPlayerDeathEffect(at: CGPoint(x: 100, y: 100))
        XCTAssertNotNil(playerDeath, "Player death particles should be created")
        XCTAssertEqual(playerDeath.particleCount, GameConfig.VisualEffectsSettings.Particles.playerDeathParticleCount, "Player death should have correct particle count")
    }
    
    func testParticleSystemPerformance() {
        measure {
            for _ in 0..<100 {
                _ = ParticleFactory.createEnemyExplosion(at: CGPoint(x: 100, y: 100))
            }
        }
    }
    
    // MARK: - Visual Effects Integration Tests
    func testVisualEffectsIntegration() {
        let screenShake = ScreenShake(camera: camera)
        let background = ParallaxBackground(size: gameScene.size)
        gameScene.addChild(background)
        
        // Test phase shift effects
        screenShake.shakePhaseShift()
        background.applyPhaseShiftEffects()
        
        XCTAssertTrue(screenShake.isShaking, "Screen should shake during phase shift")
        XCTAssertNotEqual(background.layers[0].color, .white, "Background should change during phase shift")
    }
    
    func testVisualEffectsCleanup() {
        let screenShake = ScreenShake(camera: camera)
        let background = ParallaxBackground(size: gameScene.size)
        gameScene.addChild(background)
        
        // Apply effects
        screenShake.shakePhaseShift()
        background.applyPhaseShiftEffects()
        
        // Cleanup
        screenShake.stopShake()
        background.removePhaseShiftEffects()
        
        XCTAssertFalse(screenShake.isShaking, "Screen shake should be stopped")
        XCTAssertEqual(background.layers[0].color, .white, "Background should return to normal")
    }
} 