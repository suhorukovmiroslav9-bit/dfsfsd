--[[
Strip UI (бело-голубой интерфейс с анимациями, локализацией и функциями)
Версия: 2.1
Исправления: переработаны FreeCam и Fly функции, исправлена локализация вкладок, улучшен интерфейс
]]

-- ========= СЛУЖБЫ =========
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local SoundService = game:GetService("SoundService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = Workspace.CurrentCamera

-- ========= НАСТРОЙКИ ТЕМЫ =========
local Theme = {
    Bg = Color3.fromRGB(245, 249, 255),
    Card = Color3.fromRGB(230, 240, 255),
    Accent = Color3.fromRGB(70, 145, 255),
    Accent2 = Color3.fromRGB(140, 185, 255),
    Text = Color3.fromRGB(20, 40, 80),
    Muted = Color3.fromRGB(120, 140, 170),
    Success = Color3.fromRGB(50, 185, 120),
    Danger = Color3.fromRGB(230, 80, 80),
}

-- ========= ГЛОБАЛЬНЫЕ ПЕРЕМЕННЫЕ ДЛЯ ФУНКЦИЙ =========
local Aimbot = {
    Enabled = false,
    FOV = 50,
    Target = nil,
    Circle = nil
}

local Wallhack = {
    Enabled = false,
    Highlights = {}
}

local FreeCam = {
    Enabled = false,
    Camera = nil,
    Speed = 10,
    Connection = nil
}

local Fly = {
    Enabled = false,
    BodyVelocity = nil,
    Speed = 25,
    Connection = nil
}

local Noclip = {
    Enabled = false,
    Connection = nil
}

local Follow = {
    Enabled = false,
    Target = nil,
    Connection = nil
}

local AvoidPlayers = {
    Enabled = false,
    Connection = nil
}

local Invisible = {
    Enabled = false,
    OriginalTransparency = {}
}

-- ========= УТИЛИТЫ =========
local function tween(obj, time, props, style, dir)
    local t = TweenService:Create(obj, TweenInfo.new(time, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
    t:Play()
    return t
end

local function makeCorner(radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 12)
    return c
end

local function makePadding(p)
    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, p)
    pad.PaddingBottom = UDim.new(0, p)
    pad.PaddingLeft = UDim.new(0, p)
    pad.PaddingRight = UDim.new(0, p)
    return pad
end

local function centerOnScreen(frame)
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.Position = UDim2.fromScale(0.5, 0.5)
end

local function makeShadow(parent)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://5028857084"
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(24, 24, 276, 276)
    shadow.ImageTransparency = 0.2
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.Size = UDim2.fromScale(1, 1)
    shadow.ZIndex = parent.ZIndex - 1
    shadow.Parent = parent
    shadow.Position = UDim2.new(0, -12, 0, -12)
    shadow.Size = UDim2.new(1, 24, 1, 24)
    return shadow
end

local function makeScroll(container)
    local sc = Instance.new("ScrollingFrame")
    sc.BackgroundTransparency = 1
    sc.BorderSizePixel = 0
    sc.Size = UDim2.fromScale(1, 1)
    sc.CanvasSize = UDim2.new(0, 0, 0, 0)
    sc.ScrollBarThickness = 6
    sc.ScrollBarImageColor3 = Theme.Accent
    sc.ScrollBarImageTransparency = 0
    sc.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sc.Parent = container
    return sc
end

local function playSound(id)
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://" .. id
    sound.Parent = SoundService
    sound:Play()
    game:GetService("Debris"):AddItem(sound, 5)
end

-- ========= ЛОКАЛИЗАЦИЯ =========
local LANGUAGES = { "ru", "en", "es", "zh" }
local L = {
    ru = {
        title = "Strip UI",
        chooseLang = "Выберите язык интерфейса",
        botCheck = "Подтвердите, что вы не бот",
        botTask = "Нажмите 1 → 2 → 3 по порядку",
        tabFunctions = "ФУНКЦИИ",
        tabHelp = "ПОМОЩЬ",
        tabUpdates = "ОБНОВЛЕНИЯ",
        aiTitle = "Помощник ИИ (выберите готовый вопрос ниже)",
        q1 = "Как скрывать/показывать интерфейс?",
        a1 = "Нажмите Левый Alt. Панель можно перетаскивать мышью за верхнюю область.",
        q2 = "Как сменить язык?",
        a2 = "Откройте экран выбора языков (кнопка «Сменить язык» в заголовке) и нажмите на нужный флаг.",
        q3 = "Как работает таймер?",
        a3 = "Введите секунды и нажмите «Старт». По окончании появится уведомление.",
        updatesTitle = "История изменений",
        timer = "Таймер (сек.)",
        start = "Старт",
        stop = "Стоп",
        running = "Идёт отсчёт…",
        done = "Таймер завершён!",
        demoOnly = "Функции активированы. Используйте осторожно.",
        functionsInfo = "Включите функции с помощью переключателей ниже.",
        changeLang = "Сменить язык",
        aim = "Aim",
        wallhack = "WallHack",
        freecam = "FreeCam",
        fly = "Fly",
        jumphack = "JumpHack",
        speedhack = "SpeedHack",
        collision = "Collision",
        noclip = "Noclip",
        teleport = "Teleport",
        walk = "Walk",
        run = "Run",
        invisible = "Invisible",
        selectPlayer = "Выберите игрока",
        teleportTo = "Телепортироваться к",
        follow = "Следовать за",
        stopFollow = "Остановить следование",
        player = "Игрок",
        mouse = "Мышь",
        value = "Значение",
        enabled = "Включено",
        disabled = "Выключено",
        clickToTeleport = "Нажмите ЛКМ чтобы телепортироваться",
        teleportCancelled = "Телепортация отменена"
    },
    en = {
        title = "Strip UI",
        chooseLang = "Choose interface language",
        botCheck = "Prove you are not a bot",
        botTask = "Click 1 → 2 → 3 in order",
        tabFunctions = "FUNCTIONS",
        tabHelp = "HELP",
        tabUpdates = "UPDATES",
        aiTitle = "AI Assistant (pick a preset question below)",
        q1 = "How to hide/show the UI?",
        a1 = "Press Left Alt. You can drag the window by its top bar.",
        q2 = "How to change language?",
        a2 = "Open language selection (the \"Change Language\" button) and click a flag.",
        q3 = "How does the timer work?",
        a3 = "Enter seconds and press Start. You'll see a notification once it ends.",
        updatesTitle = "Changelog",
        timer = "Timer (sec)",
        start = "Start",
        stop = "Stop",
        running = "Counting…",
        done = "Timer finished!",
        demoOnly = "Functions activated. Use with caution.",
        functionsInfo = "Enable functions using the switches below.",
        changeLang = "Change Language",
        aim = "Aim",
        wallhack = "WallHack",
        freecam = "FreeCam",
        fly = "Fly",
        jumphack = "JumpHack",
        speedhack = "SpeedHack",
        collision = "Collision",
        noclip = "Noclip",
        teleport = "Teleport",
        walk = "Walk",
        run = "Run",
        invisible = "Invisible",
        selectPlayer = "Select player",
        teleportTo = "Teleport to",
        follow = "Follow",
        stopFollow = "Stop following",
        player = "Player",
        mouse = "Mouse",
        value = "Value",
        enabled = "Enabled",
        disabled = "Disabled",
        clickToTeleport = "Click LMB to teleport",
        teleportCancelled = "Teleport cancelled"
    },
    es = {
        title = "Strip UI",
        chooseLang = "Elige el idioma de la interfaz",
        botCheck = "Demuestra que no eres un bot",
        botTask = "Haz clic 1 → 2 → 3 en orden",
        tabFunctions = "FUNCIONES",
        tabHelp = "AYUDA",
        tabUpdates = "ACTUALIZACIONES",
        aiTitle = "Asistente IA (elige una pregunta predefinida abajo)",
        q1 = "¿Cómo oculto/muestro la interfaz?",
        a1 = "Pulsa Alt izquierdo. Puedes arrastrar la ventana por la barra superior.",
        q2 = "¿Cómo cambio el idioma?",
        a2 = "Abre la selección de idioma (botón \"Cambiar idioma\") y pulsa una bandera.",
        q3 = "¿Cómo funciona el temporizador?",
        a3 = "Introduce segundos y pulsa Iniciar. Verás un aviso al terminar.",
        updatesTitle = "Registro de cambios",
        timer = "Temporizador (seg)",
        start = "Iniciar",
        stop = "Parar",
        running = "Contando…",
        done = "¡Temporizador terminado!",
        demoOnly = "Funciones activadas. Usa con precaución.",
        functionsInfo = "Activa funciones usando los interruptores abajo.",
        changeLang = "Cambiar idioma",
        aim = "Aim",
        wallhack = "WallHack",
        freecam = "FreeCam",
        fly = "Fly",
        jumphack = "JumpHack",
        speedhack = "SpeedHack",
        collision = "Collision",
        noclip = "Noclip",
        teleport = "Teleport",
        walk = "Walk",
        run = "Run",
        invisible = "Invisible",
        selectPlayer = "Seleccionar jugador",
        teleportTo = "Teletransportarse a",
        follow = "Seguir",
        stopFollow = "Dejar de seguir",
        player = "Jugador",
        mouse = "Ratón",
        value = "Valor",
        enabled = "Activado",
        disabled = "Desactivado",
        clickToTeleport = "Haz clic LMB para teletransportarte",
        teleportCancelled = "Teletransporte cancelado"
    },
    zh = {
        title = "Strip UI",
        chooseLang = "选择界面语言",
        botCheck = "请证明你不是机器人",
        botTask = "按顺序点击 1 → 2 → 3",
        tabFunctions = "功能",
        tabHelp = "帮助",
        tabUpdates = "更新",
        aiTitle = "AI 助手（从下方预设问题中选择）",
        q1 = "如何隐藏/显示界面？",
        a1 = "按下左 Alt。你可以拖动顶部栏移动窗口。",
        q2 = "如何切换语言？",
        a2 = "打开语言选择（\"切换语言\"按钮）并点击国旗。",
        q3 = "计时器如何使用？",
        a3 = "输入秒数并点击开始。结束时会提示。",
        updatesTitle = "更新日志",
        timer = "计时器（秒）",
        start = "开始",
        stop = "停止",
        running = "计时中…",
        done = "计时结束！",
        demoOnly = "功能已激活。请谨慎使用。",
        functionsInfo = "使用下方开关启用功能。",
        changeLang = "切换语言",
        aim = "Aim",
        wallhack = "WallHack",
        freecam = "FreeCam",
        fly = "Fly",
        jumphack = "JumpHack",
        speedhack = "SpeedHack",
        collision = "Collision",
        noclip = "Noclip",
        teleport = "Teleport",
        walk = "Walk",
        run = "Run",
        invisible = "Invisible",
        selectPlayer = "选择玩家",
        teleportTo = "传送到",
        follow = "跟随",
        stopFollow = "停止跟随",
        player = "玩家",
        mouse = "鼠标",
        value = "值",
        enabled = "已启用",
        disabled = "已禁用",
        clickToTeleport = "点击左键传送",
        teleportCancelled = "传送已取消"
    }
}
local currentLang = "ru"
local function T(key) return L[currentLang][key] or ("{"..key.."}") end

-- ========= ГЛОБАЛЬНЫЕ КОНТЕЙНЕРЫ =========
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "StripUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.IgnoreGuiInset = true
screenGui.Parent = CoreGui

-- ========= ФОНОВЫЕ ЭЛЕМЕНТЫ (логотип) =========
local bg = Instance.new("Frame")
bg.Name = "Background"
bg.Size = UDim2.fromScale(1, 1)
bg.BackgroundTransparency = 1
bg.Parent = screenGui

local bgLogo = Instance.new("TextLabel")
bgLogo.BackgroundTransparency = 1
bgLogo.Text = "Strip UI"
bgLogo.Font = Enum.Font.GothamBold
bgLogo.TextTransparency = 0.92
bgLogo.TextColor3 = Theme.Text
bgLogo.TextScaled = true
bgLogo.Size = UDim2.new(0.6, 0, 0.2, 0)
bgLogo.Position = UDim2.new(0.2,0,0.4,0)
bgLogo.Parent = bg

local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0.0, Theme.Accent),
    ColorSequenceKeypoint.new(0.5, Theme.Accent2),
    ColorSequenceKeypoint.new(1.0, Theme.Accent)
}
gradient.Rotation = 0
gradient.Parent = bgLogo

