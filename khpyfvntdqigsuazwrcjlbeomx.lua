local imgui = require "mimgui"
local new = imgui.new
local widgets = require("widgets")
local inicfg = require 'inicfg'
local faicons = require('fAwesome6')
local se = require("samp.events")
local ffi = require("ffi")
local gtasa = ffi.load("GTASA")
local vector3d = require("vector3d")
local memory = require("SAMemory")
local encoding = require("encoding")
encoding.default = "CP1251"
local u8 = encoding.UTF8

-- VERIFICAR IMAGEM
local credito = renderCreateFont("Arial", 12, 1 + 4) 
-- PLATAFORMA
local players = {}
local FontPlataforma = renderCreateFont('Arial', 10, 12)
-- FUNCAO DE NOTIFICACAO
local notificacoes = {}
local camModes = {7, 8, 34, 45, 46, 51, 65}
-- RESOLUCAO DA TELA
local largura, altura = getScreenResolution()
-- FONTE
local FontEspCar = renderCreateFont("Arial", 16, 12)
local FontEspSkinId = renderCreateFont("Arial", 10, 5)
local FontEspNome = renderCreateFont("Arial", 15, 9)
-- AIMBOT
memory.require("CCamera")
local camera_principal = memory.camera
-- LOG DO SERVER
local MessagesLog = {}
local FonteLog = renderCreateFont("Arial", 12, 0)
-- IMAGEM
local Imagem = nil
local Imagem2 = nil
-- BOTAO
local buttonSize
local categoria
-- ANIMACAO DO MENU
local LimparParticulas = {}
for i = 1, 40 do
    table.insert(LimparParticulas, {
        posicao = imgui.ImVec2(math.random(0, 900), math.random(0, 700)),
        velocidade = imgui.ImVec2((math.random() - 0.5) * 4.0, (math.random() - 0.5) * 0.4)
    })
end

local function CriarDiretorioSeNecessario()
    local diretorio = getWorkingDirectory() .. "/JhowModsOfc/config"
    if not doesDirectoryExist(diretorio) then
        createDirectory(diretorio)
    end
end

local function VerificarOuCriarConfig(caminho)
    local file = io.open(caminho, "r")

    if not file then
        file = io.open(caminho, "w")
        if file then
            file:write("[Amigos]\n\n")
            file:write("[ConfigHexDump]\n")

            file:write("AtivarMessagesLog = false\n")
            file:write("AntCrash = false\n")
            file:write("Menu1 = false\n")
            file:write("Menu2 = false\n")
            file:write("DesativarMenu = true\n")
            file:write("temaAzul = false\n")
            file:write("temaVermelho = true\n")
            file:write("temaRosa = true\n")
            file:write("AtivarDraFov = false\n")
            file:write("Cabeca = true\n")
            file:write("Peito = false\n")
            file:write("IgnoreSkin = false\n")
            file:write("IgnoreAdmin = false\n")
            file:write("IgnoreAmigos = false\n")
            file:write("IgnoreObject = false\n")
            file:write("IgnoreVeiculo = false\n")
            file:write("IgnoreAfkAim = false\n")
            file:write("EspLine = false\n")
            file:write("EspNome = false\n")
            file:write("EspBox = false\n")

            file:close()
        end
    else
        file:close()
    end
end

CriarDiretorioSeNecessario()
local CaminhoConfig = getWorkingDirectory() .. "/JhowModsOfc/config/HexDumTeam.ini"
VerificarOuCriarConfig(CaminhoConfig)

local config = inicfg.load({
    ConfigHexDump = {
        AtivarDraFov = false,
        Cabeca = false,
        Peito = false,
        IgnoreSkin = false,
        IgnoreAdmin = false,
        IgnoreAmigos = false,
        IgnoreObject = false,
        IgnoreVeiculo = false,
        IgnoreAfkAim = false,
        EspLine = false,
        EspNome = false,
        EspBox = false,
        AtivarMessagesLog = false,
        AntCrash = false,
        Menu1 = false,
        Menu2 = false,
        DesativarMenu = false,
        temaAzul = false,
        temaVermelho = false,
        temaRosa = false
    },
    Amigos = {}
}, CaminhoConfig)

if not config then
    config = {
        ConfigHexDump = {
            AtivarDraFov = false,
            Cabeca = false,
            Peito = false,
            IgnoreSkin = false,
            IgnoreAdmin = false,
            IgnoreAmigos = false,
            IgnoreObject = false,
            IgnoreVeiculo = false,
            IgnoreAfkAim = false,
            EspLine = false,
            EspNome = false,
            EspBox = false,
            AtivarMessagesLog = false,
            AntCrash = false,
            Menu1 = false,
            Menu2 = false,
            DesativarMenu = false,
            temaAzul = false,
            temaVermelho = false,
            temaRosa = false
        },
        Amigos = {}
    }
    inicfg.save(config, CaminhoConfig)
end

if not config.ConfigHexDump then
    config.ConfigHexDump = {
        AtivarDraFov = false,
        Cabeca = false,
        Peito = false,
        IgnoreSkin = false,
        IgnoreAdmin = false,
        IgnoreAmigos = false,
        IgnoreObject = false,
        IgnoreVeiculo = false,
        IgnoreAfkAim = false,
        EspLine = false,
        EspNome = false,
        EspBox = false,
        AtivarMessagesLog = false,
        AntCrash = false,
        Menu1 = false,
        Menu2 = false,
        DesativarMenu = false,
        temaAzul = false,
        temaVermelho = false,
        temaRosa = false
    }
    inicfg.save(config, CaminhoConfig)
end

if not config.Amigos then
    config.Amigos = {}
    inicfg.save(config, CaminhoConfig)
end

local function CarregarListaAmigos()
    if not config.Amigos then
        config.Amigos = {}
    end

    local amigosArray = {}
    for key, value in pairs(config.Amigos) do
        if value == true then
            table.insert(amigosArray, key)
        end
    end

    return amigosArray
end

local function AdicionarAmigo(nome)
    if nome and nome ~= "" then
        local nomeFormatado = nome:gsub("^%s*(.-)%s*$", "%1")
        
        if nomeFormatado == "" then
            return false, "Nome Invalido!"
        end
        
        if config.Amigos[nomeFormatado] then
            return false, "Ja Na Lista!"
        end
        
        config.Amigos[nomeFormatado] = true
        inicfg.save(config, CaminhoConfig)
        return true, "Amigo Adicionado!"
    end
    return false, "Nome invalido!"
end

local function RemoverAmigo(nome)
    if nome and nome ~= "" then
        local nomeFormatado = nome:gsub("^%s*(.-)%s*$", "%1")
        
        if nomeFormatado == "" then
            return false, "Nome Invalido!"
        end
        
        if config.Amigos[nomeFormatado] then
            config.Amigos[nomeFormatado] = nil
            inicfg.save(config, CaminhoConfig)
            return true, "Amigo Removido!"
        else
            return false, "Amigo Nao Encontrado!"
        end
    end
    return false, "Nome invalido!"
end

local function IsAmigo(nomeJogador)
    if not nomeJogador then return false end
    local nomeFormatado = nomeJogador:gsub("^%s*(.-)%s*$", "%1")
    return config.Amigos[nomeFormatado] == true
end

-- SERVIDOR PROIBIDO
local function BlackListServer()
    local ip, porta = sampGetCurrentServerAddress()
    local serverKey = ip .. ":" .. tostring(porta)
    if serverKey == "135.148.164.122:29698" then
        return true
    end
    return false
end

local GUI = {
    AbrirMenu = imgui.new.bool(false),
    IgnoreSkinID = new.int(217),
    AtivarAimbot = new.bool(false),
    AtivarDraFov = new.bool(config.ConfigHexDump.AtivarDraFov),
    AntHs = new.bool(false),
    GodMod = new.bool(false),
    AntTraze = new.bool(false),
    FovAimbot = new.float(100),
    SelecionaPlayerTab = new.int(-1),
    SelecionaVeiculosTab = new.int(-1),
    SuavidadeAimbot = new.int(100),
    DistanciaAimbot = new.float(100),
    AlturaY = new.float(0.4381),
    LaguraX = new.float(0.5211),
    Cabeca = new.bool(config.ConfigHexDump.Cabeca),
    Peito = new.bool(config.ConfigHexDump.Peito),
    IgnoreAfkAim = new.bool(config.ConfigHexDump.IgnoreAfkAim),
    IgnoreVeiculo = new.bool(config.ConfigHexDump.IgnoreVeiculo),
    IgnoreObject = new.bool(config.ConfigHexDump.IgnoreObject),
    IgnoreAmigos = new.bool(config.ConfigHexDump.IgnoreAmigos),
    IgnoreAdmin = new.bool(config.ConfigHexDump.IgnoreAdmin),
    IgnoreSkin = new.bool(config.ConfigHexDump.IgnoreSkin),
    EspLine = new.bool(config.ConfigHexDump.EspLine),
    EspBox = new.bool(config.ConfigHexDump.EspBox),
    EspPlataforma = new.bool(false),
    EspEsqueleto = new.bool(false),
    EspSkinId = new.bool(false),
    EspNome = new.bool(config.ConfigHexDump.EspNome),
    EspInfoCar = new.bool(false),
    EspCarro = new.bool(false),
    Menu1 = new.bool(config.ConfigHexDump.Menu1),
    Menu2 = new.bool(config.ConfigHexDump.Menu2),
    DesativarMenu = new.bool(config.ConfigHexDump.DesativarMenu),
    temaAzul = new.bool(config.ConfigHexDump.temaAzul),
    temaVermelho = new.bool(config.ConfigHexDump.temaVermelho),
    temaRosa = new.bool(config.ConfigHexDump.temaRosa),
    AtivarMessagesLog = new.bool(config.ConfigHexDump.AtivarMessagesLog),
    AtivarTelaEsticada = new.bool(false),
    AlterarFovTela = new.int(70),
    ProAimbot = new.bool(false),
    AtivarDiaClima = new.bool(false),
    SetClima = new.int(0),
    SetDia = new.int(30),
    AntCrash = new.bool(config.ConfigHexDump.AntCrash),
    selected_category = "creditos"
}

local listaAmigos = CarregarListaAmigos()

function SalvarConfig()
    config.ConfigHexDump.AtivarDraFov = GUI.AtivarDraFov[0]
    config.ConfigHexDump.Cabeca = GUI.Cabeca[0]
    config.ConfigHexDump.Peito = GUI.Peito[0]
    config.ConfigHexDump.IgnoreAfkAim = GUI.IgnoreAfkAim[0]
    config.ConfigHexDump.IgnoreVeiculo = GUI.IgnoreVeiculo[0]
    config.ConfigHexDump.IgnoreObject = GUI.IgnoreObject[0]
    config.ConfigHexDump.IgnoreAmigos = GUI.IgnoreAmigos[0]
    config.ConfigHexDump.IgnoreAdmin = GUI.IgnoreAdmin[0]
    config.ConfigHexDump.IgnoreSkin = GUI.IgnoreSkin[0]
    config.ConfigHexDump.EspNome = GUI.EspNome[0]
    config.ConfigHexDump.EspLine = GUI.EspLine[0]
    config.ConfigHexDump.EspBox = GUI.EspBox[0]
    config.ConfigHexDump.AtivarMessagesLog = GUI.AtivarMessagesLog[0]
    config.ConfigHexDump.AntCrash = GUI.AntCrash[0]
    config.ConfigHexDump.Menu1 = GUI.Menu1[0]
    config.ConfigHexDump.Menu2 = GUI.Menu2[0]
    config.ConfigHexDump.DesativarMenu = GUI.DesativarMenu[0]
    config.ConfigHexDump.temaAzul = GUI.temaAzul[0]
    config.ConfigHexDump.temaVermelho = GUI.temaVermelho[0]
    config.ConfigHexDump.temaRosa = GUI.temaRosa[0]
    inicfg.save(config, CaminhoConfig)
