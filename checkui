-- ============================================================
--  UILib.lua - Complete Standalone UI Library
--  Version 2.0.0
--  GitHub-Ready | Loadstring-Ready | Module-Ready
--  Features: Tabs, Sections, Buttons, Toggles, Labels,
--  Paragraphs, Textboxes, Dropdowns, Sliders, Keybinds,
--  Notifications, Theme System, Animation Engine
-- ============================================================

local UILib = {}

-- ============================================================
-- SERVICES
-- ============================================================
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- ============================================================
-- DEFAULT THEME
-- ============================================================
local DefaultTheme = {
    Background = Color3.fromRGB(14, 17, 26),
    Secondary = Color3.fromRGB(20, 24, 36),
    Tertiary = Color3.fromRGB(26, 30, 44),
    Accent = Color3.fromRGB(0, 200, 255),
    AccentDim = Color3.fromRGB(20, 80, 200),
    AccentBright = Color3.fromRGB(80, 220, 255),
    TextPrimary = Color3.fromRGB(235, 245, 255),
    TextSecondary = Color3.fromRGB(130, 150, 190),
    TextMuted = Color3.fromRGB(80, 100, 140),
    Success = Color3.fromRGB(60, 220, 130),
    Warning = Color3.fromRGB(255, 200, 50),
    Danger = Color3.fromRGB(235, 100, 100),
    InputBg = Color3.fromRGB(10, 14, 24),
    ToggleOff = Color3.fromRGB(40, 45, 65),
    ToggleOn = Color3.fromRGB(0, 200, 255),
    Knob = Color3.fromRGB(255, 255, 255),
    Border = Color3.fromRGB(40, 50, 80),
    Glow = Color3.fromRGB(0, 200, 255),
    CornerRadius = 10,
    TweenSpeed = 0.2,
}

local ActiveTheme = {}
for k, v in pairs(DefaultTheme) do ActiveTheme[k] = v end

