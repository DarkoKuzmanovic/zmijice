# Zmijice

Zmijice is a retro-styled snake game built using the LÖVE framework.

## Overview

This game features:

- A **Main Menu** with "Play" and "Exit" buttons. The menu is fully navigable via both keyboard and mouse.
- An **In-game** state where you control a snake using the arrow keys or the WASD keys.
- A **Game Over** screen that displays your final score and provides options to start a new game or exit. This screen is also controlled with keyboard (using arrow keys or W/S to navigate and Enter to select) and mouse clicks.

## Features

- **Menu Navigation:**
  - Use the up/down keys (or W/S) to change the selection
  - Confirm a selection with Enter or a mouse click on the appropriate button

- **Game Mechanics:**
  - The snake speeds up if an arrow key is held for more than one second
  - Regular food increases your score by 1
  - Special food, which appears when the score is a multiple of 10, gives an extra bonus of 3 points and features a blinking effect
  - Snake grows longer with each food item collected
  - Game ends if snake collides with walls or itself

- **Controls:**
  - **Keyboard:**
    - Arrow keys or WASD for movement
    - Up/Down to navigate menus
    - Enter to select a menu item
    - Escape or Q to quit the game
  - **Mouse:**
    - Click on buttons in the menu and game over screen

## Installation

### Prerequisites

- LÖVE framework 11.4 or higher
- Any operating system that supports LÖVE (Windows, macOS, Linux)

### Installation Steps

1. Download the latest release from the releases page
2. Install LÖVE framework from [here](https://love2d.org)
3. Run the game using one of these methods:

``` bash
love path/to/project
```

Or double-click the .love file if LÖVE is properly installed

## Development

### Project Structure

zmijice/
├── main.lua # Main game loop and core logic
├── conf.lua # LÖVE configuration
├── assets/ # Game assets (images, sounds)
└── src/ # Source code modules

### Building from Source

1. Clone the repository
2. Make sure LÖVE is installed
3. Run the project using LÖVE

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- LÖVE framework community
- Original Snake game concept

Enjoy playing Zmijice!
