import SpriteKit

class ParallaxBackground: SKNode {
    // MARK: - Properties
    private let layers: [SKNode]
    private let speeds: [CGFloat]
    private let oscillationAmplitude: CGFloat = 5.0
    private let oscillationFrequency: TimeInterval = 2.0
    private var timeElapsed: TimeInterval = 0
    
    // MARK: - Initialization
    init(size: CGSize) {
        // Create 5 layers with different speeds and star densities
        let layerCount = 5
        var tempLayers: [SKNode] = []
        var tempSpeeds: [CGFloat] = []
        
        for i in 0..<layerCount {
            let layer = SKNode()
            let speed = CGFloat(i + 1) * 20.0 // Increasing speeds for deeper layers
            tempLayers.append(layer)
            tempSpeeds.append(speed)
            
            // Add stars to layer
            let starCount = 50 - (i * 8) // Fewer stars in deeper layers
            for _ in 0..<starCount {
                let star = SKSpriteNode(color: .white, size: CGSize(width: 2, height: 2))
                star.position = CGPoint(
                    x: CGFloat.random(in: 0...size.width),
                    y: CGFloat.random(in: 0...size.height)
                )
                star.alpha = 1.0 - (CGFloat(i) * 0.15) // Deeper layers are more transparent
                layer.addChild(star)
            }
        }
        
        layers = tempLayers
        speeds = tempSpeeds
        
        super.init()
        
        // Add layers to node
        for layer in layers {
            addChild(layer)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Update
    func update(deltaTime: TimeInterval) {
        timeElapsed += deltaTime
        
        // Update each layer
        for (index, layer) in layers.enumerated() {
            // Calculate vertical oscillation
            let oscillation = sin(timeElapsed * .pi * 2 / oscillationFrequency) * oscillationAmplitude
            
            // Move layer
            let moveDown = SKAction.moveBy(x: 0, y: -speeds[index] * CGFloat(deltaTime), duration: 0)
            let moveOscillate = SKAction.moveBy(x: 0, y: oscillation, duration: 0)
            layer.run(SKAction.group([moveDown, moveOscillate]))
            
            // Reset stars that move off screen
            for star in layer.children {
                if star.position.y < -star.frame.height {
                    star.position.y = frame.height + star.frame.height
                    star.position.x = CGFloat.random(in: 0...frame.width)
                }
            }
        }
    }
    
    // MARK: - Phase Shift Effects
    func applyPhaseShiftEffects() {
        // Change star colors and add glow
        for layer in layers {
            for star in layer.children {
                let colorize = SKAction.colorize(with: .purple, colorBlendFactor: 1.0, duration: 0.5)
                let glow = SKAction.sequence([
                    SKAction.scale(to: 1.5, duration: 0.5),
                    SKAction.scale(to: 1.0, duration: 0.5)
                ])
                star.run(SKAction.group([colorize, SKAction.repeatForever(glow)]))
            }
        }
    }
    
    func removePhaseShiftEffects() {
        // Reset star colors and remove glow
        for layer in layers {
            for star in layer.children {
                let colorize = SKAction.colorize(with: .white, colorBlendFactor: 1.0, duration: 0.5)
                star.run(colorize)
                star.removeAllActions()
            }
        }
    }
} 