-- плавное «дыхание» логотипа
task.spawn(function()
    while bgLogo.Parent do
        tween(bgLogo, 2.2, {TextTransparency = 0.95})
        task.wait(2.2)
        tween(bgLogo, 2.2, {TextTransparency = 0.90})
        task.wait(2.2)
    end
end)

-- ========= УНИВЕРСАЛЬНОЕ ОКНО =========
local root = Instance.new("Frame")
root.Name = "Root"
root.BackgroundColor3 = Theme.Card
root.Size = UDim2.new(0, 600, 0, 450) -- Более компактный размер
centerOnScreen(root)
root.Parent = screenGui
makeCorner(16).Parent = root
makeShadow(root)

local topBar = Instance.new("Frame")
topBar.BackgroundTransparency = 1
topBar.Size = UDim2.new(1, -24, 0, 40)
topBar.Position = UDim2.new(0, 12, 0, 8)
topBar.Parent = root

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextColor3 = Theme.Text
title.TextScaled = true
title.Text = T("title")
title.Size = UDim2.new(0.5, 0, 1, 0)
title.Position = UDim2.new(0, 0, 0, 0)
title.Parent = topBar

local changeLangBtn = Instance.new("TextButton")
changeLangBtn.Text = T("changeLang")
changeLangBtn.Font = Enum.Font.GothamSemibold
changeLangBtn.TextScaled = true
changeLangBtn.TextColor3 = Color3.new(1,1,1)
changeLangBtn.BackgroundColor3 = Theme.Accent
changeLangBtn.Size = UDim2.new(0, 160, 1, -8)
changeLangBtn.Position = UDim2.new(1, -160, 0, 4)
makeCorner(12).Parent = changeLangBtn
changeLangBtn.Parent = topBar

-- перетаскивание
local dragging, dragStart, startPos = false, nil, nil
topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true; dragStart = input.Position; startPos = root.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
topBar.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        root.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- скрытие на Левый Alt
local hidden = false
local function toggleUI()
    hidden = not hidden
    if hidden then
        tween(root, 0.25, {Size = UDim2.new(0, 600, 0, 0), BackgroundTransparency = 1})
        tween(bgLogo, 0.25, {TextTransparency = 0.98})
    else
        tween(root, 0.25, {Size = UDim2.new(0, 600, 0, 450), BackgroundTransparency = 0})
        tween(bgLogo, 0.25, {TextTransparency = 0.92})
    end
end
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.LeftAlt then
        toggleUI()
    end
end)

-- ========= СТРАНИЦА 1: ВЫБОР ЯЗЫКА =========
local pageLang = Instance.new("Frame")
pageLang.BackgroundTransparency = 1
pageLang.Size = UDim2.new(1, -24, 1, -60)
pageLang.Position = UDim2.new(0, 12, 0, 52)
pageLang.Parent = root

local langTitle = Instance.new("TextLabel")
langTitle.BackgroundTransparency = 1
langTitle.Font = Enum.Font.GothamBold
langTitle.TextColor3 = Theme.Text
langTitle.TextScaled = true
langTitle.Text = T("chooseLang")
langTitle.Size = UDim2.new(1, 0, 0, 36)
langTitle.Parent = pageLang

local grid = Instance.new("Frame")
grid.BackgroundTransparency = 1
grid.Size = UDim2.new(1, 0, 1, -44)
grid.Position = UDim2.new(0, 0, 0, 40)
grid.Parent = pageLang

local gridLayout = Instance.new("UIGridLayout")
gridLayout.CellPadding = UDim2.new(0, 12, 0, 12)
gridLayout.CellSize = UDim2.new(0.5, -18, 0.5, -18)
gridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
gridLayout.VerticalAlignment = Enum.VerticalAlignment.Center
gridLayout.Parent = grid

local languagesMeta = {
    {code="ru", flag="🇷🇺", name="Русский"},
    {code="en", flag="🇬🇧", name="English"},
    {code="es", flag="🇪🇸", name="Español"},
    {code="zh", flag="🇨🇳", name="中文"},
}

