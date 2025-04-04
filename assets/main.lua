-- main.lua
--
-- # Tiny Dungeon Game
--
-- By Ryland and Shane
--
-- # TODO
--
-- # BUGS

-- time
t = 0
-- location of player
x = 64
y = 64
speed = 1
-- facing
fx = 0
fy = 0
-- modal message, press button to resume
modal = false
player_shape = { 2, -14,
                 14, -2 }
player_reach = { -2, -18,
                 18, 2 }
attack_time = -30
-- Take note of which crates were opened.
opened_chests = {}
function _init()
    world.info("init")
    m = map(0, 0, 0, 0, 0, 0, nil, room):retain(0.1)
end

function _update()
    -- BUG: If camera isn't called, the tilemap goes away. I DON'T KNOW WHY. :(
    local qx = x/128
    local qy = y/128
    camera(128 * flr(qx),128 * flr(qy))

    if modal then
        if btnp() then
            modal = false
        end
        return
    end
    -- dx, dy are the direction the player is pointing the character.
    local dx, dy = 0, 0
    if btn(0) then
        dx = -1
        fx = -1
        fy = 0
    end
    if btn(1) then
        dx = 1
        fx = 1
        fy = 0
    end
    if btn(2) then
        dy = -1
        fx = 0
        fy = -1
    end
    if btn(3) then
        dy = 1
        fx = 0
        fy = 1
    end
    -- Check if we're stuck. Are we on top of anything without moving?
    if #raydown(x, y, 1, player_shape) > 0 then
        -- I might be stuck.
        local directions = {
            {-1,  0 }, -- left
            { 1,  0 }, -- right
            { 0, -1 }, -- up
            { 0,  1 }, -- down
        }
        local distances = {}
        local j = 1
        for i = 1, #directions do
            -- Calculate distances for each direction.
            distances[i] = min_dist(raycast(x + 8, y + 8, directions[i][1], directions[i][2], 1))
            -- Find minimum distances and move away from it.
            if distances[j] > distances[i] then
                j = i
            end
        end
        -- nudge ourselves away by one pixel.
        x = x - directions[j][1]
        y = y - directions[j][2]
    end

    local wall_dist, wall_id = min_dist(raycast(x + dx, y + dy, dx, dy, 1, player_shape))
    if wall_dist and wall_dist < speed then
        -- world.info("will bump ".. wall_dist.." "..props(wall_id))
        world.info("will bump "..wall_id.." at dist "..wall_dist)
    else
        x = x + dx * speed
        y = y + dy * speed
    end

    -- Check for doors
    for id in all(raydown(x + 8, y + 8, 2)) do
        world.info("on door "..id)
        local p = props(id)
        if p and p.goto_place then
            local v = place(p.goto_place)
            if v then
                x = flr(v[1])
                y = flr(v[2] - 16)
            end
        else
            world.info("p "..dump(p))
        end
        -- p.k
    end

    -- Interact with something
    if btnp(5) then
        for id in all(raydown(x, y, 4, player_reach)) do
            world.info("check id "..id)
            local p = props(id)
            local e = ent(id) -- e is a Val<Entity>
            print_ent(e) -- my work-around.
            world.info("entity tostring "..tostring(e))
            -- world.info("entity "..e) -- doesn't work, probably bad Lua.
            world.info("entity display_ref "..e:display_ref())
            world.info("entity display_value "..e:display_value())
            -- world.info("entity "..tostr(e._1))
            if not opened_chests[id] and p and p.class == "chest" then
                cx, cy = camera()
                rectfill(cx + 5, cy + 100, cx + 123, cy + 123)
                print("You got "..(p.content or "nothing"), cx + 10, cy + 104, 0)
                sset(id, 91)
                modal = true
                opened_chests[id] = true
                break
            end
        end
    end
    -- Attack!
    if btnp(4) then
        attack_time = t
    end
    -- Only grid align if we're moving in a single direction.
    if xor(dy == 0, dx == 0) then
        if dy ~= 0 then
            x = x + grid_align(x)
        else
            y = y + grid_align(y)
        end
    end
    -- Increment time
    t = t + 1
end

function fold(map, init, f)
    for k, v in pairs(map) do
        init = f(k, v, init)
    end
    return init
end

function ifold(map, init, f)
    for k, v in ipairs(map) do
        init = f(k, v, init)
    end
    return init
end

function min_dist(list)
    if list == nil then
        return nil
    end
    local x = math.huge
    local id = nil
    for i = 2, #list, 2 do
        if x > list[i] then
            x = list[i]
            id = list[i - 1]
        end
    end
    return x, id
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
    if modal then
        return
    end
    -- Clear the screen.
    cls()
    local s = 99 -- sprite index, character
    if fy < 0 then
        s = {1, -- sprite sheet
             1  -- sprite index, back of character
        }
    end
    -- Draw the character.
    spr(s, x, y, 1, 1, fx < 0)
    local attack_frame = t - attack_time
    -- Are we attacking?
    if attack_frame < 8 then
        -- Draw the weapon
        spr(103, x + fx * (attack_frame + 8), y + fy * (attack_frame + 8), 1, 1, false, false, atan2(fx, fy) - 0.25)
    end
end
