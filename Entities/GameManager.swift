import SpriteKit

// MARK: - Game States
enum GameState {
    case menu
    case playing
    case paused
    case gameOver
    case phaseShift
}

class GameManager {
    // MARK: - Singleton
    static let shared = GameManager()
    private init() {}
    
    // MARK: - Properties
    private(set) var currentState: GameState = .menu
    private(set) var currentScore: Int = 0
    private(set) var highScore: Int = 0
    private(set) var scoreMultiplier: Int = 1
    
    // PowerUp tracking
    private var activePowerUps: [PowerUpType: TimeInterval] = [:]
    private var energyCoreTimer: TimeInterval = 0
    
    // MARK: - State Management
    func transition(to newState: GameState, in scene: SKScene) {
        let oldState = currentState
        currentState = newState
        
        switch (oldState, newState) {
        case (.menu, .playing):
            handleMenuToPlaying(in: scene)
        case (.playing, .paused):
            handlePlayingToPaused(in: scene)
        case (.paused, .playing):
            handlePausedToPlaying(in: scene)
        case (.playing, .gameOver):
            handlePlayingToGameOver(in: scene)
        case (.gameOver, .menu):
            handleGameOverToMenu(in: scene)
        case (.playing, .phaseShift):
            handlePlayingToPhaseShift(in: scene)
        case (.phaseShift, .playing):
            handlePhaseShiftToPlaying(in: scene)
        default:
            print("Invalid state transition from \(oldState) to \(newState)")
        }
    }
    
    // MARK: - State Transition Handlers
    private func handleMenuToPlaying(in scene: SKScene) {
        guard let gameScene = scene as? GameScene else { return }
        // Reset game state
        currentScore = 0
        scoreMultiplier = 1
        activePowerUps.removeAll()
        energyCoreTimer = 0
        gameScene.resetGame()
    }
    
    private func handlePlayingToPaused(in scene: SKScene) {
        scene.isPaused = true
        // TODO: Show pause menu overlay
    }
    
    private func handlePausedToPlaying(in scene: SKScene) {
        scene.isPaused = false
        // TODO: Hide pause menu overlay
    }
    
    private func handlePlayingToGameOver(in scene: SKScene) {
        // Update high score if needed
        if currentScore > highScore {
            highScore = currentScore
            // TODO: Save high score to UserDefaults
        }
        
        // TODO: Show game over overlay with score and restart button
    }
    
    private func handleGameOverToMenu(in scene: SKScene) {
        // Reset game state
        currentScore = 0
        scoreMultiplier = 1
        activePowerUps.removeAll()
        energyCoreTimer = 0
        // TODO: Hide game over overlay
    }
    
    private func handlePlayingToPhaseShift(in scene: SKScene) {
        // Double score multiplier
        scoreMultiplier = 2
    }
    
    private func handlePhaseShiftToPlaying(in scene: SKScene) {
        // Reset score multiplier
        scoreMultiplier = 1
    }
    
    // MARK: - Score Management
    func addScore(_ points: Int) {
        currentScore += points * scoreMultiplier
    }
    
    func resetScore() {
        currentScore = 0
    }
    
    // MARK: - PowerUp Management
    func activatePowerUp(_ type: PowerUpType) {
        activePowerUps[type] = type.duration
    }
    
    func updatePowerUps(deltaTime: TimeInterval) {
        for (type, timeRemaining) in activePowerUps {
            let newTime = timeRemaining - deltaTime
            if newTime <= 0 {
                activePowerUps.removeValue(forKey: type)
            } else {
                activePowerUps[type] = newTime
            }
        }
    }
    
    func isPowerUpActive(_ type: PowerUpType) -> Bool {
        return activePowerUps[type] != nil
    }
    
    func getPowerUpTimeRemaining(_ type: PowerUpType) -> TimeInterval {
        return activePowerUps[type] ?? 0
    }
    
    // MARK: - Energy Core Management
    func updateEnergyCoreTimer(deltaTime: TimeInterval) {
        energyCoreTimer += deltaTime
        if energyCoreTimer >= 30.0 {
            energyCoreTimer = 0
            // TODO: Spawn energy core
        }
    }
} 