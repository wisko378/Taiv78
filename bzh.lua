--[[
    JANUS V10 - ULTIMATE OVERRIDE
    Game: Steal a BZH
    Optimization: MuMu Player & Delta Executor
]]

-- ==========================================
-- NETTOYAGE
-- ==========================================
if _G.JanusRunning then
    pcall(function() game.CoreGui.Rayfield:Destroy() end)
end
_G.JanusRunning = true

-- ==========================================
-- CHARGEMENT RAYFIELD
-- ==========================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "👾 JANUS V10 | Steal a BZH",
    LoadingTitle = "Initialisation...",
    LoadingSubtitle = "by Janus & Tesavek",
    ConfigurationSaving = { Enabled = true, Folder = "JanusScripts" },
    KeySystem = false
})

-- ==========================================
-- SERVICES
-- ==========================================
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService         = game:GetService("RunService")
local LP                 = game.Players.LocalPlayer

-- WaitForChild avec timeout pour éviter un freeze infini
local function waitChild(parent, name, timeout)
    return parent:WaitForChild(name, timeout or 10)
end

local Packages = waitChild(ReplicatedStorage, "Packages")
local Net      = Packages and waitChild(Packages, "Net")
local NetRE    = Net and waitChild(Net, "RE")
local NetRF    = Net and waitChild(Net, "RF")

-- ==========================================
-- HELPERS (évite les crashes sur nil)
-- ==========================================
local function notify(title, content, duration)
    Rayfield:Notify({ Title = title, Content = content, Duration = duration or 3 })
end

local function safeFire(name, ...)
    if not NetRE then return notify("Erreur", "NetRE introuvable", 3) end
    local re = NetRE:FindFirstChild(name)
    if re then
        re:FireServer(...)
    else
        notify("Erreur", "Remote introuvable : " .. name, 3)
    end
end

local function safeInvoke(name, ...)
    if not NetRF then return notify("Erreur", "NetRF introuvable", 3) end
    local rf = NetRF:FindFirstChild(name)
    if rf then
        local ok, result = pcall(function() return rf:InvokeServer(...) end)
        if not ok then notify("Erreur", "InvokeServer échoué : " .. tostring(result), 3) end
        return result
    else
        notify("Erreur", "RemoteFunction introuvable : " .. name, 3)
    end
end

local function getHumanoid()
    return LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
end

-- ==========================================
-- ONGLET : AUTOMATIONS
-- ==========================================
local FarmTab = Window:CreateTab("🤖 Automations", 4483362458)

getgenv().AutoGrab = false

FarmTab:CreateToggle({
    Name = "🚀 Auto-Grab BZH",
    CurrentValue = false,
    Callback = function(value)
        getgenv().AutoGrab = value
        if value then
            task.spawn(function()
                while getgenv().AutoGrab do
                    safeFire("StealService/Grab")
                    safeFire("StealService/GrabDroppedBrainrot")
                    task.wait(0.5)
                end
            end)
        end
    end,
})

FarmTab:CreateButton({
    Name = "💰 Claim All Plot Coins",
    Callback = function()
        safeFire("PlotService/ClaimCoins")
        notify("Argent", "Coins récupérées !", 2)
    end,
})

FarmTab:CreateButton({
    Name = "🔄 Instant Rebirth",
    Callback = function()
        safeInvoke("Rebirth/RequestRebirth")
        notify("Rebirth", "Rebirth effectué !", 2)
    end,
})

-- ==========================================
-- ONGLET : MOUVEMENT
-- ==========================================
local MoveTab = Window:CreateTab("🏃 Mouvement", 4483362458)

MoveTab:CreateSlider({
    Name = "Vitesse de marche",
    Range = {16, 500},
    Increment = 1,
    CurrentValue = 16,
    Callback = function(value)
        local hum = getHumanoid()
        if hum then hum.WalkSpeed = value end
    end,
})

