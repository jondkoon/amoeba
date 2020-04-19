pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- pico8lib vector library
-- by sparr and codekitchen

-- mit license, details in license file

-- a vector is a point or direction in 2d space
-- represented by an x and y coordinate
-- vectors arithmetic represents operations on these points/directions

-- pico8 coordinate system
-- +x is east/right
-- -x is west/left
-- +y is south/down
-- -y is north/up

-- some code from https://github.com/codekitchen/pico-8-circuits

local vector
vector = setmetatable({

 __eq = function(a, b)
  return a.x == b.x and a.y == b.y
 end,

 __unm = function(a)
  return vector{ -a.x, -a.y }
 end,

 __add = function(a, b)
  return vector{ a.x + b.x, a.y + b.y }
 end,

 __sub = function(a, b)
  return vector{ a.x - b.x, a.y - b.y }
 end,

 __mul = function(a, b)
  if (type(b) == "number") return vector{ a.x * b, a.y * b }
  if (type(a) == "number") return b * a
  return a.x * b.x + a.y * b.y -- scalar product
 end,

 crossproduct = function(a, b)
  return a.x * b.y - a.y * b.x
 end,

 __div = function(a, b)
  return vector{ a.x / b, a.y / b }
 end,

-- duplicated as dist() in math.p8
 __len = function(a)
  -- return sqrt(a.x*a.x+a.y*a.y) -- potential overflow
  local x, y = abs(a.x), abs(a.y)
  if (x < 128 and y < 128) return sqrt(x * x + y * y) -- remove[25,54] slight decrease in accuracy
  local d = max(x, y)
  local n = x / d * a.y / d
  return sqrt(n * n + 1) * d
 end,

 __tostring = function(a)
  return "[vector:" .. tostr(a.x) .. "," .. tostr(a.y) .. "]"
 end,

 -- magnitude squared
 magsqr = function(a)
  return a.x * a.x + a.y * a.y
 end,

 angle = function(a)
  return atan2(a.x, -a.y)
 end,

 normalize = function(a)
  return a / #a
 end,

 contained = function(a, p1, p2)
  return a.x >= p1.x and a.x <= p2.x and a.y >= p1.y and a.y <= p2.y
 end,

 dset = function(a, idx)
  dset(idx, a.x)
  dset(idx+1, a.y)
 end,

 dget = function(idx)
  return vector{dget(idx), dget(idx + 1)}
 end,

 rotate_90 = function(a)
  return vector{-a.y, a.x}
 end,

 rotate_180 = function(a)
  return -a
 end,

 rotate_270 = function(a)
  return vector{a.y, -a.x}
 end,

 rotate_degrees = function(a, angle)
  return a:rotate(angle / 360)
 end,

 rotate = function(a, angle) -- todo test
  return vector{a.x * cos(angle) + a.y * sin(angle), a.y * cos(angle) + a.x * -sin(angle)}
 end,

 from_polar = function(p) -- todo test
  return vector{p.r * cos(p.t), -p.r * sin(p.t)}
 end,

 to_polar = function(a) -- todo test
  return {r = #a, t = a:angle()}
 end,

 -- reflection vector between vector a and normal n
 -- todo test
 reflect = function(a, n)
  return a - a * n * n * 2
 end
},{

 __call=function(t, o)
  o = o or {0,0}
  return setmetatable({ x = o[1] or o.x or 0, y = o[2] or o.y or 0}, t)
 end

})
vector.__index = vector
vector.mag = vector.__len

local vector_directions_4 = {vector{1, 0}, vector{0, 1}, vector{-1, 0}, vector{0, -1}}
local vector_directions_8 = {vector{1, 0}, vector{1, 1}, vector{0, 1}, vector{-1, 1}, vector{-1, 0}, vector{-1, -1}, vector{0, -1}, vector{1, -1}}