package game

import "core:sys/windows"
import "core:fmt"
import "core:math"
import la "core:math/linalg"
import rl "vendor:raylib"

//--- Globals Constants
SCREEN_SIZE   :: 320
PADDLE_WIDTH  :: 50 
PADDLE_HEIGHT :: 6
PADDLE_POS_Y  :: 260
PADDLE_SPEED  :: 200
BALL_SPEED    :: 260
BALL_RADIUS   :: 4
BALL_START_Y  :: 160
NUM_BLOCKS_X  :: 10 
NUM_BLOCK_Y   :: 8
BLOCK_WIDTH   :: 28
BLOCK_HEIGHT  :: 10


//--- Global Mutables
row_colors := [NUM_BLOCK_Y]BLOCK_COLORS {
  .block_red,
  .block_red,
  .block_green,
  .block_green,
  .block_yellow,
  .block_yellow,
  .block_purple,
  .block_purple,
}


blocks: [NUM_BLOCKS_X][NUM_BLOCK_Y]bool
paddle_pos_x: f32
ball_pos: rl.Vector2
ball_dir: rl.Vector2
started: bool
score: int
game_over: bool

telemetryToggle: bool = true

restart :: proc() {
  paddle_pos_x = (SCREEN_SIZE/2) - (PADDLE_WIDTH/2)
  ball_pos = { (SCREEN_SIZE/2), BALL_START_Y }
  started = false
  score = 0
  game_over = false

  for x in 0..<NUM_BLOCKS_X {
    for y in 0..<NUM_BLOCK_Y {
      blocks[x][y] = true
    }
  }
}

reflect :: proc(dir, normal: rl.Vector2) -> rl.Vector2 {
  new_direction := la.reflect(dir, la.normalize(normal))
  return la.normalize(new_direction)
}

calc_block_rect :: proc(x,y: int) -> rl.Rectangle {
  return {
    f32(20 + x * BLOCK_WIDTH),
    f32(40 + y * BLOCK_HEIGHT),
    BLOCK_WIDTH,
    BLOCK_HEIGHT,
  }
}

block_exists :: proc(x,y: int) -> bool {
  if x < 0 || y < 0 || x >= NUM_BLOCKS_X || y >= NUM_BLOCK_Y {
    return false
  }

  return blocks[x][y]
}

