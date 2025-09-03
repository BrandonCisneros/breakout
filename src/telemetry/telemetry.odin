package telemetry

import "../colors"
import "core:fmt"
import rl "vendor:raylib"

telemetry :: proc () {

  monitor: i32 = rl.GetCurrentMonitor()

  rl.DrawFPS((rl.GetScreenWidth()/100),(rl.GetScreenHeight()/100))
  rl.DrawText("Testing", rl.GetScreenWidth()/100, rl.GetScreenHeight()/30,20,colors.base_colors.royalBlue)
  
  if rl.IsKeyDown(rl.KeyboardKey(65)) || rl.IsKeyDown(rl.KeyboardKey(68)) {
    fmt.printfln(
      "Time: {} | Frame Time: {} | Action: {} | Screen Dimension: {} x {}",
      rl.GetTime(),
      rl.GetFrameTime(),
      rl.GetKeyPressed(),
      rl.GetScreenWidth(),
      rl.GetScreenHeight()
    )
  }

  switch {
  case rl.IsKeyDown(rl.KeyboardKey(65)):
     fmt.printfln(
      "Time: {} | Frame Time: {} | Key Press: A | Screen Dimension: {} x {}",
      rl.GetTime(),
      rl.GetFrameTime(),
      rl.GetScreenWidth(),
      rl.GetScreenHeight()
    )
  case rl.IsKeyDown(rl.KeyboardKey(68)):
    fmt.printfln(
      "Time: {} | Frame Time: {} | Key Press: D | Screen Dimension: {} x {}",
      rl.GetTime(),
      rl.GetFrameTime(),
      rl.GetScreenWidth(),
      rl.GetScreenHeight()
    )

    
  }
}
