import SpriteKit

class ProfileMenu: SKNode {
    // MARK: - Properties
    private let background: SKShapeNode
    private let titleLabel: SKLabelNode
    private let closeButton: SKLabelNode
    private let usernameLabel: SKLabelNode
    private let usernameInput: SKLabelNode
    private let statsContainer: SKNode
    private let resetButton: SKLabelNode
    
    private var profile: PlayerProfile
    private var isEditingUsername = false
    
    // MARK: - Initialization
    override init() {
        // Initialize properties
        background = SKShapeNode(rectOf: CGSize(width: 600, height: 800), cornerRadius: 20)
        titleLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        closeButton = SKLabelNode(fontNamed: "AvenirNext-Bold")
        usernameLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        usernameInput = SKLabelNode(fontNamed: "AvenirNext-Regular")
        statsContainer = SKNode()
        resetButton = SKLabelNode(fontNamed: "AvenirNext-Bold")
        
        // Load profile
        do {
            profile = try SaveManager.shared.loadPlayerProfile()
        } catch {
            profile = PlayerProfile()
        }
        
        super.init()
        
        setupUI()
        updateStats()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        // Background
        background.fillColor = .black
        background.strokeColor = .white
        background.alpha = 0.9
        addChild(background)
        
        // Title
        titleLabel.text = "PROFILE"
        titleLabel.fontSize = 32
        titleLabel.position = CGPoint(x: 0, y: 350)
        addChild(titleLabel)
        
        // Close button
        closeButton.text = "✕"
        closeButton.fontSize = 24
        closeButton.position = CGPoint(x: 270, y: 350)
        closeButton.name = "closeButton"
        addChild(closeButton)
        
        // Username section
        usernameLabel.text = "Username:"
        usernameLabel.fontSize = 24
        usernameLabel.horizontalAlignmentMode = .left
        usernameLabel.position = CGPoint(x: -250, y: 250)
        addChild(usernameLabel)
        
        usernameInput.text = profile.username
        usernameInput.fontSize = 24
        usernameInput.horizontalAlignmentMode = .left
        usernameInput.position = CGPoint(x: -100, y: 250)
        usernameInput.name = "usernameInput"
        addChild(usernameInput)
        
        // Stats container
        statsContainer.position = CGPoint(x: 0, y: 150)
        addChild(statsContainer)
        
        // Reset button
        resetButton.text = "Reset Profile"
        resetButton.fontSize = 20
        resetButton.position = CGPoint(x: 0, y: -350)
        resetButton.name = "resetButton"
        addChild(resetButton)
    }
    
    // MARK: - Stats Display
    private func updateStats() {
        statsContainer.removeAllChildren()
        
        let stats = [
            ("Highest Score", "\(profile.highestScore)"),
            ("Total Time Played", profile.formattedTotalTimePlayed),
            ("Total Enemy Kills", "\(profile.totalEnemyKills)"),
            ("Most Used Ship", profile.mostUsedShip),
            ("Most Used Power-Up", profile.mostUsedPowerUp.rawValue),
            ("Average Power-Up Duration", String(format: "%.1fs", profile.averagePowerUpDuration)),
            ("Fastest Phase Shift", profile.fastestPhaseShiftTime.map { String(format: "%.2fs", $0) } ?? "N/A")
        ]
        
        for (index, (label, value)) in stats.enumerated() {
            let statNode = createStatNode(label: label, value: value)
            statNode.position = CGPoint(x: 0, y: -CGFloat(index) * 40)
            statsContainer.addChild(statNode)
        }
    }
    
    private func createStatNode(label: String, value: String) -> SKNode {
        let node = SKNode()
        
        let labelNode = SKLabelNode(fontNamed: "AvenirNext-Bold")
        labelNode.text = label
        labelNode.fontSize = 18
        labelNode.horizontalAlignmentMode = .left
        labelNode.position = CGPoint(x: -200, y: 0)
        node.addChild(labelNode)
        
        let valueNode = SKLabelNode(fontNamed: "AvenirNext-Regular")
        valueNode.text = value
        valueNode.fontSize = 18
        valueNode.horizontalAlignmentMode = .right
        valueNode.position = CGPoint(x: 200, y: 0)
        node.addChild(valueNode)
        
        return node
    }
    
    // MARK: - Username Editing
    private func startUsernameEditing() {
        isEditingUsername = true
        usernameInput.text = "Enter username..."
        usernameInput.fontColor = .gray
    }
    
    private func finishUsernameEditing() {
        isEditingUsername = false
        if usernameInput.text == "Enter username..." {
            usernameInput.text = profile.username
        } else {
            profile.username = usernameInput.text
            try? SaveManager.shared.savePlayerProfile(profile)
        }
        usernameInput.fontColor = .white
    }
    
    // MARK: - Profile Reset
    private func resetProfile() {
        let alert = UIAlertController(
            title: "Reset Profile",
            message: "Are you sure you want to reset your profile? This cannot be undone.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Reset", style: .destructive) { [weak self] _ in
            try? SaveManager.shared.resetPlayerProfile()
            self?.profile = PlayerProfile()
            self?.updateStats()
        })
        
        if let viewController = self.scene?.view?.window?.rootViewController {
            viewController.present(alert, animated: true)
        }
    }
    
    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodes = nodes(at: location)
        
        for node in nodes {
            if node.name == "closeButton" {
                removeFromParent()
                return
            }
            
            if node.name == "usernameInput" {
                startUsernameEditing()
                return
            }
            
            if node.name == "resetButton" {
                resetProfile()
                return
            }
        }
        
        if isEditingUsername {
            finishUsernameEditing()
        }
    }
} 