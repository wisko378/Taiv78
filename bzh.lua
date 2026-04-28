--[[
    JANUS V10 - ULTIMATE OVERRIDE
    Game: Steal a BZH
    Optimization: MuMu Player & Delta Executor
]]

-- Nettoyage des instances précédentes
if _G.JanusRunning then
    pcall(function() game.CoreGui.Rayfield:Destroy() end)
end
_G.JanusRunning = true

-- Chargement de la librairie Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "👾 JANUS V10 | Steal a BZH",
   LoadingTitle = "Initialisation du God Mode...",
   LoadingSubtitle = "by Janus & Tesavek",
   ConfigurationSaving = { Enabled = true, Folder = "JanusScripts" },
   KeySystem = false
})

-- ==========================================
-- SERVICES & REFERENCES (Source: Game Dump)
-- ==========================================
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NetRE = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Net"):WaitForChild("RE")
local NetRF = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Net"):WaitForChild("RF")
local LP = game.Players.LocalPlayer
local RunService = game:GetService("RunService")

-- ==========================================
-- ONGLET : AUTOMATION (FARMING)
-- ==========================================
local FarmTab = Window:CreateTab("Automations", 4483362458)

getgenv().AutoGrab = false
FarmTab:CreateToggle({
   Name = "🚀 Auto-Grab BZH (Ultra Fast)",
   CurrentValue = false,
   Callback = function(Value)
       getgenv().AutoGrab = Value
       task.spawn(function()
           while getgenv().AutoGrab do
               -- Appel direct des services de vol identifiés
               NetRE:FindFirstChild("StealService/Grab"):FireServer()
               NetRE:FindFirstChild("StealService/GrabDroppedBrainrot"):FireServer()
               task.wait(0.01) -- Vitesse maximale
           end
       end)
   end,
})

FarmTab:CreateButton({
   Name = "💰 Claim All Plot Coins",
   Callback = function()
       NetRE:FindFirstChild("PlotService/ClaimCoins"):FireServer()
       Rayfield:Notify({Title = "Argent", Content = "Coins récupérées avec succès !", Duration = 2})
   end,
})

FarmTab:CreateButton({
   Name = "🔄 Instant Rebirth",
   Callback = function()
       NetRF:FindFirstChild("Rebirth/RequestRebirth"):InvokeServer()
   end,
})

-- ==========================================
-- ONGLET : MOUVEMENT (GOD MODS)
-- ==========================================
local MoveTab = Window:CreateTab("Mouvement", 4483362458)

MoveTab:CreateSlider({
   Name = "Vitesse de marche",
   Range = {16, 500},
   Increment = 1,
   CurrentValue = 16,
   Callback = function(Value)
       if LP.Character and LP.Character:FindFirstChild("Humanoid") then
           LP.Character.Humanoid.WalkSpeed = Value
       end
   end,
})

MoveTab:CreateToggle({
   Name = "NoClip (Passer les murs)",
   CurrentValue = false,
   Callback = function(Value)
       getgenv().NoClip = Value
   end,
})

-- Connexion NoClip stable
RunService.Stepped:Connect(function()
    if getgenv().NoClip and LP.Character then
        for _, v in pairs(LP.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
end)

MoveTab:CreateButton({
   Name = "Activer le Menu Fly (Touche E)",
   Callback = function()
       loadstring(game:HttpGet("https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.lua"))()
   end,
})

-- ==========================================
-- ONGLET : ITEMS & HACKS
-- ==========================================
local ItemTab = Window:CreateTab("Items", 4483362458)

ItemTab:CreateButton({
   Name = "Obtenir tous les Items (Visual/Client)",
   Callback = function()
       local items = ReplicatedStorage:FindFirstChild("Items")
       if items then
           for _, item in pairs(items:GetChildren()) do
               if item:IsA("Tool") then
                   item:Clone().Parent = LP.Backpack
               end
           end
       end
   end,
})

ItemTab:CreateButton({
   Name = "Dupli-Glitch (Equip Item)",
   Callback = function()
       -- Tente de forcer l'équipement via le Remote de l'inventaire
       NetRF:FindFirstChild("InventoryService/EquipItem"):InvokeServer("BZH")
   end,
})

-- ==========================================
-- ONGLET : VISUELS
-- ==========================================
local VisualTab = Window:CreateTab("Visuels", 4483362458)

VisualTab:CreateButton({
   Name = "Vision Nocturne / Full Bright",
   Callback = function()
       game.Lighting.Brightness = 2
       game.Lighting.GlobalShadows = false
       game.Lighting.ClockTime = 14
       game.Lighting.FogEnd = 100000
   end,
})

VisualTab:CreateButton({
   Name = "ESP BZH (Voir à travers les murs)",
   Callback = function()
       for _, v in pairs(workspace:GetChildren()) do
           if v.Name == "BZH" and not v:FindFirstChild("ESP") then
               local b = Instance.new("BoxHandleAdornment", v)
               b.Name = "ESP"
               b.AlwaysOnTop = true
               b.ZIndex = 10
               b.Size = v:GetExtentsSize()
               b.Adornee = v
               b.Color3 = Color3.fromRGB(255, 0, 0)
               b.Transparency = 0.5
           end
       end
   end,
})

Rayfield:LoadConfiguration()
Rayfield:Notify({
    Title = "JANUS V10 CHARGÉ",
    Content = "Tout est prêt. Utilise les onglets à gauche.",
    Duration = 5
})

print("ARCHITECT: SCRIPT FINAL EXÉCUTÉ.")