end

carros = { "Landstalker", "Bravura", "BUFFALO", "Linerunner", "PERENIEL", "SENTINEL", "Dumper", "Firetruck", "Trashmaster", "Stretch", "Manana", "INFERNUS", "Voodoo", "Pony", "Mule", "CHEETAH", "AMBULANCIA", "Leviathan", "Moonbeam", "Esperanto", "TAXI", "Washington", "Bobcat", "Mr Whoopee", "BF INJECTION", "Hunter", "PREMIER", "Enforcer", "Securicar", "BANSHEE", "Predator", "Bus", "Rhino", "Barracks", "Hotknife", "Trailer", "Previon", "Coach", "Cabbie", "Stallion", "Rumpo", "RC Bandit", "Romero", "Packer", "Monster Truck", "Admiral", "Squalo", "Seasparrow", "Pizzaboy", "Tram", "Trailer", "Turismo", "Speeder", "Reefer", "Tropic", "Flatbed", "Yankee", "Caddy", "Solair", "Berkley's RC Van", "Skimmer", "PCJ 600", "Faggio", "Freeway", "RC Baron", "RC Raider", "Glendale", "Oceanic", "SANCHEZ", "Sparrow", "Patriot", "QUADRICICLO", "Coastguard", "Dinghy", "Hermes", "Sabre", "Rustler", "ZR 350", "Walton", "Regina", "Comet", "BMX", "Burrito", "Camper", "Marquis", "Baggage", "Dozer", "Maverick", "News Chopper", "RANCHER", "FBI RANCHER", "Virgo", "Greenwood", "Jetmax", "HOTRING", "Sandking", "Blista Compact", "Police Maverick", "Boxville", "Benson", "Mesa", "RC Goblin", "HOTRING RACER", "HOTRING RACER", "Bloodring Banger", "RANCHER", "SUPER GT", "Elegant", "Journey", "BIKE", "MOUNTAIN BIKE", "Beagle", "Cropdust", "Stunt", "Tanker", "RoadTrain", "Nebula", "Majestic", "Buccaneer", "Shamal", "Hydra", "FCR 900", "NRG 500", "HPV 1000", "Cement Truck", "Tow Truck", "Fortune", "Cadrona", "FBI Truck", "Willard", "Forklift", "Tractor", "Combine", "Feltzer", "Remington", "Slamvan", "Blade", "Freight", "Streak", "Vortex", "Vincent", "Bullet", "Clover", "Sadler", "Firetruck", "Hustler", "Intruder", "Primo", "Cargobob", "Tampa", "Sunrise", "Merit", "Utility", "Nevada", "Yosemite", "Windsor", "Monster Truck", "Monster Truck", "Uranus", "JESTER", "SULTAN", "STRATUM", "ELEGY", "Raindance", "RC TIGER", "FLASH", "Tahoma", "SAVANNA", "Bandito", "Freight", "Trailer", "Kart", "Mower", "Duneride", "Sweeper", "Broadway", "TORNADO", "AT-400", "DFT-30", "Huntley", "Stafford", "BF 400", "Newsvan", "Tug", "Trailer", "Emperor", "Wayfarer", "EUROS", "Hotdog", "Club", "Trailer", "Trailer", "Andromada", "Dodo", "RC Cam", "Launch", "POLICIA CAR (LS)", "POLICIA CAR (SF)", "Police Car (LV)", "Police RANGER", "PICADOR", "S.W.A.T. Van", "ALPHA", "PHOENIX", "Glendale", "Sadler", "Luggage Trailer", "Luggage Trailer", "Stair Trailer", "Boxville", "Farm Plow", "Utility Trailer" }

function getDPIScale()
    local w, h = getScreenResolution()
    local base_w = 1920
    return w / base_w
end

local ui_scale = imgui.new.float(1.0)
local DPI = 1.0
local BotaoMob = imgui.ImVec2(380 * DPI, 40 * DPI)

imgui.OnInitialize(function()
    DPI = getDPIScale() * ui_scale[0]

    local config = imgui.ImFontConfig()
    config.MergeMode = true
    config.PixelSnapH = true

    local iconRanges = imgui.new.ImWchar[3](faicons.min_range, faicons.max_range, 0)

    imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(
        faicons.get_font_data_base85("Regular"),
        20 * DPI,
        config,
        iconRanges
    )

    imgui.GetIO().IniFilename = nil

    if GUI.temaAzul[0] then
        TemaAzul()
    elseif GUI.temaRosa[0] then
        TemaRosa()
    elseif GUI.temaVermelho[0] then
        TemaVermelho()
    end

    local Foto1 = getWorkingDirectory() .. "/JhowModsOfc/Menu Mobile/HexDumpTeam.png"
    local Foto2 = getWorkingDirectory() .. "/JhowModsOfc/Menu Mobile/JhowModsOfc.png"

    Imagem = imgui.CreateTextureFromFile(Foto1)
    Imagem2 = imgui.CreateTextureFromFile(Foto2)
end)