-- ============================================================
-- UTILITY FUNCTIONS
-- ============================================================
local function CreateCorner(instance, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = radius or UDim.new(0, ActiveTheme.CornerRadius)
    corner.Parent = instance
    return corner
end

local function CreateStroke(instance, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or ActiveTheme.Border
    stroke.Thickness = thickness or 1
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = instance
    return stroke
end

local function CreateGradient(instance, colors, rotation)
    local grad = Instance.new("UIGradient")
    local seq = {}
    for i, color in ipairs(colors) do
        table.insert(seq, ColorSequenceKeypoint.new((i-1)/(#colors-1), color))
    end
    grad.Color = ColorSequence.new(seq)
    grad.Rotation = rotation or 45
    grad.Parent = instance
    return grad
end

local function CreateGlow(parent, color, size, transparency)
    local glow = Instance.new("ImageLabel")
    glow.Name = "Glow"
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://5028857084"
    glow.ImageColor3 = color or ActiveTheme.Glow
    glow.ImageTransparency = transparency or 0.5
    glow.ScaleType = Enum.ScaleType.Slice
    glow.SliceCenter = Rect.new(20, 20, 20, 20)
    glow.Size = UDim2.new(1, size or 40, 1, size or 40)
    glow.Position = UDim2.new(0.5, 0, 0.5, 0)
    glow.AnchorPoint = Vector2.new(0.5, 0.5)
    glow.ZIndex = 0
    glow.Parent = parent
    return glow
end

local function TweenObject(obj, properties, duration)
    duration = duration or ActiveTheme.TweenSpeed
    local info = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(obj, info, properties)
    tween:Play()
    return tween
end

-- ============================================================
-- NOTIFICATION SYSTEM
-- ============================================================
local Notifications = {}

function UILib:Notify(title, message, duration, type)
    duration = duration or 3
    type = type or "info"
    
    local colors = {
        info = ActiveTheme.Accent,
        success = ActiveTheme.Success,
        warning = ActiveTheme.Warning,
        error = ActiveTheme.Danger,
    }
    
    local color = colors[type] or ActiveTheme.Accent
    
    -- Create notification container
    local notification = Instance.new("Frame")
    notification.Size = UDim2.new(0, 350, 0, 60)
    notification.Position = UDim2.new(1, 20, 0, 20)
    notification.AnchorPoint = Vector2.new(1, 0)
    notification.BackgroundColor3 = ActiveTheme.Secondary
    notification.BackgroundTransparency = 0.9
    notification.BorderSizePixel = 0
    notification.Parent = PlayerGui
    CreateCorner(notification, UDim.new(0, 8))
    CreateStroke(notification, color, 1.5)
    CreateGlow(notification, color, 30, 0.6)
    
    -- Icon
    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(0, 30, 1, 0)
    icon.Position = UDim2.new(0, 10, 0, 0)
    icon.BackgroundTransparency = 1
    icon.Font = Enum.Font.GothamBold
    icon.TextSize = 18
    icon.TextColor3 = color
    icon.Text = type == "info" and "ℹ" or
                type == "success" and "✓" or
                type == "warning" and "⚠" or "✕"
    icon.TextXAlignment = Enum.TextXAlignment.Center
    icon.Parent = notification
    
    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -50, 0, 22)
    titleLabel.Position = UDim2.new(0, 45, 0, 4)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 14
    titleLabel.TextColor3 = ActiveTheme.TextPrimary
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Text = title
    titleLabel.Parent = notification
    
    -- Message
    local msgLabel = Instance.new("TextLabel")
    msgLabel.Size = UDim2.new(1, -50, 0, 22)
    msgLabel.Position = UDim2.new(0, 45, 0, 28)
    msgLabel.BackgroundTransparency = 1
    msgLabel.Font = Enum.Font.Gotham
    msgLabel.TextSize = 12
    msgLabel.TextColor3 = ActiveTheme.TextSecondary
    msgLabel.TextXAlignment = Enum.TextXAlignment.Left
    msgLabel.Text = message
    msgLabel.Parent = notification
    
    -- Close button
    local close = Instance.new("TextButton")
    close.Size = UDim2.new(0, 24, 0, 24)
    close.Position = UDim2.new(1, -30, 0, 4)
    close.BackgroundTransparency = 1
    close.Font = Enum.Font.GothamBold
    close.TextSize = 14
    close.TextColor3 = ActiveTheme.TextMuted
    close.Text = "✕"
    close.Parent = notification
    close.MouseButton1Click:Connect(function()
        TweenObject(notification, {Position = UDim2.new(1, 20, 0, 20), BackgroundTransparency = 1}, 0.2)
        task.wait(0.2)
        notification:Destroy()
    end)
    
    -- Animate in
    notification.Position = UDim2.new(1, 20, 0, -80)
    task.wait(0.05)
    TweenObject(notification, {Position = UDim2.new(1, 20, 0, 20)})
    
    -- Auto dismiss
    task.spawn(function()
        task.wait(duration)
        TweenObject(notification, {Position = UDim2.new(1, 20, 0, -80), BackgroundTransparency = 1}, 0.3)
        task.wait(0.3)
        notification:Destroy()
    end)
    
    return notification
end

-- ============================================================
-- THEME SYSTEM
-- ============================================================
function UILib:SetTheme(theme)
    for k, v in pairs(theme) do
        ActiveTheme[k] = v
    end
    -- Update all existing windows
    for _, window in pairs(UILib.Windows or {}) do
        window:UpdateTheme()
    end
end

function UILib:GetTheme()
    return ActiveTheme
end

function UILib:ResetTheme()
    for k, v in pairs(DefaultTheme) do
        ActiveTheme[k] = v
    end
    for _, window in pairs(UILib.Windows or {}) do
        window:UpdateTheme()
    end
end

-- ============================================================
-- ANIMATION ENGINE
-- ============================================================
local AnimationEngine = {}

function UILib:Animate(object, properties, duration, style, direction)
    duration = duration or ActiveTheme.TweenSpeed
    style = style or Enum.EasingStyle.Quad
    direction = direction or Enum.EasingDirection.Out
    local info = TweenInfo.new(duration, style, direction)
    local tween = TweenService:Create(object, info, properties)
    tween:Play()
    return tween
end

function UILib:Sequence(object, animations)
    for _, anim in ipairs(animations) do
        local tween = self:Animate(object, anim.properties, anim.duration, anim.style, anim.direction)
        tween.Completed:Wait()
    end
end

-- ============================================================
-- WINDOW CLASS
-- ============================================================
local Window = {}
Window.__index = Window

UILib.Windows = {}

function UILib:CreateWindow(options)
    options = options or {}
    
    local self = setmetatable({}, Window)
    self.Title = options.Title or "UI Library"
    self.Size = options.Size or UDim2.new(0, 500, 0, 400)
    self.MinSize = options.MinSize or UDim2.new(0, 400, 0, 300)
    self.Position = options.Position or UDim2.new(0.5, -250, 0.5, -200)
    self.Draggable = options.Draggable == nil and true or options.Draggable
    self.Resizable = options.Resizable or false
    self.Theme = {}
    self.Tabs = {}
    self.ActiveTab = nil
    self.Objects = {}
    
    -- Create main frame
    self.Frame = Instance.new("Frame")
    self.Frame.Size = self.Size
    self.Frame.Position = self.Position
    self.Frame.BackgroundColor3 = ActiveTheme.Background
    self.Frame.BackgroundTransparency = 0.08
    self.Frame.ClipsDescendants = true
    self.Frame.Parent = PlayerGui
    CreateCorner(self.Frame, UDim.new(0, 12))
    CreateStroke(self.Frame, ActiveTheme.Border, 1.2)
    CreateGlow(self.Frame, ActiveTheme.Accent, 50, 0.5)
    
    -- Title Bar
    self.TitleBar = Instance.new("Frame")
    self.TitleBar.Size = UDim2.new(1, 0, 0, 34)
    self.TitleBar.BackgroundColor3 = ActiveTheme.Background
    self.TitleBar.BackgroundTransparency = 0.3
    self.TitleBar.BorderSizePixel = 0
    self.TitleBar.Parent = self.Frame
    CreateCorner(self.TitleBar, UDim.new(0, 12))
    
    -- Title Text
    self.TitleLabel = Instance.new("TextLabel")
    self.TitleLabel.Size = UDim2.new(1, -50, 1, 0)
    self.TitleLabel.Position = UDim2.new(0, 16, 0, 0)
    self.TitleLabel.BackgroundTransparency = 1
    self.TitleLabel.Font = Enum.Font.GothamBlack
    self.TitleLabel.TextSize = 17
    self.TitleLabel.TextColor3 = ActiveTheme.AccentBright
    self.TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.TitleLabel.Text = self.Title
    self.TitleLabel.Parent = self.TitleBar
    CreateGradient(self.TitleLabel, {ActiveTheme.Accent, ActiveTheme.AccentBright}, 0)
    
    -- Close Button
    self.CloseBtn = Instance.new("TextButton")
    self.CloseBtn.Size = UDim2.new(0, 26, 0, 22)
    self.CloseBtn.AnchorPoint = Vector2.new(1, 0.5)
    self.CloseBtn.Position = UDim2.new(1, -10, 0.5, 0)
    self.CloseBtn.BackgroundColor3 = ActiveTheme.AccentDim
    self.CloseBtn.BorderSizePixel = 0
    self.CloseBtn.Font = Enum.Font.GothamBlack
    self.CloseBtn.TextSize = 16
    self.CloseBtn.TextColor3 = ActiveTheme.TextSecondary
    self.CloseBtn.Text = "✕"
    self.CloseBtn.Parent = self.TitleBar
    CreateCorner(self.CloseBtn, UDim.new(0, 6))
    
    self.CloseBtn.MouseButton1Click:Connect(function()
        self:Destroy()
    end)
    self.CloseBtn.MouseEnter:Connect(function()
        TweenObject(self.CloseBtn, {BackgroundColor3 = ActiveTheme.Danger})
    end)
    self.CloseBtn.MouseLeave:Connect(function()
        TweenObject(self.CloseBtn, {BackgroundColor3 = ActiveTheme.AccentDim})
    end)
    
    -- Minimize Button
    self.MinBtn = Instance.new("TextButton")
    self.MinBtn.Size = UDim2.new(0, 26, 0, 22)
    self.MinBtn.AnchorPoint = Vector2.new(1, 0.5)
    self.MinBtn.Position = UDim2.new(1, -42, 0.5, 0)
    self.MinBtn.BackgroundColor3 = ActiveTheme.AccentDim
    self.MinBtn.BorderSizePixel = 0
    self.MinBtn.Font = Enum.Font.GothamBlack
    self.MinBtn.TextSize = 16
    self.MinBtn.TextColor3 = ActiveTheme.TextSecondary
    self.MinBtn.Text = "−"
    self.MinBtn.Parent = self.TitleBar
    CreateCorner(self.MinBtn, UDim.new(0, 6))
    
    self.Minimized = false
    self.MinBtn.MouseButton1Click:Connect(function()
        self.Minimized = not self.Minimized
        self.MinBtn.Text = self.Minimized and "+" or "−"
        if self.Minimized then
            self.Frame.Size = UDim2.new(self.Size.X.Scale, self.Size.X.Offset, 0, 34)
        else
            self.Frame.Size = self.Size
        end
    end)
    
    -- Content Container
    self.Content = Instance.new("Frame")
    self.Content.Size = UDim2.new(1, 0, 1, -34)
    self.Content.Position = UDim2.new(0, 0, 0, 34)
    self.Content.BackgroundTransparency = 1
    self.Content.Parent = self.Frame
    
    -- Tab Bar
    self.TabBar = Instance.new("Frame")
    self.TabBar.Size = UDim2.new(1, 0, 0, 44)
    self.TabBar.BackgroundTransparency = 1
    self.TabBar.Parent = self.Content
    
    self.TabLayout = Instance.new("UIListLayout")
    self.TabLayout.FillDirection = Enum.FillDirection.Horizontal
    self.TabLayout.Padding = UDim.new(0, 4)
    self.TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    self.TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    self.TabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    self.TabLayout.Parent = self.TabBar
    
    self.TabPadding = Instance.new("UIPadding")
    self.TabPadding.PaddingLeft = UDim.new(0, 8)
    self.TabPadding.PaddingRight = UDim.new(0, 8)
    self.TabPadding.PaddingTop = UDim.new(0, 4)
    self.TabPadding.PaddingBottom = UDim.new(0, 4)
    self.TabPadding.Parent = self.TabBar
    
    -- Tab Content
    self.TabContent = Instance.new("Frame")
    self.TabContent.Size = UDim2.new(1, 0, 1, -44)
    self.TabContent.Position = UDim2.new(0, 0, 0, 44)
    self.TabContent.BackgroundTransparency = 1
    self.TabContent.Parent = self.Content
    
    -- Drag functionality
    if self.Draggable then
        local dragData = {dragging = false, start = nil, pos = nil}
        self.TitleBar.InputBegan:Connect(function(input)
            if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
            dragData.dragging = true
            dragData.start = input.Position
            dragData.pos = self.Frame.Position
        end)
        UserInputService.InputChanged:Connect(function(input)
            if not dragData.dragging then return end
            if input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
            local delta = input.Position - dragData.start
            self.Frame.Position = UDim2.new(
                dragData.pos.X.Scale, dragData.pos.X.Offset + delta.X,
                dragData.pos.Y.Scale, dragData.pos.Y.Offset + delta.Y
            )
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragData.dragging = false
            end
        end)
    end
    
    table.insert(UILib.Windows, self)
    return self
end

-- ============================================================
-- WINDOW METHODS
-- ============================================================
function Window:Destroy()
    self.Frame:Destroy()
    for i, win in ipairs(UILib.Windows) do
        if win == self then
            table.remove(UILib.Windows, i)
            break
        end
    end
end

function Window:UpdateTheme()
    self.Frame.BackgroundColor3 = ActiveTheme.Background
    self.TitleBar.BackgroundColor3 = ActiveTheme.Background
    self.TitleLabel.TextColor3 = ActiveTheme.AccentBright
    self.CloseBtn.BackgroundColor3 = ActiveTheme.AccentDim
    self.MinBtn.BackgroundColor3 = ActiveTheme.AccentDim
    for _, tab in ipairs(self.Tabs) do
        tab:UpdateTheme()
    end
end

-- ============================================================
-- TAB CLASS
-- ============================================================
local Tab = {}
Tab.__index = Tab

function Window:CreateTab(name)
    local self = setmetatable({}, Tab)
    self.Window = self
    self.Name = name
    self.Objects = {}
    self.Sections = {}
    
    -- Tab Button
    self.Button = Instance.new("TextButton")
    self.Button.Size = UDim2.new(0, 80, 1, -8)
    self.Button.BackgroundColor3 = ActiveTheme.Tertiary
    self.Button.BackgroundTransparency = 0.5
    self.Button.BorderSizePixel = 0
    self.Button.AutoButtonColor = false
    self.Button.Font = Enum.Font.GothamBold
    self.Button.TextSize = 12
    self.Button.TextColor3 = ActiveTheme.TextSecondary
    self.Button.Text = name
    self.Button.Parent = self.Window.TabBar
    CreateCorner(self.Button, UDim.new(0, 8))
    CreateStroke(self.Button, ActiveTheme.Border, 1)
    
    -- Tab Content Frame
    self.Content = Instance.new("ScrollingFrame")
    self.Content.Size = UDim2.new(1, 0, 1, 0)
    self.Content.BackgroundTransparency = 1
    self.Content.BorderSizePixel = 0
    self.Content.ScrollBarThickness = 3
    self.Content.ScrollBarImageColor3 = ActiveTheme.AccentDim
    self.Content.AutomaticCanvasSize = Enum.AutomaticSize.Y
    self.Content.CanvasSize = UDim2.new(0, 0, 0, 0)
    self.Content.ClipsDescendants = true
    self.Content.Visible = false
    self.Content.Parent = self.Window.TabContent
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.VerticalAlignment = Enum.VerticalAlignment.Top
    layout.Parent = self.Content
    
    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 12)
    pad.PaddingRight = UDim.new(0, 12)
    pad.PaddingTop = UDim.new(0, 8)
    pad.PaddingBottom = UDim.new(0, 8)
    pad.Parent = self.Content
    
    -- Click handler
    self.Button.MouseButton1Click:Connect(function()
        self.Window:SelectTab(self)
    end)
    self.Button.MouseEnter:Connect(function()
        if self.Window.ActiveTab ~= self then
            TweenObject(self.Button, {BackgroundColor3 = ActiveTheme.AccentDim, BackgroundTransparency = 0.3})
        end
    end)
    self.Button.MouseLeave:Connect(function()
        if self.Window.ActiveTab ~= self then
            TweenObject(self.Button, {BackgroundColor3 = ActiveTheme.Tertiary, BackgroundTransparency = 0.5})
        end
    end)
    
    table.insert(self.Window.Tabs, self)
    
    -- Auto-select first tab
    if not self.Window.ActiveTab then
        self.Window:SelectTab(self)
    end
    
    return self
end

function Tab:UpdateTheme()
    self.Button.BackgroundColor3 = self.Window.ActiveTab == self and ActiveTheme.AccentDim or ActiveTheme.Tertiary
    self.Button.BackgroundTransparency = self.Window.ActiveTab == self and 0.1 or 0.5
    self.Button.TextColor3 = self.Window.ActiveTab == self and ActiveTheme.TextPrimary or ActiveTheme.TextSecondary
end

function Window:SelectTab(tab)
    if self.ActiveTab then
        self.ActiveTab.Content.Visible = false
        self.ActiveTab.Button.BackgroundColor3 = ActiveTheme.Tertiary
        self.ActiveTab.Button.BackgroundTransparency = 0.5
        self.ActiveTab.Button.TextColor3 = ActiveTheme.TextSecondary
    end
    self.ActiveTab = tab
    tab.Content.Visible = true
    tab.Button.BackgroundColor3 = ActiveTheme.AccentDim
    tab.Button.BackgroundTransparency = 0.1
    tab.Button.TextColor3 = ActiveTheme.TextPrimary
end

-- ============================================================
-- SECTION CLASS
-- ============================================================
function Tab:CreateSection(name)
    local section = {}
    section.Name = name
    section.Objects = {}
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 0)
    frame.BackgroundColor3 = ActiveTheme.Secondary
    frame.BackgroundTransparency = 0.2
    frame.AutomaticSize = Enum.AutomaticSize.Y
    frame.Parent = self.Content
    CreateCorner(frame, UDim.new(0, 8))
    CreateStroke(frame, ActiveTheme.Border, 1)
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -16, 0, 30)
    title.Position = UDim2.new(0, 8, 0, 4)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.TextColor3 = ActiveTheme.TextPrimary
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Text = name
    title.Parent = frame
    
    local divider = Instance.new("Frame")
    divider.Size = UDim2.new(1, -16, 0, 1)
    divider.Position = UDim2.new(0, 8, 0, 36)
    divider.BackgroundColor3 = ActiveTheme.AccentDim
    divider.BackgroundTransparency = 0.3
    divider.BorderSizePixel = 0
    divider.Parent = frame
    
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -16, 0, 0)
    content.Position = UDim2.new(0, 8, 0, 40)
    content.BackgroundTransparency = 1
    content.AutomaticSize = Enum.AutomaticSize.Y
    content.Parent = frame
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 6)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.VerticalAlignment = Enum.VerticalAlignment.Top
    layout.Parent = content
    
    local pad = Instance.new("UIPadding")
    pad.PaddingBottom = UDim.new(0, 8)
    pad.Parent = content
    
    section.Frame = frame
    section.Content = content
    section.Layout = layout
    section.Title = title
    
    table.insert(self.Sections, section)
    return section
