--Function Forwarders

function setPos(...) return term.setCursorPos(...) end
function setFG(...) return term.setTextColor(...) end
function setBG(...) return term.setBackgroundColor(...) end
function box(...) return paintutils.drawFilledBox(...) end
function write(...) return term.write(...) end

local MAX_X, MAX_Y = term.getSize()
local scroll = 0
local dropdown

local color_list = {
    colors.white,
    colors.orange,
    colors.magenta,
    colors.lightBlue,
    colors.yellow,
    colors.lime,
    colors.pink,
    colors.gray,
    colors.lightGray,
    colors.cyan,
    colors.purple,
    colors.blue,
    colors.brown,
    colors.green,
    colors.red,
    colors.black
}

function init()
    redraw()

    while true do
        sleep(0)
    end
end

function redraw()
    setBG(colors.black)
    term.clear()
    drawBoxes()
    drawBorders()

    if dropdown then
        local x = dropdown.x
        local y = dropdown.y + scroll
        for _,color in pairs(color_list) do
            box(x, y, MAX_X-2, y, color)
            y = y + 1
        end
    end
end

function drawBorders()
    box(1, 1, MAX_X, 1, colors.gray)
    box(1, 1, 1, MAX_Y, colors.gray)
    box(1, MAX_Y, MAX_X, MAX_Y, colors.gray)
    box(MAX_X, 1, MAX_X, MAX_Y, colors.gray)
    setPos(9, 1)
    setFG(colors.white)
    write("Settings")

    setPos(MAX_X, 1)
    setFG(colors.red)
    write("x")
end

function drawBoxes()
    y = 3 + scroll
    box(3, y, MAX_X-2, y + 2, settings.get("border_color") or colors.gray) --Border Color Box
    setPos(7, y + 1)
    setFG(colors.black)
    write("Border Color")
    setPos(MAX_X-2, y + 1)
    write("v")

    y = y + 4

    box(3, y, MAX_X-2, y + 2, settings.get("background_color") or colors.lightGray) --Background Color Box
    setPos(5, y + 1)
    write("Background Color")
    setPos(MAX_X-2, y)
    write("v")

    y = y + 4

    box(3, y, MAX_X-2, y + 2, settings.get("title_color") or colors.white) --Title Color Box
    setPos(8, y + 1)
    write("Title Color")
    setPos(MAX_X-2, y)
    write("v")


    y = y + 8

    box(3, y, MAX_X-2, y+2, colors.red)
    setPos(11, y + 1)
    write("Reset")
end


function click_listener()
    while true do
        local event, click, x, y = os.pullEvent("mouse_click")
        box(1, 1, MAX_X, 1, colors.gray)
        setPos(8, 1)
        setFG(colors.white)
        if x == MAX_X and y == 1 then --X button
            return
        end
        if x > 3 and x < MAX_X-2 then --is one of the buttons x-wise
            scroll_y = y - scroll

            if dropdown then
                temp_y = dropdown.y
                for _,color in pairs(color_list) do
                    if scroll_y == temp_y then
                        settings.set(dropdown.setting, color)
                        settings.save()
                        dropdown = nil
                        redraw()
                        setFG(colors.white)
                        setPos(2, 1)
                        write("Setting Successfully set")
                        sleep(1)
                        redraw()
                    end
                    temp_y = temp_y + 1
                end

                goto skip
            end


            if scroll_y >= 3 and scroll_y < 6 then --Border Color Button
                colorDropdown(3, 3, "border_color")
            elseif scroll_y >= 7 and scroll_y < 10 then --Background Color Button
                setPos(6, 1)
                colorDropdown(3, 7, "background_color")
            elseif scroll_y >= 11 and scroll_y < 14 then --Title Color Button
                colorDropdown(3, 11, "title_color")

            elseif scroll_y >= 19 and scroll_y < 22 then --Reset Button
                settings.unset("border_color")
                settings.unset("background_color")
                settings.unset("title_color")
                settings.save()
                redraw()
            end
        end

        ::skip::
    end
end

function colorDropdown(x, y, setting)
    dropdown = {
        x = x,
        y = y,
        setting = setting
    }

    redraw()
end

function scroll_listener()
    while true do
        local event, dir, x, y = os.pullEvent("mouse_scroll")
        scroll = scroll - dir
        if scroll > 0 then scroll = 0 end
        redraw()
    end
end

parallel.waitForAny(init, click_listener, scroll_listener)
os.reboot()