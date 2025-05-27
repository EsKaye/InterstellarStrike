import SpriteKit

class GameConfig {
    // MARK: - Singleton
    static let shared = GameConfig()
    private init() {}
    
    // MARK: - Game Settings
    struct GameSettings {
        static let targetFPS: Int = 60
        static let physicsWorldGravity = CGVector(dx: 0, dy: 0)
        static let defaultSceneSize = CGSize(width: 750, height: 1334)
    }
    
    // MARK: - Player Settings
    struct PlayerSettings {
        static let maxHealth: CGFloat = 100
        static let maxEnergy: CGFloat = 100
        static let moveSpeed: CGFloat = 300
        static let fireRate: TimeInterval = 0.2
        static let laserSpeed: CGFloat = 500
        static let laserDamage: Int = 10
    }
    
    // MARK: - Enemy Settings
    struct EnemySettings {
        static let spawnInterval: TimeInterval = 1.0
        static let maxEnemies: Int = 20
        
        struct Standard {
            static let health: Int = 1
            static let score: Int = 10
            static let moveSpeed: CGFloat = 100
        }
        
        struct Zigzag {
            static let health: Int = 2
            static let score: Int = 20
            static let moveSpeed: CGFloat = 80
            static let zigzagFrequency: TimeInterval = 1.0
            static let zigzagAmplitude: CGFloat = 100
        }
        
        struct Divebomb {
            static let health: Int = 1
            static let score: Int = 15
            static let moveSpeed: CGFloat = 200
            static let diveSpeed: CGFloat = 400
        }
        
        struct Hover {
            static let health: Int = 3
            static let score: Int = 25
            static let moveSpeed: CGFloat = 50
            static let shootInterval: TimeInterval = 1.5
        }
        
        struct Boss {
            static let health: Int = 10
            static let score: Int = 100
            static let moveSpeed: CGFloat = 30
            static let shootInterval: TimeInterval = 1.0
            static let phaseDuration: TimeInterval = 10.0
        }
    }
    
    // MARK: - PowerUp Settings
    struct PowerUpSettings {
        static let spawnChance: Double = 0.3
        static let duration: TimeInterval = 5.0
        
        struct Shield {
            static let damageReduction: CGFloat = 0.5
            static let color: SKColor = .cyan
        }
        
        struct RapidFire {
            static let fireRateMultiplier: CGFloat = 2.0
            static let color: SKColor = .orange
        }
        
        struct SlowTime {
            static let timeScale: CGFloat = 0.5
            static let color: SKColor = .purple
        }
    }
    
    // MARK: - Energy Core Settings
    struct EnergyCoreSettings {
        static let spawnInterval: TimeInterval = 30.0
        static let phaseShiftDuration: TimeInterval = 10.0
        static let scoreMultiplier: Int = 2
        static let color: SKColor = .yellow
    }
    
    // MARK: - Visual Effects Settings
    struct VisualEffectsSettings {
        struct ScreenShake {
            static let enemyDeathIntensity: CGFloat = 5.0
            static let enemyDeathDuration: TimeInterval = 0.3
            static let playerDamageIntensity: CGFloat = 15.0
            static let playerDamageDuration: TimeInterval = 0.5
            static let energyCoreIntensity: CGFloat = 20.0
            static let energyCoreDuration: TimeInterval = 0.8
            static let phaseShiftIntensity: CGFloat = 25.0
            static let phaseShiftDuration: TimeInterval = 1.0
        }
        
        struct ParallaxBackground {
            static let layerCount: Int = 5
            static let baseSpeed: CGFloat = 20.0
            static let oscillationAmplitude: CGFloat = 5.0
            static let oscillationFrequency: TimeInterval = 2.0
        }
        
        struct Particles {
            static let explosionParticleCount: Int = 50
            static let powerUpParticleCount: Int = 30
            static let phaseShiftParticleCount: Int = 100
            static let playerDeathParticleCount: Int = 100
        }
    }
    
    // MARK: - UI Settings
    struct UISettings {
        static let healthBarWidth: CGFloat = 200
        static let healthBarHeight: CGFloat = 20
        static let energyBarWidth: CGFloat = 200
        static let energyBarHeight: CGFloat = 20
        static let powerUpTimerFontSize: CGFloat = 16
        static let scoreFontSize: CGFloat = 24
        static let gameOverFontSize: CGFloat = 48
    }
    
    // MARK: - Physics Categories
    struct PhysicsCategories {
        static let none: UInt32 = 0
        static let player: UInt32 = 0b1
        static let enemy: UInt32 = 0b10
        static let laser: UInt32 = 0b100
        static let powerUp: UInt32 = 0b1000
        static let energyCore: UInt32 = 0b10000
    }
} 