end

-- ============================================================
-- BUTTON COMPONENT
-- ============================================================
function Tab:CreateButton(options)
    options = options or {}
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 34)
    btn.BackgroundColor3 = ActiveTheme.Tertiary
    btn.BackgroundTransparency = 0.4
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    btn.TextColor3 = ActiveTheme.TextPrimary
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Text = options.Name or "Button"
    btn.Parent = self.Content
    CreateCorner(btn, UDim.new(0, 6))
    CreateStroke(btn, ActiveTheme.Border, 1)
    
    -- Icon
    if options.Icon then
        local icon = Instance.new("TextLabel")
        icon.Size = UDim2.new(0, 24, 1, 0)
        icon.Position = UDim2.new(0, 8, 0, 0)
        icon.BackgroundTransparency = 1
        icon.Font = Enum.Font.Gotham
        icon.TextSize = 16
        icon.TextColor3 = ActiveTheme.Accent
        icon.TextXAlignment = Enum.TextXAlignment.Center
        icon.Text = options.Icon
        icon.Parent = btn
    end
    
    -- Description (optional)
    if options.Description then
        local desc = Instance.new("TextLabel")
        desc.Size = UDim2.new(1, -16, 0, 14)
        desc.Position = UDim2.new(0, 8, 0, 34)
        desc.BackgroundTransparency = 1
        desc.Font = Enum.Font.Gotham
        desc.TextSize = 10
        desc.TextColor3 = ActiveTheme.TextSecondary
        desc.TextXAlignment = Enum.TextXAlignment.Left
        desc.Text = options.Description
        desc.Parent = btn
        btn.Size = UDim2.new(1, 0, 0, 50)
    end
    
    btn.MouseButton1Click:Connect(function()
        if options.Callback then
            options.Callback()
        end
    end)
    
    btn.MouseEnter:Connect(function()
        TweenObject(btn, {BackgroundColor3 = ActiveTheme.AccentDim, BackgroundTransparency = 0.2})
        TweenObject(btn:FindFirstChildWhichIsA("UIStroke") or Instance.new("UIStroke"), {Color = ActiveTheme.Accent})
    end)
    
    btn.MouseLeave:Connect(function()
        TweenObject(btn, {BackgroundColor3 = ActiveTheme.Tertiary, BackgroundTransparency = 0.4})
        TweenObject(btn:FindFirstChildWhichIsA("UIStroke") or Instance.new("UIStroke"), {Color = ActiveTheme.Border})
    end)
    
    return btn
