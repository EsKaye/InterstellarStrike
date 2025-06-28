import SpriteKit
import AVFoundation

class IntroCinematicScene: SKScene {
    // MARK: - Properties
    private var starfield: SKEmitterNode!
    private var narrationLabel: SKLabelNode!
    private var skipButton: SKLabelNode!
    private var audioPlayer: AVAudioPlayer?
    private var isPlaying = false
    private var cinematicPlayer: CinematicPlayer!
    private var distressSignal: SKEmitterNode!
    private var shipNode: SKSpriteNode!
    private var backgroundStars: [SKShapeNode] = []
    private var parallaxStars: [SKShapeNode] = []
    private var energyPulse: SKEmitterNode!
    private var titleLabel: SKLabelNode!
    private var cameraNode: SKCameraNode!
    private var debrisField: [SKSpriteNode] = []
    private var nebulaEffect: SKEmitterNode!
    private var timeDistortion: SKEffectNode!
    
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
        
        // Setup starfield
        if let starfieldEmitter = SKEmitterNode(fileNamed: "Starfield") {
            starfield = starfieldEmitter
            starfield.position = CGPoint(x: frame.midX, y: frame.midY)
            starfield.zPosition = -1
            starfield.alpha = 0
            addChild(starfield)
        }
        
        // Setup background stars
        setupBackgroundStars()
        setupParallaxStars()
        setupDebrisField()
        
        // Setup nebula effect
        if let nebulaEmitter = SKEmitterNode(fileNamed: "NebulaEffect") {
            nebulaEffect = nebulaEmitter
            nebulaEffect.position = CGPoint(x: frame.midX, y: frame.midY)
            nebulaEffect.zPosition = -0.5
            nebulaEffect.alpha = 0
            addChild(nebulaEffect)
        }
        
        // Setup time distortion effect
        timeDistortion = SKEffectNode()
        timeDistortion.shouldRasterize = true
        timeDistortion.filter = CIFilter(name: "CIMotionBlur")
        timeDistortion.alpha = 0
        addChild(timeDistortion)
        
        // Setup distress signal
        if let distressEmitter = SKEmitterNode(fileNamed: "DistressSignal") {
            distressSignal = distressEmitter
            distressSignal.position = CGPoint(x: frame.midX, y: frame.midY)
            distressSignal.zPosition = 1
            distressSignal.alpha = 0
            addChild(distressSignal)
        }
        
        // Setup energy pulse
        if let pulseEmitter = SKEmitterNode(fileNamed: "EnergyPulse") {
            energyPulse = pulseEmitter
            energyPulse.position = CGPoint(x: frame.midX, y: frame.midY)
            energyPulse.zPosition = 0
            energyPulse.alpha = 0
            addChild(energyPulse)
        }
        
        // Setup ship
        shipNode = SKSpriteNode(imageNamed: "player_ship")
        shipNode.position = CGPoint(x: frame.midX, y: frame.minY - 100)
        shipNode.alpha = 0
        shipNode.zPosition = 2
        addChild(shipNode)
        
