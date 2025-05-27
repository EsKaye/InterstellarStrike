import SpriteKit

class ScreenShake {
    // MARK: - Properties
    private let camera: SKCameraNode
    private var isShaking = false
    
    // MARK: - Initialization
    init(camera: SKCameraNode) {
        self.camera = camera
    }
    
    // MARK: - Shake Methods
    func shake(intensity: CGFloat = 10.0, duration: TimeInterval = 0.5) {
        guard !isShaking else { return }
        isShaking = true
        
        // Store original position
        let originalPosition = camera.position
        
        // Create shake sequence
        var actions: [SKAction] = []
        let shakeCount = Int(duration * 10) // 10 shakes per second
        
        for _ in 0..<shakeCount {
            let randomX = CGFloat.random(in: -intensity...intensity)
            let randomY = CGFloat.random(in: -intensity...intensity)
            let move = SKAction.moveBy(x: randomX, y: randomY, duration: 0.05)
            actions.append(move)
        }
        
        // Add return to original position
        actions.append(SKAction.move(to: originalPosition, duration: 0.1))
        
        // Run sequence
        camera.run(SKAction.sequence(actions)) { [weak self] in
            self?.isShaking = false
        }
    }
    
    // MARK: - Preset Shakes
    func shakeOnEnemyDeath() {
        shake(intensity: 5.0, duration: 0.3)
    }
    
    func shakeOnPlayerDamage() {
        shake(intensity: 15.0, duration: 0.5)
    }
    
    func shakeOnEnergyCorePickup() {
        shake(intensity: 20.0, duration: 0.8)
    }
    
    func shakeOnPhaseShift() {
        shake(intensity: 25.0, duration: 1.0)
    }
} 