end

-- ============================================================
-- TOGGLE COMPONENT
-- ============================================================
function Tab:CreateToggle(options)
    options = options or {}
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 34)
    frame.BackgroundColor3 = ActiveTheme.Tertiary
    frame.BackgroundTransparency = 0.4
    frame.Parent = self.Content
    CreateCorner(frame, UDim.new(0, 6))
    CreateStroke(frame, ActiveTheme.Border, 1)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -70, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextColor3 = ActiveTheme.TextPrimary
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = options.Name or "Toggle"
    label.Parent = frame
    
    -- Description
    if options.Description then
        label.Size = UDim2.new(1, -70, 0, 16)
        label.TextSize = 12
        
        local desc = Instance.new("TextLabel")
        desc.Size = UDim2.new(1, -70, 0, 14)
        desc.Position = UDim2.new(0, 12, 0, 18)
        desc.BackgroundTransparency = 1
        desc.Font = Enum.Font.Gotham
        desc.TextSize = 10
        desc.TextColor3 = ActiveTheme.TextSecondary
        desc.TextXAlignment = Enum.TextXAlignment.Left
        desc.Text = options.Description
        desc.Parent = frame
        frame.Size = UDim2.new(1, 0, 0, 50)
    end
    
    -- Toggle track
    local track = Instance.new("Frame")
    track.AnchorPoint = Vector2.new(1, 0.5)
    track.Position = UDim2.new(1, -12, 0.5, 0)
    track.Size = UDim2.new(0, 40, 0, 20)
    track.BackgroundColor3 = options.Default and ActiveTheme.ToggleOn or ActiveTheme.ToggleOff
    track.Parent = frame
    CreateCorner(track, UDim.new(1, 0))
    
    -- Toggle knob
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = options.Default and UDim2.new(0, 22, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    knob.BackgroundColor3 = ActiveTheme.Knob
    knob.Parent = track
    CreateCorner(knob, UDim.new(1, 0))
    
    -- Click area
    local click = Instance.new("TextButton")
    click.Size = UDim2.new(1, 0, 1, 0)
    click.BackgroundTransparency = 1
    click.Text = ""
    click.Parent = frame
    
    local state = options.Default or false
    
    local function SetState(newState)
        state = newState
        TweenObject(track, {BackgroundColor3 = state and ActiveTheme.ToggleOn or ActiveTheme.ToggleOff})
        TweenObject(knob, {Position = state and UDim2.new(0, 22, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)})
        if options.Callback then
            options.Callback(state)
        end
    end
    
    click.MouseButton1Click:Connect(function()
        SetState(not state)
    end)
    
    click.MouseEnter:Connect(function()
        TweenObject(frame, {BackgroundColor3 = ActiveTheme.AccentDim, BackgroundTransparency = 0.2})
    end)
    click.MouseLeave:Connect(function()
        TweenObject(frame, {BackgroundColor3 = ActiveTheme.Tertiary, BackgroundTransparency = 0.4})
    end)
    
    return {
        SetState = SetState,
        GetState = function() return state end,
    }
end

-- ============================================================
-- LABEL COMPONENT
-- ============================================================
function Tab:CreateLabel(options)
    options = options or {}
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, options.Height or 22)
    label.BackgroundTransparency = 1
    label.Font = options.Bold and Enum.Font.GothamBold or Enum.Font.Gotham
    label.TextSize = options.Size or 13
    label.TextColor3 = options.Color or ActiveTheme.TextPrimary
    label.TextXAlignment = options.Align or Enum.TextXAlignment.Left
    label.Text = options.Text or ""
    label.Parent = self.Content
    
    if options.Wrapped then
        label.TextWrapped = true
        label.TextYAlignment = Enum.TextYAlignment.Top
        label.Size = UDim2.new(1, 0, 0, 0)
        label.AutomaticSize = Enum.AutomaticSize.Y
    end
    
    return label
