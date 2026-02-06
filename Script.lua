-- Nikit Hub - Advanced Script Hub
-- Criado para demonstração educacional

local NikitHub = {}

-- Serviços
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- Variáveis
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Configurações
local Config = {
    ESP = {
        Enabled = false,
        ShowBoxes = true,
        ShowNames = true,
        ShowDistance = true,
        ShowHealth = true,
        BoxColor = Color3.fromRGB(255, 0, 0),
        NameColor = Color3.fromRGB(255, 255, 255),
        MaxDistance = 1000
    },
    Aimbot = {
        Enabled = false,
        TeamCheck = true,
        VisibleCheck = true,
        FOV = 100,
        Smoothness = 0.5,
        TargetPart = "Head",
        ShowFOV = true,
        FOVColor = Color3.fromRGB(255, 255, 255)
    },
    GodMode = {
        Enabled = false
    }
}

-- Sistema ESP
local ESPObjects = {}

function NikitHub:CreateESP(player)
    if player == LocalPlayer then return end
    
    local esp = {
        Player = player,
        Drawings = {}
    }
    
    -- Box
    esp.Drawings.Box = Drawing.new("Square")
    esp.Drawings.Box.Thickness = 2
    esp.Drawings.Box.Filled = false
    esp.Drawings.Box.Color = Config.ESP.BoxColor
    esp.Drawings.Box.Visible = false
    esp.Drawings.Box.Transparency = 1
    
    -- Name
    esp.Drawings.Name = Drawing.new("Text")
    esp.Drawings.Name.Size = 16
    esp.Drawings.Name.Center = true
    esp.Drawings.Name.Outline = true
    esp.Drawings.Name.Color = Config.ESP.NameColor
    esp.Drawings.Name.Visible = false
    
    -- Distance
    esp.Drawings.Distance = Drawing.new("Text")
    esp.Drawings.Distance.Size = 14
    esp.Drawings.Distance.Center = true
    esp.Drawings.Distance.Outline = true
    esp.Drawings.Distance.Color = Config.ESP.NameColor
    esp.Drawings.Distance.Visible = false
    
    -- Health Bar
    esp.Drawings.HealthBar = Drawing.new("Square")
    esp.Drawings.HealthBar.Thickness = 1
    esp.Drawings.HealthBar.Filled = true
    esp.Drawings.HealthBar.Color = Color3.fromRGB(0, 255, 0)
    esp.Drawings.HealthBar.Visible = false
    
    -- Health Outline
    esp.Drawings.HealthOutline = Drawing.new("Square")
    esp.Drawings.HealthOutline.Thickness = 1
    esp.Drawings.HealthOutline.Filled = false
    esp.Drawings.HealthOutline.Color = Color3.fromRGB(0, 0, 0)
    esp.Drawings.HealthOutline.Visible = false
    
    ESPObjects[player] = esp
end

function NikitHub:RemoveESP(player)
    if ESPObjects[player] then
        for _, drawing in pairs(ESPObjects[player].Drawings) do
            drawing:Remove()
        end
        ESPObjects[player] = nil
    end
end