imgui.OnFrame(function() return GUI.AbrirMenu[0] end, function()
    DPI = getDPIScale() * ui_scale[0]
    buttonSize = imgui.ImVec2(360 * DPI, 60 * DPI)
    categoria = imgui.ImVec2(-1, 75 * DPI)

    imgui.SetNextWindowPos(imgui.ImVec2(470 * DPI, 100 * DPI), imgui.Cond.FirstUseEver)
    imgui.SetNextWindowSize(imgui.ImVec2(960 * DPI, 720 * DPI), imgui.Cond.Always)
    local windowFlags = bit.bor(imgui.WindowFlags.NoCollapse, imgui.WindowFlags.NoResize, imgui.WindowFlags.NoTitleBar)

    if imgui.Begin("##menu", nil, windowFlags) then
        mainPos = imgui.GetWindowPos()
        mainSize = imgui.GetWindowSize()

        local buttonSizeX = 35 * DPI
        local xMarkPosX = mainSize.x - buttonSizeX - 10
        local xMarkPosY = 10

        imgui.SetCursorPos(imgui.ImVec2(xMarkPosX, xMarkPosY))
        imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.8, 0.0, 0.0, 1.0))
        imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(1.0, 0.2, 0.2, 1.0))
        imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.6, 0.0, 0.0, 1.0))
        imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.0, 1.0, 1.0, 1.0))

        if imgui.Button(faicons("XMARK"), imgui.ImVec2(buttonSizeX, buttonSizeX)) then
            Som2()
            GUI.AbrirMenu[0] = false
        end
        imgui.PopStyleColor(4)

        imgui.BeginChild("LeftPane", imgui.ImVec2(215 * DPI, 0), false)
        if Imagem then
            imgui.Image(Imagem, imgui.ImVec2(200 * DPI, 200 * DPI))
        end
        imgui.Dummy(imgui.ImVec2(0, 50 * DPI))
        if imgui.Button(     faicons("USER") .. " JOGADOR       ", categoria) then
            GUI.selected_category = "Jogador"
            Som2()
        end
        imgui.Dummy(imgui.ImVec2(0, 2 * DPI))
        if imgui.Button(     faicons("CROSSHAIRS") .. " COMBATE       ", categoria) then
            GUI.selected_category = "Aimbot"
            Som2()
        end
        imgui.Dummy(imgui.ImVec2(0, 2 * DPI))
        if imgui.Button(     faicons("EYE") .. " VISUAL          ", categoria) then
            GUI.selected_category = "visual"
            Som2()
        end
        imgui.Dummy(imgui.ImVec2(0, 70 * DPI))
        if imgui.Button(     faicons("GEAR") .. " CONFIG         ", categoria) then
            GUI.selected_category = "config"
            Som2()
        end
        imgui.Dummy(imgui.ImVec2(0, 2 * DPI))

        imgui.EndChild()
        imgui.SameLine()

        imgui.BeginChild("RightPane", imgui.ImVec2(0, 0), false)
        if GUI.selected_category == "Jogador" then
            imgui.Dummy(imgui.ImVec2(0, 5 * DPI))
            imgui.Separator()
            local textCredit = "JOGADORES"
            local textWidth = imgui.CalcTextSize(textCredit).x
            local leftPaneWidth = 220 * DPI
            local padding = 400 * DPI
            if leftPaneWidth and textWidth then
                imgui.SetCursorPosX((leftPaneWidth - textWidth) / 2 + padding / 2)
            end
            imgui.Text(textCredit)
            imgui.Separator()
            imgui.Dummy(imgui.ImVec2(0, 25 * DPI))
            if imgui.Checkbox(" ANT HS", GUI.AntHs) then
                Som1()
                MostrarNotificacao("ANT HS", GUI.AntHs[0])
            end
            imgui.Dummy(imgui.ImVec2(0, 10 * DPI))
            if imgui.Checkbox(" GOD MOD", GUI.GodMod) then
                Som1()
                MostrarNotificacao("GOD MOD", GUI.GodMod[0])
            end
            imgui.Dummy(imgui.ImVec2(0, 10 * DPI))
            if imgui.Checkbox(" ANT TRAZER", GUI.AntTraze) then
                Som1()
                MostrarNotificacao("ANT TRAZER", GUI.AntTraze[0])
            end
            imgui.Dummy(imgui.ImVec2(0, 25 * DPI))
            if GUI.temaAzul[0] then
                imgui.PushStyleColor(imgui.Col.Button,        imgui.ImVec4(0.00, 0.00, 1.00, 1.00))
                imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.0, 0.5, 1.0, 1.0))
                imgui.PushStyleColor(imgui.Col.ButtonActive,  imgui.ImVec4(0.0, 0.3, 0.6, 1.0))
            elseif GUI.temaRosa[0] then
                imgui.PushStyleColor(imgui.Col.Button,        imgui.ImVec4(1.00, 0.20, 0.70, 1.00))
                imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.0, 0.5, 1.0, 1.0))
                imgui.PushStyleColor(imgui.Col.ButtonActive,  imgui.ImVec4(0.0, 0.3, 0.6, 1.0))
            elseif GUI.temaVermelho[0] then
                imgui.PushStyleColor(imgui.Col.Button,        imgui.ImVec4(0.8, 0.0, 0.0, 1.0))
                imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(1.0, 0.0, 0.0, 1.0))
                imgui.PushStyleColor(imgui.Col.ButtonActive,  imgui.ImVec4(0.6, 0.0, 0.0, 1.0))
            end
            if imgui.Button(" PUXAR VIDA", BotaoMob) then
                Som1()
                setCharHealth(PLAYER_PED, 100)
            end
            if imgui.Button(" PUXAR COLETE", BotaoMob) then
                Som1()
                addArmourToChar(PLAYER_PED, 100)
            end
            if imgui.Button(" DESCONGELAR JOGADOR", BotaoMob) then
                freezeCharPosition(PLAYER_PED, true)
                freezeCharPosition(PLAYER_PED, false)
                setPlayerControl(PLAYER_HANDLE, true)
                restoreCameraJumpcut()
                clearCharTasksImmediately(PLAYER_PED)
            end
            if imgui.Button(" SUICIDAR", BotaoMob) then
                setCharHealth(PLAYER_PED, 0)
            end
            if imgui.Button(" SPAWN", BotaoMob) then
                sampSendSpawn()
            end
            if GUI.temaAzul[0] or GUI.temaVermelho[0] or GUI.temaRosa[0] then
                imgui.PopStyleColor(3)
            end
            imgui.Dummy(imgui.ImVec2(0, 25 * DPI))
            if Toggle(" ATIVAR FOV TELA", GUI.AtivarTelaEsticada) then
                Som1()
                MostrarNotificacao("FOV TELA", GUI.AtivarTelaEsticada[0])
            end
            imgui.Dummy(imgui.ImVec2(0, 5 * DPI))
            if GUI.AtivarTelaEsticada[0] then
                if Slider("AJUSTAR FOV", GUI.AlterarFovTela, 10, 120, 400) then
                    if GUI.AtivarTelaEsticada[0] then
                        cameraSetLerpFov(GUI.AlterarFovTela[0], 101, 1000, true)
                    end
                end
                imgui.Dummy(imgui.ImVec2(0, 20 * DPI))
            end
            if Toggle(" ATIVAR CLIMA/TEMPO", GUI.AtivarDiaClima) then
                Som1()
                MostrarNotificacao("CLIMA/TEMPO", GUI.AtivarDiaClima[0])
            end
            if GUI.AtivarDiaClima[0] then
                imgui.Dummy(imgui.ImVec2(0, 10 * DPI))
                Slider("TEMPO", GUI.SetDia, 1, 23, 400)
                imgui.Dummy(imgui.ImVec2(0, 5 * DPI))
                Slider("CLIMA", GUI.SetClima, 1, 45, 400)
            end
        end
        if GUI.selected_category == "Aimbot" then
            imgui.Dummy(imgui.ImVec2(0, 5 * DPI))
            imgui.Separator()
            local textCredit = "FUNÇÕES AIMBOT"
            local textWidth = imgui.CalcTextSize(textCredit).x
            local leftPaneWidth = 220 * DPI
            local padding = 400 * DPI
            if leftPaneWidth and textWidth then
                imgui.SetCursorPosX((leftPaneWidth - textWidth) / 2 + padding / 2)
            end
            imgui.Text(textCredit)
            imgui.Separator()
            imgui.Dummy(imgui.ImVec2(0, 25 * DPI))
            if Toggle(" ATIVAR AIMBOT", GUI.AtivarAimbot) then
                Som1()
                MostrarNotificacao("AIMBOT", GUI.AtivarAimbot[0])
            end
            imgui.Dummy(imgui.ImVec2(0, 10 * DPI))
            if GUI.AtivarAimbot[0] then
                if Toggle(" ATIVAR DRAW FOV", GUI.AtivarDraFov) then
                    Som1()
                    MostrarNotificacao("DRAW FOV", GUI.AtivarDraFov[0])
                    SalvarConfig()
                end
                imgui.Dummy(imgui.ImVec2(0, 15 * DPI))
                Slider("FOV AIMBOT", GUI.FovAimbot, 1, 100, 400)
                imgui.Dummy(imgui.ImVec2(0, 15 * DPI))
                Slider("SUAVIDADE", GUI.SuavidadeAimbot, 1, 100, 400)
                imgui.Dummy(imgui.ImVec2(0, 15 * DPI))
                Slider("DISTANCIA", GUI.DistanciaAimbot, 1, 100, 400)
                imgui.Dummy(imgui.ImVec2(0, 15 * DPI))
                if Slider("ALTURA Y", GUI.AlturaY, 0.39, 0.55, 400, "%.4f") then
                    if GUI.Cabeca[0] or GUI.Peito[0] then
                        GUI.Cabeca[0] = false
                        GUI.Peito[0] = false
                        SalvarConfig()
                    end
                end
                imgui.Dummy(imgui.ImVec2(0, 15 * DPI))
                if Slider("LAGURA X", GUI.LaguraX, 0.39, 0.55, 400, "%.4f") then
                    if GUI.Cabeca[0] or GUI.Peito[0] then
                        GUI.Cabeca[0] = false
                        GUI.Peito[0] = false
                        SalvarConfig()
                    end
                end
                imgui.Dummy(imgui.ImVec2(0, 15 * DPI))
                imgui.InputInt("IGNORE SKIN ID", GUI.IgnoreSkinID)
                imgui.Dummy(imgui.ImVec2(0, 15 * DPI))
                if imgui.Checkbox(" CABECA", GUI.Cabeca) then
                    GUI.Peito[0] = false
                    GUI.AlturaY[0] = 0.4381
                    GUI.LaguraX[0] = 0.5211
                    Som1()
                    MostrarNotificacao("CABECA", GUI.Cabeca[0])
                    SalvarConfig()
                end
                imgui.SameLine(400)
                if imgui.Checkbox(" PEITO", GUI.Peito) then
                    GUI.Cabeca[0] = false
                    GUI.AlturaY[0] = 0.4111
                    GUI.LaguraX[0] = 0.5199
                    Som1()
                    MostrarNotificacao("PEITO", GUI.Peito[0])
                    SalvarConfig()
                end
                imgui.Dummy(imgui.ImVec2(0, 15 * DPI))
                if imgui.Checkbox(" IGNORE AFK", GUI.IgnoreAfkAim) then
                    Som1()
                    MostrarNotificacao("IGNORE AFK", GUI.IgnoreAfkAim[0])
                    SalvarConfig()
                end
                imgui.SameLine(400)
                if imgui.Checkbox(" IGNORE VEICULOS", GUI.IgnoreVeiculo) then
                    Som1()
                    MostrarNotificacao("IGNORE VEICULOS", GUI.IgnoreVeiculo[0])
                    SalvarConfig()
                end
                imgui.Dummy(imgui.ImVec2(0, 15 * DPI))
                if imgui.Checkbox(" IGNORE OBJETOS", GUI.IgnoreObject) then
                    Som1()
                    MostrarNotificacao("IGNORE OBJETOS", GUI.IgnoreObject[0])
                    SalvarConfig()
                end
                imgui.SameLine(400)
                if imgui.Checkbox(" IGNORE SKIN", GUI.IgnoreSkin) then
                    Som1()
                    MostrarNotificacao("IGNORE SKIN", GUI.IgnoreSkin[0])
                    SalvarConfig()
                end
                imgui.Dummy(imgui.ImVec2(0, 15 * DPI))
                if imgui.Checkbox(" IGNORE ADMIN", GUI.IgnoreAdmin) then
                    Som1()
                    MostrarNotificacao("IGNORE ADMIN", GUI.IgnoreAdmin[0])
                    SalvarConfig()
                end
                imgui.SameLine(400)
                if imgui.Checkbox(" IGNORE AMIGOS", GUI.IgnoreAmigos) then
                    Som1()
                    MostrarNotificacao("IGNORE AMIGOS", GUI.IgnoreAmigos[0])
                    SalvarConfig()
                end
                imgui.Dummy(imgui.ImVec2(0, 15 * DPI))
                if GUI.temaAzul[0] then
                    imgui.PushStyleColor(imgui.Col.Button,        imgui.ImVec4(0.00, 0.00, 1.00, 1.00))
                    imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.0, 0.5, 1.0, 1.0))
                    imgui.PushStyleColor(imgui.Col.ButtonActive,  imgui.ImVec4(0.0, 0.3, 0.6, 1.0))
                elseif GUI.temaRosa[0] then
                    imgui.PushStyleColor(imgui.Col.Button,        imgui.ImVec4(1.00, 0.20, 0.70, 1.00))
                    imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.0, 0.5, 1.0, 1.0))
                    imgui.PushStyleColor(imgui.Col.ButtonActive,  imgui.ImVec4(0.0, 0.3, 0.6, 1.0))
                elseif GUI.temaVermelho[0] then
                    imgui.PushStyleColor(imgui.Col.Button,        imgui.ImVec4(0.8, 0.0, 0.0, 1.0))
                    imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(1.0, 0.0, 0.0, 1.0))
                    imgui.PushStyleColor(imgui.Col.ButtonActive,  imgui.ImVec4(0.6, 0.0, 0.0, 1.0))
                end
                imgui.Text("ADICIONE AMIGO:")
                if imgui.Button(" ADICIONAR AMIGO", BotaoMob) then
                    Som1()
                    local nomeAmigo = ""
                    local playerId = GUI.SelecionaPlayerTab[0]
                    if playerId >= 0 and sampIsPlayerConnected(playerId) then
                        nomeAmigo = sampGetPlayerNickname(playerId)
                    end
                    local sucesso, mensagem = AdicionarAmigo(nomeAmigo)
                    if sucesso then
                        listaAmigos = CarregarListaAmigos()
                        MostrarNotificacao(mensagem, true)
                    else
                        MostrarNotificacao(mensagem, false)
                    end
                end
                imgui.SameLine()
                if imgui.Button(" REMOVER AMIGO", BotaoMob) then
                    Som1()
                    local nomeAmigo = ""
                    local playerId = GUI.SelecionaPlayerTab[0]
                    if playerId >= 0 and sampIsPlayerConnected(playerId) then
                        nomeAmigo = sampGetPlayerNickname(playerId)
                    end
                    local sucesso, mensagem = RemoverAmigo(nomeAmigo)
                    if sucesso then
                        listaAmigos = CarregarListaAmigos()
                        MostrarNotificacao(mensagem, true)
                    else
                        MostrarNotificacao(mensagem, false)
                    end
                end
                if GUI.temaAzul[0] or GUI.temaVermelho[0] or GUI.temaRosa[0] then
                    imgui.PopStyleColor(3)
                end
                imgui.Dummy(imgui.ImVec2(0, 30 * DPI))
            end
            if Toggle(" PUXAR E MATA JOGADORES", GUI.ProAimbot) then
                Som1()
                MostrarNotificacao("PUXAR E MATA", GUI.ProAimbot[0])
            end
            imgui.Dummy(imgui.ImVec2(0, 5 * DPI))
        end
        if GUI.selected_category == "visual" then
            imgui.Dummy(imgui.ImVec2(0, 5 * DPI))
            imgui.Separator()
            local textCredit = "FUNÇÕES ESP"
            local textWidth = imgui.CalcTextSize(textCredit).x
            local leftPaneWidth = 220 * DPI
            local padding = 400 * DPI
            if leftPaneWidth and textWidth then
                imgui.SetCursorPosX((leftPaneWidth - textWidth) / 2 + padding / 2)
            end
            imgui.Text(textCredit)
            imgui.Separator()
            imgui.Dummy(imgui.ImVec2(0, 25 * DPI))
            if imgui.Checkbox(" ESP NOME", GUI.EspNome) then
                Som1()
                MostrarNotificacao("ESP NOME", GUI.EspNome[0])
                SalvarConfig()
            end
            imgui.Dummy(imgui.ImVec2(0, 15 * DPI))
            if imgui.Checkbox(" ESP LINE", GUI.EspLine) then
                Som1()
                MostrarNotificacao("ESP LINE", GUI.EspLine[0])
                SalvarConfig()
            end
            imgui.Dummy(imgui.ImVec2(0, 15 * DPI))
            if imgui.Checkbox(" ESP BOX", GUI.EspBox) then
                Som1()
                MostrarNotificacao("ESP BOX", GUI.EspBox[0])
                SalvarConfig()
            end
            imgui.Dummy(imgui.ImVec2(0, 15 * DPI))
            if imgui.Checkbox(" ESP PLATAFORMA", GUI.EspPlataforma) then
                Som1()
                MostrarNotificacao("ESP PLATAFORMA", GUI.EspPlataforma[0])
            end
            imgui.Dummy(imgui.ImVec2(0, 15 * DPI))
            if imgui.Checkbox(" ESP SKIN ID", GUI.EspSkinId) then
                Som1()
                MostrarNotificacao("ESP SKIN ID", GUI.EspSkinId[0])
            end
            imgui.Dummy(imgui.ImVec2(0, 15 * DPI))
            if imgui.Checkbox(" ESP INFO VEICULO", GUI.EspInfoCar) then
                Som1()
                MostrarNotificacao("ESP INFO VEICULO", GUI.EspInfoCar[0])
            end
            imgui.Dummy(imgui.ImVec2(0, 15 * DPI))
            if imgui.Checkbox(" ESP CARRO", GUI.EspCarro) then
                Som1()
                MostrarNotificacao("ESP CARRO", GUI.EspCarro[0])
            end
            imgui.Dummy(imgui.ImVec2(0, 15 * DPI))
            if imgui.Checkbox(" ESP ESQUELETO (EM BREVE)", GUI.EspEsqueleto) then
                Som1()
                MostrarNotificacao("ESP ESQUELETO (EM BREVE)", GUI.EspEsqueleto[0])
            end
        end
        if GUI.selected_category == "config" then
            imgui.Dummy(imgui.ImVec2(0, 5 * DPI))
            imgui.Separator()
            local textCredit = "CONFIGURAÇÃO"
            local textWidth = imgui.CalcTextSize(textCredit).x
            local leftPaneWidth = 220 * DPI
            local padding = 400 * DPI
            if leftPaneWidth and textWidth then
                imgui.SetCursorPosX((leftPaneWidth - textWidth) / 2 + padding / 2)
            end
            imgui.Text(textCredit)
            imgui.Separator()
            imgui.Dummy(imgui.ImVec2(0, 25 * DPI))
            imgui.Text("CONFIG MENU")
            imgui.SameLine()
            if imgui.Button(faicons("GEAR")) then
                imgui.OpenPopup("CONFIG MENU")
            end
            if imgui.BeginPopup("CONFIG MENU") then
                imgui.Text("CONFIGURAÇÃO MOD MENU V2.0")
                imgui.Separator()
                imgui.Dummy(imgui.ImVec2(0, 20 * DPI))
                imgui.Text("MENU EXTRAS")
                imgui.Dummy(imgui.ImVec2(0, 5 * DPI))
                if imgui.Checkbox(" MENU JOGADORES", GUI.Menu1) then
                    GUI.Menu2[0] = false
                    GUI.DesativarMenu[0] = false
                    SalvarConfig()
                end
                imgui.Dummy(imgui.ImVec2(0, 10 * DPI))
                if imgui.Checkbox(" MENU VEICULOS", GUI.Menu2) then
                    GUI.Menu1[0] = false
                    GUI.DesativarMenu[0] = false
                    SalvarConfig()
                end
                imgui.Dummy(imgui.ImVec2(0, 10 * DPI))
                if imgui.Checkbox(" TODOS OS MENU", GUI.DesativarMenu) then
                    GUI.Menu1[0] = true
                    GUI.Menu2[0] = true
                    SalvarConfig()
                end
                imgui.Dummy(imgui.ImVec2(0, 20 * DPI))
                imgui.Text("TEMAS")
                if imgui.Checkbox("TEMA (VERMELHO)", GUI.temaVermelho) then
                    GUI.temaAzul[0] = false
                    GUI.temaRosa[0] = false
                    TemaVermelho()
                    SalvarConfig()
                end
                imgui.Dummy(imgui.ImVec2(0, 10 * DPI))
                if imgui.Checkbox("TEMA (AZUL)", GUI.temaAzul) then
                    GUI.temaVermelho[0] = false
                    GUI.temaRosa[0] = false
                    TemaAzul()
                    SalvarConfig()
                end
                imgui.Dummy(imgui.ImVec2(0, 10 * DPI))
                if imgui.Checkbox("TEMA (ROSA)", GUI.temaRosa) then
                    GUI.temaVermelho[0] = false
                    GUI.temaAzul[0] = false
                    TemaRosa()
                    SalvarConfig()
                end
                imgui.Dummy(imgui.ImVec2(0, 20 * DPI))
                imgui.EndPopup()
            end
            imgui.Dummy(imgui.ImVec2(0, 25 * DPI))
            if imgui.Checkbox(" LOG SERVIDOR", GUI.AtivarMessagesLog) then
                Som1()
                MostrarNotificacao("LOG SERVIDOR", GUI.AtivarMessagesLog[0])
                SalvarConfig()
            end
            imgui.Dummy(imgui.ImVec2(0, 10 * DPI))
            if imgui.Checkbox(" ANT CRASH MOBILE", GUI.AntCrash) then
                Som1()
                MostrarNotificacao("ANT CRASH MOBILE", GUI.AntCrash[0])
                SalvarConfig()
            end
            imgui.Dummy(imgui.ImVec2(0, 25 * DPI))
            if GUI.temaAzul[0] then
                imgui.PushStyleColor(imgui.Col.Button,        imgui.ImVec4(0.00, 0.00, 1.00, 1.00))
                imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.0, 0.5, 1.0, 1.0))
                imgui.PushStyleColor(imgui.Col.ButtonActive,  imgui.ImVec4(0.0, 0.3, 0.6, 1.0))
            elseif GUI.temaRosa[0] then
                imgui.PushStyleColor(imgui.Col.Button,        imgui.ImVec4(1.00, 0.20, 0.70, 1.00))
                imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.0, 0.5, 1.0, 1.0))
                imgui.PushStyleColor(imgui.Col.ButtonActive,  imgui.ImVec4(0.0, 0.3, 0.6, 1.0))
            elseif GUI.temaVermelho[0] then
                imgui.PushStyleColor(imgui.Col.Button,        imgui.ImVec4(0.8, 0.0, 0.0, 1.0))
                imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(1.0, 0.0, 0.0, 1.0))
                imgui.PushStyleColor(imgui.Col.ButtonActive,  imgui.ImVec4(0.6, 0.0, 0.0, 1.0))
            end
            if imgui.Button(" LIMPAR CHAT", BotaoMob) then
                for i = 1, 15 do
					sampAddChatMessage("", -1)
				end
            end
            if GUI.temaAzul[0] or GUI.temaVermelho[0] or GUI.temaRosa[0] then
                imgui.PopStyleColor(3)
            end
        end
        if GUI.selected_category == "creditos" then
            if Imagem2 then
                imgui.Image(Imagem2, imgui.ImVec2(650 * DPI, 650 * DPI))
            end
        end

        imgui.EndChild()

        local drawList = imgui.GetWindowDrawList()
        local winPosicao = imgui.GetWindowPos()
        local winSize = imgui.GetWindowSize()
        local Clique = os.clock()

        for i, p in ipairs(LimparParticulas) do
            p.posicao.x = p.posicao.x + p.velocidade.x
            p.posicao.y = p.posicao.y + p.velocidade.y

            if p.posicao.x < 0 or p.posicao.x > winSize.x then
                p.velocidade.x = -p.velocidade.x
            end
            if p.posicao.y < 0 or p.posicao.y > winSize.y then
                p.velocidade.y = -p.velocidade.y
            end
            local px = winPosicao.x + p.posicao.x
            local py = winPosicao.y + p.posicao.y
            local pointColor = imgui.GetColorU32Vec4(imgui.ImVec4(1.0, 0.0, 0.0, 1.0))
            drawList:AddCircleFilled(imgui.ImVec2(px, py), 2, pointColor, 12)

            for j = i + 1, #LimparParticulas do
                local p2 = LimparParticulas[j]
                local dx = p.posicao.x - p2.posicao.x
                local dy = p.posicao.y - p2.posicao.y
                local dist = math.sqrt(dx * dx + dy * dy)
                if dist < 100 then
                    local alpha = (1 - dist / 100) * 255
                    local alphaF = alpha / 255
                    local lineColor = imgui.GetColorU32Vec4(imgui.ImVec4(1.0, 1.0, 1.0, alphaF))
                    drawList:AddLine(imgui.ImVec2(winPosicao.x + p.posicao.x, winPosicao.y + p.posicao.y), imgui.ImVec2(winPosicao.x + p2.posicao.x, winPosicao.y + p2.posicao.y), lineColor, 1.0)
                end
            end
        end
    end

    imgui.End()

    if GUI.Menu1[0] or GUI.DesativarMenu[0] and mainPos then
        imgui.SetNextWindowPos(imgui.ImVec2(mainPos.x - (220 * DPI), mainPos.y + (60 * DPI)), imgui.Cond.Always)
        imgui.SetNextWindowSize(imgui.ImVec2(210 * DPI, 600 * DPI), imgui.Cond.FirstUseEver)
        local windowFlags = bit.bor(imgui.WindowFlags.NoCollapse, imgui.WindowFlags.NoResize, imgui.WindowFlags.NoTitleBar)

        imgui.Begin("##jogadores", nil, windowFlags)

        local title = faicons("USER") .. " JOGADORES"
        local windowWidth = imgui.GetWindowSize().x
        local textWidth = imgui.CalcTextSize(title).x
        imgui.SetCursorPosX((windowWidth - textWidth) * 0.5)
        imgui.Text(title)
        imgui.Separator()

        imgui.BeginChild("players_list", imgui.ImVec2(-1, -1), true)

        for _, personagem in ipairs(getAllChars()) do
            if personagem ~= PLAYER_PED and doesCharExist(personagem) and isCharOnScreen(personagem) then
                local result, id = sampGetPlayerIdByCharHandle(personagem)
                if result then
                    local name = sampGetPlayerNickname(id)
                    local selected = GUI.SelecionaPlayerTab[0] == id
                    imgui.PushStyleColor(imgui.Col.Text, selected and imgui.ImVec4(0, 1, 0, 1) or imgui.ImVec4(1, 1, 1, 1))
                    imgui.PushTextWrapPos(180 * DPI)
                    if imgui.Selectable(name .. "(" .. id .. ")", selected) then
                        GUI.SelecionaPlayerTab[0] = id
                    end
                    imgui.PopTextWrapPos()
                    imgui.PopStyleColor()
                end
            end
        end

        imgui.EndChild()
        imgui.End()
    end

    if GUI.Menu2[0] or GUI.DesativarMenu[0] and mainPos then
        imgui.SetNextWindowPos(imgui.ImVec2(mainPos.x + mainSize.x + (10 * DPI), mainPos.y + (60 * DPI)), imgui.Cond.Always)
        imgui.SetNextWindowSize(imgui.ImVec2(210 * DPI, 600 * DPI), imgui.Cond.FirstUseEver)
        local windowFlags = bit.bor(imgui.WindowFlags.NoCollapse, imgui.WindowFlags.NoResize, imgui.WindowFlags.NoTitleBar)

        imgui.Begin("##veiculos", nil, windowFlags)

        local title = faicons("CAR") .. " VEICULOS"
        local windowWidth = imgui.GetWindowSize().x
        local textWidth = imgui.CalcTextSize(title).x
        imgui.SetCursorPosX((windowWidth - textWidth) * 0.5)
        imgui.Text(title)
        imgui.Separator()

        imgui.BeginChild("veh_list", imgui.ImVec2(-1, -1), true)

        for _, v in ipairs(getAllVehicles()) do
            if v and isCarOnScreen(v) then
                local result, vehId = sampGetVehicleIdByCarHandle(v)
                if result then
                    local model = getCarModel(v)
                    local name = carros[model - 399] or "DESCONHECIDO"
                    local selected = GUI.SelecionaVeiculosTab[0] == vehId
                    imgui.PushStyleColor(imgui.Col.Text, selected and imgui.ImVec4(0, 1, 0, 1) or imgui.ImVec4(1, 1, 1, 1))
                    imgui.PushTextWrapPos(180 * DPI)
                    if imgui.Selectable(name .. " (" .. vehId .. ")", selected) then
                        GUI.SelecionaVeiculosTab[0] = vehId
                    end
                    imgui.PopTextWrapPos()
                    imgui.PopStyleColor()
                end
            end
        end

        imgui.EndChild()
        imgui.End()
    end

    DesenharNotificacoes()