end

-- ============================================================
-- PARAGRAPH COMPONENT
-- ============================================================
function Tab:CreateParagraph(options)
    options = options or {}
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 0)
    frame.BackgroundColor3 = ActiveTheme.Tertiary
    frame.BackgroundTransparency = 0.3
    frame.AutomaticSize = Enum.AutomaticSize.Y
    frame.Parent = self.Content
    CreateCorner(frame, UDim.new(0, 6))
    CreateStroke(frame, ActiveTheme.Border, 1)
    
    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 12)
    pad.PaddingRight = UDim.new(0, 12)
    pad.PaddingTop = UDim.new(0, 10)
    pad.PaddingBottom = UDim.new(0, 10)
    pad.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextColor3 = ActiveTheme.TextSecondary
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextWrapped = true
    label.TextYAlignment = Enum.TextYAlignment.Top
    label.AutomaticSize = Enum.AutomaticSize.Y
    label.Text = options.Text or ""
    label.Parent = frame
    
    return label
end

-- ============================================================
-- TEXTBOX COMPONENT
-- ============================================================
function Tab:CreateTextbox(options)
    options = options or {}
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, options.Height or 34)
    frame.BackgroundColor3 = ActiveTheme.InputBg
    frame.BackgroundTransparency = 0.8
    frame.Parent = self.Content
    CreateCorner(frame, UDim.new(0, 6))
    CreateStroke(frame, ActiveTheme.Border, 1)
    
    -- Label
    if options.Label then
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.4, -8, 1, 0)
        label.Position = UDim2.new(0, 10, 0, 0)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.Gotham
        label.TextSize = 12
        label.TextColor3 = ActiveTheme.TextPrimary
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Text = options.Label
        label.Parent = frame
    end
    
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, -20, 1, -6)
    box.Position = UDim2.new(0, 10, 0, 3)
    box.BackgroundTransparency = 1
    box.BorderSizePixel = 0
    box.Font = Enum.Font.Gotham
    box.TextSize = 13
    box.TextColor3 = ActiveTheme.TextPrimary
    box.TextXAlignment = Enum.TextXAlignment.Left
    box.PlaceholderText = options.Placeholder or ""
    box.PlaceholderColor3 = ActiveTheme.TextMuted
    box.ClearTextOnFocus = false
    box.Text = options.Default or ""
    box.Parent = frame
    
    if options.Label then
        box.Size = UDim2.new(0.6, -10, 1, -6)
        box.Position = UDim2.new(0.4, 10, 0, 3)
    end
    
    box.Focused:Connect(function()
        TweenObject(frame:FindFirstChildWhichIsA("UIStroke") or Instance.new("UIStroke"), {Color = ActiveTheme.Accent})
    end)
    box.FocusLost:Connect(function()
        TweenObject(frame:FindFirstChildWhichIsA("UIStroke") or Instance.new("UIStroke"), {Color = ActiveTheme.Border})
        if options.Callback then
            options.Callback(box.Text)
        end
    end)
    
    box:GetPropertyChangedSignal("Text"):Connect(function()
        if options.Changed then
            options.Changed(box.Text)
        end
    end)
    
    return box
