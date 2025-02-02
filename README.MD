# Zmijice

Zmijice is a retro-styled snake game built using the LÖVE framework.

## Overview

This game features:

- A **Main Menu** with "Play" and "Exit" buttons. The menu is fully navigable via both keyboard and mouse.
- An **In-game** state where you control a snake using the arrow keys or the WASD keys.
- A **Game Over** screen that displays your final score and provides options to start a new game or exit. This screen is also controlled with keyboard (using arrow keys or W/S to navigate and Enter to select) and mouse clicks.

## Features

- **Menu Navigation:**

  - Use the up/down keys (or W/S) to change the selection.
  - Confirm a selection with Enter or a mouse click on the appropriate button.

- **Game Mechanics:**

  - The snake speeds up if an arrow key is held for more than one second.
  - Regular food increases your score by 1.
  - Special food, which appears when the score is a multiple of 10, gives an extra bonus of 3 points and features a blinking effect.

- **Controls:**
  - **Keyboard:**
    - Arrow keys or WASD for movement.
    - Up/Down to navigate menus.
    - Enter to select a menu item.
    - Escape or Q to quit the game.
  - **Mouse:**
    - Click on buttons in the menu and game over screen.

## Running the Game

1. Make sure you have the LÖVE framework installed on your system.
2. Place the project folder in your LÖVE directory or run the game using the command:

   ```
   love path/to/project
   ```

## Code Structure

- **main.lua:** Contains the game loop, drawing routines for both the game and UI (menus, game over screen), and game logic (e.g., snake movement, collision detection, and food spawning).
- **conf.lua:** Configures the game window settings including width, height, title, and vsync.
- **TODO.MD:** Lists features that are planned or have been implemented, such as the interactive menu and game over screen.

Enjoy playing Zmijice!