end)

function main()
    while not isSampAvailable() do
        wait(100)
    end
    EnviarSmS("{00FF00}Hex Dump Mobile carregado com sucesso!", -1)
    sampRegisterChatCommand("hexdump", function()
        if BlackListServer() then
            EnviarSmS("{FF0000}Este servidor bloqueou o Hex Dump!", -1)
            thisScript():unload()
            return
        end
        GUI.AbrirMenu[0] = not GUI.AbrirMenu[0]
        GUI.selected_category = "creditos"
    end)
    while true do
        wait(0)
        renderFontDrawText(credito, "JhowModsOfc", 100 * DPI, 1040 * DPI, 0xFFFF0000)
        if isWidgetSwipedLeft(WIDGET_RADAR) then
            if BlackListServer() then
                EnviarSmS("{FF0000}Menu bloqueado neste servidor!", -1)
                thisScript():unload()
            else
                GUI.AbrirMenu[0] = not GUI.AbrirMenu[0]
                GUI.selected_category = "creditos"
            end
        end

        if GUI.AbrirMenu[0] then
            Aimbot()
            ProAim()
            TelaEsticada()
        else
            Aimbot()
            ProAim()
            EspNome()
            EspLine()
            EspBox()
            EspPlataforma()
            EspSkinId()
            EspInforVeiculos()
            EspBoxCar()
            TelaEsticada()
            CarregarMessagesLog()
        end

        if GUI.GodMod[0] then
            setCharProofs(PLAYER_PED, true, true, true, true, true)
            setCharHealth(PLAYER_PED, 100)
        else
			setCharProofs(PLAYER_PED, false, false, false, false, false)
        end

        if GUI.AtivarDiaClima[0] then
			setTimeOfDay(GUI.SetDia[0], 0)
			forceWeatherNow(GUI.SetClima[0])
		end
        
        if GUI.AtivarDraFov[0] and GUI.AtivarAimbot[0] and isPlayerArmed() and not IgnoreDrawFovArma() then -- DRAW FOV AIMBOT
            local centerX = (largura / 2) + 40 * DPI
            local centerY = (altura / 2) - 60 * DPI
            local radius = (GUI.FovAimbot[0] / 100) * 150
            
            local distanciaMaxima = math.floor((GUI.DistanciaAimbot[0] - 1) * (200 - 10) / (100 - 1)) + 10
            
            local temAlvoNoFov = false
            local coordX, coordY, coordZ = getCharCoordinates(PLAYER_PED)
            
            for _, char in ipairs(getAllChars()) do
                if isCharOnScreen(char) and char ~= PLAYER_PED and not isCharDead(char) then
                    local result, playerId = sampGetPlayerIdByCharHandle(char)
                    if result and not isTargetAfkAim(playerId) and not isPlayerInVehicleAim(char) then
                        local posicaoX, posicaoY, posicaoZ = obterPosicaoDoOsso(char, 5)
                        local distanciaTotal = getDistanceBetweenCoords3d(coordX, coordY, coordZ, posicaoX, posicaoY, posicaoZ)
                        if distanciaTotal < distanciaMaxima then
                            local sx, sy = convert3DCoordsToScreen(posicaoX, posicaoY, posicaoZ)
                            if sx and sy then
                                local distFov = math.sqrt((sx - centerX)^2 + (sy - centerY)^2)
                                if distFov <= radius then
                                    temAlvoNoFov = true
                                    break
                                end
                            end
                        end
                    end
                end
                if temAlvoNoFov then break end
            end
            
            local corFov
            if temAlvoNoFov then
                corFov = 0xFF00FF00
            else
                corFov = 0xFFFF0000
            end
            DrawCirculo(centerX, centerY, radius, corFov)
        end

    end
