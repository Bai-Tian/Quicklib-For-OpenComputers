-- oc程序极速开发库0.7 by Bai_Tian
local component = require("component")
local gpu = component.gpu
local event = require("event")
local timer_id = 0

local qk = {data = {}}

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
        if t.text then
            local ti=1
            while t.text[ti] do
                gpu.set(t.text[ti][2]+t.x-1,t.text[ti][3]+t.y-1,t.text[ti][1])
                ti=ti+1
            end
        end
    end
    gpu.setBackground(bk)
    gpu.setForeground(fk)
end

function qk.new(t,mt)
    if not mt and not t then
        t={}
        setmetatable(t, {__index = mt_box})
    elseif not mt then
        setmetatable(t, {__index = mt_box})
    else
        setmetatable(t, {__index = mt})
    end
    timer_id = timer_id + 1
    qk.data[timer_id] = t
    return timer_id
end

function qk.del(id)
    if type(id)=="table" then
        local i=1
        while id[i] do
            qk.data[id[i]]={type = "n"}
            i=i+1
        end
    else
    qk.data[id]={type = "n"}
    end
end

function qk.edit(id,t)
    if t.x then qk.data[id].x=t.x end
    if t.y then qk.data[id].y=t.y end
    if t.dx then qk.data[id].dx=t.dx end
    if t.dy then qk.data[id].dy=t.dy end
    if t.fc then qk.data[id].fc=t.fc end
    if t.bc then qk.data[id].bc=t.bc end
    if t.char then qk.data[id].char=t.char end
    if t.rf then qk.data[id].rf=t.rf end
    if t.text then qk.data[id].text=t.text end
    if t.pic then qk.data[id].pic=t.pic end
end

function qk.hide(id)
    qk.data[id].rf=0
end

local function event_timer(x)
    local i=1
    while qk.data[i] do
        if qk.data[i].type~=nil and qk.data[i].type ~= "n" and qk.data[i].rf ~= 0 then
            --if qk.data[i].type == "box" then
                if qk.data[i].rft <= 0 then
                    qk.data[i]:draw()
                    qk.data[i].rft = qk.data[i].rf
                elseif x then
                    qk.data[i]:draw()
                else
                    qk.data[i].rft = qk.data[i].rft - 0.1
                end
            --end
        end
        i=i+1
    end
end
event.timer(0.1, event_timer, math.huge)

local function screen(name, addr, x, y, button, player)
    event_timer(1)
    for k, v in ipairs(qk.data) do
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
    for k, v in ipairs(qk.data) do
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

return qk