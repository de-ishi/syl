if game.PlaceId == 286090429 then
    warn("loading syl")

else
    return
end


local Playern = game:GetService("Players").LocalPlayer.Name

local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/de-ishi/scripts/refs/heads/main/rayfieldSfe'))()

local Window = Rayfield:CreateWindow({
    Name = "Arsenal - SYL",
    Icon = "moon-star",
    LoadingTitle = "Hi "..Playern,
    LoadingSubtitle = "^w^",
    Theme = "DarkBlue",
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false,
    Discord = {
        Enabled = true,
        Invite = "nmqG8GMUnn",
        RememberJoins = false
    },
    KeySystem = true,
    KeySettings = {
        Title = "Hello "..Playern,
        Subtitle = "Thanks for using SYL.",
        Note = "Key at : https://discord.gg/nmqG8GMUnn",
        FileName = "arsenal_syl",
        SaveKey = true,
        GrabKeyFromSite = true,
        Key = {"https://pastebin.com/raw/MnChhYmx"},
        ProductSecret = {"prod_sk_XIz4u_ffb6d08d2cb314f743ce1e6c3c4d7a4d7ae78711"}
    }
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local db = Window:CreateTab("Dashboard", "shapes")

local sec = db:CreateSection("Overview")
local div = db:CreateDivider()
local lab = db:CreateLabel("SYL v1.0.0", "shapes", Color3.fromRGB(31,44,45), false)
local but = db:CreateButton({
    Name = "Copy discord server link",
    Callback = function()
        setclipboard("https://discord.gg/nmqG8GMUnn")
    end,
})

local sec = db:CreateSection("Changelog")
local div = db:CreateDivider()
local par = db:CreateParagraph({Title = "Latest Updates:", Content = "release"})

local sec = db:CreateSection("Credits")
local div = db:CreateDivider()
local lab = db:CreateLabel("oshied/aze/syl - Owner", "shapes", Color3.fromRGB(31,44,45), false)
local lab = db:CreateLabel("atestrysi/ - Co Owner", "shapes", Color3.fromRGB(31,44,45), false)

-- ==================== AIM TAB ====================

local AimTab = Window:CreateTab("Aim", "target")

AimTab:CreateSection("Trigger Bot")

local TriggerBot = {
    Enabled = false,
    TeamCheck = true,
    WallCheck = false,
    Firing = false
}

local function IsEnemyInFront()

    local rayOrigin = Camera.CFrame.Position
    local rayDirection = Camera.CFrame.LookVector * 1000

    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
    raycastParams.IgnoreWater = true

    local raycastResult = Workspace:Raycast(rayOrigin, rayDirection, raycastParams)

    if raycastResult then
        local hitPart = raycastResult.Instance
        local hitPlayer = nil

        for _, player in Players:GetPlayers() do
            if player ~= LocalPlayer and player.Character then
                if hitPart:IsDescendantOf(player.Character) then
                    hitPlayer = player
                    break
                end
            end
        end

        if hitPlayer then

            if TriggerBot.TeamCheck and hitPlayer.Team == LocalPlayer.Team then
                return nil
            end

            if TriggerBot.WallCheck then
                local character = LocalPlayer.Character
                if character then
                    local rootPart = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Head")
                    if rootPart then
                        local wallRayParams = RaycastParams.new()
                        wallRayParams.FilterType = Enum.RaycastFilterType.Blacklist
                        wallRayParams.FilterDescendantsInstances = {character, hitPlayer.Character}
                        wallRayParams.IgnoreWater = true

                        local wallResult = Workspace:Raycast(rootPart.Position, (hitPart.Position - rootPart.Position), wallRayParams)
                        if wallResult and not wallResult.Instance:IsDescendantOf(hitPlayer.Character) then
                            return nil

                        end
                    end
                end
            end

            return hitPlayer
        end
    end

    return nil
end

local function SimulateMouseClick()
    local VirtualInputManager = game:GetService("VirtualInputManager")

    local mouse = LocalPlayer:GetMouse()
    local mouseX, mouseY = 0, 0

    if mouse and mouse.X and mouse.Y then
        mouseX, mouseY = mouse.X, mouse.Y
    end

    VirtualInputManager:SendMouseButtonEvent(mouseX, mouseY, 0, true, game, 0)
    task.wait(0.05)

    VirtualInputManager:SendMouseButtonEvent(mouseX, mouseY, 0, false, game, 0)
end

local triggerBotConnection = nil

local function StartTriggerBot()
    if triggerBotConnection then
        triggerBotConnection:Disconnect()
        triggerBotConnection = nil
    end

    triggerBotConnection = RunService.RenderStepped:Connect(function()
        if not TriggerBot.Enabled or TriggerBot.Firing then
            return
        end

        local enemy = IsEnemyInFront()
        if enemy then
            TriggerBot.Firing = true
            SimulateMouseClick()
            task.wait(0.1)

            TriggerBot.Firing = false
        end
    end)
end

local function StopTriggerBot()
    if triggerBotConnection then
        triggerBotConnection:Disconnect()
        triggerBotConnection = nil
    end
    TriggerBot.Firing = false
end

AimTab:CreateToggle({
    Name = "Trigger Bot",
    CurrentValue = false,
    Callback = function(Value)
        -- TriggerBot.Enabled = Value
        --  if Value then
        --      StartTriggerBot()
        --  else
        --     StopTriggerBot()
        -- end
    end
})

AimTab:CreateToggle({
    Name = "Trigger Team Check",
    CurrentValue = true,
    Callback = function(Value)
        TriggerBot.TeamCheck = Value
    end
})

AimTab:CreateToggle({
    Name = "Trigger Wall Check",
    CurrentValue = false,
    Callback = function(Value)
        TriggerBot.WallCheck = Value
    end
})

local Camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local Aimbot = {
    Enabled = false,
    TeamCheck = true,
    WallCheck = false,
    FOV = 40,
    Smoothness = 0,
    TargetPart = "Head"
}

local Circle = Drawing.new("Circle")
Circle.Thickness = 3

Circle.Color = Color3.fromRGB(255, 255, 255)

Circle.Filled = false
Circle.Transparency = 0.8

Circle.Radius = Aimbot.FOV
Circle.Visible = false

local function IsTargetVisible(targetPart)
    if not Aimbot.WallCheck then
        return true

    end

    local character = LocalPlayer.Character
    if not character then return false end

    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return false end

    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {character, targetPart.Parent}
    raycastParams.IgnoreWater = true

    local direction = (targetPart.Position - rootPart.Position)
    local raycastResult = Workspace:Raycast(rootPart.Position, direction, raycastParams)

    if raycastResult then
        local hitPart = raycastResult.Instance

        if hitPart and not hitPart:IsDescendantOf(targetPart.Parent) then
            return false

        end
    end

    return true

end

local function GetClosest()
    local closest = nil
    local closestPart = nil
    local shortest = math.huge
    local mousePos = UserInputService:GetMouseLocation()

    for _, player in Players:GetPlayers() do
        if player ~= LocalPlayer and player.Character then
            if Aimbot.TeamCheck and player.Team == LocalPlayer.Team then
                continue
            end

            local targetPartName = Aimbot.TargetPart

            if targetPartName == "Random" then

                targetPartName = math.random(1, 2) == 1 and "Head" or "Torso"
            end

            local targetPart = nil
            if targetPartName == "Head" then
                targetPart = player.Character:FindFirstChild("Head")
            elseif targetPartName == "Torso" then

                targetPart = player.Character:FindFirstChild("UpperTorso") or
                        player.Character:FindFirstChild("Torso")
            end

            if not targetPart then
                targetPart = player.Character:FindFirstChild("Head")
                targetPartName = "Head"

            end

            if targetPart then

                if not IsTargetVisible(targetPart) then
                    continue

                end

                local pos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                    if dist < Aimbot.FOV and dist < shortest then
                        shortest = dist
                        closest = targetPart
                        closestPart = targetPartName
                    end
                end
            end
        end
    end
    return closest, closestPart
end

AimTab:CreateSection("Aimbot Settings")

AimTab:CreateToggle({
    Name = "Aimbot",
    CurrentValue = false,
    Callback = function(Value)
        Aimbot.Enabled = Value
        Circle.Visible = Value

    end
})

AimTab:CreateToggle({
    Name = "Team Check",
    CurrentValue = true,
    Callback = function(Value)
        Aimbot.TeamCheck = Value
    end
})

AimTab:CreateToggle({
    Name = "Wall Check",
    CurrentValue = false,
    Callback = function(Value)
        Aimbot.WallCheck = Value
    end
})

AimTab:CreateSlider({
    Name = "Aimbot FOV",
    Range = {25, 500},
    Increment = 1,
    CurrentValue = 40,
    Callback = function(Value)
        Aimbot.FOV = Value
        Circle.Radius = Value
    end
})

AimTab:CreateSlider({
    Name = "Smoothness",
    Range = {0, 100},
    Increment = 1,
    CurrentValue = 0,
    Callback = function(Value)
        Aimbot.Smoothness = Value
    end
})
local lab = AimTab:CreateLabel("0 SMOOTHNESS = INSTANT", "shapes", Color3.fromRGB(31,44,45), false)

local TargetOptions = {"Head", "Torso", "Random"}
AimTab:CreateDropdown({
    Name = "Target Part",
    Options = TargetOptions,
    CurrentOption = "Head",
    Callback = function(Option)
        Aimbot.TargetPart = Option
    end
})

AimTab:CreateSection("circle thing customization")

AimTab:CreateColorPicker({
    Name = "Circle Color",
    Color = Color3.fromRGB(255, 255, 255),

    Callback = function(Value)
        Circle.Color = Value
    end
})

AimTab:CreateSlider({
    Name = "Circle Thickness",
    Range = {1, 10},
    Increment = 1,
    CurrentValue = 3,
    Callback = function(Value)
        Circle.Thickness = Value
    end
})

AimTab:CreateSlider({
    Name = "Circle Transparency",
    Range = {0, 1},
    Increment = 0.1,
    CurrentValue = 0.8,
    Callback = function(Value)
        Circle.Transparency = Value
    end
})

AimTab:CreateToggle({
    Name = "Filled Circle",
    CurrentValue = false,
    Callback = function(Value)
        Circle.Filled = Value
    end
})

RunService.RenderStepped:Connect(function()
    local mousePos = UserInputService:GetMouseLocation()
    Circle.Position = mousePos
    Circle.Radius = Aimbot.FOV

    if Aimbot.Enabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target, partName = GetClosest()
        if target then
            if Aimbot.Smoothness > 0 then

                local currentCFrame = Camera.CFrame
                local targetCFrame = CFrame.new(currentCFrame.Position, target.Position)

                local smoothFactor = math.clamp(Aimbot.Smoothness / 100, 0, 0.99)

                Camera.CFrame = currentCFrame:Lerp(targetCFrame, smoothFactor)
            else

                Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
            end
        end
    end
end)

-- ==================== VISUAL TAB ====================

local VisualTab = Window:CreateTab("Visual", "eye")

local ESP_ENABLED = false
local TEAM_CHECK = true
local TRACERS = false
local RAINBOW_MODE = false

local ESP_SETTINGS = {
    EnemyColor = Color3.fromRGB(255, 0, 0),

    TeamColor = Color3.fromRGB(0, 255, 0),

    TracerColor = Color3.fromRGB(255, 0, 0),

    BoxThickness = 2,

    TracerThickness = 2,

    BoxFilled = false,

    BoxTransparency = 0.8,

    TracerTransparency = 0.8,

    ShowDistance = false,

    ShowHealth = false

}

local esp_objects = {}
local connection
local rainbow_hue = 0

local function GetRainbowColor()
    rainbow_hue = (rainbow_hue + 0.01) % 1
    return Color3.fromHSV(rainbow_hue, 1, 1)
end

local function UpdateESPColors()
    if RAINBOW_MODE then
        local rainbowColor = GetRainbowColor()
        ESP_SETTINGS.EnemyColor = rainbowColor
        ESP_SETTINGS.TeamColor = rainbowColor
        ESP_SETTINGS.TracerColor = rainbowColor
    end
end

local function add_player(plr)
    if plr == LocalPlayer then return end

    local box = Drawing.new("Square")
    box.Thickness = ESP_SETTINGS.BoxThickness
    box.Filled = ESP_SETTINGS.BoxFilled
    box.Color = ESP_SETTINGS.EnemyColor
    box.Transparency = ESP_SETTINGS.BoxTransparency
    box.Visible = false

    local tracer = Drawing.new("Line")
    tracer.Thickness = ESP_SETTINGS.TracerThickness
    tracer.Color = ESP_SETTINGS.TracerColor
    tracer.Transparency = ESP_SETTINGS.TracerTransparency
    tracer.Visible = false

    local distanceText = nil
    if ESP_SETTINGS.ShowDistance then
        distanceText = Drawing.new("Text")
        distanceText.Text = "0m"
        distanceText.Size = 13
        distanceText.Center = true
        distanceText.Outline = true
        distanceText.Color = ESP_SETTINGS.EnemyColor
        distanceText.Visible = false
    end

    local healthText = nil
    if ESP_SETTINGS.ShowHealth then
        healthText = Drawing.new("Text")
        healthText.Text = "100HP"
        healthText.Size = 13
        healthText.Center = true
        healthText.Outline = true
        healthText.Color = ESP_SETTINGS.EnemyColor
        healthText.Visible = false
    end

    esp_objects[plr] = {
        box = box,
        tracer = tracer,
        distanceText = distanceText,
        healthText = healthText
    }
end

local function remove_player(plr)
    if esp_objects[plr] then
        esp_objects[plr].box:Remove()
        esp_objects[plr].tracer:Remove()
        if esp_objects[plr].distanceText then
            esp_objects[plr].distanceText:Remove()
        end
        if esp_objects[plr].healthText then
            esp_objects[plr].healthText:Remove()
        end
        esp_objects[plr] = nil
    end
end

local function update()

    if RAINBOW_MODE then
        UpdateESPColors()
    end

    for plr, objs in pairs(esp_objects) do
        local success, err = pcall(function()
            if not plr.Character or not plr.Character:FindFirstChild("Head") or
                    not plr.Character:FindFirstChild("HumanoidRootPart") or
                    not plr.Character:FindFirstChild("Humanoid") or
                    plr.Character:FindFirstChild("Humanoid").Health <= 0 then
                objs.box.Visible = false
                objs.tracer.Visible = false
                if objs.distanceText then objs.distanceText.Visible = false end
                if objs.healthText then objs.healthText.Visible = false end
                return
            end

            local root = plr.Character.HumanoidRootPart
            local head = plr.Character.Head
            local humanoid = plr.Character.Humanoid

            local root_pos, on_screen = Camera:WorldToViewportPoint(root.Position)
            local head_pos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0,1,0))
            local leg_pos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0,4,0))

            if not on_screen then
                objs.box.Visible = false
                objs.tracer.Visible = false
                if objs.distanceText then objs.distanceText.Visible = false end
                if objs.healthText then objs.healthText.Visible = false end
                return
            end

            local is_team = TEAM_CHECK and plr.Team == LocalPlayer.Team
            local boxColor = is_team and ESP_SETTINGS.TeamColor or ESP_SETTINGS.EnemyColor
            local tracerColor = is_team and ESP_SETTINGS.TeamColor or ESP_SETTINGS.TracerColor

            objs.box.Color = boxColor
            objs.box.Thickness = ESP_SETTINGS.BoxThickness
            objs.box.Filled = ESP_SETTINGS.BoxFilled
            objs.box.Transparency = ESP_SETTINGS.BoxTransparency

            objs.tracer.Color = tracerColor
            objs.tracer.Thickness = ESP_SETTINGS.TracerThickness
            objs.tracer.Transparency = ESP_SETTINGS.TracerTransparency

            local height = math.abs(head_pos.Y - leg_pos.Y)
            local width = height * 0.5

            objs.box.Size = Vector2.new(width, height)
            objs.box.Position = Vector2.new(root_pos.X - width/2, head_pos.Y)
            objs.box.Visible = ESP_ENABLED

            if TRACERS then
                objs.tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                objs.tracer.To = Vector2.new(root_pos.X, leg_pos.Y)
                objs.tracer.Visible = true
            else
                objs.tracer.Visible = false
            end

            if objs.distanceText and ESP_SETTINGS.ShowDistance then
                local distance = math.floor((root.Position - Camera.CFrame.Position).Magnitude)
                objs.distanceText.Text = tostring(distance) .. "m"
                objs.distanceText.Color = boxColor
                objs.distanceText.Position = Vector2.new(root_pos.X, leg_pos.Y + 5)
                objs.distanceText.Visible = ESP_ENABLED
            end

            if objs.healthText and ESP_SETTINGS.ShowHealth then
                local health = math.floor(humanoid.Health)
                objs.healthText.Text = tostring(health) .. "HP"
                objs.healthText.Color = boxColor
                objs.healthText.Position = Vector2.new(root_pos.X, head_pos.Y - 15)
                objs.healthText.Visible = ESP_ENABLED
            end
        end)

        if not success then
            remove_player(plr)
        end
    end
