package colors

import rl "vendor:raylib"

Colors :: struct {
  white:        rl.Color,
  black:        rl.Color,
  neonOrange:   rl.Color,
  royalBlue:    rl.Color,
  block_yellow: rl.Color,
  block_green:  rl.Color,
  block_red:    rl.Color,
  block_purple: rl.Color,
}

colors :: Colors {
  white         = {255,255,255,255},
  black         = {0,0,0,0},
  neonOrange    = {255,95,31,255},
  royalBlue     = {65,105,225,255},
  block_yellow  = {255,240,0,255},
  block_green   = {0,255,0,255},
  block_red     = {255,0,0,255},
  block_purple  = {90,34,139,255},
}


colors2 :: enum {
  white,
  black,
  neonOrange,
  royalBlue,
  block_yellow,
  block_green,
  block_red,
  block_purple,
}