local selectedLang = nil
local function makeLangTile(meta)
    local btn = Instance.new("TextButton")
    btn.BackgroundColor3 = Theme.Card
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.Parent = grid
    makeCorner(12).Parent = btn

    local flag = Instance.new("TextLabel")
    flag.BackgroundTransparency = 1
    flag.Text = meta.flag
    flag.Font = Enum.Font.SourceSansBold
    flag.TextScaled = true
    flag.Size = UDim2.new(1, 0, 0.6, 0)
    flag.Parent = btn

    local name = Instance.new("TextLabel")
    name.BackgroundTransparency = 1
    name.Text = meta.name
    name.TextColor3 = Theme.Text
    name.Font = Enum.Font.GothamSemibold
    name.TextScaled = true
    name.Size = UDim2.new(1, 0, 0.3, 0)
    name.Position = UDim2.new(0, 0, 0.6, 0)
    name.Parent = btn

    btn.MouseEnter:Connect(function()
        tween(btn, 0.15, {Size = btn.Size + UDim2.new(0, 6, 0, 6)})
    end)
    btn.MouseLeave:Connect(function()
        tween(btn, 0.15, {Size = UDim2.new(0, gridLayout.CellSize.X.Offset, 0, gridLayout.CellSize.Y.Offset)})
    end)
    btn.MouseButton1Click:Connect(function()
        selectedLang = meta.code
        currentLang = selectedLang
        updateAllTexts()
        notify(T("demoOnly"), Theme.Accent)
        showPage(2)
    end)
    return btn
end

for _, meta in ipairs(languagesMeta) do
    makeLangTile(meta)
end

-- Кнопка «сменить язык» сверху
changeLangBtn.MouseButton1Click:Connect(function()
    showPage(1)
end)

-- ========= СТРАНИЦА 2: ПРОВЕРКА «НЕ БОТ» =========
local pageBot = Instance.new("Frame")
pageBot.BackgroundTransparency = 1
pageBot.Size = pageLang.Size
pageBot.Position = pageLang.Position
pageBot.Visible = false
pageBot.Parent = root

local botBox = Instance.new("Frame")
botBox.Size = UDim2.new(0, 360, 0, 180)
centerOnScreen(botBox)
botBox.Parent = pageBot
botBox.BackgroundColor3 = Theme.Card
makeCorner(16).Parent = botBox
makeShadow(botBox)
local pad = makePadding(12); pad.Parent = botBox

botTitle = Instance.new("TextLabel")
botTitle.BackgroundTransparency = 1
botTitle.Font = Enum.Font.GothamBold
botTitle.TextColor3 = Theme.Text
botTitle.TextScaled = true
botTitle.Text = T("botCheck")
botTitle.Size = UDim2.new(1, 0, 0, 32)
botTitle.Parent = botBox

botTask = Instance.new("TextLabel")
botTask.BackgroundTransparency = 1
botTask.Font = Enum.Font.Gotham
botTask.TextColor3 = Theme.Muted
botTask.TextScaled = true
botTask.Text = T("botTask")
botTask.Size = UDim2.new(1, 0, 0, 24)
botTask.Position = UDim2.new(0, 0, 0, 36)
botTask.Parent = botBox

local btnWrap = Instance.new("Frame")
btnWrap.BackgroundTransparency = 1
btnWrap.Size = UDim2.new(1, 0, 0, 100)
btnWrap.Position = UDim2.new(0, 0, 0, 68)
btnWrap.Parent = botBox

local uiList = Instance.new("UIListLayout")
uiList.Padding = UDim.new(0, 6)
uiList.FillDirection = Enum.FillDirection.Horizontal
uiList.HorizontalAlignment = Enum.HorizontalAlignment.Center
uiList.VerticalAlignment = Enum.VerticalAlignment.Center
uiList.Parent = btnWrap

local order, progress = {1,2,3}, 1
local function mkNumButton(n)
    local b = Instance.new("TextButton")
    b.Text = tostring(n)
    b.TextScaled = true
    b.Font = Enum.Font.GothamBold
    b.TextColor3 = Color3.new(1,1,1)
    b.AutoButtonColor = false
    b.BackgroundColor3 = Theme.Accent
    b.Size = UDim2.new(0, 90, 0, 90)
    makeCorner(12).Parent = b
    b.Parent = btnWrap
    b.MouseButton1Click:Connect(function()
        if n == order[progress] then
            progress += 1
            tween(b, 0.15, {BackgroundColor3 = Theme.Success})
            if progress > #order then
                notify("OK!", Theme.Success)
                task.wait(0.25)
                showPage(3)
            end
        else
            tween(b, 0.15, {BackgroundColor3 = Theme.Danger})
            task.delay(0.25, function() tween(b, 0.25, {BackgroundColor3 = Theme.Accent}) end)
            progress = 1
        end
    end)
end
mkNumButton(1); mkNumButton(2); mkNumButton(3)

-- ========= СТРАНИЦА 3: ОСНОВНОЙ ИНТЕРФЕЙС =========
local pageMain = Instance.new("Frame")
pageMain.BackgroundTransparency = 1
pageMain.Size = pageLang.Size
pageMain.Position = pageLang.Position
pageMain.Visible = false
pageMain.Parent = root

-- Вкладки
local tabs = Instance.new("Frame")
tabs.BackgroundTransparency = 1
tabs.Size = UDim2.new(1, 0, 0, 36)
tabs.Parent = pageMain

local function mkTab(text)
    local b = Instance.new("TextButton")
    b.Text = text
    b.TextScaled = true
    b.Font = Enum.Font.GothamSemibold
    b.TextColor3 = Theme.Text
    b.AutoButtonColor = false
    b.BackgroundColor3 = Theme.Card
    b.Size = UDim2.new(0, 180, 1, 0)
    makeCorner(12).Parent = b
    b.Parent = tabs
    return b
end

tabFunctions = mkTab(T("tabFunctions"))
tabHelp = mkTab(T("tabHelp"))
tabUpdates = mkTab(T("tabUpdates"))

tabFunctions.Position = UDim2.new(0, 0, 0, 0)
tabHelp.Position = UDim2.new(0, 188, 0, 0)
tabUpdates.Position = UDim2.new(0, 376, 0, 0)

local body = Instance.new("Frame")
body.BackgroundColor3 = Theme.Card
body.Size = UDim2.new(1, 0, 1, -44)
body.Position = UDim2.new(0, 0, 0, 44)
makeCorner(16).Parent = body
makeShadow(body)
body.Parent = pageMain
local bodyPad = makePadding(10); bodyPad.Parent = body

local function setActiveTab(btn)
    for _,child in ipairs(tabs:GetChildren()) do
        if child:IsA("TextButton") then
            tween(child, 0.15, {BackgroundColor3 = Theme.Card, TextColor3 = Theme.Text})
        end
    end
    tween(btn, 0.15, {BackgroundColor3 = Theme.Accent, TextColor3 = Color3.new(1,1,1)})
end

-- Страницы вкладок
local tabPages = {}
local function mkBodyPage()
    local p = Instance.new("Frame")
    p.BackgroundTransparency = 1
    p.Visible = false
    p.Size = UDim2.fromScale(1,1)
    p.Parent = body
    return p
end

-- ==== Вкладка "Функции" ====
local pageFunctions = mkBodyPage()
tabPages[tabFunctions] = pageFunctions

local functionsScroll = makeScroll(pageFunctions)
local list = Instance.new("UIListLayout")
list.Padding = UDim.new(0, 6)
list.FillDirection = Enum.FillDirection.Vertical
list.SortOrder = Enum.SortOrder.LayoutOrder
list.Parent = functionsScroll

