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
- `initPos.m`: shared pickup/release sequence using vacuum gripper (`initPos`/`grabPos`)
- `minimax.m` / `checkWinCondition.m`: gameplay intelligence and terminal checks
- `endGame.m`: safe shutdown and final board-state reporting

## How to run

From MATLAB at the project root:

```matlab
main
```

At startup you will be asked:
1. Autonomous or manual play
2. Whether to show CV intermediate stages
3. Who starts the game (robot or opponent)
4. CV stage delay (seconds, optional)

If robot is selected as starter, the first turn runs immediately.
If opponent is selected, the game waits for a detected board change before the robot turn.

If CV demo is enabled, intermediate frames are shown with the requested delay.  
If disabled, only the final board rendering is shown.

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

4. `initPos.m`: pickup procedure
   - Uses `initPos` then `grabPos`; keep this sequence for all puck sources.

To retune for another robot:
1. update pose vectors in `init.m` first,
2. verify `CAMERA_DEVICE`,
3. verify robot/gripper ports in `connectRobot.m`,
4. validate the flow in manual mode before enabling autonomous play.
