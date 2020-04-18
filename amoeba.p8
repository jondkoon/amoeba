pico-8 cartridge // http://www.pico-8.com
version 21
__lua__

x = 10
y = 10
r = 2
f = 1

ddx = 0.5
ddy = 0.5
dx_max = 3
dx_min = -3
dy_max = 3
dy_min = -3
friction = 0.2

dx = 0
dy = 0

function _update60()
	if (btn(0)) then
		dx -= ddx
	elseif (btn(1)) then
		dx += ddx
	else
		if (dx > 0) then
			dx -= friction
		else
			dx += friction
		end
		if (abs(dx) <= friction) then
			dx = 0
		end
	end
	
	if (btn(3)) then
		dy += ddy
	elseif (btn(2)) then
		dy -= ddy
	else
		if (dy > 0) then
			dy -= friction
		else
			dy += friction
		end
		if (abs(dy) <= friction) then
			dy = 0
		end
	end
	
	dx = max(min(dx,dx_max),dx_min)
	dy = max(min(dy,dy_max),dy_min)
	
	x += dx
	y += dy
end

function _draw()

	cls(12)
	circfill(x,y,r,8)

end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
