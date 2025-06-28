private var gameStats = GameStats()
private var loreManager = LoreManager.shared

private var newLoreNotification: SKLabelNode?

func setupLoreNotifications() {
    NotificationCenter.default.addObserver(
        self,
        selector: #selector(handleNewLoreUnlocked(_:)),
        name: .newLoreUnlocked,
        object: nil
    )
}

@objc private func handleNewLoreUnlocked(_ notification: Notification) {
    guard let loreEntry = notification.userInfo?["loreEntry"] as? LoreEntry else { return }
    showLoreUnlockedNotification(for: loreEntry)
}

private func showLoreUnlockedNotification(for entry: LoreEntry) {
    // Remove existing notification if any
    newLoreNotification?.removeFromParent()
    
    // Create new notification
    let notification = SKLabelNode(fontNamed: "AvenirNext-Bold")
    notification.text = "New Lore Unlocked: \(entry.title)"
    notification.fontSize = 20
    notification.fontColor = .white
    notification.position = CGPoint(x: frame.midX, y: frame.maxY - 50)
    notification.alpha = 0
    addChild(notification)
    
    // Animate notification
    let sequence = SKAction.sequence([
        SKAction.fadeIn(withDuration: 0.5),
        SKAction.wait(forDuration: 3.0),
        SKAction.fadeOut(withDuration: 0.5),
        SKAction.removeFromParent()
    ])
    
    notification.run(sequence)
    newLoreNotification = notification
}

func updateScore(_ points: Int) {
    score += points
    gameStats.highestScore = max(gameStats.highestScore, score)
    loreManager.checkUnlockConditions(gameStats: gameStats)
}

func recordEnemyKill() {
    gameStats.totalEnemyKills += 1
    loreManager.checkUnlockConditions(gameStats: gameStats)
}

func recordBossDefeat() {
    gameStats.bossDefeats += 1
    loreManager.checkUnlockConditions(gameStats: gameStats)
}

func recordPhaseShiftUse() {
    gameStats.phaseShiftUses += 1
    loreManager.checkUnlockConditions(gameStats: gameStats)
}

func recordPowerUpUse(_ type: String) {
    gameStats.powerUpUses[type, default: 0] += 1
    loreManager.checkUnlockConditions(gameStats: gameStats)
}

deinit {
    NotificationCenter.default.removeObserver(self)
} 