-- main.lua
--
-- # BUGS
-- - object sizes are only a tile wide
room = 0
x = 64
y = 64
speed = 1
dy = 0
dx = 0
reach = 1
modal = false
t = 0
player_shape = { 2, -14,
                 14, -2 }
player_reach = { -2, -18,
                 18, 2 }
attack_time = -30
-- function on_script_loaded()
--     if _init then
--         _init()
--     end
-- end
opened_chests = {}
function _init()
    world.info("init")
    m = map(0, 0, 0, 0, 0, 0, nil, room):retain(0.1)
end

function _update()
    -- BUG: If camera isn't called, the tilemap goes away. I DON'T GET IT.
    local qx = x/128
    local qy = y/128
    camera(128 * flr(qx),128 * flr(qy))

    if modal then
        if btnp() then
            modal = false
        end
        return
    end
    dx, dy = 0, 0
    if btn(0) then
        dx = -1
    end
    if btn(1) then
        dx = 1
    end
    if btn(2) then
        dy = -1
    end
    if btn(3) then
        dy = 1
    end
    local wall_dist, wall_id = min_dist(raycast(x + dx, y + dy, dx, dy, 1, player_shape))
    if wall_dist and wall_dist < speed then
        -- world.info("will bump ".. wall_dist.." "..props(wall_id))
        world.info("will bump "..wall_id.." at dist "..wall_dist)
    else
        x = x + dx * speed
        y = y + dy * speed
    end

    local ids = raydown(x + 8, y + 8)
    if #ids > 0 and btnp(4) then
    -- if #ids > 0 then
        world.info("ray "..dump(ids).." "..dump(props(ids[1])))
    end

    -- check for doors
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

    -- local cx, cy = pos_to_cell(x + 8 , y + 8 )
    -- interact with something?
    if btnp(5) then
        for id in all(raydown(x, y, 4, player_reach)) do
            world.info("check id "..id)
            local p = props(id)
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
    if btnp(4) then
        attack_time = t
    end
    --     local cx = cx + 0.5 + reach * dx
    --     local cy = cy + 0.5 + reach * dy
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
    if xor(dy == 0, dx == 0) then
        if dy ~= 0 then
            x = x + grid_align(x)
        else
            y = y + grid_align(y)
        end
    end
    t = t + 1
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
    cls()
    -- pset(x + 10,x, 2)
    -- spr(84, x, y)
    local s = 99 -- sprite index
    if dy < 0 then
        s = {1, -- sprite sheet
             1  -- sprite index
        }
    end
    spr(s, x, y, 1, 1, dx < 0)
    local attack_frame = t - attack_time
    if attack_frame < 8 then
        spr(103, x + dx * attack_frame, y + dy * attack_frame)
    end


end
