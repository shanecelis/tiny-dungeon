world.info("Lua: The main.lua script just got loaded")
function _init()
end

x = 0
y = 0
function _update()
    if btn(0) then
        x = x - 1
    end
    if btn(1) then
        x = x + 1
    end
    if btn(2) then
        y = y - 1
    end
    if btn(3) then
        y = y + 1
    end
end

function _draw()
    -- cls(3)
    if not m then
        m = map(0, 0, 0, 0, 0, 0, nil, 0):retain()
    end
    -- pset(x + 10,x, 2)
    -- spr(176, x, y)
end
