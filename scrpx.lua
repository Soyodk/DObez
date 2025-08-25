local function disableInfiniteJump()
    infiniteJumpEnabled = false
    if jumpConnection then
        jumpConnection:Disconnect()
        jumpConnection = nil
    end
    
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.JumpHeight = 7.2
    end
endlocal Luna = loadstring(game:HttpGet("https://raw.githubusercontent.com/Nebula-Softworks/Luna-Interface-Suite/refs/heads/main/source.lua", true))()

local Window = Luna:CreateWindow({
    Name = "Outlook Hub",
    Subtitle = "Advanced Game Enhancement Tool",
    LogoID = "82795327169782",
    LoadingEnabled = true,
    LoadingTitle = "Outlook Hub Interface",
    LoadingSubtitle = "by Bruxla",

    ConfigSettings = {
        RootFolder = nil,
        ConfigFolder = "OutlookHub_Config"
    },

    KeySystem = false,
    KeySettings = {
        Title = "Outlook Hub Key System",
        Subtitle = "Enter Access Key",
        Note = "Contact developer for access key",
        SaveInRoot = false,
        SaveKey = true,
        Key = {"OutlookHub2024"},
        SecondAction = {
            Enabled = false,
            Type = "Link",
            Parameter = ""
        }
    }
})

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

-- Variables
local healthRegenEnabled = false
local infiniteJumpEnabled = false
local autoFarmEnabled = false
local flyEnabled = false
local noclipEnabled = false
local speedEnabled = false
local savedPosition = nil
local healthConnection = nil
local jumpConnection = nil
local autoFarmConnection = nil
local flyConnection = nil
local noclipConnection = nil
local speedConnection = nil
local bodyVelocity = nil
local bodyAngularVelocity = nil
local originalWalkSpeed = 16

-- Anti-detection variables
local lastHealthUpdate = 0
local healthUpdateInterval = 0.1 + math.random() * 0.05 -- Random interval
local originalHealthValue = 100

-- Anti-detection functions
local function randomDelay()
    return 0.05 + math.random() * 0.1 -- Random delay between 0.05-0.15 seconds
end

local function simulateNaturalRegen()
    return math.random(1, 3) -- Random regen amount 1-3 HP
end

local function enableHealthRegen()
    healthRegenEnabled = true
    
    local function updateHealth()
        local currentTime = tick()
        if currentTime - lastHealthUpdate < healthUpdateInterval then
            return
        end
        
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            local humanoid = LocalPlayer.Character.Humanoid
            
            -- Store original max health if not stored
            if humanoid.MaxHealth ~= originalHealthValue and humanoid.MaxHealth < 999999 then
                originalHealthValue = humanoid.MaxHealth
            end
            
            -- Always boost max health first
            if humanoid.MaxHealth < 999999 then
                local newMaxHealth = math.min(humanoid.MaxHealth + math.random(50, 100), 999999)
                humanoid.MaxHealth = newMaxHealth
            end
            
            -- SEMPRE regenerar vida - nunca deixar diminuir
            if humanoid.Health < humanoid.MaxHealth then
                local regenAmount = math.random(50, 200) -- Regeneração mais forte
                local newHealth = math.min(humanoid.Health + regenAmount, humanoid.MaxHealth)
                humanoid.Health = newHealth
            end
            
            -- Força a vida para o máximo se estiver baixa
            if humanoid.Health < humanoid.MaxHealth * 0.8 then -- Se vida estiver abaixo de 80%
                humanoid.Health = humanoid.MaxHealth -- Força para o máximo
            end
        end
        
        lastHealthUpdate = currentTime
        healthUpdateInterval = 0.05 + math.random() * 0.03 -- Intervalo mais rápido
    end
    
    -- Use heartbeat para atualização mais frequente
    healthConnection = RunService.Heartbeat:Connect(updateHealth)
    
    -- Handle character respawn with immediate health boost
    LocalPlayer.CharacterAdded:Connect(function(character)
        if healthRegenEnabled then
            wait(0.5) -- Menor delay
            local humanoid = character:WaitForChild("Humanoid")
            originalHealthValue = humanoid.MaxHealth
            
            -- Força vida alta imediatamente ao respawnar
            spawn(function()
                wait(1)
                if healthRegenEnabled then
                    humanoid.MaxHealth = 999999
                    humanoid.Health = 999999
                end
            end)
        end
    end)
