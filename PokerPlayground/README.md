# Poker Playground 🃏

A macOS Texas Hold'em Poker app built entirely with **SwiftUI** and **AppKit-compatible code** as a learning project for Xcode.

This is a fun, experimental project that I'm using to:
- Learn how to build desktop/macOS apps using Xcode
- Explore Swift, SwiftUI, MVVM architecture
- Experiment with AI-assisted programming (all code in this repo was AI-generated!)

## Features

- 2-player Texas Hold'em with full 52-card deck
- Shuffling, dealing, community card logic
- Real poker hand evaluation (pair, flush, straight, full house, etc.)
- Live SwiftUI updates and Preview support
- Clean separation of model/view/viewmodel
- Fully documented source code

## How It Works

Each player gets two hole cards. The app deals the flop, turn, and river, then evaluates the best 5-card hand for each player. Ties and hand descriptions (like "Two Pair: Kings and Tens with Ace kicker") are supported.

All UI is built using SwiftUI, and game state is managed via a `GameViewModel`.

## Why I Built This

I wanted a clean, fun way to learn macOS development, and there aren't a ton of great free Texas Hold'em apps on macOS. This app was created as an AI+Xcode experiment — every line of code was generated with the help of an AI assistant (ChatGPT).

## Getting Started

Open the project in Xcode, build it, and hit play!  
No external dependencies or frameworks required.

---

💡 **Note**: This app is not intended for production or the App Store — it’s an educational sandbox project.
