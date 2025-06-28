import SpriteKit
import AVFoundation

class BossIntroScene: SKScene {
    // MARK: - Properties
    private var cameraNode: SKCameraNode!
    private var bossNode: SKSpriteNode!
    private var energyField: SKEmitterNode!
    private var darkEnergy: SKEmitterNode!
    private var narrationLabel: SKLabelNode!
    private var skipButton: SKLabelNode!
    private var audioPlayer: AVAudioPlayer?
    private var isPlaying = false
    private var cinematicPlayer: CinematicPlayer!
    private var timeDistortion: SKEffectNode!
    private var bossName: String
    private var bossType: BossType
    
    enum BossType {
        case voidCorruptor
        case temporalWarden
        case quantumBehemoth
        
        var title: String {
            switch self {
            case .voidCorruptor: return "The Void Corruptor"
            case .temporalWarden: return "The Temporal Warden"
            case .quantumBehemoth: return "The Quantum Behemoth"
            }
        }
        
        var description: String {
            switch self {
            case .voidCorruptor:
                return "A being of pure void energy, corrupting all it touches."
            case .temporalWarden:
                return "Guardian of the time stream, manipulating reality itself."
            case .quantumBehemoth:
                return "A massive quantum entity, existing in multiple dimensions."
            }
        }
    }
    
    // MARK: - Initialization
    init(size: CGSize, bossType: BossType) {
        self.bossType = bossType
        self.bossName = bossType.title
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Scene Lifecycle
    override func didMove(to view: SKView) {
        setupScene()
        startCinematic()
    }
    
    // MARK: - Setup
    private func setupScene() {
        backgroundColor = .black
        
        // Setup camera
        cameraNode = SKCameraNode()
        camera = cameraNode
        addChild(cameraNode)
        
        // Initialize cinematic player
        cinematicPlayer = CinematicPlayer(scene: self)
        
        // Setup boss node
        bossNode = SKSpriteNode(imageNamed: "\(bossType)_boss")
        bossNode.position = CGPoint(x: frame.midX, y: frame.midY)
        bossNode.alpha = 0
        bossNode.zPosition = 2
        bossNode.setScale(2.0)
        addChild(bossNode)
        
        // Setup energy field
        if let energyEmitter = SKEmitterNode(fileNamed: "BossEnergyField") {
            energyField = energyEmitter
            energyField.position = CGPoint(x: frame.midX, y: frame.midY)
            energyField.zPosition = 1
            energyField.alpha = 0
            addChild(energyField)
        }
        
        // Setup dark energy
        if let darkEmitter = SKEmitterNode(fileNamed: "DarkEnergy") {
            darkEnergy = darkEmitter
            darkEnergy.position = CGPoint(x: frame.midX, y: frame.midY)
            darkEnergy.zPosition = 0
            darkEnergy.alpha = 0
            addChild(darkEnergy)
        }
        
        // Setup time distortion
        timeDistortion = SKEffectNode()
        timeDistortion.shouldRasterize = true
        timeDistortion.filter = CIFilter(name: "CIMotionBlur")
        timeDistortion.alpha = 0
        addChild(timeDistortion)
        
        // Setup narration
        narrationLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        narrationLabel.fontSize = 24
        narrationLabel.fontColor = .white
        narrationLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        narrationLabel.alpha = 0
        narrationLabel.numberOfLines = 0
        narrationLabel.preferredMaxLayoutWidth = frame.width * 0.8
        addChild(narrationLabel)
        
        // Setup skip button
        skipButton = SKLabelNode(fontNamed: "AvenirNext-Bold")
        skipButton.text = "Skip"
        skipButton.fontSize = 20
        skipButton.fontColor = .white
        skipButton.position = CGPoint(x: frame.maxX - 50, y: frame.maxY - 30)
        skipButton.alpha = 0
        addChild(skipButton)
        
        // Load audio
        if let audioURL = Bundle.main.url(forResource: "boss_intro", withExtension: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
                audioPlayer?.prepareToPlay()
            } catch {
                print("Failed to load audio: \(error)")
            }
        }
    }
    
