-- oc程序极速开发库0.6 by Bai_Tian
local component = require("component")
local gpu = component.gpu
local event = require("event")
local timer_id = 0
qk_data = {}

local mt_box = {
    type = "box",
    x = 1,
    y = 1,
    dx = 5,
    dy = 1,
    fc = 0X000000,
    bc = 0XFFFFFF,
    char = " ",
    rf = 1,
    rft = 0
}

function mt_box:draw() -- 绘制函数
    local t=self
    local bk = gpu.getBackground()
    local fk = gpu.getForeground()
    gpu.setBackground(t.bc)
    gpu.setForeground(t.fc)
    if t.pic then
        local i=1
        local j=1
        while t.pic[i] do
            while t.pic[i][j] do
                gpu.setBackground(t.pic[i][j][2])
                gpu.setForeground(t.pic[i][j][3])
                gpu.set(t.x+j-1,t.y+i-1, t.pic[i][j][1])
                j=j+1
            end
            j=1
            i=i+1
        end
    else
        gpu.fill(t.x, t.y, t.dx, t.dy, t.char)
        gpu.set(t.x, t.y, t.text)
    end
    gpu.setBackground(bk)
    gpu.setForeground(fk)
end

function qk_new(t,mt)
    if not mt and not t then
        t={}
        setmetatable(t, {__index = mt_box})
    elseif not mt then
        setmetatable(t, {__index = mt_box})
    else
        setmetatable(t, {__index = mt})
    end
    timer_id = timer_id + 1
    qk_data[timer_id] = t
    return timer_id
end

function qk_del(id)
    qk_data[id]={type = "n"}
end

function qk_edit(id,t)
    if t.x then qk_data[id].x=t.x end
    if t.y then qk_data[id].y=t.y end
    if t.dx then qk_data[id].dx=t.dx end
    if t.dy then qk_data[id].dy=t.dy end
    if t.fc then qk_data[id].fc=t.fc end
    if t.bc then qk_data[id].bc=t.bc end
    if t.char then qk_data[id].char=t.char end
    if t.rf then qk_data[id].rf=t.rf end
    if t.text then qk_data[id].text=t.text end
    if t.pic then qk_data[id].pic=t.pic end
end

function qk_hide(id)
    qk_data[id].rf=0
end

local function event_timer(x)
    for k, v in ipairs(qk_data) do
        if v.type~=nil and v.type ~= "n" and v.rf ~= 0 then
            --if v.type == "box" then
                if v.rft <= 0 then
                    v:draw()
                    v.rft = v.rf
                    return
                elseif x then
                    v:draw()
                    return
                else
                    v.rft = v.rft - 0.1
                    return
                end
            --end
        end
    end
end
event.timer(0.1, event_timer, math.huge)

local function screen(name, addr, x, y, button, player)
    event_timer(1)
    for k, v in ipairs(qk_data) do
        if v.type ~= "n" then
            --if v.type == "box" then
                if x >= v.x and x <= v.x + v.dx - 1 and y >= v.y and y <= v.y + v.dy - 1 then
                    if v.touch and name=="touch" then v:touch(x, y, addr, button, player) return end
                    if v.drag and name=="drag" then v:drag(x, y, addr, button, player) return end
                    if v.drop and name=="drop" then v:drop(x, y, addr, button, player) return end
                    if v.scroll and name=="scroll" then v:scroll(x, y, addr, button, player) return end
                    if v.walk and name=="walk" then v:walk(x, y, addr, button) return end --button→player
                end
            --end
        end
    end
end
event.listen("touch", screen)
event.listen("drag", screen)
event.listen("drop", screen)
event.listen("scroll", screen)
event.listen("walk", screen)

local function modem(_,_,senderAddress,port,distance,msg,...)
    for k, v in ipairs(qk_data) do
        if v.type ~= "n" then
            --if v.type == "box" then
                local modemif=0
                if not(v.modem_sender==senderAddress or v.modem_sender==nil) then modemif=modemif+1 end
                if not(v.modem_port==port or v.modem_port==nil) then modemif=modemif+1 end
                if not(v.modem_distance==distance or v.modem_distance==nil) then modemif=modemif+1 end
                if not(v.modem_msg==msg or v.modem_msg==nil) then modemif=modemif+1 end
                if modemif==0 and v.modem then v:modem(...) end
            --end
        end
    end
end
event.listen("modem_message", modem)