local function mkSection(titleText)
    local card = Instance.new("Frame")
    card.BackgroundColor3 = Theme.Bg
    card.Size = UDim2.new(1, -8, 0, 60)
    makeCorner(10).Parent = card
    card.Parent = functionsScroll
    local pad = makePadding(8); pad.Parent = card

    local lbl = Instance.new("TextLabel")
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextColor3 = Theme.Text
    lbl.TextScaled = true
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = titleText
    lbl.Size = UDim2.new(1, -100, 1, 0)
    lbl.Parent = card

    local toggle = Instance.new("TextButton")
    toggle.Text = "OFF"
    toggle.Font = Enum.Font.GothamBold
    toggle.TextScaled = true
    toggle.TextColor3 = Color3.new(1,1,1)
    toggle.AutoButtonColor = false
    toggle.BackgroundColor3 = Theme.Danger
    toggle.Size = UDim2.new(0, 90, 1, -8)
    toggle.Position = UDim2.new(1, -96, 0, 4)
    makeCorner(10).Parent = toggle
    toggle.Parent = card

    local state = false
    toggle.MouseButton1Click:Connect(function()
        state = not state
        toggle.Text = state and "ON" or "OFF"
        tween(toggle, 0.15, {BackgroundColor3 = state and Theme.Success or Theme.Danger})
        tween(card, 0.15, {BackgroundColor3 = state and Theme.Card or Theme.Bg})
        
        -- Активация функций
        if titleText == T("aim") then
            toggleAim(state)
        elseif titleText == T("wallhack") then
            toggleWallhack(state)
        elseif titleText == T("freecam") then
            toggleFreeCam(state)
        elseif titleText == T("fly") then
            toggleFly(state)
        elseif titleText == T("collision") then
            toggleCollision(state)
        elseif titleText == T("noclip") then
            toggleNoclip(state)
        elseif titleText == T("run") then
            toggleAvoidPlayers(state)
        elseif titleText == T("invisible") then
            toggleInvisible(state)
        end
    end)
    return card
end

local function mkInputSection(titleText, placeholder)
    local card = Instance.new("Frame")
    card.BackgroundColor3 = Theme.Bg
    card.Size = UDim2.new(1, -8, 0, 60)
    makeCorner(10).Parent = card
    card.Parent = functionsScroll
    local pad = makePadding(8); pad.Parent = card

    local lbl = Instance.new("TextLabel")
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextColor3 = Theme.Text
    lbl.TextScaled = true
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = titleText
    lbl.Size = UDim2.new(1, -180, 1, 0)
    lbl.Parent = card

    local box = Instance.new("TextBox")
    box.Font = Enum.Font.Gotham
    box.PlaceholderText = placeholder or "0"
    box.Text = ""
    box.TextScaled = true
    box.TextColor3 = Theme.Text
    box.BackgroundColor3 = Color3.fromRGB(255,255,255)
    box.Size = UDim2.new(0, 160, 1, -8)
    box.Position = UDim2.new(1, -168, 0, 4)
    makeCorner(10).Parent = box
    box.Parent = card

    box.FocusLost:Connect(function(enter)
        if titleText == T("jumphack") then
            setJumpHeight(tonumber(box.Text) or 0)
        elseif titleText == T("speedhack") then
            setWalkSpeed(tonumber(box.Text) or 0)
        end
        notify("✔ "..titleText.." = "..box.Text, Theme.Accent2)
    end)
    return card
end

local function mkTeleportSection()
    local card = Instance.new("Frame")
    card.BackgroundColor3 = Theme.Bg
    card.Size = UDim2.new(1, -8, 0, 100)
    makeCorner(10).Parent = card
    card.Parent = functionsScroll
    local pad = makePadding(8); pad.Parent = card

    local lbl = Instance.new("TextLabel")
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextColor3 = Theme.Text
    lbl.TextScaled = true
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = T("teleport")
    lbl.Size = UDim2.new(1, 0, 0, 24)
    lbl.Parent = card

    local playerBtn = Instance.new("TextButton")
    playerBtn.Text = T("player")
    playerBtn.Font = Enum.Font.GothamBold
    playerBtn.TextScaled = true
    playerBtn.TextColor3 = Color3.new(1,1,1)
    playerBtn.AutoButtonColor = false
    playerBtn.BackgroundColor3 = Theme.Accent
    playerBtn.Size = UDim2.new(0, 120, 0, 32)
    playerBtn.Position = UDim2.new(0, 0, 0, 32)
    makeCorner(10).Parent = playerBtn
    playerBtn.Parent = card

    local mouseBtn = Instance.new("TextButton")
    mouseBtn.Text = T("mouse")
    mouseBtn.Font = Enum.Font.GothamBold
    mouseBtn.TextScaled = true
    mouseBtn.TextColor3 = Color3.new(1,1,1)
    mouseBtn.AutoButtonColor = false
    mouseBtn.BackgroundColor3 = Theme.Accent
    mouseBtn.Size = UDim2.new(0, 120, 0, 32)
    mouseBtn.Position = UDim2.new(0, 128, 0, 32)
    makeCorner(10).Parent = mouseBtn
    mouseBtn.Parent = card

    playerBtn.MouseButton1Click:Connect(function()
        showPlayerListForTeleport()
    end)

    mouseBtn.MouseButton1Click:Connect(function()
        teleportToMouse()
    end)
end

local function mkWalkSection()
    local card = Instance.new("Frame")
    card.BackgroundColor3 = Theme.Bg
    card.Size = UDim2.new(1, -8, 0, 70)
    makeCorner(10).Parent = card
    card.Parent = functionsScroll
    local pad = makePadding(8); pad.Parent = card

    local lbl = Instance.new("TextLabel")
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextColor3 = Theme.Text
    lbl.TextScaled = true
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = T("walk")
    lbl.Size = UDim2.new(1, 0, 0, 24)
    lbl.Parent = card

    local selectBtn = Instance.new("TextButton")
    selectBtn.Text = T("selectPlayer")
    selectBtn.Font = Enum.Font.GothamBold
    selectBtn.TextScaled = true
    selectBtn.TextColor3 = Color3.new(1,1,1)
    selectBtn.AutoButtonColor = false
    selectBtn.BackgroundColor3 = Theme.Accent
    selectBtn.Size = UDim2.new(0, 160, 0, 32)
    selectBtn.Position = UDim2.new(0, 0, 0, 32)
    makeCorner(10).Parent = selectBtn
    selectBtn.Parent = card

    selectBtn.MouseButton1Click:Connect(function()
        showPlayerListForFollow()
    end)
end

-- Информация
local info = Instance.new("TextLabel")
info.BackgroundTransparency = 1
info.Font = Enum.Font.Gotham
info.TextColor3 = Theme.Muted
info.TextScaled = true
info.Text = T("demoOnly")
info.Size = UDim2.new(1, -8, 0, 22)
info.Parent = functionsScroll

infoFunctions = Instance.new("TextLabel")
infoFunctions.BackgroundTransparency = 1
infoFunctions.Font = Enum.Font.Gotham
infoFunctions.TextColor3 = Theme.Text
infoFunctions.TextScaled = true
infoFunctions.TextXAlignment = Enum.TextXAlignment.Left
infoFunctions.Text = T("functionsInfo")
infoFunctions.Size = UDim2.new(1, -8, 0, 22)
infoFunctions.Parent = functionsScroll

-- Список функций
mkSection(T("aim"))
mkSection(T("wallhack"))
mkSection(T("freecam"))
mkSection(T("fly"))
mkInputSection(T("jumphack"), "50")
mkInputSection(T("speedhack"), "16")
mkSection(T("collision"))
mkSection(T("noclip"))
mkTeleportSection()
mkWalkSection()
mkSection(T("run"))
mkSection(T("invisible"))

-- Таймер
local timerCard = Instance.new("Frame")
timerCard.BackgroundColor3 = Theme.Bg
timerCard.Size = UDim2.new(1, -8, 0, 80)
makeCorner(10).Parent = timerCard
timerCard.Parent = functionsScroll
local tpad = makePadding(8); tpad.Parent = timerCard

timerLabel = Instance.new("TextLabel")
timerLabel.BackgroundTransparency = 1
timerLabel.Font = Enum.Font.GothamSemibold
timerLabel.TextColor3 = Theme.Text
timerLabel.TextScaled = true
timerLabel.TextXAlignment = Enum.TextXAlignment.Left
timerLabel.Text = T("timer")
timerLabel.Size = UDim2.new(0.5, 0, 1, 0)
timerLabel.Parent = timerCard

