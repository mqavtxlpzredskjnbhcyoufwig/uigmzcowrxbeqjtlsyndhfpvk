local imgui = require "mimgui"
local new = imgui.new
local widgets = require("widgets")
local ffi = require("ffi")
local gta = ffi.load('GTASA')
ffi.cdef([[ void _Z12AND_OpenLinkPKc(const char* link); ]])

function getDPIScale()
    local w, h = getScreenResolution()
    local base_w = 1920
    return w / base_w
end

local ui_scale = imgui.new.float(1.0)
local DPI = 1.0
local BotaoMob = imgui.ImVec2(380 * DPI, 80 * DPI)

imgui.OnInitialize(function()
    DPI = getDPIScale() * ui_scale[0]
end)

local GUI = {
    AbrirMenu = imgui.new.bool(true),
}

imgui.OnFrame(function() return GUI.AbrirMenu[0] end, function()
    DPI = getDPIScale() * 1.0
    imgui.SetNextWindowPos(imgui.ImVec2(320 * DPI, 100 * DPI), imgui.Cond.FirstUseEver)
    imgui.SetNextWindowSize(imgui.ImVec2(960 * DPI, 720 * DPI), imgui.Cond.Always)
    
    imgui.Begin("##menu_atualizacao", nil, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar)
    
    local drawList = imgui.GetWindowDrawList()
    local windowPos = imgui.GetWindowPos()
    local windowSize = imgui.GetWindowSize()
    drawList:AddRectFilled(windowPos, imgui.ImVec2(windowPos.x + windowSize.x, windowPos.y + windowSize.y), imgui.GetColorU32Vec4(imgui.ImVec4(0.0, 0.0, 0.0, 1.0)))

    imgui.SetCursorPosY(40 * DPI)
    imgui.SetCursorPosX((windowSize.x - imgui.CalcTextSize("ATUALIZAÇÃO, HEX DUMP TEAM V2").x) / 2)
    imgui.TextColored(imgui.ImVec4(1.0, 1.0, 1.0, 1.0), "ATUALIZAÇÃO, HEX DUMP TEAM V2")
    
    imgui.SetCursorPosY(330 * DPI)
    imgui.SetCursorPosX((windowSize.x - imgui.CalcTextSize("Nova Atualização, Atualize Agora!").x) / 2)
    imgui.TextColored(imgui.ImVec4(1.0, 0.0, 0.0, 1.0), "Nova Atualização, Atualize Agora!")

    imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.8, 0.0, 0.0, 1.0))
    imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(1.0, 0.0, 0.0, 1.0))
    imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.6, 0.0, 0.0, 1.0))
    imgui.SetCursorPosY(620 * DPI)
    imgui.SetCursorPosX((windowSize.x - BotaoMob.x) / 2)
    if imgui.Button(" ATUALIZAR", BotaoMob) then
        openLink("https://4br.me/HexDump")
    end
    imgui.PopStyleColor(3)
    imgui.End()
end)

function main()
    while not isSampAvailable() do
        wait(100)
    end
    GUI.AbrirMenu[0] = true
    while true do
        wait(0)
    end
end

function openLink(link)
    if link and link ~= "" then
        gta._Z12AND_OpenLinkPKc(link)
    end
end
