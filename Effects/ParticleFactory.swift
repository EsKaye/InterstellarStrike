import SpriteKit

class ParticleFactory {
    // MARK: - Explosion Effects
    static func createEnemyExplosion(at position: CGPoint) -> SKEmitterNode {
        let emitter = SKEmitterNode()
        emitter.position = position
        
        // Configure particle properties
        emitter.particleTexture = SKTexture(imageNamed: "spark") // Placeholder
        emitter.particleBirthRate = 100
        emitter.numParticlesToEmit = 50
        emitter.particleLifetime = 0.5
        emitter.particleLifetimeRange = 0.2
        emitter.particleSpeed = 100
        emitter.particleSpeedRange = 50
        emitter.particleAlpha = 1.0
        emitter.particleAlphaRange = 0.5
        emitter.particleAlphaSpeed = -1.0
        emitter.particleScale = 0.5
        emitter.particleScaleRange = 0.2
        emitter.particleScaleSpeed = -0.5
        emitter.particleColor = .orange
        emitter.particleColorBlendFactor = 1.0
        emitter.particleColorBlendFactorRange = 0.5
        emitter.particleBlendMode = .add
        
        // Configure emission angle
        emitter.emissionAngle = 0
        emitter.emissionAngleRange = .pi * 2
        
        return emitter
    }
    
    // MARK: - PowerUp Effects
    static func createPowerUpBurst(at position: CGPoint, color: SKColor) -> SKEmitterNode {
        let emitter = SKEmitterNode()
        emitter.position = position
        
        // Configure particle properties
        emitter.particleTexture = SKTexture(imageNamed: "sparkle") // Placeholder
        emitter.particleBirthRate = 200
        emitter.numParticlesToEmit = 30
        emitter.particleLifetime = 0.8
        emitter.particleLifetimeRange = 0.3
        emitter.particleSpeed = 50
        emitter.particleSpeedRange = 20
        emitter.particleAlpha = 1.0
        emitter.particleAlphaRange = 0.3
        emitter.particleAlphaSpeed = -0.5
        emitter.particleScale = 0.3
        emitter.particleScaleRange = 0.1
        emitter.particleScaleSpeed = -0.2
        emitter.particleColor = color
        emitter.particleColorBlendFactor = 1.0
        emitter.particleBlendMode = .add
        
        // Configure emission angle
        emitter.emissionAngle = 0
        emitter.emissionAngleRange = .pi * 2
        
        return emitter
    }
    
    // MARK: - Phase Shift Effects
    static func createPhaseShiftSparkles(in scene: SKScene) -> SKEmitterNode {
        let emitter = SKEmitterNode()
        emitter.position = CGPoint(x: scene.size.width/2, y: scene.size.height/2)
        
        // Configure particle properties
        emitter.particleTexture = SKTexture(imageNamed: "sparkle") // Placeholder
        emitter.particleBirthRate = 50
        emitter.numParticlesToEmit = 100
        emitter.particleLifetime = 2.0
        emitter.particleLifetimeRange = 0.5
        emitter.particleSpeed = 30
        emitter.particleSpeedRange = 10
        emitter.particleAlpha = 0.8
        emitter.particleAlphaRange = 0.2
        emitter.particleAlphaSpeed = -0.2
        emitter.particleScale = 0.2
        emitter.particleScaleRange = 0.1
        emitter.particleScaleSpeed = -0.1
        emitter.particleColor = .purple
        emitter.particleColorBlendFactor = 1.0
        emitter.particleBlendMode = .add
        
        // Configure emission angle
        emitter.emissionAngle = 0
        emitter.emissionAngleRange = .pi * 2
        
        return emitter
    }
    
    // MARK: - Player Death Effect
    static func createPlayerDeathEffect(at position: CGPoint) -> SKEmitterNode {
        let emitter = SKEmitterNode()
        emitter.position = position
        
        // Configure particle properties
        emitter.particleTexture = SKTexture(imageNamed: "spark") // Placeholder
        emitter.particleBirthRate = 200
        emitter.numParticlesToEmit = 100
        emitter.particleLifetime = 1.0
        emitter.particleLifetimeRange = 0.3
        emitter.particleSpeed = 150
        emitter.particleSpeedRange = 50
        emitter.particleAlpha = 1.0
        emitter.particleAlphaRange = 0.3
        emitter.particleAlphaSpeed = -0.5
        emitter.particleScale = 0.4
        emitter.particleScaleRange = 0.2
        emitter.particleScaleSpeed = -0.3
        emitter.particleColor = .red
        emitter.particleColorBlendFactor = 1.0
        emitter.particleBlendMode = .add
        
        // Configure emission angle
        emitter.emissionAngle = 0
        emitter.emissionAngleRange = .pi * 2
        
        return emitter
    }
} 