local timerBox = Instance.new("TextBox")
timerBox.Font = Enum.Font.Gotham
timerBox.PlaceholderText = "30"
timerBox.Text = ""
timerBox.TextScaled = true
timerBox.TextColor3 = Theme.Text
timerBox.BackgroundColor3 = Color3.fromRGB(255,255,255)
timerBox.Size = UDim2.new(0, 100, 1, -8)
timerBox.Position = UDim2.new(0.5, 6, 0, 4)
makeCorner(10).Parent = timerBox
timerBox.Parent = timerCard

startBtn = Instance.new("TextButton")
startBtn.Text = T("start")
startBtn.Font = Enum.Font.GothamBold
startBtn.TextScaled = true
startBtn.TextColor3 = Color3.new(1,1,1)
startBtn.AutoButtonColor = false
startBtn.BackgroundColor3 = Theme.Success
startBtn.Size = UDim2.new(0, 80, 1, -8)
startBtn.Position = UDim2.new(0.5, 112, 0, 4)
makeCorner(10).Parent = startBtn
startBtn.Parent = timerCard

stopBtn = Instance.new("TextButton")
stopBtn.Text = T("stop")
stopBtn.Font = Enum.Font.GothamBold
stopBtn.TextScaled = true
stopBtn.TextColor3 = Color3.new(1,1,1)
stopBtn.AutoButtonColor = false
stopBtn.BackgroundColor3 = Theme.Danger
stopBtn.Size = UDim2.new(0, 80, 1, -8)
stopBtn.Position = UDim2.new(0.5, 198, 0, 4)
makeCorner(10).Parent = stopBtn
stopBtn.Parent = timerCard

local timerConn, timerEndAt
local runningLbl = Instance.new("TextLabel")
runningLbl.BackgroundTransparency = 1
runningLbl.Font = Enum.Font.Gotham
runningLbl.TextColor3 = Theme.Muted
runningLbl.TextScaled = true
runningLbl.Text = ""
runningLbl.Size = UDim2.new(1, -8, 0, 20)
runningLbl.Parent = functionsScroll

local function setRunningText(on)
    runningLbl.Text = on and T("running") or ""
end

local function stopTimer()
    if timerConn then timerConn:Disconnect() end
    timerConn = nil
    timerEndAt = nil
    setRunningText(false)
end

local function startTimer(seconds)
    stopTimer()
    if seconds <= 0 then return end
    timerEndAt = os.clock() + seconds
    setRunningText(true)
    timerConn = RunService.RenderStepped:Connect(function()
        local rem = math.max(0, math.floor(timerEndAt - os.clock()))
        timerBox.Text = tostring(rem)
        if rem <= 0 then
            stopTimer()
            notify(T("done"), Theme.Success)
            playSound(138080944)
        end
    end)
end

startBtn.MouseButton1Click:Connect(function()
    local n = tonumber(timerBox.Text) or tonumber(timerBox.PlaceholderText) or 30
    startTimer(n)
end)
stopBtn.MouseButton1Click:Connect(function()
    stopTimer()
end)

-- ==== Вкладка "Помощь" ====
local pageHelp = mkBodyPage()
tabPages[tabHelp] = pageHelp

aiTitle = Instance.new("TextLabel")
aiTitle.BackgroundTransparency = 1
aiTitle.Font = Enum.Font.GothamSemibold
aiTitle.TextColor3 = Theme.Text
aiTitle.TextScaled = true
aiTitle.TextXAlignment = Enum.TextXAlignment.Left
aiTitle.Text = T("aiTitle")
aiTitle.Size = UDim2.new(1, -8, 0, 28)
aiTitle.Parent = pageHelp

local helpScroll = makeScroll(pageHelp)
helpScroll.Position = UDim2.new(0,0,0,32)
helpScroll.Size = UDim2.new(1,0,1,-32)

local helpList = Instance.new("UIListLayout")
helpList.Padding = UDim.new(0, 6)
helpList.FillDirection = Enum.FillDirection.Vertical
helpList.SortOrder = Enum.SortOrder.LayoutOrder
helpList.Parent = helpScroll

local function mkQA(q, a)
    local card = Instance.new("Frame")
    card.BackgroundColor3 = Theme.Bg
    card.Size = UDim2.new(1, -8, 0, 70)
    makeCorner(10).Parent = card
    card.Parent = helpScroll
    local pad = makePadding(8); pad.Parent = card

    local btn = Instance.new("TextButton")
    btn.AutoButtonColor = false
    btn.Text = q
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamSemibold
    btn.TextColor3 = Theme.Text
    btn.BackgroundTransparency = 1
    btn.Size = UDim2.new(1, 0, 0.5, -4)
    btn.Parent = card

    local ans = Instance.new("TextLabel")
    ans.BackgroundTransparency = 1
    ans.Text = ""
    ans.TextScaled = true
    ans.Font = Enum.Font.Gotham
    ans.TextColor3 = Theme.Muted
    ans.TextWrapped = true
    ans.Size = UDim2.new(1, 0, 0.5, 0)
    ans.Position = UDim2.new(0,0,0.5,4)
    ans.Parent = card

    btn.MouseButton1Click:Connect(function()
        if ans.Text == "" then
            ans.Text = a
            tween(card, 0.15, {BackgroundColor3 = Theme.Card})
        else
            ans.Text = ""
            tween(card, 0.15, {BackgroundColor3 = Theme.Bg})
        end
    end)
end

helpQ1 = {Text=T("q1")}
helpQ2 = {Text=T("q2")}
helpQ3 = {Text=T("q3")}
mkQA(T("q1"), T("a1"))
mkQA(T("q2"), T("a2"))
mkQA(T("q3"), T("a3"))

-- ==== Вкладка "Обновления" ====
local pageUpdates = mkBodyPage()
tabPages[tabUpdates] = pageUpdates

updatesTitle = Instance.new("TextLabel")
updatesTitle.BackgroundTransparency = 1
updatesTitle.Font = Enum.Font.GothamSemibold
updatesTitle.TextColor3 = Theme.Text
updatesTitle.TextScaled = true
updatesTitle.TextXAlignment = Enum.TextXAlignment.Left
updatesTitle.Text = T("updatesTitle")
updatesTitle.Size = UDim2.new(1, -8, 0, 28)
updatesTitle.Parent = pageUpdates

local updatesScroll = makeScroll(pageUpdates)
updatesScroll.Position = UDim2.new(0,0,0,32)
updatesScroll.Size = UDim2.new(1,0,1,-32)

local updatesList = Instance.new("UIListLayout")
updatesList.Padding = UDim.new(0, 6)
updatesList.FillDirection = Enum.FillDirection.Vertical
updatesList.SortOrder = Enum.SortOrder.LayoutOrder
updatesList.Parent = updatesScroll

local function addUpdateEntry(text)
    local item = Instance.new("TextLabel")
    item.BackgroundColor3 = Theme.Bg
    item.TextColor3 = Theme.Text
    item.Font = Enum.Font.Gotham
    item.TextScaled = true
    item.TextXAlignment = Enum.TextXAlignment.Left
    item.Size = UDim2.new(1, -8, 0, 40)
    item.Text = ("[%s] %s"):format(os.date("%Y-%m-%d %H:%M:%S"), text)
    makeCorner(8).Parent = item
    item.Parent = updatesScroll
end

-- Записи обновлений
addUpdateEntry("Инициализация интерфейса, локализация (RU/EN/ES/中文), анимации, логотип, прокрутка.")
addUpdateEntry("Добавлены вкладки: Функции/Помощь/Обновления. Таймер и «не бот» проверка.")
addUpdateEntry("Скрытие на Левый Alt, перетаскивание, бело-голубая тема с градиентом.")
addUpdateEntry("Реализованы все функции: Aim, WallHack, FreeCam, Fly, JumpHack, SpeedHack, Collision, Noclip, Teleport, Walk, Run, Invisible.")
addUpdateEntry("Исправлены функции FreeCam и Fly, улучшен интерфейс.")

-- ========= РЕАЛИЗАЦИЯ ФУНКЦИЙ =========