end

for _, plr in pairs(Players:GetPlayers()) do
    add_player(plr)
end

Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Wait()
    add_player(plr)
end)

Players.PlayerRemoving:Connect(remove_player)

VisualTab:CreateSection("ESP Settings")

VisualTab:CreateToggle({
    Name = "ESP",
    CurrentValue = false,
    Callback = function(Value)
        ESP_ENABLED = Value
        if Value and not connection then
            connection = RunService.RenderStepped:Connect(update)
        elseif not Value and connection then
            connection:Disconnect()
            connection = nil
            for _, objs in pairs(esp_objects) do
                objs.box.Visible = false
                objs.tracer.Visible = false
                if objs.distanceText then objs.distanceText.Visible = false end
                if objs.healthText then objs.healthText.Visible = false end
            end
        end
    end
})

VisualTab:CreateToggle({
    Name = "Team Check",
    CurrentValue = true,
    Callback = function(Value)
        TEAM_CHECK = Value
    end
})

VisualTab:CreateToggle({
    Name = "Tracers",
    CurrentValue = false,
    Callback = function(Value)
        TRACERS = Value
    end
})

VisualTab:CreateToggle({
    Name = "Rainbow Mode",
    CurrentValue = false,
    Callback = function(Value)
        RAINBOW_MODE = Value
    end
})

