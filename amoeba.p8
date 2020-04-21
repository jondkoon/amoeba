pico-8 cartridge // http://www.pico-8.com
version 21
__lua__

#include vector.p8
#include iris_shot_lib.p8

function random_one(set)
	return set[1 + flr(rnd(count(set)))]
end

function cc_collision(c1,c2)
	local distance = c1.pos - c2.pos
	return #distance <= c1.r+c2.r
end

function circle_distance(c1, c2, distance)
	local dist = distance and distance or c1.pos - c2.pos
	return #dist - c1.r - c2.r
end

function sign(x)
	return x <= 0 and -1 or 1
end

function random_sign()
	return sign(rnd(1) - 0.5)
end

level = 1

local starting_colors = {
	13,
	6,
	10,
	11,
	9,
	14,
	1,
	2,
	8
}

local colors_new_game = {
	13,
	6,
	10,
	8,
	2,
	1,
	14,
	9,
	11
}

local max_r = 9

local size_to_color = {}
function set_size_to_color(colors)
	for i = 2, max_r do
		size_to_color[i] = colors[flr(i * #colors / max_r)]
	end
end

set_size_to_color(starting_colors)

local circle_id_counter = 0
function make_circle(o)
	circle_id_counter += 1
	return {
		id = circle_id_counter,
		is_player = o.is_player,
		pos = vector{o.list,o.y},
		x = o.x,
		y = o.y,
		r = o.r,
		col = o.col,
		inactive_col = o.col,
		dx = 0,
		dy = 0,
		ddx = 0.15,
		ddy = 0.15,
		v_max = o.v_max,
		dx_max = o.v_max,
		dx_min = -o.v_max,
		dy_max = o.v_max,
		dy_min = -o.v_max,
		friction = 0.05,
		set_pos = function(self, x, y)
			self.x = x
			self.y = y
			self.pos.x = x
			self.pos.y = y
		end,
		update = function(self)
			self.r = max(min(max_r, self.r), 2)
			if (o.update) then
				o.update(self)
			end

			self.dx = max(min(self.dx,self.dx_max),self.dx_min)
			self.dy = max(min(self.dy,self.dy_max),self.dy_min)
			
			local x = self.x + self.dx
			local y = self.y + self.dy
			self:set_pos(x, y)
		end,
		draw = function(self)
			local color = size_to_color[flr(self.r)]
			if (self.r >= max_r) then
				color = size_to_color[max_r]
			end

			circfill(self.x,self.y,self.r,color)
			local half_r = flr(self.r / 2)

			local mouth_height_divisor = self.is_bigger and  2 or 4
			
			-- mouth
			rectfill(self.x - half_r, self.y + 1, self.x + half_r, self.y + max(1, flr(self.r / mouth_height_divisor)), 0)

			-- left whites
			rectfill(self.x - half_r, self.y - half_r, self.x - half_r + flr(self.r / 4), self.y - half_r + flr(self.r / 4), 7)
			-- right whites
			rectfill(self.x + half_r, self.y - half_r,self.x + half_r - flr(self.r / 4), self.y - half_r + flr(self.r / 4), 7)

			-- left blacks
			local pupil_offset = self.dx >= 0 and flr(self.r / 4) or -flr(self.r / 4)
			local start_x = self.x - half_r + pupil_offset
			rectfill(start_x, self.y - half_r, start_x + flr(self.r / 4), self.y - half_r + flr(self.r / 4), 0)

			-- right blacks
			local pupil_offset = self.dx >= 0 and flr(self.r / 4) or -flr(self.r / 4)
			local start_x = self.x + flr(self.r / 3) + pupil_offset
			rectfill(start_x, self.y - half_r,start_x + flr(self.r / 4), self.y - half_r + flr(self.r / 4), 0)
		end
	}
end


function make_player()
	return make_circle({
		is_player = true,
		x = 0,
		y = 0,
		r = 4,
		v_max = 1.2,
		update = function(self)
			if (btn(4)) then
				local speed_up = self.v_max * 1.5
				self.dx_max = speed_up
				self.dx_min = -speed_up
				self.dy_max = speed_up
				self.dy_min = -speed_up
			else
				self.boosting = false
				self.dx_max = self.v_max
				self.dx_min = -self.v_max
				self.dy_max = self.v_max
				self.dy_min = -self.v_max
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
end

player = make_player()

objects = {}

function make_random_circle()
	local distance_from_player = 30
	local circle = make_circle({
		x = 64 - flr(rnd(128)),
		y = 64 - flr(rnd(128)),
		r = 2 + flr(rnd(3)),
		v_max = 0.3 + rnd(.1)
	})

	local resultant = circle.pos - player.pos
	local distance = #resultant - circle.r - player.r

	if (distance < distance_from_player) then
		local new_x = circle.x + sign(resultant.x) * distance_from_player
		local new_y = circle.y + sign(resultant.y) * distance_from_player
		circle:set_pos(new_x, new_y)
	end

	return circle
end

local iris = nil

function start_game()
	objects = {}
	player = make_player()
	iris = make_iris(64, 64)
	add(objects, player)
	for i = 0, 20 do
		local circle = make_random_circle()
		add(objects, circle)
	end	
end

function recycle_circle(circle)
	local x = player.x
	local y = player.y
	local off_vertically = rnd(1) < 0.5
	if (off_vertically) then
		x += -64 + rnd(128)
		y += random_sign() * 70
	else
		y += -64 + rnd(128)
		x += random_sign() * 70
	end

	local r_roll = rnd(10)

	if (r_roll <= 2) then
		circle.r = player.r - flr(rnd(2)) - 4
	elseif (r_roll <= 4) then
		circle.r = player.r - flr(rnd(2)) - 3
	elseif (r_roll <= 6) then
		circle.r = player.r - flr(rnd(2)) - 2
	elseif (r_roll <= 8) then
		circle.r = player.r - flr(rnd(2)) - 1
	elseif (r_roll <= 9.5) then
		circle.r = player.r - flr(rnd(2))
	else
		circle.r = player.r + 1
	end

	if (circle.is_player) then
		circle.r = 4
	end

	circle:set_pos(x,y)
	local resultant = circle.pos - player.pos
	circle.dx = resultant.x + random_sign()
	circle.dy = resultant.y + random_sign()
end

local on_next_level = false

local current_objects = {}
local c_counter = 1
function _update60()
	if (iris) then
		iris:update()
	end

	current_objects = {}

	local max_right = player.x + 80
	local max_left = player.x - 80
	local max_top = player.y - 80
	local max_bottom = player.y + 80

	for o in all(objects) do
		if (o.x < max_right and o.x > max_left and o.y > max_top and o.y < max_bottom) then
			add(current_objects, o)
		else
			recycle_circle(o)
		end
	end

	for o in all(current_objects) do
		if (o.update) then
			o:update()
		end
	end

	for k1, c1 in pairs(current_objects) do
		-- poor mans perf boost
		c_counter += 1
		if (c_counter > 5) then
			c_counter = 1
		end
		if (c1.id % c_counter == 0) then
			local closest = nil
			local closest_resultant = nil
			local closest_distance = 128
			for k2, c2 in pairs(current_objects) do
				if (c1 != c2) then
					local resultant = c1.pos - c2.pos
					local distance = circle_distance(c1, c2, resultant)

					if (distance < 20 and distance <= closest_distance) then
						closest = c2
						closest_distance = distance
						closest_resultant = resultant
					end

					local is_collision = #resultant < c1.r + c2.r
					if (is_collision) then
						local bigger = c1.r >= c2.r and c1 or c2
						local smaller = c1.r >= c2.r and c2 or c1				
						local r_increase = smaller.r / 20
						bigger.r += r_increase
						if (bigger.is_player) then
							if (bigger.r >= max_r) then
								sfx(3)
								level += 1
								if (not on_next_level) then
									on_next_level = true
									set_size_to_color(colors_new_game)
								else
									on_next_level = false
									set_size_to_color(starting_colors)
								end								
								start_game()
							elseif (size_to_color[flr(bigger.r)] != size_to_color[flr(bigger.r - r_increase)]) then
								sfx(1)
							else
								sfx(0)
							end
						elseif (smaller.is_player) then
							sfx(2)
							level = 1
							start_game()
						end
						recycle_circle(smaller)
					end
				end
			end

			if (closest) then 
				if (closest.r <= c1.r) then
					c1.is_bigger = true
					closest.is_smaller = true
					if (not c1.is_player) then
						c1.dx += -1 * sign(closest_resultant.x) * c1.ddx
						c1.dy += -1 * sign(closest_resultant.y) * c1.ddy
					end
				else 
					c1.is_smaller = true
					closest.is_bigger = true
					if (not c1.is_player) then
						c1.dx += sign(closest_resultant.x) * c1.ddx
						c1.dy += sign(closest_resultant.y) * c1.ddy
					end
				end
			else
				c1.is_bigger = false
				c1.is_smaller = false
			end
		end
	end
end

function draw_background()
	local x_start = flr(player.x / 16) - 4
	local y_start = flr(player.y / 16) - 4
	local start_x = player.x - 64
	local start_y = player.y - 64
	for x = x_start, x_start + 8 do
		for y = y_start, y_start + 8 do
			spr(0, x * 16, y * 16, 2, 2)
		end
	end
end

local at_title_screen = true

local start_prompt = {
	y = 116,
	height = 4,
	init = function(self)
		self.text = "press ❎ or 🅾️ to start"
		self.width = (#self.text + 2) * 4
		self.x = (128 - self.width) / 2
		self.timer = 60
	end,
	update = function(self)
		self.timer -= 1
		if (self.timer < -20) then
			self.timer = 60
		end
		if (btn(4) or btn(5)) then
			at_title_screen = false
			start_game()
		end
	end,
	draw = function(self)
		if (self.timer > 0) then
			print(self.text, self.x, self.y, 7)
		end
	end
}
start_prompt:init()

function draw_title_screen()
	start_prompt:update()
	start_prompt:draw()

	rectfill(13, 6, 13 + 27, 6 + 17, 0)
	rectfill(13, 6, 13 + 10, 6 + 17, 7)	

	rectfill(94, 6, 94 + 27, 6 + 17, 0)
	rectfill(94, 6, 94 + 10, 6 + 17, 7)

	palt(15)
	spr(99, 12, 24, 13, 10)
	palt()
end

function _draw()
	if (at_title_screen) then
		cls(8)
		draw_title_screen()
	else 
		cls(12)
		local center_x = player.x - 64
		local center_y = player.y - 64
		camera(center_x, center_y)
		draw_background()
		for o in all(current_objects) do
			if (o.draw) then
				o:draw()
			end
		end
		camera()
		if (iris) then
			iris:draw()
		end
		print("level "..level, 100, 1)
		
	end
end

__gfx__
30033300003000330088888888888888888888800000000000000999999999000000000000000000000000000000000000000000000000000000000000000000
33000330030003300088000088888880000888800aa0aa0aaa00099099909990000eee00eeee00eeee0066666000000000000000000000000000000000000000
03000033330003000080888808888808888088800aaa00aaaa00099909099999000eeeee0ee0eeeeee0070670000000000000000000000000000000000000000
03300000000033000088888880888088888888800700aa700a00070090997009000eeeeee00eeeeeee0066666000000000000000000000000000000000000000
00330000000030000088888888080888888888800700aa700a0007009999700900077000eeee77000e0060006000000000000000000000000000000000000000
00033000000030000088888888808888888888800aaaaaaaaa0009999999999900077000eeee77000e0066666000000000000000000000000000000000000000
30003300000330030088888888888888888888800aaaaaaaaa0009999999999900077000eeee77000e0000000000000000000000000000000000000000000000
33000330000300300077700000888877700000800aa07070aa00099999999999000eeeeeeeeeeeeeee0000000000000000000000000000000000000000000000
03300033003300300077700000888877700000800aaaaaaaaa00097070707999000eeeeeeeeeeeeeee0000000000000000000000000000000000000000000000
0033000033300330007770000088887770000080000000000000090000000999000eeeeeeeeeeeeeee0000000000000000000000000000000000000000000000
0003330000003300007770000088887770000080000000000000090707070999000ee0707070707eee0000000000000000000000000000000000000000000000
0000033300033000008888888888888888888880000000000000099999999990000e000000000000ee0000000000000000000000000000000000000000000000
3000000333330003008888888888888888888880000000000000000000000000000e000000000000ee0000000000000000000000000000000000000000000000
3300000000000333008888888888888888888880000000000000000000000000000e000000000000ee0000000000000000000000000000000000000000000000
0330000000003300008888888888888888888880000000000000000000000000000ee7070707070eee0000000000000000000000000000000000000000000000
0033000000033000008888888888888888888880000000000000000000000000000eeeeeeeeeeeeeee0000000000000000000000000000000000000000000000
00000000000000000088770077007700770888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000080770077007700770088800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000080000000000000000088800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000080000000000000000088800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000080000000000000000088800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000080000000000000000088800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000080007700770077000088800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000088007700770077000888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000088888888888888888888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
000000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
000000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
000000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
000000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
000000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
000000000000000000000000f8888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
000000000000000000000000f8888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
000000000000000000000000f8888888877777000000777777000000777777000000777777000000777777000000777777000000777777000000777788888888
000000000000000000000000f8888888777777000000777777000000777777000000777777000000777777000000777777000000777777000000777777888888
000000000000000000000000f8888880777777000000777777000000777777000000777777000000777777000000777777000000777777000000777777088888
000000000000000000000000f8888800777777000000777777000000777777000000777777000000777777000000777777000000777777000000777777008888
000000000000000000000000f8888000777777000000777777000000777777000000777777000000777777000000777777000000777777000000777777008888
000000000000000000000000f8888000777777000000777777000000777777000000777777000000777777000000777777000000777777000000777777000888
000000000000000000000000f8880000777777000000777777000000777777000000777777000000777777000000777777000000777777000000777777000888
000000000000000000000000f8880000777777000000777777000000777777000000777777000000777777000000777777000000777777000000777777000888
000000000000000000000000f8880000777777000000777777000000777777000000777777000000777777000000777777000000777777000000777777000888
000000000000000000000000f8880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000088
000000000000000000000000f8880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000088
000000000000000000000000f8800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000088
000000000000000000000000f8800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000088
000000000000000000000000f8800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000088
000000000000000000000000f8800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000088
000000000000000000000000f8800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000088
000000000000000000000000f8800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000088
000000000000000000000000f8800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000088
000000000000000000000000f8800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000088
000000000000000000000000f8000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000088
000000000000000000000000f8000000077777000007770000000077700000777777000077700000000007770077700777000000000077700777777777700008
000000000000000000000000f8000007777777700007770000000077700000777777770007770000000007770077700077700000000077700777777777700008
000000000000000000000000f8000007770007770007770000000077700000770007777007770000000007770077700077700000000077700777000000000008
000000000000000000000000f8000077700000700007770000000077700000770000077700777000000077700077700007770000000777000777000000000008
000000000000000000000000f8000077700000000007770000000077700000770000077700777000000777000077700007770000007770000777000000000008
000000000000000000000000f8000077777000000007770000000077700000770000077700077700000777000077700000777000007770000777000000000008
000000000000000000000000f8000007777770000007770000000077700000770000777700077700000777000077700000777000007770000777777777700008
000000000000000000000000f8000000777777700007770000000077700000770007777000007770007770000077700000077700077700000777777777700008
000000000000000000000000f8000000077777770007770000000077700000777777770000007770007770000077700000077700077700000777000000000008
000000000000000000000000f8000000000777770007770000000077700000777777700000007770077700000077700000077700777000000777000000000008
000000000000000000000000f8000000000007777007770000000077700000770777000000000777077700000077700000007770777000000777000000000008
000000000000000000000000f8000000000000777007770000000077700000770077700000000777077700000077700000007770777000000777000000000008
000000000000000000000000f8000007000000777007770000000077700000770077770000000077777000000077700000000777770000000777000000000008
000000000000000000000000f8000077700000770000777000000777000000770000777000000007770000000077700000000077700000000777000000000008
000000000000000000000000f8000077770007770000077700007770000000770000777700000007770000000077700000000077700000000777000000000008
000000000000000000000000f8000007777777700000007777777700000000770000077770000007700000000077700000000077000000000777777777700008
000000000000000000000000f8000000777777000000000777777000000000770000007770000000700000000077700000000007000000000777777777700008
000000000000000000000000f8000000000000000000000000000000000000000000000000000000700000000000000000000007000000000000000000000008
000000000000000000000000f8000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008
000000000000000000000000f8000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008
000000000000000000000000f8000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008
000000000000000000000000f8000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008
000000000000000000000000f8000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008
000000000000000000000000f8000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008
000000000000000000000000f8000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008
000000000000000000000000f8800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000088
000000000000000000000000f8800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000088
000000000000000000000000f8800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000088
000000000000000000000000f8887777000000777777000007777770000007777770000007777770000007777770000007777770000077777700000077777788
000000000000000000000000f8887777000000777777000007777770000007777770000007777770000007777770000007777770000077777700000077777888
000000000000000000000000f8887777000000777777000007777770000007777770000007777770000007777770000007777770000077777700000077777888
000000000000000000000000f8888777000000777777000007777770000007777770000007777770000007777770000007777770000077777700000077777888
000000000000000000000000f8888777000000777777000007777770000007777770000007777770000007777770000007777770000077777700000077778888
000000000000000000000000f8888877000000777777000007777770000007777770000007777770000007777770000007777770000077777700000077778888
000000000000000000000000f8888887000000777777000007777770000007777770000007777770000007777770000007777770000077777700000077778888
000000000000000000000000f8888888000000777777000007777770000007777770000007777770000007777770000007777770000077777700000077788888
000000000000000000000000f8888888800000777777000007777770000007777770000007777770000007777770000007777770000077777700000077888888
000000000000000000000000f8888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
000000000000000000000000f8888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
000000000000000000000000f8888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
000000000000000000000000f8888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
000000000000000000000000f8888800000888888888888888888888888888888888888000888888888888888880000088888888888888888888888888888888
000000000000000000000000f8888808888888888888880088888888888888888888888088008888888888888880888888888888888008888888888888888888
000000000000000000000000f8888808888888888888880088888888888888888888888088008888888888888880888888888888888008888888888888888888
000000000000000000000000f8888800000888000008800008888880000880000088888088008888800888888880000088800000880000880088880000888888
000000000000000000000000f8888808888880008008880088888800880080088888888000088888008088888880888888000800888008808808880088088888
000000000000000000000000f8888808888880088008880088888008888000088888888088800880000008888880888888008800888008000000880088088888
000000000000000000000000f8888808888880088008880088888008888000088888888088800880088888888880888888008800888008008888880088088888
000000000000000000000000f8888808888880008008880088888800880080088888888088000888088008888880888888000800888008808800880088088888
000000000000000000000000f8888800000888000008880088888880000880088888888000088888800088888880000088800000888008880008880088088888
000000000000000000000000f8888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
000000000000000000000000f8888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
__sfx__
0001000000070066700a4700e470114701447016470056700e6701147011470114701f4701147006670124700667014470076701f4701f470154701b4701b4701b4700d670164701c4700e670164701c4701a470
00020000000000f020140301603018040190401a0301b0201b0201c0501a050180401504013040100300e0301002014020160201a0301d040171501a1501c1501d150291502a1502f15030150321503215032150
000400003a0703907038070340703507032070300702f0702d0702c0702a070260701f4701e4701d4701b4701a47018470174701447011470114700e4700d4700b4700a470094700947008470064700547003470
000600000000020120251302b1302f1402b14027130221201b120151501d15023140271402b1402d13026130221201b12013120111301414015150181501c1501d150291502115025150291502e1503215037150
001000001905000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
06 04424344

