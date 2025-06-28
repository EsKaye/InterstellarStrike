import SpriteKit

class LoreCodexView: SKNode {
    // MARK: - Properties
    private var background: SKShapeNode!
    private var titleLabel: SKLabelNode!
    private var closeButton: SKLabelNode!
    private var scrollView: SKScrollView!
    private var contentNode: SKNode!
    private var selectedEntry: LoreEntry?
    private var detailView: SKNode?
    
    // MARK: - Initialization
    override init() {
        super.init()
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        // Background
        background = SKShapeNode(rectOf: CGSize(width: 600, height: 800))
        background.fillColor = SKColor(white: 0.1, alpha: 0.95)
        background.strokeColor = .white
        background.lineWidth = 2
        background.alpha = 0
        addChild(background)
        
        // Title
        titleLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        titleLabel.text = "Celestial Archives"
        titleLabel.fontSize = 32
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: 0, y: 350)
        titleLabel.alpha = 0
        addChild(titleLabel)
        
        // Close Button
        closeButton = SKLabelNode(fontNamed: "AvenirNext-Bold")
        closeButton.text = "×"
        closeButton.fontSize = 40
        closeButton.fontColor = .white
        closeButton.position = CGPoint(x: 280, y: 350)
        closeButton.alpha = 0
        addChild(closeButton)
        
        // Scroll View
        scrollView = SKScrollView(frame: CGRect(x: -280, y: -350, width: 560, height: 650))
        scrollView.contentSize = CGSize(width: 560, height: 1000)
        scrollView.alpha = 0
        
        // Content Node
        contentNode = SKNode()
        scrollView.contentNode = contentNode
        
        // Load and display lore entries
        loadLoreEntries()
        
        // Animate in
        animateIn()
    }
    
    // MARK: - Content Loading
    private func loadLoreEntries() {
        let entries = LoreManager.shared.getUnlockedLoreEntries()
        var yOffset: CGFloat = 450
        
        for entry in entries {
            let entryNode = createEntryNode(for: entry, at: CGPoint(x: 0, y: yOffset))
            contentNode.addChild(entryNode)
            yOffset -= 120
        }
        
        // Update scroll view content size
        scrollView.contentSize = CGSize(width: 560, height: max(1000, -yOffset + 100))
    }
    
    private func createEntryNode(for entry: LoreEntry, at position: CGPoint) -> SKNode {
        let node = SKNode()
        node.position = position
        
        // Background
        let bg = SKShapeNode(rectOf: CGSize(width: 520, height: 100))
        bg.fillColor = SKColor(white: 0.2, alpha: 1.0)
        bg.strokeColor = tierColor(for: entry.tier)
        bg.lineWidth = 2
        node.addChild(bg)
        
        // Title
        let title = SKLabelNode(fontNamed: "AvenirNext-Bold")
        title.text = entry.title
        title.fontSize = 24
        title.fontColor = .white
        title.position = CGPoint(x: -240, y: 20)
        title.horizontalAlignmentMode = .left
        node.addChild(title)
        
        // Tier
        let tier = SKLabelNode(fontNamed: "AvenirNext-Regular")
        tier.text = entry.tier.rawValue
        tier.fontSize = 16
        tier.fontColor = tierColor(for: entry.tier)
        tier.position = CGPoint(x: 240, y: 20)
        tier.horizontalAlignmentMode = .right
        node.addChild(tier)
        
        // Preview
        let preview = SKLabelNode(fontNamed: "AvenirNext-Regular")
        preview.text = String(entry.description.prefix(50)) + "..."
        preview.fontSize = 16
        preview.fontColor = .gray
        preview.position = CGPoint(x: -240, y: -10)
        preview.horizontalAlignmentMode = .left
        node.addChild(preview)
        
        return node
    }
    
    private func tierColor(for tier: LoreTier) -> SKColor {
        switch tier {
        case .common:
            return .white
        case .rare:
            return .cyan
        case .mythic:
            return .orange
        }
    }
    
    // MARK: - Detail View
    private func showDetailView(for entry: LoreEntry) {
        // Remove existing detail view
        detailView?.removeFromParent()
        
        // Create new detail view
        let detail = SKNode()
        
        // Background
        let bg = SKShapeNode(rectOf: CGSize(width: 500, height: 600))
        bg.fillColor = SKColor(white: 0.15, alpha: 1.0)
        bg.strokeColor = tierColor(for: entry.tier)
        bg.lineWidth = 2
        detail.addChild(bg)
        
        // Title
        let title = SKLabelNode(fontNamed: "AvenirNext-Bold")
        title.text = entry.title
        title.fontSize = 28
        title.fontColor = .white
        title.position = CGPoint(x: 0, y: 250)
        detail.addChild(title)
        
        // Tier
        let tier = SKLabelNode(fontNamed: "AvenirNext-Regular")
        tier.text = entry.tier.rawValue
        tier.fontSize = 20
        tier.fontColor = tierColor(for: entry.tier)
        tier.position = CGPoint(x: 0, y: 200)
        detail.addChild(tier)
        
        // Description
        let description = SKLabelNode(fontNamed: "AvenirNext-Regular")
        description.text = entry.description
        description.fontSize = 18
        description.fontColor = .white
        description.position = CGPoint(x: 0, y: 100)
        description.preferredMaxLayoutWidth = 460
        description.numberOfLines = 0
        description.verticalAlignmentMode = .top
        detail.addChild(description)
        
        // Close button
        let close = SKLabelNode(fontNamed: "AvenirNext-Bold")
        close.text = "×"
        close.fontSize = 40
        close.fontColor = .white
        close.position = CGPoint(x: 220, y: 250)
        detail.addChild(close)
        
        detailView = detail
        addChild(detail)
        
        // Animate in
        detail.alpha = 0
        detail.run(SKAction.fadeIn(withDuration: 0.3))
    }
    
    // MARK: - Animations
    private func animateIn() {
        let fadeIn = SKAction.fadeIn(withDuration: 0.3)
        background.run(fadeIn)
        titleLabel.run(fadeIn)
        closeButton.run(fadeIn)
        scrollView.alpha = 1
    }
    
    private func animateOut(completion: @escaping () -> Void) {
        let fadeOut = SKAction.fadeOut(withDuration: 0.3)
        background.run(fadeOut)
        titleLabel.run(fadeOut)
        closeButton.run(fadeOut)
        scrollView.alpha = 0
        
        run(SKAction.sequence([
            SKAction.wait(forDuration: 0.3),
            SKAction.run { completion() }
        ]))
    }
    
    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        if closeButton.contains(location) {
            animateOut {
                self.removeFromParent()
            }
            return
        }
        
        if let detailView = detailView {
            if detailView.contains(location) {
                detailView.removeFromParent()
                self.detailView = nil
            }
            return
        }
        
        // Check for entry selection
        for child in contentNode.children {
            if child.contains(location) {
                if let entry = LoreManager.shared.getLoreEntry(id: child.name ?? "") {
                    showDetailView(for: entry)
                }
                break
            }
        }
    }
} 