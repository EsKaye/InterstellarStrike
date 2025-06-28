import Foundation

enum LoreTier: String, Codable {
    case common = "Common"
    case rare = "Rare"
    case mythic = "Mythic"
}

struct LoreEntry: Codable {
    let id: String
    let title: String
    let description: String
    let unlockCondition: UnlockCondition
    let tier: LoreTier
    var isUnlocked: Bool
    var unlockDate: Date?
    
    enum UnlockCondition: Codable {
        case enemyKills(Int)
        case phaseShiftUses(Int)
        case bossDefeats(Int)
        case powerUpUses(String, Int) // powerUp type and count
        case scoreThreshold(Int)
        case custom(String)
    }
}

class LoreManager {
    // MARK: - Singleton
    static let shared = LoreManager()
    private init() {
        loadLoreEntries()
    }
    
    // MARK: - Properties
    private var loreEntries: [LoreEntry] = []
    private let saveKey = "unlocked_lore_entries"
    
    // MARK: - Lore Management
    private func loadLoreEntries() {
        // Initialize with default lore entries
        loreEntries = [
            LoreEntry(
                id: "syndicate_fall",
                title: "The Fall of the Syndicate",
                description: "The Celestial Syndicate, once the greatest power in the galaxy, fell to an unknown force. Their last transmission was a warning about a dark energy anomaly.",
                unlockCondition: .enemyKills(100),
                tier: .common,
                isUnlocked: false
            ),
            LoreEntry(
                id: "phase_shift_origin",
                title: "Origins of Phase Shift",
                description: "The Phase Shift technology was developed by Syndicate scientists to combat the dark energy anomaly. It allows ships to temporarily exist between dimensions.",
                unlockCondition: .phaseShiftUses(10),
                tier: .rare,
                isUnlocked: false
            ),
            LoreEntry(
                id: "dark_anomaly",
                title: "The Dark Anomaly",
                description: "A mysterious force that corrupts and transforms matter. The Syndicate's last research suggests it's growing stronger with each passing cycle.",
                unlockCondition: .bossDefeats(3),
                tier: .mythic,
                isUnlocked: false
            ),
            
            // New entries
            LoreEntry(
                id: "quantum_shield",
                title: "Quantum Shield Technology",
                description: "The Syndicate's most advanced defensive system. By manipulating quantum fields, it creates an impenetrable barrier around the ship. However, the energy cost is immense.",
                unlockCondition: .powerUpUses("shield", 25),
                tier: .rare,
                isUnlocked: false
            ),
            LoreEntry(
                id: "temporal_weapons",
                title: "Temporal Weapons Research",
                description: "Early experiments with time manipulation led to the development of rapid-fire systems. The technology was controversial due to its potential to destabilize local spacetime.",
                unlockCondition: .powerUpUses("rapid_fire", 30),
                tier: .rare,
                isUnlocked: false
            ),
            LoreEntry(
                id: "syndicate_fleet",
                title: "The Last Fleet",
                description: "Before the fall, the Syndicate maintained a fleet of advanced warships. Each vessel was equipped with experimental technology, including the prototype you now pilot.",
                unlockCondition: .scoreThreshold(5000),
                tier: .common,
                isUnlocked: false
            ),
            LoreEntry(
                id: "void_corruption",
                title: "Void Corruption",
                description: "The dark energy anomaly doesn't just destroy - it corrupts. Ships that come too close are transformed into twisted versions of themselves, their pilots lost to the void.",
                unlockCondition: .enemyKills(500),
                tier: .mythic,
                isUnlocked: false
            ),
            LoreEntry(
                id: "syndicate_archives",
                title: "Syndicate Archives",
                description: "The last remaining database of Syndicate knowledge. It contains blueprints, research data, and historical records. Most of it is encrypted, waiting to be unlocked.",
                unlockCondition: .custom("collect_all_powerups"),
                tier: .mythic,
                isUnlocked: false
            ),
            LoreEntry(
                id: "quantum_cores",
                title: "Quantum Energy Cores",
                description: "The power source of Phase Shift technology. These cores contain concentrated quantum energy, allowing ships to briefly phase between dimensions.",
                unlockCondition: .phaseShiftUses(50),
                tier: .rare,
                isUnlocked: false
            ),
            LoreEntry(
                id: "syndicate_commanders",
                title: "The Last Commanders",
                description: "The Syndicate's elite pilots were known as Commanders. Each was a master of their ship and its unique capabilities. You were the last to be trained.",
                unlockCondition: .bossDefeats(10),
                tier: .mythic,
                isUnlocked: false
            ),
            LoreEntry(
                id: "temporal_anomalies",
                title: "Temporal Anomalies",
                description: "The dark energy has begun to affect time itself. Some regions of space experience time dilation, while others are caught in temporal loops.",
                unlockCondition: .powerUpUses("slow_time", 40),
                tier: .rare,
                isUnlocked: false
            ),
            LoreEntry(
                id: "syndicate_origins",
                title: "The Syndicate's Rise",
                description: "Founded by the greatest minds of their time, the Celestial Syndicate began as a research organization. Their discoveries in quantum physics led to their dominance.",
                unlockCondition: .scoreThreshold(10000),
                tier: .common,
                isUnlocked: false
            )
        ]
        
        // Load unlocked entries
        if let savedData = UserDefaults.standard.data(forKey: saveKey),
           let unlockedIds = try? JSONDecoder().decode([String].self, from: savedData) {
            for (index, entry) in loreEntries.enumerated() {
                if unlockedIds.contains(entry.id) {
                    loreEntries[index].isUnlocked = true
                    loreEntries[index].unlockDate = Date()
                }
            }
        }
    }
    
