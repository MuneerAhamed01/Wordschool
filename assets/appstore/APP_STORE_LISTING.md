# WordSchool — App Store Listing & ASO Guide

Everything you need to submit WordSchool to the Apple App Store, with ASO-optimized naming, keywords, and marketing copy.

**Current app version:** 1.1.0 (build 5)  
**Bundle ID:** `com.wordschool.mat`  
**Contact:** [muneerahamed.dev@gmail.com](mailto:muneerahamed.dev@gmail.com)

---

## Quick copy-paste (recommended)

Use these as your primary listing unless you A/B test alternatives below.


| Field                  | Character limit | Recommended value                                                                                                                                         |
| ---------------------- | --------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **App Name**           | 30              | `WordSchool: Daily Word Puzzle`                                                                                                                           |
| **Subtitle**           | 30              | `Guess, Streak & Brain Train`                                                                                                                             |
| **Keywords**           | 100             | `word,puzzle,game,daily,guess,brain,vocabulary,spelling,streak,challenge,5 letter,quiz,logic,free`                                                        |
| **Privacy Policy URL** | —               | `https://sites.google.com/view/wordschool/home`                                                                                                           |
| **Support URL**        | —               | `https://sites.google.com/view/wordschool/home`                                                                                                           |
| **Copyright**          | —               | `2026 Muneerahamed` (individual) — or `2026 Bosc Services` if that is your registered business (matches your Google Sites privacy page)                |
| **Promotional Text**   | 170             | `One new 5-letter puzzle every day. Build your streak, replay past games in the archive, and sharpen your vocabulary — free, no ads, just pure word fun.` |
| **Primary Category**   | —               | Games → Word                                                                                                                                              |
| **Secondary Category** | —               | Games → Puzzle                                                                                                                                            |
| **Age Rating**         | —               | 4+ (no restricted content)                                                                                                                                |
| **Price**              | —               | Free                                                                                                                                                      |


---

## ASO: App name options

Apple allows **30 characters** for the App Store name. Shorter names leave room for a keyword-rich subtitle. Pick one primary name and keep it consistent across App Store, in-app branding, and marketing.

### Tier 1 — Recommended


| App Name                          | Chars | Why it works                                    |
| --------------------------------- | ----- | ----------------------------------------------- |
| **WordSchool: Daily Word Puzzle** | 30    | Brand + top search intent ("daily word puzzle") |
| **WordSchool - Word Puzzle Game** | 30    | Strong category keyword coverage                |
| **WordSchool: Guess & Streak**    | 27    | Highlights unique hooks (guessing + streaks)    |


### Tier 2 — Brand-forward


| App Name                      | Chars | Why it works                                           |
| ----------------------------- | ----- | ------------------------------------------------------ |
| **WordSchool**                | 10    | Clean brand; relies on subtitle/keywords for discovery |
| **WordSchool - Daily Puzzle** | 26    | Simple, readable on home screen                        |
| **WordSchool Word Game**      | 22    | Direct category signal                                 |


### Tier 3 — Discovery-forward (test carefully)


| App Name                           | Chars | Notes                                                       |
| ---------------------------------- | ----- | ----------------------------------------------------------- |
| **Daily Word Puzzle - WordSchool** | 32    | ❌ Over limit — trim to `Daily Word Puzzle: WordSchool` (30) |
| **5-Letter Word Puzzle Game**      | 26    | High search volume; weaker brand recall                     |


> **Note:** `Info.plist` currently shows `Wordshool` (typo). Update `CFBundleDisplayName` to `WordSchool` before submission so the home-screen name matches your listing.

---

## ASO: Subtitle options (30 characters max)

Subtitles appear under your app name in search results. Apple indexes them for search — do not repeat words already in your App Name.


| Subtitle                        | Chars | Best paired with                |
| ------------------------------- | ----- | ------------------------------- |
| **Guess, Streak & Brain Train** | 29    | `WordSchool: Daily Word Puzzle` |
| **One Puzzle Every Day**        | 22    | `WordSchool`                    |
| **5-Letter Daily Word Game**    | 26    | `WordSchool`                    |
| **Free Word Game, No Ads**      | 24    | Brand-forward names             |
| **Vocabulary & Logic Puzzles**  | 28    | Discovery-forward names         |
| **Play, Win & Build Streaks**   | 27    | Streak-focused marketing        |


---

## ASO: Keyword sets (100 characters max)

Rules:

- Comma-separated, **no spaces** after commas (saves characters)
- Do **not** repeat words from App Name or Subtitle (Apple ignores duplicates)
- No competitor trademarks in visible metadata (see legal note below)
- Max **100 characters** including commas

### Set A — Recommended (balanced)

