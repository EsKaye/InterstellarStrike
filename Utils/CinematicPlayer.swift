import SpriteKit

class CinematicPlayer {
    // MARK: - Types
    enum CameraAction {
        case move(to: CGPoint, duration: TimeInterval)
        case zoom(to: CGFloat, duration: TimeInterval)
        case shake(intensity: CGFloat, duration: TimeInterval)
    }
    
    enum SpriteAction {
        case fadeIn(duration: TimeInterval)
        case fadeOut(duration: TimeInterval)
        case move(to: CGPoint, duration: TimeInterval)
        case scale(to: CGFloat, duration: TimeInterval)
        case rotate(to: CGFloat, duration: TimeInterval)
        case custom(SKAction)
    }
    
    struct Narration {
        let text: String
        let duration: TimeInterval
        let position: CGPoint
        let fontSize: CGFloat
        let fontColor: SKColor
    }
    
    // MARK: - Properties
    private weak var scene: SKScene?
    private var camera: SKCameraNode?
    private var currentSequence: [SKAction] = []
    private var isPlaying = false
    
    // MARK: - Initialization
    init(scene: SKScene) {
        self.scene = scene
        self.camera = scene.camera
    }
    
    // MARK: - Sequence Management
    func playSequence(_ actions: [SKAction], completion: (() -> Void)? = nil) {
        guard !isPlaying else { return }
        isPlaying = true
        
        let sequence = SKAction.sequence(actions + [SKAction.run { [weak self] in
            self?.isPlaying = false
            completion?()
        }])
        
        scene?.run(sequence)
    }
    
    // MARK: - Camera Actions
    func createCameraAction(_ action: CameraAction) -> SKAction {
        switch action {
        case .move(let position, let duration):
            return SKAction.move(to: position, duration: duration)
            
        case .zoom(let scale, let duration):
            return SKAction.scale(to: scale, duration: duration)
            
        case .shake(let intensity, let duration):
            return createShakeAction(intensity: intensity, duration: duration)
        }
    }
    
    private func createShakeAction(intensity: CGFloat, duration: TimeInterval) -> SKAction {
        let numberOfShakes = Int(duration * 10)
        var actions: [SKAction] = []
        
        for _ in 0..<numberOfShakes {
            let moveX = CGFloat.random(in: -intensity...intensity)
            let moveY = CGFloat.random(in: -intensity...intensity)
            let shake = SKAction.moveBy(x: moveX, y: moveY, duration: 0.1)
            actions.append(shake)
            actions.append(shake.reversed())
        }
        
        return SKAction.sequence(actions)
    }
    
    // MARK: - Sprite Actions
    func createSpriteAction(_ action: SpriteAction) -> SKAction {
        switch action {
        case .fadeIn(let duration):
            return SKAction.fadeIn(withDuration: duration)
            
        case .fadeOut(let duration):
            return SKAction.fadeOut(withDuration: duration)
            
        case .move(let position, let duration):
            return SKAction.move(to: position, duration: duration)
            
        case .scale(let scale, let duration):
            return SKAction.scale(to: scale, duration: duration)
            
        case .rotate(let angle, let duration):
            return SKAction.rotate(toAngle: angle, duration: duration)
            
        case .custom(let action):
            return action
        }
    }
    
    // MARK: - Narration
    func createNarrationNode(_ narration: Narration) -> SKLabelNode {
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = narration.text
        label.fontSize = narration.fontSize
        label.fontColor = narration.fontColor
        label.position = narration.position
        label.alpha = 0
        label.numberOfLines = 0
        label.preferredMaxLayoutWidth = 400
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        
        return label
    }
    
    func playNarration(_ narration: Narration, completion: (() -> Void)? = nil) {
        let label = createNarrationNode(narration)
        scene?.addChild(label)
        
        let sequence = SKAction.sequence([
            SKAction.fadeIn(withDuration: 0.5),
            SKAction.wait(forDuration: narration.duration),
            SKAction.fadeOut(withDuration: 0.5),
            SKAction.removeFromParent(),
            SKAction.run { completion?() }
        ])
        
        label.run(sequence)
    }
    
    // MARK: - Utility Methods
    func createFadeTransition(to scene: SKScene, duration: TimeInterval) -> SKTransition {
        return SKTransition.fade(withDuration: duration)
    }
    
    func createCrossFadeTransition(to scene: SKScene, duration: TimeInterval) -> SKTransition {
        return SKTransition.crossFade(withDuration: duration)
    }
    
    func createDoorwayTransition(to scene: SKScene, duration: TimeInterval) -> SKTransition {
        return SKTransition.doorway(withDuration: duration)
    }
    
    // MARK: - Sequence Building
    func buildSequence(_ actions: [SKAction]) -> SKAction {
        return SKAction.sequence(actions)
    }
    
    func buildGroup(_ actions: [SKAction]) -> SKAction {
        return SKAction.group(actions)
    }
    
    func repeatAction(_ action: SKAction, count: Int) -> SKAction {
        return SKAction.repeat(action, count: count)
    }
    
    func repeatActionForever(_ action: SKAction) -> SKAction {
        return SKAction.repeatForever(action)
    }
} 