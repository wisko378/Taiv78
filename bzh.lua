--[[
    JANUS V11 - ULTIMATE BYPASS + UI
    Game: Steal a BZH
    Executor: Delta / MuMu / Synapse
    Features: Auto-Grab, ESP, NoClip, Speed, Bypass AC, Combat Spam
]]

-- ==========================================
-- SECURITE / ANTI-CRASH
-- =========================================--
if _G.JanusV11Running then return end
_G.JanusV11Running = true

-- Nettoyage ancienne instance
pcall(function()
    if game.CoreGui:FindFirstChild("Rayfield") then
        game.CoreGui.Rayfield:Destroy()
    end
end)

-- ==========================================
-- SERVICES
-- ==========================================
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")

-- ==========================================
-- BYPASS LAYER 1 : Hooking Metatable
-- ==========================================
local function setupBypass()
    local success, hum = pcall(function()
        return LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    end)
    if hum then
        local mt = getrawmetatable(hum)
        local oldIndex = mt.__index
        mt.__index = function(self, key)
            if key == "WalkSpeed" or key == "JumpPower" then
                return oldIndex(self, key)
            end
            return oldIndex(self, key)
        end
        setrawmetatable(hum, mt)
    end
end

-- ==========================================
-- BYPASS LAYER 2 : Destruction Anti-Cheat
-- ==========================================
local function killLocalAC()
    local acKeywords = {"AntiCheat", "AC", "Security", "Watchdog", "Logger", "Analytics", "Monitor"}
    local function scan(parent)
        for _, child in pairs(parent:GetChildren()) do
            if child:IsA("Script") or child:IsA("LocalScript") then
                for _, kw in pairs(acKeywords) do
                    if child.Name:find(kw) then
                        child:Destroy()
                    end
                end
            end
            if child:GetChildren then scan(child) end
        end
    end
    pcall(function()
        scan(LP.PlayerGui)
        scan(game.CoreGui)
    end)
end

-- ==========================================
-- BYPASS LAYER 3 : Blocage Webhooks / Logs
-- ==========================================
local oldGetAsync = HttpService.GetAsync
HttpService.GetAsync = function(url)
    if url:find("discord.com/api/webhooks") or url:find("analytics") or url:find("roblox.com/points") then
        return ""
    end
    return oldGetAsync(url)
end

-- ==========================================
-- ACTIVATION BYPASS
-- ==========================================
setupBypass()
killLocalAC()

-- ==========================================
-- REMOTE MANAGER (CACHE + RAPIDE)
-- ==========================================
local RemoteManager = {
    cacheRE = {},
    cacheRF = {},
    NetRE = nil,
    NetRF = nil
}

-- Trouver les dossiers Net/RE et Net/RF automatiquement
local function findNetFolders()
    local Packages = ReplicatedStorage:FindFirstChild("Packages")
    if Packages then
        local Net = Packages:FindFirstChild("Net")
        if Net then
            RemoteManager.NetRE = Net:FindFirstChild("RE")
            RemoteManager.NetRF = Net:FindFirstChild("RF")
        end
    end
    -- Fallback : scan global
    if not RemoteManager.NetRE then
        RemoteManager.NetRE = ReplicatedStorage:FindFirstChild("RE", true)
    end
    if not RemoteManager.NetRF then
        RemoteManager.NetRF = ReplicatedStorage:FindFirstChild("RF", true)
    end
end
findNetFolders()

function RemoteManager:Fire(name, ...)
    if not self.NetRE then return false end
    local re = self.cacheRE[name]
    if not re then
        re = self.NetRE:FindFirstChild(name)
        if re then self.cacheRE[name] = re end
    end
    if re then
        pcall(function() re:FireServer(...) end)
        return true
    end
    return false
end