```
word,puzzle,game,daily,guess,brain,vocabulary,spelling,streak,challenge,5 letter,quiz,logic,free
```

**99 characters**

### Set B — Puzzle & brain focus

```
puzzle,brain,trainer,logic,guess,spell,vocab,daily,challenge,grid,keyboard,win,streak,archive,quiz
```

**97 characters**

### Set C — Daily habit / retention focus

```
daily,habit,streak,morning,challenge,guess,spell,brain,puzzle,practice,win,stats,calendar,replay,free
```

**99 characters**

### Set D — Casual gamer focus

```
casual,puzzle,word,game,free,offline,quick,fun,brain,teaser,guess,letter,grid,daily,streak,vocabulary
```

**98 characters**

### Words to avoid in keywords (already in recommended name/subtitle)

`wordschool`, `daily`, `word`, `puzzle`, `guess`, `streak` — if you use the recommended name + subtitle, prioritize the other high-value terms in your keyword field.

### Legal note on competitor terms

Many word games rank for terms like "wordle." Apple may reject obvious trademark use in **name/subtitle**, and competitors may complain. Using related generic terms (`5 letter`, `daily puzzle`, `guess the word`) is safer and still captures intent.

---

## Promotional text (170 characters)

Can be updated anytime without a new app review. Use for seasonal hooks, feature launches, or limited messaging.

### Default

```
One new 5-letter puzzle every day. Build your streak, replay past games in the archive, and sharpen your vocabulary — free, no ads, just pure word fun.
```

**149 characters**

### Alternates

```
New puzzle drops every day at midnight. Can you guess the word in six tries? Track your streak, browse the archive, and play free — no ads ever.
```

**141 characters**

```
Your daily brain workout is here. Guess the 5-letter word, grow your streak, and revisit past puzzles anytime. Simple to learn, hard to put down.
```

**145 characters**

---

## App description (4,000 characters max)

Paste into **Description** in App Store Connect.

```
WordSchool is your daily 5-letter word puzzle — one fresh challenge every day, six guesses to get it right, and a streak worth protecting.

Whether you have two minutes or twenty, WordSchool is built for quick, satisfying brain play. No clutter, no ads, no paywalls — just you, the keyboard, and the word.

HOW TO PLAY
• Guess the hidden 5-letter word in up to 6 tries
• Green means correct letter, correct spot
• Orange means correct letter, wrong spot
• Use each clue to narrow your next guess
• Come back tomorrow for a brand-new puzzle

BUILD YOUR STREAK
Play every day to grow your streak. Miss a day and the counter resets — so make it count. Track games played, wins, and your personal best streak from your dashboard.

REPLAY PAST PUZZLES
Missed yesterday? Want more practice? Open the archive and replay previous daily puzzles on a calendar. Perfect for sharpening your skills without waiting for tomorrow.

TRACK YOUR STATS
See your current streak, total games played, wins, and longest streak at a glance. Watch your improvement over time and challenge yourself to beat your best.

PLAY YOUR WAY
• Sign in with Google to sync progress across devices
• Or jump in instantly with guest play
• Clean dark interface designed for focused play
• Polished animations and satisfying feedback on every guess

WHY WORDSCHOOL?
• Free to play — no ads, no subscriptions
• One puzzle per day keeps it fresh, not overwhelming
• Archive mode for extra practice on your schedule
• Built for word lovers, puzzle fans, and anyone who enjoys a daily brain teaser

COMING SOON
• Leaderboards — compete with players worldwide
• Detective Story Mode — solve cases through word puzzles

Download WordSchool and make word puzzles part of your daily routine. Guess the word. Build your streak. See you tomorrow.
```

**~1,750 characters** — room to add localized paragraphs or feature updates later.

---

## What’s New (version 1.1.0)

Use for the **What's New in This Version** field.

```
Welcome to WordSchool 1.1.0!

• Play today's daily 5-letter word puzzle
• Build and track your winning streak
• Replay past puzzles in the archive calendar
• View your stats: played, won, and best streak
• Sign in with Google or play as a guest
• Updated privacy policy and in-app legal pages

Leaderboards and Detective Story Mode are on the way. Thanks for playing — see you tomorrow!
```

---

## App Store Connect checklist

### 1. App information


| Item               | Status | Value / action                                          |
| ------------------ | ------ | ------------------------------------------------------- |
| App Name           | ☐      | `WordSchool: Daily Word Puzzle`                         |
| Subtitle           | ☐      | `Guess, Streak & Brain Train`                           |
| Bundle ID          | ☐      | `com.wordschool.mat`                                    |
| SKU                | ☐      | e.g. `wordschool-ios-001` (your internal ID, immutable) |
| Primary Language   | ☐      | English (U.S.)                                          |
| Primary Category   | ☐      | Games → **Word**                                        |
| Secondary Category | ☐      | Games → **Puzzle**                                      |
| Content Rights     | ☐      | Confirm you own or have rights to all content           |
| Age Rating         | ☐      | Complete questionnaire → expect **4+**                  |
| Copyright          | ☐      | `2026 Muneerahamed` — or `2026 Bosc Services` if submitting under that entity |