-- Aim функция
function toggleAim(enabled)
    Aimbot.Enabled = enabled
    
    if enabled then
        -- Создаем круг прицеливания
        if not Aimbot.Circle then
            local circle = Drawing.new("Circle")
            circle.Visible = true
            circle.Transparency = 1
            circle.Color = Color3.fromRGB(255, 0, 0)
            circle.Thickness = 2
            circle.NumSides = 64
            circle.Radius = Aimbot.FOV
            circle.Filled = false
            circle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            Aimbot.Circle = circle
        end
        
        -- Подключаем обработчик для aimbot
        RunService.RenderStepped:Connect(function()
            if not Aimbot.Enabled then return end
            
            -- Обновляем позицию круга
            Aimbot.Circle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            
            -- Ищем ближайшую цель
            local closest = nil
            local closestDistance = math.huge
            
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local humanoid = player.Character:FindFirstChild("Humanoid")
                    local head = player.Character:FindFirstChild("Head")
                    
                    if humanoid and humanoid.Health > 0 and head then
                        local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                        
                        if onScreen then
                            local mousePos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                            local targetPos = Vector2.new(screenPos.X, screenPos.Y)
                            local distance = (mousePos - targetPos).Magnitude
                            
                            if distance < Aimbot.FOV and distance < closestDistance then
                                closest = player
                                closestDistance = distance
                            end
                        end
                    end
                end
            end
            
            -- Автоматическое наведение
            if closest and closest.Character then
                local head = closest.Character:FindFirstChild("Head")
                if head then
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, head.Position)
                end
            end
        end)
    else
        -- Удаляем круг прицеливания
        if Aimbot.Circle then
            Aimbot.Circle:Remove()
            Aimbot.Circle = nil
        end
    end
end

-- WallHack функция
function toggleWallhack(enabled)
    Wallhack.Enabled = enabled
    
    if enabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local highlight = Instance.new("Highlight")
                highlight.Name = "WallhackHighlight"
                highlight.FillColor = Color3.fromRGB(255, 0, 0)
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.FillTransparency = 0.5
                highlight.OutlineTransparency = 0
                highlight.Parent = player.Character
                
                -- Добавляем текст с именем игрока
                local billboard = Instance.new("BillboardGui")
                billboard.Name = "WallhackName"
                billboard.Size = UDim2.new(0, 200, 0, 50)
                billboard.StudsOffset = Vector3.new(0, 3, 0)
                billboard.AlwaysOnTop = true
                billboard.Parent = player.Character
                
                local text = Instance.new("TextLabel")
                text.Size = UDim2.new(1, 0, 1, 0)
                text.BackgroundTransparency = 1
                text.Text = player.Name
                text.TextColor3 = Color3.fromRGB(255, 255, 255)
                text.TextScaled = true
                text.Parent = billboard
                
                Wallhack.Highlights[player] = {highlight, billboard}
            end
        end
        
        -- Обработчик для новых игроков
        Players.PlayerAdded:Connect(function(player)
            player.CharacterAdded:Connect(function(character)
                if Wallhack.Enabled then
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "WallhackHighlight"
                    highlight.FillColor = Color3.fromRGB(255, 0, 0)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.FillTransparency = 0.5
                    highlight.OutlineTransparency = 0
                    highlight.Parent = character
                    
                    local billboard = Instance.new("BillboardGui")
                    billboard.Name = "WallhackName"
                    billboard.Size = UDim2.new(0, 200, 0, 50)
                    billboard.StudsOffset = Vector3.new(0, 3, 0)
                    billboard.AlwaysOnTop = true
                    billboard.Parent = character
                    
                    local text = Instance.new("TextLabel")
                    text.Size = UDim2.new(1, 0, 1, 0)
                    text.BackgroundTransparency = 1
                    text.Text = player.Name
                    text.TextColor3 = Color3.fromRGB(255, 255, 255)
                    text.TextScaled = true
                    text.Parent = billboard
                    
                    Wallhack.Highlights[player] = {highlight, billboard}
                end
            end)
        end)
    else
        -- Удаляем все подсветки
        for player, objects in pairs(Wallhack.Highlights) do
            if objects[1] then objects[1]:Destroy() end
            if objects[2] then objects[2]:Destroy() end
        end
        Wallhack.Highlights = {}
    end
end

-- FreeCam функция (полностью переработанная)
function toggleFreeCam(enabled)
    FreeCam.Enabled = enabled
    
    if enabled then
        -- Сохраняем оригинальную камеру
        FreeCam.OriginalCamera = Camera.CFrame
        FreeCam.OriginalSubject = Camera.CameraSubject
        FreeCam.OriginalType = Camera.CameraType
        
        -- Создаем виртуальную камеру
        FreeCam.Camera = Instance.new("Part")
        FreeCam.Camera.Anchored = true
        FreeCam.Camera.Transparency = 1
        FreeCam.Camera.CanCollide = false
        FreeCam.Camera.CFrame = Camera.CFrame
        FreeCam.Camera.Parent = Workspace
        
        Camera.CameraSubject = FreeCam.Camera
        Camera.CameraType = Enum.CameraType.Scriptable
        
        -- Переменные для управления камерой
        local cameraAngleX = 0
        local cameraAngleY = 0
        
        -- Обработчик движения камеры
        FreeCam.Connection = RunService.RenderStepped:Connect(function()
            if not FreeCam.Enabled or not FreeCam.Camera then
                return
            end
            
            -- Получаем ввод с клавиатуры
            local moveVector = Vector3.new(0, 0, 0)
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                moveVector = moveVector + Vector3.new(0, 0, -1)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                moveVector = moveVector + Vector3.new(0, 0, 1)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                moveVector = moveVector + Vector3.new(-1, 0, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                moveVector = moveVector + Vector3.new(1, 0, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.E) then
                moveVector = moveVector + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Q) then
                moveVector = moveVector + Vector3.new(0, -1, 0)
            end
            
            -- Ускорение при Shift
            local speed = FreeCam.Speed
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                speed = speed * 3
            end
            
            -- Вращение камеры мышью
            local delta = UserInputService:GetMouseDelta()
            cameraAngleX = cameraAngleX - delta.X * 0.003
            cameraAngleY = math.clamp(cameraAngleY - delta.Y * 0.003, -math.pi/2, math.pi/2)
            
            -- Создаем поворот камеры
            local cameraRotation = CFrame.Angles(0, cameraAngleX, 0) * CFrame.Angles(cameraAngleY, 0, 0)
            
            -- Преобразуем вектор движения в мировые координаты
            local worldMoveVector = cameraRotation:VectorToWorldSpace(moveVector)
            
            -- Обновляем позицию камеры
            FreeCam.Camera.CFrame = cameraRotation + FreeCam.Camera.Position + (worldMoveVector * speed * 0.1)
            
            -- Обновляем направление камеры
            Camera.CFrame = CFrame.new(FreeCam.Camera.Position, FreeCam.Camera.Position + cameraRotation.LookVector)
        end)
    else
        -- Отключаем обработчик
        if FreeCam.Connection then
            FreeCam.Connection:Disconnect()
            FreeCam.Connection = nil
        end
        
        -- Восстанавливаем оригинальную камеру
        if FreeCam.OriginalCamera then
            Camera.CFrame = FreeCam.OriginalCamera
        end
        Camera.CameraSubject = FreeCam.OriginalSubject or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid"))
        Camera.CameraType = FreeCam.OriginalType or Enum.CameraType.Custom
        
        -- Удаляем виртуальную камеру
        if FreeCam.Camera then
            FreeCam.Camera:Destroy()
            FreeCam.Camera = nil
        end
    end
end

