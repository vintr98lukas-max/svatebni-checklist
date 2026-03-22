# Life XP

Minimal React + Node.js app for healthy lifestyle gamification.

## Stack

- React + Vite frontend
- Vercel serverless API for daily feedback generation
- Local browser storage for saved daily entries

## Run

1. Install Node.js 18+.
2. Run `npm install` in the project root.
3. Run `npm run install:all`.
4. Run `npm run dev`.

Frontend: `http://localhost:5173`

## Notes

- Workout XP assumption: `rehab` and `light` both award `20 XP`, since the brief listed four workout types but only three XP values.
- Running supports either minutes or kilometers. Kilometer thresholds are mapped as `2 / 4 / 6+ km` for `20 / 40 / 60 XP`.
- Streak and total XP are computed from saved daily history in local storage.
- On Vercel, set the project Root Directory to the repository root, not `server` or `client`.
