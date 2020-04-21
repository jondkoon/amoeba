pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

local screen_width = 128
local screen_height = 128

function get_max_r(x,y)
  local farthest_x = x >= (screen_width / 2) and 0 or screen_width
  local farthest_y = y >= (screen_height / 2) and 0 or screen_height

  return sqrt((farthest_x - x)^2 + (farthest_y - y)^2)
end

function draw_iris(cx, cy, r)
  if (r <= 3) then
    cls(0)
    return
  end
  local theta = 0
  local step = 0.2 -- adjust quality - lower is better
  local y2 = cy + r
  while theta <= 360 do
    local x = cx + r * cos(theta / 360)
    local y = cy + r * sin(theta / 360)
    local x2 = x >= cx and screen_width or 0
		if (x >= 0 and x <= screen_width and y >= 0 and y <= screen_height) then
			rectfill(x, y, x2, y2, 0)
		end
    y2 = y
    theta += step
  end
	if (cy - r > 0) then
  	rectfill(0,0,screen_width, cy - r, 0)
	end
	if (cy + r <= screen_height) then
  	rectfill(0,screen_height,screen_width, cy + r, 0)
	end
end

function make_iris(x,y)
  return {
    x = x,
    y = y,
    r = 3,
    rate = 3,
    dr = 3,
    max_r = get_max_r(x,y),
    active = true,
    update = function(self)
      if (self.active) then
        self.r += self.dr
        if (self.r >= self.max_r) then
          self.active = false
        end
      end    
    end,
    draw = function(self)
      draw_iris(self.x, self.y, self.r)
    end   
  }
end