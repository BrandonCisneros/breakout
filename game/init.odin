package game

import rl "vendor:raylib"

init_game :: proc() {
  
  rl.SetConfigFlags(
    {
        .VSYNC_HINT,
        .WINDOW_RESIZABLE,
        .WINDOW_MAXIMIZED,
        .WINDOW_HIGHDPI,
    })
  initScreenWidth: i32  = 1000
  initScreenHeight: i32 = 1000
  fps: i32 = 500


  rl.InitWindow(initScreenWidth,initScreenHeight,"BREAKOUT!")
  defer rl.CloseWindow()
  rl.InitAudioDevice()
  defer rl.CloseAudioDevice()
  rl.SetTargetFPS(fps)
}