end

local function disableHealthRegen()
    healthRegenEnabled = false
    if healthConnection then
        healthConnection:Disconnect()
        healthConnection = nil
    end
    
    -- Gradually restore normal health
    spawn(function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            local humanoid = LocalPlayer.Character.Humanoid
            local steps = 20
            local targetMaxHealth = originalHealthValue
            local currentMaxHealth = humanoid.MaxHealth
            
            for i = 1, steps do
                if not healthRegenEnabled then -- Check if still disabled
                    local newMaxHealth = currentMaxHealth - ((currentMaxHealth - targetMaxHealth) / steps * i)
                    humanoid.MaxHealth = math.max(newMaxHealth, targetMaxHealth)
                    humanoid.Health = math.min(humanoid.Health, humanoid.MaxHealth)
                    wait(0.1)
                end
            end
        end
    end)
end

local function enableInfiniteJump()
    infiniteJumpEnabled = true
    
    local function updateJump()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            local humanoid = LocalPlayer.Character.Humanoid
            -- Use a high but not infinite value to avoid detection
            humanoid.JumpHeight = 500 + math.random(-50, 50) -- Random jump height
        end
    end
    
    jumpConnection = RunService.Heartbeat:Connect(updateJump)
    
    LocalPlayer.CharacterAdded:Connect(function(character)
        if infiniteJumpEnabled then
            wait(1 + randomDelay())
            character:WaitForChild("Humanoid").JumpHeight = 500 + math.random(-50, 50)
        end
    end)
end

local function enableSpeed()
    speedEnabled = true
    
    local function updateSpeed()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            local humanoid = LocalPlayer.Character.Humanoid
            local baseSpeed = 50 + math.random(-5, 5) -- Speed with variation 45-55
            humanoid.WalkSpeed = baseSpeed
        end
    end
    
    speedConnection = RunService.Heartbeat:Connect(updateSpeed)
    
    LocalPlayer.CharacterAdded:Connect(function(character)
        if speedEnabled then
            wait(1 + randomDelay())
            local humanoid = character:WaitForChild("Humanoid")
            originalWalkSpeed = humanoid.WalkSpeed
            humanoid.WalkSpeed = 50 + math.random(-5, 5)
        end
    end)
end

local function disableSpeed()
    speedEnabled = false
    if speedConnection then
        speedConnection:Disconnect()
        speedConnection = nil
    end
    
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = originalWalkSpeed
    end
end