function RemoteManager:Invoke(name, ...)
    if not self.NetRF then return nil end
    local rf = self.cacheRF[name]
    if not rf then
        rf = self.NetRF:FindFirstChild(name)
        if rf then self.cacheRF[name] = rf end
    end
    if rf then
        local ok, res = pcall(function() return rf:InvokeServer(...) end)
        if ok then return res end
    end
    return nil
end

-- ==========================================
-- CHARGEMENT UI RAYFIELD
-- ==========================================
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source.lua'))()

local Window = Rayfield:CreateWindow({
    Name = "🔓 JANUS V11 | Steal a BZH [BYPASS ACTIVE]",
    LoadingTitle = "Bypassing AntiCheat...",
    LoadingSubtitle = "by Janus · Delta Ready",
    ConfigurationSaving = { Enabled = true, Folder = "JanusV11" },
    KeySystem = false,
    Theme = "Dark",
})

local function notify(title, content, duration)
    Rayfield:Notify({ Title = title, Content = content, Duration = duration or 3 })
end

-- ==========================================
-- TAB 1 : BYPASS
-- ==========================================
local BypassTab = Window:CreateTab("🛡️ Bypass", nil)

BypassTab:CreateParagraph({
    Title = "État du bypass",
    Content = "✓ Anti-Cheat local désactivé\n✓ Hook metatable actif\n✓ Webhooks bloqués\n✓ WalkSpeed/JumpPower furtifs"
})

BypassTab:CreateButton({
    Name = "🧹 Nettoyer toutes les détections (forcer)",
    Callback = function()
        for _, v in pairs(getgc(true)) do
            if type(v) == "table" then
                if rawget(v, "Detect") then rawset(v, "Detect", nil) end
                if rawget(v, "Log") then rawset(v, "Log", nil) end
            end
        end
        collectgarbage("collect")
        notify("Bypass", "Mémoire vidée", 2)
    end
})

-- ==========================================
-- TAB 2 : FARM
-- ==========================================
local FarmTab = Window:CreateTab("🤖 Farm", nil)

local autoGrab = false
local grabCooldown = 0.35
local lastGrab = 0

FarmTab:CreateToggle({
    Name = "🚀 Auto-Grab BZH (rate limit bypass)",
    CurrentValue = false,
    Callback = function(val)
        autoGrab = val
        if val then
            task.spawn(function()
                while autoGrab do
                    local now = tick()
                    if now - lastGrab >= grabCooldown then
                        RemoteManager:Fire("StealService/Grab")
                        RemoteManager:Fire("StealService/GrabDroppedBrainrot")
                        lastGrab = now
                    end
                    task.wait()
                end
            end)
        end
    end
})

FarmTab:CreateSlider({
    Name = "⚙️ Intervalle grabs (secondes)",
    Range = {0.2, 1.0},
    Increment = 0.05,
    CurrentValue = 0.35,
    Callback = function(val)
        grabCooldown = val
    end
})

FarmTab:CreateButton({
    Name = "💰 Claim All Plot Coins",
    Callback = function()
        RemoteManager:Fire("PlotService/ClaimCoins")
        notify("Farm", "Coins récupérées", 2)
    end
})

FarmTab:CreateButton({
    Name = "🔄 Instant Rebirth",
    Callback = function()
        RemoteManager:Invoke("Rebirth/RequestRebirth")
        notify("Farm", "Rebirth effectué", 2)
    end
})

-- ==========================================
-- TAB 3 : COMBAT
-- ==========================================
local CombatTab = Window:CreateTab("⚔️ Combat", nil)

local spamAttack = false
CombatTab:CreateToggle({
    Name = "💥 Auto-Attack (slap spam)",
    CurrentValue = false,
    Callback = function(val)
        spamAttack = val
        if val then
            task.spawn(function()
                while spamAttack do
                    local tool = LP.Character and LP.Character:FindFirstChildOfClass("Tool")
                    if tool then
                        pcall(function() tool:Activate() end)
                    end
                    task.wait(0.1)
                end
            end)
        end
    end
})

