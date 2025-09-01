package main

import "colors"
import "telemetry"
import "core:fmt"
import "core:math"
import la "core:math/linalg"
import rl "vendor:raylib"

//--- Globals
SCREEN_SIZE :: 320
PADDLE_WIDTH :: 50 
PADDLE_HEIGHT :: 6
PADDLE_POS_Y :: 260
PADDLE_SPEED :: 200
BALL_SPEED :: 260
BALL_RADIUS :: 4
BALL_START_Y :: 160

paddle_pos_x: f32
ball_pos: rl.Vector2
ball_dir: rl.Vector2
started: bool

telemetryToggle: bool = true

restart :: proc() {
  paddle_pos_x = (SCREEN_SIZE/2) - (PADDLE_WIDTH/2)
  ball_pos = { (SCREEN_SIZE/2), BALL_START_Y }
  started = false
}

main :: proc() {
  //--- Initialization
  rl.SetConfigFlags({.VSYNC_HINT})
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

    dt: f32

    if !started {

      ball_pos = {
        SCREEN_SIZE/2 + f32(math.cos(rl.GetTime()) * SCREEN_SIZE/2.1),
        BALL_START_Y
      }

      if rl.IsKeyPressed(.SPACE) {
        paddle_middle  := rl.Vector2 {paddle_pos_x + PADDLE_WIDTH/2, PADDLE_POS_Y}
        ball_to_paddle := paddle_middle - ball_pos
        ball_dir = la.normalize0(ball_to_paddle)
        started = true
      }
    } else {
      dt = rl.GetFrameTime()
    }

    
    //--- Game logic
    previous_ball_pos := ball_pos
    ball_pos += ball_dir * BALL_SPEED * dt

    switch {
      case rl.IsKeyDown(rl.KeyboardKey(65)): paddle_pos_x -= 10
      case rl.IsKeyDown(rl.KeyboardKey(68)): paddle_pos_x += 10
    }
    paddle_pos_x = clamp(paddle_pos_x,0, SCREEN_SIZE - PADDLE_WIDTH)
    
    paddle_rect := rl.Rectangle {
        paddle_pos_x, PADDLE_POS_Y,
        PADDLE_WIDTH, PADDLE_HEIGHT
    }

    /*if rl.CheckCollisionCircleRec(ball_pos, BALL_RADIUS, paddle_rect) {
      collision_normal: rl.Vector2

      if previous_ball_pos.x < paddle_rect.x {
        collision_normal = {-1,0}
      }

      if previous_ball_pos.x > paddle_rect.x + paddle_rect.width {
        collision_normal = {1, 0}
      }

      if collision_normal != 0 {
        ball_dir = la.normalize(la.reflect(ball_dir, la.normalize(collision_normal)))
      }
    }*/

    if rl.CheckCollisionCircleRec(ball_pos, BALL_RADIUS, paddle_rect) {
      collision_normal: rl.Vector2
      
      if previous_ball_pos.y < paddle_rect.y + paddle_rect.height {
          collision_normal += {0,-1}
          ball_pos.y = paddle_rect.y - BALL_RADIUS
      }
      if previous_ball_pos.y > paddle_rect.y + paddle_rect.height {
          collision_normal += {0,1}
          ball_pos.y = paddle_rect.y + paddle_rect.height + BALL_RADIUS
      }
      if previous_ball_pos.x < paddle_rect.x {
          collision_normal += {-1,0}
      }
      if previous_ball_pos.x > paddle_rect.x + paddle_rect.width {
          collision_normal += {1,0}
      }
      if collision_normal != 0 {
          ball_dir = la.normalize(la.reflect(ball_dir, la.normalize(collision_normal)))
      }
    }



    //--- Drawing
    rl.BeginDrawing()
      rl.ClearBackground(colors.colors.white)

      camera := rl.Camera2D{
        zoom = f32(rl.GetScreenHeight()/SCREEN_SIZE)
      }

      rl.BeginMode2D(camera)

     

      rl.DrawRectangleRec(paddle_rect, colors.colors.neonOrange)
      rl.DrawCircleV(ball_pos, BALL_RADIUS, colors.colors.royalBlue)


      rl.EndMode2D()
    rl.EndDrawing()
  }
  
}
