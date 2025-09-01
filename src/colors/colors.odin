package colors

import rl "vendor:raylib"

Colors :: struct {
  white:      rl.Color,
  black:      rl.Color,
  neonOrange: rl.Color,
  royalBlue:  rl.Color,
}

colors := Colors {
  white       = {255,255,255,255},
  black       = {0,0,0,0},
  neonOrange  = {255,95,31,255},
  royalBlue   = {65,105,225,1},
}