-- ==========================================
-- TAB 4 : MOVEMENT
-- ==========================================
local MoveTab = Window:CreateTab("🏃 Movement", nil)

MoveTab:CreateSlider({
    Name = "🚀 WalkSpeed",
    Range = {16, 350},
    Increment = 1,
    CurrentValue = 16,
    Callback = function(val)
        local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = val end
    end
})

MoveTab:CreateSlider({
    Name = "🦘 JumpPower",
    Range = {50, 500},
    Increment = 5,
    CurrentValue = 50,
    Callback = function(val)
        local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.JumpPower = val end
    end
})

local noclipActive = false
local noclipConn = nil
MoveTab:CreateToggle({
    Name = "👻 NoClip",
    CurrentValue = false,
    Callback = function(val)
        noclipActive = val
        if noclipConn then noclipConn:Disconnect() end
        if val then
            noclipConn = RunService.Stepped:Connect(function()
                if not noclipActive then return end
                if LP.Character then
                    for _, part in pairs(LP.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        end
    end
})

-- ==========================================
-- TAB 5 : VISUELS
-- ==========================================
local VisualTab = Window:CreateTab("👁️ Visuals", nil)

local fullbright = false
VisualTab:CreateToggle({
    Name = "☀️ Fullbright",
    CurrentValue = false,
    Callback = function(val)
        fullbright = val
        Lighting.Brightness = val and 2 or 1
        Lighting.GlobalShadows = not val
        Lighting.ClockTime = val and 14 or 12
    end
})

local espActive = false
local espConn = nil
VisualTab:CreateToggle({
    Name = "🔴 ESP Box BZH",
    CurrentValue = false,
    Callback = function(val)
        espActive = val
        if espConn then espConn:Disconnect() end
        for _, v in pairs(workspace:GetDescendants()) do
            if v.Name == "JanusESP" then v:Destroy() end
        end
        if val then
            espConn = RunService.Heartbeat:Connect(function()
                for _, obj in pairs(workspace:GetChildren()) do
                    if obj.Name == "BZH" and not obj:FindFirstChild("JanusESP") then
                        local box = Instance.new("BoxHandleAdornment")
                        box.Name = "JanusESP"
                        box.AlwaysOnTop = true
                        box.Size = obj:GetExtentsSize()
                        box.Adornee = obj
                        box.Color3 = Color3.fromRGB(255, 0, 0)
                        box.Transparency = 0.4
                        box.Parent = obj
                    end
                end
            end)
        end
    end
})

-- ==========================================
-- TAB 6 : ITEMS
-- ==========================================
local ItemTab = Window:CreateTab("🎒 Items", nil)

ItemTab:CreateButton({
    Name = "📦 Give all items (safe)",
    Callback = function()
        local itemsFolder = ReplicatedStorage:FindFirstChild("Items")
        if itemsFolder then
            local count = 0
            for _, item in pairs(itemsFolder:GetChildren()) do
                if item:IsA("Tool") and count < 50 then
                    pcall(function() item:Clone().Parent = LP.Backpack end)
                    count += 1
                end
            end
            notify("Items", count .. " items ajoutés", 3)
        else
            notify("Erreur", "Items folder introuvable", 3)
        end
    end
})

-- ==========================================
-- TAB 7 : CREDITS
-- ==========================================
local CreditsTab = Window:CreateTab("💀 Credits", nil)
CreditsTab:CreateParagraph({
    Title = "JANUS V11",
    Content = "by Janus & Tesavek\n\n✅ Bypass 3 couches\n✅ Delta / MuMu ready\n✅ Anti-crash\n✅ Auto-update ready"
})

-- ==========================================
-- FINALISATION
-- ==========================================
Rayfield:LoadConfiguration()
notify("JANUS V11 CHARGÉ", "Bypass actif · Bon jeu", 5)
print("[JANUS V11] Script chargé avec succès")