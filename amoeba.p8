pico-8 cartridge // http://www.pico-8.com
version 21
__lua__

c_col_inactive = 6
c_col_active = 11

function make_circle(o)
	return {
		x = o.x,
		y = o.y,
		r = o.r,
		col = o.col,
		dx = 0,
		dy = 0,
		ddx = 0.3,
		ddy = 0.3,
		dx_max = 2,
		dx_min = -2,
		dy_max = 2,
		dy_min = -2,
		friction = 0.1,
		update = function(self)
			if (o.update) then
				o.update(self)
			end
			self.dx = max(min(self.dx,self.dx_max),self.dx_min)
			self.dy = max(min(self.dy,self.dy_max),self.dy_min)
			
			self.x += self.dx
			self.y += self.dy
		end,
		draw = function(self)
			circfill(self.x,self.y,self.r,self.col)
		end
	}
end

function cc_collision(c1,c2)
	local distx = c1.x - c2.x
	local disty = c1.y - c2.y
	local distance = sqrt((distx*distx) + (disty*disty))
	return distance <= c1.r+c2.r
end

player = make_circle({
	x = 10,
	y = 10,
	r = 3,
	col = 8,
	update = function(self)
		if (btn(0)) then
			self.dx -= self.ddx
		elseif (btn(1)) then
			self.dx += self.ddx
		else
			if (self.dx > 0) then
				self.dx -= self.friction
			else
				self.dx += self.friction
			end
			if (abs(self.dx) <= self.friction) then
				self.dx = 0
			end
		end
		
		if (btn(3)) then
			self.dy += self.ddy
		elseif (btn(2)) then
			self.dy -= self.ddy
		else
			if (self.dy > 0) then
				self.dy -= self.friction
			else
				self.dy += self.friction
			end
			if (abs(self.dy) <= self.friction) then
				self.dy = 0
			end
		end
	end
})

target = make_circle({
	x = 50,
	y = 50,
	r = 8,
	col = 6
})

objects = {}
add(objects, player)
add(objects, target)

function _update60()
	for o in all(objects) do
		if (o.update) then
			o:update()
		end
	end

	if (cc_collision(player, target)) then
		target.col = c_col_active
	else
		target.col = c_col_inactive
	end
end

function _draw()
	cls(12)
	for o in all(objects) do
		if (o.draw) then
			o:draw()
		end
	end
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