function NikitHub:UpdateESP()
    for player, esp in pairs(ESPObjects) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
            local hrp = player.Character.HumanoidRootPart
            local humanoid = player.Character.Humanoid
            local distance = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) 
                and (LocalPlayer.Character.HumanoidRootPart.Position - hrp.Position).Magnitude or math.huge
            
            if Config.ESP.Enabled and distance <= Config.ESP.MaxDistance then
                local vector, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                
                if onScreen then
                    local head = player.Character:FindFirstChild("Head")
                    local legPart = player.Character:FindFirstChild("LeftFoot") or player.Character:FindFirstChild("LeftLowerLeg")
                    
                    if head and legPart then
                        local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                        local legPos = Camera:WorldToViewportPoint(legPart.Position - Vector3.new(0, 0.5, 0))
                        
                        local height = math.abs(headPos.Y - legPos.Y)
                        local width = height / 2
                        
                        -- Box
                        if Config.ESP.ShowBoxes then
                            esp.Drawings.Box.Size = Vector2.new(width, height)
                            esp.Drawings.Box.Position = Vector2.new(vector.X - width/2, vector.Y - height/2)
                            esp.Drawings.Box.Visible = true
                        else
                            esp.Drawings.Box.Visible = false
                        end
                        
                        -- Name
                        if Config.ESP.ShowNames then
                            esp.Drawings.Name.Text = player.Name
                            esp.Drawings.Name.Position = Vector2.new(vector.X, headPos.Y - 20)
                            esp.Drawings.Name.Visible = true
                        else
                            esp.Drawings.Name.Visible = false
                        end
                        
                        -- Distance
                        if Config.ESP.ShowDistance then
                            esp.Drawings.Distance.Text = math.floor(distance) .. "m"
                            esp.Drawings.Distance.Position = Vector2.new(vector.X, legPos.Y + 5)
                            esp.Drawings.Distance.Visible = true
                        else
                            esp.Drawings.Distance.Visible = false
                        end
                        
                        -- Health Bar
                        if Config.ESP.ShowHealth then
                            local healthPercent = humanoid.Health / humanoid.MaxHealth
                            esp.Drawings.HealthBar.Size = Vector2.new(3, height * healthPercent)
                            esp.Drawings.HealthBar.Position = Vector2.new(vector.X - width/2 - 6, vector.Y - height/2 + (height * (1 - healthPercent)))
                            esp.Drawings.HealthBar.Color = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 0)
                            esp.Drawings.HealthBar.Visible = true
                            
                            esp.Drawings.HealthOutline.Size = Vector2.new(3, height)
                            esp.Drawings.HealthOutline.Position = Vector2.new(vector.X - width/2 - 6, vector.Y - height/2)
                            esp.Drawings.HealthOutline.Visible = true
                        else
                            esp.Drawings.HealthBar.Visible = false
                            esp.Drawings.HealthOutline.Visible = false
                        end
                    end
                else
                    for _, drawing in pairs(esp.Drawings) do
                        drawing.Visible = false
                    end
                end
            else
                for _, drawing in pairs(esp.Drawings) do
                    drawing.Visible = false
                end
            end
        else
            for _, drawing in pairs(esp.Drawings) do
                drawing.Visible = false
            end
        end
    end
end

-- Sistema Aimbot
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.NumSides = 50
FOVCircle.Radius = Config.Aimbot.FOV
FOVCircle.Filled = false
FOVCircle.Color = Config.Aimbot.FOVColor
FOVCircle.Transparency = 1
FOVCircle.Visible = false

function NikitHub:GetClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = Config.Aimbot.FOV
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(Config.Aimbot.TargetPart) and player.Character:FindFirstChild("Humanoid") then
            if player.Character.Humanoid.Health > 0 then
                if Config.Aimbot.TeamCheck and player.Team == LocalPlayer.Team then
                    continue
                end
                
                local part = player.Character[Config.Aimbot.TargetPart]
                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                
                if onScreen then
                    local mousePos = Vector2.new(Mouse.X, Mouse.Y)
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    
                    if distance < shortestDistance then
                        if Config.Aimbot.VisibleCheck then
                            local ray = Ray.new(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * 1000)
                            local hitPart = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, Camera})
                            
                            if hitPart and hitPart:IsDescendantOf(player.Character) then
                                closestPlayer = player
                                shortestDistance = distance
                            end
                        else
                            closestPlayer = player
                            shortestDistance = distance
                        end
                    end
                end
            end
        end
    end
    
    return closestPlayer
end

function NikitHub:UpdateAimbot()
    if Config.Aimbot.Enabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = self:GetClosestPlayer()
        
        if target and target.Character and target.Character:FindFirstChild(Config.Aimbot.TargetPart) then
            local targetPart = target.Character[Config.Aimbot.TargetPart]
            local targetPos = Camera:WorldToViewportPoint(targetPart.Position)
            local mousePos = Vector2.new(Mouse.X, Mouse.Y)
            
            local smoothX = mousePos.X + (targetPos.X - mousePos.X) * Config.Aimbot.Smoothness
            local smoothY = mousePos.Y + (targetPos.Y - mousePos.Y) * Config.Aimbot.Smoothness
            
            mousemoverel((smoothX - mousePos.X), (smoothY - mousePos.Y))
        end
    end