        // Setup title
        titleLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        titleLabel.text = "INTERSTELLAR STRIKE"
        titleLabel.fontSize = 36
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: frame.midX, y: frame.maxY - 100)
        titleLabel.alpha = 0
        titleLabel.zPosition = 3
        addChild(titleLabel)
        
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
        if let audioURL = Bundle.main.url(forResource: "intro_narration", withExtension: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
                audioPlayer?.prepareToPlay()
            } catch {
                print("Failed to load audio: \(error)")
            }
        }
    }
    
    private func setupBackgroundStars() {
        for _ in 0..<50 {
            let star = SKShapeNode(circleOfRadius: CGFloat.random(in: 1...3))
            star.fillColor = .white
            star.strokeColor = .clear
            star.position = CGPoint(
                x: CGFloat.random(in: 0...frame.width),
                y: CGFloat.random(in: 0...frame.height)
            )
            star.alpha = 0
            star.zPosition = -2
            addChild(star)
            backgroundStars.append(star)
        }
    }
    
    private func setupParallaxStars() {
        for _ in 0..<30 {
            let star = SKShapeNode(circleOfRadius: CGFloat.random(in: 2...4))
            star.fillColor = .white
            star.strokeColor = .clear
            star.position = CGPoint(
                x: CGFloat.random(in: 0...frame.width),
                y: CGFloat.random(in: 0...frame.height)
            )
            star.alpha = 0
            star.zPosition = -1.5
            addChild(star)
            parallaxStars.append(star)
        }
    }
    
    private func setupDebrisField() {
        let debrisTypes = ["debris1", "debris2", "debris3"]
        for _ in 0..<20 {
            if let debrisType = debrisTypes.randomElement() {
                let debris = SKSpriteNode(imageNamed: debrisType)
                debris.position = CGPoint(
                    x: CGFloat.random(in: 0...frame.width),
                    y: CGFloat.random(in: 0...frame.height)
                )
                debris.alpha = 0
                debris.zPosition = -0.8
                debris.setScale(CGFloat.random(in: 0.5...1.5))
                debris.zRotation = CGFloat.random(in: 0...2 * .pi)
                addChild(debris)
                debrisField.append(debris)
            }
        }
    }
    
    // MARK: - Cinematic Sequence
    private func startCinematic() {
        isPlaying = true
        
        // Fade in title with glow effect
        let titleFadeIn = SKAction.sequence([
            SKAction.fadeIn(withDuration: 2.0),
            SKAction.wait(forDuration: 1.0),
            SKAction.fadeOut(withDuration: 2.0)
        ])
        titleLabel.run(titleFadeIn)
        
        // Fade in background stars
        let starFadeIn = SKAction.fadeIn(withDuration: 2.0)
        for star in backgroundStars {
            star.run(starFadeIn)
        }
        
        // Fade in parallax stars with staggered timing
        for (index, star) in parallaxStars.enumerated() {
            let delay = Double(index) * 0.1
            let sequence = SKAction.sequence([
                SKAction.wait(forDuration: delay),
                SKAction.fadeIn(withDuration: 1.0)
            ])
            star.run(sequence)
        }
        
        // Fade in nebula effect
        let nebulaFadeIn = SKAction.fadeIn(withDuration: 3.0)
        nebulaEffect.run(nebulaFadeIn)
        
        // Fade in debris field
        for debris in debrisField {
            let randomDelay = Double.random(in: 0...2)
            let sequence = SKAction.sequence([
                SKAction.wait(forDuration: randomDelay),
                SKAction.fadeIn(withDuration: 1.0)
            ])
            debris.run(sequence)
        }
        
        // Fade in starfield
        let fadeInStarfield = SKAction.fadeIn(withDuration: 2.0)
        starfield.run(fadeInStarfield)
        
        // Show skip button
        let fadeInSkip = SKAction.fadeIn(withDuration: 0.5)
        skipButton.run(fadeInSkip)
        
        // Start cinematic sequence
        let sequence = [
            // Initial narration
            SKAction.run { [weak self] in
                self?.playNarration(
                    "In the year 3137...",
                    duration: 2.0
                )
            },
            SKAction.wait(forDuration: 2.5),
            
            // Camera zoom out
            SKAction.run { [weak self] in
                let zoomOut = SKAction.scale(to: 1.5, duration: 2.0)
                self?.cameraNode.run(zoomOut)
            },
            SKAction.wait(forDuration: 2.0),
            
            // Energy pulse
            SKAction.run { [weak self] in
                self?.energyPulse.alpha = 1
                self?.energyPulse.run(SKAction.fadeIn(withDuration: 0.5))
            },
            SKAction.wait(forDuration: 1.0),
            
            // Time distortion effect
            SKAction.run { [weak self] in
                self?.timeDistortion.alpha = 1
                let filter = self?.timeDistortion.filter as? CIFilter
                filter?.setValue(20.0, forKey: "inputRadius")
                filter?.setValue(0.0, forKey: "inputAngle")
            },
            SKAction.wait(forDuration: 0.5),
            
            // Distress signal
            SKAction.run { [weak self] in
                self?.distressSignal.alpha = 1
                self?.distressSignal.run(SKAction.fadeIn(withDuration: 0.5))
                
                // Add pulsing effect
                let pulse = SKAction.sequence([
                    SKAction.scale(to: 1.2, duration: 0.5),
                    SKAction.scale(to: 1.0, duration: 0.5)
                ])
                self?.distressSignal.run(SKAction.repeatForever(pulse))
            },
            SKAction.wait(forDuration: 1.0),
            
            // Main narration
            SKAction.run { [weak self] in
                self?.playNarration(
                    "The Celestial Syndicate fell...\nYou were the last one left to fly.",
                    duration: 3.0
                )
            },
            SKAction.wait(forDuration: 3.5),
            
            // Ship entrance with enhanced effects
            SKAction.run { [weak self] in
                self?.shipNode.alpha = 1
                let moveUp = SKAction.moveTo(
                    y: self?.frame.midY ?? 0,
                    duration: 2.0
                )
                let rotate = SKAction.sequence([
                    SKAction.rotate(toAngle: .pi / 8, duration: 0.5),
                    SKAction.rotate(toAngle: -.pi / 8, duration: 1.0),
                    SKAction.rotate(toAngle: 0, duration: 0.5)
                ])
                let glow = SKAction.sequence([
                    SKAction.fadeAlpha(to: 0.8, duration: 0.5),
                    SKAction.fadeAlpha(to: 1.0, duration: 0.5)
                ])
                self?.shipNode.run(SKAction.group([moveUp, rotate, SKAction.repeatForever(glow)]))
            },
            SKAction.wait(forDuration: 2.5),
            
            // Final narration
            SKAction.run { [weak self] in
                self?.playNarration(
                    "The dark energy anomaly grows stronger...\nThe fate of the galaxy rests in your hands.",
                    duration: 4.0
                )
            },
            SKAction.wait(forDuration: 4.5),
            
            // Transition
            SKAction.run { [weak self] in
                self?.transitionToMainMenu()
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
    private func transitionToMainMenu() {
        guard isPlaying else { return }
        isPlaying = false
        
        let fadeOut = SKAction.fadeOut(withDuration: 1.0)
        let transition = SKAction.run { [weak self] in
            let mainMenu = MainMenuScene(size: self?.size ?? CGSize(width: 750, height: 1334))
            mainMenu.scaleMode = .aspectFill
            self?.view?.presentScene(mainMenu, transition: SKTransition.fade(withDuration: 1.0))
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
            transitionToMainMenu()
        }
    }
} 