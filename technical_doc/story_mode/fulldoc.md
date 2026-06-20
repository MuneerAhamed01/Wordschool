# Detective Wordle — Feature Overview

A daily detective mystery game built with Flutter where players solve crimes through narrative-driven Wordle puzzles.

---

## Implementation phases

Build progress and step-by-step docs live alongside this spec. Update them after each completed step.

- **[README — Progress tracker](./README.md)**
- [Phase 0 — Foundation & data model](./phase-00-foundation.md)
- [Phase 1 — Backend: daily case generation](./phase-01-backend.md)
- [Phase 2 — App: load today's case](./phase-02-load-case.md)
- [Phase 3 — Story flow UI](./phase-03-story-ui.md)
- [Phase 4 — Wordle per clue](./phase-04-wordle-clues.md)
- [Phase 5 — Scoring & outcomes](./phase-05-scoring-outcomes.md)
- [Phase 6 — Leaderboards & progress](./phase-06-leaderboards.md)
- [Phase 7 — Atmosphere (visual & audio)](./phase-07-atmosphere.md)
- [Phase 8 — Sharing](./phase-08-sharing.md)
- [Phase 9 — Monetization](./phase-09-monetization.md)
- [Phase 10 — Analytics & polish](./phase-10-analytics-polish.md)

---

## Overview

Detective Wordle combines **storytelling + deduction + Wordle gameplay**.

Each day, players receive a new mystery case and solve it by uncovering three clues through Wordle-style puzzles.

Solve all clues and close the case.

---

# Features

## 1. Daily Detective Cases

* One new mystery every day
* Generated automatically using AI
* Shared globally to all players
* Daily progression system

---

## 2. Story-Driven Gameplay

* Detective-style narrative progression
* Story reveals after each completed clue
* Immersive reading experience
* Multiple case endings based on performance

---

## 3. Multi-Step Wordle Investigation

Each case contains **3 Wordle puzzles**

### Clue Structure

1. Crime Location
2. Murder Weapon
3. Main Suspect

Rules:

* 5-letter answers
* Maximum 6 attempts
* Sequential clue progression

---

## 4. Dynamic Story Flow

### Game Flow

App Open
↓
Case Introduction
↓
Story Hint
↓
Investigate Prompt
↓
Wordle Puzzle
↓
Story Reaction
↓
Next Clue
↓
Case Resolution

---

## 5. Detective Score System

Players earn points based on efficiency.

| Attempts | Points |
| -------- | ------ |
| 1        | 100    |
| 2        | 80     |
| 3        | 60     |
| 4        | 40     |
| 5        | 20     |
| 6        | 10     |
| Failed   | 0      |

Maximum: **300 points/day**

---

## 6. Case Outcomes

| Result      | Requirement      |
| ----------- | ---------------- |
| Case Closed | All clues solved |
| Cold Case   | 2 clues solved   |
| Unsolved    | 1 clue solved    |
| Dismissed   | No clues solved  |

---

## 7. Atmosphere & Experience

### Visual

* Noir-inspired UI
* Typewriter text effect
* Animated Wordle tiles
* Minimal image-free design

### Audio

* Ambient rain
* Keyboard clicks
* Tile animations
* Victory / failure effects

---

## 8. AI Content Generation

AI automatically creates:

* Story introduction
* Mystery narrative
* Wordle answers
* Hints
* Case reactions
* Final resolution

Content generation pipeline:
Claude API
↓
Firebase Cloud Function
↓
Firestore
↓
Remote Config
↓
Flutter App

---

## 9. Firebase Infrastructure

Services used:

* Firebase Authentication
* Firestore
* Remote Config
* Analytics
* Cloud Functions

Capabilities:

* Daily case delivery
* Leaderboards
* Progress tracking
* Configuration updates

---

## 10. Leaderboards & Progress

* Weekly leaderboard
* Player rank
* Streak tracking
* Total detective points

---

## 11. Sharing System

Players can share:

* Case result
* Score
* Guess history
* Detective outcome

Supported:

* WhatsApp
* Native Share Sheet

---

## 12. Monetization

### Ads

* Banner Ads
* Interstitial Ads
* Rewarded Ads

### In-App Purchases

* Remove Ads
* Hint Packs
* Detective Pro Subscription

---

## 13. Technical Stack

### Frontend

* Flutter

### Backend

* Firebase

### AI

* Claude API

### Packages

* cloud_firestore
* firebase_remote_config
* firebase_analytics
* google_mobile_ads
* just_audio
* share_plus
* flutter_animate

---

## Future Roadmap

* Friend Challenges
* Push Notifications
* Adaptive Difficulty
* Replay Past Cases
* AI Generated Artwork
* Guest Mode

---

**Platform:** iOS & Android
**Architecture:** Flutter + Firebase + AI Powered Content Generation
