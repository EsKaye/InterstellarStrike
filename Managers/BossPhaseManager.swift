import SpriteKit
import AVFoundation

class BossPhaseManager {
    // MARK: - Properties
    private let bossAI: BossAI
    private let scene: SKScene
    private var phaseTransitionEffect: SKEmitterNode?
    private var phaseMusicLayer: AVAudioPlayer?
    private var isTransitioning = false
    
    // MARK: - Visual Effects
    private var energyField: SKEmitterNode?
    private var timeDistortion: SKEffectNode?
    private var phaseIndicator: SKLabelNode?
    
    // MARK: - Initialization
    init(bossAI: BossAI, scene: SKScene) {
        self.bossAI = bossAI
        self.scene = scene
        
        setupNotifications()
        setupVisualEffects()
    }
    
    // MARK: - Setup
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePhaseChange(_:)),
            name: .bossPhaseChanged,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMoveExecution(_:)),
            name: .bossMoveExecuted,
            object: nil
        )
    }
    
    private func setupVisualEffects() {
        // Setup energy field
        if let energyEmitter = SKEmitterNode(fileNamed: "BossEnergyField") {
            energyField = energyEmitter
            energyField?.position = CGPoint(x: scene.frame.midX, y: scene.frame.midY)
            energyField?.zPosition = 1
            energyField?.alpha = 0
            scene.addChild(energyField!)
        }
        
        // Setup time distortion
        timeDistortion = SKEffectNode()
        timeDistortion?.filter = CIFilter(name: "CIMotionBlur")
        if let filter = timeDistortion?.filter as? CIFilter {
            filter.setValue(20.0, forKey: "inputRadius")
            filter.setValue(0.0, forKey: "inputAngle")
        }
        timeDistortion?.alpha = 0
        scene.addChild(timeDistortion!)
        
        // Setup phase indicator
        phaseIndicator = SKLabelNode(fontNamed: "AvenirNext-Bold")
        phaseIndicator?.fontSize = 24
        phaseIndicator?.fontColor = .white
        phaseIndicator?.position = CGPoint(x: scene.frame.midX, y: scene.frame.maxY - 50)
        phaseIndicator?.alpha = 0
        scene.addChild(phaseIndicator!)
    }
    
    // MARK: - Phase Management
    @objc private func handlePhaseChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let bossType = userInfo["bossType"] as? BossType,
              let newPhase = userInfo["newPhase"] as? Int,
              let healthPercentage = userInfo["healthPercentage"] as? Double else {
            return
        }
        
        // Start phase transition
        startPhaseTransition(to: newPhase, healthPercentage: healthPercentage)
    }
    
    private func startPhaseTransition(to newPhase: Int, healthPercentage: Double) {
        guard !isTransitioning else { return }
        isTransitioning = true
        
        // Update phase indicator
        phaseIndicator?.text = "Phase \(newPhase)"
        
        // Create transition sequence
        let transitionSequence = SKAction.sequence([
            // Initial effects
            SKAction.run { [weak self] in
                self?.triggerPhaseTransitionEffects()
            },
            SKAction.wait(forDuration: 0.5),
            
            // Update music layer
            SKAction.run { [weak self] in
                self?.updateMusicLayer(for: newPhase)
            },
            
            // Show phase indicator
            SKAction.run { [weak self] in
                self?.showPhaseIndicator()
            },
            
            // Final effects
            SKAction.run { [weak self] in
                self?.completePhaseTransition()
            }
        ])
        
        scene.run(transitionSequence) { [weak self] in
            self?.isTransitioning = false
        }
    }
    
    private func triggerPhaseTransitionEffects() {
        // Create energy flare
        if let flareEmitter = SKEmitterNode(fileNamed: "PhaseTransitionFlare") {
            flareEmitter.position = CGPoint(x: scene.frame.midX, y: scene.frame.midY)
            flareEmitter.zPosition = 2
            phaseTransitionEffect = flareEmitter
            scene.addChild(flareEmitter)
            
            // Animate flare
            let flareSequence = SKAction.sequence([
                SKAction.fadeIn(withDuration: 0.3),
                SKAction.scale(to: 2.0, duration: 0.5),
                SKAction.fadeOut(withDuration: 0.3),
                SKAction.removeFromParent()
            ])
            
            flareEmitter.run(flareSequence)
        }
        
        // Animate energy field
        energyField?.run(SKAction.sequence([
            SKAction.fadeIn(withDuration: 0.3),
            SKAction.scale(to: 1.5, duration: 0.5),
            SKAction.scale(to: 1.0, duration: 0.3)
        ]))
        
        // Animate time distortion
        timeDistortion?.run(SKAction.sequence([
            SKAction.fadeIn(withDuration: 0.3),
            SKAction.wait(forDuration: 0.5),
            SKAction.fadeOut(withDuration: 0.3)
        ]))
    }
    
    private func updateMusicLayer(for phase: Int) {
        // Stop current music layer
        phaseMusicLayer?.stop()
        
        // Load and play new music layer
        if let musicURL = Bundle.main.url(forResource: "boss_phase_\(phase)", withExtension: "mp3") {
            do {
                phaseMusicLayer = try AVAudioPlayer(contentsOf: musicURL)
                phaseMusicLayer?.numberOfLoops = -1 // Loop indefinitely
                phaseMusicLayer?.volume = 0.7
                phaseMusicLayer?.play()
            } catch {
                print("Failed to load phase music: \(error)")
            }
        }
    }
    
    private func showPhaseIndicator() {
        // Animate phase indicator
        let indicatorSequence = SKAction.sequence([
            SKAction.fadeIn(withDuration: 0.3),
            SKAction.scale(to: 1.2, duration: 0.2),
            SKAction.scale(to: 1.0, duration: 0.2),
            SKAction.wait(forDuration: 1.0),
            SKAction.fadeOut(withDuration: 0.3)
        ])
        
        phaseIndicator?.run(indicatorSequence)
    }
    
    private func completePhaseTransition() {
        // Clean up transition effects
        phaseTransitionEffect?.removeFromParent()
        phaseTransitionEffect = nil
        
        // Update energy field color based on phase
        if let energyField = energyField {
            let colorAction = SKAction.colorize(
                with: phaseColor(for: bossAI.currentPhase),
                colorBlendFactor: 1.0,
                duration: 0.5
            )
            energyField.run(colorAction)
        }
    }
    
    // MARK: - Move Execution
    @objc private func handleMoveExecution(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let bossType = userInfo["bossType"] as? BossType,
              let phase = userInfo["phase"] as? Int,
              let move = userInfo["move"] as? BossMovePattern else {
            return
        }
        
        // Show move warning
        showMoveWarning(for: move, in: phase)
    }
    
    private func showMoveWarning(for move: BossMovePattern, in phase: Int) {
        // Create warning label
        let warningLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        warningLabel.fontSize = 20
        warningLabel.fontColor = .red
        warningLabel.position = CGPoint(x: scene.frame.midX, y: scene.frame.maxY - 100)
        warningLabel.alpha = 0
        scene.addChild(warningLabel)
        
        // Set warning text based on move
        switch move {
        case .voidPulse:
            warningLabel.text = "Void Pulse Incoming!"
        case .chronoSlam:
            warningLabel.text = "Chrono Slam Warning!"
        case .quantumSpiral:
            warningLabel.text = "Quantum Spiral Detected!"
        case .summonMinions:
            warningLabel.text = "Minions Being Summoned!"
        case .voidCorruption:
            warningLabel.text = "Void Corruption Spreading!"
        }
        
        // Animate warning
        let warningSequence = SKAction.sequence([
            SKAction.fadeIn(withDuration: 0.2),
            SKAction.scale(to: 1.2, duration: 0.2),
            SKAction.scale(to: 1.0, duration: 0.2),
            SKAction.wait(forDuration: 0.5),
            SKAction.fadeOut(withDuration: 0.2),
            SKAction.removeFromParent()
        ])
        
        warningLabel.run(warningSequence)
    }
    
    // MARK: - Helper Methods
    private func phaseColor(for phase: Int) -> SKColor {
        switch phase {
        case 1: return .purple
        case 2: return .red
        case 3: return .orange
        default: return .white
        }
    }
    
    // MARK: - Cleanup
    deinit {
        NotificationCenter.default.removeObserver(self)
        phaseMusicLayer?.stop()
    }
} 