VisualTab:CreateSection("ESP Customization")

VisualTab:CreateColorPicker({
    Name = "Enemy Color",
    Color = ESP_SETTINGS.EnemyColor,
    Callback = function(Value)
        ESP_SETTINGS.EnemyColor = Value
    end
})

VisualTab:CreateColorPicker({
    Name = "Team Color",
    Color = ESP_SETTINGS.TeamColor,
    Callback = function(Value)
        ESP_SETTINGS.TeamColor = Value
    end
})

VisualTab:CreateColorPicker({
    Name = "Tracer Color",
    Color = ESP_SETTINGS.TracerColor,
    Callback = function(Value)
        ESP_SETTINGS.TracerColor = Value
    end
})

VisualTab:CreateSlider({
    Name = "Box Thickness",
    Range = {1, 10},
    Increment = 1,
    CurrentValue = 2,
    Callback = function(Value)
        ESP_SETTINGS.BoxThickness = Value
    end
})

VisualTab:CreateSlider({
    Name = "Tracer Thickness",
    Range = {1, 10},
    Increment = 1,
    CurrentValue = 2,
    Callback = function(Value)
        ESP_SETTINGS.TracerThickness = Value
    end
})

VisualTab:CreateSlider({
    Name = "Box Transparency",
    Range = {0, 1},
    Increment = 0.1,
    CurrentValue = 0.8,
    Callback = function(Value)
        ESP_SETTINGS.BoxTransparency = Value
    end
})

