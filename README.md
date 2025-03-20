# Flappy Bird in Lua

A simple Flappy Bird clone made with Lua and the LÖVE2D framework.

## How to Play

1. **Space** - Jump/Flap
2. **R** - Restart (when game over)
3. **Escape** - Quit game

## How to Run (Windows)

### Method 1: Using LÖVE Portable

Since you don't have Lua installed, the easiest way to play is to use a portable version of LÖVE:

1. Download LÖVE from https://love2d.org/ (Get the 32-bit or 64-bit zip version)
2. Extract the zip file to a convenient location
3. Create a zip file of the `src` folder's contents (main.lua and conf.lua)
4. Rename the zip file to `flappybird.love`
5. Drag and drop the `flappybird.love` file onto the `love.exe` executable

### Method 2: Using LÖVE Installer

Alternatively, you can install LÖVE:

1. Download and install LÖVE from https://love2d.org/ (Get the 32-bit or 64-bit installer)
2. Once installed, you can run the game by either:
   - Dragging the `src` folder onto the `love.exe` executable
   - Creating a zip of the `src` folder contents, renaming it to `flappybird.love`, and double-clicking it (if LÖVE is set as the default program for .love files)
   - From command line: `"C:\Program Files\LOVE\love.exe" path\to\src`

## Game Features

- Simple physics-based gameplay
- Procedurally generated pipes
- Score tracking
- Simple graphics

Enjoy the game! 