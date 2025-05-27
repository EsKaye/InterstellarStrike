import SpriteKit

class PlayerHUD: SKNode {
    // MARK: - Properties
    private let healthBar: SKShapeNode
    private let energyBar: SKShapeNode
    private let powerUpTimers: [PowerUpType: SKLabelNode]
    private let scoreLabel: SKLabelNode
    
    // MARK: - Initialization
    init(size: CGSize) {
        // Create health bar
        healthBar = SKShapeNode(rectOf: CGSize(width: 200, height: 20), cornerRadius: 5)
        healthBar.fillColor = .green
        healthBar.strokeColor = .white
        healthBar.lineWidth = 2
        
        // Create energy bar
        energyBar = SKShapeNode(rectOf: CGSize(width: 200, height: 20), cornerRadius: 5)
        energyBar.fillColor = .blue
        energyBar.strokeColor = .white
        energyBar.lineWidth = 2
        
        // Create powerup timers
        var timers: [PowerUpType: SKLabelNode] = [:]
        for type in [PowerUpType.shield, .rapidFire, .slowTime] {
            let timer = SKLabelNode(fontNamed: "AvenirNext-Bold")
            timer.text = "\(type.icon) --:--"
            timer.fontSize = 16
            timer.fontColor = type.color
            timers[type] = timer
        }
        powerUpTimers = timers
        
        // Create score label
        scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 24
        
        super.init()
        
        // Position elements
        healthBar.position = CGPoint(x: size.width/2 - 110, y: size.height - 30)
        energyBar.position = CGPoint(x: size.width/2 - 110, y: size.height - 60)
        
        var yOffset: CGFloat = size.height - 90
        for (_, timer) in powerUpTimers {
            timer.position = CGPoint(x: size.width/2 - 110, y: yOffset)
            yOffset -= 30
        }
        
        scoreLabel.position = CGPoint(x: size.width - 100, y: size.height - 30)
        
        // Add to scene
        addChild(healthBar)
        addChild(energyBar)
        for (_, timer) in powerUpTimers {
            addChild(timer)
        }
        addChild(scoreLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Update Methods
    func updateHealth(_ health: CGFloat, maxHealth: CGFloat) {
        let healthPercentage = health / maxHealth
        let newWidth = 200 * healthPercentage
        
        // Animate health bar
        let resize = SKAction.resize(toWidth: newWidth, duration: 0.2)
        healthBar.run(resize)
        
        // Update color based on health
        let color = healthPercentage > 0.5 ? SKColor.green :
                   healthPercentage > 0.25 ? SKColor.yellow : SKColor.red
        healthBar.fillColor = color
    }
    
    func updateEnergy(_ energy: CGFloat, maxEnergy: CGFloat) {
        let energyPercentage = energy / maxEnergy
        let newWidth = 200 * energyPercentage
        
        // Animate energy bar
        let resize = SKAction.resize(toWidth: newWidth, duration: 0.2)
        energyBar.run(resize)
    }
    
    func updatePowerUpTimer(_ type: PowerUpType, timeRemaining: TimeInterval) {
        guard let timer = powerUpTimers[type] else { return }
        
        if timeRemaining > 0 {
            let minutes = Int(timeRemaining) / 60
            let seconds = Int(timeRemaining) % 60
            timer.text = "\(type.icon) \(String(format: "%02d:%02d", minutes, seconds))"
        } else {
            timer.text = "\(type.icon) --:--"
        }
    }
    
    func updateScore(_ score: Int) {
        scoreLabel.text = "Score: \(score)"
    }
    
    // MARK: - Visual Effects
    func showDamageEffect() {
        // Flash red
        let flash = SKAction.sequence([
            SKAction.colorize(with: .red, colorBlendFactor: 1.0, duration: 0.1),
            SKAction.colorize(with: .white, colorBlendFactor: 0.0, duration: 0.1)
        ])
        run(flash)
    }
    
    func showPowerUpActivated(_ type: PowerUpType) {
        guard let timer = powerUpTimers[type] else { return }
        
        // Pulse effect
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 0.1),
            SKAction.scale(to: 1.0, duration: 0.1)
        ])
        timer.run(pulse)
    }
} 