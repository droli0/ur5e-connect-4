# ur5e-connect-4

## Overview

This project runs a complete Connect 4 game loop for a UR5e robot setup with two player modes:
- **Autonomous mode**: robot chooses moves using a minimax strategy.
- **Manual mode**: operator enters the robot drop column from the MATLAB console.

The game loop continuously:
1. captures the board from the camera,
2. detects piece positions,
3. waits for a board change after the opponent move,
4. executes the chosen move,
5. updates win/tie state and exits with a board-safe end sequence.

The implementation also includes an optional computer-vision stage visualiser for troubleshooting perception tuning.

### Workspace (no `global`)

`main.m` is a **script** (with local functions at the end for prompts only). Every other game file it calls (`init`, `connectRobot`, `getGameboard`, `transform`, `matrix`, `executeTurn`, …) is also a **script**, so they all read and write the **same base workspace**—the same way a single long demo script would, just split across files.

**Note:** `matrix`, `getGameboard`, and `waitForOpponentMove` are intentionally **not** `function` files, because MATLAB functions get a **private workspace** and would not see `robot`, `board`, `SHOW_CV_DEMO`, etc., unless those values were passed in as arguments.

The gripper handle is named **`vacuumGrip`** so it never shadows the **`vacuum`** class constructor (`vacuumGrip = vacuum(host, port)`).

### Robot turn flow (single-pickup pose)
- The robot always returns to the shared vacuum setup:
  - `initPos` = pre-pick hover pose (single shared position above puck pickup point).
  - `grabPos` = lower grab pose (single shared pose to engage suction).
- After pickup it always executes:
  - move above target column (`colTPos(column,:)`)
  - lower into target drop cell (`colPos(column,:)`)
  - release suction
  - return through `colTPos` to `topPos`

The dispenser indexing logic from earlier multi-position pickup flows is removed; only one reusable pickup location is used for every move.

## Files added at the repository root

- `main.m`: interactive entrypoint (mode selection + run loop)
- `init.m` / `connectRobot.m`: hardware/session setup
- `getGameboard.m` / `transform.m` / `matrix.m` / `visualise.m`: board capture and detection pipeline
- `waitForOpponentMove.m`: debounce-based board-change detection
- `executeTurn.m`: turn execution (auto and manual selection paths)
- `runPickupSequence.m`: shared pickup sequence using vacuum gripper (`initPos`/`grabPos` poses from `init.m`)
- `minimax.m` / `checkWinCondition.m`: gameplay intelligence and terminal checks
- `endGame.m`: safe shutdown and final board-state reporting

## How to run

From MATLAB at the project root:

```matlab
main
```

At startup you will be asked (invalid text or out-of-range numbers are rejected; press Enter for each default):
1. Autonomous or manual play (`0` / `1`)
2. Robot starts first or opponent starts first (`0` / `1`)
3. Whether to show CV intermediate stages (`0` / `1`)
4. CV stage delay in seconds (non-negative number)
5. **Robot color on the board** — `1` if the robot’s pieces are **red** in vision (`matrix` label 1), or `2` if the robot’s pieces are **blue** (label 2). Minimax and win detection use this; the opponent is the other color.

Manual column entry accepts only integers **1–7**; letters, decimals, or out-of-range values get a short error and a new prompt.

If robot is selected as starter, the first turn runs immediately.
If opponent is selected, the game waits for a detected board change before the robot turn.

If CV demo is enabled, intermediate frames are shown with the requested delay.  
If disabled, only the final board rendering is shown.

## Robot setup: recording poses before a full run

To tune or replace the joint poses in `init.m` for your cell layout and pickup point:

1. **Connect from MATLAB** — run `connectRobot.m` once (from the Command Window is fine). Variables **`robot`** and **`vacuumGrip`** appear in the **base workspace**; read poses with `robot.actualJointPositions` there.
2. **Jog with the teach pendant** — move the arm to each pose you need (standby, pickup hover, grab, each column approach, each drop, and so on).
3. **Read joint angles in MATLAB** — in the Command Window, after each physical pose:

   ```matlab
   robot.actualJointPositions
   ```

   This returns the six actual joint angles in **radians**, matching the vectors already used in `init.m` (`topPos`, `bottomPos`, `initPos`, `grabPos`, `colTPos`, `colPos`).

4. **Copy into `init.m`** — paste each 1×6 row into the appropriate variable. Use `rad2deg(robot.actualJointPositions)` only if you prefer to think in degrees while noting values; the code expects radians in those arrays.

Repeat for every waypoint you need. You do not need to run `main` for this workflow—only `connectRobot.m` plus teach-pendant moves and recording from the terminal.

## Where to set/adjust variables for another robot

This file is your main setup surface for position and hardware tuning:

1. `main.m`: runtime and mode behavior
   - `CAMERA_DEVICE` (camera source ID)
   - `OPPONENT_POLL_DELAY` (board-polling interval)
   - `MOVE_STEP_DELAY` (robot movement timing between waypoints)
   - `CV_DEMO_DELAY` (only used when CV demo is enabled)

2. `init.m`: all robot joint-space pose constants
   - `topPos`: standby/upper transition
   - `bottomPos`: pre-pick transition
   - `initPos`: shared pre-grab hover pose
   - `grabPos`: shared grab/engage pose
   - `colTPos`: per-column transition poses above the target slot
   - `colPos`: per-column drop poses for each column

3. `connectRobot.m`: connection details
   - `host`: robot controller IP
   - `rtdeport`: RTDE control port
   - `vacuumport`: vacuum gripper port
   - Creates **`vacuumGrip = vacuum(host, vacuumport)`** in the workspace (class name stays `vacuum`).

4. `runPickupSequence.m`: pickup procedure (script name must differ from the `initPos` pose vector)
   - Uses joint poses `initPos` then `grabPos` from `init.m`; keep this sequence for all puck sources.

To retune for another robot:
1. update pose vectors in `init.m` first,
2. verify `CAMERA_DEVICE`,
3. verify robot/gripper ports in `connectRobot.m`,
4. validate the flow in manual mode before enabling autonomous play.