-- Fly функция (полностью переработанная)
function toggleFly(enabled)
    Fly.Enabled = enabled
    
    if enabled then
        local character = LocalPlayer.Character
        if not character then return end
        
        local humanoid = character:FindFirstChild("Humanoid")
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoid or not humanoidRootPart then return end
        
        -- Сохраняем оригинальные значения
        Fly.OriginalGravity = Workspace.Gravity
        Workspace.Gravity = 0
        
        -- Создаем BodyVelocity для полета
        Fly.BodyVelocity = Instance.new("BodyVelocity")
        Fly.BodyVelocity.Velocity = Vector3.new(0, 0, 0)
        Fly.BodyVelocity.MaxForce = Vector3.new(10000, 10000, 10000)
        Fly.BodyVelocity.Parent = humanoidRootPart
        
        -- Отключаем гравитацию для персонажа
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
            end
        end
        
        -- Обработчик управления полетом
        Fly.Connection = RunService.RenderStepped:Connect(function()
            if not Fly.Enabled or not Fly.BodyVelocity or not humanoidRootPart then
                return
            end
            
            -- Движение
            local moveVector = Vector3.new(0, 0, 0)
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                moveVector = moveVector + humanoidRootPart.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                moveVector = moveVector - humanoidRootPart.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                moveVector = moveVector - humanoidRootPart.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                moveVector = moveVector + humanoidRootPart.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.E) then
                moveVector = moveVector + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Q) then
                moveVector = moveVector + Vector3.new(0, -1, 0)
            end
            
            -- Ускорение при Shift
            local speed = Fly.Speed
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                speed = speed * 2
            end
            
            Fly.BodyVelocity.Velocity = moveVector.Unit * speed
        end)
    else
        -- Отключаем обработчик
        if Fly.Connection then
            Fly.Connection:Disconnect()
            Fly.Connection = nil
        end
        
        -- Восстанавливаем гравитацию
        if Fly.OriginalGravity then
            Workspace.Gravity = Fly.OriginalGravity
        end
        
        -- Удаляем BodyVelocity
        if Fly.BodyVelocity then
            Fly.BodyVelocity:Destroy()
            Fly.BodyVelocity = nil
        end
        
        -- Восстанавливаем физические свойства
        local character = LocalPlayer.Character
        if character then
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CustomPhysicalProperties = nil
                end
            end
            
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
            end
        end
    end
end

-- JumpHack функция
function setJumpHeight(height)
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    humanoid.JumpPower = height > 0 and height or 50
end

-- SpeedHack функция
function setWalkSpeed(speed)
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    humanoid.WalkSpeed = speed > 0 and speed or 16
end

-- Collision функция
function toggleCollision(enabled)
    local character = LocalPlayer.Character
    if not character then return end
    
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = not enabled
        end
    end
    
    -- Отключаем коллизию только со стенами (но не с полом)
    if enabled then
        Workspace.DescendantAdded:Connect(function(descendant)
            if descendant:IsA("BasePart") and descendant.Name ~= "Baseplate" then
                descendant.CanCollide = false
            end
        end)
        
        for _, part in ipairs(Workspace:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "Baseplate" then
                part.CanCollide = false
            end
        end
    else
        -- Восстанавливаем коллизию
        for _, part in ipairs(Workspace:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

-- Noclip функция
function toggleNoclip(enabled)
    Noclip.Enabled = enabled
    
    if enabled then
        local function noclipLoop()
            if Noclip.Enabled and LocalPlayer.Character then
                for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end
        
        Noclip.Connection = RunService.Stepped:Connect(noclipLoop)
    else
        if Noclip.Connection then
            Noclip.Connection:Disconnect()
            Noclip.Connection = nil
        end
        
        -- Восстанавливаем коллизию
        if LocalPlayer.Character then
            for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end

-- Teleport функция (к игроку)
function showPlayerListForTeleport()
    local teleportGui = Instance.new("ScreenGui")
    teleportGui.Name = "TeleportGui"
    teleportGui.Parent = CoreGui
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 400)
    frame.Position = UDim2.new(0.5, -150, 0.5, -200)
    frame.BackgroundColor3 = Theme.Card
    makeCorner(12).Parent = frame
    makeShadow(frame)
    frame.Parent = teleportGui
    
    local title = Instance.new("TextLabel")
    title.Text = T("selectPlayer")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundTransparency = 1
    title.TextColor3 = Theme.Text
    title.Font = Enum.Font.GothamBold
    title.TextScaled = true
    title.Parent = frame
    
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -20, 1, -60)
    scroll.Position = UDim2.new(0, 10, 0, 50)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 6
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.Parent = frame
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 5)
    layout.Parent = scroll
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local btn = Instance.new("TextButton")
            btn.Text = player.Name
            btn.Size = UDim2.new(1, 0, 0, 40)
            btn.BackgroundColor3 = Theme.Accent
            btn.TextColor3 = Color3.new(1, 1, 1)
            btn.Font = Enum.Font.GothamSemibold
            makeCorner(8).Parent = btn
            btn.Parent = scroll
            
            btn.MouseButton1Click:Connect(function()
                if player.Character then
                    local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
                    if humanoidRootPart then
                        LocalPlayer.Character:MoveTo(humanoidRootPart.Position)
                        notify(T("teleportTo") .. " " .. player.Name, Theme.Success)
                    end
                end
                teleportGui:Destroy()
            end)
        end
    end
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Text = "X"
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 5)
    closeBtn.BackgroundColor3 = Theme.Danger
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Font = Enum.Font.GothamBold
    makeCorner(15).Parent = closeBtn
    closeBtn.Parent = frame
    
    closeBtn.MouseButton1Click:Connect(function()
        teleportGui:Destroy()
    end)
end

-- Teleport функция (к курсору) - улучшенная версия
function teleportToMouse()
    local teleportIndicator = Instance.new("Part")
    teleportIndicator.Shape = Enum.PartType.Ball
    teleportIndicator.Size = Vector3.new(2, 2, 2)
    teleportIndicator.Material = Enum.Material.Neon
    teleportIndicator.Color = Color3.fromRGB(0, 255, 0)
    teleportIndicator.Anchored = true
    teleportIndicator.CanCollide = false
    teleportIndicator.Parent = Workspace
    
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = teleportIndicator
    
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.Text = T("clickToTeleport")
    text.TextColor3 = Color3.fromRGB(255, 255, 255)
    text.TextScaled = true
    text.Parent = billboard
    
    notify(T("clickToTeleport"), Theme.Accent)
    
    local connection
    connection = RunService.RenderStepped:Connect(function()
        local hit = Mouse.Hit
        if hit then
            teleportIndicator.Position = hit.Position + Vector3.new(0, 1, 0)
        end
    end)
    
    local clickConnection
    clickConnection = UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local hit = Mouse.Hit
            if hit then
                LocalPlayer.Character:MoveTo(hit.Position)
                notify("Teleported to mouse position", Theme.Success)
            end
            connection:Disconnect()
            clickConnection:Disconnect()
            teleportIndicator:Destroy()
        elseif input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.Escape then
            connection:Disconnect()
            clickConnection:Disconnect()
            teleportIndicator:Destroy()
            notify(T("teleportCancelled"), Theme.Danger)
        end
    end)
end

-- Walk функция (следование за игроком)
function showPlayerListForFollow()
    local followGui = Instance.new("ScreenGui")
    followGui.Name = "FollowGui"
    followGui.Parent = CoreGui
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 400)
    frame.Position = UDim2.new(0.5, -150, 0.5, -200)
    frame.BackgroundColor3 = Theme.Card
    makeCorner(12).Parent = frame
    makeShadow(frame)
    frame.Parent = followGui
    
    local title = Instance.new("TextLabel")
    title.Text = T("selectPlayer")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundTransparency = 1
    title.TextColor3 = Theme.Text
    title.Font = Enum.Font.GothamBold
    title.TextScaled = true
    title.Parent = frame
    
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -20, 1, -60)
    scroll.Position = UDim2.new(0, 10, 0, 50)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 6
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.Parent = frame
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 5)
    layout.Parent = scroll
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local btn = Instance.new("TextButton")
            btn.Text = player.Name
            btn.Size = UDim2.new(1, 0, 0, 40)
            btn.BackgroundColor3 = Theme.Accent
            btn.TextColor3 = Color3.new(1, 1, 1)
            btn.Font = Enum.Font.GothamSemibold
            makeCorner(8).Parent = btn
            btn.Parent = scroll
            
            btn.MouseButton1Click:Connect(function()
                Follow.Target = player
                toggleFollow(true)
                notify(T("follow") .. " " .. player.Name, Theme.Success)
                followGui:Destroy()
            end)
        end
    end
    
    local stopBtn = Instance.new("TextButton")
    stopBtn.Text = T("stopFollow")
    stopBtn.Size = UDim2.new(1, -20, 0, 40)
    stopBtn.Position = UDim2.new(0, 10, 1, -50)
    stopBtn.BackgroundColor3 = Theme.Danger
    stopBtn.TextColor3 = Color3.new(1, 1, 1)
    stopBtn.Font = Enum.Font.GothamBold
    makeCorner(8).Parent = stopBtn
    stopBtn.Parent = frame
    
    stopBtn.MouseButton1Click:Connect(function()
        toggleFollow(false)
        followGui:Destroy()
    end)
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Text = "X"
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 5)
    closeBtn.BackgroundColor3 = Theme.Danger
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Font = Enum.Font.GothamBold
    makeCorner(15).Parent = closeBtn
    closeBtn.Parent = frame
    
    closeBtn.MouseButton1Click:Connect(function()
        followGui:Destroy()
    end)