end

-- ============================================================
-- DROPDOWN COMPONENT
-- ============================================================
function Tab:CreateDropdown(options)
    options = options or {}
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 34)
    frame.BackgroundColor3 = ActiveTheme.InputBg
    frame.BackgroundTransparency = 0.8
    frame.Parent = self.Content
    CreateCorner(frame, UDim.new(0, 6))
    CreateStroke(frame, ActiveTheme.Border, 1)
    
    -- Label
    if options.Label then
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.35, -8, 1, 0)
        label.Position = UDim2.new(0, 10, 0, 0)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.Gotham
        label.TextSize = 12
        label.TextColor3 = ActiveTheme.TextPrimary
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Text = options.Label
        label.Parent = frame
    end
    
    -- Selected display
    local display = Instance.new("TextLabel")
    display.Size = UDim2.new(0.5, -10, 1, 0)
    display.Position = UDim2.new(options.Label and 0.35 or 0, 8, 0, 0)
    display.BackgroundTransparency = 1
    display.Font = Enum.Font.Gotham
    display.TextSize = 13
    display.TextColor3 = ActiveTheme.TextPrimary
    display.TextXAlignment = Enum.TextXAlignment.Left
    display.Text = options.Default or "Select..."
    display.Parent = frame
    
    -- Arrow
    local arrow = Instance.new("TextLabel")
    arrow.AnchorPoint = Vector2.new(1, 0.5)
    arrow.Position = UDim2.new(1, -10, 0.5, 0)
    arrow.Size = UDim2.new(0, 20, 0, 20)
    arrow.BackgroundTransparency = 1
    arrow.Font = Enum.Font.Gotham
    arrow.TextSize = 14
    arrow.TextColor3 = ActiveTheme.TextMuted
    arrow.Text = "▾"
    arrow.Parent = frame
    
    local expanded = false
    
    -- Dropdown list
    local list = Instance.new("Frame")
    list.Size = UDim2.new(1, 0, 0, 0)
    list.Position = UDim2.new(0, 0, 1, 4)
    list.BackgroundColor3 = ActiveTheme.Secondary
    list.BackgroundTransparency = 0.9
    list.ClipsDescendants = true
    list.Visible = false
    list.Parent = frame
    CreateCorner(list, UDim.new(0, 6))
    CreateStroke(list, ActiveTheme.Border, 1)
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 2)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.FillDirection = Enum.FillDirection.Vertical
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    listLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    listLayout.Parent = list
    
    local selected = options.Default or ""
    
    for _, item in ipairs(options.Options or {}) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -8, 0, 28)
        btn.BackgroundColor3 = ActiveTheme.Tertiary
        btn.BackgroundTransparency = 0.5
        btn.BorderSizePixel = 0
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 13
        btn.TextColor3 = ActiveTheme.TextPrimary
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Text = item
        btn.Parent = list
        CreateCorner(btn, UDim.new(0, 4))
        
        btn.MouseButton1Click:Connect(function()
            selected = item
            display.Text = item
            if options.Callback then
                options.Callback(item)
            end
            expanded = false
            list.Visible = false
            frame.Size = UDim2.new(1, 0, 0, 34)
            arrow.Text = "▾"
        end)
        
        btn.MouseEnter:Connect(function()
            TweenObject(btn, {BackgroundColor3 = ActiveTheme.AccentDim, BackgroundTransparency = 0.2})
        end)
        btn.MouseLeave:Connect(function()
            TweenObject(btn, {BackgroundColor3 = ActiveTheme.Tertiary, BackgroundTransparency = 0.5})
        end)
    end
    
    -- Click to toggle
    local click = Instance.new("TextButton")
    click.Size = UDim2.new(1, 0, 1, 0)
    click.BackgroundTransparency = 1
    click.Text = ""
    click.Parent = frame
    
    click.MouseButton1Click:Connect(function()
        expanded = not expanded
        list.Visible = expanded
        arrow.Text = expanded and "▴" or "▾"
        if expanded then
            local count = #(options.Options or {})
            local height = math.min(count * 30 + 10, 200)
            frame.Size = UDim2.new(1, 0, 0, 34 + height)
            list.Size = UDim2.new(1, 0, 0, height)
        else
            frame.Size = UDim2.new(1, 0, 0, 34)
        end
    end)
    
    return {
        GetValue = function() return selected end,
        SetValue = function(val)
            selected = val
            display.Text = val
            if options.Callback then options.Callback(val) end
        end,
    }
