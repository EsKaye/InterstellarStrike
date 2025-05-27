import Foundation

struct PlayerProfile: Codable {
    // MARK: - Properties
    var username: String
    var highestScore: Int
    var totalTimePlayed: TimeInterval
    var powerUpStats: PowerUpStats
    var mostUsedShip: String
    var totalEnemyKills: Int
    var fastestPhaseShiftTime: TimeInterval?
    var lastPlayedDate: Date
    
    // MARK: - Nested Types
    struct PowerUpStats: Codable {
        var shieldUses: Int
        var rapidFireUses: Int
        var slowTimeUses: Int
        var totalPowerUpsCollected: Int
        
        var shieldDuration: TimeInterval
        var rapidFireDuration: TimeInterval
        var slowTimeDuration: TimeInterval
    }
    
    // MARK: - Initialization
    init(username: String = "Player") {
        self.username = username
        self.highestScore = 0
        self.totalTimePlayed = 0
        self.powerUpStats = PowerUpStats(
            shieldUses: 0,
            rapidFireUses: 0,
            slowTimeUses: 0,
            totalPowerUpsCollected: 0,
            shieldDuration: 0,
            rapidFireDuration: 0,
            slowTimeDuration: 0
        )
        self.mostUsedShip = "Default"
        self.totalEnemyKills = 0
        self.fastestPhaseShiftTime = nil
        self.lastPlayedDate = Date()
    }
    
    // MARK: - Methods
    mutating func updateScore(_ newScore: Int) {
        if newScore > highestScore {
            highestScore = newScore
        }
    }
    
    mutating func addPlayTime(_ time: TimeInterval) {
        totalTimePlayed += time
    }
    
    mutating func recordPowerUpUse(type: PowerUpType, duration: TimeInterval) {
        switch type {
        case .shield:
            powerUpStats.shieldUses += 1
            powerUpStats.shieldDuration += duration
        case .rapidFire:
            powerUpStats.rapidFireUses += 1
            powerUpStats.rapidFireDuration += duration
        case .slowTime:
            powerUpStats.slowTimeUses += 1
            powerUpStats.slowTimeDuration += duration
        }
        powerUpStats.totalPowerUpsCollected += 1
    }
    
    mutating func recordPhaseShiftTime(_ time: TimeInterval) {
        if fastestPhaseShiftTime == nil || time < fastestPhaseShiftTime! {
            fastestPhaseShiftTime = time
        }
    }
    
    mutating func incrementEnemyKills() {
        totalEnemyKills += 1
    }
    
    mutating func updateLastPlayed() {
        lastPlayedDate = Date()
    }
    
    // MARK: - Statistics
    var averagePowerUpDuration: TimeInterval {
        let totalDuration = powerUpStats.shieldDuration + 
                          powerUpStats.rapidFireDuration + 
                          powerUpStats.slowTimeDuration
        return powerUpStats.totalPowerUpsCollected > 0 ? 
               totalDuration / Double(powerUpStats.totalPowerUpsCollected) : 0
    }
    
    var mostUsedPowerUp: PowerUpType {
        let uses = [
            (PowerUpType.shield, powerUpStats.shieldUses),
            (PowerUpType.rapidFire, powerUpStats.rapidFireUses),
            (PowerUpType.slowTime, powerUpStats.slowTimeUses)
        ]
        return uses.max(by: { $0.1 < $1.1 })?.0 ?? .shield
    }
    
    var formattedTotalTimePlayed: String {
        let hours = Int(totalTimePlayed) / 3600
        let minutes = (Int(totalTimePlayed) % 3600) / 60
        return String(format: "%dh %dm", hours, minutes)
    }
} 