    func checkUnlockConditions(gameStats: GameStats) {
        var updated = false
        
        for (index, entry) in loreEntries.enumerated() {
            if entry.isUnlocked { continue }
            
            let shouldUnlock = checkCondition(entry.unlockCondition, against: gameStats)
            if shouldUnlock {
                loreEntries[index].isUnlocked = true
                loreEntries[index].unlockDate = Date()
                updated = true
                
                // Notify about new lore unlock
                NotificationCenter.default.post(
                    name: .newLoreUnlocked,
                    object: nil,
                    userInfo: ["loreEntry": loreEntries[index]]
                )
            }
        }
        
        if updated {
            saveUnlockedEntries()
        }
    }
    
    private func checkCondition(_ condition: LoreEntry.UnlockCondition, against stats: GameStats) -> Bool {
        switch condition {
        case .enemyKills(let required):
            return stats.totalEnemyKills >= required
        case .phaseShiftUses(let required):
            return stats.phaseShiftUses >= required
        case .bossDefeats(let required):
            return stats.bossDefeats >= required
        case .powerUpUses(let type, let required):
            return stats.powerUpUses[type] ?? 0 >= required
        case .scoreThreshold(let required):
            return stats.highestScore >= required
        case .custom(let condition):
            // Handle custom conditions
            return false
        }
    }
    
    private func saveUnlockedEntries() {
        let unlockedIds = loreEntries.filter { $0.isUnlocked }.map { $0.id }
        if let data = try? JSONEncoder().encode(unlockedIds) {
            UserDefaults.standard.set(data, forKey: saveKey)
        }
    }
    
    // MARK: - Public Interface
    func getAllLoreEntries() -> [LoreEntry] {
        return loreEntries
    }
    
    func getUnlockedLoreEntries() -> [LoreEntry] {
        return loreEntries.filter { $0.isUnlocked }
    }
    
    func getLoreEntry(id: String) -> LoreEntry? {
        return loreEntries.first { $0.id == id }
    }
}

// MARK: - Notifications
extension Notification.Name {
    static let newLoreUnlocked = Notification.Name("newLoreUnlocked")
}

// MARK: - Game Stats
struct GameStats {
    var totalEnemyKills: Int = 0
    var phaseShiftUses: Int = 0
    var bossDefeats: Int = 0
    var powerUpUses: [String: Int] = [:]
    var highestScore: Int = 0
} 