local function enableNoclip()
    noclipEnabled = true
    
    local function updateNoclip()
        if LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetChildren()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.CanCollide = false
                end
            end
        end
    end
    
    noclipConnection = RunService.Stepped:Connect(updateNoclip)
    
    LocalPlayer.CharacterAdded:Connect(function(character)
        if noclipEnabled then
            wait(1)
            for _, part in pairs(character:GetChildren()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.CanCollide = false
                end
            end
        end
    end)
end

local function disableNoclip()
    noclipEnabled = false
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
    
    if LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetChildren()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.CanCollide = true
            end
        end
    end
end

local function saveCurrentPosition()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        savedPosition = LocalPlayer.Character.HumanoidRootPart.Position
        return true
    end
    return false
end

local function createFlyBodyMovers(character)
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    if bodyVelocity then bodyVelocity:Destroy() end
    if bodyAngularVelocity then bodyAngularVelocity:Destroy() end
    
    -- Use AssemblyLinearVelocity for better anti-detection
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(2000, 2000, 2000) -- Lower force to seem more natural
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.Parent = humanoidRootPart
    
    bodyAngularVelocity = Instance.new("BodyAngularVelocity")
    bodyAngularVelocity.MaxTorque = Vector3.new(2000, 2000, 2000)
    bodyAngularVelocity.AngularVelocity = Vector3.new(0, 0, 0)
    bodyAngularVelocity.Parent = humanoidRootPart
end

local function removeFlyBodyMovers()
    if bodyVelocity then
        bodyVelocity:Destroy()
        bodyVelocity = nil
    end
    if bodyAngularVelocity then
        bodyAngularVelocity:Destroy()
        bodyAngularVelocity = nil
    end
end

local function enableFly()
    flyEnabled = true
    
    if LocalPlayer.Character then
        createFlyBodyMovers(LocalPlayer.Character)
    end
    
    local flySpeed = 0
    flyConnection = RunService.Heartbeat:Connect(function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and flyEnabled then
            local humanoidRootPart = LocalPlayer.Character.HumanoidRootPart
            local humanoid = LocalPlayer.Character.Humanoid
            
            -- Variable fly speed to seem more natural
            flySpeed = math.sin(tick()) * 2 + 2 -- Oscillating between 0-4
            
            if bodyVelocity then
                -- Enhanced fly controls - WASD + Space/Shift
                local camera = game.Workspace.CurrentCamera
                local moveVector = Vector3.new(0, 0, 0)
                
                -- Get user input for enhanced flying
                local UserInputService = game:GetService("UserInputService")
                
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    moveVector = moveVector + camera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    moveVector = moveVector - camera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    moveVector = moveVector - camera.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    moveVector = moveVector + camera.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    moveVector = moveVector + Vector3.new(0, 1, 0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                    moveVector = moveVector - Vector3.new(0, 1, 0)
                end
                
                if moveVector.Magnitude > 0 then
                    bodyVelocity.Velocity = moveVector.Unit * 50 -- Fly speed
                else
                    bodyVelocity.Velocity = Vector3.new(0, flySpeed, 0) -- Hover
                end
            end
            
            humanoid.PlatformStand = true
        end
    end)
    
    LocalPlayer.CharacterAdded:Connect(function(character)
        if flyEnabled then
            wait(1 + randomDelay())
            createFlyBodyMovers(character)
        end
    end)
end

local function disableFly()
    flyEnabled = false
    
    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end
    
    removeFlyBodyMovers()
    
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.PlatformStand = false
    end
end

local function enableAutoFarm()
    if not savedPosition then
        return false
    end
    
    autoFarmEnabled = true
    
    local function teleportToSavedPosition()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            -- Add random height variation (15-25 studs above)
            local randomHeight = 15 + math.random() * 10
            local targetPosition = savedPosition + Vector3.new(0, randomHeight, 0)
            
            -- Smooth teleportation to avoid detection
            local currentCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
            local targetCFrame = CFrame.new(targetPosition)
            
            -- Use TweenService for smooth movement
            local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
            local tween = TweenService:Create(LocalPlayer.Character.HumanoidRootPart, tweenInfo, {CFrame = targetCFrame})
            tween:Play()
        end
    end
    
    local lastTeleport = 0
    autoFarmConnection = RunService.Heartbeat:Connect(function()
        if autoFarmEnabled and savedPosition and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local currentTime = tick()
            local currentPosition = LocalPlayer.Character.HumanoidRootPart.Position
            local targetPosition = savedPosition + Vector3.new(0, 20, 0)
            local distance = (currentPosition - targetPosition).Magnitude
            
            -- Only teleport if distance is significant and enough time has passed
            if distance > 15 and currentTime - lastTeleport > 2 then
                teleportToSavedPosition()
                lastTeleport = currentTime
            end
        end
    end)
    
    -- Initial teleport with delay
    spawn(function()
        wait(randomDelay())
        teleportToSavedPosition()
    end)
    
    LocalPlayer.CharacterAdded:Connect(function()
        if autoFarmEnabled then
            wait(2 + randomDelay())
            teleportToSavedPosition()
        end
    end)
    
    return true
end

local function disableAutoFarm()
    autoFarmEnabled = false
    if autoFarmConnection then
        autoFarmConnection:Disconnect()
        autoFarmConnection = nil
    end
end

-- Create Tabs
local MainTab = Window:CreateTab({
    Name = "Main Features",
    Icon = "settings",
    ImageSource = "Material",
    ShowTitle = true
})

local MovementTab = Window:CreateTab({
    Name = "Movement",
    Icon = "directions_run",
    ImageSource = "Material",
    ShowTitle = true
})

local AutoFarmTab = Window:CreateTab({
    Name = "Auto Farm",
    Icon = "agriculture",
    ImageSource = "Material",
    ShowTitle = true
})

local SecurityTab = Window:CreateTab({
    Name = "Security Info",
    Icon = "security",
    ImageSource = "Material",
    ShowTitle = true
})

-- Create Home Tab
Window:CreateHomeTab({
    SupportedExecutors = {"Synapse X", "Script-Ware", "Krnl", "Fluxus", "Delta X"},
    DiscordInvite = "",
    Icon = 1
})

-- Main Features Tab
local InfoParagraph = MainTab:CreateParagraph({
    Title = "Outlook Hub - Anti-Detection",
    Text = "Enhanced game features with smart anti-detection systems and health regeneration by Bruxla."
})

local HealthRegenToggle = MainTab:CreateToggle({
    Name = "Regeneração de Vida FORTE",
    Description = "Regenera vida rapidamente e mantém sempre alta",
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            enableHealthRegen()
            Luna:MakeNotification({
                Name = "Regeneração Ativada!",
                Content = "Vida será mantida sempre alta automaticamente!",
                Image = "favorite",
                Time = 3
            })
        else
            disableHealthRegen()
        end
    end
}, "HealthRegenToggle")

local InfiniteJumpToggle = MainTab:CreateToggle({
    Name = "Pulo Melhorado",
    Description = "Pulo alto com variação aleatória para evitar detecção",
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            enableInfiniteJump()
        else
            disableInfiniteJump()
        end
    end
}, "InfiniteJumpToggle")

-- Movement Tab
local MovementInfo = MovementTab:CreateParagraph({
    Title = "Controles de Movimento",
    Text = "Funcionalidades avançadas de movimento com controles intuitivos e anti-detecção."
})

local SpeedToggle = MovementTab:CreateToggle({
    Name = "Velocidade Rápida",
    Description = "Aumenta velocidade de caminhada (45-55 speed)",
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            enableSpeed()
            Luna:MakeNotification({
                Name = "Speed Ativado!",
                Content = "Velocidade aumentada com variação!",
                Image = "speed",
                Time = 3
            })
        else
            disableSpeed()
        end
    end
}, "SpeedToggle")

local NoclipToggle = MovementTab:CreateToggle({
    Name = "Noclip",
    Description = "Atravesse paredes e objetos",
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            enableNoclip()
            Luna:MakeNotification({
                Name = "Noclip Ativado!",
                Content = "Agora você pode atravessar paredes!",
                Image = "visibility_off",
                Time = 3
            })
        else
            disableNoclip()
        end
    end
}, "NoclipToggle")

local FlyToggle = MovementTab:CreateToggle({
    Name = "Voar (Fly) - Controles WASD",
    Description = "Voe com controles WASD + Space/Shift",
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            enableFly()
            Luna:MakeNotification({
                Name = "Fly Ativado!",
                Content = "Use WASD para voar, Space/Shift para subir/descer!",
                Image = "flight",
                Time = 5
            })
        else
            disableFly()
        end
    end
}, "FlyToggle")

local FlyControls = MovementTab:CreateParagraph({
    Title = "Controles do Fly",
    Text = "• W/A/S/D: Mover para frente/esquerda/trás/direita\n• Space: Subir\n• Shift: Descer\n• Velocidade: 50 studs/segundo\n• Hover automático quando parado"
})

-- Auto Farm Tab (same as before)
local AutoFarmInfo = AutoFarmTab:CreateParagraph({
    Title = "Auto Farm System",
    Text = "Sistema de farm automático com movimento suave e anti-detecção integrado."
})

local SavePositionButton = AutoFarmTab:CreateButton({
    Name = "Salvar Posição Atual",
    Description = "Salva sua posição atual para o Auto Farm",
    Callback = function()
        if saveCurrentPosition() then
            Luna:MakeNotification({
                Name = "Posição Salva!",
                Content = "Sua posição atual foi salva com sucesso!",
                Image = "ch