end -- FIM MAIN

function DrawCirculo(x, y, radius, color)
    local segmentos = math.min(128, math.max(64, math.floor(128 * DPI)))
    local step = (2 * math.pi) / segmentos
    local oldX, oldY = x + radius, y

    for i = 1, segmentos do
        local newX = x + radius * math.cos(step * i)
        local newY = y + radius * math.sin(step * i)
        renderDrawLine(oldX, oldY, newX, newY, 2 * DPI, color)
        oldX, oldY = newX, newY
    end
end

function isPlayerSkin(char) -- IGNORE SKIN
    if not GUI.IgnoreSkin[0] then
        return false
    end
    local skinIgnore = GUI.IgnoreSkinID[0]
    local skinId = getCharModel(char)
    return skinId == skinIgnore
end

function isPlayerAdmin(char) -- IGNORE ADMIN
    if not GUI.IgnoreAdmin[0] then
        return false
    end
    local skinId = getCharModel(char)
    return skinId == 217 or skinId == 211
end

function IgnoreDrawFovArma() -- IGNORE ARMA SNIPER
    local weapon = getCurrentCharWeapon(PLAYER_PED)
    return weapon == 34
end

function se.onSetPlayerHealth() -- ANT HS
    if GUI.AntHs[0] then
        freezeCharPosition(PLAYER_PED, true)
        freezeCharPosition(PLAYER_PED, false)
        setPlayerControl(PLAYER_HANDLE, true)
        return false
    end
end

function se.onSetPlayerPos()
    if GUI.AntTraze[0] then -- ANT TRAZER
        return false
    elseif GUI.AntTraze[0] == false then
        return true
    end
end

function EspInforVeiculos() -- ESP INFO VEICULO
    if GUI.EspInfoCar[0] then
        local px, py, pz = getCharCoordinates(PLAYER_PED)
        for _, v in ipairs(getAllVehicles()) do
            if v and isCarOnScreen(v) then
                local carX, carY, carZ = getCarCoordinates(v)
                local dist = getDistanceBetweenCoords3d(px, py, pz, carX, carY, carZ)
                if dist < 150.0 then
                    local carId = getCarModel(v)
                    local nomeModelo = carros[carId - 399] or "DESCONHECIDO"
                    local _, IdVeiculoServer = sampGetVehicleIdByCarHandle(v)
                    local hp = getCarHealth(v)
                    local X, Y = convert3DCoordsToScreen(carX, carY, carZ + 1)
                    local infoText = string.format("%s (%d) \nHP: %.0f", nomeModelo, IdVeiculoServer, hp)
                    renderFontDrawText(FontEspCar, infoText, X, Y, 0xFFFF0000)
                end
            end
        end
    end
end

-- AIMBOT
function obterPosicaoDoOsso(id_char, id_osso)
    local ponteiro_char = ffi.cast("void*", getCharPointer(id_char))
    local posicao_osso = ffi.new("RwV3d[1]")

    gtasa._ZN4CPed15GetBonePositionER5RwV3djb(ponteiro_char, posicao_osso, id_osso, false)

    return posicao_osso[0].x, posicao_osso[0].y, posicao_osso[0].z
end

function obterRotacaoDaCamera()
    local anguloHorizontal = camera_principal.aCams[0].fHorizontalAngle
    local anguloVertical = camera_principal.aCams[0].fVerticalAngle
    return anguloHorizontal, anguloVertical
end

function definirRotacaoDaCamera(anguloHorizontal, anguloVertical)
    camera_principal.aCams[0].fHorizontalAngle = anguloHorizontal
    camera_principal.aCams[0].fVerticalAngle = anguloVertical
end

function converterCoordenadasCartesianasParaEsfericas(posicao)
    local vetor = posicao - vector3d(getActiveCameraCoordinates())
    local comprimento = vetor:length()
    local anguloHorizontal = math.atan2(vetor.y, vetor.x)
    local anguloVertical = math.acos(vetor.z / comprimento)

    if anguloHorizontal > 0 then
        anguloHorizontal = anguloHorizontal - math.pi
    else
        anguloHorizontal = anguloHorizontal + math.pi
    end

    local anguloVerticalFinal = math.pi / 2 - anguloVertical
    return anguloHorizontal, anguloVerticalFinal
end

function obterPosicaoDoMiraNaTela()
    local posicaoX = largura * GUI.LaguraX[0]
    local posicaoY = altura * GUI.AlturaY[0]
    return posicaoX, posicaoY
end

function obterRotacaoDoMira(distancia)
    distancia = distancia or 5
    local posicaoX, posicaoY = obterPosicaoDoMiraNaTela()
    local ponto3D = vector3d(convertScreenCoordsToWorld3D(posicaoX, posicaoY, distancia))
    return converterCoordenadasCartesianasParaEsfericas(ponto3D)
end

function mirarPontoComM16(ponto)
    local anguloHorizontal, anguloVertical = converterCoordenadasCartesianasParaEsfericas(ponto)
    local rotacaoHorizontal, rotacaoVertical = obterRotacaoDaCamera()
    local miraHorizontal, miraVertical = obterRotacaoDoMira()
    local novaRotacaoHorizontal = rotacaoHorizontal + (anguloHorizontal - miraHorizontal)
    local novaRotacaoVertical = rotacaoVertical + (anguloVertical - miraVertical)
    definirRotacaoDaCamera(novaRotacaoHorizontal, novaRotacaoVertical)
end

function mirarPontoComMiraTelescopica(ponto)
    local anguloHorizontal, anguloVertical = converterCoordenadasCartesianasParaEsfericas(ponto)
    definirRotacaoDaCamera(anguloHorizontal, anguloVertical)
end

function obterCharProximoAoCentro(distanciaMaxima)
    local charsProximos = {}
    for _, char in ipairs(getAllChars()) do
        if isCharOnScreen(char) and char ~= PLAYER_PED and not isCharDead(char) then
            local coordX, coordY, coordZ = getCharCoordinates(char)
            local posX, posY = convert3DCoordsToScreen(coordX, coordY, coordZ)
            local distancia = getDistanceBetweenCoords2d(largura / 2 + 3, altura / 2 + 3, posX, posY)

            if isCurrentCharWeapon(PLAYER_PED, 34) then
                distancia = getDistanceBetweenCoords2d(largura / 2, altura / 2, posX, posY)
            end

            if distancia <= tonumber(distanciaMaxima and distanciaMaxima or altura) then
                table.insert(charsProximos, {
                    distancia,
                    char
                })
            end
        end
    end
    if #charsProximos > 0 then
        table.sort(charsProximos, function(a, b)
            return a[1] < b[1]
        end)
        return charsProximos[1][2]
    end
    return nil