end

function NikitHub:UpdateFOV()
    FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y)
    FOVCircle.Radius = Config.Aimbot.FOV
    FOVCircle.Visible = Config.Aimbot.Enabled and Config.Aimbot.ShowFOV
end

-- Sistema God Mode
function NikitHub:ToggleGodMode()
    if Config.GodMode.Enabled then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
            LocalPlayer.Character.Humanoid.MaxHealth = math.huge
            LocalPlayer.Character.Humanoid.Health = math.huge
        end
    else
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
            LocalPlayer.Character.Humanoid.MaxHealth = 100
            LocalPlayer.Character.Humanoid.Health = 100
        end
    end
end

-- Interface GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NikitHub"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false

-- Proteção
pcall(function()
    ScreenGui.Parent = CoreGui
end)
if ScreenGui.Parent ~= CoreGui then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -175)
MainFrame.Size = UDim2.new(0, 400, 0, 350)
MainFrame.Active = true
MainFrame.Draggable = true

-- Sombra
local Shadow = Instance.new("ImageLabel")
Shadow.Name = "Shadow"
Shadow.Parent = MainFrame
Shadow.BackgroundTransparency = 1
Shadow.Position = UDim2.new(0, -15, 0, -15)
Shadow.Size = UDim2.new(1, 30, 1, 30)
Shadow.ZIndex = 0
Shadow.Image = "rbxassetid://6014261993"
Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
Shadow.ImageTransparency = 0.5
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(49, 49, 450, 450)

-- UICorner para Main Frame
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

-- Header
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Parent = MainFrame
Header.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
Header.BorderSizePixel = 0
Header.Size = UDim2.new(1, 0, 0, 40)

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 10)
HeaderCorner.Parent = Header

-- Correção do canto inferior do header
local HeaderFix = Instance.new("Frame")
HeaderFix.Parent = Header
HeaderFix.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
HeaderFix.BorderSizePixel = 0
HeaderFix.Position = UDim2.new(0, 0, 1, -10)
HeaderFix.Size = UDim2.new(1, 0, 0, 10)

-- Título
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Parent = Header
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Font = Enum.Font.GothamBold
Title.Text = "🎮 NIKIT HUB"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Botão Fechar
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Parent = Header
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseButton.BorderSizePixel = 0
CloseButton.Position = UDim2.new(1, -35, 0.5, -12)
CloseButton.Size = UDim2.new(0, 24, 0, 24)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 14

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseButton

-- Container de Conteúdo
local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Parent = MainFrame
ContentFrame.BackgroundTransparency = 1
ContentFrame.BorderSizePixel = 0
ContentFrame.Position = UDim2.new(0, 0, 0, 50)
ContentFrame.Size = UDim2.new(1, 0, 1, -50)
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ContentFrame.ScrollBarThickness = 4
ContentFrame.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 70)

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.Parent = ContentFrame
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContentLayout.Padding = UDim.new(0, 10)
ContentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local ContentPadding = Instance.new("UIPadding")
ContentPadding.Parent = ContentFrame
ContentPadding.PaddingTop = UDim.new(0, 10)
ContentPadding.PaddingBottom = UDim.new(0, 10)
ContentPadding.PaddingLeft = UDim.new(0, 15)
ContentPadding.PaddingRight = UDim.new(0, 15)

-- Função para criar seções
function NikitHub:CreateSection(name)
    local Section = Instance.new("Frame")
    Section.Name = name
    Section.Parent = ContentFrame
    Section.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    Section.BorderSizePixel = 0
    Section.Size = UDim2.new(1, -15, 0, 0)
    
    local SectionCorner = Instance.new("UICorner")
    SectionCorner.CornerRadius = UDim.new(0, 8)
    SectionCorner.Parent = Section
    
    local SectionTitle = Instance.new("TextLabel")
    SectionTitle.Name = "SectionTitle"
    SectionTitle.Parent = Section
    SectionTitle.BackgroundTransparency = 1
    SectionTitle.Position = UDim2.new(0, 12, 0, 8)
    SectionTitle.Size = UDim2.new(1, -24, 0, 25)
    SectionTitle.Font = Enum.Font.GothamBold
    SectionTitle.Text = name
    SectionTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
    SectionTitle.TextSize = 14
    SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    local SectionContent = Instance.new("Frame")
    SectionContent.Name = "SectionContent"
    SectionContent.Parent = Section
    SectionContent.BackgroundTransparency = 1
    SectionContent.Position = UDim2.new(0, 12, 0, 38)
    SectionContent.Size = UDim2.new(1, -24, 1, -48)
    
    local SectionLayout = Instance.new("UIListLayout")
    SectionLayout.Parent = SectionContent
    SectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
    SectionLayout.Padding = UDim.new(0, 8)
    
    return Section, SectionContent
