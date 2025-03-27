-- main.lua
--
-- # BUGS
-- - object sizes are only a tile wide
room = 0
x = 64
y = 64
speed = 1
dir_y = 0
dir_x = 0
reach = 1
player_size = 15
player_adjust = (16 - player_size) / 16
modal = false

-- function on_script_loaded()
--     if _init then
--         _init()
--     end
-- end

-- position to map cell
function pos_to_cell(x, y)
    return x / 16, y / 16
end

function goto_room(room_num)
    if m ~= nil then
        m:despawn()
    end
    room = room_num
    m = map(0, 0, 0, 0, 0, 0, nil, room):retain(0.1)
    local props = mgetp("player_start", room, 1)
    if props and props.x and props.y then
        x = flr(props.x)
        y = flr(props.y) - 16
        -- y = flr(props.y)
    end
    world.info("changed room to "..room)
end

function _init()
    world.info("init")
    goto_room(room)
end

function _update()
    if modal then
        if btnp() then
            modal = false
        end
        return
    end
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
    local ids = ray(x,y)
    if #ids > 0 and btnp(4) then
        world.info("ray "..dump(ids).." "..dump(props(ids[1])))
    end

    local cx, cy = pos_to_cell(x + 8 , y + 8 )
    -- interact with something?
    -- if btnp(5) then
    --     local cx = cx + 0.5 + reach * dir_x
    --     local cy = cy + 0.5 + reach * dir_y
    --     local props = mgetp({cx, cy}, room, 1)
    --     if props then
    --         -- world.info("props " .. dump(props))
    --         if props.class == "chest" then
    --             -- if not props.is_open then
    --             -- We only do something if it's not open.
    --             world.info("cx "..cx.." cy "..cy)
    --             mset(cx, cy, 91, room, 1)
    --             -- end
    --             rectfill(5, 64, 123, 123)

    --             print("You got "..(props.content or "nothing"), 10, 68, 0)
    --             modal = true
    --         end
    --     end
    -- end
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
    local props = mgetp({cx, cy}, room, 1)
    if props and props.goto_level then
        goto_room(props.goto_level)
        world.info("we at a door")
    end
end

function d_mget(cx, cy, map_index)
    local r = mget(cx, cy, map_index)
    world.info("mget length " .. #r)
    return r
end

function is_block(r)
    return false
    -- if r and r.p8flags then
    --     return r.p8flags == 1
    -- elseif r and r.block then
    --     return r.block == 1
    -- else
    --     return false
    -- end
end

function is_wall(cx, cy, ...)
    -- return false
    local args = { ... }
    if is_block(mgetp({cx, cy}, room, 0)) or is_block(mgetp({cx, cy}, room, 1)) then
        return true
    end
    for i = 1, #args, 2 do
        if is_block(mgetp({args[i], args[i + 1]}, room, 0)) or is_block(mgetp({args[i], args[i + 1]}, room, 1)) then
            return true
        end
    end
    return false
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
    if not modal then
        cls()
    end
    -- pset(x + 10,x, 2)
    -- spr(84, x, y)
    local s = 99 -- sprite index
    if dir_y < 0 then
        s = {1, -- sprite sheet
             1  -- sprite index
        }
    end

    spr(s, x, y, 1, 1, dir_x < 0)

end
