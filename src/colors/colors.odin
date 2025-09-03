package colors

import rl "vendor:raylib"

BASE_COLORS :: struct {
  white: rl.Color,
  black: rl.Color,
  neonOrange: rl.Color,
  royalBlue: rl.Color,
}


base_colors :: BASE_COLORS {
  white         = {255,255,255,255},
  black         = {0,0,0,0},
  neonOrange    = {255,95,31,255},
  royalBlue     = {65,105,225,255},
}

BLOCK_COLORS :: enum {
  block_yellow,
  block_green,
  block_red,
  block_purple,
}
block_colors := [BLOCK_COLORS]rl.Color {
  .block_yellow  = {255,240,0,255},
  .block_green   = {0,255,0,255},
  .block_red     = {255,0,0,255},
  .block_purple  = {90,34,139,255},
}

block_score := [BLOCK_COLORS]int {
  .block_yellow = 8,
  .block_green  = 6,
  .block_red    = 4,
  .block_purple = 2,
}