VisualTab:CreateSlider({
    Name = "Tracer Transparency",
    Range = {0, 1},
    Increment = 0.1,
    CurrentValue = 0.8,
    Callback = function(Value)
        ESP_SETTINGS.TracerTransparency = Value
    end
})

VisualTab:CreateToggle({
    Name = "Filled Box",
    CurrentValue = false,
    Callback = function(Value)
        ESP_SETTINGS.BoxFilled = Value
    end
})

VisualTab:CreateToggle({
    Name = "Show Distance",
    CurrentValue = false,
    Callback = function(Value)
        ESP_SETTINGS.ShowDistance = Value

        if Value then
            for plr, objs in pairs(esp_objects) do
                if not objs.distanceText then
                    remove_player(plr)
                    add_player(plr)
                end
            end
        end
    end
})

VisualTab:CreateToggle({
    Name = "Show Health",
    CurrentValue = false,
    Callback = function(Value)
        ESP_SETTINGS.ShowHealth = Value

        if Value then
            for plr, objs in pairs(esp_objects) do
                if not objs.healthText then
                    remove_player(plr)
                    add_player(plr)
                end
            end
        end
    end
})

local MovementTab = Window:CreateTab("Movement", "user")

MovementTab:CreateSection("Bunny Hop")

local BunnyHop = {
    Enabled = false,
    AutoJump = true,
    SpeedBoost = 1.2,

    JumpPower = 50,
    Strafe = false

}