end

function Aimbot()
    if GUI.AtivarAimbot[0] and isPlayerArmed() then
        local modoCamera = camera_principal.aCams[0].nMode
        
        if modoCamera ~= 7 and modoCamera ~= 53 then
            return
        end
        
        local distanciaMaxima = math.floor((GUI.DistanciaAimbot[0] - 1) * (200 - 10) / (100 - 1)) + 10
        local suavidadeMaxia = math.floor(100 + (GUI.SuavidadeAimbot[0] - 1) * (250 - 100) / (100 - 1))
        local centroX, centroY = largura / 2, altura / 2
        local maxFovRadius = (GUI.FovAimbot[0] / 100) * 150
        local charProximo = nil
        local menorDistFov = nil
        
        local coordX, coordY, coordZ = getCharCoordinates(PLAYER_PED)
        local myPos = {coordX, coordY, coordZ}

        for _, char in ipairs(getAllChars()) do
            if isCharOnScreen(char) and char ~= PLAYER_PED and not isCharDead(char) then
                if GUI.IgnoreAdmin[0] and isPlayerAdmin(char) then
                    goto continue
                end
                
                if GUI.IgnoreSkin[0] and isPlayerSkin(char) then
                    goto continue
                end

                if GUI.IgnoreAmigos[0] then
                    local result, playerId = sampGetPlayerIdByCharHandle(char)
                    if result then
                        local nomeJogador = sampGetPlayerNickname(playerId)
                        if nomeJogador and IsAmigo(nomeJogador) then
                            goto continue
                        end
                    end
                end
                
                local result, playerId = sampGetPlayerIdByCharHandle(char)
                if result and not isTargetAfkAim(playerId) and not isPlayerInVehicleAim(char) then
                    local posicaoX, posicaoY, posicaoZ = obterPosicaoDoOsso(char, 5)
                    local distanciaTotal = getDistanceBetweenCoords3d(coordX, coordY, coordZ, posicaoX, posicaoY, posicaoZ)
                    if distanciaTotal < distanciaMaxima then
                        local sx, sy = convert3DCoordsToScreen(posicaoX, posicaoY, posicaoZ)
                        if sx and sy then
                            local distFov = math.sqrt((sx - centroX)^2 + (sy - centroY)^2)
                            if distFov <= maxFovRadius * 2.0 then
                                if not menorDistFov or distFov < menorDistFov then
                                    menorDistFov = distFov
                                    charProximo = char
                                end
                            end
                        end
                    end
                end
                ::continue::
            end
        end
        
        if charProximo then
            local alvoX, alvoY, alvoZ = obterPosicaoDoOsso(charProximo, 5)
            local coordX, coordY, coordZ = getCharCoordinates(PLAYER_PED)
            local myPos = {coordX, coordY, coordZ}
            local enPos = {alvoX, alvoY, alvoZ}
            
            local temVisao = true
            if GUI.IgnoreObject[0] then
                temVisao = isLineOfSightClear(myPos[1], myPos[2], myPos[3], enPos[1], enPos[2], enPos[3], true, false, false, true, false, false, false)
            end
            
            if temVisao then
                ponto = vector3d(alvoX, alvoY, alvoZ)
                if modoCamera == 7 then
                    mirarPontoComMiraTelescopica(ponto)
                elseif modoCamera == 53 then
                    local fatorSuavidade = math.max(0.8, GUI.SuavidadeAimbot[0] / 100)
                    local anguloHorizontal, anguloVertical = converterCoordenadasCartesianasParaEsfericas(ponto)
                    local rotacaoHorizontal, rotacaoVertical = obterRotacaoDaCamera()
                    local miraHorizontal, miraVertical = obterRotacaoDoMira()
                    
                    local novaRotacaoHorizontal = rotacaoHorizontal + (anguloHorizontal - miraHorizontal) * fatorSuavidade
                    local novaRotacaoVertical = rotacaoVertical + (anguloVertical - miraVertical) * fatorSuavidade
                    
                    definirRotacaoDaCamera(novaRotacaoHorizontal, novaRotacaoVertical)
                else
                    local fatorSuavidade = math.max(0.8, GUI.SuavidadeAimbot[0] / 100)
                    local anguloHorizontal, anguloVertical = converterCoordenadasCartesianasParaEsfericas(ponto)
                    local rotacaoHorizontal, rotacaoVertical = obterRotacaoDaCamera()
                    local miraHorizontal, miraVertical = obterRotacaoDoMira()
                    
                    local novaRotacaoHorizontal = rotacaoHorizontal + (anguloHorizontal - miraHorizontal) * fatorSuavidade
                    local novaRotacaoVertical = rotacaoVertical + (anguloVertical - miraVertical) * fatorSuavidade
                    
                    definirRotacaoDaCamera(novaRotacaoHorizontal, novaRotacaoVertical)
                end
            end
        end
    end
end

function isTargetAfkAim(playerId) -- IGNORE AFK AIMBOT
    if GUI.IgnoreAfkAim[0] then
        return sampIsPlayerPaused(playerId)
    end
    return false
end

function isPlayerInVehicleAim(charProximo) -- IGNORE VEICULO AIMBOT
    if GUI.IgnoreVeiculo[0] then
        return isCharInAnyCar(charProximo)
    end
    return false
end

function isClearObject(myPos, enPos) -- IGNORE OBJECT AIMBOT
    if GUI.IgnoreObject[0] then
        return isLineOfSightClear(myPos[1], myPos[2], myPos[3], enPos[1], enPos[2], enPos[3], true, false, false, true, false, false, false)
    end
    return true
end

ffi.cdef([[typedef struct RwV3d {float x, y, z;} RwV3d; void _ZN4CPed15GetBonePositionER5RwV3djb(void* thiz, RwV3d* posn, uint32_t bone, bool calledFromCam);]])
-- FIM AIMBOT

function ProAim()
    if GUI.ProAimbot[0] and isWidgetPressed(WIDGET_VC_SHOOT_ALT) and isPlayerArmed() then
        local playerId = GUI.SelecionaPlayerTab[0]
        if playerId >= 0 and playerId <= sampGetMaxPlayerId(true) and sampIsPlayerConnected(playerId) then
            local resultado, manipulador = sampGetCharHandleBySampPlayerId(playerId)
            if resultado and doesCharExist(manipulador) and not isCharDead(manipulador) and manipulador ~= PLAYER_PED then
                if not isTargetAFK(playerId) and not isPlayerInVehicle(playerId) then
                    local minha_posição = {getCharCoordinates(PLAYER_PED)}
                    local direção = getCharHeading(PLAYER_PED)
                    local distância = 2.0
                    local deslocamentoX = distância * math.sin(math.rad(direção))
                    local deslocamentoY = distância * math.cos(math.rad(direção))
                    local novaX = minha_posição[1] + deslocamentoX
                    local novaY = minha_posição[2] + deslocamentoY + 0.5
                    local novaZ = minha_posição[3] - 1
                    setCharCoordinates(manipulador, novaX, novaY, novaZ)
                    setCharHeading(manipulador, direção)
                end
            end
        end
    end
end

function isTargetAFK(playerId) -- IGNORA AFK NO PRO AIM
    return sampIsPlayerPaused(playerId)
end

function isPlayerArmed() -- IGNORA SOCO ATE ARMA 16
    local weapon = getCurrentCharWeapon(PLAYER_PED)
    return weapon > 0 and weapon ~= 16
end

function isPlayerInVehicle(playerId) -- IGNORA JOGADORES EM VEÍCULOS
    local resultado, manipulador = sampGetCharHandleBySampPlayerId(playerId)
    if resultado and doesCharExist(manipulador) then
        return isCharInAnyCar(manipulador)
    end
    return false
end

function TelaEsticada() -- FOV TELA
    if GUI.AtivarTelaEsticada[0] then
        cameraSetLerpFov(GUI.AlterarFovTela[0], 101, 1000, true)
    end
end

function EspLine() -- ESP LINE
    if GUI.EspLine[0] then
        local playerX, playerY, playerZ = getCharCoordinates(PLAYER_PED)
        for playerId = 0, sampGetMaxPlayerId(false) do
            if sampIsPlayerConnected(playerId) then
                local result, playerPed = sampGetCharHandleBySampPlayerId(playerId)
                if result and doesCharExist(playerPed) and isCharOnScreen(playerPed) then

                    local nomeJogador = sampGetPlayerNickname(playerId)
                    local cor = 0xFFFF0000
                    if nomeJogador and IsAmigo(nomeJogador) then
                        cor = 0xFF00FF00
                    end
                    
                    local targetX, targetY, targetZ = getCharCoordinates(playerPed)
                    local distance = getDistanceBetweenCoords3d(playerX, playerY, playerZ, targetX, targetY, targetZ)
                    if distance <= 300 then
                        local lineEndX, lineEndY = convert3DCoordsToScreen(targetX, targetY, targetZ)
                        local lineStartX = largura / 2
                        local lineStartY = 0
                        renderDrawLine(lineStartX, lineStartY, lineEndX, lineEndY, 2 * DPI, cor)
                    end
                end
            end
        end
    end
end

