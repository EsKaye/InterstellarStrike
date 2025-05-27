import SpriteKit

class ButtonNode: SKNode {
    // MARK: - Properties
    private let background: SKShapeNode
    private let label: SKLabelNode
    private let action: () -> Void
    
    // MARK: - Initialization
    init(text: String, size: CGSize, action: @escaping () -> Void) {
        self.action = action
        
        // Create background
        background = SKShapeNode(rectOf: size, cornerRadius: 10)
        background.fillColor = .darkGray
        background.strokeColor = .white
        background.lineWidth = 2
        
        // Create label
        label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = text
        label.fontSize = 24
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        
        super.init()
        
        // Setup node hierarchy
        addChild(background)
        addChild(label)
        
        // Enable user interaction
        isUserInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Scale down animation
        let scaleDown = SKAction.scale(to: 0.95, duration: 0.1)
        run(scaleDown)
        
        // Change background color
        background.fillColor = .gray
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Scale up animation
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.1)
        run(scaleUp)
        
        // Reset background color
        background.fillColor = .darkGray
        
        // Check if touch ended within button bounds
        if let touch = touches.first {
            let location = touch.location(in: self)
            if background.contains(location) {
                // Play click sound
                // TODO: Add sound effect
                
                // Execute action
                action()
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Reset button state
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.1)
        run(scaleUp)
        background.fillColor = .darkGray
    }
    
    // MARK: - Customization
    func setColors(background: SKColor, text: SKColor) {
        self.background.fillColor = background
        self.label.fontColor = text
    }
    
    func setFont(_ fontName: String, size: CGFloat) {
        label.fontName = fontName
        label.fontSize = size
    }
} 