local bhopConnection = nil
local isJumping = false
local lastJumpTime = 0

local function ApplyBunnyHop()
    local character = LocalPlayer.Character
    if not character then return end

    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end

    if humanoid:GetState() == Enum.HumanoidStateType.Running or
            humanoid:GetState() == Enum.HumanoidStateType.Landed then

        if BunnyHop.AutoJump and tick() - lastJumpTime > 0.1 then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            lastJumpTime = tick()
            isJumping = true

            if BunnyHop.SpeedBoost > 1 then
                humanoid.WalkSpeed = humanoid.WalkSpeed * BunnyHop.SpeedBoost
            end
        end
    end

    if BunnyHop.Strafe and isJumping and humanoid:GetState() == Enum.HumanoidStateType.Freefall then
        local root = character:FindFirstChild("HumanoidRootPart")
        if root then

            local moveDir = humanoid.MoveDirection
            if moveDir.Magnitude > 0 then

                root.CFrame = CFrame.new(root.Position, root.Position + moveDir)
            end
        end
    end

    if humanoid:GetState() == Enum.HumanoidStateType.Landed then
        isJumping = false

        if BunnyHop.SpeedBoost > 1 then
            humanoid.WalkSpeed = 16
        end
    end
end

local function StartBunnyHop()
    if bhopConnection then
        bhopConnection:Disconnect()
        bhopConnection = nil
    end

    bhopConnection = RunService.Heartbeat:Connect(function()
        if BunnyHop.Enabled then
            ApplyBunnyHop()
        end
    end)
end

