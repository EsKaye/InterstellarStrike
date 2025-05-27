import SpriteKit
import AVFoundation

class AudioManager {
    // MARK: - Singleton
    static let shared = AudioManager()
    private init() {
        setupAudioSession()
    }
    
    // MARK: - Properties
    private var backgroundMusicPlayer: AVAudioPlayer?
    private var soundEffects: [String: AVAudioPlayer] = [:]
    private var currentMusic: String?
    
    // Volume settings
    private(set) var musicVolume: Float = 0.5
    private(set) var effectsVolume: Float = 0.7
    
    // MARK: - Audio Session Setup
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    // MARK: - Background Music
    func playBackgroundMusic(_ name: String, loop: Bool = true) {
        guard currentMusic != name else { return }
        currentMusic = name
        
        // Stop current music
        backgroundMusicPlayer?.stop()
        
        // Load and play new music
        if let url = Bundle.main.url(forResource: name, withExtension: "mp3") {
            do {
                backgroundMusicPlayer = try AVAudioPlayer(contentsOf: url)
                backgroundMusicPlayer?.numberOfLoops = loop ? -1 : 0
                backgroundMusicPlayer?.volume = musicVolume
                backgroundMusicPlayer?.play()
            } catch {
                print("Failed to play background music: \(error)")
            }
        }
    }
    
    func stopBackgroundMusic() {
        backgroundMusicPlayer?.stop()
        currentMusic = nil
    }
    
    func pauseBackgroundMusic() {
        backgroundMusicPlayer?.pause()
    }
    
    func resumeBackgroundMusic() {
        backgroundMusicPlayer?.play()
    }
    
    // MARK: - Sound Effects
    func playSoundEffect(_ name: String) {
        // Check if sound is already loaded
        if let player = soundEffects[name] {
            player.currentTime = 0
            player.play()
            return
        }
        
        // Load and play new sound
        if let url = Bundle.main.url(forResource: name, withExtension: "wav") {
            do {
                let player = try AVAudioPlayer(contentsOf: url)
                player.volume = effectsVolume
                soundEffects[name] = player
                player.play()
            } catch {
                print("Failed to play sound effect: \(error)")
            }
        }
    }
    
    // MARK: - Volume Control
    func setMusicVolume(_ volume: Float) {
        musicVolume = max(0, min(1, volume))
        backgroundMusicPlayer?.volume = musicVolume
    }
    
    func setEffectsVolume(_ volume: Float) {
        effectsVolume = max(0, min(1, volume))
        for player in soundEffects.values {
            player.volume = effectsVolume
        }
    }
    
    // MARK: - Game Events
    func playGameStart() {
        playBackgroundMusic("bgm_main")
        playSoundEffect("sfx_game_start")
    }
    
    func playGameOver() {
        playBackgroundMusic("bgm_game_over", loop: false)
        playSoundEffect("sfx_game_over")
    }
    
    func playPhaseShift() {
        playBackgroundMusic("bgm_phase_shift")
        playSoundEffect("sfx_phase_shift")
    }
    
    func playEnemyDeath() {
        playSoundEffect("sfx_explosion")
    }
    
    func playPlayerHit() {
        playSoundEffect("sfx_player_hit")
    }
    
    func playPowerUpCollect() {
        playSoundEffect("sfx_powerup")
    }
    
    // MARK: - Cleanup
    func cleanup() {
        stopBackgroundMusic()
        soundEffects.removeAll()
    }
} 