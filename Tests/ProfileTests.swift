import XCTest
@testable import InterstellarStrike

class ProfileTests: XCTestCase {
    var saveManager: SaveManager!
    var testProfile: PlayerProfile!
    
    override func setUp() {
        super.setUp()
        saveManager = SaveManager.shared
        testProfile = PlayerProfile(username: "TestPlayer")
        
        // Clear any existing data
        try? saveManager.clearAllData()
    }
    
    override func tearDown() {
        try? saveManager.clearAllData()
        super.tearDown()
    }
    
    // MARK: - PlayerProfile Tests
    func testProfileInitialization() {
        XCTAssertEqual(testProfile.username, "TestPlayer")
        XCTAssertEqual(testProfile.highestScore, 0)
        XCTAssertEqual(testProfile.totalTimePlayed, 0)
        XCTAssertEqual(testProfile.totalEnemyKills, 0)
        XCTAssertNil(testProfile.fastestPhaseShiftTime)
    }
    
    func testProfileScoreUpdate() {
        testProfile.updateScore(1000)
        XCTAssertEqual(testProfile.highestScore, 1000)
        
        testProfile.updateScore(500)
        XCTAssertEqual(testProfile.highestScore, 1000, "Highest score should not decrease")
        
        testProfile.updateScore(2000)
        XCTAssertEqual(testProfile.highestScore, 2000, "Highest score should update when higher")
    }
    
    func testProfilePlayTime() {
        testProfile.addPlayTime(3600) // 1 hour
        XCTAssertEqual(testProfile.totalTimePlayed, 3600)
        
        testProfile.addPlayTime(1800) // 30 minutes
        XCTAssertEqual(testProfile.totalTimePlayed, 5400)
    }
    
    func testProfilePowerUpStats() {
        testProfile.recordPowerUpUse(type: .shield, duration: 10)
        XCTAssertEqual(testProfile.powerUpStats.shieldUses, 1)
        XCTAssertEqual(testProfile.powerUpStats.shieldDuration, 10)
        
        testProfile.recordPowerUpUse(type: .rapidFire, duration: 15)
        XCTAssertEqual(testProfile.powerUpStats.rapidFireUses, 1)
        XCTAssertEqual(testProfile.powerUpStats.rapidFireDuration, 15)
        
        testProfile.recordPowerUpUse(type: .slowTime, duration: 20)
        XCTAssertEqual(testProfile.powerUpStats.slowTimeUses, 1)
        XCTAssertEqual(testProfile.powerUpStats.slowTimeDuration, 20)
        
        XCTAssertEqual(testProfile.powerUpStats.totalPowerUpsCollected, 3)
    }
    
    func testProfilePhaseShiftTime() {
        testProfile.recordPhaseShiftTime(10)
        XCTAssertEqual(testProfile.fastestPhaseShiftTime, 10)
        
        testProfile.recordPhaseShiftTime(5)
        XCTAssertEqual(testProfile.fastestPhaseShiftTime, 5, "Should update to faster time")
        
        testProfile.recordPhaseShiftTime(15)
        XCTAssertEqual(testProfile.fastestPhaseShiftTime, 5, "Should not update to slower time")
    }
    
    func testProfileEnemyKills() {
        testProfile.incrementEnemyKills()
        XCTAssertEqual(testProfile.totalEnemyKills, 1)
        
        testProfile.incrementEnemyKills()
        XCTAssertEqual(testProfile.totalEnemyKills, 2)
    }
    
    // MARK: - SaveManager Tests
    func testSaveAndLoadProfile() throws {
        // Save profile
        try saveManager.savePlayerProfile(testProfile)
        
        // Load profile
        let loadedProfile = try saveManager.loadPlayerProfile()
        
        XCTAssertEqual(loadedProfile.username, testProfile.username)
        XCTAssertEqual(loadedProfile.highestScore, testProfile.highestScore)
        XCTAssertEqual(loadedProfile.totalTimePlayed, testProfile.totalTimePlayed)
        XCTAssertEqual(loadedProfile.totalEnemyKills, testProfile.totalEnemyKills)
    }
    