end

function toggleFollow(enabled)
    if enabled then
        if Follow.Connection then
            Follow.Connection:Disconnect()
        end
        
        Follow.Connection = RunService.Heartbeat:Connect(function()
            if Follow.Target and Follow.Target.Character then
                local targetRoot = Follow.Target.Character:FindFirstChild("HumanoidRootPart")
                local localRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                
                if targetRoot and localRoot then
                    local distance = (targetRoot.Position - localRoot.Position).Magnitude
                    
                    if distance > 5 then
                        localRoot.CFrame = CFrame.new(localRoot.Position, targetRoot.Position)
                        
                        local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
                        if humanoid then
                            humanoid:MoveTo(targetRoot.Position)
                        end
                    end
                end
            end
        end)
    else
        if Follow.Connection then
            Follow.Connection:Disconnect()
            Follow.Connection = nil
        end
        Follow.Target = nil
    end
end

-- Run функция (избегание игроков)
function toggleAvoidPlayers(enabled)
    AvoidPlayers.Enabled = enabled
    
    if enabled then
        if AvoidPlayers.Connection then
            AvoidPlayers.Connection:Disconnect()
        end
        
        AvoidPlayers.Connection = RunService.Heartbeat:Connect(function()
            local character = LocalPlayer.Character
            if not character then return end
            
            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
            local humanoid = character:FindFirstChild("Humanoid")
            
            if not humanoidRootPart or not humanoid then return end
            
            local avoidVector = Vector3.new(0, 0, 0)
            
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
                    if targetRoot then
                        local distance = (targetRoot.Position - humanoidRootPart.Position).Magnitude
                        
                        if distance < 20 then
                            local direction = (humanoidRootPart.Position - targetRoot.Position).Unit
                            avoidVector = avoidVector + (direction * (20 - distance))
                        end
                    end
                end
            end
            
            if avoidVector.Magnitude > 0 then
                humanoid:MoveTo(humanoidRootPart.Position + avoidVector.Unit * 5)
            end
        end)
    else
        if AvoidPlayers.Connection then
            AvoidPlayers.Connection:Disconnect()
            AvoidPlayers.Connection = nil
        end
    end
end

-- Invisible функция
function toggleInvisible(enabled)
    Invisible.Enabled = enabled
    
    local character = LocalPlayer.Character
    if not character then return end
    
    if enabled then
        -- Сохраняем оригинальную прозрачность
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                Invisible.OriginalTransparency[part] = part.Transparency
                part.Transparency = 1
            elseif part:IsA("Decal") then
                Invisible.OriginalTransparency[part] = part.Transparency
                part.Transparency = 1
            end
        end
        
        -- Обработчик для новых частей
        character.DescendantAdded:Connect(function(descendant)
            if Invisible.Enabled then
                if descendant:IsA("BasePart") or descendant:IsA("Decal") then
                    Invisible.OriginalTransparency[descendant] = descendant.Transparency
                    descendant.Transparency = 1
                end
            end
        end)
    else
        -- Восстанавливаем прозрачность
        for part, transparency in pairs(Invisible.OriginalTransparency) do
            if part.Parent then
                part.Transparency = transparency
            end
        end
        Invisible.OriginalTransparency = {}
    end
end

-- ========= ОБНОВЛЕНИЕ ТЕКСТОВ ПРИ СМЕНЕ ЯЗЫКА =========
function updateAllTexts()
    title.Text = T("title")
    changeLangBtn.Text = T("changeLang")
    langTitle.Text = T("chooseLang")
    botTitle.Text = T("botCheck")
    botTask.Text = T("botTask")
    tabFunctions.Text = T("tabFunctions")
    tabHelp.Text = T("tabHelp")
    tabUpdates.Text = T("tabUpdates")
    aiTitle.Text = T("aiTitle")
    timerLabel.Text = T("timer")
    startBtn.Text = T("start")
    stopBtn.Text = T("stop")
    updatesTitle.Text = T("updatesTitle")
    infoFunctions.Text = T("functionsInfo")
    
    -- Обновляем текст в вопросах помощи
    for _, child in ipairs(helpScroll:GetChildren()) do
        if child:IsA("Frame") then
            local questionBtn = child:FindFirstChildWhichIsA("TextButton")
            local answerLbl = child:FindFirstChildWhichIsA("TextLabel")
            
            if questionBtn then
                if questionBtn.Text == L.ru.q1 then questionBtn.Text = T("q1")
                elseif questionBtn.Text == L.ru.q2 then questionBtn.Text = T("q2")
                elseif questionBtn.Text == L.ru.q3 then questionBtn.Text = T("q3") end
            end
            
            if answerLbl and answerLbl.Text ~= "" then
                if answerLbl.Text == L.ru.a1 then answerLbl.Text = T("a1")
                elseif answerLbl.Text == L.ru.a2 then answerLbl.Text = T("a2")
                elseif answerLbl.Text == L.ru.a3 then answerLbl.Text = T("a3") end
            end
        end
    end
end

-- ========= ПЕРЕКЛЮЧЕНИЕ СТРАНИЦ/ВКЛАДОК =========
local pages = {pageLang, pageBot, pageMain}
function showPage(i)
    for idx, p in ipairs(pages) do
        local vis = (idx == i)
        if vis and not p.Visible then
            p.Visible = true
            p.BackgroundTransparency = 1
            tween(p, 0.25, {BackgroundTransparency = 0})
        elseif not vis and p.Visible then
            tween(p, 0.2, {BackgroundTransparency = 1}).Completed:Wait()
            p.Visible = false
        end
    end
end

local function showTab(tabBtn)
    for _,p in pairs(tabPages) do p.Visible = false end
    tabPages[tabBtn].Visible = true
    setActiveTab(tabBtn)
end

tabFunctions.MouseButton1Click:Connect(function() showTab(tabFunctions) end)
tabHelp.MouseButton1Click:Connect(function() showTab(tabHelp) end)
tabUpdates.MouseButton1Click:Connect(function() showTab(tabUpdates) end)

-- ========= УВЕДОМЛЕНИЯ =========
local notifyHolder = Instance.new("Frame")
notifyHolder.BackgroundTransparency = 1
notifyHolder.Size = UDim2.new(1, 0, 1, 0)
notifyHolder.Parent = screenGui

local function mkToast(msg, bgColor)
    local toast = Instance.new("TextLabel")
    toast.BackgroundColor3 = bgColor or Theme.Accent
    toast.TextColor3 = Color3.new(1,1,1)
    toast.Font = Enum.Font.GothamSemibold
    toast.TextScaled = true
    toast.Text = msg
    toast.AnchorPoint = Vector2.new(0.5, 1)
    toast.Position = UDim2.new(0.5, 0, 1, 80)
    toast.Size = UDim2.new(0, 360, 0, 48)
    toast.Parent = notifyHolder
    makeCorner(10).Parent = toast
    makeShadow(toast)
    tween(toast, 0.2, {Position = UDim2.new(0.5, 0, 1, -12)})
    task.delay(2.0, function()
        tween(toast, 0.2, {Position = UDim2.new(0.5, 0, 1, 80)}).Completed:Wait()
        toast:Destroy()
    end)
end

function notify(text, color)
    mkToast(text, color or Theme.Accent)
end

-- Стартовая страница
showPage(1)
showTab(tabFunctions)

-- Очистка при выходе
LocalPlayer.CharacterRemoving:Connect(function()
    -- Отключаем все функции при выходе
    toggleAim(false)
    toggleWallhack(false)
    toggleFreeCam(false)
    toggleFly(false)
    toggleNoclip(false)
    toggleFollow(false)
    toggleAvoidPlayers(false)
    toggleInvisible(false)
end)

print("Strip UI loaded successfully! Press Left Alt to toggle visibility.")
