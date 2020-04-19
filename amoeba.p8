pico-8 cartridge // http://www.pico-8.com
version 21
__lua__

function random_one(set)
	return set[1 + flr(rnd(count(set)))]
end

c_col_inactive = 6
c_col_active = 11

function make_circle(o)
	return {
		x = o.x,
		y = o.y,
		r = o.r,
		col = o.col,
		inactive_col = o.col,
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

function dist(x1, y1, x2, y2)
 local x, y = abs(x2 - x1), abs(y2 - y1)
 if (x < 128 and y < 128) return sqrt(x * x + y * y)
 local d = max(x, y)
 local n = x / d * y / d
 return sqrt(n * n + 1) * d
end

function cc_collision(c1,c2)
	local distance = dist(c1.x, c1.y, c2.x, c2.y)
	return distance <= c1.r+c2.r
end

player = make_circle({
	x = 10,
	y = 10,
	r = 3,
	col = 8,
	update = function(self)

		if (btn(4)) then
			self.ddx = 0.3
			self.ddy = 0.3
			self.dx_max = 4
			self.dx_min = -4
			self.dy_max = 4
			self.dy_min = -4
		else
			self.boosting = false
			self.ddx = 0.3
			self.ddy = 0.3
			self.dx_max = 2
			self.dx_min = -2
			self.dy_max = 2
			self.dy_min = -2
		end

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

objects = {}
circles = {}
add(objects, player)

function make_random_circle()
	local colors = { 0, 2, 3, 4, 9, 10, 11, 14 }
	return make_circle({
		x = 128 - flr(rnd(256)),
		y = 128 - flr(rnd(256)),
		r = 3 + flr(rnd(7)),
		col =  random_one(colors)
	})
end

for i = 0, 40 do
	local circle = make_random_circle()
	add(objects, circle)
	add(circles, circle)
end

function _update60()
	for o in all(objects) do
		if (o.update) then
			o:update()
		end
	end

	for circle in all(circles) do
		if (cc_collision(player, circle)) then
			player.r += circle.r / 8
			del(circles, circle)
			del(objects, circle)
		end
	end
end

function _draw()
	cls(12)
	local center_x = player.x - 64
	local center_y = player.y - 64
	camera(center_x, center_y)
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
