# PrepPilot 🚀

Your placement co-pilot — an AI-assisted study-progress tracker for B.Tech students preparing for placements. Modern, motion-rich UI; fully **local-first** (works offline, no account, no server cost).

This is the first app in a planned series of study-trackers (placement / govt-exam / school), all sharing this design system and architecture.

## Highlights

- **Preparation tracking** — DSA (Blind-75 / Striver style), CS core (OS/DBMS/CN/OOP), aptitude, system design, HR. Non-binary progress states including *Revisit*, which powers spaced repetition.
- **Personalized roadmap** — rule-based, phase-by-phase plan generated from your target role, timeline and daily hours. Zero API cost.
- **Smart daily plan** — an auto-generated to-do for today (new problems + spaced-repetition reviews + theory), sized to your goal.
- **Visual analytics** — GitHub-style consistency heatmap, strengths radar, difficulty donut, weekly bars, and an explainable *readiness score*.
- **Engagement** — streaks, XP/levels, daily goals, and a Pomodoro focus timer that auto-logs sessions.

## Tech stack (all free / open-source)

| Concern | Choice |
|---|---|
| UI | Flutter (Material 3), custom design system |
| State | Riverpod |
| Local DB | Drift (SQLite) |
| Charts | fl_chart |
| Motion | flutter_animate + custom tokens |
| Type | google_fonts (Plus Jakarta Sans) |
| Misc | url_launcher, flutter_local_notifications, shared_preferences |

## Project structure

```
lib/
  core/           design system + shared widgets/utils
    theme/        palette, theme, dimensions & motion tokens
    widgets/      cards, progress ring, stat tiles, pills, entrance anim
    constants/    enums (categories, statuses, difficulty, roles)
    utils/        day-key, readiness score
  data/
    database/     Drift schema + generated code
    models/       DTOs (joined rows, summaries, stats)
    repositories/ profile, prep (progress/streak/sessions), roadmap, seeding
    seed/         built-in study content
  providers/      Riverpod providers wiring data → UI
  features/
    onboarding/   multi-step goal setup → roadmap generation
    shell/        splash + animated bottom-nav shell
    dashboard/    today's focus, streak, plan, category progress
    tracker/      sheets → topics → problems, status toggling
    roadmap/      phased timeline + weekly tasks
    analytics/    heatmap, radar, bars, donut, readiness
    profile/      profile, settings, theme, goals
    focus/        Pomodoro timer
```

## Running it

Flutter 3.44+ and the Android SDK are required.

```bash
cd D:\preppilot
flutter pub get
dart run build_runner build   # generates Drift code (only after schema changes)
flutter run                   # on a connected device / emulator
```

Regenerate DB code after editing `lib/data/database/tables.dart`:

```bash
dart run build_runner build
```

## Monetization plan

Free (ad-supported, limited AI/day) → Premium (ad-free, unlimited AI, advanced analytics). AI features are the natural paywall; v1 keeps everything rule-based so there is no running cost.

## Roadmap

- [ ] Local reminder notifications
- [ ] Achievements/badges
- [ ] App icon + branded splash
- [ ] Release signing + Play Store assets
- [ ] (Later) Ads, premium tier, LLM-powered doubt-solver & mock interviews, cloud sync