local function StopBunnyHop()
    if bhopConnection then
        bhopConnection:Disconnect()
        bhopConnection = nil
    end

    local character = LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = 16
        end
    end
    isJumping = false
end

MovementTab:CreateToggle({
    Name = "Bunny Hop",
    CurrentValue = false,
    Callback = function(Value)
        BunnyHop.Enabled = Value
        if Value then
            StartBunnyHop()
        else
            StopBunnyHop()
        end
    end
})

MovementTab:CreateToggle({
    Name = "Auto Jump",
    CurrentValue = true,
    Callback = function(Value)
        BunnyHop.AutoJump = Value
    end
})

MovementTab:CreateToggle({
    Name = "Auto Strafe",
    CurrentValue = false,
    Callback = function(Value)
        BunnyHop.Strafe = Value
    end
})

MovementTab:CreateSlider({
    Name = "Jump Power",
    Range = {30, 100},
    Increment = 5,
    CurrentValue = 50,
    Callback = function(Value)
        BunnyHop.JumpPower = Value
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.JumpPower = Value
            end
        end
    end
})

MovementTab:CreateSlider({
    Name = "Speed Boost",
    Range = {1.0, 2.0},
    Increment = 0.1,
    CurrentValue = 1.2,
    Callback = function(Value)
        BunnyHop.SpeedBoost = Value
    end
})

MovementTab:CreateSection("Anti-Aim")

local AntiAim = {
    Enabled = false,
    Mode = "Jitter",

    Speed = 10,

    Intensity = 5,

    FakeLag = false,

    FakeLagAmount = 0.1

}

local antiAimConnection = nil
local spinAngle = 0
local jitterTimer = 0
local fakeLagBuffer = {}
local originalCFrames = {}

local function ApplyAntiAim()
    local character = LocalPlayer.Character
    if not character then return end

    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    if not originalCFrames[character] then
        originalCFrames[character] = root.CFrame
    end

    if AntiAim.Mode == "Spin" then

        spinAngle = (spinAngle + AntiAim.Speed) % 360
        local radians = math.rad(spinAngle)
        local offset = Vector3.new(math.sin(radians) * AntiAim.Intensity, 0, math.cos(radians) * AntiAim.Intensity)
        root.CFrame = originalCFrames[character] * CFrame.new(offset) * CFrame.Angles(0, radians, 0)

    elseif AntiAim.Mode == "Jitter" then

        jitterTimer = jitterTimer + 0.1
        local xJitter = math.sin(jitterTimer * AntiAim.Speed) * AntiAim.Intensity
        local yJitter = math.cos(jitterTimer * AntiAim.Speed * 1.5) * AntiAim.Intensity
        local zJitter = math.sin(jitterTimer * AntiAim.Speed * 0.5) * AntiAim.Intensity

        root.CFrame = originalCFrames[character] * CFrame.new(xJitter, yJitter, zJitter)

    elseif AntiAim.Mode == "Random" then

        if tick() % 0.5 < 0.1 then

            spinAngle = math.random(0, 360)
        end

        local radians = math.rad(spinAngle)
        local offset = Vector3.new(
                math.random(-AntiAim.Intensity, AntiAim.Intensity),
                math.random(-AntiAim.Intensity / 2, AntiAim.Intensity / 2),
                math.random(-AntiAim.Intensity, AntiAim.Intensity)
        )

        root.CFrame = originalCFrames[character] * CFrame.new(offset) * CFrame.Angles(0, radians, 0)
    end
end

local function ApplyFakeLag()
    local character = LocalPlayer.Character
    if not character then return end

    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    table.insert(fakeLagBuffer, {
        position = root.Position,
        time = tick()
    })

    for i = #fakeLagBuffer, 1, -1 do
        if tick() - fakeLagBuffer[i].time > AntiAim.FakeLagAmount then
            table.remove(fakeLagBuffer, i)
        end
    end

    if #fakeLagBuffer > 0 then
        local delayedPos = fakeLagBuffer[1].position
        root.CFrame = CFrame.new(delayedPos) * (root.CFrame - root.Position)
    end
end

local function StartAntiAim()
    if antiAimConnection then
        antiAimConnection:Disconnect()
        antiAimConnection = nil
    end

    spinAngle = 0
    jitterTimer = 0
    fakeLagBuffer = {}
    originalCFrames = {}

    antiAimConnection = RunService.Heartbeat:Connect(function()
        if AntiAim.Enabled then
            if AntiAim.FakeLag and AntiAim.Mode == "Fake Lag" then
                ApplyFakeLag()
            else
                ApplyAntiAim()
            end
        end
    end)
end