MoveTab:CreateSlider({
    Name = "Hauteur de saut",
    Range = {50, 500},
    Increment = 5,
    CurrentValue = 50,
    Callback = function(value)
        local hum = getHumanoid()
        if hum then hum.JumpPower = value end
    end,
})

getgenv().NoClip = false
MoveTab:CreateToggle({
    Name = "👻 NoClip (Passer les murs)",
    CurrentValue = false,
    Callback = function(value)
        getgenv().NoClip = value
    end,
})

-- NoClip : connexion stable avec vérification CanCollide
RunService.Stepped:Connect(function()
    if getgenv().NoClip and LP.Character then
        for _, v in pairs(LP.Character:GetDescendants()) do
            if v:IsA("BasePart") and v.CanCollide then
                v.CanCollide = false
            end
        end
    end
end)

MoveTab:CreateButton({
    Name = "✈️ Activer le Fly (Touche E)",
    Callback = function()
        local ok, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.lua"))()
        end)
        if not ok then
            notify("Erreur Fly", tostring(err), 4)
        end
    end,
})

-- ==========================================
-- ONGLET : ITEMS
-- ==========================================
local ItemTab = Window:CreateTab("🎒 Items", 4483362458)

ItemTab:CreateButton({
    Name = "📦 Obtenir tous les Items (Client)",
    Callback = function()
        local items = ReplicatedStorage:FindFirstChild("Items")
        if items then
            local count = 0
            for _, item in pairs(items:GetChildren()) do
                if item:IsA("Tool") then
                    item:Clone().Parent = LP.Backpack
                    count += 1
                end
            end
            notify("Items", count .. " item(s) ajouté(s) au backpack.", 3)
        else
            notify("Items", "Dossier Items introuvable.", 3)
        end
    end,
})

ItemTab:CreateButton({
    Name = "🔁 Dupli-Glitch (Equip BZH)",
    Callback = function()
        safeInvoke("InventoryService/EquipItem", "BZH")
    end,
})

-- ==========================================
-- ONGLET : VISUELS
-- ==========================================
local VisualTab = Window:CreateTab("👁️ Visuels", 4483362458)

local fullBrightActive = false
VisualTab:CreateToggle({
    Name = "🌕 Full Bright",
    CurrentValue = false,
    Callback = function(value)
        fullBrightActive = value
        if value then
            game.Lighting.Brightness = 2
            game.Lighting.GlobalShadows = false
            game.Lighting.ClockTime = 14
            game.Lighting.FogEnd = 100000
        else
            game.Lighting.Brightness = 1
            game.Lighting.GlobalShadows = true
            game.Lighting.ClockTime = 12
            game.Lighting.FogEnd = 100000
        end
    end,
})

local espActive = false
VisualTab:CreateToggle({
    Name = "🔴 ESP BZH (Voir à travers les murs)",
    CurrentValue = false,
    Callback = function(value)
        espActive = value
        if not value then
            -- Supprime tous les ESP existants
            for _, v in pairs(workspace:GetDescendants()) do
                if v.Name == "ESP_JANUS" then v:Destroy() end
            end
        end
    end,
})

-- ESP mis à jour en temps réel
RunService.Heartbeat:Connect(function()
    if not espActive then return end
    for _, v in pairs(workspace:GetChildren()) do
        if v.Name == "BZH" and not v:FindFirstChild("ESP_JANUS") then
            local ok, _ = pcall(function()
                local b = Instance.new("BoxHandleAdornment")
                b.Name = "ESP_JANUS"
                b.AlwaysOnTop = true
                b.ZIndex = 10
                b.Size = v:GetExtentsSize()
                b.Adornee = v
                b.Color3 = Color3.fromRGB(255, 50, 50)
                b.Transparency = 0.4
                b.Parent = v
            end)
        end
    end
end)

-- ==========================================
-- FINALISATION
-- ==========================================
Rayfield:LoadConfiguration()
notify("JANUS V10 CHARGÉ ✅", "Tout est prêt. Bonne session !", 5)
print("[JANUS V10] Script chargé avec succès.")
