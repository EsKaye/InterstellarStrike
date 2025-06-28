import SpriteKit

class MainMenuScene: SKScene {
    
    private var playButton: SKLabelNode!
    private var settingsButton: SKLabelNode!
    private var loreCodexButton: SKLabelNode!
    
    override func didMove(to view: SKView) {
        setupUI()
    }
    
    private func setupUI() {
        setupPlayButton()
        setupSettingsButton()
        setupLoreCodexButton()
    }
    
    private func setupPlayButton() {
        playButton = SKLabelNode(fontNamed: "AvenirNext-Bold")
        playButton.text = "Play"
        playButton.fontSize = 24
        playButton.fontColor = .white
        playButton.position = CGPoint(x: frame.midX, y: frame.midY + 100)
        addChild(playButton)
    }
    
    private func setupSettingsButton() {
        settingsButton = SKLabelNode(fontNamed: "AvenirNext-Bold")
        settingsButton.text = "Settings"
        settingsButton.fontSize = 24
        settingsButton.fontColor = .white
        settingsButton.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(settingsButton)
    }
    
    private func setupLoreCodexButton() {
        loreCodexButton = SKLabelNode(fontNamed: "AvenirNext-Bold")
        loreCodexButton.text = "Celestial Archives"
        loreCodexButton.fontSize = 24
        loreCodexButton.fontColor = .white
        loreCodexButton.position = CGPoint(x: frame.midX, y: frame.midY - 100)
        addChild(loreCodexButton)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        if playButton.contains(location) {
            startGame()
        } else if settingsButton.contains(location) {
            showSettings()
        } else if loreCodexButton.contains(location) {
            showLoreCodex()
        }
    }
    
    private func startGame() {
        // Implementation of starting the game
    }
    
    private func showSettings() {
        // Implementation of showing settings
    }
    
    private func showLoreCodex() {
        let codexView = LoreCodexView()
        addChild(codexView)
    }
} 