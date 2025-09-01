package main

import "colors"
import "telemetry"
import "core:fmt"
import "core:time"
import "core:log"
import rl "vendor:raylib"

//--- Globals
SCREEN_SIZE :: 320
PADDLE_WIDTH :: 50 
PADDLE_HEIGHT :: 6
PADDLE_POS_Y :: 260
PADDLE_SPEED :: 200
paddle_pos_x: f32

telemetryToggle: bool = true

restart :: proc() {
  paddle_pos_x = (SCREEN_SIZE/2) - (PADDLE_WIDTH/2)
}

main :: proc() {
  //--- Initialization
  rl.SetConfigFlags({.VSYNC_HINT,.WINDOW_RESIZABLE})
  initScreenWidth: i32  = 1280
  initScreenHeight: i32 = 1280
  fps: i32 = 500


  rl.InitWindow(initScreenWidth,initScreenHeight,"Basic Odin Game")
  defer rl.CloseWindow()
  rl.SetTargetFPS(fps)

  restart()

  //--- main loop
  for !rl.WindowShouldClose() {
    //--- Telemetry
    if telemetryToggle {
      telemetry.telemetry()
    }


    //--- Game logic
    switch {
      case rl.IsKeyDown(rl.KeyboardKey(65)): paddle_pos_x -= 10
      case rl.IsKeyDown(rl.KeyboardKey(68)): paddle_pos_x += 10
    }
    paddle_pos_x = clamp(paddle_pos_x,0, SCREEN_SIZE - PADDLE_WIDTH)
    

    //--- Drawing
    rl.BeginDrawing()
      rl.ClearBackground(colors.colors.white)

      camera := rl.Camera2D{
        zoom = f32(rl.GetScreenHeight()/SCREEN_SIZE)
      }

      rl.BeginMode2D(camera)

      paddle_rect := rl.Rectangle {
        paddle_pos_x, PADDLE_POS_Y,
        PADDLE_WIDTH, PADDLE_HEIGHT
      }

      rl.DrawRectangleRec(paddle_rect, colors.colors.neonOrange)
      rl.EndMode2D()
    rl.EndDrawing()
  }
  
}
