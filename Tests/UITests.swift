import XCTest
@testable import InterstellarStrike

class UITests: XCTestCase {
    var gameScene: GameScene!
    var saveManager: SaveManager!
    
    override func setUp() {
        super.setUp()
        gameScene = GameScene(size: CGSize(width: 1024, height: 768))
        saveManager = SaveManager.shared
        
        // Clear any existing data
        try? saveManager.clearAllData()
        
        // Add some test data
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
        
        try? saveManager.addScoreToLeaderboard(entry1)
        try? saveManager.addScoreToLeaderboard(entry2)
    }
    
    override func tearDown() {
        try? saveManager.clearAllData()
        super.tearDown()
    }
    
    // MARK: - LeaderboardView Tests
    func testLeaderboardViewInitialization() {
        let leaderboardView = LeaderboardView(size: CGSize(width: 800, height: 600))
        
        XCTAssertNotNil(leaderboardView.background)
        XCTAssertNotNil(leaderboardView.titleLabel)
        XCTAssertNotNil(leaderboardView.closeButton)
        XCTAssertNotNil(leaderboardView.scrollView)
        XCTAssertNotNil(leaderboardView.contentNode)
    }
    
    func testLeaderboardViewTabSwitching() {
        let leaderboardView = LeaderboardView(size: CGSize(width: 800, height: 600))
        
        // Test initial tab
        XCTAssertEqual(leaderboardView.currentTab, .scores)
        
        // Switch to phase shift tab
        leaderboardView.currentTab = .phaseShift
        XCTAssertEqual(leaderboardView.currentTab, .phaseShift)
        
        // Switch to kills tab
        leaderboardView.currentTab = .kills
        XCTAssertEqual(leaderboardView.currentTab, .kills)
    }
    
    func testLeaderboardViewEntryDisplay() {
        let leaderboardView = LeaderboardView(size: CGSize(width: 800, height: 600))
        
        // Verify entries are displayed
        XCTAssertEqual(leaderboardView.leaderboardEntries.count, 2)
        
        // Verify sorting (highest score first)
        XCTAssertEqual(leaderboardView.leaderboardEntries[0].score, 2000)
        XCTAssertEqual(leaderboardView.leaderboardEntries[1].score, 1000)
    }
    
    func testLeaderboardViewTouchHandling() {
        let leaderboardView = LeaderboardView(size: CGSize(width: 800, height: 600))
        
        // Test close button touch
        let closeButtonTouch = MockTouch(location: CGPoint(x: 750, y: 550))
        leaderboardView.touchesBegan([closeButtonTouch], with: nil)
        
        // Test tab button touches
        let scoresTabTouch = MockTouch(location: CGPoint(x: 200, y: 550))
        leaderboardView.touchesBegan([scoresTabTouch], with: nil)
        XCTAssertEqual(leaderboardView.currentTab, .scores)
        
        let phaseShiftTabTouch = MockTouch(location: CGPoint(x: 400, y: 550))
        leaderboardView.touchesBegan([phaseShiftTabTouch], with: nil)
        XCTAssertEqual(leaderboardView.currentTab, .phaseShift)
        
        let killsTabTouch = MockTouch(location: CGPoint(x: 600, y: 550))
        leaderboardView.touchesBegan([killsTabTouch], with: nil)
        XCTAssertEqual(leaderboardView.currentTab, .kills)
    }
    
    // MARK: - ProfileMenu Tests
    func testProfileMenuInitialization() {
        let profileMenu = ProfileMenu(size: CGSize(width: 800, height: 600))
        
        XCTAssertNotNil(profileMenu.background)
        XCTAssertNotNil(profileMenu.titleLabel)
        XCTAssertNotNil(profileMenu.closeButton)
        XCTAssertNotNil(profileMenu.usernameLabel)
        XCTAssertNotNil(profileMenu.usernameInput)
        XCTAssertNotNil(profileMenu.statsContainer)
        XCTAssertNotNil(profileMenu.resetButton)
    }
    
    func testProfileMenuUsernameEditing() {
        let profileMenu = ProfileMenu(size: CGSize(width: 800, height: 600))
        
        // Test initial state
        XCTAssertFalse(profileMenu.isEditingUsername)
        
        // Start editing
        let editTouch = MockTouch(location: CGPoint(x: 400, y: 500))
        profileMenu.touchesBegan([editTouch], with: nil)
        XCTAssertTrue(profileMenu.isEditingUsername)
        
        // Finish editing
        profileMenu.finishEditingUsername()
        XCTAssertFalse(profileMenu.isEditingUsername)
    }
    
    func testProfileMenuStatsDisplay() {
        let profileMenu = ProfileMenu(size: CGSize(width: 800, height: 600))
        
        // Verify stats are displayed
        XCTAssertNotNil(profileMenu.statsContainer)
        XCTAssertGreaterThan(profileMenu.statsContainer.children.count, 0)
    }
    
    func testProfileMenuResetConfirmation() {
        let profileMenu = ProfileMenu(size: CGSize(width: 800, height: 600))
        
        // Test reset button touch
        let resetTouch = MockTouch(location: CGPoint(x: 400, y: 100))
        profileMenu.touchesBegan([resetTouch], with: nil)
        
        // Verify alert is presented
        XCTAssertTrue(profileMenu.isPresentingAlert)
    }
    
    func testProfileMenuTouchHandling() {
        let profileMenu = ProfileMenu(size: CGSize(width: 800, height: 600))
        
        // Test close button touch
        let closeButtonTouch = MockTouch(location: CGPoint(x: 750, y: 550))
        profileMenu.touchesBegan([closeButtonTouch], with: nil)
        
        // Test username edit touch
        let editTouch = MockTouch(location: CGPoint(x: 400, y: 500))
        profileMenu.touchesBegan([editTouch], with: nil)
        XCTAssertTrue(profileMenu.isEditingUsername)
        
        // Test reset button touch
        let resetTouch = MockTouch(location: CGPoint(x: 400, y: 100))
        profileMenu.touchesBegan([resetTouch], with: nil)
        XCTAssertTrue(profileMenu.isPresentingAlert)
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