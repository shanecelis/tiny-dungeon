-- main.lua
--
-- # BUGS
-- - object sizes are only a tile wide
room = 0
x = 64
y = 64
speed = 2
dir_y = 0
dir_x = 0
reach = 1
player_size = 15
player_adjust = (16 - player_size) / 16
map_offset = { x = 0, y = 0 }

-- function on_script_loaded()
--     if _init then
--         _init()
--     end
-- end

-- position to map cell
function pos_to_cell(x, y)
    return (x + map_offset.x) / 16, (y + map_offset.y) / 16
end

function goto_room(room_num)
    if m ~= nil then
        m:despawn()
    end
    room = room_num
    if room == 0 then
        map_offset = { x = 16, y = 16 }
    else
        map_offset = { x = 0, y = 0 }
    end
    m = map(0, 0, -map_offset.x, -map_offset.y, 0, 0, nil, room):retain(0.1)
    world.warn("made map")
end

function _init()
    world.info("init")
    goto_room(room)
end

function _update()
    top_left_x, top_left_y = pos_to_cell(x, y)
    top_left_x = top_left_x + player_adjust
    top_left_y = top_left_y + player_adjust
    bottom_right_x, bottom_right_y = pos_to_cell(x + 15, y + 15)
    bottom_right_x = bottom_right_x - player_adjust
    bottom_right_y = bottom_right_y - player_adjust
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
    local cx, cy = pos_to_cell(x, y)
    -- interact with something?
    if btn(5) then
        local cx = cx + 0.5 + reach * dir_x
        local cy = cy + 0.5 + reach * dir_y
        local props = mgetp(cx, cy, room, 1)
        if props then
            world.info("props " .. dump(props))
            if props.class == "chest" then
                -- if not props.is_open then
                -- We only do something if it's not open.
                mset(cx, cy, 91, room, 1)
                -- end
            end
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

    -- check for exit tile
    local props = mgetp(cx, cy, room, 1)
    if props and props.goto_level then
        goto_room(props.goto_level)
        -- world.info("we at a door")
    end
    -- if is_door(x, y) then
    --     m:despawn()
    --     room = 1
    --     m = map(0, 0, 0, 0, 0, 0, nil, room):retain(0.1)
    --     map_offset = { x = 0, y = 0 }
    --     world.info("we at a door")
    -- end
end

function d_mget(cx, cy, map_index)
    local r = mget(cx, cy, map_index)
    world.info("mget length " .. #r)
    return r
end

function is_wall(cx, cy, ...)
    return false
    -- local args = { ... }
    -- local r = fget(mget(cx, cy, room, 0), 0) or fget(mget(cx, cy, room, 1), 0)
    -- for i = 1, #args, 2 do
    --     r = r or fget(mget(args[i], args[i + 1], room, 0), 0) or fget(mget(args[i], args[i + 1], room, 1), 0)
    -- end
    -- return r
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
    local cx, cy = pos_to_cell(x + 8, y + 8)
    local sprite = mget(cx, cy, room, 0) or mget(cx, cy, room, 1)
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
        for k, v in pairs(o) do
            if type(k) ~= 'number' then k = '\'' .. k .. '\'' end
            s = s .. '[' .. k .. '] = ' .. dump(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
end

function _draw()
    cls()
    -- pset(x + 10,x, 2)
    -- spr(84, x, y)
    spr(99, x, y)
end
