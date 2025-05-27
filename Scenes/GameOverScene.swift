import SpriteKit

class GameOverScene: SKScene {
    // MARK: - Properties
    private let background: SKShapeNode
    private let titleLabel: SKLabelNode
    private let scoreLabel: SKLabelNode
    private let highScoreLabel: SKLabelNode
    private let newHighScoreLabel: SKLabelNode
    private let leaderboardButton: SKLabelNode
    private let retryButton: SKLabelNode
    private let menuButton: SKLabelNode
    
    private let finalScore: Int
    private let phaseShiftTime: TimeInterval?
    private let enemyKills: Int
    private var isHighScore = false
    
    // MARK: - Initialization
    init(size: CGSize, score: Int, phaseShiftTime: TimeInterval?, enemyKills: Int) {
        self.finalScore = score
        self.phaseShiftTime = phaseShiftTime
        self.enemyKills = enemyKills
        
        // Initialize properties
        background = SKShapeNode(rectOf: size, cornerRadius: 20)
        titleLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        highScoreLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
        newHighScoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        leaderboardButton = SKLabelNode(fontNamed: "AvenirNext-Bold")
        retryButton = SKLabelNode(fontNamed: "AvenirNext-Bold")
        menuButton = SKLabelNode(fontNamed: "AvenirNext-Bold")
        
        super.init(size: size)
        
        setupUI()
        checkHighScore()
        updateProfile()
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
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(background)
        
        // Title
        titleLabel.text = "GAME OVER"
        titleLabel.fontSize = 48
        titleLabel.position = CGPoint(x: size.width/2, y: size.height * 0.8)
        addChild(titleLabel)
        
        // Score
        scoreLabel.text = "Score: \(finalScore)"
        scoreLabel.fontSize = 36
        scoreLabel.position = CGPoint(x: size.width/2, y: size.height * 0.6)
        addChild(scoreLabel)
        
        // High score
        highScoreLabel.fontSize = 24
        highScoreLabel.position = CGPoint(x: size.width/2, y: size.height * 0.5)
        addChild(highScoreLabel)
        
        // New high score
        newHighScoreLabel.text = "NEW HIGH SCORE!"
        newHighScoreLabel.fontSize = 32
        newHighScoreLabel.fontColor = .yellow
        newHighScoreLabel.position = CGPoint(x: size.width/2, y: size.height * 0.7)
        newHighScoreLabel.isHidden = true
        addChild(newHighScoreLabel)
        
        // Buttons
        leaderboardButton.text = "Leaderboard"
        leaderboardButton.fontSize = 24
        leaderboardButton.position = CGPoint(x: size.width/2, y: size.height * 0.3)
        leaderboardButton.name = "leaderboardButton"
        addChild(leaderboardButton)
        
        retryButton.text = "Try Again"
        retryButton.fontSize = 24
        retryButton.position = CGPoint(x: size.width/2, y: size.height * 0.2)
        retryButton.name = "retryButton"
        addChild(retryButton)
        
        menuButton.text = "Main Menu"
        menuButton.fontSize = 24
        menuButton.position = CGPoint(x: size.width/2, y: size.height * 0.1)
        menuButton.name = "menuButton"
        addChild(menuButton)
    }
    
    // MARK: - High Score Check
    private func checkHighScore() {
        do {
            isHighScore = try SaveManager.shared.isHighScore(finalScore)
            if isHighScore {
                newHighScoreLabel.isHidden = false
                animateHighScore()
            }
            
            // Update high score label
            let profile = try SaveManager.shared.loadPlayerProfile()
            highScoreLabel.text = "High Score: \(profile.highestScore)"
        } catch {
            print("Error checking high score: \(error)")
        }
    }
    
    private func animateHighScore() {
        let scaleUp = SKAction.scale(to: 1.2, duration: 0.2)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.2)
        let sequence = SKAction.sequence([scaleUp, scaleDown])
        newHighScoreLabel.run(SKAction.repeatForever(sequence))
    }
    
    // MARK: - Profile Update
    private func updateProfile() {
        do {
            var profile = try SaveManager.shared.loadPlayerProfile()
            
            // Update profile stats
            profile.updateScore(finalScore)
            profile.incrementEnemyKills()
            if let time = phaseShiftTime {
                profile.recordPhaseShiftTime(time)
            }
            
            // Save updated profile
            try SaveManager.shared.savePlayerProfile(profile)
            
            // Add to leaderboard if it's a high score
            if isHighScore {
                let entry = SaveManager.LeaderboardEntry(
                    username: profile.username,
                    score: finalScore,
                    date: Date(),
                    phaseShiftTime: phaseShiftTime,
                    enemyKills: enemyKills
                )
                try SaveManager.shared.addScoreToLeaderboard(entry)
            }
        } catch {
            print("Error updating profile: \(error)")
        }
    }
    
    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodes = nodes(at: location)
        
        for node in nodes {
            switch node.name {
            case "leaderboardButton":
                showLeaderboard()
            case "retryButton":
                restartGame()
            case "menuButton":
                returnToMenu()
            default:
                break
            }
        }
    }
    
    // MARK: - Navigation
    private func showLeaderboard() {
        let leaderboard = LeaderboardView()
        leaderboard.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(leaderboard)
    }
    
    private func restartGame() {
        let gameScene = GameScene(size: size)
        gameScene.scaleMode = .aspectFill
        view?.presentScene(gameScene, transition: SKTransition.fade(withDuration: 0.5))
    }
    
    private func returnToMenu() {
        let menuScene = MainMenuScene(size: size)
        menuScene.scaleMode = .aspectFill
        view?.presentScene(menuScene, transition: SKTransition.fade(withDuration: 0.5))
    }
} 