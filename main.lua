-- main.lua
room = 0
x = 0
y = 0
speed = 2
dir_y = 0
dir_x = 0
reach = 1
function _init()
    if m == nil then
        m = map(0, 0, 0, 0, 0, 0, nil, room):retain()
    end
end
function _update()
    top_left_x = x / 16
    top_left_y = y / 16
    bottom_right_x = (x + 15) / 16
    bottom_right_y = (y + 15) / 16
    d = 1 / 16
    if btn(0) then
        if not is_wall(top_left_x - d, top_left_y,
                              top_left_x - d, bottom_right_y) then
        x = x - speed
        end
        dir_x = -1
        dir_y = 0
    end
    if btn(1) then
        if not is_wall(bottom_right_x + d, bottom_right_y,
                              bottom_right_x + d, top_left_y) then
        x = x + speed
        end
        dir_x = 1
        dir_y = 0
    end
    if btn(2) then
        if not is_wall(top_left_x, top_left_y - d,
                              bottom_right_x, top_left_y - d) then
            y = y - speed
        end
        dir_y = -1
        dir_x = 0
    end
    if btn(3) then
        if not is_wall(bottom_right_x, bottom_right_y + d,
                              top_left_x, bottom_right_y + d) then
        y = y + speed
        end
        dir_y = 1
        dir_x = 0
    end
    if btn(5) then
        local props = mgetp(x / 16 + 0.5 + reach * dir_x, y / 16 + 0.5 + reach * dir_y, room, 1)
        if props then
            world.info("props "..dump(props))
        end
    end
    -- Only grid align if we're moving in a single direction.
    if abs(dir_y) ~ abs(dir_x) == 1 then
        if dir_y ~= 0 then
            x = x + grid_align(x)
            dir_x = 0
        else
            y = y + grid_align(y)
            dir_y = 0
        end
    end
    if is_door(x, y) then
        m:despawn()
        room = 1
        m = map(0, 0, 0, 0, 0, 0, nil, room):retain()
        world.info("we at a door")
    end
end

function d_mget(cx,cy,map_index)
    local r = mget(cx,cy,map_index)
    world.info("mget length " ..#r)
    return r
end

function is_wall(cx, cy, ...)
    local args = {...}
    local r = fgets(mget(cx, cy, room), 0)
    for i = 1, #args, 2 do
        r = r or fgets(mget(args[i], args[i + 1], room), 0)
    end
    return r
end

function fgets(list, index)
    local r = false;
    for sprite in all(list) do
        if sprite ~= nil then
            r = r or fget(sprite, index)
        end
    end
    return r
end

function is_door(x, y)
    -- Check the center of the sprite.
    local sprite = mget((x + 8) / 16, (y + 8) / 16, room)[1]
    if sprite == nil then
        return false
    end
    return fget(sprite, 1)
end

function grid_align(a)
    local dist = a % 8
    if dist == 0 then
        return 0
    elseif dist > 4 then
        return 1
    else
        return -1
    end
end

function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end


function _draw()
    cls(3)
    -- pset(x + 10,x, 2)
    spr(84, x, y)
end
