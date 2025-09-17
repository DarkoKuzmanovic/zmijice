# QA Checklist for Navigation Refactor

## Menu Screen
- [ ] Mouse hover over buttons changes selection
- [ ] Mouse click on buttons triggers correct action
- [ ] Keyboard up/down arrows change selection
- [ ] Keyboard enter/space triggers correct action
- [ ] Keyboard escape/q quits the game

## Pause Screen
- [ ] Mouse hover over buttons changes selection
- [ ] Mouse click on buttons triggers correct action
- [ ] Keyboard up/down arrows change selection
- [ ] Keyboard enter/space triggers correct action
- [ ] Keyboard escape/p unpauses the game

## Game Over Screen
- [ ] Mouse hover over buttons changes selection
- [ ] Mouse click on buttons triggers correct action
- [ ] Keyboard left/right arrows change selection
- [ ] Keyboard enter/space triggers correct action
- [ ] Keyboard escape/q returns to menu

## Options Screen
- [ ] Mouse hover over SFX slider changes selection
- [ ] Mouse click on SFX slider adjusts volume
- [ ] Mouse hover over CRT toggle changes selection
- [ ] Mouse click on CRT toggle changes effect
- [ ] Mouse hover over BACK button changes selection
- [ ] Mouse click on BACK button returns to previous screen
- [ ] Keyboard up/down arrows change selection
- [ ] Keyboard left/right arrows adjust SFX volume when SFX slider selected
- [ ] Keyboard left/right arrows change CRT effect when CRT toggle selected
- [ ] Keyboard enter/space on BACK button returns to previous screen
- [ ] Keyboard escape returns to previous screen

## Name Entry Screen
- [ ] Mouse wheel up increments character
- [ ] Mouse wheel down decrements character
- [ ] Keyboard left/right arrows change selected character
- [ ] Keyboard up/down arrows increment/decrement character
- [ ] Keyboard enter/space confirms name

## General Navigation
- [ ] Selection state is properly maintained when switching between screens
- [ ] Selection state is properly reset when returning to a screen
- [ ] Visual feedback for selected items is consistent across screens
- [ ] Visual feedback for hovered items is consistent across screens