end

-- ============================================================
-- SLIDER COMPONENT
-- ============================================================
function Tab:CreateSlider(options)
    options = options or {}
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 50)
    frame.BackgroundColor3 = ActiveTheme.Tertiary
    frame.BackgroundTransparency = 0.4
    frame.Parent = self.Content
    CreateCorner(frame, UDim.new(0, 6))
    CreateStroke(frame, ActiveTheme.Border, 1)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -16, 0, 18)
    label.Position = UDim2.new(0, 12, 0, 4)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextColor3 = ActiveTheme.TextPrimary
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = options.Name or "Slider"
    label.Parent = frame
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.AnchorPoint = Vector2.new(1, 0)
    valueLabel.Position = UDim2.new(1, -12, 0, 4)
    valueLabel.Size = UDim2.new(0, 50, 0, 18)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextSize = 13
    valueLabel.TextColor3 = ActiveTheme.Accent
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Text = tostring(options.Default or options.Min or 0)
    valueLabel.Parent = frame
    
    -- Slider track
    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -24, 0, 4)
    track.Position = UDim2.new(0, 12, 0, 30)
    track.BackgroundColor3 = ActiveTheme.ToggleOff
    track.Parent = frame
    CreateCorner(track, UDim.new(1, 0))
    
    -- Fill
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = ActiveTheme.Accent
    fill.Parent = track
    CreateCorner(fill, UDim.new(1, 0))
    
    -- Knob
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = UDim2.new(0, -8, 0.5, -8)
    knob.BackgroundColor3 = ActiveTheme.Knob
    knob.Parent = frame
    CreateCorner(knob, UDim.new(1, 0))
    CreateStroke(knob, ActiveTheme.Accent, 1.5)
    
    local min = options.Min or 0
    local max = options.Max or 100
    local current = options.Default or min
    
    local function UpdateSlider(value)
        current = math.clamp(value, min, max)
        local percent = (current - min) / (max - min)
        fill.Size = UDim2.new(percent, 0, 1, 0)
        knob.Position = UDim2.new(percent, -8, 0.5, -8)
        valueLabel.Text = tostring(current)
        if options.Callback then
            options.Callback(current)
        end
    end
    
    UpdateSlider(current)
    
    -- Drag
    local dragging = false
    track.MouseButton1Down:Connect(function()
        dragging = true
    end)
    track.MouseButton1Up:Connect(function()
        dragging = false
    end)
    track.MouseLeave:Connect(function()
        dragging = false
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
        local pos = input.Position.X
        local absPos = track.AbsolutePosition.X
        local absSize = track.AbsoluteSize.X
        local percent = math.clamp((pos - absPos) / absSize, 0, 1)
        local value = min + (max - min) * percent
        UpdateSlider(value)
    end)
    
    return {
        GetValue = function() return current end,
        SetValue = UpdateSlider,
    }