function EspNome()
    if GUI.EspNome[0] then
        if doesCharExist(PLAYER_PED) then
            local jogadorX, jogadorY, jogadorZ = getCharCoordinates(PLAYER_PED)
            for _, personagem in ipairs(getAllChars()) do
                if personagem ~= PLAYER_PED and doesCharExist(personagem) and isCharOnScreen(personagem) and not isCharDead(personagem) then
                    local resultado, idJogador = sampGetPlayerIdByCharHandle(personagem)
                    if resultado then

                        local ossoX, ossoY, ossoZ = obterPosicaoDoOsso(personagem, 5)
                        if not ossoX or not ossoY or not ossoZ then
                            ossoX, ossoY, ossoZ = getCharCoordinates(personagem)
                        end

                        local distanciaTotal = getDistanceBetweenCoords3d(jogadorX, jogadorY, jogadorZ, ossoX, ossoY, ossoZ)

                        if distanciaTotal > 17.9 then
                            local telaX, telaY = convert3DCoordsToScreen(ossoX, ossoY, ossoZ + 0.5)
                            if telaX and telaY then
                                local nomeJogador = sampGetPlayerNickname(idJogador)
                                local texto = string.format("%s (%d)", nomeJogador, idJogador)
                                renderFontDrawText(FontEspNome, texto, telaX - (#texto * 5) * DPI, telaY - 25 * DPI, 0xFFFFFFFF)

                                local vida = sampGetPlayerHealth(idJogador)
                                local colete = sampGetPlayerArmor(idJogador)

                                local larguraBarra = 70 * DPI
                                local alturaBarra = 8 * DPI

                                local larguraVida = (vida / 100) * larguraBarra
                                local larguraColete = (colete / 100) * larguraBarra

                                local posBarraX = telaX - (larguraBarra / 2)
                                local posBarraY = telaY - 2 * DPI

                                renderDrawBoxWithBorder(posBarraX, posBarraY, larguraBarra, alturaBarra, 0xFF300000, 1, 0xFF300000)
                                renderDrawBoxWithBorder(posBarraX, posBarraY, larguraVida, alturaBarra, 0xFFFF0000, 1, 0x00000000)

                                if colete > 0 then
                                    local posColeteY = posBarraY + alturaBarra + 2 * DPI
                                    renderDrawBoxWithBorder(posBarraX, posColeteY, larguraBarra, alturaBarra, 0xFF300000, 1, 0xFF300000)
                                    renderDrawBoxWithBorder(posBarraX, posColeteY, larguraColete, alturaBarra, 0xFFFFFFFF, 1, 0x00000000)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

function EspBox()
    if GUI.EspBox[0] then
        for jogador_id = 0, 999 do
            local handle_personagem, id_personagem = sampGetCharHandleBySampPlayerId(jogador_id)

            if handle_personagem then

                local nomeJogador = sampGetPlayerNickname(jogador_id)
                local cor = 0xFFFF0000
                if nomeJogador and IsAmigo(nomeJogador) then
                    cor = 0xFF00FF00
                end
                
                local coordenadas_personagem = {}
                coordenadas_personagem.x, coordenadas_personagem.y, coordenadas_personagem.z = getCharCoordinates(id_personagem)

                local pontos = {
                    { x = coordenadas_personagem.x + 0.5, y = coordenadas_personagem.y + 0.5, z = coordenadas_personagem.z + 1 },
                    { x = coordenadas_personagem.x + 0.5, y = coordenadas_personagem.y - 0.5, z = coordenadas_personagem.z + 1 },
                    { x = coordenadas_personagem.x - 0.5, y = coordenadas_personagem.y - 0.5, z = coordenadas_personagem.z + 1 },
                    { x = coordenadas_personagem.x - 0.5, y = coordenadas_personagem.y + 0.5, z = coordenadas_personagem.z + 1 },
                    { x = coordenadas_personagem.x + 0.5, y = coordenadas_personagem.y + 0.5, z = coordenadas_personagem.z + 1 },
                    { x = coordenadas_personagem.x - 0.5, y = coordenadas_personagem.y + 0.5, z = coordenadas_personagem.z + 1 },
                    { x = coordenadas_personagem.x - 0.5, y = coordenadas_personagem.y + 0.5, z = coordenadas_personagem.z - 1 },
                    { x = coordenadas_personagem.x - 0.5, y = coordenadas_personagem.y - 0.5, z = coordenadas_personagem.z - 1 },
                    { x = coordenadas_personagem.x - 0.5, y = coordenadas_personagem.y - 0.5, z = coordenadas_personagem.z + 1 },
                    { x = coordenadas_personagem.x - 0.5, y = coordenadas_personagem.y - 0.5, z = coordenadas_personagem.z - 1 },
                    { x = coordenadas_personagem.x + 0.5, y = coordenadas_personagem.y - 0.5, z = coordenadas_personagem.z - 1 },
                    { x = coordenadas_personagem.x + 0.5, y = coordenadas_personagem.y - 0.5, z = coordenadas_personagem.z + 1 },
                    { x = coordenadas_personagem.x + 0.5, y = coordenadas_personagem.y - 0.5, z = coordenadas_personagem.z - 1 },
                    { x = coordenadas_personagem.x + 0.5, y = coordenadas_personagem.y + 0.5, z = coordenadas_personagem.z - 1 },
                    { x = coordenadas_personagem.x - 0.5, y = coordenadas_personagem.y + 0.5, z = coordenadas_personagem.z - 1 },
                    { x = coordenadas_personagem.x + 0.5, y = coordenadas_personagem.y + 0.5, z = coordenadas_personagem.z - 1 }
                }

                local todosPontosNaTela = true
                for _, ponto in ipairs(pontos) do
                    if not isPointOnScreen(ponto.x, ponto.y, ponto.z, 0) then
                        todosPontosNaTela = false
                        break
                    end
                end

                if todosPontosNaTela then
                    for i = 1, #pontos do
                        local proximoIndice = (i % #pontos) + 1
                        local x1, y1 = convert3DCoordsToScreen(pontos[i].x, pontos[i].y, pontos[i].z)
                        local x2, y2 = convert3DCoordsToScreen(pontos[proximoIndice].x, pontos[proximoIndice].y, pontos[proximoIndice].z)
                        renderDrawLine(x1, y1, x2, y2, 2, cor)
                    end
                end
            end
        end
    end
end

function EspSkinId()
    if GUI.EspSkinId[0] then
        for _, ped in ipairs(getAllChars()) do
            if ped ~= playerPed and doesCharExist(ped) and isCharOnScreen(ped) then
                local cx, cy, cz = getCharCoordinates(ped)
                local x, y = convert3DCoordsToScreen(cx, cy, cz)
                renderFontDrawText(FontEspSkinId, string.format("ID DA SKIN: %d", getCharModel(ped)), x, y, 0xFF00FF00)
            end
        end
    end
end

function EspPlataforma()
    if GUI.EspPlataforma[0] then
        local peds = getAllChars()
        for i=2, #peds do
            local _, id = sampGetPlayerIdByCharHandle(peds[i])
            if peds[i] ~= nil and isCharOnScreen(peds[i]) and not sampIsPlayerNpc(id) then
                local x, y, z = getCharCoordinates(peds[i])
                local xs, ys = convert3DCoordsToScreen(x, y, z)
                if players[id] ~= nil then
                    renderFontDrawText(FontPlataforma, players[id], xs - 23, ys, 0xFF32FF16)
                end
            end
        end
    end
end

function EspBoxCar() -- ESP BOX CARRO
    if GUI.EspCarro[0] then
        local playerX, playerY, playerZ = getCharCoordinates(PLAYER_PED)
        local x, y = convert3DCoordsToScreen(playerX, playerY, playerZ)
        local Linha = 2 * DPI

        for _, vehicle in ipairs(getAllVehicles()) do
            if isCarOnScreen(vehicle) then
                local carX, carY, carZ = getCarCoordinates(vehicle)
                local px, py = convert3DCoordsToScreen(carX, carY, carZ)

                local corners = {
                    { x = 1.5, y = 3, z = 1 },
                    { x = 1.5, y = -3, z = 1 },
                    { x = -1.5, y = -3, z = 1 },
                    { x = -1.5, y = 3, z = 1 },
                    { x = 1.5, y = 3, z = -1 },
                    { x = 1.5, y = -3, z = -1 },
                    { x = -1.5, y = -3, z = -1 },
                    { x = -1.5, y = 3, z = -1 }
                }

                local boxCorners = {}
                for _, offset in ipairs(corners) do
                    local worldX, worldY, worldZ = getOffsetFromCarInWorldCoords(vehicle, offset.x, offset.y, offset.z)
                    local screenX, screenY = convert3DCoordsToScreen(worldX, worldY, worldZ)
                    table.insert(boxCorners, { x = screenX, y = screenY })
                end

                for i = 1, 4 do
                    local nextIndex = (i % 4 == 0 and i - 3) or (i + 1)
                    renderDrawLine(boxCorners[i].x, boxCorners[i].y, boxCorners[nextIndex].x, boxCorners[nextIndex].y, Linha, 0xFFFFFFFF)
                    renderDrawLine(boxCorners[i].x, boxCorners[i].y, boxCorners[i + 4].x, boxCorners[i + 4].y, Linha, 0xFFFFFFFF)
                end

                for i = 5, 8 do
                    local nextIndex = (i % 4 == 0 and i - 3) or (i + 1)
                    renderDrawLine(boxCorners[i].x, boxCorners[i].y, boxCorners[nextIndex].x, boxCorners[nextIndex].y, Linha, 0xFFFFFFFF)
                end
                renderDrawLine(x, y, px, py, Linha, 0xFFFFFFFF)
            end
        end
    end
end

function se.onAimSync(playerId, data)
    if GUI.AntCrash[0] then
        for aa, i in pairs(camModes) do
            if data.camMode == i then
                EnviarSmS("{FFFFFF}O Suspeito (ID: ".. playerId ..") Esta tentando te crashar")
                return false
            end
        end
    end
end

-- PLATAFORMA
function se.onUnoccupiedSync(id, data)
    players[id] = "PC"
end

function se.onPlayerSync(id, data)
    if data.keysData == 160 then
        players[id] = "PC"
    end
    if data.specialAction ~= 0 and data.specialAction ~= 1 then
        players[id] = "PC"
    end
    if data.leftRightKeys ~= nil then
        if data.leftRightKeys ~= 128 and data.leftRightKeys ~= 65408 then
            players[id] = "Mobile"
        else
            if players[id] ~= "Mobile" then
                players[id] = "PC"
            end
        end
    end
    if data.upDownKeys ~= nil then
        if data.upDownKeys ~= 128 and data.upDownKeys ~= 65408 then
            players[id] = "Mobile"
        else
            if players[id] ~= "Mobile" then
                players[id] = "PC"
            end
        end
    end
end

function se.onVehicleSync(id, vehid, data)
    if data.leftRightKeys ~= 0 then
        if data.leftRightKeys ~= 128 and data.leftRightKeys ~= 65408 then
            players[id] = "Mobile"
        end
    end
end -- FIM PLATAFORMA

function EnviarSmS(text) -- TAG MESSAGEM
    tag = '{FF0000}[JhowModsOfc]: '
    sampAddChatMessage(tag .. text, -1)
end

function MostrarNotificacao(tipo, estado) -- NOTIFICACAO
    table.insert(notificacoes, {
        texto = tipo..(estado and " (ON)" or " (OFF)"),
        tempo = os.clock() + 5,
        y_offset = 0,
        estado = estado
    })
end

function DesenharNotificacoes()
    local alturaNotificacao = 70 * DPI
    local espacamento = 10 * DPI
    local posX = largura - 550 * DPI
    local posYBase = altura - 150 * DPI
    
    for i = #notificacoes, 1, -1 do
        local notif = notificacoes[i]
        if os.clock() > notif.tempo then
            table.remove(notificacoes, i)
        else
            notif.y_offset = (#notificacoes - i) * (alturaNotificacao + espacamento)
            local posY = posYBase - notif.y_offset
            
            imgui.SetNextWindowPos(imgui.ImVec2(posX, posY))
            imgui.SetNextWindowSize(imgui.ImVec2(230 * DPI, alturaNotificacao))
            imgui.Begin("Notificacao_"..i, nil, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoScrollbar)
            if notif.estado then
                imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.0, 1.0, 0.0, 1.0)) -- Verde
            else
                imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.0, 0.0, 0.0, 1.0)) -- Vermelho
            end
            imgui.Text(notif.texto)
            imgui.PopStyleColor()
            
            imgui.End()
        end
    end
end -- FIM NOTIFICACAO

function CarregarMessagesLog() -- LOG DO SERVER
    if GUI.AtivarMessagesLog[0] then
        for i, MessagesLogString in ipairs(MessagesLog) do
            if FonteLog then
                renderFontDrawText(FonteLog, MessagesLogString, 1320 * DPI, 600 * DPI + (i - 1) * 24, 0xFFff004F)
            end
        end
    end
end