local function StopAntiAim()
    if antiAimConnection then
        antiAimConnection:Disconnect()
        antiAimConnection = nil
    end

    local character = LocalPlayer.Character
    if character and originalCFrames[character] then
        local root = character:FindFirstChild("HumanoidRootPart")
        if root then
            root.CFrame = originalCFrames[character]
        end
    end

    fakeLagBuffer = {}
    originalCFrames = {}
end

local AntiAimModes = {"Jitter", "Spin", "Random", "Fake Lag"}
MovementTab:CreateDropdown({
    Name = "Anti-Aim Mode",
    Options = AntiAimModes,
    CurrentOption = "Jitter",
    Callback = function(Option)
        AntiAim.Mode = Option
    end
})

MovementTab:CreateToggle({
    Name = "Anti-Aim",
    CurrentValue = false,
    Callback = function(Value)
        AntiAim.Enabled = Value
        if Value then
            StartAntiAim()
        else
            StopAntiAim()
        end
    end
})

MovementTab:CreateSlider({
    Name = "Anti-Aim Speed",
    Range = {1, 50},
    Increment = 1,
    CurrentValue = 10,
    Callback = function(Value)
        AntiAim.Speed = Value
    end
})

MovementTab:CreateSlider({
    Name = "Anti-Aim Intensity",
    Range = {1, 20},
    Increment = 1,
    CurrentValue = 5,
    Callback = function(Value)
        AntiAim.Intensity = Value
    end
})

local PlayerTab = Window:CreateTab("Player", "user")

local FlightEnabled = false
local FlightSpeed = 75
local BodyPos, BodyGyro
local UpdateConnection
local CharAddedConnection

local function StartFlight()
    local Character = LocalPlayer.Character
    if not Character then return end

    local Humanoid = Character:FindFirstChild("Humanoid")
    local RootPart = Character:FindFirstChild("HumanoidRootPart")
    if not Humanoid or not RootPart then return end

    Humanoid.PlatformStand = true

    BodyPos = Instance.new("BodyPosition")
    BodyPos.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    BodyPos.P = 16000
    BodyPos.D = 1000
    BodyPos.Parent = RootPart

    BodyGyro = Instance.new("BodyGyro")
    BodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    BodyGyro.P = 5000
    BodyGyro.Parent = RootPart
end

local function StopFlight()
    if BodyPos then
        BodyPos:Destroy()
        BodyPos = nil
    end
    if BodyGyro then
        BodyGyro:Destroy()
        BodyGyro = nil
    end

    local Character = LocalPlayer.Character
    if Character and Character:FindFirstChild("Humanoid") then
        Character.Humanoid.PlatformStand = false
    end
end

local function UpdateFlight()
    local Character = LocalPlayer.Character
    if not Character or not Character:FindFirstChild("HumanoidRootPart") or not BodyPos or not BodyGyro then
        return
    end

    local RootPart = Character.HumanoidRootPart
    local MoveVector = Vector3.new()

    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
        MoveVector = MoveVector + Camera.CFrame.LookVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
        MoveVector = MoveVector - Camera.CFrame.LookVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
        MoveVector = MoveVector - Camera.CFrame.RightVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
        MoveVector = MoveVector + Camera.CFrame.RightVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        MoveVector = MoveVector + Vector3.new(0, 1, 0)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
        MoveVector = MoveVector - Vector3.new(0, 1, 0)
    end

    if MoveVector.Magnitude > 0 then
        MoveVector = MoveVector.Unit * FlightSpeed
    end

    BodyPos.Position = RootPart.Position + MoveVector
    BodyGyro.CFrame = Camera.CFrame
end

local function ToggleFlight(Value)
    FlightEnabled = Value

    if Value then

        CharAddedConnection = LocalPlayer.CharacterAdded:Connect(function(Character)
            Character:WaitForChild("Humanoid")
            Character:WaitForChild("HumanoidRootPart")
            StartFlight()
        end)

        if LocalPlayer.Character then
            StartFlight()
        end

        UpdateConnection = RunService.Heartbeat:Connect(UpdateFlight)
    else
        StopFlight()

        if UpdateConnection then
            UpdateConnection:Disconnect()
            UpdateConnection = nil
        end
        if CharAddedConnection then
            CharAddedConnection:Disconnect()
            CharAddedConnection = nil
        end
    end
end

PlayerTab:CreateSection("Movement")

PlayerTab:CreateToggle({
    Name = "Flight",
    CurrentValue = false,
    Callback = function(Value)
        ToggleFlight(Value)
    end
})

PlayerTab:CreateSlider({
    Name = "Flight Speed",
    Range = {50, 200},
    Increment = 5,
    CurrentValue = 75,
    Callback = function(Value)
        FlightSpeed = Value
    end
})

