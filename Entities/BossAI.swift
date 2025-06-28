import SpriteKit

class BossAI {
    // MARK: - Properties
    let name: String
    let type: BossType
    var health: Double
    let maxHealth: Double
    let phaseCount: Int
    var currentPhase: Int = 1
    private var movePatterns: [Int: [BossMovePattern]] = [:]
    private var phaseThresholds: [Double]
    private var isTransitioning = false
    
    // MARK: - Phase Properties
    private var currentMoveIndex = 0
    private var moveCooldown: TimeInterval = 0
    private var lastMoveTime: TimeInterval = 0
    private var phaseStartTime: TimeInterval = 0
    
    // MARK: - Visual Effects
    private var energyField: SKEmitterNode?
    private var timeDistortion: SKEffectNode?
    private var phaseTransitionEffect: SKEmitterNode?
    
    // MARK: - Initialization
    init(type: BossType, health: Double, phaseCount: Int) {
        self.type = type
        self.name = type.title
        self.maxHealth = health
        self.health = health
        self.phaseCount = phaseCount
        
        // Calculate phase thresholds (e.g., 70%, 30% for 3 phases)
        self.phaseThresholds = (1..<phaseCount).map { phase in
            Double(phaseCount - phase) / Double(phaseCount)
        }
        
        setupMovePatterns()
    }
    
    // MARK: - Setup
    private func setupMovePatterns() {
        // Phase 1 moves
        movePatterns[1] = [
            .voidPulse(count: 8, speed: 200),
            .chronoSlam(duration: 2.0, damage: 50),
            .quantumSpiral(count: 3, speed: 150)
        ]
        
        // Phase 2 moves
        movePatterns[2] = [
            .voidPulse(count: 12, speed: 250),
            .chronoSlam(duration: 1.5, damage: 75),
            .quantumSpiral(count: 5, speed: 200),
            .summonMinions(count: 3)
        ]
        
        // Phase 3 moves
        movePatterns[3] = [
            .voidPulse(count: 16, speed: 300),
            .chronoSlam(duration: 1.0, damage: 100),
            .quantumSpiral(count: 8, speed: 250),
            .summonMinions(count: 5),
            .voidCorruption(radius: 200, duration: 3.0)
        ]
    }
    
    // MARK: - Update
    func update(deltaTime: TimeInterval, bossNode: SKSpriteNode, scene: SKScene) {
        guard !isTransitioning else { return }
        
        // Check for phase transition
        checkPhaseTransition()
        
        // Update move cooldown
        moveCooldown -= deltaTime
        
        // Execute next move if cooldown is ready
        if moveCooldown <= 0 {
            executeNextMove(bossNode: bossNode, scene: scene)
        }
    }
    
    // MARK: - Phase Management
    private func checkPhaseTransition() {
        let healthPercentage = health / maxHealth
        
        for (index, threshold) in phaseThresholds.enumerated() {
            if healthPercentage <= threshold && currentPhase == index + 1 {
                transitionToPhase(index + 2)
                break
            }
        }
    }
    
    private func transitionToPhase(_ newPhase: Int) {
        guard newPhase <= phaseCount else { return }
        
        isTransitioning = true
        currentPhase = newPhase
        phaseStartTime = Date().timeIntervalSince1970
        
        // Reset move index for new phase
        currentMoveIndex = 0
        
        // Trigger phase transition effects
        triggerPhaseTransitionEffects()
        
        // Notify phase change
        NotificationCenter.default.post(
            name: .bossPhaseChanged,
            object: nil,
            userInfo: [
                "bossType": type,
                "newPhase": newPhase,
                "healthPercentage": health / maxHealth
            ]
        )
        
        // Unlock phase-specific lore
        unlockPhaseLore()
        
        isTransitioning = false
    }
    
    private func triggerPhaseTransitionEffects() {
        // Create energy flare
        if let flareEmitter = SKEmitterNode(fileNamed: "PhaseTransitionFlare") {
            flareEmitter.position = CGPoint(x: 0, y: 0)
            flareEmitter.zPosition = 1
            phaseTransitionEffect = flareEmitter
        }
        
        // Apply time distortion
        timeDistortion?.filter = CIFilter(name: "CIMotionBlur")
        if let filter = timeDistortion?.filter as? CIFilter {
            filter.setValue(20.0, forKey: "inputRadius")
            filter.setValue(0.0, forKey: "inputAngle")
        }
        
        // Animate effects
        let sequence = SKAction.sequence([
            SKAction.fadeIn(withDuration: 0.5),
            SKAction.wait(forDuration: 1.0),
            SKAction.fadeOut(withDuration: 0.5)
        ])
        
        phaseTransitionEffect?.run(sequence)
        timeDistortion?.run(sequence)
    }
    
    // MARK: - Move Execution
    private func executeNextMove(bossNode: SKSpriteNode, scene: SKScene) {
        guard let currentMoves = movePatterns[currentPhase],
              !currentMoves.isEmpty else { return }
        
        let move = currentMoves[currentMoveIndex]
        move.execute(from: bossNode, in: scene)
        
        // Update move index and cooldown
        currentMoveIndex = (currentMoveIndex + 1) % currentMoves.count
        moveCooldown = move.cooldown
        
        // Log move execution
        NotificationCenter.default.post(
            name: .bossMoveExecuted,
            object: nil,
            userInfo: [
                "bossType": type,
                "phase": currentPhase,
                "move": move
            ]
        )
    }
    
    // MARK: - Lore Management
    private func unlockPhaseLore() {
        let loreEntry = BossLoreEntry(
            id: "\(type)_phase_\(currentPhase)",
            title: "\(name) - Phase \(currentPhase)",
            description: type.phaseDescription(currentPhase),
            unlockCondition: .custom("boss_phase_\(currentPhase)"),
            tier: .mythic,
            isUnlocked: false
        )
        
        NotificationCenter.default.post(
            name: .newLoreUnlocked,
            object: nil,
            userInfo: ["loreEntry": loreEntry]
        )
    }
}

// MARK: - Notifications
extension Notification.Name {
    static let bossPhaseChanged = Notification.Name("bossPhaseChanged")
    static let bossMoveExecuted = Notification.Name("bossMoveExecuted")
}

// MARK: - Boss Type Extensions
extension BossType {
    func phaseDescription(_ phase: Int) -> String {
        switch self {
        case .voidCorruptor:
            switch phase {
            case 1: return "The Void Corruptor begins to manifest, its form shifting between dimensions."
            case 2: return "As its power grows, the Void Corruptor begins to corrupt the space around it."
            case 3: return "At its full power, the Void Corruptor threatens to consume all of reality."
            default: return ""
            }
        case .temporalWarden:
            switch phase {
            case 1: return "The Temporal Warden emerges, its form flickering between past and future."
            case 2: return "Time itself begins to bend as the Warden's power increases."
            case 3: return "The Temporal Warden reaches its peak, threatening to collapse the timeline."
            default: return ""
            }
        case .quantumBehemoth:
            switch phase {
            case 1: return "The Quantum Behemoth materializes, its form existing in multiple states."
            case 2: return "Quantum fluctuations intensify as the Behemoth's power grows."
            case 3: return "The Quantum Behemoth reaches its final form, threatening to collapse all possibilities."
            default: return ""
            }
        }
    }
} 