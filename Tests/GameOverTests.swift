import XCTest
@testable import InterstellarStrike

class GameOverTests: XCTestCase {
    var gameOverScene: GameOverScene!
    var saveManager: SaveManager!
    
    override func setUp() {
        super.setUp()
        saveManager = SaveManager.shared
        
        // Clear any existing data
        try? saveManager.clearAllData()
        
        // Create game over scene with test data
        gameOverScene = GameOverScene(
            size: CGSize(width: 1024, height: 768),
            score: 1000,
            phaseShiftTime: 10,
            enemyKills: 50
        )
    }
    
    override func tearDown() {
        try? saveManager.clearAllData()
        super.tearDown()
    }
    
    // MARK: - GameOverScene Tests
    func testGameOverSceneInitialization() {
        XCTAssertNotNil(gameOverScene.background)
        XCTAssertNotNil(gameOverScene.titleLabel)
        XCTAssertNotNil(gameOverScene.scoreLabel)
        XCTAssertNotNil(gameOverScene.highScoreLabel)
        XCTAssertNotNil(gameOverScene.leaderboardButton)
        XCTAssertNotNil(gameOverScene.retryButton)
        XCTAssertNotNil(gameOverScene.menuButton)
    }
    
    func testGameOverSceneScoreDisplay() {
        XCTAssertEqual(gameOverScene.finalScore, 1000)
        XCTAssertEqual(gameOverScene.phaseShiftTime, 10)
        XCTAssertEqual(gameOverScene.enemyKills, 50)
    }
    
    func testGameOverSceneHighScoreHandling() throws {
        // First score should be a high score
        XCTAssertTrue(gameOverScene.isHighScore)
        
        // Add a higher score
        let entry = SaveManager.LeaderboardEntry(
            username: "Player1",
            score: 2000,
            date: Date(),
            phaseShiftTime: 15,
            enemyKills: 75
        )
        try saveManager.addScoreToLeaderboard(entry)
        
        // Create new game over scene with lower score
        let newGameOverScene = GameOverScene(
            size: CGSize(width: 1024, height: 768),
            score: 500,
            phaseShiftTime: 5,
            enemyKills: 25
        )
        
        // Should not be a high score
        XCTAssertFalse(newGameOverScene.isHighScore)
    }
    
    func testGameOverSceneProfileUpdate() throws {
        // Verify profile is updated
        let profile = try saveManager.loadPlayerProfile()
        XCTAssertEqual(profile.highestScore, 1000)
        XCTAssertEqual(profile.totalEnemyKills, 50)
        XCTAssertEqual(profile.fastestPhaseShiftTime, 10)
    }
    
    func testGameOverSceneLeaderboardUpdate() throws {
        // Verify leaderboard entry is added
        let leaderboard = try saveManager.loadLeaderboard()
        XCTAssertEqual(leaderboard.count, 1)
        XCTAssertEqual(leaderboard[0].score, 1000)
        XCTAssertEqual(leaderboard[0].phaseShiftTime, 10)
        XCTAssertEqual(leaderboard[0].enemyKills, 50)
    }
    
    func testGameOverSceneTouchHandling() {
        // Test leaderboard button touch
        let leaderboardTouch = MockTouch(location: CGPoint(x: 400, y: 400))
        gameOverScene.touchesBegan([leaderboardTouch], with: nil)
        
        // Test retry button touch
        let retryTouch = MockTouch(location: CGPoint(x: 400, y: 300))
        gameOverScene.touchesBegan([retryTouch], with: nil)
        
        // Test menu button touch
        let menuTouch = MockTouch(location: CGPoint(x: 400, y: 200))
        gameOverScene.touchesBegan([menuTouch], with: nil)
    }
    
    func testGameOverSceneNavigation() {
        // Test showing leaderboard
        gameOverScene.showLeaderboard()
        
        // Test restarting game
        gameOverScene.restartGame()
        
        // Test returning to menu
        gameOverScene.returnToMenu()
    }
    
    func testGameOverSceneAnimation() {
        // Test new high score animation
        gameOverScene.animateNewHighScore()
        
        // Test score counting animation
        gameOverScene.animateScoreCounting()
    }
    
    func testGameOverSceneMultipleScores() throws {
        // Add multiple scores
        let entry1 = SaveManager.LeaderboardEntry(
            username: "Player1",
            score: 1000,
            date: Date(),
            phaseShiftTime: 10,
            enemyKills: 50
        )
        
        let entry2 = SaveManager.LeaderboardEntry(
            username: "Player2",
            score: 2000,
            date: Date(),
            phaseShiftTime: 8,
            enemyKills: 75
        )
        
        try saveManager.addScoreToLeaderboard(entry1)
        try saveManager.addScoreToLeaderboard(entry2)
        
        // Create new game over scene with higher score
        let newGameOverScene = GameOverScene(
            size: CGSize(width: 1024, height: 768),
            score: 3000,
            phaseShiftTime: 5,
            enemyKills: 100
        )
        
        // Verify it's a high score
        XCTAssertTrue(newGameOverScene.isHighScore)
        
        // Verify leaderboard is updated
        let leaderboard = try saveManager.loadLeaderboard()
        XCTAssertEqual(leaderboard.count, 3)
        XCTAssertEqual(leaderboard[0].score, 3000, "New highest score should be first")
    }
    
    func testGameOverSceneProfileStats() throws {
        // Verify profile stats are updated correctly
        let profile = try saveManager.loadPlayerProfile()
        
        // Test multiple game overs
        let gameOver2 = GameOverScene(
            size: CGSize(width: 1024, height: 768),
            score: 2000,
            phaseShiftTime: 5,
            enemyKills: 75
        )
        
        let gameOver3 = GameOverScene(
            size: CGSize(width: 1024, height: 768),
            score: 500,
            phaseShiftTime: 15,
            enemyKills: 25
        )
        
        // Load updated profile
        let updatedProfile = try saveManager.loadPlayerProfile()
        
        // Verify highest score
        XCTAssertEqual(updatedProfile.highestScore, 2000)
        
        // Verify total enemy kills
        XCTAssertEqual(updatedProfile.totalEnemyKills, 150)
        
        // Verify fastest phase shift time
        XCTAssertEqual(updatedProfile.fastestPhaseShiftTime, 5)
    }
}

// MARK: - Mock Touch
class MockTouch: UITouch {
    private let mockLocation: CGPoint
    
    init(location: CGPoint) {
        self.mockLocation = location
        super.init()
    }
    
    override func location(in view: UIView?) -> CGPoint {
        return mockLocation
    }
} 