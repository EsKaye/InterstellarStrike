import Foundation

class SaveManager {
    // MARK: - Singleton
    static let shared = SaveManager()
    private init() {}
    
    // MARK: - File Paths
    private var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private var playerProfilePath: URL {
        documentsDirectory.appendingPathComponent("player_profile.json")
    }
    
    private var leaderboardPath: URL {
        documentsDirectory.appendingPathComponent("leaderboard.json")
    }
    
    private var settingsPath: URL {
        documentsDirectory.appendingPathComponent("game_settings.json")
    }
    
    // MARK: - Game Settings
    struct GameSettings: Codable {
        var soundEnabled: Bool
        var musicVolume: Float
        var effectsVolume: Float
        var controlStyle: ControlStyle
        var difficulty: GameDifficulty
        
        enum ControlStyle: String, Codable {
            case touch
            case tilt
            case hybrid
        }
        
        enum GameDifficulty: String, Codable {
            case easy
            case normal
            case hard
        }
        
        static var `default`: GameSettings {
            GameSettings(
                soundEnabled: true,
                musicVolume: 0.7,
                effectsVolume: 1.0,
                controlStyle: .touch,
                difficulty: .normal
            )
        }
    }
    
    // MARK: - Leaderboard Entry
    struct LeaderboardEntry: Codable {
        var username: String
        var score: Int
        var date: Date
        var phaseShiftTime: TimeInterval?
        var enemyKills: Int
    }
    
    // MARK: - Save Methods
    func savePlayerProfile(_ profile: PlayerProfile) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(profile)
        try data.write(to: playerProfilePath)
    }
    
    func loadPlayerProfile() throws -> PlayerProfile {
        guard let data = try? Data(contentsOf: playerProfilePath) else {
            return PlayerProfile()
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(PlayerProfile.self, from: data)
    }
    
    func saveLeaderboard(_ entries: [LeaderboardEntry]) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(entries)
        try data.write(to: leaderboardPath)
    }
    
    func loadLeaderboard() throws -> [LeaderboardEntry] {
        guard let data = try? Data(contentsOf: leaderboardPath) else {
            return []
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode([LeaderboardEntry].self, from: data)
    }
    
    func saveGameSettings(_ settings: GameSettings) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(settings)
        try data.write(to: settingsPath)
    }
    
    func loadGameSettings() throws -> GameSettings {
        guard let data = try? Data(contentsOf: settingsPath) else {
            return GameSettings.default
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode(GameSettings.self, from: data)
    }
    
    // MARK: - Leaderboard Management
    func addScoreToLeaderboard(_ entry: LeaderboardEntry) throws {
        var leaderboard = try loadLeaderboard()
        leaderboard.append(entry)
        leaderboard.sort { $0.score > $1.score }
        
        // Keep only top 100 scores
        if leaderboard.count > 100 {
            leaderboard = Array(leaderboard.prefix(100))
        }
        
        try saveLeaderboard(leaderboard)
    }
    
    func isHighScore(_ score: Int) throws -> Bool {
        let leaderboard = try loadLeaderboard()
        return leaderboard.count < 100 || score > leaderboard.last?.score ?? 0
    }
    
    // MARK: - Profile Management
    func resetPlayerProfile() throws {
        let newProfile = PlayerProfile()
        try savePlayerProfile(newProfile)
    }
    
    // MARK: - Settings Management
    func resetGameSettings() throws {
        try saveGameSettings(GameSettings.default)
    }
    
    // MARK: - Data Cleanup
    func clearAllData() throws {
        try? FileManager.default.removeItem(at: playerProfilePath)
        try? FileManager.default.removeItem(at: leaderboardPath)
        try? FileManager.default.removeItem(at: settingsPath)
    }
} 