main :: proc() {

  init_game()

  //--- Load textures 
  texture_ball    := rl.LoadTexture("../assets/ball.png")
  texture_paddle  := rl.LoadTexture("../assets/paddle.png")

  //--- Load audio
  sound_block_hit   := rl.LoadSound("../assets/hit_block.wav")
  sound_paddle_hit  := rl.LoadSound("../assets/hit_paddle.wav")
  sound_game_over   := rl.LoadSound("../assets/game_over.wav")


  restart()

  //--- main loop
  for !rl.WindowShouldClose() {
    //--- Telemetry
    if telemetryToggle {
      telemetry()
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
    } else if game_over == true {
        if rl.IsKeyPressed(.SPACE){
          restart()
        }
    }else {
      dt = rl.GetFrameTime()
    }

    
    //--- Game logic
    previous_ball_pos := ball_pos
    ball_pos += ball_dir * BALL_SPEED * dt

    //--- Collisons w/ RIGHT wall
    if ball_pos.x + BALL_RADIUS > SCREEN_SIZE {
      ball_pos.x = SCREEN_SIZE - BALL_RADIUS
      ball_dir = reflect(ball_dir, rl.Vector2 {-1,0})
    }
    //--- Collisions w/ LEFT wall
    if ball_pos.x - BALL_RADIUS < 0 {
      ball_pos.x = BALL_RADIUS
      ball_dir = reflect(ball_dir, {1,0})
    }

    //--- Collisions w/ TOP wall
    if ball_pos.y - BALL_RADIUS < 0 {
      ball_pos.y = BALL_RADIUS
      ball_dir = reflect(ball_dir, {0,1})
    }

    //--- Restart after collision with bottom
    if !game_over && ball_pos.y > SCREEN_SIZE + BALL_RADIUS * 6 {
      game_over = true
    }




    switch {
      case rl.IsKeyDown(rl.KeyboardKey(65)): paddle_pos_x -= 10
      case rl.IsKeyDown(rl.KeyboardKey(68)): paddle_pos_x += 10
    }
    paddle_pos_x = clamp(paddle_pos_x,0, SCREEN_SIZE - PADDLE_WIDTH)
    
    paddle_rect := rl.Rectangle {
        paddle_pos_x, PADDLE_POS_Y,
        PADDLE_WIDTH, PADDLE_HEIGHT
    }

   
    if rl.CheckCollisionCircleRec(ball_pos, BALL_RADIUS, paddle_rect) {
      collision_normal: rl.Vector2
      rl.PlaySound(sound_paddle_hit)
      
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
        ball_dir = reflect(ball_dir, collision_normal)
      }
    }

    block_x_loop: for x in 0..<NUM_BLOCKS_X {
      for y in 0..<NUM_BLOCK_Y {
        if blocks[x][y] == false {
          continue
        }

        block_rect := calc_block_rect(x, y)

        //--- Check for collisions between the ball and blocks
        if rl.CheckCollisionCircleRec(ball_pos, BALL_RADIUS, block_rect) {
          collision_normal: rl.Vector2
          
          //--- collision from top
          if previous_ball_pos.y < block_rect.y {
            collision_normal += {0,-1}          
          }
          //--- collision from bottom
          if previous_ball_pos.y > block_rect.y + block_rect.height {
            collision_normal += {0,1}
          }
          //--- collision from left
          if previous_ball_pos.x < block_rect.x {
            collision_normal += {-1, 0}
          }
          //--- collision from right
          if previous_ball_pos.x > block_rect.x + block_rect.width {
            collision_normal += {1,0}
          }
          //--- reflection of ball after collision_normal value is set
          if collision_normal != 0 {
           ball_dir = reflect(ball_dir, collision_normal) 
          }  

          
          if block_exists(x + int(collision_normal.x), y){
            collision_normal.x = 0
          }
          if block_exists(x, y + int(collision_normal.y)) {
            collision_normal.y = 0
          }


          //--- Destroy block
          blocks[x][y] = false
          rl.PlaySound(sound_block_hit) 
          row_color := row_colors[y]
          score += block_score[row_color]
          break block_x_loop

        }
      }
    }

    //--- Drawing
    rl.BeginDrawing()
      rl.ClearBackground(base_colors.white)

      camera := rl.Camera2D{
        zoom = f32(rl.GetScreenHeight()/SCREEN_SIZE)
      }

      rl.BeginMode2D(camera)

     

      //--- Draw paddle
      rl.DrawTextureV(texture_paddle, {paddle_pos_x, PADDLE_POS_Y}, base_colors.neonOrange)
      //rl.DrawRectangleRec(paddle_rect, colors.base_colors.neonOrange)

      //--- Draw ball
      rl.DrawTextureV(texture_ball, ball_pos - {BALL_RADIUS, BALL_RADIUS}, base_colors.royalBlue)
      //rl.DrawCircleV(ball_pos, BALL_RADIUS, colors.base_colors.royalBlue)
      
      for x in 0..<NUM_BLOCKS_X {
        for y in 0..<NUM_BLOCK_Y {
          if blocks[x][y] == false {
            continue
          }

          block_rect := calc_block_rect(x, y)

          block_rect = rl.Rectangle {
            f32(20 + x * BLOCK_WIDTH),
            f32(40 + y * BLOCK_HEIGHT),
            BLOCK_WIDTH,
            BLOCK_HEIGHT,
          }

          //--- Block borders
          top_left  := rl.Vector2 {block_rect.x, block_rect.y}
          top_right := rl.Vector2 {block_rect.x + block_rect.width, block_rect.y}
          bottom_left := rl.Vector2 { block_rect.x, block_rect.y + block_rect.height}
          bottom_right := rl.Vector2 { block_rect.x + block_rect.width, block_rect.y + block_rect.height}

          rl.DrawLineEx(top_left, top_right, 1.0, base_colors.white)       //--- Top
          rl.DrawLineEx(top_left,bottom_left, 1.0, base_colors.white)      //--- Left 
          rl.DrawLineEx(bottom_left, bottom_right, 1.0, base_colors.white) //--- Bottom 
          rl.DrawLineEx(bottom_right, top_right, 1.0, base_colors.white)   //--- Right
          

          rl.DrawRectangleRec(block_rect,block_colors[row_colors[y]])
        }
      }
      
      score_text := fmt.ctprint(score)
      rl.DrawText(score_text, 290, 310, 20, base_colors.neonOrange)

      
      if !started {
        start_text := fmt.ctprint("Start: SPACE")
        start_text_width := rl.MeasureText(start_text,15)
        rl.DrawText(start_text, SCREEN_SIZE/2 - start_text_width/2, BALL_START_Y - 30, 15, base_colors.royalBlue)
      }

      if game_over {
        rl.PlaySound(sound_game_over)
        game_over_text := fmt.ctprintf("Score: %v | Reset: SPACE", score)
        game_over_text_width := rl.MeasureText(game_over_text,15)
        rl.DrawText(game_over_text, SCREEN_SIZE/2 - game_over_text_width/2, BALL_START_Y - 30, 15, base_colors.royalBlue)

      }

      rl.EndMode2D()
    rl.EndDrawing()

    free_all(context.temp_allocator)
  }
  
}
