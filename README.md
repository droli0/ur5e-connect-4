# ur5e-connect-4

Connect 4 on a physical board: camera → piece detection → UR5e + vacuum gripper. Two play modes: **autonomous** (minimax) or **manual** (column from the MATLAB prompt).

## Start guide

On **new hardware or a new cell**, work through the sections below in order before relying on a full game run.

### Tuning checklist (new cell / robot)

1. **`init.m`** — all joint pose rows, especially **`colAPos`** so the puck clears the gripper after release. Use **Recording joint poses** (below) to capture real angles.
2. **`connectRobot.m`** — controller **`host`**, **`rtdeport`**, **`vacuumport`**.
3. **`main.m`** — **`CAMERA_DEVICE`**, **`OPPONENT_POLL_DELAY`**, **`MOVE_STEP_DELAY`**, optional **`CV_DEMO_DELAY`** (montage pause; **`0`** = none).
4. **`matrix.m`** — top-of-file RGB thresholds (`Rmin_red`, `Gmax_red`, …). Enable CV demo at launch and use **figure 2** to compare masks to lighting; relax if red is missed, tighten if colours swap.
5. **`main.m`** again — confirm **`MINIMAX_DEPTH`** if autonomous play feels too slow or too shallow.
6. Run **manual mode** (`0` at the play-mode prompt) before autonomous.

### Recording joint poses for `init.m`

1. Run **`connectRobot.m`**. **`robot`** and **`vacuumGrip`** appear in the base workspace.
2. Jog with the teach pendant to each waypoint (standby, pickup hover, grab, column transitions, drops, after-drop clears, etc.).
3. After each physical pose, in the Command Window:

   ```matlab
   robot.actualJointPositions
   ```

   Values are **radians**, 1×6, matching the vectors in **`init.m`** (`topPos`, `bottomPos`, `initPos`, `grabPos`, `colTPos`, `colPos`, **`colAPos`**, …). Paste each row into the matching variable.

You do not need **`main`** for this — only **`connectRobot`**, the pendant, and the Command Window.

### Launch (`main`)

```matlab
cd <path-to-this-repo>
main
```

Prompts (invalid input is rejected; Enter uses each default shown in **`main.m`**):

| # | Question | Values |
|---|----------|--------|
| 1 | Play mode | `1` autonomous, `0` manual |
| 2 | Who starts | `1` robot first, `0` opponent first |
| 3 | CV demo | `1` on (figure 2 montage), `0` board only |
| 4 | Robot colour in vision | `1` red (`matrix` label 1), `2` blue (label 2) — minimax and win checks use this |

Manual column entry: integers **1–7** only.

- Robot starts first (`1`) → first robot turn runs immediately.  
- Opponent starts (`0`) → loop waits for a **detected board change** after their move.

Optional pause after each CV montage: set **`CV_DEMO_DELAY`** in **`main.m`** (seconds; **`0`** = no pause).

## Figures

| Figure | Role |
|--------|------|
| **1** | Board circles (`visualise.m`), title **Board** |
| **2** | CV montage when demo is on: raw, warped, red/blue masks, R vs B, soft scores — **one window** (`matrix.m`). Optional `pause` only if `CV_DEMO_DELAY` > 0 in `main.m`. Off → figure 1 only. |

During debounced polling (`CV_QUIET`), figure 2 is not updated.

## Game loop

1. Capture board (`getGameboard` → `transform` → `matrix` → `visualise`)  
2. Wait for opponent move when it is their turn (`waitForOpponentMove`, debounced)  
3. Choose column (minimax or prompt) and `executeTurn`  
4. Win / tie / exit via `endGame`

## Workspace model (no `global`)

`main.m` and the files it chains (`init`, `connectRobot`, `getGameboard`, `transform`, `matrix`, `executeTurn`, …) are **scripts**. They share the **base workspace** (like one long script split across files).

`matrix`, `getGameboard`, and `waitForOpponentMove` stay as scripts so they see `robot`, `board`, `SHOW_CV_DEMO`, etc. without threading arguments through everything.

The gripper variable is **`vacuumGrip`** (`vacuumGrip = vacuum(host, vacuumport)`) so it does not shadow the **`vacuum`** class name.

## Robot motion (single pickup pose)

Shared pickup: **`initPos`** (hover) → **`grabPos`** (engage). After grab: **`colTPos`** (above column) → **`colPos`** (drop) → release → **`colAPos(column,:)`** (clear the slot) → **`topPos`**. One pickup location for every move (no multi-dispenser indexing).

## Key files

| File | Purpose |
|------|---------|
| `main.m` | Entry: prompts, loop, `MINIMAX_DEPTH`, `CAMERA_DEVICE`, `OPPONENT_POLL_DELAY`, `MOVE_STEP_DELAY`, `CV_DEMO_DELAY` |
| `init.m` | Joint pose rows (`topPos`, `bottomPos`, `initPos`, `grabPos`, `colTPos`, `colPos`, `colAPos`, …) |
| `connectRobot.m` | `host`, `rtdeport`, `vacuumport`; builds `robot`, `vacuumGrip` |
| `getGameboard.m` | Orchestrates capture + detect + draw |
| `transform.m` | Webcam, ArUco warp / resize fallback, optional `cvRawImg` for demo |
| `matrix.m` | Colour thresholds, occupancy grid |
| `visualise.m` | Figure 1 board |
| `waitForOpponentMove.m` | Debounced board-change wait |
| `executeTurn.m` | Auto / manual paths |
| `runPickupSequence.m` | Shared pickup using `initPos` / `grabPos` |
| `minimax.m`, `checkWinCondition.m` | Search and terminal state |
| `endGame.m` | Shutdown and final state |
