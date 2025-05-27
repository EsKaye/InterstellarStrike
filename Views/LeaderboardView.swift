import SpriteKit

class LeaderboardView: SKNode {
    // MARK: - Properties
    private let background: SKShapeNode
    private let titleLabel: SKLabelNode
    private let closeButton: SKLabelNode
    private let scrollView: SKScrollView
    private let contentNode: SKNode
    
    private var entries: [SaveManager.LeaderboardEntry] = []
    private var currentTab: LeaderboardTab = .scores
    
    // MARK: - Types
    enum LeaderboardTab {
        case scores
        case phaseShift
        case kills
    }
    
    // MARK: - Initialization
    override init() {
        // Initialize properties
        background = SKShapeNode(rectOf: CGSize(width: 600, height: 800), cornerRadius: 20)
        titleLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        closeButton = SKLabelNode(fontNamed: "AvenirNext-Bold")
        scrollView = SKScrollView(size: CGSize(width: 550, height: 700))
        contentNode = SKNode()
        
        super.init()
        
        setupUI()
        loadLeaderboard()
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
        titleLabel.text = "LEADERBOARD"
        titleLabel.fontSize = 32
        titleLabel.position = CGPoint(x: 0, y: 350)
        addChild(titleLabel)
        
        // Close button
        closeButton.text = "✕"
        closeButton.fontSize = 24
        closeButton.position = CGPoint(x: 270, y: 350)
        closeButton.name = "closeButton"
        addChild(closeButton)
        
        // Tab buttons
        let tabNames = ["Scores", "Phase Shift", "Kills"]
        for (index, name) in tabNames.enumerated() {
            let tab = SKLabelNode(fontNamed: "AvenirNext-Bold")
            tab.text = name
            tab.fontSize = 20
            tab.position = CGPoint(x: CGFloat(index - 1) * 150, y: 300)
            tab.name = "tab_\(index)"
            addChild(tab)
        }
        
        // Scroll view
        scrollView.position = CGPoint(x: 0, y: -50)
        addChild(scrollView)
        
        // Content node
        contentNode.position = CGPoint(x: 0, y: 0)
        scrollView.contentNode = contentNode
    }
    
    // MARK: - Data Loading
    private func loadLeaderboard() {
        do {
            entries = try SaveManager.shared.loadLeaderboard()
            updateDisplay()
        } catch {
            print("Error loading leaderboard: \(error)")
        }
    }
    
    // MARK: - Display Updates
    private func updateDisplay() {
        contentNode.removeAllChildren()
        
        let sortedEntries: [SaveManager.LeaderboardEntry]
        switch currentTab {
        case .scores:
            sortedEntries = entries.sorted { $0.score > $1.score }
        case .phaseShift:
            sortedEntries = entries.sorted { ($0.phaseShiftTime ?? .infinity) < ($1.phaseShiftTime ?? .infinity) }
        case .kills:
            sortedEntries = entries.sorted { $0.enemyKills > $1.enemyKills }
        }
        
        for (index, entry) in sortedEntries.prefix(50).enumerated() {
            let entryNode = createEntryNode(entry, rank: index + 1)
            entryNode.position = CGPoint(x: 0, y: -CGFloat(index) * 40)
            contentNode.addChild(entryNode)
        }
    }
    
    private func createEntryNode(_ entry: SaveManager.LeaderboardEntry, rank: Int) -> SKNode {
        let node = SKNode()
        
        // Rank
        let rankLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        rankLabel.text = "#\(rank)"
        rankLabel.fontSize = 20
        rankLabel.horizontalAlignmentMode = .left
        rankLabel.position = CGPoint(x: -250, y: 0)
        node.addChild(rankLabel)
        
        // Username
        let usernameLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
        usernameLabel.text = entry.username
        usernameLabel.fontSize = 18
        usernameLabel.horizontalAlignmentMode = .left
        usernameLabel.position = CGPoint(x: -200, y: 0)
        node.addChild(usernameLabel)
        
        // Value based on current tab
        let valueLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        switch currentTab {
        case .scores:
            valueLabel.text = "\(entry.score)"
        case .phaseShift:
            if let time = entry.phaseShiftTime {
                valueLabel.text = String(format: "%.2fs", time)
            } else {
                valueLabel.text = "N/A"
            }
        case .kills:
            valueLabel.text = "\(entry.enemyKills)"
        }
        valueLabel.fontSize = 20
        valueLabel.horizontalAlignmentMode = .right
        valueLabel.position = CGPoint(x: 250, y: 0)
        node.addChild(valueLabel)
        
        return node
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
            
            if let name = node.name, name.starts(with: "tab_") {
                if let index = Int(name.dropFirst(4)) {
                    switch index {
                    case 0: currentTab = .scores
                    case 1: currentTab = .phaseShift
                    case 2: currentTab = .kills
                    default: break
                    }
                    updateDisplay()
                }
            }
        }
    }
} 