function se.onPlayerJoin(playerId, color, isNpc, nick)
    local MessagesLogString = string.format("{FFFFFF}%s[%d]{80FF00} ENTROU NO SERVER", nick, playerId)
    table.insert(MessagesLog, 1, MessagesLogString)
    if #MessagesLog > 6 then
        table.remove(MessagesLog, #MessagesLog)
    end
end

function se.onPlayerQuit(playerId)
    players[playerId] = nil -- PLATAFORMA

    local nick = sampGetPlayerNickname(playerId)
    local MessagesLogString = string.format("{FFFFFF}%s[%d]{FF0004} SAIU DO SERVER{FFFFFF}", nick, playerId)
    table.insert(MessagesLog, 1, MessagesLogString)
    if #MessagesLog > 6 then
        table.remove(MessagesLog, #MessagesLog)
    end
end -- FIM LOG DO SERVER

function CarregarFoto(path) -- CARREGAR AS FOTOS E OUTROS ARQUIVOS
    local file = io.open(path, "r")
    if not file then return nil end
    local size = file:seek("end")
    file:close()
    return size
end

function Som1() -- SOM 1
    local som1 = PLAYER_PED
    if som1 then
        local x, y, z = getCharCoordinates(som1)
        addOneOffSound(x, y, z, 1139)
    end
end

function Som2() -- SOM 2
    local som2 = PLAYER_PED
    if som2 then
        local x, y, z = getCharCoordinates(som2)
        addOneOffSound(x, y, z, 1085)
    end
end

function Toggle(id, bool) -- BOTAO TOGGLE
    local VerificarToggle = false
    if UltimoTempoAtivo == nil then
        UltimoTempoAtivo = {}
    end
    if UltimoAtivo == nil then
        UltimoAtivo = {}
    end

    local function ImSaturate(f)
        return f < 0.0 and 0.0 or (f > 1.0 and 1.0 or f)
    end

    local p = imgui.GetCursorScreenPos()
    local dl = imgui.GetWindowDrawList()
    local altura = imgui.GetTextLineHeightWithSpacing()
    local largura = altura * 2.21
    local raio = altura * 0.50
    local VELOCIDADE_ANIMACAO = type == 2 and 0.10 or 0.15
    local butPos = imgui.GetCursorPos()

    if imgui.InvisibleButton(id, imgui.ImVec2(largura, altura)) then
        bool[0] = not bool[0]
        VerificarToggle = true
        UltimoTempoAtivo[tostring(id)] = os.clock()
        UltimoAtivo[tostring(id)] = true
    end

    imgui.SetCursorPos(imgui.ImVec2(butPos.x + largura + 8, butPos.y + 2.5))
    imgui.Text(id:gsub('##.+', ''))

    local t = bool[0] and 1.0 or 0.0
    if UltimoAtivo[tostring(id)] then
        local time = os.clock() - UltimoTempoAtivo[tostring(id)]
        if time <= VELOCIDADE_ANIMACAO then
            local t_anim = ImSaturate(time / VELOCIDADE_ANIMACAO)
            t = bool[0] and t_anim or 1.0 - t_anim
        else
            UltimoAtivo[tostring(id)] = false
        end
    end

    local corFundo, corHover
    if GUI.temaAzul[0] then
        corFundo = imgui.ImVec4(0.00, 0.00, 1.00, 1.00)
        corHover = imgui.ImVec4(0.00, 0.00, 1.00, 1.00)
    elseif GUI.temaRosa[0] then
        corFundo = imgui.ImVec4(1.00, 0.20, 0.70, 1.00)
        corHover = imgui.ImVec4(1.00, 0.20, 0.70, 1.00)
    elseif GUI.temaVermelho[0] then
        corFundo = imgui.ImVec4(0.8, 0.0, 0.0, 1.0)
        corHover = imgui.ImVec4(1.0, 0.0, 0.0, 1.0)
    else
        corFundo = imgui.ImVec4(0.8, 0.0, 0.0, 1.0)
        corHover = imgui.ImVec4(1.0, 0.0, 0.0, 1.0)
    end
    local col_bg = bool[0] and imgui.ColorConvertFloat4ToU32(corHover) or imgui.ColorConvertFloat4ToU32(corFundo)
    local col_circle = bool[0] and imgui.ColorConvertFloat4ToU32(imgui.ImVec4(0.0, 1.0, 0.0, 1.0)) or imgui.ColorConvertFloat4ToU32(imgui.ImVec4(1.0, 1.0, 1.0, 1.0))
    
    dl:AddRectFilled(p, imgui.ImVec2(p.x + largura, p.y + altura), col_bg, altura * 0.5)
    dl:AddCircleFilled(imgui.ImVec2(p.x + raio + t * (largura - raio * 2.0), p.y + raio), raio - 1.5, col_circle, 30)
    imgui.SetCursorPos(imgui.ImVec2(butPos.x, butPos.y + altura + 5))

    return VerificarToggle
end -- FIM BOTAO TOGGLE

function Slider(id, value, min, max, width, format) -- BOTAO SLIDE
    local VerificarSlider = false
    local DPI = imgui.GetIO().FontGlobalScale
    local p = imgui.GetCursorScreenPos()
    local dl = imgui.GetWindowDrawList()
    local altura = imgui.GetTextLineHeightWithSpacing() * 0.8 * DPI
    local largura = (width or 250) * DPI
    local raio = altura * 0.8
    format = format or "%.0f%%"

    local t = (value[0] - min) / (max - min)
    t = t < 0 and 0 or (t > 1 and 1 or t)
    local porcentagem = t * 100

    imgui.SetCursorScreenPos(imgui.ImVec2(p.x, p.y))
    imgui.Text(id:gsub('##.+', ''))

    local textWidthEstimate = imgui.GetFontSize() * 6 * DPI
    imgui.SetCursorScreenPos(imgui.ImVec2(p.x + textWidthEstimate, p.y))

    local sliderStart = imgui.ImVec2(p.x + textWidthEstimate, p.y)
    if imgui.InvisibleButton(id, imgui.ImVec2(largura, altura)) then
        local mousePos = imgui.GetMousePos()
        local relativeX = mousePos.x - sliderStart.x
        local newT = relativeX / largura
        newT = newT < 0 and 0 or (newT > 1 and 1 or newT)
        value[0] = min + newT * (max - min)
        VerificarSlider = true
    end

    if imgui.IsItemActive() and imgui.IsMouseDragging(0) then
        local mousePos = imgui.GetMousePos()
        local relativeX = mousePos.x - sliderStart.x
        local newT = relativeX / largura
        newT = newT < 0 and 0 or (newT > 1 and 1 or newT)
        value[0] = min + newT * (max - min)
        VerificarSlider = true
    end

    imgui.SetCursorScreenPos(imgui.ImVec2(sliderStart.x + largura + 30 * DPI, p.y))

    local displayText
    if format == "%.0f%%" then
        displayText = string.format(format, porcentagem)
    else
        displayText = string.format(format, value[0])
    end
    imgui.Text(displayText)

    local col_bg = imgui.ColorConvertFloat4ToU32(imgui.ImVec4(0.3, 0.3, 0.3, 1.0))
    local col_fill
    local col_handle = imgui.ColorConvertFloat4ToU32(imgui.ImVec4(1.0, 1.0, 1.0, 1.0))

    if GUI.temaAzul[0] then
        col_fill = imgui.ColorConvertFloat4ToU32(imgui.ImVec4(0.00, 0.00, 1.00, 1.00))
    elseif GUI.temaRosa[0] then
        col_fill = imgui.ColorConvertFloat4ToU32(imgui.ImVec4(1.00, 0.20, 0.70, 1.00))
    elseif GUI.temaVermelho[0] then
        col_fill = imgui.ColorConvertFloat4ToU32(imgui.ImVec4(1.0, 0.0, 0.0, 1.0))
    else
        col_fill = imgui.ColorConvertFloat4ToU32(imgui.ImVec4(1.0, 0.0, 0.0, 1.0))
    end

    dl:AddRectFilled(sliderStart, imgui.ImVec2(sliderStart.x + largura, sliderStart.y + altura), col_bg, altura * 0.5)
    dl:AddRectFilled(sliderStart, imgui.ImVec2(sliderStart.x + largura * t, sliderStart.y + altura), col_fill, altura * 0.5)

    local handlePosX = sliderStart.x + largura * t
    dl:AddCircleFilled(imgui.ImVec2(handlePosX, sliderStart.y + altura / 2), raio, col_handle, 30)
    dl:AddRect(sliderStart, imgui.ImVec2(sliderStart.x + largura, sliderStart.y + altura), imgui.ColorConvertFloat4ToU32(imgui.ImVec4(1.0, 1.0, 1.0, 0.5)), altura * 0.5)

    imgui.SetCursorScreenPos(imgui.ImVec2(p.x, p.y + altura + 8 * DPI))

    return VerificarSlider
end -- FIM BOTAO SLIDE

function TemaVermelho()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4

    colors[clr.Border] = ImVec4(1.00, 0.00, 0.00, 1.00)
    colors[clr.Separator] = ImVec4(1.00, 0.00, 0.00, 1.00)
    colors[clr.WindowBg] = ImVec4(0.05, 0.05, 0.05, 1.00)
    colors[clr.FrameBg] = ImVec4(1.00, 0.00, 0.00, 1.00)
    colors[clr.TitleBg] = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.TitleBgActive] = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.Button] = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.ButtonHovered] = ImVec4(0.20, 0.20, 0.20, 1.00)
    colors[clr.ButtonActive] = ImVec4(0.15, 0.15, 0.15, 1.00)
    colors[clr.CheckMark] = ImVec4(0.00, 1.00, 0.00, 1.00)
end

function TemaAzul()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4

    colors[clr.Border] = ImVec4(0.00, 0.00, 1.00, 1.00)
    colors[clr.Separator] = ImVec4(0.00, 0.00, 1.00, 1.00)
    colors[clr.WindowBg] = ImVec4(0.05, 0.05, 0.10, 1.00)
    colors[clr.FrameBg] = ImVec4(0.00, 0.00, 1.00, 1.00)
    colors[clr.TitleBg] = ImVec4(0.00, 0.00, 0.50, 0.80)
    colors[clr.TitleBgActive] = ImVec4(0.00, 0.00, 0.70, 1.00)
    colors[clr.Button] = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.ButtonHovered] = ImVec4(0.20, 0.20, 0.20, 1.00)
    colors[clr.ButtonActive] = ImVec4(0.15, 0.15, 0.15, 1.00)
    colors[clr.CheckMark] = ImVec4(0.00, 1.00, 0.00, 1.00)
end

function TemaRosa()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4

    colors[clr.Border] = ImVec4(1.00, 0.20, 0.70, 1.00)
    colors[clr.Separator] = ImVec4(1.00, 0.20, 0.70, 1.00)
    colors[clr.WindowBg] = ImVec4(0.08, 0.05, 0.08, 1.00)
    colors[clr.FrameBg] = ImVec4(1.00, 0.20, 0.70, 1.00)
    colors[clr.TitleBg] = ImVec4(0.60, 0.00, 0.35, 0.80)
    colors[clr.TitleBgActive] = ImVec4(0.80, 0.00, 0.50, 1.00)
    colors[clr.Button] = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.ButtonHovered] = ImVec4(1.00, 0.40, 0.80, 0.40)
    colors[clr.ButtonActive] = ImVec4(0.90, 0.10, 0.60, 0.60)
    colors[clr.CheckMark] = ImVec4(1.00, 0.60, 0.90, 1.00)
end