local NoClipEnabled = false
local NoClipConnection = nil

local function NoClipLoop()
    local Character = LocalPlayer.Character
    if Character then
        for _, Part in pairs(Character:GetDescendants()) do
            if Part:IsA("BasePart") then
                Part.CanCollide = false
            end
        end
    end
end

local function ToggleNoClip(Value)
    NoClipEnabled = Value

    if Value then

        NoClipConnection = RunService.Stepped:Connect(NoClipLoop)
    else

        if NoClipConnection then
            NoClipConnection:Disconnect()
            NoClipConnection = nil
        end

        local Character = LocalPlayer.Character
        if Character then
            for _, Part in pairs(Character:GetDescendants()) do
                if Part:IsA("BasePart") then
                    Part.CanCollide = true
                end
            end
        end
    end
end

PlayerTab:CreateToggle({
    Name = "No Clip",
    CurrentValue = false,
    Callback = function(Value)
        ToggleNoClip(Value)
    end
})

local CurrentSpeed = 16
local SpeedConnection = nil
local CharacterAddedConnection

local function SpeedLoop()
    local Character = LocalPlayer.Character
    if not Character then return end

    local Humanoid = Character:FindFirstChild("Humanoid")
    local RootPart = Character:FindFirstChild("HumanoidRootPart")
    if not Humanoid or not RootPart then return end

    Humanoid.WalkSpeed = 16

    local MoveDirection = Humanoid.MoveDirection
    if MoveDirection.Magnitude > 0 then
        local MoveVelocity = MoveDirection * CurrentSpeed
        RootPart.AssemblyLinearVelocity = Vector3.new(
                MoveVelocity.X,
                RootPart.AssemblyLinearVelocity.Y,

                MoveVelocity.Z
        )
    end
end

local function StartSpeedLoop()
    if SpeedConnection then return end
    SpeedConnection = RunService.Heartbeat:Connect(SpeedLoop)
end

local function StopSpeedLoop()
    if SpeedConnection then
        SpeedConnection:Disconnect()
        SpeedConnection = nil
    end
end

local function OnCharacterAdded(Character)
    Character:WaitForChild("Humanoid", 5)
    Character:WaitForChild("HumanoidRootPart", 5)
    task.wait(0.1)

    local Humanoid = Character.Humanoid
    Humanoid.WalkSpeed = 16

    if CurrentSpeed > 16 and not SpeedConnection then
        StartSpeedLoop()
    end
end

CharacterAddedConnection = LocalPlayer.CharacterAdded:Connect(OnCharacterAdded)

task.spawn(function()
    task.wait(1)
    if LocalPlayer.Character then
        OnCharacterAdded(LocalPlayer.Character)
    end
end)

PlayerTab:CreateSlider({
    Name = "Speed",
    Range = {16, 400},
    Increment = 5,
    CurrentValue = 16,
    Callback = function(Value)
        CurrentSpeed = Value

        if Value > 16 then
            StartSpeedLoop()
        else
            StopSpeedLoop()

            local Character = LocalPlayer.Character
            if Character and Character:FindFirstChild("Humanoid") then
                Character.Humanoid.WalkSpeed = 16
            end
        end
    end
})

local CurrentJumpPower = 50
local JumpConnection = nil
local JumpCharacterAddedConnection

local function JumpLoop()
    local Character = LocalPlayer.Character
    if not Character then return end

    local Humanoid = Character:FindFirstChild("Humanoid")
    if not Humanoid then return end

    if CurrentJumpPower > 50 then

        Humanoid.UseJumpPower = true
        Humanoid.JumpPower = CurrentJumpPower
    else

        Humanoid.UseJumpPower = false
        Humanoid.JumpHeight = 7.2
    end
end

local function StartJumpLoop()
    if JumpConnection then return end
    JumpConnection = RunService.Stepped:Connect(JumpLoop)
end

local function OnCharacterAddedJump(Character)
    Character:WaitForChild("Humanoid", 5)
    Character:WaitForChild("HumanoidRootPart", 5)
    task.wait(0.1)

    JumpLoop()

end

JumpCharacterAddedConnection = LocalPlayer.CharacterAdded:Connect(OnCharacterAddedJump)

StartJumpLoop()

task.spawn(function()
    task.wait(1)
    if LocalPlayer.Character then
        OnCharacterAddedJump(LocalPlayer.Character)
    end
end)

PlayerTab:CreateSlider({
    Name = "Jump Power",
    Range = {50, 300},
    Increment = 5,
    CurrentValue = 50,
    Callback = function(Value)
        CurrentJumpPower = Value
    end
})


print("syl loaded")