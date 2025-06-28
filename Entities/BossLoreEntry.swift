import Foundation

class BossLoreEntry: Codable {
    // MARK: - Properties
    let id: String
    let title: String
    let description: String
    let unlockCondition: UnlockCondition
    let tier: LoreTier
    var isUnlocked: Bool
    let bossType: BossType
    let phase: Int
    let origin: String
    let weakness: String
    let quote: String
    let unlockDate: Date?
    
    // MARK: - Initialization
    init(
        id: String,
        title: String,
        description: String,
        unlockCondition: UnlockCondition,
        tier: LoreTier,
        isUnlocked: Bool,
        bossType: BossType,
        phase: Int,
        origin: String,
        weakness: String,
        quote: String,
        unlockDate: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.unlockCondition = unlockCondition
        self.tier = tier
        self.isUnlocked = isUnlocked
        self.bossType = bossType
        self.phase = phase
        self.origin = origin
        self.weakness = weakness
        self.quote = quote
        self.unlockDate = unlockDate
    }
    
    // MARK: - Factory Methods
    static func createForBoss(_ bossType: BossType, phase: Int) -> BossLoreEntry {
        let (origin, weakness, quote) = bossType.loreDetails(for: phase)
        
        return BossLoreEntry(
            id: "\(bossType)_phase_\(phase)",
            title: "\(bossType.title) - Phase \(phase)",
            description: bossType.phaseDescription(phase),
            unlockCondition: .custom("boss_phase_\(phase)"),
            tier: .mythic,
            isUnlocked: false,
            bossType: bossType,
            phase: phase,
            origin: origin,
            weakness: weakness,
            quote: quote
        )
    }
}

// MARK: - Boss Type Extensions
extension BossType {
    func loreDetails(for phase: Int) -> (origin: String, weakness: String, quote: String) {
        switch self {
        case .voidCorruptor:
            switch phase {
            case 1:
                return (
                    origin: "Born from the collapse of a quantum singularity, the Void Corruptor exists between dimensions.",
                    weakness: "Vulnerable to temporal weapons that can disrupt its quantum state.",
                    quote: "\"The void between worlds calls to me...\""
                )
            case 2:
                return (
                    origin: "As it grows in power, the Void Corruptor begins to manifest in multiple realities simultaneously.",
                    weakness: "Quantum shields can temporarily prevent its dimensional shifts.",
                    quote: "\"Your reality is but one of many I shall consume...\""
                )
            case 3:
                return (
                    origin: "At its peak, the Void Corruptor threatens to collapse all possible realities into a single void.",
                    weakness: "A perfect synchronization of quantum and temporal weapons can disrupt its core.",
                    quote: "\"The end of all things approaches...\""
                )
            default:
                return ("", "", "")
            }
            
        case .temporalWarden:
            switch phase {
            case 1:
                return (
                    origin: "A guardian of the time stream, the Temporal Warden exists across all points in time.",
                    weakness: "Vulnerable to void energy that can disrupt its temporal anchor.",
                    quote: "\"Time is a river, and I am its keeper...\""
                )
            case 2:
                return (
                    origin: "As it grows stronger, the Warden begins to manipulate the flow of time itself.",
                    weakness: "Quantum entanglement can temporarily lock it in a single timeline.",
                    quote: "\"Your past and future are mine to command...\""
                )
            case 3:
                return (
                    origin: "At full power, the Temporal Warden threatens to collapse the entire timeline.",
                    weakness: "A perfect void-temporal resonance can disrupt its control over time.",
                    quote: "\"The timeline ends here...\""
                )
            default:
                return ("", "", "")
            }
            
        case .quantumBehemoth:
            switch phase {
            case 1:
                return (
                    origin: "A massive quantum entity, the Behemoth exists in multiple states simultaneously.",
                    weakness: "Temporal weapons can force it to collapse into a single state.",
                    quote: "\"I exist in all possible states...\""
                )
            case 2:
                return (
                    origin: "As it grows, the Behemoth begins to affect the quantum state of all matter around it.",
                    weakness: "Void energy can temporarily disrupt its quantum field.",
                    quote: "\"Your reality is but one possibility among infinite...\""
                )
            case 3:
                return (
                    origin: "At its peak, the Quantum Behemoth threatens to collapse all quantum possibilities.",
                    weakness: "A perfect harmony of void and temporal energy can disrupt its quantum core.",
                    quote: "\"The quantum sea shall consume all...\""
                )
            default:
                return ("", "", "")
            }
        }
    }
}

// MARK: - Codable
extension BossLoreEntry {
    enum CodingKeys: String, CodingKey {
        case id, title, description, unlockCondition, tier, isUnlocked
        case bossType, phase, origin, weakness, quote, unlockDate
    }
    
    convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let id = try container.decode(String.self, forKey: .id)
        let title = try container.decode(String.self, forKey: .title)
        let description = try container.decode(String.self, forKey: .description)
        let unlockCondition = try container.decode(UnlockCondition.self, forKey: .unlockCondition)
        let tier = try container.decode(LoreTier.self, forKey: .tier)
        let isUnlocked = try container.decode(Bool.self, forKey: .isUnlocked)
        let bossType = try container.decode(BossType.self, forKey: .bossType)
        let phase = try container.decode(Int.self, forKey: .phase)
        let origin = try container.decode(String.self, forKey: .origin)
        let weakness = try container.decode(String.self, forKey: .weakness)
        let quote = try container.decode(String.self, forKey: .quote)
        let unlockDate = try container.decodeIfPresent(Date.self, forKey: .unlockDate)
        
        self.init(
            id: id,
            title: title,
            description: description,
            unlockCondition: unlockCondition,
            tier: tier,
            isUnlocked: isUnlocked,
            bossType: bossType,
            phase: phase,
            origin: origin,
            weakness: weakness,
            quote: quote,
            unlockDate: unlockDate
        )
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(description, forKey: .description)
        try container.encode(unlockCondition, forKey: .unlockCondition)
        try container.encode(tier, forKey: .tier)
        try container.encode(isUnlocked, forKey: .isUnlocked)
        try container.encode(bossType, forKey: .bossType)
        try container.encode(phase, forKey: .phase)
        try container.encode(origin, forKey: .origin)
        try container.encode(weakness, forKey: .weakness)
        try container.encode(quote, forKey: .quote)
        try container.encodeIfPresent(unlockDate, forKey: .unlockDate)
    }
} 