end

-- Função para criar toggle
function NikitHub:CreateToggle(parent, text, default, callback)
    local Toggle = Instance.new("Frame")
    Toggle.Name = text
    Toggle.Parent = parent
    Toggle.BackgroundTransparency = 1
    Toggle.Size = UDim2.new(1, 0, 0, 30)
    
    local ToggleLabel = Instance.new("TextLabel")
    ToggleLabel.Parent = Toggle
    ToggleLabel.BackgroundTransparency = 1
    ToggleLabel.Size = UDim2.new(1, -50, 1, 0)
    ToggleLabel.Font = Enum.Font.Gotham
    ToggleLabel.Text = text
    ToggleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    ToggleLabel.TextSize = 13
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Parent = Toggle
    ToggleButton.BackgroundColor3 = default and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(60, 60, 70)
    ToggleButton.BorderSizePixel = 0
    ToggleButton.Position = UDim2.new(1, -40, 0.5, -12)
    ToggleButton.Size = UDim2.new(0, 40, 0, 24)
    ToggleButton.Font = Enum.Font.Gotham
    ToggleButton.Text = ""
    ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleButton.TextSize = 12
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(1, 0)
    ToggleCorner.Parent = ToggleButton
    
    local ToggleIndicator = Instance.new("Frame")
    ToggleIndicator.Parent = ToggleButton
    ToggleIndicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ToggleIndicator.BorderSizePixel = 0
    ToggleIndicator.Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 4, 0.5, -8)
    ToggleIndicator.Size = UDim2.new(0, 16, 0, 16)
    
    local IndicatorCorner = Instance.new("UICorner")
    IndicatorCorner.CornerRadius = UDim.new(1, 0)
    IndicatorCorner.Parent = ToggleIndicator
    
    local enabled = default
    
    ToggleButton.MouseButton1Click:Connect(function()
        enabled = not enabled
        
        ToggleButton.BackgroundColor3 = enabled and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(60, 60, 70)
        ToggleIndicator:TweenPosition(
            enabled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 4, 0.5, -8),
            Enum.EasingDirection.Out,
            Enum.EasingStyle.Quad,
            0.2,
            true
        )
        
        callback(enabled)
    end)
    
    return Toggle
end

-- Função para criar slider
function NikitHub:CreateSlider(parent, text, min, max, default, callback)
    local Slider = Instance.new("Frame")
    Slider.Name = text
    Slider.Parent = parent
    Slider.BackgroundTransparency = 1
    Slider.Size = UDim2.new(1, 0, 0, 50)
    
    local SliderLabel = Instance.new("TextLabel")
    SliderLabel.Parent = Slider
    SliderLabel.BackgroundTransparency = 1
    SliderLabel.Size = UDim2.new(0.7, 0, 0, 20)
    SliderLabel.Font = Enum.Font.Gotham
    SliderLabel.Text = text
    SliderLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    SliderLabel.TextSize = 13
    SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local SliderValue = Instance.new("TextLabel")
    SliderValue.Parent = Slider
    SliderValue.BackgroundTransparency = 1
    SliderValue.Position = UDim2.new(0.7, 0, 0, 0)
    SliderValue.Size = UDim2.new(0.3, 0, 0, 20)
    SliderValue.Font = Enum.Font.GothamBold
    SliderValue.Text = tostring(default)
    SliderValue.TextColor3 = Color3.fromRGB(100, 200, 255)
    SliderValue.TextSize = 13
    SliderValue.TextXAlignment = Enum.TextXAlignment.Right
    
    local SliderBar = Instance.new("Frame")
    Sl