    // MARK: - Cinematic Sequence
    private func startCinematic() {
        isPlaying = true
        
        // Show skip button
        let fadeInSkip = SKAction.fadeIn(withDuration: 0.5)
        skipButton.run(fadeInSkip)
        
        // Start cinematic sequence
        let sequence = [
            // Initial dark energy
            SKAction.run { [weak self] in
                self?.darkEnergy.alpha = 1
                self?.darkEnergy.run(SKAction.fadeIn(withDuration: 1.0))
            },
            SKAction.wait(forDuration: 1.5),
            
            // Boss name reveal
            SKAction.run { [weak self] in
                self?.playNarration(
                    self?.bossName ?? "",
                    duration: 2.0
                )
            },
            SKAction.wait(forDuration: 2.5),
            
            // Time distortion
            SKAction.run { [weak self] in
                self?.timeDistortion.alpha = 1
                let filter = self?.timeDistortion.filter as? CIFilter
                filter?.setValue(30.0, forKey: "inputRadius")
                filter?.setValue(0.0, forKey: "inputAngle")
            },
            SKAction.wait(forDuration: 0.5),
            
            // Energy field
            SKAction.run { [weak self] in
                self?.energyField.alpha = 1
                self?.energyField.run(SKAction.fadeIn(withDuration: 0.5))
            },
            SKAction.wait(forDuration: 1.0),
            
            // Boss appearance
            SKAction.run { [weak self] in
                self?.bossNode.alpha = 1
                let scaleDown = SKAction.scale(to: 1.0, duration: 1.0)
                let rotate = SKAction.sequence([
                    SKAction.rotate(toAngle: .pi / 4, duration: 0.5),
                    SKAction.rotate(toAngle: -.pi / 4, duration: 1.0),
                    SKAction.rotate(toAngle: 0, duration: 0.5)
                ])
                self?.bossNode.run(SKAction.group([scaleDown, rotate]))
            },
            SKAction.wait(forDuration: 2.0),
            
            // Boss description
            SKAction.run { [weak self] in
                self?.playNarration(
                    self?.bossType.description ?? "",
                    duration: 3.0
                )
            },
            SKAction.wait(forDuration: 3.5),
            
            // Final effect
            SKAction.run { [weak self] in
                let pulse = SKAction.sequence([
                    SKAction.scale(to: 1.2, duration: 0.5),
                    SKAction.scale(to: 1.0, duration: 0.5)
                ])
                self?.bossNode.run(SKAction.repeatForever(pulse))
            },
            SKAction.wait(forDuration: 2.0),
            
            // Transition
            SKAction.run { [weak self] in
                self?.transitionToBattle()
            }
        ]
        
        run(SKAction.sequence(sequence))
        
        // Play audio
        audioPlayer?.play()
    }
    
    private func playNarration(_ text: String, duration: TimeInterval) {
        let narration = CinematicPlayer.Narration(
            text: text,
            duration: duration,
            position: CGPoint(x: frame.midX, y: frame.midY),
            fontSize: 24,
            fontColor: .white
        )
        cinematicPlayer.playNarration(narration)
    }
    
    // MARK: - Transitions
    private func transitionToBattle() {
        guard isPlaying else { return }
        isPlaying = false
        
        let fadeOut = SKAction.fadeOut(withDuration: 1.0)
        let transition = SKAction.run { [weak self] in
            let battleScene = BattleScene(size: self?.size ?? CGSize(width: 750, height: 1334))
            battleScene.scaleMode = .aspectFill
            self?.view?.presentScene(battleScene, transition: SKTransition.fade(withDuration: 1.0))
        }
        
        let sequence = SKAction.sequence([fadeOut, transition])
        run(sequence)
    }
    
    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        if skipButton.contains(location) {
            audioPlayer?.stop()
            transitionToBattle()
        }
    }
} 