### 2. Pricing & availability


| Item         | Status | Value / action                             |
| ------------ | ------ | ------------------------------------------ |
| Price        | ☐      | Free                                       |
| Availability | ☐      | All territories (or select target markets) |
| Pre-orders   | ☐      | Optional — off for v1 launch               |


### 3. URLs (required)


| Item                   | Status         | Value / action                                                                       |
| ---------------------- | -------------- | ------------------------------------------------------------------------------------ |
| **Privacy Policy URL** | ☐ **Required** | `https://sites.google.com/view/wordschool/home` (already live; linked in app Settings) |
| **Support URL**        | ☐ **Required** | `https://sites.google.com/view/wordschool/home` (contact: muneerahamed.dev@gmail.com)  |
| Marketing URL          | ☐ Optional     | App website or landing page                                                          |


> You must publish privacy policy and support pages on the web before submission. In-app markdown is not enough for App Store Connect.

#### Copyright (App Store Connect → App Information)

Apple expects **year + legal owner name**. Do **not** include the © symbol — Apple displays it automatically.

**Paste one of these** (use the name that matches your Apple Developer account / legal entity):

| Entity | Copyright field value |
| ------ | --------------------- |
| Individual developer | `2026 Muneerahamed` |
| Business (Google Sites privacy lists this) | `2026 Bosc Services` |

Optional — same string in `ios/Runner/Info.plist` for the App Store “About” metadata:

```xml
<key>NSHumanReadableCopyright</key>
<string>2026 Muneerahamed</string>
```

Also check **Content Rights**: confirm you own or have licensed all app content (word lists, art, Firebase/Google sign-in assets, etc.).

### 4. App Privacy (nutrition labels)

Based on current codebase (Firebase Auth, Firestore, Firebase Analytics):


| Data type                            | Collected?    | Linked to user? | Used for tracking? |
| ------------------------------------ | ------------- | --------------- | ------------------ |
| User ID                              | Yes           | Yes             | No                 |
| Email (if Google sign-in)            | Yes           | Yes             | No                 |
| Display name                         | Yes           | Yes             | No                 |
| Gameplay content (guesses, progress) | Yes           | Yes             | No                 |
| Product interaction (analytics)      | Yes           | No              | No                 |
| Crash data                           | If enabled    | No              | No                 |
| Coarse location (country)            | Via Analytics | No              | No                 |


Declare in App Store Connect:

- **Data linked to you:** Identifiers, gameplay, contact info (email)
- **Data not linked to you:** Analytics / usage data
- **Tracking:** No (no ads, no cross-app tracking)
- **Third-party SDKs:** Firebase (Google)

### 5. Screenshots & previews

#### iPhone (required — 6.7" display)

Minimum **3** screenshots, up to **10**. Recommended sizes:


| Device                   | Size (px)   | Required?         |
| ------------------------ | ----------- | ----------------- |
| iPhone 6.7" (15 Pro Max) | 1290 × 2796 | ✅ Primary set     |
| iPhone 6.5" (11 Pro Max) | 1242 × 2688 | Optional (scaled) |
| iPhone 5.5"              | 1242 × 2208 | Optional          |


#### iPad (if `supportsTablet` is enabled)


| Device         | Size (px)   |
| -------------- | ----------- |
| iPad Pro 12.9" | 2048 × 2732 |


#### Suggested screenshot order (storytelling)

1. **Dashboard** — "Your daily word puzzle" + streak/stats
2. **Gameplay** — active grid + keyboard mid-guess
3. **Victory** — win screen with guess count
4. **Archive** — calendar of past puzzles
5. **Auth / welcome** — "Guess the word. Build your streak."

You already have Play Store assets at `assets/playstore/` (1080×1920). Resize/reframe to **1290×2796** for iPhone 6.7", or capture fresh on a simulator.

#### App Preview video (optional)

- 15–30 seconds
- Show: open app → make a guess → win → streak update
- Same resolution as screenshot set for each device class

### 6. App icon