end

-- ============================================================
-- KEYBIND COMPONENT
-- ============================================================
function Tab:CreateKeybind(options)
    options = options or {}
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 34)
    frame.BackgroundColor3 = ActiveTheme.Tertiary
    frame.BackgroundTransparency = 0.4
    frame.Parent = self.Content
    CreateCorner(frame, UDim.new(0, 6))
    CreateStroke(frame, ActiveTheme.Border, 1)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -100, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextColor3 = ActiveTheme.TextPrimary
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = options.Name or "Keybind"
    label.Parent = frame
    
    local keyLabel = Instance.new("TextLabel")
    keyLabel.AnchorPoint = Vector2.new(1, 0.5)
    keyLabel.Position = UDim2.new(1, -12, 0.5, 0)
    keyLabel.Size = UDim2.new(0, 80, 0, 24)
    keyLabel.BackgroundColor3 = ActiveTheme.InputBg
    keyLabel.BackgroundTransparency = 0.8
    keyLabel.Font = Enum.Font.GothamBold
    keyLabel.TextSize = 12
    keyLabel.TextColor3 = ActiveTheme.TextPrimary
    keyLabel.Text = options.Default or "None"
    keyLabel.Parent = frame
    CreateCorner(keyLabel, UDim.new(0, 4))
    CreateStroke(keyLabel, ActiveTheme.Border, 1)
    
    local listening = false
    local key = options.Default or ""
    
    local function SetKey(newKey)
        key = newKey
        keyLabel.Text = key ~= "" and key or "None"
        if options.Callback then
            options.Callback(key)
        end
    end
    
    keyLabel.MouseButton1Click:Connect(function()
        listening = not listening
        keyLabel.Text = listening and "Press key..." or (key ~= "" and key or "None")
        keyLabel.BackgroundColor3 = listening and ActiveTheme.AccentDim or ActiveTheme.InputBg
        keyLabel.BackgroundTransparency = listening and 0.2 or 0.8
    end)
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not listening then return end
        if gameProcessed then return end
        if input.UserInputType == Enum.UserInputType.Keyboard then
            local keyName = input.KeyCode.Name
            if keyName ~= "Unknown" then
                SetKey(keyName)
                listening = false
                keyLabel.Text = keyName
                keyLabel.BackgroundColor3 = ActiveTheme.InputBg
                keyLabel.BackgroundTransparency = 0.8
            end
        end
    end)
    
    return {
        GetKey = function() return key end,
        SetKey = SetKey,
    }
end

-- ============================================================
-- SAVE SYSTEM SUPPORT
-- ============================================================
function UILib:SaveSettings(settings, path)
    if not writefile then return false end
    path = path or "uilib_settings.json"
    local ok, err = pcall(function()
        writefile(path, HttpService:JSONEncode(settings))
    end)
    return ok
end

function UILib:LoadSettings(path)
    if not (readfile and isfile) then return nil end
    path = path or "uilib_settings.json"
    if not isfile(path) then return nil end
    local ok, data = pcall(function()
        return HttpService:JSONDecode(readfile(path))
    end)
    if ok then return data end
    return nil
end

-- ============================================================
-- LOADSTRING-READY EXPORT
-- ============================================================
return UILib
