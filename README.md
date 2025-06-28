# Interstellar Strike

A modern space shooter game built with SpriteKit and Swift.

## Features

- 🚀 Fast-paced space combat
- 🛡️ Multiple power-ups (Shield, Rapid Fire, Slow Time)
- ⚡ Phase Shift mode for high-risk, high-reward gameplay
- 🏆 Global leaderboards
- 👤 Player profiles with detailed statistics
- 🎮 Multiple control schemes (Touch, Tilt, Hybrid)
- 🎵 Dynamic sound effects and music
- 🌟 Beautiful visual effects

## Requirements

- iOS 13.0+
- Xcode 12.0+
- Swift 5.0+

## Installation

1. Clone the repository:
```bash
git clone https://github.com/EsKaye/InterstellarStrike.git
```

2. Open `InterstellarStrike.xcodeproj` in Xcode

3. Build and run the project

## Gameplay

### Controls
- Touch: Tap and hold to move the ship
- Tilt: Use device tilt to control ship movement
- Hybrid: Combine touch and tilt for precise control

### Power-ups
- Shield: Temporary invincibility
- Rapid Fire: Increased fire rate
- Slow Time: Slows down enemy movement

### Phase Shift
- Collect Energy Cores to enter Phase Shift mode
- Score multiplier during Phase Shift
- Faster ship movement
- Special visual effects

## Development

### Project Structure
```
InterstellarStrike/
├── Models/         # Game data models
├── Views/          # UI components
├── Scenes/         # Game scenes
├── Managers/       # Game systems
├── Tests/          # Unit tests
└── Resources/      # Assets and resources
```

### Testing
Run the test suite:
```bash
xcodebuild test -scheme InterstellarStrike -destination 'platform=iOS Simulator,name=iPhone 12'
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- SpriteKit for the game engine
- Swift for the programming language
- The open-source community for inspiration and resources 