    func testLeaderboardManagement() throws {
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
        
        // Add entries
        try saveManager.addScoreToLeaderboard(entry1)
        try saveManager.addScoreToLeaderboard(entry2)
        
        // Load leaderboard
        let leaderboard = try saveManager.loadLeaderboard()
        
        XCTAssertEqual(leaderboard.count, 2)
        XCTAssertEqual(leaderboard[0].score, 2000, "Higher score should be first")
        XCTAssertEqual(leaderboard[1].score, 1000)
    }
    
    func testHighScoreCheck() throws {
        let entry = SaveManager.LeaderboardEntry(
            username: "Player1",
            score: 1000,
            date: Date(),
            phaseShiftTime: nil,
            enemyKills: 0
        )
        
        try saveManager.addScoreToLeaderboard(entry)
        
        XCTAssertTrue(try saveManager.isHighScore(2000), "Higher score should be considered high score")
        XCTAssertFalse(try saveManager.isHighScore(500), "Lower score should not be considered high score")
    }
    
    func testGameSettings() throws {
        let settings = SaveManager.GameSettings(
            soundEnabled: true,
            musicVolume: 0.8,
            effectsVolume: 0.9,
            controlStyle: .tilt,
            difficulty: .hard
        )
        
        // Save settings
        try saveManager.saveGameSettings(settings)
        
        // Load settings
        let loadedSettings = try saveManager.loadGameSettings()
        
        XCTAssertEqual(loadedSettings.soundEnabled, settings.soundEnabled)
        XCTAssertEqual(loadedSettings.musicVolume, settings.musicVolume)
        XCTAssertEqual(loadedSettings.effectsVolume, settings.effectsVolume)
        XCTAssertEqual(loadedSettings.controlStyle, settings.controlStyle)
        XCTAssertEqual(loadedSettings.difficulty, settings.difficulty)
    }
    
    func testDefaultGameSettings() throws {
        let settings = try saveManager.loadGameSettings()
        
        XCTAssertEqual(settings.soundEnabled, SaveManager.GameSettings.default.soundEnabled)
        XCTAssertEqual(settings.musicVolume, SaveManager.GameSettings.default.musicVolume)
        XCTAssertEqual(settings.effectsVolume, SaveManager.GameSettings.default.effectsVolume)
        XCTAssertEqual(settings.controlStyle, SaveManager.GameSettings.default.controlStyle)
        XCTAssertEqual(settings.difficulty, SaveManager.GameSettings.default.difficulty)
    }
    
    func testProfileReset() throws {
        // Set up profile with data
        testProfile.updateScore(1000)
        testProfile.addPlayTime(3600)
        testProfile.recordPowerUpUse(type: .shield, duration: 10)
        
        // Save profile
        try saveManager.savePlayerProfile(testProfile)
        
        // Reset profile
        try saveManager.resetPlayerProfile()
        
        // Load reset profile
        let resetProfile = try saveManager.loadPlayerProfile()
        
        XCTAssertEqual(resetProfile.highestScore, 0)
        XCTAssertEqual(resetProfile.totalTimePlayed, 0)
        XCTAssertEqual(resetProfile.powerUpStats.totalPowerUpsCollected, 0)
    }
    
    func testDataCleanup() throws {
        // Set up test data
        try saveManager.savePlayerProfile(testProfile)
        try saveManager.addScoreToLeaderboard(SaveManager.LeaderboardEntry(
            username: "Test",
            score: 1000,
            date: Date(),
            phaseShiftTime: nil,
            enemyKills: 0
        ))
        try saveManager.saveGameSettings(SaveManager.GameSettings.default)
        
        // Clear all data
        try saveManager.clearAllData()
        
        // Verify data is cleared
        let newProfile = try saveManager.loadPlayerProfile()
        let leaderboard = try saveManager.loadLeaderboard()
        
        XCTAssertEqual(newProfile.username, "Player")
        XCTAssertEqual(leaderboard.count, 0)
    }
} 