- **1024 × 1024** PNG, no transparency, no rounded corners (Apple applies mask)
- Source: `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

### 7. Build & submission


| Item                          | Status | Action                                                         |
| ----------------------------- | ------ | -------------------------------------------------------------- |
| Apple Developer account       | ☐      | Enrolled ($99/year)                                            |
| Certificates & profiles       | ☐      | Distribution cert + App Store profile for `com.wordschool.mat` |
| App Store Connect app record  | ☐      | Create app linked to bundle ID                                 |
| Archive in Xcode              | ☐      | `flutter build ipa` or Xcode → Product → Archive               |
| Upload build                  | ☐      | Xcode Organizer or Transporter                                 |
| Select build in Connect       | ☐      | Attach build to version 1.1.0                                  |
| Export compliance             | ☐      | Typically "No" for HTTPS-only apps                             |
| Advertising Identifier (IDFA) | ☐      | **No** — app does not use ads                                  |
| Review notes                  | ☐      | See below                                                      |
| Demo account                  | ☐      | Provide test Google account if login required for review       |


#### Suggested review notes

```
WordSchool is a free daily word puzzle game. Reviewers can:
1. Tap "Continue as Guest" on the login screen to play immediately without signing in.
2. Play today's puzzle from the dashboard.
3. Open "Previous Games" to access the archive.

No special hardware or region is required. The app does not use ads or in-app purchases.
```

### 8. Age rating questionnaire (expected answers)


| Question area              | Expected answer |
| -------------------------- | --------------- |
| Cartoon / fantasy violence | None            |
| Realistic violence         | None            |
| Sexual content             | None            |
| Profanity                  | None            |
| Drugs / alcohol / tobacco  | None            |
| Gambling                   | None            |
| Horror                     | None            |
| Mature themes              | None            |
| Unrestricted web access    | No              |
| User-generated content     | No              |


**Expected rating: 4+**

### 9. In-app purchases & subscriptions


| Item              | Value |
| ----------------- | ----- |
| IAP               | None  |
| Subscriptions     | None  |
| Restore purchases | N/A   |


### 10. Sign in with Apple

If you offer **Google Sign-In**, Apple typically requires **Sign in with Apple** as an equivalent option for apps that use third-party login. Plan to add Sign in with Apple before submission, or confirm your auth flow qualifies for an exemption (e.g. guest-only with optional Google linking).


| Item               | Status                                  |
| ------------------ | --------------------------------------- |
| Sign in with Apple | ☐ Verify requirement for your auth flow |


### 11. Localization (optional, recommended later)


| Priority | Locale                  | Notes                     |
| -------- | ----------------------- | ------------------------- |
| P1       | English (U.S.)          | Launch                    |
| P2       | English (U.K.)          | Same copy, minor spelling |
| P3       | Spanish, French, German | Larger word-game markets  |


---

## Marketing positioning

### One-line pitch

**WordSchool — guess the word, build your streak, one puzzle every day.**

### Target audience

- Daily puzzle players (Wordle-style habit)
- Casual gamers who want short sessions
- Vocabulary and brain-training enthusiasts
- Commuters and morning-routine players

### Differentiators (use in social posts & screenshot captions)

1. **Free, no ads** — pure gameplay
2. **Daily streak** — habit-forming retention hook
3. **Archive** — replay past puzzles (many daily games lack this)
4. **Dark, polished UI** — premium feel
5. **Guest or Google** — low friction start

### Screenshot caption ideas (overlay text)


| Screen    | Caption                         |
| --------- | ------------------------------- |
| Dashboard | One puzzle. Every day.          |
| Gameplay  | Six guesses. One word.          |
| Win       | Streak saved. See you tomorrow. |
| Archive   | Missed a day? Replay it.        |
| Stats     | Track wins, streaks & progress  |


---

## Pre-submission code fixes


| Item                     | File                    | Current          | Should be                            |
| ------------------------ | ----------------------- | ---------------- | ------------------------------------ |
| Home screen name         | `ios/Runner/Info.plist` | `Wordshool`      | `WordSchool`                         |
| Portrait-only (optional) | `Info.plist`            | Allows landscape | Consider portrait-only for puzzle UX |


---

## Post-launch ASO tips

1. **Ask for ratings** after a win (not mid-game) — implement a soft prompt at streak milestones.
2. **Update promotional text** monthly with streak challenges or seasonal hooks.
3. **A/B test** subtitle and screenshot #1 in App Store Connect (iOS 15+).
4. **Localize** keywords for top territories once you have download data.
5. **Ship leaderboard & story mode** as a "What's New" moment to bump discovery.

---

## File reference in this repo


| Asset                                   | Path                                             |
| --------------------------------------- | ------------------------------------------------ |
| Privacy policy (source)                 | `assets/legal/privacy.md`                        |
| Terms (source)                          | `assets/legal/terms.md`                          |
| Play Store screenshots (resize for iOS) | `assets/playstore/`                              |
| App icon                                | `ios/Runner/Assets.xcassets/AppIcon.appiconset/` |
| Version                                 | `pubspec.yaml` → `1.1.0+5`                       |


---

*Last updated: June 20, 2026*