--[[
	UILib  |  single-file executor build

	Paste and run. Borderless weight-based styling, live-retinting
	themes, frosted backdrop, in-header search, named config
	profiles, resizable and position-sticky panels.

		local W = UILib.CreatePanel({ Title = "Menu", Tabs = { "Main" } })
		UILib.CreateToggle(W.GetTab(1), { Label = "Thing", OnChanged = print })

	Themes retint live, no rebuild:
		UILib.SetTheme("Ice" | "Mono" | "Clay" | "Paper" | "Terminal")

	RightControl shows/hides. UILib.Unload() tears everything down.
]]

if not game:IsLoaded() then game.Loaded:Wait() end

local UILib = {}

local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService      = game:GetService("HttpService")
local TextService      = game:GetService("TextService")
local RunService       = game:GetService("RunService")
local Lighting         = game:GetService("Lighting")
local Players          = game:GetService("Players")
local LocalPlayer      = Players.LocalPlayer
local PlayerGui        = LocalPlayer:WaitForChild("PlayerGui")

-- ============================================================
-- THEME
--
-- Separation comes from elevation, spacing and type weight rather
-- than outlines, so strokes are invisible by default and the accent
-- is spent only on active state and live values. Radius shrinks with
-- nesting depth, which is what makes things read as contained.
-- ============================================================
local Theme = {
	Bg0               = Color3.fromRGB(  9,  10,  12),
	Bg1               = Color3.fromRGB( 15,  16,  19),
	Bg2               = Color3.fromRGB( 25,  27,  32),
	Bg3               = Color3.fromRGB( 20,  22,  26),

	Accent            = Color3.fromRGB(120, 190, 255),
	AccentDim         = Color3.fromRGB( 44,  52,  66),
	AccentSec         = Color3.fromRGB(196, 222, 255),

	ToggleOff         = Color3.fromRGB( 44,  48,  58),
	ToggleOn          = Color3.fromRGB(120, 190, 255),
	Knob              = Color3.fromRGB(248, 251, 255),

	Hover             = Color3.fromRGB( 33,  36,  43),
	SelectedBg        = Color3.fromRGB( 26,  38,  54),

	ToggleW           = 34,
	ToggleH           = 18,
	KnobSz            = 13,

	TextPrimary       = Color3.fromRGB(232, 236, 243),
	TextMuted         = Color3.fromRGB(129, 137, 152),
	ActiveTabText     = Color3.fromRGB( 12,  16,  22),

	InputBg           = Color3.fromRGB( 12,  13,  16),

	HeaderHeight      = 34,
	TabHeight         = 34,
	RowHeight         = 30,

	CornerRadius      = 14,
	CornerRadiusSmall = 9,
	CornerRadiusXs    = 5,
	Padding           = 12,

	FontBold          = Enum.Font.GothamBold,
	FontMedium        = Enum.Font.GothamMedium,
	FontRegular       = Enum.Font.Gotham,
	-- Gotham has no glyphs for chevrons, arrows or multiplication
	-- signs; they render as tofu. SourceSansBold covers them.
	FontIcon          = Enum.Font.SourceSansBold,
	-- Values go monospace so digits stop jittering as they tick.
	FontMono          = Enum.Font.Code,

	TitleSize         = 15,
	BodySize          = 13,
	SmallSize         = 12,
	CaptionSize       = 10,

	-- 1 is fully invisible. Raise to ~0.55 for a hairline look.
	StrokeAlpha       = 1,
	PanelStrokeAlpha  = 0.35,
	FocusStrokeAlpha  = 0,
	RowLift           = 0.35,
	CapsLabels        = true,

	Acrylic           = 0.10,
	BlurSize          = 18,
}
UILib.Theme = Theme

local ThemeDefaults = {}
for k, v in pairs(Theme) do ThemeDefaults[k] = v end

UILib.Themes = {
	Ice = {},

	-- Pure greyscale. The only colour left is whatever your content
	-- brings, so it reads as furthest from a saturated build.
	Mono = {
		Bg0 = Color3.fromRGB(10, 10, 10),        Bg1 = Color3.fromRGB(16, 16, 16),
		Bg2 = Color3.fromRGB(26, 26, 27),        Bg3 = Color3.fromRGB(21, 21, 22),
		Accent = Color3.fromRGB(236, 238, 242),  AccentDim = Color3.fromRGB(52, 52, 55),
		AccentSec = Color3.fromRGB(255, 255, 255),
		ToggleOff = Color3.fromRGB(46, 46, 49),  ToggleOn = Color3.fromRGB(226, 229, 235),
		Knob = Color3.fromRGB(18, 18, 19),
		Hover = Color3.fromRGB(34, 34, 36),      SelectedBg = Color3.fromRGB(40, 40, 43),
		TextPrimary = Color3.fromRGB(232, 233, 236),
		TextMuted = Color3.fromRGB(124, 126, 132),
		ActiveTabText = Color3.fromRGB(14, 14, 15),
		InputBg = Color3.fromRGB(12, 12, 13),
		Acrylic = 0.08, BlurSize = 14,
	},

	-- Warm near-black, desaturated terracotta. Softer than a
	-- saturated hue without going grey.
	Clay = {
		Bg0 = Color3.fromRGB(17, 15, 14),        Bg1 = Color3.fromRGB(24, 21, 20),
		Bg2 = Color3.fromRGB(36, 32, 30),        Bg3 = Color3.fromRGB(29, 26, 24),
		Accent = Color3.fromRGB(214, 132, 104),  AccentDim = Color3.fromRGB(70, 54, 48),
		AccentSec = Color3.fromRGB(240, 190, 170),
		ToggleOff = Color3.fromRGB(56, 49, 46),  ToggleOn = Color3.fromRGB(214, 132, 104),
		Knob = Color3.fromRGB(252, 244, 240),
		Hover = Color3.fromRGB(45, 40, 37),      SelectedBg = Color3.fromRGB(52, 38, 32),
		TextPrimary = Color3.fromRGB(240, 232, 227),
		TextMuted = Color3.fromRGB(147, 133, 126),
		ActiveTabText = Color3.fromRGB(24, 18, 15),
		InputBg = Color3.fromRGB(19, 17, 16),
		Acrylic = 0.12, BlurSize = 20,
	},

	-- Light. Paper surfaces, ink text, one blue for state. Worth
	-- loading once even on a dark build: it exposes anywhere the
	-- design was leaning on darkness instead of structure.
	Paper = {
		Bg0 = Color3.fromRGB(232, 233, 236),     Bg1 = Color3.fromRGB(244, 245, 247),
		Bg2 = Color3.fromRGB(255, 255, 255),     Bg3 = Color3.fromRGB(238, 240, 243),
		Accent = Color3.fromRGB(38, 108, 224),   AccentDim = Color3.fromRGB(206, 212, 222),
		AccentSec = Color3.fromRGB(26, 82, 180),
		ToggleOff = Color3.fromRGB(206, 211, 219), ToggleOn = Color3.fromRGB(38, 108, 224),
		Knob = Color3.fromRGB(255, 255, 255),
		Hover = Color3.fromRGB(237, 241, 248),   SelectedBg = Color3.fromRGB(224, 234, 252),
		TextPrimary = Color3.fromRGB(28, 32, 40),
		TextMuted = Color3.fromRGB(112, 120, 134),
		ActiveTabText = Color3.fromRGB(255, 255, 255),
		InputBg = Color3.fromRGB(255, 255, 255),
		RowLift = 0, PanelStrokeAlpha = 0.55, Acrylic = 0.04, BlurSize = 8,
	},

	-- Very dark, tight radii, Code font throughout. The one preset
	-- that turns hairlines back on, because this look wants to feel
	-- drawn rather than layered.
	Terminal = {
		Bg0 = Color3.fromRGB(8, 9, 8),           Bg1 = Color3.fromRGB(13, 15, 13),
		Bg2 = Color3.fromRGB(19, 22, 19),        Bg3 = Color3.fromRGB(15, 18, 15),
		Accent = Color3.fromRGB(232, 176, 84),   AccentDim = Color3.fromRGB(58, 54, 38),
		AccentSec = Color3.fromRGB(248, 214, 150),
		ToggleOff = Color3.fromRGB(38, 40, 36),  ToggleOn = Color3.fromRGB(232, 176, 84),
		Knob = Color3.fromRGB(14, 16, 14),
		Hover = Color3.fromRGB(26, 30, 26),      SelectedBg = Color3.fromRGB(38, 32, 18),
		TextPrimary = Color3.fromRGB(214, 224, 210),
		TextMuted = Color3.fromRGB(112, 122, 108),
		ActiveTabText = Color3.fromRGB(12, 14, 12),
		InputBg = Color3.fromRGB(10, 12, 10),
		FontRegular = Enum.Font.Code, FontMedium = Enum.Font.Code,
		CornerRadius = 4, CornerRadiusSmall = 3, CornerRadiusXs = 2,
		StrokeAlpha = 0.55, RowLift = 0.6, Acrylic = 0.14, BlurSize = 24,
	},
}
UILib.ThemeNames = { "Ice", "Mono", "Clay", "Paper", "Terminal" }

-- ============================================================
-- LIVE THEME BINDING
-- Instances register the theme keys they use, so SetTheme retints
-- the running UI in place. Dead instances are dropped lazily on the
-- next sweep so closed panels don't accumulate.
-- ============================================================
local Bound, Reactions = {}, {}

local function Track(inst, map)
	Bound[#Bound + 1] = { inst = inst, map = map }
	for prop, key in pairs(map) do inst[prop] = Theme[key] end
	return inst
end

-- For anything that isn't a straight property assignment: gradients,
-- uppercase labels, radius on a UICorner, derived state colours.
local function React(owner, fn)
	Reactions[#Reactions + 1] = { owner = owner, fn = fn }
	fn()
end

local function Retint(animate)
	local info = animate
		and TweenInfo.new(0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.Out) or nil
	for i = #Bound, 1, -1 do
		local b = Bound[i]
		if not b.inst.Parent and not b.inst:IsA("ScreenGui") then
			table.remove(Bound, i)
		else
			for prop, key in pairs(b.map) do
				local target = Theme[key]
				if animate and (typeof(target) == "Color3" or type(target) == "number") then
					pcall(function() TweenService:Create(b.inst, info, { [prop] = target }):Play() end)
				else
					pcall(function() b.inst[prop] = target end)
				end
			end
		end
	end
	for i = #Reactions, 1, -1 do
		local r = Reactions[i]
		if r.owner and not r.owner.Parent then
			table.remove(Reactions, i)
		else
			pcall(r.fn)
		end
	end
end

local CurrentTheme = "Ice"

function UILib.SetTheme(preset, animate)
	local patch = preset
	if type(preset) == "string" then
		patch = UILib.Themes[preset]
		if not patch then return UILib end
		CurrentTheme = preset
	end
	if type(patch) ~= "table" then return UILib end
	-- Reset first, so switching from a preset that sets CornerRadius
	-- to one that doesn't can't leave the old value behind.
	for k, v in pairs(ThemeDefaults) do Theme[k] = v end
	for k, v in pairs(patch) do Theme[k] = v end
	Retint(animate ~= false)
	return UILib
end

UILib.GetTheme = function() return CurrentTheme end

-- ============================================================
-- GUI PARENT
-- Executors expose a hidden container that survives respawns and
-- isn't walked by game scripts iterating PlayerGui. Prefer it, then
-- CoreGui if writable, then PlayerGui — so this same file runs in
-- Studio with no executor globals present.
-- ============================================================
local function ResolveGuiParent()
	local ok, hidden = pcall(function()
		if type(gethui) == "function" then return gethui() end
		if type(get_hidden_gui) == "function" then return get_hidden_gui() end
		return nil
	end)
	if ok and typeof(hidden) == "Instance" then return hidden end

	-- CoreGui throws rather than returning nil when access is denied,
	-- so probe with a throwaway Folder instead of assuming.
	local okCore, core = pcall(game.GetService, game, "CoreGui")
	if okCore and core then
		local probe = Instance.new("Folder")
		local wrote = pcall(function() probe.Parent = core end)
		probe:Destroy()
		if wrote then return core end
	end
	return PlayerGui
end

local DefaultParent = ResolveGuiParent()
UILib.GetGuiParent = function() return DefaultParent end

-- ============================================================
-- HELPERS
-- ============================================================
local TweenFast   = TweenInfo.new(0.14, Enum.EasingStyle.Quad,  Enum.EasingDirection.Out)
local TweenMed    = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local TweenSpring = TweenInfo.new(0.28, Enum.EasingStyle.Back,  Enum.EasingDirection.Out)
-- Overshoots further and settles slower; used on knobs and dots so
-- they read as sprung rather than eased.
local TweenBounce = TweenInfo.new(0.42, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out)

-- Radius follows a theme key so nesting depth retints with the rest.
local function Corner(parent, key)
	local c = Instance.new("UICorner")
	key = key or "CornerRadiusSmall"
	React(parent, function() c.CornerRadius = UDim.new(0, Theme[key]) end)
	c.Parent = parent
	return c
end

local function Pill(parent)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(1, 0)
	c.Parent = parent
	return c
end

local function Fixed(parent, px)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, px)
	c.Parent = parent
	return c
end

-- Strokes exist but are invisible by default, so anything that wants
-- to be seen has to ask. This is what removes the outline-on-
-- everything look while leaving every call site in place.
local function Stroke(parent, key, thickness, alphaKey)
	local s = Instance.new("UIStroke")
	s.Thickness       = thickness or 1
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent          = parent
	Track(s, { Color = key or "AccentDim", Transparency = alphaKey or "StrokeAlpha" })
	return s
end

local function Pad(parent, l, r, t, b)
	local p = Instance.new("UIPadding")
	p.PaddingLeft   = UDim.new(0, l or 0)
	p.PaddingRight  = UDim.new(0, r or 0)
	p.PaddingTop    = UDim.new(0, t or 0)
	p.PaddingBottom = UDim.new(0, b or 0)
	p.Parent        = parent
	return p
end

-- Multiplies the parent's (possibly tweened) BackgroundColor3, so it
-- adds depth without new palette colours or fighting state tweens.
local function Sheen(parent, strength)
	local g = Instance.new("UIGradient")
	g.Rotation = 90
	local k = 1 - (strength or 0.12)
	g.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.new(k, k, k))
	g.Parent = parent
	return g
end

local function List(parent, dir, pad, ha, va)
	local l = Instance.new("UIListLayout")
	l.FillDirection       = dir or Enum.FillDirection.Vertical
	l.Padding             = UDim.new(0, pad or 6)
	l.SortOrder           = Enum.SortOrder.LayoutOrder
	l.HorizontalAlignment = ha or Enum.HorizontalAlignment.Left
	l.VerticalAlignment   = va or Enum.VerticalAlignment.Top
	l.Parent              = parent
	return l
end

-- Connects a service-level signal and drops it when `owner` dies.
-- Without this every slider, picker and keybind leaks a global
-- connection after its GUI is gone.
local function Scoped(owner, signal, fn)
	local conn = signal:Connect(fn)
	owner.Destroying:Connect(function() conn:Disconnect() end)
	return conn
end

local function Caps(text)
	return Theme.CapsLabels and tostring(text or ""):upper() or tostring(text or "")
end

-- Parent frames carry their tab index as an attribute so components
-- register against the right tab without the caller passing it in.
-- Guarded: plain Frames have the method but no attribute.
local function TabOf(parent)
	if typeof(parent) ~= "Instance" then return nil end
	local ok, v = pcall(function() return parent:GetAttribute("UILibTab") end)
	return ok and v or nil
end

-- At most one expanding overlay open at a time; clicking outside the
-- open card closes it. The watcher only exists while one is open.
local _openOverlay, _overlayWatch = nil, nil

local function OverlayClosed(card)
	if _openOverlay and _openOverlay.Card == card then
		_openOverlay = nil
		if _overlayWatch then _overlayWatch:Disconnect(); _overlayWatch = nil end
	end
end

local function OverlayOpened(card, closeFn)
	if _openOverlay and _openOverlay.Card ~= card then _openOverlay.Close() end
	_openOverlay = { Card = card, Close = closeFn }
	if not _overlayWatch then
		_overlayWatch = UserInputService.InputBegan:Connect(function(inp)
			if inp.UserInputType ~= Enum.UserInputType.MouseButton1
			and inp.UserInputType ~= Enum.UserInputType.Touch then return end
			local o = _openOverlay
			if not o or not o.Card.Parent then return end
			local p, s = o.Card.AbsolutePosition, o.Card.AbsoluteSize
			local x, y = inp.Position.X, inp.Position.Y
			if x < p.X or x > p.X + s.X or y < p.Y or y > p.Y + s.Y then o.Close() end
		end)
	end
end

local Flags = {}
UILib.Flags = Flags
local _allGuis = {}

-- Components register their row and label text so the header search
-- can dim non-matching rows in place, across every tab at once.
local Searchables = {}
local function Searchable(row, text, tabIndex)
	Searchables[#Searchables + 1] =
		{ row = row, text = tostring(text or ""):lower(), tab = tabIndex }
end

-- ============================================================
-- FROSTED BACKDROP
-- One shared BlurEffect, reference counted, so two open panels don't
-- stack blur and closing one doesn't clear it while another is up.
-- ============================================================
local _blur, _blurRefs = nil, 0

local function AcquireBlur()
	_blurRefs = _blurRefs + 1
	if not _blur or not _blur.Parent then
		_blur = Instance.new("BlurEffect")
		_blur.Name   = "UILibAcrylic"
		_blur.Size   = 0
		_blur.Parent = Lighting
	end
	TweenService:Create(_blur, TweenMed, { Size = Theme.BlurSize }):Play()
end

local function ReleaseBlur()
	_blurRefs = math.max(0, _blurRefs - 1)
	if _blurRefs == 0 and _blur then
		local b = _blur
		TweenService:Create(b, TweenMed, { Size = 0 }):Play()
		task.delay(0.3, function()
			if _blurRefs == 0 and b then b:Destroy() end
			if _blur == b then _blur = nil end
		end)
	end
end

-- ============================================================
-- STICKY LAYOUT
-- Panel position and size remembered per panel Name, through the
-- same file APIs as config profiles and silently skipped without.
-- ============================================================
local LAYOUT_FILE = "UILibLayout.json"
local _layout = nil

local function layoutLoad()
	if _layout then return _layout end
	_layout = {}
	if type(readfile) == "function" then
		local exists = (type(isfile) ~= "function") or isfile(LAYOUT_FILE)
		if exists then
			local ok, body = pcall(readfile, LAYOUT_FILE)
			if ok and body then
				local okDec, data = pcall(HttpService.JSONDecode, HttpService, body)
				if okDec and type(data) == "table" then _layout = data end
			end
		end
	end
	return _layout
end

local function layoutSave(name, rec)
	local L = layoutLoad()
	L[name] = rec
	if type(writefile) ~= "function" then return end
	local ok, body = pcall(HttpService.JSONEncode, HttpService, L)
	if ok then pcall(writefile, LAYOUT_FILE, body) end
end

-- ============================================================
-- TOOLTIP
-- ============================================================
local _tipSg, _tipFrame, _tipLbl

local function ensureTip()
	if _tipSg and _tipSg.Parent then return end
	_tipSg = Instance.new("ScreenGui")
	_tipSg.Name           = "UILibTooltip"
	_tipSg.ResetOnSpawn   = false
	_tipSg.DisplayOrder   = 2000
	_tipSg.IgnoreGuiInset = true
	_tipSg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	_tipSg.Parent         = DefaultParent

	_tipFrame = Instance.new("Frame")
	_tipFrame.AutomaticSize          = Enum.AutomaticSize.XY
	_tipFrame.BackgroundTransparency = 0.04
	_tipFrame.BorderSizePixel        = 0
	_tipFrame.Visible                = false
	_tipFrame.Parent                 = _tipSg
	Track(_tipFrame, { BackgroundColor3 = "Bg0" })
	Corner(_tipFrame, "CornerRadiusXs")
	Stroke(_tipFrame, "AccentDim", 1, "PanelStrokeAlpha")
	Pad(_tipFrame, 8, 8, 5, 5)

	_tipLbl = Instance.new("TextLabel")
	_tipLbl.AutomaticSize          = Enum.AutomaticSize.XY
	_tipLbl.BackgroundTransparency = 1
	_tipLbl.TextSize               = Theme.SmallSize
	_tipLbl.Parent                 = _tipFrame
	Track(_tipLbl, { TextColor3 = "TextPrimary", Font = "FontRegular" })
end

-- IgnoreGuiInset is on, so the mouse location needs no correction —
-- and under gethui/CoreGui there is no inset to correct for anyway.
local function placeTip()
	local loc = UserInputService:GetMouseLocation()
	local screen, sz = _tipSg.AbsoluteSize, _tipFrame.AbsoluteSize
	_tipFrame.Position = UDim2.fromOffset(
		math.max(0, math.min(loc.X + 16, screen.X - sz.X - 4)),
		math.max(0, math.min(loc.Y + 14, screen.Y - sz.Y - 4)))
end

local function Tip(target, text)
	if not text or text == "" then return end
	target.MouseEnter:Connect(function()
		ensureTip()
		_tipLbl.Text      = text
		_tipFrame.Visible = true
		placeTip()
	end)
	target.MouseMoved:Connect(function()
		if _tipFrame and _tipFrame.Visible then placeTip() end
	end)
	target.MouseLeave:Connect(function()
		if _tipFrame then _tipFrame.Visible = false end
	end)
	target.Destroying:Connect(function()
		if _tipFrame then _tipFrame.Visible = false end
	end)
end

-- ============================================================
-- ShowNotification(Title, Text, Duration)
-- ============================================================
local _notifs, _notifSg = {}, nil
local NW, NH, NGAP = 258, 38, 6

local function ensureNotifs()
	if _notifSg and _notifSg.Parent then return end
	_notifSg = Instance.new("ScreenGui")
	_notifSg.Name           = "UILibNotifs"
	_notifSg.ResetOnSpawn   = false
	_notifSg.DisplayOrder   = 1999
	_notifSg.IgnoreGuiInset = true
	_notifSg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	_notifSg.Parent         = DefaultParent
end

local function stackNotifs()
	local y = 0
	for i = #_notifs, 1, -1 do
		local f = _notifs[i]
		if f and f.Parent then
			TweenService:Create(f, TweenMed,
				{ Position = UDim2.new(1, -(NW + 14), 1, -(14 + y + NH)) }):Play()
			y = y + NH + NGAP
		end
	end
end

function UILib.ShowNotification(Title, Text, Duration)
	ensureNotifs()

	local F = Instance.new("Frame", _notifSg)
	F.Size                   = UDim2.new(0, NW, 0, NH)
	F.Position               = UDim2.new(1, 14, 1, 0)
	F.BackgroundTransparency = 0.02
	F.BorderSizePixel        = 0
	F.ClipsDescendants       = true
	Track(F, { BackgroundColor3 = "Bg2" })
	Corner(F, "CornerRadiusSmall")
	Sheen(F, 0.08)

	local Bar = Instance.new("Frame", F)
	Bar.Size            = UDim2.new(0, 3, 1, -10)
	Bar.Position        = UDim2.new(0, 7, 0, 5)
	Bar.BorderSizePixel = 0
	Track(Bar, { BackgroundColor3 = "Accent" })
	Pill(Bar)

	local T = Instance.new("TextLabel", F)
	T.Position               = UDim2.new(0, 18, 0, 6)
	T.Size                   = UDim2.new(1, -26, 0, 14)
	T.BackgroundTransparency = 1
	T.TextSize               = Theme.CaptionSize
	T.TextXAlignment         = Enum.TextXAlignment.Left
	T.TextTruncate           = Enum.TextTruncate.AtEnd
	T.Text                   = Caps(Title)
	Track(T, { TextColor3 = "Accent", Font = "FontBold" })

	local B = Instance.new("TextLabel", F)
	B.Position               = UDim2.new(0, 18, 0, 19)
	B.Size                   = UDim2.new(1, -26, 0, 14)
	B.BackgroundTransparency = 1
	B.TextSize               = Theme.SmallSize
	B.TextXAlignment         = Enum.TextXAlignment.Left
	B.TextTruncate           = Enum.TextTruncate.AtEnd
	B.Text                   = Text or ""
	Track(B, { TextColor3 = "TextPrimary", Font = "FontRegular" })

	table.insert(_notifs, F)
	stackNotifs()

	task.delay(tonumber(Duration) or 2.5, function()
		if not F.Parent then return end
		TweenService:Create(F,
			TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{ Position = UDim2.new(1, 14, F.Position.Y.Scale, F.Position.Y.Offset) }):Play()
		task.delay(0.22, function()
			if F.Parent then F:Destroy() end
			for i, v in ipairs(_notifs) do
				if v == F then table.remove(_notifs, i) break end
			end
			stackNotifs()
		end)
	end)
end

-- ============================================================
-- CreatePanel(Options)
--   Name Title SubTitle Width Height Tabs DefaultTab TabSide
--   TabWidth Minimized ClampToScreen ToggleKey Parent Discord
--   Search Resizable Sticky Acrylic MinWidth MinHeight MaxWidth
--   MaxHeight
-- ============================================================
function UILib.CreatePanel(Options)
	Options = Options or {}

	local NAME       = Options.Name or "Panel"
	local Tabs       = Options.Tabs
	local hasTabs    = Tabs and #Tabs > 0
	local activeTab  = Options.DefaultTab or 1
	local wantSearch = Options.Search ~= false and hasTabs
	local resizable  = Options.Resizable ~= false
	local sticky     = Options.Sticky ~= false
	local acrylic    = Options.Acrylic ~= false
	local showDiscord = Options.Discord == true

	local sideTabs = hasTabs and Options.TabSide == "left"
	local HEADER_H = Theme.HeaderHeight
	local SEARCH_H = wantSearch and 30 or 0
	local TABBAR_H = (hasTabs and not sideTabs) and Theme.TabHeight or 0
	local RAIL_W   = sideTabs and (Options.TabWidth or 84) or 0

	local Width     = Options.Width  or 340
	local CONTENT_H = Options.Height or 300
	local FULL_H    = HEADER_H + TABBAR_H + SEARCH_H + CONTENT_H

	local MIN_W = Options.MinWidth  or 260
	local MIN_H = Options.MinHeight or (HEADER_H + TABBAR_H + SEARCH_H + 90)
	local MAX_W = Options.MaxWidth  or 900
	local MAX_H = Options.MaxHeight or 760

	-- Sticky geometry lands before anything is measured, so the
	-- entrance animation settles at the remembered size.
	local startX, startY
	if sticky then
		local rec = layoutLoad()[NAME]
		if type(rec) == "table" then
			if type(rec.w) == "number" then Width = math.clamp(rec.w, MIN_W, MAX_W) end
			if type(rec.h) == "number" then
				FULL_H    = math.clamp(rec.h, MIN_H, MAX_H)
				CONTENT_H = FULL_H - HEADER_H - TABBAR_H - SEARCH_H
			end
			startX, startY = rec.x, rec.y
		end
	end

	local Gui = Instance.new("ScreenGui")
	Gui.Name           = NAME
	Gui.ResetOnSpawn   = false
	Gui.IgnoreGuiInset = true
	Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	Gui.Parent         = Options.Parent or DefaultParent
	table.insert(_allGuis, Gui)

	local Frame = Instance.new("Frame")
	Frame.Size             = UDim2.new(0, Width, 0, FULL_H)
	Frame.Position         = (startX and startY)
		and UDim2.new(0, startX, 0, startY)
		or  UDim2.new(0.5, -(Width / 2), 0.5, -(FULL_H / 2))
	Frame.BorderSizePixel  = 0
	Frame.ClipsDescendants = true
	Frame.Active           = true
	Frame.Parent           = Gui
	Track(Frame, { BackgroundColor3 = "Bg1", BackgroundTransparency = "Acrylic" })
	Corner(Frame, "CornerRadius")
	-- The one border worth keeping.
	Stroke(Frame, "AccentDim", 1, "PanelStrokeAlpha")
	Sheen(Frame, 0.07)

	if acrylic then
		AcquireBlur()
		Gui.Destroying:Connect(ReleaseBlur)
		React(Gui, function()
			if _blur and _blur.Parent and _blurRefs > 0 then
				TweenService:Create(_blur, TweenMed, { Size = Theme.BlurSize }):Play()
			end
		end)
	end

	-- The panel clips descendants, so the shadow is a sibling beneath
	-- it mirroring Position/Size. Those signals fire during drags,
	-- resizes and tweens, so it tracks all of them for free.
	local PAD = 28
	local Shadow = Instance.new("ImageLabel")
	Shadow.Name                   = "Shadow"
	Shadow.BackgroundTransparency = 1
	Shadow.Image                  = "rbxassetid://6014261993"
	Shadow.ImageColor3            = Color3.new(0, 0, 0)
	Shadow.ImageTransparency      = 0.46
	Shadow.ScaleType              = Enum.ScaleType.Slice
	Shadow.SliceCenter            = Rect.new(49, 49, 450, 450)
	Shadow.ZIndex                 = 0
	Shadow.Parent                 = Gui

	local function syncShadow()
		local p, s = Frame.Position, Frame.Size
		Shadow.Position = UDim2.new(p.X.Scale, p.X.Offset - PAD, p.Y.Scale, p.Y.Offset - PAD + 6)
		Shadow.Size     = UDim2.new(s.X.Scale, s.X.Offset + PAD * 2, s.Y.Scale, s.Y.Offset + PAD * 2)
	end
	Frame:GetPropertyChangedSignal("Position"):Connect(syncShadow)
	Frame:GetPropertyChangedSignal("Size"):Connect(syncShadow)
	syncShadow()

	local OpenScale = Instance.new("UIScale"); OpenScale.Scale = 0.94; OpenScale.Parent = Frame
	local ShadScale = Instance.new("UIScale"); ShadScale.Scale = 0.94; ShadScale.Parent = Shadow
	TweenService:Create(OpenScale, TweenSpring, { Scale = 1 }):Play()
	TweenService:Create(ShadScale, TweenSpring, { Scale = 1 }):Play()

	-- ── Header ─────────────────────────────────────────────
	local Header = Instance.new("Frame")
	Header.Size                   = UDim2.new(1, 0, 0, HEADER_H)
	Header.BackgroundTransparency = 1
	Header.BorderSizePixel        = 0
	Header.Active                 = true
	Header.ZIndex                 = 2
	Header.Parent                 = Frame

	local plainTitle = Options.Title or ""
	local btnCount   = 2 + (showDiscord and 1 or 0)
	local reserved   = 12 + btnCount * 30

	local TitleLabel = Instance.new("TextLabel")
	TitleLabel.Size                   = UDim2.new(1, -reserved - 14, 1, 0)
	TitleLabel.Position               = UDim2.new(0, 14, 0, 0)
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.TextSize               = Theme.TitleSize
	TitleLabel.TextXAlignment         = Enum.TextXAlignment.Left
	TitleLabel.TextTruncate           = Enum.TextTruncate.AtEnd
	TitleLabel.ZIndex                 = 3
	TitleLabel.Parent                 = Header
	Track(TitleLabel, { TextColor3 = "TextPrimary", Font = "FontBold" })

	-- Rebuilt on retint because the subtitle colour is baked into
	-- RichText markup and can't be tracked as a property.
	React(Header, function()
		if Options.SubTitle and Options.SubTitle ~= "" then
			local m = Theme.TextMuted
			TitleLabel.RichText = true
			TitleLabel.Text = string.format('%s  <font size="%d" color="#%02X%02X%02X">%s</font>',
				plainTitle, Theme.CaptionSize,
				math.floor(m.R * 255 + 0.5), math.floor(m.G * 255 + 0.5), math.floor(m.B * 255 + 0.5),
				Options.SubTitle)
		else
			TitleLabel.Text = plainTitle
		end
	end)

	local function headerBtn(glyph, right, hoverKey)
		local b = Instance.new("TextButton")
		b.Size                   = UDim2.new(0, 24, 0, 20)
		b.AnchorPoint            = Vector2.new(1, 0.5)
		b.Position               = UDim2.new(1, -right, 0.5, 0)
		b.BackgroundTransparency = 1
		b.BorderSizePixel        = 0
		b.TextSize               = 15
		b.Text                   = glyph
		b.AutoButtonColor        = false
		b.ZIndex                 = 4
		b.Parent                 = Header
		Track(b, { BackgroundColor3 = "Bg2", TextColor3 = "TextMuted", Font = "FontIcon" })
		Fixed(b, 5)
		b.MouseEnter:Connect(function()
			TweenService:Create(b, TweenFast, {
				BackgroundTransparency = 0,
				TextColor3 = hoverKey and Theme[hoverKey] or Theme.TextPrimary,
			}):Play()
		end)
		b.MouseLeave:Connect(function()
			TweenService:Create(b, TweenFast,
				{ BackgroundTransparency = 1, TextColor3 = Theme.TextMuted }):Play()
		end)
		return b
	end

	local CloseBtn = headerBtn("\u{00D7}", 10, nil)
	local MinBtn   = headerBtn("\u{2013}", 40, nil)

	local DiscordBtn
	if showDiscord then
		DiscordBtn = headerBtn("\u{25CF}", 70, "Accent")
		Tip(DiscordBtn, "Copy invite link")
		local INVITE = Options.DiscordInvite or "https://discord.gg/"
		DiscordBtn.MouseButton1Click:Connect(function()
			if type(setclipboard) == "function" then
				pcall(setclipboard, INVITE)
				UILib.ShowNotification("Copied", "Invite link on your clipboard.", 2)
			else
				UILib.ShowNotification("Unavailable", "setclipboard not supported.", 2.5)
			end
		end)
	end

	-- ── Tab bar ────────────────────────────────────────────
	-- Active tab is a filled pill; inactive tabs are bare text. No
	-- outlines, so the fill is the only thing carrying state.
	local TabBar, TabBtns, Rail
	if hasTabs and not sideTabs then
		TabBar = Instance.new("Frame")
		TabBar.Position               = UDim2.new(0, 0, 0, HEADER_H)
		TabBar.Size                   = UDim2.new(1, 0, 0, TABBAR_H)
		TabBar.BackgroundTransparency = 1
		TabBar.ZIndex                 = 2
		TabBar.Parent                 = Frame
		Pad(TabBar, 10, 10, 2, 6)
		List(TabBar, Enum.FillDirection.Horizontal, 4,
			Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center)

		TabBtns = {}
		for i, name in ipairs(Tabs) do
			local btn = Instance.new("TextButton")
			btn.LayoutOrder            = i
			btn.BackgroundTransparency = 1
			btn.BorderSizePixel        = 0
			btn.AutoButtonColor        = false
			btn.TextSize               = Theme.SmallSize
			btn.Text                   = name
			btn.ZIndex                 = 3
			btn.Parent                 = TabBar
			Track(btn, { BackgroundColor3 = "ToggleOn", Font = "FontMedium" })
			Fixed(btn, 6)
			TabBtns[i] = btn
		end

		-- Equal share, recomputed on resize so tabs never squeeze.
		local function layoutTabs()
			local gap = 4
			local avail = Frame.AbsoluteSize.X - 20 - gap * (#Tabs - 1)
			local w = math.max(24, avail / #Tabs)
			for _, b in ipairs(TabBtns) do b.Size = UDim2.new(0, w, 1, -4) end
		end
		layoutTabs()
		Frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(layoutTabs)
	elseif sideTabs then
		Rail = Instance.new("Frame")
		Rail.Position               = UDim2.new(0, 0, 0, HEADER_H)
		Rail.Size                   = UDim2.new(0, RAIL_W, 1, -HEADER_H)
		Rail.BackgroundTransparency = 0.5
		Rail.BorderSizePixel        = 0
		Rail.ZIndex                 = 2
		Rail.Parent                 = Frame
		Track(Rail, { BackgroundColor3 = "Bg0" })
		Pad(Rail, 6, 6, 6, 8)
		List(Rail, Enum.FillDirection.Vertical, 3)
		TabBar = Rail

		TabBtns = {}
		for i, name in ipairs(Tabs) do
			local btn = Instance.new("TextButton")
			btn.Size                   = UDim2.new(1, 0, 0, 26)
			btn.LayoutOrder            = i
			btn.BackgroundTransparency = 1
			btn.BorderSizePixel        = 0
			btn.AutoButtonColor        = false
			btn.TextSize               = Theme.SmallSize
			btn.TextXAlignment         = Enum.TextXAlignment.Left
			btn.TextTruncate           = Enum.TextTruncate.AtEnd
			btn.Text                   = name
			btn.ZIndex                 = 3
			btn.Parent                 = Rail
			Track(btn, { BackgroundColor3 = "ToggleOn", Font = "FontMedium" })
			Fixed(btn, 6)
			Pad(btn, 9, 6, 0, 0)
			TabBtns[i] = btn
		end
	end

	-- ── Search field ───────────────────────────────────────
	local SearchBox, SearchWrap
	if wantSearch then
		SearchWrap = Instance.new("Frame")
		SearchWrap.Position               = UDim2.new(0, RAIL_W, 0, HEADER_H + TABBAR_H)
		SearchWrap.Size                   = UDim2.new(1, -RAIL_W, 0, SEARCH_H)
		SearchWrap.BackgroundTransparency = 1
		SearchWrap.ZIndex                 = 2
		SearchWrap.Parent                 = Frame
		Pad(SearchWrap, 12, 12, 2, 6)

		local box = Instance.new("Frame", SearchWrap)
		box.Size            = UDim2.new(1, 0, 1, 0)
		box.BorderSizePixel = 0
		box.ZIndex          = 3
		Track(box, { BackgroundColor3 = "InputBg" })
		Fixed(box, 6)
		local bs = Stroke(box, "AccentDim", 1)
		Pad(box, 9, 8, 0, 0)

		local mag = Instance.new("TextLabel", box)
		mag.AnchorPoint            = Vector2.new(0, 0.5)
		mag.Position               = UDim2.new(0, 0, 0.5, 0)
		mag.Size                   = UDim2.new(0, 12, 1, 0)
		mag.BackgroundTransparency = 1
		mag.TextSize               = 12
		mag.Text                   = "\u{2315}"
		mag.ZIndex                 = 4
		Track(mag, { TextColor3 = "TextMuted", Font = "FontIcon" })

		SearchBox = Instance.new("TextBox", box)
		SearchBox.Position               = UDim2.new(0, 17, 0, 0)
		SearchBox.Size                   = UDim2.new(1, -38, 1, 0)
		SearchBox.BackgroundTransparency = 1
		SearchBox.TextSize               = Theme.SmallSize
		SearchBox.PlaceholderText        = "Filter"
		SearchBox.TextXAlignment         = Enum.TextXAlignment.Left
		SearchBox.ClearTextOnFocus       = false
		SearchBox.Text                   = ""
		SearchBox.ZIndex                 = 4
		Track(SearchBox, { TextColor3 = "TextPrimary",
			PlaceholderColor3 = "TextMuted", Font = "FontRegular" })

		local clear = Instance.new("TextButton", box)
		clear.AnchorPoint            = Vector2.new(1, 0.5)
		clear.Position               = UDim2.new(1, 0, 0.5, 0)
		clear.Size                   = UDim2.new(0, 14, 0, 14)
		clear.BackgroundTransparency = 1
		clear.TextSize               = 13
		clear.Text                   = "\u{00D7}"
		clear.AutoButtonColor        = false
		clear.Visible                = false
		clear.ZIndex                 = 4
		Track(clear, { TextColor3 = "TextMuted", Font = "FontIcon" })

		SearchBox.Focused:Connect(function()
			TweenService:Create(bs, TweenFast,
				{ Color = Theme.Accent, Transparency = Theme.FocusStrokeAlpha }):Play()
		end)
		SearchBox.FocusLost:Connect(function()
			TweenService:Create(bs, TweenFast,
				{ Color = Theme.AccentDim, Transparency = Theme.StrokeAlpha }):Play()
		end)
		clear.MouseButton1Click:Connect(function() SearchBox.Text = "" end)

		-- Non-matching rows fade in place. Layout is untouched, so
		-- nothing jumps as you type.
		local function applyFilter()
			local q = SearchBox.Text:lower()
			clear.Visible = q ~= ""
			for i = #Searchables, 1, -1 do
				local s = Searchables[i]
				if not s.row.Parent then
					table.remove(Searchables, i)
				else
					local hit = (q == "") or s.text:find(q, 1, true) ~= nil
					local fade = hit and 0 or 0.75
					local base = s.row:GetAttribute("UILibBaseAlpha")
					TweenService:Create(s.row, TweenFast, {
						BackgroundTransparency = hit and (base or 0) or 0.9,
					}):Play()
					for _, d in ipairs(s.row:GetDescendants()) do
						if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then
							TweenService:Create(d, TweenFast, { TextTransparency = fade }):Play()
						end
					end
					s.row.Active = hit
				end
			end
		end
		SearchBox:GetPropertyChangedSignal("Text"):Connect(applyFilter)
	end

	-- ── Content ────────────────────────────────────────────
	local TOP = HEADER_H + TABBAR_H + SEARCH_H
	local tabCount = hasTabs and #Tabs or 1
	local tabFrames = {}
	for i = 1, tabCount do
		local sf = Instance.new("ScrollingFrame")
		sf.Position                   = UDim2.new(0, RAIL_W, 0, TOP)
		sf.Size                       = UDim2.new(1, -RAIL_W, 1, -TOP)
		sf.BackgroundTransparency     = 1
		sf.BorderSizePixel            = 0
		sf.ScrollBarThickness         = 2
		sf.ScrollBarImageTransparency = 0.35
		sf.ScrollingDirection         = Enum.ScrollingDirection.Y
		sf.AutomaticCanvasSize        = Enum.AutomaticSize.Y
		sf.CanvasSize                 = UDim2.new(0, 0, 0, 0)
		sf.ClipsDescendants           = true
		sf.Visible                    = (i == 1)
		sf.Parent                     = Frame
		Track(sf, { ScrollBarImageColor3 = "AccentDim" })
		Pad(sf, Theme.Padding, Theme.Padding, 4, Theme.Padding)
		List(sf, Enum.FillDirection.Vertical, 5)
		sf:SetAttribute("UILibTab", i)
		tabFrames[i] = sf
	end

	-- ── Tab switching with staggered entrance ───────────────
	local function paintTabs(animate)
		if not hasTabs then return end
		for i, btn in ipairs(TabBtns) do
			local on = (i == activeTab)
			local target = {
				BackgroundTransparency = on and 0 or 1,
				TextColor3 = on and Theme.ActiveTabText or Theme.TextMuted,
			}
			if animate then
				TweenService:Create(btn, TweenFast, target):Play()
			else
				btn.BackgroundTransparency = target.BackgroundTransparency
				btn.TextColor3             = target.TextColor3
			end
			btn.Font = on and Theme.FontBold or Theme.FontMedium
		end
	end

	-- Rows slide up a few pixels, each a frame later than the last.
	-- Capped at 12: past that the delay outlasts the animation and it
	-- just reads as slow.
	local function cascade(sf)
		local n = 0
		for _, child in ipairs(sf:GetChildren()) do
			if child:IsA("GuiObject") then
				n = n + 1
				if n > 12 then break end
				local final = child.Position
				child.Position = final + UDim2.fromOffset(0, 9)
				local h = child
				task.delay(0.016 * n, function()
					if h.Parent then
						TweenService:Create(h,
							TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
							{ Position = final }):Play()
					end
				end)
			end
		end
	end

	local function SetTab(idx, silent)
		if not hasTabs then return end
		local changed = activeTab ~= idx
		activeTab = idx
		for i, sf in ipairs(tabFrames) do sf.Visible = (i == idx) end
		paintTabs(true)
		if changed and not silent then cascade(tabFrames[idx]) end
	end

	if hasTabs then
		for i, btn in ipairs(TabBtns) do
			local idx = i
			btn.MouseButton1Click:Connect(function() SetTab(idx) end)
			btn.MouseEnter:Connect(function()
				if activeTab ~= idx then
					TweenService:Create(btn, TweenFast, { TextColor3 = Theme.TextPrimary }):Play()
				end
			end)
			btn.MouseLeave:Connect(function()
				if activeTab ~= idx then
					TweenService:Create(btn, TweenFast, { TextColor3 = Theme.TextMuted }):Play()
				end
			end)
		end
		paintTabs(false)
		SetTab(activeTab, true)
		React(Frame, function() paintTabs(false) end)
	end

	-- ── Minimize ───────────────────────────────────────────
	-- Two stages: collapse height into the header, then slide the
	-- width in until it hugs the title. Width is measured from the
	-- plain title, not TitleLabel.Text, which carries RichText markup
	-- when SubTitle is set and would measure far too wide.
	local isMin, minToken = Options.Minimized == true, 0
	local Grip

	local function minWidth()
		local ok, b = pcall(TextService.GetTextSize, TextService,
			plainTitle, Theme.TitleSize, Theme.FontBold, Vector2.new(2000, HEADER_H))
		local tw = (ok and b and b.X) or 60
		return math.clamp(14 + tw + 12 + reserved, 100, Frame.AbsoluteSize.X)
	end

	local function bodyVisible(v)
		if TabBar     then TabBar.Visible     = v end
		if SearchWrap then SearchWrap.Visible = v end
		if Grip       then Grip.Visible       = v and resizable end
		if v then
			for i, sf in ipairs(tabFrames) do
				sf.Visible = hasTabs and (i == activeTab) or (i == 1)
			end
		else
			for _, sf in ipairs(tabFrames) do sf.Visible = false end
		end
	end

	local function applyMin(instant)
		minToken = minToken + 1
		local tok = minToken
		MinBtn.Text = isMin and "+" or "\u{2013}"

		if instant then
			bodyVisible(not isMin)
			Frame.Size = isMin and UDim2.new(0, minWidth(), 0, HEADER_H)
				or UDim2.new(0, Width, 0, FULL_H)
			return
		end

		if isMin then
			bodyVisible(false)
			local t = TweenService:Create(Frame, TweenMed,
				{ Size = UDim2.new(0, Frame.Size.X.Offset, 0, HEADER_H) })
			t.Completed:Connect(function(st)
				if tok ~= minToken or st ~= Enum.PlaybackState.Completed then return end
				TweenService:Create(Frame, TweenMed,
					{ Size = UDim2.new(0, minWidth(), 0, HEADER_H) }):Play()
			end)
			t:Play()
		else
			local t = TweenService:Create(Frame, TweenMed,
				{ Size = UDim2.new(0, Width, 0, HEADER_H) })
			t.Completed:Connect(function(st)
				if tok ~= minToken or st ~= Enum.PlaybackState.Completed then return end
				bodyVisible(true)
				local t2 = TweenService:Create(Frame, TweenMed,
					{ Size = UDim2.new(0, Width, 0, FULL_H) })
				t2.Completed:Connect(function()
					if hasTabs then cascade(tabFrames[activeTab]) end
				end)
				t2:Play()
			end)
			t:Play()
		end
	end

	local function SetMinimized(m)
		if isMin == m then return end
		isMin = m
		applyMin(false)
	end
	MinBtn.MouseButton1Click:Connect(function() SetMinimized(not isMin) end)

	local function persist()
		if not sticky then return end
		layoutSave(NAME, {
			x = Frame.AbsolutePosition.X, y = Frame.AbsolutePosition.Y,
			w = Width, h = FULL_H,
		})
	end

	local function CloseWindow()
		persist()
		if Gui then Gui:Destroy() end
	end
	CloseBtn.MouseButton1Click:Connect(CloseWindow)
	Tip(CloseBtn, "Close")
	Tip(MinBtn, "Minimize")

	applyMin(true)

	-- ── Dragging ───────────────────────────────────────────
	do
		local clamp = Options.ClampToScreen == true
		local dragging, dragStart, startPos = false, nil, nil
		Header.InputBegan:Connect(function(inp)
			if inp.UserInputType ~= Enum.UserInputType.MouseButton1
			and inp.UserInputType ~= Enum.UserInputType.Touch then return end
			dragging, dragStart, startPos = true, inp.Position, Frame.Position
			inp.Changed:Connect(function()
				if inp.UserInputState == Enum.UserInputState.End then
					dragging = false
					persist()
				end
			end)
		end)
		Scoped(Gui, UserInputService.InputChanged, function(inp)
			if not dragging then return end
			if inp.UserInputType ~= Enum.UserInputType.MouseMovement
			and inp.UserInputType ~= Enum.UserInputType.Touch then return end
			local d = inp.Position - dragStart
			local pos = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X,
				startPos.Y.Scale, startPos.Y.Offset + d.Y)
			if clamp then
				local screen = Gui.AbsoluteSize
				local fw, fh = Frame.AbsoluteSize.X, Frame.AbsoluteSize.Y
				local ax = math.clamp(pos.X.Scale * screen.X + pos.X.Offset, 0, math.max(0, screen.X - fw))
				local ay = math.clamp(pos.Y.Scale * screen.Y + pos.Y.Offset, 0, math.max(0, screen.Y - fh))
				pos = UDim2.new(pos.X.Scale, ax - pos.X.Scale * screen.X,
					pos.Y.Scale, ay - pos.Y.Scale * screen.Y)
			end
			Frame.Position = pos
		end)
	end

	-- ── Resize grip ────────────────────────────────────────
	if resizable then
		Grip = Instance.new("TextButton")
		Grip.AnchorPoint            = Vector2.new(1, 1)
		Grip.Position               = UDim2.new(1, -3, 1, -3)
		Grip.Size                   = UDim2.new(0, 15, 0, 15)
		Grip.BackgroundTransparency = 1
		Grip.Text                   = ""
		Grip.AutoButtonColor        = false
		Grip.ZIndex                 = 8
		Grip.Parent                 = Frame

		for i = 1, 3 do
			local t = Instance.new("Frame", Grip)
			t.AnchorPoint            = Vector2.new(1, 1)
			t.Position               = UDim2.new(1, -1, 1, -1 - (i - 1) * 4)
			t.Size                   = UDim2.new(0, (4 - i) * 4 - 1, 0, 2)
			t.BackgroundTransparency = 0.55
			t.BorderSizePixel        = 0
			Track(t, { BackgroundColor3 = "TextMuted" })
		end
		Tip(Grip, "Drag to resize")

		local sizing, sizeStart, startSize = false, nil, nil
		Grip.InputBegan:Connect(function(inp)
			if inp.UserInputType ~= Enum.UserInputType.MouseButton1
			and inp.UserInputType ~= Enum.UserInputType.Touch then return end
			sizing, sizeStart = true, inp.Position
			startSize = Vector2.new(Frame.AbsoluteSize.X, Frame.AbsoluteSize.Y)
			inp.Changed:Connect(function()
				if inp.UserInputState == Enum.UserInputState.End then
					sizing = false
					persist()
				end
			end)
		end)
		Scoped(Gui, UserInputService.InputChanged, function(inp)
			if not sizing or isMin then return end
			if inp.UserInputType ~= Enum.UserInputType.MouseMovement
			and inp.UserInputType ~= Enum.UserInputType.Touch then return end
			local d = inp.Position - sizeStart
			Width  = math.clamp(startSize.X + d.X, MIN_W, MAX_W)
			FULL_H = math.clamp(startSize.Y + d.Y, MIN_H, MAX_H)
			Frame.Size = UDim2.new(0, Width, 0, FULL_H)
		end)
	end

	-- ── Visibility ─────────────────────────────────────────
	local function SetVisible(v)
		Gui.Enabled = v == true
		if acrylic then
			if Gui.Enabled then AcquireBlur() else ReleaseBlur() end
		end
	end
	local function ToggleVisible() SetVisible(not Gui.Enabled) end

	do
		local tk = Options.ToggleKey
		if type(tk) == "string" then
			local ok, parsed = pcall(function() return Enum.KeyCode[tk] end)
			tk = ok and parsed or nil
		end
		if typeof(tk) == "EnumItem" then
			Scoped(Gui, UserInputService.InputBegan, function(inp, processed)
				if processed then return end
				if inp.UserInputType == Enum.UserInputType.Keyboard and inp.KeyCode == tk then
					ToggleVisible()
				end
			end)
		end
	end

	return {
		Gui = Gui, Frame = Frame, Header = Header, TitleLabel = TitleLabel,
		Content       = tabFrames[1],
		GetTab        = function(i) return tabFrames[i] end,
		SetTab        = SetTab,
		GetActiveTab  = function() return activeTab end,
		GetTabButton  = function(i) return TabBtns and TabBtns[i] end,
		SearchBox     = SearchBox,
		DiscordBtn    = DiscordBtn,
		SetTitle      = function(t)
			plainTitle = t or ""
			TitleLabel.RichText = false
			TitleLabel.Text = plainTitle
		end,
		SetMinimized  = SetMinimized,
		IsMinimized   = function() return isMin end,
		SetVisible    = SetVisible,
		ToggleVisible = ToggleVisible,
		IsVisible     = function() return Gui.Enabled end,
		SetSize       = function(w, h)
			Width  = math.clamp(w or Width, MIN_W, MAX_W)
			FULL_H = math.clamp(h or FULL_H, MIN_H, MAX_H)
			TweenService:Create(Frame, TweenMed,
				{ Size = UDim2.new(0, Width, 0, FULL_H) }):Play()
		end,
		SaveLayout = persist,
		CloseBtn   = CloseBtn,
		Close      = CloseWindow,
	}
end

-- ============================================================
-- Shared row scaffolding. Everything funnels through this so search
-- registration, retinting and hover behave identically. Rows carry
-- their base transparency as an attribute so the search filter can
-- restore it without knowing the theme.
-- ============================================================
local function RowBase(Parent, height, searchText)
	local Row = Instance.new("Frame")
	Row.Size            = UDim2.new(1, 0, 0, height or Theme.RowHeight)
	Row.BorderSizePixel = 0
	Row.Parent          = Parent
	Track(Row, { BackgroundColor3 = "Bg2", BackgroundTransparency = "RowLift" })
	Corner(Row, "CornerRadiusXs")
	React(Row, function() Row:SetAttribute("UILibBaseAlpha", Theme.RowLift) end)
	Searchable(Row, searchText, TabOf(Parent))
	return Row
end

local function RowLabel(Row, text, reserve)
	local L = Instance.new("TextLabel", Row)
	L.Size                   = UDim2.new(1, -(reserve or 20), 1, 0)
	L.Position               = UDim2.new(0, 11, 0, 0)
	L.BackgroundTransparency = 1
	L.TextSize               = Theme.BodySize
	L.TextXAlignment         = Enum.TextXAlignment.Left
	L.TextTruncate           = Enum.TextTruncate.AtEnd
	L.Text                   = text or ""
	Track(L, { TextColor3 = "TextPrimary", Font = "FontRegular" })
	return L
end

local function HoverRow(Row, guard)
	Row.MouseEnter:Connect(function()
		if guard and not guard() then return end
		TweenService:Create(Row, TweenFast,
			{ BackgroundColor3 = Theme.Hover, BackgroundTransparency = 0 }):Play()
	end)
	Row.MouseLeave:Connect(function()
		TweenService:Create(Row, TweenFast,
			{ BackgroundColor3 = Theme.Bg2, BackgroundTransparency = Theme.RowLift }):Play()
	end)
end

-- ============================================================
-- CreateSection(Parent, { Title, Open, Tooltip })
-- Header is a caps micro-label with an accent tick. No card border;
-- the content indents instead, which reads as containment without
-- drawing a box.
-- ============================================================
function UILib.CreateSection(Parent, Options)
	Options = Options or {}

	local Wrap = Instance.new("Frame")
	Wrap.Size                   = UDim2.new(1, 0, 0, 0)
	Wrap.AutomaticSize          = Enum.AutomaticSize.Y
	Wrap.BackgroundTransparency = 1
	Wrap.BorderSizePixel        = 0
	Wrap.Parent                 = Parent
	List(Wrap, Enum.FillDirection.Vertical, 3)

	local Head = Instance.new("TextButton")
	Head.Size                   = UDim2.new(1, 0, 0, 24)
	Head.LayoutOrder            = 0
	Head.BackgroundTransparency = 1
	Head.BorderSizePixel        = 0
	Head.Text                   = ""
	Head.AutoButtonColor        = false
	Head.Parent                 = Wrap

	local Tick = Instance.new("Frame", Head)
	Tick.Size            = UDim2.new(0, 2, 0, 11)
	Tick.Position        = UDim2.new(0, 2, 0.5, -5)
	Tick.BorderSizePixel = 0
	Track(Tick, { BackgroundColor3 = "Accent" })
	Pill(Tick)

	local TitleLbl = Instance.new("TextLabel", Head)
	TitleLbl.Size                   = UDim2.new(1, -46, 1, 0)
	TitleLbl.Position               = UDim2.new(0, 11, 0, 0)
	TitleLbl.BackgroundTransparency = 1
	TitleLbl.TextSize               = Theme.CaptionSize
	TitleLbl.TextXAlignment         = Enum.TextXAlignment.Left
	Track(TitleLbl, { TextColor3 = "TextMuted", Font = "FontBold" })
	React(Head, function() TitleLbl.Text = Caps(Options.Title) end)

	local Arrow = Instance.new("TextLabel", Head)
	Arrow.Size                   = UDim2.new(0, 16, 1, 0)
	Arrow.Position               = UDim2.new(1, -18, 0, 0)
	Arrow.BackgroundTransparency = 1
	Arrow.TextSize               = 11
	Arrow.Text                   = "\u{25BC}"
	Track(Arrow, { Font = "FontIcon" })

	local Content = Instance.new("Frame", Wrap)
	Content.Size                   = UDim2.new(1, 0, 0, 0)
	Content.AutomaticSize          = Enum.AutomaticSize.Y
	Content.BackgroundTransparency = 1
	Content.BorderSizePixel        = 0
	Content.LayoutOrder            = 1
	Pad(Content, 8, 0, 0, 4)
	List(Content, Enum.FillDirection.Vertical, 4)
	local inh = TabOf(Parent)
	if inh then Content:SetAttribute("UILibTab", inh) end

	local isOpen = Options.Open == true
	local function SetOpen(open, animate)
		isOpen = open
		Content.Visible = open
		TweenService:Create(Arrow, animate == false and TweenFast or TweenMed, {
			Rotation   = open and 180 or 0,
			TextColor3 = open and Theme.Accent or Theme.TextMuted,
		}):Play()
		if open and animate ~= false then
			local n = 0
			for _, c in ipairs(Content:GetChildren()) do
				if c:IsA("GuiObject") then
					n = n + 1
					if n > 10 then break end
					local final = c.Position
					c.Position = final + UDim2.fromOffset(0, 5)
					local h = c
					task.delay(0.014 * n, function()
						if h.Parent then
							TweenService:Create(h, TweenMed, { Position = final }):Play()
						end
					end)
				end
			end
		end
	end
	SetOpen(isOpen, false)
	React(Wrap, function()
		Arrow.TextColor3 = isOpen and Theme.Accent or Theme.TextMuted
	end)

	Head.MouseEnter:Connect(function()
		TweenService:Create(TitleLbl, TweenFast, { TextColor3 = Theme.TextPrimary }):Play()
	end)
	Head.MouseLeave:Connect(function()
		TweenService:Create(TitleLbl, TweenFast, { TextColor3 = Theme.TextMuted }):Play()
	end)
	Head.MouseButton1Click:Connect(function() SetOpen(not isOpen) end)
	Tip(Head, Options.Tooltip)
	Searchable(Wrap, Options.Title, inh)

	return {
		Frame = Wrap, Content = Content, SetOpen = SetOpen,
		IsOpen = function() return isOpen end,
		SetTitle = function(t) TitleLbl.Text = Caps(t) end,
	}
end

-- ============================================================
-- CreateButton(Parent, { Text, Style, Color, TextColor, Height,
--                OnClick, Tooltip, Confirm, ConfirmText })
--   Style = "Primary" fills with the accent; "Danger" tints red;
--   omitted gives the quiet default. Primary is what stops every
--   button looking equally important.
-- ============================================================
function UILib.CreateButton(Parent, Options)
	Options = Options or {}
	local style   = Options.Style
	local primary = style == "Primary"
	local danger  = style == "Danger"

	local Row = Instance.new("Frame")
	Row.Size            = UDim2.new(1, 0, 0, Options.Height or Theme.RowHeight)
	Row.BorderSizePixel = 0
	Row.Parent          = Parent
	Corner(Row, "CornerRadiusXs")
	Searchable(Row, Options.Text, TabOf(Parent))

	if primary then
		Track(Row, { BackgroundColor3 = "Accent" })
		Row:SetAttribute("UILibBaseAlpha", 0)
	elseif danger then
		Row.BackgroundTransparency = 0.82
		Track(Row, { BackgroundColor3 = "Accent" })
		React(Row, function()
			Row.BackgroundColor3 = Color3.fromRGB(226, 92, 88)
			Row:SetAttribute("UILibBaseAlpha", 0.82)
		end)
	else
		Track(Row, { BackgroundColor3 = "Bg2", BackgroundTransparency = "RowLift" })
		React(Row, function() Row:SetAttribute("UILibBaseAlpha", Theme.RowLift) end)
	end
	if Options.Color then Row.BackgroundColor3 = Options.Color end

	local Btn = Instance.new("TextButton")
	Btn.Size                   = UDim2.new(1, 0, 1, 0)
	Btn.AnchorPoint            = Vector2.new(0.5, 0.5)
	Btn.Position               = UDim2.new(0.5, 0, 0.5, 0)
	Btn.BackgroundTransparency = 1
	Btn.BorderSizePixel        = 0
	Btn.TextSize               = Theme.BodySize
	Btn.Text                   = Options.Text or ""
	Btn.AutoButtonColor        = false
	Btn.Parent                 = Row
	if Options.TextColor then
		Btn.TextColor3 = Options.TextColor
		Track(Btn, { Font = "FontMedium" })
	elseif primary then
		Track(Btn, { TextColor3 = "ActiveTabText", Font = "FontBold" })
	elseif danger then
		Btn.TextColor3 = Color3.fromRGB(255, 176, 172)
		Track(Btn, { Font = "FontMedium" })
	else
		Track(Btn, { TextColor3 = "TextPrimary", Font = "FontRegular" })
	end

	local Scale = Instance.new("UIScale")
	Scale.Parent = Btn

	local function baseAlpha() return Row:GetAttribute("UILibBaseAlpha") or 0 end
	local disabled = false

	Btn.MouseEnter:Connect(function()
		if disabled then return end
		TweenService:Create(Row,   TweenFast, { BackgroundTransparency = math.max(0, baseAlpha() - 0.3) }):Play()
		TweenService:Create(Scale, TweenFast, { Scale = 1.015 }):Play()
	end)
	Btn.MouseLeave:Connect(function()
		if disabled then return end
		TweenService:Create(Row,   TweenFast, { BackgroundTransparency = baseAlpha() }):Play()
		TweenService:Create(Scale, TweenFast, { Scale = 1 }):Play()
	end)
	Btn.MouseButton1Down:Connect(function()
		if disabled then return end
		TweenService:Create(Scale, TweenFast, { Scale = 0.965 }):Play()
	end)
	Btn.MouseButton1Up:Connect(function()
		if disabled then return end
		TweenService:Create(Scale, TweenBounce, { Scale = 1.015 }):Play()
	end)

	local armed, armToken = false, 0
	local baseText = Options.Text or ""
	local function disarm()
		armed = false; armToken = armToken + 1; Btn.Text = baseText
	end

	Btn.MouseButton1Click:Connect(function()
		if disabled then return end
		if Options.Confirm and not armed then
			armed = true; armToken = armToken + 1
			local tok = armToken
			Btn.Text = Options.ConfirmText or "Confirm?"
			TweenService:Create(Btn, TweenFast, { TextColor3 = Theme.Accent }):Play()
			task.delay(2, function()
				if armed and tok == armToken and Btn.Parent then disarm() end
			end)
			return
		end
		if armed then disarm() end
		if Options.OnClick then Options.OnClick() end
	end)

	Tip(Row, Options.Tooltip)

	return {
		Frame = Row, Button = Btn,
		SetText = function(t)
			baseText = t or ""
			if not armed then Btn.Text = baseText end
		end,
		SetDisabled = function(on)
			disabled = on == true
			TweenService:Create(Btn, TweenFast, { TextTransparency = disabled and 0.55 or 0 }):Play()
			TweenService:Create(Row, TweenFast, { BackgroundTransparency = baseAlpha() }):Play()
		end,
	}
end

-- ============================================================
-- CreateToggle(Parent, { Label, Default, OnChanged, Tooltip, Flag })
-- ============================================================
function UILib.CreateToggle(Parent, Options)
	Options = Options or {}
	local state = Options.Default == true
	local W, H, K = Theme.ToggleW, Theme.ToggleH, Theme.KnobSz

	local Row = RowBase(Parent, nil, Options.Label)
	local Lbl = RowLabel(Row, Options.Label, W + 20)

	local Trk = Instance.new("Frame", Row)
	Trk.AnchorPoint     = Vector2.new(1, 0.5)
	Trk.Position        = UDim2.new(1, -10, 0.5, 0)
	Trk.Size            = UDim2.new(0, W, 0, H)
	Trk.BorderSizePixel = 0
	Pill(Trk)
	Sheen(Trk, 0.16)

	local Knob = Instance.new("Frame", Trk)
	Knob.Size            = UDim2.new(0, K, 0, K)
	Knob.BorderSizePixel = 0
	Pill(Knob)
	Track(Knob, { BackgroundColor3 = "Knob" })

	-- Glow behind the knob so the switch reads as lit when on rather
	-- than merely repositioned.
	local Glow = Instance.new("ImageLabel", Trk)
	Glow.BackgroundTransparency = 1
	Glow.AnchorPoint            = Vector2.new(0.5, 0.5)
	Glow.Size                   = UDim2.new(0, K + 16, 0, K + 16)
	Glow.Image                  = "rbxassetid://6014261993"
	Glow.ImageTransparency      = 1
	Glow.ScaleType              = Enum.ScaleType.Slice
	Glow.SliceCenter            = Rect.new(49, 49, 450, 450)
	Glow.ZIndex                 = 0
	Track(Glow, { ImageColor3 = "Accent" })

	local function pos(on)
		return on and UDim2.new(0, W - K - 2, 0.5, -K / 2) or UDim2.new(0, 2, 0.5, -K / 2)
	end
	React(Row, function()
		Trk.BackgroundColor3 = state and Theme.ToggleOn or Theme.ToggleOff
	end)

	local function Set(on, fire)
		state = on == true
		TweenService:Create(Trk, TweenFast,
			{ BackgroundColor3 = state and Theme.ToggleOn or Theme.ToggleOff }):Play()
		TweenService:Create(Knob, TweenBounce, { Position = pos(state) }):Play()
		TweenService:Create(Glow, TweenBounce,
			{ Position = pos(state) + UDim2.fromOffset(K / 2, 0) }):Play()
		TweenService:Create(Glow, TweenMed, { ImageTransparency = state and 0.5 or 1 }):Play()
		if fire ~= false and Options.OnChanged then Options.OnChanged(state, Set) end
	end

	Knob.Position          = pos(state)
	Glow.Position          = pos(state) + UDim2.fromOffset(K / 2, 0)
	Glow.ImageTransparency = state and 0.5 or 1

	local Hit = Instance.new("TextButton", Row)
	Hit.Size                   = UDim2.new(1, 0, 1, 0)
	Hit.BackgroundTransparency = 1
	Hit.Text                   = ""
	Hit.AutoButtonColor        = false

	local disabled = false
	Hit.MouseButton1Click:Connect(function()
		if disabled then return end
		-- Squash across, spring back to round.
		TweenService:Create(Knob, TweenFast, { Size = UDim2.new(0, K + 4, 0, K - 2) }):Play()
		task.delay(0.1, function()
			TweenService:Create(Knob, TweenBounce, { Size = UDim2.new(0, K, 0, K) }):Play()
		end)
		Set(not state)
	end)
	HoverRow(Row, function() return not disabled end)
	Tip(Row, Options.Tooltip)

	if Options.Flag then
		Flags[Options.Flag] = {
			Kind = "toggle",
			Get  = function() return state end,
			Set  = function(v) Set(v == true) end,
		}
	end

	return {
		Frame = Row, Set = Set, GetValue = function() return state end,
		SetDisabled = function(on)
			disabled = on == true
			TweenService:Create(Lbl,  TweenFast, { TextTransparency = disabled and 0.5 or 0 }):Play()
			TweenService:Create(Trk,  TweenFast, { BackgroundTransparency = disabled and 0.5 or 0 }):Play()
			TweenService:Create(Knob, TweenFast, { BackgroundTransparency = disabled and 0.5 or 0 }):Play()
		end,
	}
end

-- ============================================================
-- CreateSlider(Parent, { Label, Min, Max, Default, Step, Format,
--                        OnChanged, Tooltip, Flag })
-- ============================================================
function UILib.CreateSlider(Parent, Options)
	Options = Options or {}
	local Min, Max = Options.Min or 0, Options.Max or 100
	local cur  = Options.Default or Min
	local fmt  = Options.Format or "%.0f"
	local step = Options.Step

	local Row = RowBase(Parent, nil, Options.Label)

	local LabelW = 0
	if Options.Label and Options.Label ~= "" then
		LabelW = 76
		local L = Instance.new("TextLabel", Row)
		L.Size                   = UDim2.new(0, LabelW, 1, 0)
		L.Position               = UDim2.new(0, 11, 0, 0)
		L.BackgroundTransparency = 1
		L.TextSize               = Theme.BodySize
		L.TextXAlignment         = Enum.TextXAlignment.Left
		L.TextTruncate           = Enum.TextTruncate.AtEnd
		L.Text                   = Options.Label
		Track(L, { TextColor3 = "TextPrimary", Font = "FontRegular" })
	end

	local Val = Instance.new("TextLabel", Row)
	Val.Size                   = UDim2.new(0, 40, 0, 15)
	Val.Position               = UDim2.new(1, -47, 0.5, -7)
	Val.BackgroundTransparency = 1
	Val.TextSize               = Theme.SmallSize
	Val.TextXAlignment         = Enum.TextXAlignment.Right
	Track(Val, { TextColor3 = "Accent", Font = "FontMono" })

	local Trk = Instance.new("Frame", Row)
	Trk.Size            = UDim2.new(1, -(LabelW + 62), 0, 3)
	Trk.Position        = UDim2.new(0, LabelW + 14, 0.5, -1)
	Trk.BorderSizePixel = 0
	Track(Trk, { BackgroundColor3 = "ToggleOff" })
	Pill(Trk)

	local Fill = Instance.new("Frame", Trk)
	Fill.Size            = UDim2.new(0, 0, 1, 0)
	Fill.BorderSizePixel = 0
	Track(Fill, { BackgroundColor3 = "Accent" })
	Pill(Fill)

	local Knob = Instance.new("Frame", Trk)
	Knob.Size            = UDim2.new(0, 10, 0, 10)
	Knob.AnchorPoint     = Vector2.new(0.5, 0.5)
	Knob.Position        = UDim2.new(0, 0, 0.5, 0)
	Knob.BorderSizePixel = 0
	Track(Knob, { BackgroundColor3 = "Knob" })
	Pill(Knob)

	-- Dragging writes straight through; only programmatic Set springs,
	-- so the handle never lags behind the cursor.
	local dragging = false
	local function Set(v, fire, spring)
		if step and step > 0 then
			v = Min + math.floor((v - Min) / step + 0.5) * step
		end
		v = math.clamp(v, Min, Max)
		cur = v
		Val.Text = string.format(fmt, v)
		local pct = (Max > Min) and (v - Min) / (Max - Min) or 0
		if spring then
			TweenService:Create(Fill, TweenMed, { Size = UDim2.new(pct, 0, 1, 0) }):Play()
			TweenService:Create(Knob, TweenMed, { Position = UDim2.new(pct, 0, 0.5, 0) }):Play()
		else
			Fill.Size     = UDim2.new(pct, 0, 1, 0)
			Knob.Position = UDim2.new(pct, 0, 0.5, 0)
		end
		if fire ~= false and Options.OnChanged then Options.OnChanged(v) end
	end
	Set(cur, false, false)

	local function fromX(x)
		Set(Min + math.clamp((x - Trk.AbsolutePosition.X) / Trk.AbsoluteSize.X, 0, 1) * (Max - Min))
	end

	-- The hit area is taller than the 3px track so it stays grabbable.
	local Hit = Instance.new("TextButton", Row)
	Hit.BackgroundTransparency = 1
	Hit.Position               = UDim2.new(0, LabelW + 14, 0.5, -10)
	Hit.Size                   = UDim2.new(1, -(LabelW + 62), 0, 20)
	Hit.Text                   = ""
	Hit.AutoButtonColor        = false

	Hit.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1
		or inp.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			TweenService:Create(Knob, TweenBounce, { Size = UDim2.new(0, 14, 0, 14) }):Play()
			fromX(inp.Position.X)
		end
	end)
	Scoped(Row, UserInputService.InputEnded, function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1
		or inp.UserInputType == Enum.UserInputType.Touch then
			if dragging then
				TweenService:Create(Knob, TweenBounce, { Size = UDim2.new(0, 10, 0, 10) }):Play()
			end
			dragging = false
		end
	end)
	Scoped(Row, UserInputService.InputChanged, function(inp)
		if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement
		or inp.UserInputType == Enum.UserInputType.Touch) then
			fromX(inp.Position.X)
		end
	end)

	HoverRow(Row)
	Tip(Row, Options.Tooltip)

	if Options.Flag then
		Flags[Options.Flag] = {
			Kind = "number",
			Get  = function() return cur end,
			Set  = function(v) if type(v) == "number" then Set(v, true, true) end end,
		}
	end

	return {
		Frame = Row, Update = function(v) Set(v, true, true) end,
		GetValue = function() return cur end,
	}
end

-- ============================================================
-- CreateTextInput(Parent, { Label, Placeholder, Default, Width,
--                  NumericOnly, MaxLength, OnSubmit, Tooltip, Flag })
-- ============================================================
function UILib.CreateTextInput(Parent, Options)
	Options = Options or {}
	local W = Options.Width or 90

	local Row = RowBase(Parent, nil, Options.Label)
	RowLabel(Row, Options.Label, W + 20)

	local Box = Instance.new("TextBox", Row)
	Box.AnchorPoint      = Vector2.new(1, 0.5)
	Box.Position         = UDim2.new(1, -8, 0.5, 0)
	Box.Size             = UDim2.new(0, W, 0, 20)
	Box.BorderSizePixel  = 0
	Box.TextSize         = Theme.SmallSize
	Box.PlaceholderText  = Options.Placeholder or ""
	Box.TextXAlignment   = Enum.TextXAlignment.Center
	Box.ClearTextOnFocus = false
	Box.Text             = tostring(Options.Default or "")
	Track(Box, { BackgroundColor3 = "InputBg", TextColor3 = "AccentSec",
		PlaceholderColor3 = "TextMuted", Font = "FontMono" })
	Fixed(Box, 4)
	local bs = Stroke(Box, "AccentDim", 1)

	Box.Focused:Connect(function()
		TweenService:Create(bs, TweenFast,
			{ Color = Theme.Accent, Transparency = Theme.FocusStrokeAlpha }):Play()
	end)
	Box.FocusLost:Connect(function()
		TweenService:Create(bs, TweenFast,
			{ Color = Theme.AccentDim, Transparency = Theme.StrokeAlpha }):Play()
		if Options.NumericOnly then
			local n = tonumber(Box.Text:match("%-?%d+%.?%d*"))
			Box.Text = n and tostring(n) or ""
		end
		if Options.OnSubmit then Options.OnSubmit(Box.Text) end
	end)

	if Options.MaxLength then
		Box:GetPropertyChangedSignal("Text"):Connect(function()
			if #Box.Text > Options.MaxLength then
				Box.Text = Box.Text:sub(1, Options.MaxLength)
			end
		end)
	end

	HoverRow(Row)
	Tip(Row, Options.Tooltip)

	if Options.Flag then
		Flags[Options.Flag] = {
			Kind = "text",
			Get  = function() return Box.Text end,
			Set  = function(v)
				Box.Text = tostring(v)
				if Options.OnSubmit then Options.OnSubmit(Box.Text) end
			end,
		}
	end

	return { Frame = Row, TextBox = Box, GetValue = function() return Box.Text end }
end

-- ============================================================
-- CreateKeybind(Parent, { Label, Default, OnChanged, OnTrigger,
--                         Tooltip, Flag })
-- ============================================================
function UILib.CreateKeybind(Parent, Options)
	Options = Options or {}
	local cur = Options.Default
	if type(cur) == "string" then
		local ok, parsed = pcall(function() return Enum.KeyCode[cur] end)
		cur = ok and parsed or nil
	end

	local Row = RowBase(Parent, nil, Options.Label)
	RowLabel(Row, Options.Label, 84)

	local Key = Instance.new("TextButton", Row)
	Key.AnchorPoint      = Vector2.new(1, 0.5)
	Key.Position         = UDim2.new(1, -8, 0.5, 0)
	Key.Size             = UDim2.new(0, 66, 0, 20)
	Key.BorderSizePixel  = 0
	Key.TextSize         = Theme.CaptionSize
	Key.AutoButtonColor  = false
	Key.Text             = cur and cur.Name or "None"
	Track(Key, { BackgroundColor3 = "InputBg", TextColor3 = "AccentSec", Font = "FontMono" })
	Fixed(Key, 4)
	local ks = Stroke(Key, "AccentDim", 1)

	local listening, conn = false, nil
	local function stop()
		listening = false
		TweenService:Create(ks, TweenFast,
			{ Color = Theme.AccentDim, Transparency = Theme.StrokeAlpha }):Play()
		if conn then conn:Disconnect(); conn = nil end
	end
	Row.Destroying:Connect(function()
		if conn then conn:Disconnect(); conn = nil end
	end)

	Key.MouseButton1Click:Connect(function()
		if listening then
			stop(); Key.Text = cur and cur.Name or "None"; return
		end
		listening = true
		Key.Text  = "..."
		TweenService:Create(ks, TweenFast,
			{ Color = Theme.Accent, Transparency = Theme.FocusStrokeAlpha }):Play()
		conn = UserInputService.InputBegan:Connect(function(inp)
			if inp.UserInputType ~= Enum.UserInputType.Keyboard then return end
			if inp.KeyCode ~= Enum.KeyCode.Escape then cur = inp.KeyCode end
			Key.Text = cur and cur.Name or "None"
			stop()
			if Options.OnChanged then Options.OnChanged(cur) end
		end)
	end)

	if Options.OnTrigger then
		Scoped(Row, UserInputService.InputBegan, function(inp, processed)
			if processed or listening then return end
			if inp.UserInputType == Enum.UserInputType.Keyboard and inp.KeyCode == cur then
				Options.OnTrigger(cur)
				-- Flash so a trigger is visible even with the panel hidden.
				TweenService:Create(Key, TweenFast, { BackgroundColor3 = Theme.Accent }):Play()
				task.delay(0.13, function()
					TweenService:Create(Key, TweenMed, { BackgroundColor3 = Theme.InputBg }):Play()
				end)
			end
		end)
	end

	HoverRow(Row)
	Tip(Row, Options.Tooltip)

	if Options.Flag then
		Flags[Options.Flag] = {
			Kind = "keybind",
			Get  = function() return cur and cur.Name or nil end,
			Set  = function(v)
				local kc = v
				if type(kc) == "string" then
					local ok, parsed = pcall(function() return Enum.KeyCode[kc] end)
					kc = ok and parsed or nil
				end
				if typeof(kc) == "EnumItem" then
					cur = kc; Key.Text = kc.Name
					if Options.OnChanged then Options.OnChanged(cur) end
				end
			end,
		}
	end

	return {
		Frame = Row,
		Set = function(kc) cur = kc; Key.Text = kc and kc.Name or "None" end,
		GetValue = function() return cur end,
	}
end

-- ============================================================
-- CreateDropdown(Parent, { Label, Options, Default, Multi,
--                Placeholder, OnChanged, Tooltip, Flag })
-- Selection is a filled pill, not a radio dot — one less circle on
-- screen and it matches the tab bar's active state.
-- ============================================================
function UILib.CreateDropdown(Parent, Options)
	Options = Options or {}
	local items = Options.Options or {}
	local multi = Options.Multi == true
	local sel   = {}

	if multi then
		for _, v in ipairs(Options.Default or {}) do sel[v] = true end
	else
		local d = Options.Default
		if type(d) == "number" then d = items[d] end
		if d ~= nil then sel[d] = true end
	end

	local Card = Instance.new("Frame")
	Card.Size             = UDim2.new(1, 0, 0, 0)
	Card.AutomaticSize    = Enum.AutomaticSize.Y
	Card.BorderSizePixel  = 0
	Card.ClipsDescendants = true
	Card.Parent           = Parent
	Track(Card, { BackgroundColor3 = "Bg2", BackgroundTransparency = "RowLift" })
	Corner(Card, "CornerRadiusXs")
	React(Card, function() Card:SetAttribute("UILibBaseAlpha", Theme.RowLift) end)
	local CL = Instance.new("UIListLayout", Card)
	CL.SortOrder = Enum.SortOrder.LayoutOrder
	CL.Padding   = UDim.new(0, 0)

	local searchText = Options.Label or ""
	for _, v in ipairs(items) do searchText = searchText .. " " .. tostring(v) end
	Searchable(Card, searchText, TabOf(Parent))

	local Head = Instance.new("TextButton", Card)
	Head.Size                   = UDim2.new(1, 0, 0, Theme.RowHeight)
	Head.LayoutOrder            = 0
	Head.BackgroundTransparency = 1
	Head.AutoButtonColor        = false
	Head.Text                   = ""

	local hasLabel = Options.Label and Options.Label ~= ""
	if hasLabel then
		local L = Instance.new("TextLabel", Head)
		L.Size                   = UDim2.new(0.45, 0, 1, 0)
		L.Position               = UDim2.new(0, 11, 0, 0)
		L.BackgroundTransparency = 1
		L.TextSize               = Theme.BodySize
		L.TextXAlignment         = Enum.TextXAlignment.Left
		L.TextTruncate           = Enum.TextTruncate.AtEnd
		L.Text                   = Options.Label
		Track(L, { TextColor3 = "TextPrimary", Font = "FontRegular" })
	end

	local Val = Instance.new("TextLabel", Head)
	Val.Size                   = hasLabel and UDim2.new(0.55, -30, 1, 0) or UDim2.new(1, -38, 1, 0)
	Val.Position               = hasLabel and UDim2.new(0.45, 0, 0, 0) or UDim2.new(0, 11, 0, 0)
	Val.BackgroundTransparency = 1
	Val.TextSize               = Theme.SmallSize
	Val.TextXAlignment         = Enum.TextXAlignment.Right
	Val.TextTruncate           = Enum.TextTruncate.AtEnd
	Track(Val, { TextColor3 = "Accent", Font = "FontMono" })

	local Chev = Instance.new("TextLabel", Head)
	Chev.Size                   = UDim2.new(0, 16, 1, 0)
	Chev.Position               = UDim2.new(1, -20, 0, 0)
	Chev.BackgroundTransparency = 1
	Chev.TextSize               = 11
	Chev.Text                   = "\u{25BC}"
	Track(Chev, { TextColor3 = "TextMuted", Font = "FontIcon" })

	local List_ = Instance.new("Frame", Card)
	List_.Size                   = UDim2.new(1, 0, 0, 0)
	List_.AutomaticSize          = Enum.AutomaticSize.Y
	List_.LayoutOrder            = 1
	List_.BackgroundTransparency = 1
	List_.Visible                = false
	Pad(List_, 6, 6, 0, 6)
	List(List_, Enum.FillDirection.Vertical, 2)

	local rows = {}

	local function label()
		local out = {}
		for _, v in ipairs(items) do
			if sel[v] then table.insert(out, tostring(v)) end
		end
		Val.Text = (#out > 0) and table.concat(out, ", ") or (Options.Placeholder or "none")
	end

	local function refresh()
		for v, r in pairs(rows) do
			local on = sel[v] == true
			TweenService:Create(r, TweenFast, {
				BackgroundTransparency = on and 0 or 1,
				TextColor3 = on and Theme.ActiveTabText or Theme.TextMuted,
			}):Play()
			r.Font = on and Theme.FontMedium or Theme.FontRegular
		end
	end
	React(Card, function() refresh(); Chev.TextColor3 = Theme.TextMuted end)

	local function getValue()
		if multi then
			local out = {}
			for _, v in ipairs(items) do if sel[v] then table.insert(out, v) end end
			return out
		end
		for _, v in ipairs(items) do if sel[v] then return v end end
		return nil
	end

	local open = false
	local function setOpen(o)
		open = o
		List_.Visible = o
		TweenService:Create(Chev, TweenMed, {
			Rotation = o and 180 or 0,
			TextColor3 = o and Theme.Accent or Theme.TextMuted,
		}):Play()
		if o then
			OverlayOpened(Card, function() setOpen(false) end)
			local n = 0
			for _, c in ipairs(List_:GetChildren()) do
				if c:IsA("TextButton") then
					n = n + 1
					local final = c.Position
					c.Position = final + UDim2.fromOffset(-5, 0)
					local h = c
					task.delay(0.011 * n, function()
						if h.Parent then
							TweenService:Create(h, TweenMed, { Position = final }):Play()
						end
					end)
				end
			end
		else
			OverlayClosed(Card)
		end
	end
	Card.Destroying:Connect(function() OverlayClosed(Card) end)

	local function buildRows()
		for _, r in pairs(rows) do r:Destroy() end
		rows = {}
		for i, v in ipairs(items) do
			local R = Instance.new("TextButton", List_)
			R.Size                   = UDim2.new(1, 0, 0, 23)
			R.LayoutOrder            = i
			R.BackgroundTransparency = 1
			R.AutoButtonColor        = false
			R.TextSize               = Theme.SmallSize
			R.TextXAlignment         = Enum.TextXAlignment.Left
			R.TextTruncate           = Enum.TextTruncate.AtEnd
			R.Text                   = "  " .. tostring(v)
			Track(R, { BackgroundColor3 = "Accent" })
			Fixed(R, 4)
			rows[v] = R

			R.MouseButton1Click:Connect(function()
				if multi then
					sel[v] = (not sel[v]) or nil
				else
					sel = {}; sel[v] = true
				end
				refresh(); label()
				if Options.OnChanged then Options.OnChanged(getValue()) end
				if not multi then setOpen(false) end
			end)
			R.MouseEnter:Connect(function()
				if not sel[v] then
					TweenService:Create(R, TweenFast, { TextColor3 = Theme.TextPrimary }):Play()
				end
			end)
			R.MouseLeave:Connect(function()
				if not sel[v] then
					TweenService:Create(R, TweenFast, { TextColor3 = Theme.TextMuted }):Play()
				end
			end)
		end
		refresh()
	end

	buildRows(); label()
	Tip(Head, Options.Tooltip)
	Head.MouseButton1Click:Connect(function() setOpen(not open) end)
	Head.MouseEnter:Connect(function()
		TweenService:Create(Card, TweenFast, { BackgroundTransparency = 0 }):Play()
	end)
	Head.MouseLeave:Connect(function()
		TweenService:Create(Card, TweenFast, { BackgroundTransparency = Theme.RowLift }):Play()
	end)

	if Options.Flag then
		Flags[Options.Flag] = {
			Kind = multi and "table" or "value",
			Get  = getValue,
			Set  = function(v)
				sel = {}
				if multi then
					if type(v) == "table" then for _, x in ipairs(v) do sel[x] = true end end
				else
					if type(v) == "number" then v = items[v] end
					if v ~= nil then sel[v] = true end
				end
				refresh(); label()
				if Options.OnChanged then Options.OnChanged(getValue()) end
			end,
		}
	end

	return {
		Frame = Card, SetOpen = setOpen, GetValue = getValue,
		SetItems = function(newItems, keep)
			items = newItems or {}
			if keep then
				local look = {}
				for _, v in ipairs(items) do look[v] = true end
				for v in pairs(sel) do if not look[v] then sel[v] = nil end end
			else
				sel = {}
			end
			buildRows(); label()
		end,
	}
end

-- ============================================================
-- CreateGroup(Parent, { Label, Options, Default, OnChanged, Flag })
-- Segmented control rather than a radio stack: for three or four
-- mutually exclusive choices it costs one row instead of four.
-- Falls back to a vertical list past five options.
-- ============================================================
function UILib.CreateGroup(Parent, Options)
	Options = Options or {}
	local items = Options.Options or {}
	local cur   = Options.Default or 1
	local segmented = #items <= 4

	local searchText = Options.Label or ""
	for _, v in ipairs(items) do searchText = searchText .. " " .. tostring(v) end

	local Wrap = Instance.new("Frame")
	Wrap.Size                   = UDim2.new(1, 0, 0, 0)
	Wrap.AutomaticSize          = Enum.AutomaticSize.Y
	Wrap.BackgroundTransparency = 1
	Wrap.BorderSizePixel        = 0
	Wrap.Parent                 = Parent
	List(Wrap, Enum.FillDirection.Vertical, 3)
	Searchable(Wrap, searchText, TabOf(Parent))

	if Options.Label and Options.Label ~= "" then
		local L = Instance.new("TextLabel", Wrap)
		L.Size                   = UDim2.new(1, 0, 0, 15)
		L.LayoutOrder            = 0
		L.BackgroundTransparency = 1
		L.TextSize               = Theme.CaptionSize
		L.TextXAlignment         = Enum.TextXAlignment.Left
		Pad(L, 2, 0, 0, 0)
		Track(L, { TextColor3 = "TextMuted", Font = "FontBold" })
		React(L, function() L.Text = Caps(Options.Label) end)
	end

	local btns = {}
	local function refresh()
		for i, b in ipairs(btns) do
			local on = (i == cur)
			TweenService:Create(b, TweenFast, {
				BackgroundTransparency = on and 0 or 1,
				TextColor3 = on and Theme.ActiveTabText or Theme.TextMuted,
			}):Play()
			b.Font = on and Theme.FontBold or Theme.FontRegular
		end
	end
	React(Wrap, refresh)

	local Holder = Instance.new("Frame", Wrap)
	Holder.LayoutOrder    = 1
	Holder.BorderSizePixel = 0
	Track(Holder, { BackgroundColor3 = "Bg2", BackgroundTransparency = "RowLift" })
	Corner(Holder, "CornerRadiusXs")

	if segmented then
		Holder.Size = UDim2.new(1, 0, 0, Theme.RowHeight)
		Pad(Holder, 3, 3, 3, 3)
		List(Holder, Enum.FillDirection.Horizontal, 3,
			Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center)
	else
		Holder.Size          = UDim2.new(1, 0, 0, 0)
		Holder.AutomaticSize = Enum.AutomaticSize.Y
		Pad(Holder, 3, 3, 3, 3)
		List(Holder, Enum.FillDirection.Vertical, 2)
	end

	for i, text in ipairs(items) do
		local B = Instance.new("TextButton", Holder)
		B.LayoutOrder            = i
		B.BackgroundTransparency = 1
		B.BorderSizePixel        = 0
		B.AutoButtonColor        = false
		B.TextSize               = Theme.SmallSize
		B.Text                   = tostring(text)
		B.TextTruncate           = Enum.TextTruncate.AtEnd
		Track(B, { BackgroundColor3 = "Accent" })
		Fixed(B, 4)
		if segmented then
			B.Size = UDim2.new(1 / #items, -3 + 3 / #items, 1, 0)
		else
			B.Size           = UDim2.new(1, 0, 0, 22)
			B.TextXAlignment = Enum.TextXAlignment.Left
			Pad(B, 7, 4, 0, 0)
		end
		btns[i] = B

		B.MouseButton1Click:Connect(function()
			cur = i
			refresh()
			if Options.OnChanged then Options.OnChanged(i, text) end
		end)
		B.MouseEnter:Connect(function()
			if cur ~= i then
				TweenService:Create(B, TweenFast, { TextColor3 = Theme.TextPrimary }):Play()
			end
		end)
		B.MouseLeave:Connect(function()
			if cur ~= i then
				TweenService:Create(B, TweenFast, { TextColor3 = Theme.TextMuted }):Play()
			end
		end)
	end

	refresh()
	Tip(Holder, Options.Tooltip)

	if Options.Flag then
		Flags[Options.Flag] = {
			Kind = "number",
			Get  = function() return cur end,
			Set  = function(i)
				if type(i) == "number" and items[i] then
					cur = i; refresh()
					if Options.OnChanged then Options.OnChanged(i, items[i]) end
				end
			end,
		}
	end

	return {
		Frame = Wrap,
		SetValue = function(i) cur = i; refresh() end,
		GetValue = function() return cur, items[cur] end,
	}
end

-- ============================================================
-- CreateColorPicker(Parent, { Label, Default, OnChanged, Flag })
-- ============================================================
function UILib.CreateColorPicker(Parent, Options)
	Options = Options or {}
	local cur = Options.Default or Color3.fromRGB(255, 255, 255)
	local h, s, v = cur:ToHSV()

	local Card = Instance.new("Frame")
	Card.Size             = UDim2.new(1, 0, 0, 0)
	Card.AutomaticSize    = Enum.AutomaticSize.Y
	Card.BorderSizePixel  = 0
	Card.ClipsDescendants = true
	Card.Parent           = Parent
	Track(Card, { BackgroundColor3 = "Bg2", BackgroundTransparency = "RowLift" })
	Corner(Card, "CornerRadiusXs")
	React(Card, function() Card:SetAttribute("UILibBaseAlpha", Theme.RowLift) end)
	local CL = Instance.new("UIListLayout", Card)
	CL.SortOrder = Enum.SortOrder.LayoutOrder
	CL.Padding   = UDim.new(0, 0)
	Searchable(Card, Options.Label, TabOf(Parent))

	local Head = Instance.new("TextButton", Card)
	Head.Size                   = UDim2.new(1, 0, 0, Theme.RowHeight)
	Head.LayoutOrder            = 0
	Head.BackgroundTransparency = 1
	Head.AutoButtonColor        = false
	Head.Text                   = ""

	local L = Instance.new("TextLabel", Head)
	L.Size                   = UDim2.new(1, -110, 1, 0)
	L.Position               = UDim2.new(0, 11, 0, 0)
	L.BackgroundTransparency = 1
	L.TextSize               = Theme.BodySize
	L.TextXAlignment         = Enum.TextXAlignment.Left
	L.Text                   = Options.Label or ""
	Track(L, { TextColor3 = "TextPrimary", Font = "FontRegular" })

	local HexLbl = Instance.new("TextLabel", Head)
	HexLbl.AnchorPoint            = Vector2.new(1, 0.5)
	HexLbl.Position               = UDim2.new(1, -42, 0.5, 0)
	HexLbl.Size                   = UDim2.new(0, 62, 0, 15)
	HexLbl.BackgroundTransparency = 1
	HexLbl.TextSize               = Theme.CaptionSize
	HexLbl.TextXAlignment         = Enum.TextXAlignment.Right
	Track(HexLbl, { TextColor3 = "TextMuted", Font = "FontMono" })

	local Swatch = Instance.new("Frame", Head)
	Swatch.AnchorPoint      = Vector2.new(1, 0.5)
	Swatch.Position         = UDim2.new(1, -9, 0.5, 0)
	Swatch.Size             = UDim2.new(0, 28, 0, 18)
	Swatch.BackgroundColor3 = cur
	Swatch.BorderSizePixel  = 0
	Fixed(Swatch, 4)

	local Panel = Instance.new("Frame", Card)
	Panel.Size                   = UDim2.new(1, 0, 0, 0)
	Panel.AutomaticSize          = Enum.AutomaticSize.Y
	Panel.LayoutOrder            = 1
	Panel.BackgroundTransparency = 1
	Panel.Visible                = false
	Pad(Panel, 9, 9, 2, 9)
	List(Panel, Enum.FillDirection.Vertical, 7)

	local SV = Instance.new("Frame", Panel)
	SV.Size             = UDim2.new(1, 0, 0, 84)
	SV.LayoutOrder      = 0
	SV.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
	SV.BorderSizePixel  = 0
	SV.ClipsDescendants = true
	Fixed(SV, 5)

	local Sat = Instance.new("Frame", SV)
	Sat.Size             = UDim2.new(1, 0, 1, 0)
	Sat.BackgroundColor3 = Color3.new(1, 1, 1)
	Sat.BorderSizePixel  = 0
	local sg = Instance.new("UIGradient", Sat)
	sg.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1) })

	local Vl = Instance.new("Frame", SV)
	Vl.Size             = UDim2.new(1, 0, 1, 0)
	Vl.BackgroundColor3 = Color3.new(0, 0, 0)
	Vl.BorderSizePixel  = 0
	local vg = Instance.new("UIGradient", Vl)
	vg.Rotation     = 90
	vg.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0) })

	local Cur = Instance.new("Frame", SV)
	Cur.Size             = UDim2.new(0, 9, 0, 9)
	Cur.AnchorPoint      = Vector2.new(0.5, 0.5)
	Cur.BackgroundColor3 = Color3.new(1, 1, 1)
	Cur.BorderSizePixel  = 0
	Cur.ZIndex           = 2
	Pill(Cur)
	local cst = Instance.new("UIStroke", Cur)
	cst.Color = Color3.new(0, 0, 0); cst.Thickness = 1.5

	local Hue = Instance.new("Frame", Panel)
	Hue.Size            = UDim2.new(1, 0, 0, 10)
	Hue.LayoutOrder     = 1
	Hue.BorderSizePixel = 0
	Pill(Hue)
	local hg = Instance.new("UIGradient", Hue)
	hg.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0.000, Color3.fromHSV(0 / 6, 1, 1)),
		ColorSequenceKeypoint.new(0.166, Color3.fromHSV(1 / 6, 1, 1)),
		ColorSequenceKeypoint.new(0.333, Color3.fromHSV(2 / 6, 1, 1)),
		ColorSequenceKeypoint.new(0.500, Color3.fromHSV(3 / 6, 1, 1)),
		ColorSequenceKeypoint.new(0.666, Color3.fromHSV(4 / 6, 1, 1)),
		ColorSequenceKeypoint.new(0.833, Color3.fromHSV(5 / 6, 1, 1)),
		ColorSequenceKeypoint.new(1.000, Color3.fromHSV(6 / 6, 1, 1)),
	})

	local HueCur = Instance.new("Frame", Hue)
	HueCur.Size             = UDim2.new(0, 3, 1, 4)
	HueCur.AnchorPoint      = Vector2.new(0.5, 0.5)
	HueCur.Position         = UDim2.new(h, 0, 0.5, 0)
	HueCur.BackgroundColor3 = Color3.new(1, 1, 1)
	HueCur.BorderSizePixel  = 0
	Pill(HueCur)
	local hcs = Instance.new("UIStroke", HueCur)
	hcs.Color = Color3.new(0, 0, 0); hcs.Thickness = 1

	local Hex = Instance.new("TextBox", Panel)
	Hex.Size             = UDim2.new(1, 0, 0, 22)
	Hex.LayoutOrder      = 2
	Hex.BorderSizePixel  = 0
	Hex.TextSize         = Theme.SmallSize
	Hex.ClearTextOnFocus = false
	Track(Hex, { BackgroundColor3 = "InputBg", TextColor3 = "AccentSec", Font = "FontMono" })
	Fixed(Hex, 4)
	local hxs = Stroke(Hex, "AccentDim", 1)
	Hex.Focused:Connect(function()
		TweenService:Create(hxs, TweenFast,
			{ Color = Theme.Accent, Transparency = Theme.FocusStrokeAlpha }):Play()
	end)

	local function emit(fire)
		cur                     = Color3.fromHSV(h, s, v)
		Swatch.BackgroundColor3 = cur
		SV.BackgroundColor3     = Color3.fromHSV(h, 1, 1)
		Cur.Position            = UDim2.new(s, 0, 1 - v, 0)
		HueCur.Position         = UDim2.new(h, 0, 0.5, 0)
		local hex = string.format("#%02X%02X%02X",
			math.floor(cur.R * 255 + 0.5),
			math.floor(cur.G * 255 + 0.5),
			math.floor(cur.B * 255 + 0.5))
		Hex.Text    = hex
		HexLbl.Text = hex
		if fire and Options.OnChanged then Options.OnChanged(cur) end
	end
	emit(false)

	local dragSV, dragHue = false, false
	local function jumpSV(p)
		s = math.clamp((p.X - SV.AbsolutePosition.X) / SV.AbsoluteSize.X, 0, 1)
		v = 1 - math.clamp((p.Y - SV.AbsolutePosition.Y) / SV.AbsoluteSize.Y, 0, 1)
		emit(true)
	end
	local function jumpHue(p)
		h = math.clamp((p.X - Hue.AbsolutePosition.X) / Hue.AbsoluteSize.X, 0, 1)
		emit(true)
	end

	Vl.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1
		or inp.UserInputType == Enum.UserInputType.Touch then
			dragSV = true; jumpSV(inp.Position)
		end
	end)
	Hue.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1
		or inp.UserInputType == Enum.UserInputType.Touch then
			dragHue = true; jumpHue(inp.Position)
		end
	end)
	Scoped(Card, UserInputService.InputEnded, function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1
		or inp.UserInputType == Enum.UserInputType.Touch then
			dragSV, dragHue = false, false
		end
	end)
	Scoped(Card, UserInputService.InputChanged, function(inp)
		if inp.UserInputType ~= Enum.UserInputType.MouseMovement
		and inp.UserInputType ~= Enum.UserInputType.Touch then return end
		if dragSV then jumpSV(inp.Position) elseif dragHue then jumpHue(inp.Position) end
	end)

	Hex.FocusLost:Connect(function()
		TweenService:Create(hxs, TweenFast,
			{ Color = Theme.AccentDim, Transparency = Theme.StrokeAlpha }):Play()
		local x = Hex.Text:gsub("#", "")
		if #x == 6 and x:match("^%x+$") then
			h, s, v = Color3.new(
				tonumber(x:sub(1, 2), 16) / 255,
				tonumber(x:sub(3, 4), 16) / 255,
				tonumber(x:sub(5, 6), 16) / 255):ToHSV()
			emit(true)
		else
			emit(false)
		end
	end)

	local open = false
	local function setOpen(o)
		open = o
		Panel.Visible = o
		if o then OverlayOpened(Card, function() setOpen(false) end) else OverlayClosed(Card) end
	end
	Card.Destroying:Connect(function() OverlayClosed(Card) end)
	Head.MouseButton1Click:Connect(function() setOpen(not open) end)
	Head.MouseEnter:Connect(function()
		TweenService:Create(Card, TweenFast, { BackgroundTransparency = 0 }):Play()
	end)
	Head.MouseLeave:Connect(function()
		TweenService:Create(Card, TweenFast, { BackgroundTransparency = Theme.RowLift }):Play()
	end)
	Tip(Head, Options.Tooltip)

	if Options.Flag then
		Flags[Options.Flag] = {
			Kind = "color",
			Get  = function() return cur end,
			Set  = function(c)
				if typeof(c) == "Color3" then h, s, v = c:ToHSV(); emit(true) end
			end,
		}
	end

	return {
		Frame = Card, SetOpen = setOpen, GetValue = function() return cur end,
		SetValue = function(c) h, s, v = c:ToHSV(); emit(false) end,
	}
end

-- ============================================================
-- Text, data and layout components
-- ============================================================
function UILib.CreateLabel(Parent, Options)
	Options = Options or {}
	local L = Instance.new("TextLabel")
	L.Size                   = UDim2.new(1, 0, 0, Options.Height or 17)
	L.BackgroundTransparency = 1
	L.BorderSizePixel        = 0
	L.TextSize               = Options.TextSize or Theme.SmallSize
	L.TextXAlignment         = Options.Alignment or Enum.TextXAlignment.Left
	L.TextTruncate           = Enum.TextTruncate.AtEnd
	L.Text                   = Options.Text or ""
	L.Parent                 = Parent
	Pad(L, 2, 0, 0, 0)
	if Options.Color then
		L.TextColor3 = Options.Color
		Track(L, { Font = "FontRegular" })
	else
		Track(L, { TextColor3 = "TextMuted", Font = "FontRegular" })
	end
	if Options.Font then L.Font = Options.Font end
	Searchable(L, Options.Text, TabOf(Parent))
	return { Frame = L, Label = L, SetText = function(t) L.Text = t or "" end }
end

function UILib.CreateParagraph(Parent, Options)
	Options = Options or {}

	local Card = Instance.new("Frame")
	Card.Size            = UDim2.new(1, 0, 0, 0)
	Card.AutomaticSize   = Enum.AutomaticSize.Y
	Card.BorderSizePixel = 0
	Card.Parent          = Parent
	Track(Card, { BackgroundColor3 = "Bg2", BackgroundTransparency = "RowLift" })
	Corner(Card, "CornerRadiusXs")
	React(Card, function() Card:SetAttribute("UILibBaseAlpha", Theme.RowLift) end)
	Pad(Card, 11, 11, 9, 10)
	List(Card, Enum.FillDirection.Vertical, 3)

	local T
	if Options.Title and Options.Title ~= "" then
		T = Instance.new("TextLabel", Card)
		T.Size                   = UDim2.new(1, 0, 0, 0)
		T.AutomaticSize          = Enum.AutomaticSize.Y
		T.BackgroundTransparency = 1
		T.TextSize               = Theme.CaptionSize
		T.TextXAlignment         = Enum.TextXAlignment.Left
		T.TextWrapped            = true
		T.LayoutOrder            = 0
		Track(T, { TextColor3 = "Accent", Font = "FontBold" })
		React(Card, function() T.Text = Caps(Options.Title) end)
	end

	local B = Instance.new("TextLabel", Card)
	B.Size                   = UDim2.new(1, 0, 0, 0)
	B.AutomaticSize          = Enum.AutomaticSize.Y
	B.BackgroundTransparency = 1
	B.TextSize               = Theme.SmallSize
	B.TextXAlignment         = Enum.TextXAlignment.Left
	B.TextYAlignment         = Enum.TextYAlignment.Top
	B.TextWrapped            = true
	B.LayoutOrder            = 1
	B.Text                   = Options.Content or Options.Text or ""
	Track(B, { TextColor3 = "TextMuted", Font = "FontRegular" })

	Searchable(Card, (Options.Title or "") .. " " .. (Options.Content or Options.Text or ""),
		TabOf(Parent))

	return {
		Frame = Card,
		SetTitle = function(t) if T then T.Text = Caps(t) end end,
		SetText  = function(t) B.Text = t end,
	}
end

-- Key/value strips are the densest thing here on purpose: no
-- background at all, just a dotted leader between label and value,
-- so a stack of readouts reads as a table rather than a list of cards.
function UILib.CreateKeyValue(Parent, Options)
	Options = Options or {}
	local value = Options.Value ~= nil and tostring(Options.Value) or "-"

	local Row = Instance.new("Frame")
	Row.Size                   = UDim2.new(1, 0, 0, 22)
	Row.BackgroundTransparency = 1
	Row.BorderSizePixel        = 0
	Row.Parent                 = Parent
	Row:SetAttribute("UILibBaseAlpha", 1)
	Searchable(Row, Options.Label, TabOf(Parent))
	Pad(Row, 2, 2, 0, 0)

	local K = Instance.new("TextLabel", Row)
	K.Size                   = UDim2.new(0.5, 0, 1, 0)
	K.BackgroundTransparency = 1
	K.TextSize               = Theme.SmallSize
	K.TextXAlignment         = Enum.TextXAlignment.Left
	K.TextTruncate           = Enum.TextTruncate.AtEnd
	K.Text                   = Options.Label or ""
	Track(K, { TextColor3 = "TextMuted", Font = "FontRegular" })

	local Leader = Instance.new("Frame", Row)
	Leader.AnchorPoint            = Vector2.new(0, 1)
	Leader.Position               = UDim2.new(0, 0, 1, -6)
	Leader.Size                   = UDim2.new(1, 0, 0, 1)
	Leader.BackgroundTransparency = 0.82
	Leader.BorderSizePixel        = 0
	Leader.ZIndex                 = 0
	Track(Leader, { BackgroundColor3 = "TextMuted" })

	local V = Instance.new("TextLabel", Row)
	V.AnchorPoint            = Vector2.new(1, 0)
	V.Position               = UDim2.new(1, 0, 0, 0)
	V.Size                   = UDim2.new(0.5, 0, 1, 0)
	V.BackgroundTransparency = 1
	V.TextSize               = Theme.SmallSize
	V.TextXAlignment         = Enum.TextXAlignment.Right
	V.TextTruncate           = Enum.TextTruncate.AtEnd
	V.Text                   = value
	V.ZIndex                 = 2
	Track(V, { TextColor3 = "TextPrimary", Font = "FontMono" })

	-- Masks the leader behind each end so it reads as a gap, not a rule
	-- crossing the text.
	local function mask(label, align)
		local m = Instance.new("Frame", Row)
		m.Size                   = UDim2.new(0, 6, 1, 0)
		m.AnchorPoint            = Vector2.new(align, 0)
		m.Position               = UDim2.new(align, 0, 0, 0)
		m.BackgroundTransparency = 1
		m.BorderSizePixel        = 0
		m.ZIndex                 = 1
		return m
	end
	mask(K, 0); mask(V, 1)

	Tip(Row, Options.Tooltip)

	return {
		Frame = Row,
		SetValue = function(v) value = tostring(v); V.Text = value end,
		SetLabel = function(t) K.Text = t or "" end,
		GetValue = function() return value end,
	}
end

function UILib.CreateProgressBar(Parent, Options)
	Options = Options or {}
	local Min, Max = Options.Min or 0, Options.Max or 100
	local cur = math.clamp(Options.Default or Min, Min, Max)

	local Row = Instance.new("Frame")
	Row.Size                   = UDim2.new(1, 0, 0, 30)
	Row.BackgroundTransparency = 1
	Row.BorderSizePixel        = 0
	Row.Parent                 = Parent
	Row:SetAttribute("UILibBaseAlpha", 1)
	Pad(Row, 2, 2, 0, 0)
	Searchable(Row, Options.Label, TabOf(Parent))

	local L = Instance.new("TextLabel", Row)
	L.Size                   = UDim2.new(1, -50, 0, 15)
	L.BackgroundTransparency = 1
	L.TextSize               = Theme.SmallSize
	L.TextXAlignment         = Enum.TextXAlignment.Left
	L.TextTruncate           = Enum.TextTruncate.AtEnd
	L.Text                   = Options.Label or ""
	Track(L, { TextColor3 = "TextMuted", Font = "FontRegular" })

	local P = Instance.new("TextLabel", Row)
	P.AnchorPoint            = Vector2.new(1, 0)
	P.Position               = UDim2.new(1, 0, 0, 0)
	P.Size                   = UDim2.new(0, 50, 0, 15)
	P.BackgroundTransparency = 1
	P.TextSize               = Theme.SmallSize
	P.TextXAlignment         = Enum.TextXAlignment.Right
	Track(P, { TextColor3 = "TextPrimary", Font = "FontMono" })

	local Trk = Instance.new("Frame", Row)
	Trk.Position        = UDim2.new(0, 0, 0, 21)
	Trk.Size            = UDim2.new(1, 0, 0, 3)
	Trk.BorderSizePixel = 0
	Track(Trk, { BackgroundColor3 = "ToggleOff" })
	Pill(Trk)

	local Fill = Instance.new("Frame", Trk)
	Fill.Size            = UDim2.new(0, 0, 1, 0)
	Fill.BorderSizePixel = 0
	Track(Fill, { BackgroundColor3 = "Accent" })
	Pill(Fill)

	local function Update(val, instant)
		val = math.clamp(val, Min, Max)
		cur = val
		local pct = (Max > Min) and (val - Min) / (Max - Min) or 0
		P.Text = string.format(Options.Format or "%d%%", math.floor(pct * 100 + 0.5))
		if instant then
			Fill.Size = UDim2.new(pct, 0, 1, 0)
		else
			TweenService:Create(Fill, TweenMed, { Size = UDim2.new(pct, 0, 1, 0) }):Play()
		end
	end
	Update(cur, true)

	return {
		Frame = Row, Update = Update,
		GetValue = function() return cur end,
		SetLabel = function(t) L.Text = t or "" end,
	}
end

function UILib.CreateDivider(Parent, Options)
	Options = Options or {}

	if not Options.Text or Options.Text == "" then
		local Holder = Instance.new("Frame")
		Holder.Size                   = UDim2.new(1, 0, 0, 9)
		Holder.BackgroundTransparency = 1
		Holder.BorderSizePixel        = 0
		Holder.Parent                 = Parent
		local d = Instance.new("Frame", Holder)
		d.AnchorPoint            = Vector2.new(0, 0.5)
		d.Position               = UDim2.new(0, 2, 0.5, 0)
		d.Size                   = UDim2.new(1, -4, 0, 1)
		d.BackgroundTransparency = 0.8
		d.BorderSizePixel        = 0
		Track(d, { BackgroundColor3 = "TextMuted" })
		return Holder
	end

	-- With a caption it's a caps micro-label plus a rule to its right,
	-- rather than text floating in the middle of a line.
	local Holder = Instance.new("Frame")
	Holder.Size                   = UDim2.new(1, 0, 0, 16)
	Holder.BackgroundTransparency = 1
	Holder.BorderSizePixel        = 0
	Holder.Parent                 = Parent
	Pad(Holder, 2, 2, 0, 0)

	local Cap = Instance.new("TextLabel", Holder)
	Cap.AnchorPoint            = Vector2.new(0, 0.5)
	Cap.Position               = UDim2.new(0, 0, 0.5, 0)
	Cap.Size                   = UDim2.new(0, 0, 1, 0)
	Cap.AutomaticSize          = Enum.AutomaticSize.X
	Cap.BackgroundTransparency = 1
	Cap.TextSize               = Theme.CaptionSize
	Cap.TextXAlignment         = Enum.TextXAlignment.Left
	Track(Cap, { TextColor3 = "TextMuted", Font = "FontBold" })
	React(Holder, function() Cap.Text = Caps(Options.Text) end)

	local Line = Instance.new("Frame", Holder)
	Line.AnchorPoint            = Vector2.new(1, 0.5)
	Line.Position               = UDim2.new(1, 0, 0.5, 0)
	Line.BackgroundTransparency = 0.85
	Line.BorderSizePixel        = 0
	Track(Line, { BackgroundColor3 = "TextMuted" })
	-- Recomputed rather than scaled, so the rule always starts just
	-- after the caption whatever its length.
	local function fit()
		Line.Size = UDim2.new(1, -(Cap.AbsoluteSize.X + 10), 0, 1)
	end
	fit()
	Cap:GetPropertyChangedSignal("AbsoluteSize"):Connect(fit)

	return Holder
end

function UILib.CreateSpace(Parent, Options)
	Options = Options or {}
	local S = Instance.new("Frame")
	S.Size = Options.Width and UDim2.new(0, Options.Width, 0, Options.Height or 6)
		or UDim2.new(1, 0, 0, Options.Height or 6)
	S.BackgroundTransparency = 1
	S.BorderSizePixel        = 0
	S.Parent                 = Parent
	return { Frame = S }
end

function UILib.CreateHStack(Parent, Options)
	Options = Options or {}
	local gap = Options.Spacing or 5

	local S = Instance.new("Frame")
	S.BackgroundTransparency = 1
	S.BorderSizePixel        = 0
	S.Parent                 = Parent
	if Options.Height then
		S.Size = UDim2.new(1, 0, 0, Options.Height)
	else
		S.Size          = UDim2.new(1, 0, 0, 0)
		S.AutomaticSize = Enum.AutomaticSize.Y
	end
	List(S, Enum.FillDirection.Horizontal, gap,
		Options.HorizontalAlignment or Enum.HorizontalAlignment.Left,
		Options.VerticalAlignment or Enum.VerticalAlignment.Center)

	local inh = TabOf(Parent)
	if inh then S:SetAttribute("UILibTab", inh) end

	-- Components build full-width since they're normally alone in a
	-- row. In a horizontal stack that makes each claim everything, so
	-- give them an equal share. Children auto-sizing on X are left be.
	local function relayout()
		local kids = {}
		for _, c in ipairs(S:GetChildren()) do
			if c:IsA("GuiObject") then table.insert(kids, c) end
		end
		local n = #kids
		if n == 0 then return end
		local off = -(gap * (n - 1)) / n
		for _, c in ipairs(kids) do
			if c.AutomaticSize ~= Enum.AutomaticSize.X
			and c.AutomaticSize ~= Enum.AutomaticSize.XY then
				c.Size = UDim2.new(1 / n, off, c.Size.Y.Scale, c.Size.Y.Offset)
			end
		end
	end
	S.ChildAdded:Connect(relayout)
	S.ChildRemoved:Connect(relayout)

	return { Frame = S }
end

function UILib.CreateVStack(Parent, Options)
	Options = Options or {}
	local S = Instance.new("Frame")
	S.Size                   = UDim2.new(1, 0, 0, 0)
	S.AutomaticSize          = Enum.AutomaticSize.Y
	S.BackgroundTransparency = 1
	S.BorderSizePixel        = 0
	S.Parent                 = Parent
	List(S, Enum.FillDirection.Vertical, Options.Spacing or 5,
		Options.HorizontalAlignment or Enum.HorizontalAlignment.Left,
		Options.VerticalAlignment or Enum.VerticalAlignment.Top)
	local inh = TabOf(Parent)
	if inh then S:SetAttribute("UILibTab", inh) end
	return { Frame = S }
end

-- ============================================================
-- CreateCardList(Parent, { Items, Multi, Height, CardHeight,
--                          OnSelect, OnChange })
-- ============================================================
function UILib.CreateCardList(Parent, Options)
	Options = Options or {}
	local multi = Options.Multi ~= false
	local items = Options.Items or {}
	local cardH = Options.CardHeight
	local selSet = {}

	local Wrap = Instance.new("Frame")
	Wrap.Size             = UDim2.new(1, 0, 0, Options.Height or 200)
	Wrap.BorderSizePixel  = 0
	Wrap.ClipsDescendants = true
	Wrap.Parent           = Parent
	Track(Wrap, { BackgroundColor3 = "Bg3", BackgroundTransparency = "RowLift" })
	Corner(Wrap, "CornerRadiusSmall")

	local Scroll = Instance.new("ScrollingFrame", Wrap)
	Scroll.Size                       = UDim2.new(1, 0, 1, 0)
	Scroll.BackgroundTransparency     = 1
	Scroll.BorderSizePixel            = 0
	Scroll.ScrollBarThickness         = 2
	Scroll.ScrollBarImageTransparency = 0.4
	Scroll.CanvasSize                 = UDim2.new(0, 0, 0, 0)
	Scroll.AutomaticCanvasSize        = Enum.AutomaticSize.Y
	Scroll.ClipsDescendants           = true
	Track(Scroll, { ScrollBarImageColor3 = "AccentDim" })
	Pad(Scroll, 5, 5, 5, 5)
	List(Scroll, Enum.FillDirection.Vertical, 4)

	local objs = {}

	local function fire(i, on)
		if Options.OnSelect then
			Options.OnSelect(i, items[i] and items[i].Title or "", on)
		end
		if Options.OnChange then
			local out = {}
			for k in pairs(selSet) do table.insert(out, k) end
			table.sort(out)
			Options.OnChange(out)
		end
	end

	local function paint(o)
		local on = selSet[o.Index] == true
		TweenService:Create(o.Card, TweenFast, {
			BackgroundColor3       = on and Theme.SelectedBg or Theme.Bg2,
			BackgroundTransparency = on and 0 or Theme.RowLift,
		}):Play()
		TweenService:Create(o.Tick, TweenMed, {
			BackgroundTransparency = on and 0 or 1,
			Size = UDim2.new(0, 2, 0, on and 14 or 4),
		}):Play()
		TweenService:Create(o.Title, TweenFast, {
			TextColor3 = on and Theme.Accent or Theme.TextPrimary,
		}):Play()
	end

	local function build(i, item)
		item = item or {}
		local Card = Instance.new("TextButton")
		if cardH then
			Card.Size          = UDim2.new(1, 0, 0, cardH)
			Card.AutomaticSize = Enum.AutomaticSize.None
		else
			Card.Size          = UDim2.new(1, 0, 0, 0)
			Card.AutomaticSize = Enum.AutomaticSize.Y
		end
		Card.BorderSizePixel  = 0
		Card.AutoButtonColor  = false
		Card.Text             = ""
		Card.LayoutOrder      = i
		Card.ClipsDescendants = true
		Card.Parent           = Scroll
		Track(Card, { BackgroundColor3 = "Bg2", BackgroundTransparency = "RowLift" })
		Corner(Card, "CornerRadiusXs")
		Pad(Card, 12, 10, 7, 8)

		-- Selection reads as an accent tick that grows, rather than a
		-- ring and dot. One less circle, and it echoes Section headers.
		local Tick = Instance.new("Frame", Card)
		Tick.AnchorPoint            = Vector2.new(0, 0.5)
		Tick.Position               = UDim2.new(0, -7, 0.5, 0)
		Tick.Size                   = UDim2.new(0, 2, 0, 4)
		Tick.BackgroundTransparency = 1
		Tick.BorderSizePixel        = 0
		Track(Tick, { BackgroundColor3 = "Accent" })
		Pill(Tick)

		if not cardH then List(Card, Enum.FillDirection.Vertical, 2) end

		local Title = Instance.new("TextLabel", Card)
		if cardH then
			Title.Size     = UDim2.new(1, 0, 0, 17)
			Title.Position = UDim2.new(0, 0, 0, 0)
		else
			Title.Size          = UDim2.new(1, 0, 0, 0)
			Title.AutomaticSize = Enum.AutomaticSize.Y
		end
		Title.BackgroundTransparency = 1
		Title.TextSize               = Theme.BodySize
		Title.TextXAlignment         = Enum.TextXAlignment.Left
		Title.TextWrapped            = true
		Title.LayoutOrder            = 0
		Title.Text                   = item.Title or ""
		Track(Title, { TextColor3 = "TextPrimary", Font = "FontMedium" })

		local Desc = Instance.new("TextLabel", Card)
		if cardH then
			Desc.Position      = UDim2.new(0, 0, 0, 19)
			Desc.Size          = UDim2.new(1, 0, 0, cardH - 15 - 19)
			Desc.AutomaticSize = Enum.AutomaticSize.None
		else
			Desc.Size          = UDim2.new(1, 0, 0, 0)
			Desc.AutomaticSize = Enum.AutomaticSize.Y
		end
		Desc.BackgroundTransparency = 1
		Desc.TextSize               = Theme.SmallSize
		Desc.TextXAlignment         = Enum.TextXAlignment.Left
		Desc.TextYAlignment         = Enum.TextYAlignment.Top
		Desc.TextWrapped            = true
		Desc.LayoutOrder            = 1
		Desc.Text                   = item.Description or ""
		Track(Desc, { TextColor3 = "TextMuted", Font = "FontRegular" })

		local o = { Card = Card, Title = Title, Desc = Desc, Tick = Tick, Index = i }
		objs[i] = o

		Card.MouseEnter:Connect(function()
			if not selSet[i] then
				TweenService:Create(Card, TweenFast,
					{ BackgroundColor3 = Theme.Hover, BackgroundTransparency = 0 }):Play()
			end
		end)
		Card.MouseLeave:Connect(function()
			if not selSet[i] then
				TweenService:Create(Card, TweenFast,
					{ BackgroundColor3 = Theme.Bg2, BackgroundTransparency = Theme.RowLift }):Play()
			end
		end)
		Card.MouseButton1Click:Connect(function()
			if not multi then
				for j, other in pairs(objs) do
					if j ~= i and selSet[j] then selSet[j] = nil; paint(other) end
				end
			end
			selSet[i] = (not selSet[i]) or nil
			paint(o)
			fire(i, selSet[i] == true)
		end)

		return o
	end

	local function buildAll(newItems)
		for _, o in pairs(objs) do o.Card:Destroy() end
		objs, selSet = {}, {}
		items = newItems or {}
		for i, item in ipairs(items) do build(i, item) end
	end
	buildAll(items)
	React(Wrap, function()
		for _, o in pairs(objs) do paint(o) end
	end)

	return {
		Frame = Wrap,
		GetSelected = function()
			local out = {}
			for i in pairs(selSet) do table.insert(out, i) end
			table.sort(out)
			return out
		end,
		SetSelected = function(list)
			selSet = {}
			for _, i in ipairs(list) do if objs[i] then selSet[i] = true end end
			for _, o in pairs(objs) do paint(o) end
		end,
		ClearSelected = function()
			selSet = {}
			for _, o in pairs(objs) do paint(o) end
		end,
		SetItems = buildAll,
	}
end

-- ============================================================
-- CreateCode(Parent, { Text, Language, Height })
-- ============================================================
function UILib.CreateCode(Parent, Options)
	Options = Options or {}
	local fixedH  = Options.Height
	local hasHead = Options.Language and Options.Language ~= ""

	local Card = Instance.new("Frame")
	Card.Size            = UDim2.new(1, 0, 0, fixedH and (fixedH + (hasHead and 22 or 0)) or 0)
	Card.AutomaticSize   = fixedH and Enum.AutomaticSize.None or Enum.AutomaticSize.Y
	Card.BorderSizePixel = 0
	Card.ClipsDescendants = true
	Card.Parent          = Parent
	Track(Card, { BackgroundColor3 = "InputBg" })
	Corner(Card, "CornerRadiusXs")
	local CL = Instance.new("UIListLayout", Card)
	CL.SortOrder = Enum.SortOrder.LayoutOrder
	CL.Padding   = UDim.new(0, 0)
	Searchable(Card, (Options.Language or "") .. " " .. (Options.Text or ""), TabOf(Parent))

	if hasHead then
		local H = Instance.new("Frame", Card)
		H.Size                   = UDim2.new(1, 0, 0, 22)
		H.LayoutOrder            = 0
		H.BackgroundTransparency = 1

		local Lang = Instance.new("TextLabel", H)
		Lang.Size                   = UDim2.new(1, -50, 1, 0)
		Lang.Position               = UDim2.new(0, 10, 0, 0)
		Lang.BackgroundTransparency = 1
		Lang.TextSize               = Theme.CaptionSize
		Lang.TextXAlignment         = Enum.TextXAlignment.Left
		Lang.Text                   = Caps(Options.Language)
		Track(Lang, { TextColor3 = "TextMuted", Font = "FontBold" })

		local Copy = Instance.new("TextButton", H)
		Copy.AnchorPoint            = Vector2.new(1, 0.5)
		Copy.Position               = UDim2.new(1, -8, 0.5, 0)
		Copy.Size                   = UDim2.new(0, 38, 0, 16)
		Copy.BackgroundTransparency = 1
		Copy.BorderSizePixel        = 0
		Copy.TextSize               = Theme.CaptionSize
		Copy.Text                   = "copy"
		Copy.AutoButtonColor        = false
		Track(Copy, { TextColor3 = "TextMuted", Font = "FontMedium" })

		Copy.MouseEnter:Connect(function()
			TweenService:Create(Copy, TweenFast, { TextColor3 = Theme.Accent }):Play()
		end)
		Copy.MouseLeave:Connect(function()
			TweenService:Create(Copy, TweenFast, { TextColor3 = Theme.TextMuted }):Play()
		end)
		Copy.MouseButton1Click:Connect(function()
			if type(setclipboard) == "function" then
				pcall(setclipboard, Options.Text or "")
				Copy.Text = "copied"
				task.delay(1, function() if Copy.Parent then Copy.Text = "copy" end end)
			else
				Copy.Text = "n/a"
				task.delay(1, function() if Copy.Parent then Copy.Text = "copy" end end)
			end
		end)
	end

	local Scroll = Instance.new("ScrollingFrame", Card)
	Scroll.LayoutOrder                = 1
	Scroll.BackgroundTransparency      = 1
	Scroll.BorderSizePixel             = 0
	Scroll.ScrollBarThickness          = 2
	Scroll.ScrollBarImageTransparency  = 0.4
	Scroll.CanvasSize                  = UDim2.new(0, 0, 0, 0)
	Scroll.ClipsDescendants            = true
	Track(Scroll, { ScrollBarImageColor3 = "AccentDim" })
	if fixedH then
		Scroll.Size                = UDim2.new(1, 0, 0, fixedH)
		Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	else
		Scroll.Size                = UDim2.new(1, 0, 0, 0)
		Scroll.AutomaticSize       = Enum.AutomaticSize.Y
		Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	end
	Pad(Scroll, 10, 10, 8, 8)

	local Code = Instance.new("TextLabel", Scroll)
	Code.Size                   = UDim2.new(1, -20, 0, 0)
	Code.AutomaticSize          = Enum.AutomaticSize.Y
	Code.BackgroundTransparency = 1
	Code.TextSize               = Theme.SmallSize
	Code.TextXAlignment         = Enum.TextXAlignment.Left
	Code.TextYAlignment         = Enum.TextYAlignment.Top
	Code.TextWrapped            = true
	Code.Text                   = Options.Text or ""
	Track(Code, { TextColor3 = "TextPrimary", Font = "FontMono" })

	return { Frame = Card, SetText = function(t) Code.Text = t end }
end

-- ============================================================
-- CreateStatusLog(Parent, { Height, MaxLines })
-- ============================================================
function UILib.CreateStatusLog(Parent, Options)
	Options = Options or {}
	local h = Options.Height or 160

	local Wrap = Instance.new("Frame")
	Wrap.Size                   = UDim2.new(1, 0, 0, h + 26)
	Wrap.BackgroundTransparency = 1
	Wrap.BorderSizePixel        = 0
	Wrap.Parent                 = Parent

	local Scroll = Instance.new("ScrollingFrame", Wrap)
	Scroll.Size                       = UDim2.new(1, 0, 1, -26)
	Scroll.BorderSizePixel            = 0
	Scroll.ScrollBarThickness         = 2
	Scroll.ScrollBarImageTransparency = 0.4
	Scroll.AutomaticCanvasSize        = Enum.AutomaticSize.Y
	Scroll.CanvasSize                 = UDim2.new(0, 0, 0, 0)
	Scroll.ClipsDescendants           = true
	Track(Scroll, { BackgroundColor3 = "InputBg", ScrollBarImageColor3 = "AccentDim" })
	Corner(Scroll, "CornerRadiusXs")
	Pad(Scroll, 8, 6, 6, 6)
	List(Scroll, Enum.FillDirection.Vertical, 1)

	local Clear = Instance.new("TextButton", Wrap)
	Clear.AnchorPoint            = Vector2.new(1, 1)
	Clear.Position               = UDim2.new(1, -2, 1, 0)
	Clear.Size                   = UDim2.new(0, 60, 0, 18)
	Clear.BackgroundTransparency = 1
	Clear.BorderSizePixel        = 0
	Clear.TextSize               = Theme.CaptionSize
	Clear.Text                   = "clear log"
	Clear.AutoButtonColor        = false
	Track(Clear, { TextColor3 = "TextMuted", Font = "FontMedium" })
	Clear.MouseEnter:Connect(function()
		TweenService:Create(Clear, TweenFast, { TextColor3 = Theme.Accent }):Play()
	end)
	Clear.MouseLeave:Connect(function()
		TweenService:Create(Clear, TweenFast, { TextColor3 = Theme.TextMuted }):Play()
	end)

	local entries  = {}
	local maxLines = Options.MaxLines

	local function Log(msg, color)
		local stamp = (os and os.date) and os.date("%H:%M:%S") or "--:--:--"
		local L = Instance.new("TextLabel", Scroll)
		L.Size                   = UDim2.new(1, -8, 0, 0)
		L.AutomaticSize          = Enum.AutomaticSize.Y
		L.BackgroundTransparency = 1
		L.RichText               = true
		L.TextSize               = Theme.CaptionSize
		L.TextXAlignment         = Enum.TextXAlignment.Left
		L.TextWrapped            = true
		L.LayoutOrder            = #entries + 1
		Track(L, { Font = "FontMono" })
		L.TextColor3 = color or Theme.TextPrimary
		local m = Theme.TextMuted
		L.Text = string.format("<font color='#%02X%02X%02X'>%s</font>  %s",
			math.floor(m.R * 255 + 0.5), math.floor(m.G * 255 + 0.5),
			math.floor(m.B * 255 + 0.5), stamp, msg)

		table.insert(entries, L)
		if maxLines then
			while #entries > maxLines do
				local old = table.remove(entries, 1)
				if old then old:Destroy() end
			end
		end
		task.defer(function()
			if Scroll.Parent then Scroll.CanvasPosition = Vector2.new(0, math.huge) end
		end)
	end

	local function ClearAll()
		for _, e in ipairs(entries) do e:Destroy() end
		entries = {}
	end
	Clear.MouseButton1Click:Connect(ClearAll)

	return { Frame = Wrap, Log = Log, Clear = ClearAll }
end

-- ============================================================
-- CreateInputList(Parent, { Label, Count, Defaults, Placeholder,
--                           OnChanged, Height, Flag })
-- ============================================================
function UILib.CreateInputList(Parent, Options)
	Options = Options or {}
	local count = Options.Count  or 8
	local h     = Options.Height or 110
	local defs  = Options.Defaults or {}

	local Wrap = Instance.new("Frame")
	Wrap.Size                   = UDim2.new(1, 0, 0, h + 20)
	Wrap.BackgroundTransparency = 1
	Wrap.BorderSizePixel        = 0
	Wrap.Parent                 = Parent
	List(Wrap, Enum.FillDirection.Vertical, 3)
	Searchable(Wrap, Options.Label, TabOf(Parent))

	local L = Instance.new("TextLabel", Wrap)
	L.Size                   = UDim2.new(1, 0, 0, 15)
	L.LayoutOrder            = 0
	L.BackgroundTransparency = 1
	L.TextSize               = Theme.CaptionSize
	L.TextXAlignment         = Enum.TextXAlignment.Left
	Pad(L, 2, 0, 0, 0)
	Track(L, { TextColor3 = "TextMuted", Font = "FontBold" })
	React(Wrap, function() L.Text = Caps(Options.Label or "items") end)

	local Scroll = Instance.new("ScrollingFrame", Wrap)
	Scroll.Size                       = UDim2.new(1, 0, 0, h)
	Scroll.LayoutOrder                = 1
	Scroll.BorderSizePixel            = 0
	Scroll.ScrollBarThickness         = 2
	Scroll.ScrollBarImageTransparency = 0.4
	Scroll.AutomaticCanvasSize        = Enum.AutomaticSize.Y
	Scroll.CanvasSize                 = UDim2.new(0, 0, 0, 0)
	Scroll.ClipsDescendants           = true
	Track(Scroll, { BackgroundColor3 = "InputBg", ScrollBarImageColor3 = "AccentDim" })
	Corner(Scroll, "CornerRadiusXs")
	Pad(Scroll, 5, 5, 5, 5)
	List(Scroll, Enum.FillDirection.Vertical, 3)

	local values, boxes = {}, {}

	for i = 1, count do
		values[i] = defs[i] or ""

		local Slot = Instance.new("Frame", Scroll)
		Slot.Size                   = UDim2.new(1, 0, 0, 20)
		Slot.BackgroundTransparency = 1
		Slot.BorderSizePixel        = 0
		Slot.LayoutOrder            = i

		local Num = Instance.new("TextLabel", Slot)
		Num.Size                   = UDim2.new(0, 16, 1, 0)
		Num.BackgroundTransparency = 1
		Num.TextSize               = Theme.CaptionSize
		Num.TextXAlignment         = Enum.TextXAlignment.Right
		Num.Text                   = tostring(i)
		Track(Num, { TextColor3 = "TextMuted", Font = "FontMono" })

		local ph = (type(Options.Placeholder) == "function")
			and Options.Placeholder(i) or (Options.Placeholder or "")

		local TB = Instance.new("TextBox", Slot)
		TB.Position               = UDim2.new(0, 22, 0, 0)
		TB.Size                   = UDim2.new(1, -24, 1, 0)
		TB.BackgroundTransparency = 1
		TB.BorderSizePixel        = 0
		TB.TextSize               = Theme.SmallSize
		TB.PlaceholderText        = ph
		TB.TextXAlignment         = Enum.TextXAlignment.Left
		TB.ClearTextOnFocus       = false
		TB.Text                   = values[i]
		Track(TB, { TextColor3 = "TextPrimary",
			PlaceholderColor3 = "TextMuted", Font = "FontMono" })

		-- An underline that lights on focus instead of a full box, so a
		-- stack of eight fields doesn't become eight rectangles.
		local Rule = Instance.new("Frame", Slot)
		Rule.AnchorPoint            = Vector2.new(0, 1)
		Rule.Position               = UDim2.new(0, 22, 1, 0)
		Rule.Size                   = UDim2.new(1, -24, 0, 1)
		Rule.BackgroundTransparency = 0.85
		Rule.BorderSizePixel        = 0
		Track(Rule, { BackgroundColor3 = "TextMuted" })

		TB.Focused:Connect(function()
			TweenService:Create(Rule, TweenFast,
				{ BackgroundColor3 = Theme.Accent, BackgroundTransparency = 0 }):Play()
		end)
		TB.FocusLost:Connect(function()
			TweenService:Create(Rule, TweenFast,
				{ BackgroundColor3 = Theme.TextMuted, BackgroundTransparency = 0.85 }):Play()
			values[i] = TB.Text
			if Options.OnChanged then Options.OnChanged(i, TB.Text) end
		end)
		TB:GetPropertyChangedSignal("Text"):Connect(function() values[i] = TB.Text end)

		boxes[i] = TB
	end

	if Options.Flag then
		Flags[Options.Flag] = {
			Kind = "table",
			Get  = function() return values end,
			Set  = function(t)
				if type(t) ~= "table" then return end
				for i = 1, count do
					if t[i] ~= nil then
						values[i] = tostring(t[i])
						if boxes[i] then boxes[i].Text = values[i] end
						if Options.OnChanged then Options.OnChanged(i, values[i]) end
					end
				end
			end,
		}
	end

	return {
		Frame = Wrap,
		GetValues = function() return values end,
		SetValue  = function(i, t)
			values[i] = t
			if boxes[i] then boxes[i].Text = t end
		end,
	}
end

-- ============================================================
-- Media
-- ============================================================
function UILib.CreateImage(Parent, Options)
	Options = Options or {}

	local Card = Instance.new("Frame")
	Card.Size             = UDim2.new(1, 0, 0, Options.Height or 140)
	Card.BorderSizePixel  = 0
	Card.ClipsDescendants = true
	Card.Parent           = Parent
	Track(Card, { BackgroundColor3 = "Bg3" })
	Corner(Card, "CornerRadiusSmall")

	local Img = Instance.new("ImageLabel", Card)
	Img.Size                   = UDim2.new(1, 0, 1, 0)
	Img.BackgroundTransparency = 1
	Img.Image                  = Options.Image or ""
	Img.ScaleType              = Options.ScaleType or Enum.ScaleType.Fit

	if Options.Caption then
		local Strip = Instance.new("Frame", Card)
		Strip.AnchorPoint            = Vector2.new(0, 1)
		Strip.Position               = UDim2.new(0, 0, 1, 0)
		Strip.Size                   = UDim2.new(1, 0, 0, 22)
		Strip.BackgroundTransparency = 0.25
		Strip.BorderSizePixel        = 0
		Track(Strip, { BackgroundColor3 = "Bg0" })

		local C = Instance.new("TextLabel", Strip)
		C.Size                   = UDim2.new(1, -16, 1, 0)
		C.Position               = UDim2.new(0, 8, 0, 0)
		C.BackgroundTransparency = 1
		C.TextSize               = Theme.CaptionSize
		C.TextXAlignment         = Enum.TextXAlignment.Left
		C.Text                   = Options.Caption
		Track(C, { TextColor3 = "TextPrimary", Font = "FontRegular" })
	end

	return { Frame = Card, Image = Img, SetImage = function(id) Img.Image = id end }
end

function UILib.CreateVideo(Parent, Options)
	Options = Options or {}
	local h = Options.Height or 160

	local Card = Instance.new("Frame")
	Card.Size             = UDim2.new(1, 0, 0, h + 26)
	Card.BorderSizePixel  = 0
	Card.ClipsDescendants = true
	Card.Parent           = Parent
	Track(Card, { BackgroundColor3 = "Bg3" })
	Corner(Card, "CornerRadiusSmall")

	local has = Options.Video and Options.Video ~= ""
	local Vid
	if has then
		Vid = Instance.new("VideoFrame", Card)
		Vid.Size             = UDim2.new(1, 0, 0, h)
		Vid.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		Vid.BorderSizePixel  = 0
		Vid.Video            = Options.Video
		Vid.Looped           = Options.Looped == true
		Vid.Volume           = Options.Volume or 1
	else
		local E = Instance.new("TextLabel", Card)
		E.Size                   = UDim2.new(1, 0, 0, h)
		E.BackgroundTransparency = 1
		E.TextSize               = Theme.SmallSize
		E.Text                   = "no video asset set"
		Track(E, { TextColor3 = "TextMuted", Font = "FontRegular" })
	end

	local Play = Instance.new("TextButton", Card)
	Play.Position               = UDim2.new(0, 9, 0, h + 4)
	Play.Size                   = UDim2.new(0, 46, 0, 18)
	Play.BackgroundTransparency = 1
	Play.BorderSizePixel        = 0
	Play.TextSize               = Theme.CaptionSize
	Play.TextXAlignment         = Enum.TextXAlignment.Left
	Play.Text                   = "play"
	Play.AutoButtonColor        = false
	Track(Play, { Font = "FontMedium" })
	Play.TextColor3 = has and Theme.Accent or Theme.TextMuted

	local function refresh() Play.Text = (Vid and Vid.IsPlaying) and "pause" or "play" end
	local function DoPlay()  if Vid then Vid:Play();  refresh() end end
	local function DoPause() if Vid then Vid:Pause(); refresh() end end

	Play.MouseButton1Click:Connect(function()
		if not Vid then return end
		if Vid.IsPlaying then DoPause() else DoPlay() end
	end)
	if has and Options.Autoplay then DoPlay() else refresh() end

	return { Frame = Card, Video = Vid, Play = DoPlay, Pause = DoPause }
end

function UILib.CreateViewport(Parent, Options)
	Options = Options or {}

	local Card = Instance.new("Frame")
	Card.Size             = UDim2.new(1, 0, 0, Options.Height or 160)
	Card.BorderSizePixel  = 0
	Card.ClipsDescendants = true
	Card.Parent           = Parent
	if Options.BackgroundColor3 then
		Card.BackgroundColor3 = Options.BackgroundColor3
	else
		Track(Card, { BackgroundColor3 = "Bg3" })
	end
	Corner(Card, "CornerRadiusSmall")

	local VP = Instance.new("ViewportFrame", Card)
	VP.Size                   = UDim2.new(1, 0, 1, 0)
	VP.BackgroundTransparency = 1
	VP.Ambient                = Options.Ambient or Color3.fromRGB(150, 150, 150)
	VP.LightColor             = Options.LightColor or Color3.fromRGB(255, 255, 255)

	local Cam = Instance.new("Camera", VP)
	VP.CurrentCamera = Cam

	local clone, rotConn
	Card.Destroying:Connect(function()
		if rotConn then rotConn:Disconnect(); rotConn = nil end
	end)

	local function SetModel(model)
		if clone then clone:Destroy(); clone = nil end
		if rotConn then rotConn:Disconnect(); rotConn = nil end
		if not model then return end

		clone = model:Clone()
		clone.Parent = VP

		task.defer(function()
			local ok, cf, size = pcall(function()
				local a, b = clone:GetBoundingBox()
				return a, b
			end)
			if not ok or not cf then
				Cam.CFrame = CFrame.new(Vector3.new(0, 0, 10), Vector3.new(0, 0, 0))
				return
			end
			local dist = math.max(size.Magnitude, 4)
			Cam.CFrame = CFrame.new(cf.Position + Vector3.new(0, size.Y * 0.2, dist), cf.Position)

			if Options.AutoRotate then
				local angle = 0
				rotConn = RunService.RenderStepped:Connect(function(dt)
					if not clone or not clone.Parent then return end
					angle = angle + dt * (Options.Speed or 0.5)
					Cam.CFrame = CFrame.new(cf.Position + Vector3.new(
						math.sin(angle) * dist, size.Y * 0.2, math.cos(angle) * dist), cf.Position)
				end)
			end
		end)
	end

	if Options.Model then SetModel(Options.Model) end
	return { Frame = Card, Viewport = VP, Camera = Cam, SetModel = SetModel }
end

function UILib.MakeDraggable(Handle, Target, Options)
	Options = Options or {}
	local clamp = Options.ClampToScreen == true
	local dragging, dragStart, startPos = false, nil, nil

	Handle.InputBegan:Connect(function(inp)
		if inp.UserInputType ~= Enum.UserInputType.MouseButton1
		and inp.UserInputType ~= Enum.UserInputType.Touch then return end
		dragging, dragStart, startPos = true, inp.Position, Target.Position
		inp.Changed:Connect(function()
			if inp.UserInputState == Enum.UserInputState.End then dragging = false end
		end)
	end)
	Scoped(Target, UserInputService.InputChanged, function(inp)
		if not dragging then return end
		if inp.UserInputType ~= Enum.UserInputType.MouseMovement
		and inp.UserInputType ~= Enum.UserInputType.Touch then return end
		local d = inp.Position - dragStart
		local pos = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X,
			startPos.Y.Scale, startPos.Y.Offset + d.Y)
		if clamp and Target.Parent then
			local ok, screen = pcall(function() return Target.Parent.AbsoluteSize end)
			if ok and screen and screen.X > 0 and screen.Y > 0 then
				local tw, th = Target.AbsoluteSize.X, Target.AbsoluteSize.Y
				local ax = math.clamp(pos.X.Scale * screen.X + pos.X.Offset, 0, math.max(0, screen.X - tw))
				local ay = math.clamp(pos.Y.Scale * screen.Y + pos.Y.Offset, 0, math.max(0, screen.Y - th))
				pos = UDim2.new(pos.X.Scale, ax - pos.X.Scale * screen.X,
					pos.Y.Scale, ay - pos.Y.Scale * screen.Y)
			end
		end
		Target.Position = pos
	end)
end

-- ============================================================
-- CONFIG PROFILES
-- Named slots with an autoload pointer. Degrades to a no-op
-- returning false plus a reason when the executor has no file API.
-- ============================================================
local CFG_DIR = "UILibConfigs"
local _useDir = nil

local function filesOK()
	return type(writefile) == "function" and type(readfile) == "function"
end

local function ensureDir()
	if type(makefolder) == "function" and type(isfolder) == "function" then
		if not isfolder(CFG_DIR) then pcall(makefolder, CFG_DIR) end
		return true
	end
	return false
end

local function profilePath(name)
	if _useDir == nil then _useDir = ensureDir() end
	name = tostring(name or "default"):gsub("[^%w_%-]", "_")
	return _useDir and (CFG_DIR .. "/" .. name .. ".json") or ("UILib_" .. name .. ".json")
end

local function indexPath()
	if _useDir == nil then _useDir = ensureDir() end
	return _useDir and (CFG_DIR .. "/_index.json") or "UILib_index.json"
end

local function readIndex()
	if not filesOK() then return {} end
	local file = indexPath()
	local exists = (type(isfile) ~= "function") or isfile(file)
	if not exists then return {} end
	local ok, body = pcall(readfile, file)
	if not ok or not body then return {} end
	local okDec, data = pcall(HttpService.JSONDecode, HttpService, body)
	return (okDec and type(data) == "table") and data or {}
end

local function writeIndex(idx)
	if not filesOK() then return end
	local ok, body = pcall(HttpService.JSONEncode, HttpService, idx)
	if ok then pcall(writefile, indexPath(), body) end
end

local function snapshot()
	local out = {}
	for flag, entry in pairs(Flags) do
		local ok, v = pcall(entry.Get)
		if ok and v ~= nil then
			if typeof(v) == "Color3" then
				v = { __c3 = true,
					R = math.floor(v.R * 255 + 0.5),
					G = math.floor(v.G * 255 + 0.5),
					B = math.floor(v.B * 255 + 0.5) }
			end
			out[flag] = v
		end
	end
	return out
end

local function restore(data)
	for flag, v in pairs(data) do
		local entry = Flags[flag]
		if entry then
			if type(v) == "table" and v.__c3 then
				v = Color3.fromRGB(v.R or 255, v.G or 255, v.B or 255)
			end
			pcall(entry.Set, v)
		end
	end
end

function UILib.SaveConfig(name)
	if not filesOK() then return false, "file API not supported by this executor" end
	local ok, body = pcall(HttpService.JSONEncode, HttpService,
		{ theme = CurrentTheme, flags = snapshot() })
	if not ok then return false, body end
	local okW, err = pcall(writefile, profilePath(name), body)
	if not okW then return false, err end

	local idx = readIndex()
	idx.profiles = idx.profiles or {}
	local key = tostring(name or "default")
	if not table.find(idx.profiles, key) then table.insert(idx.profiles, key) end
	writeIndex(idx)
	return true
end

function UILib.LoadConfig(name)
	if not filesOK() then return false, "file API not supported by this executor" end
	local file = profilePath(name)
	if type(isfile) == "function" and not isfile(file) then
		return false, "no such profile: " .. tostring(name)
	end
	local ok, body = pcall(readfile, file)
	if not ok then return false, body end
	local okDec, data = pcall(HttpService.JSONDecode, HttpService, body)
	if not okDec or type(data) ~= "table" then return false, "invalid profile file" end

	if data.flags then
		if data.theme and UILib.Themes[data.theme] then UILib.SetTheme(data.theme) end
		restore(data.flags)
	else
		-- Older flat files are still accepted.
		restore(data)
	end
	return true
end

function UILib.DeleteConfig(name)
	if type(delfile) ~= "function" then return false, "delfile not supported" end
	local ok = pcall(delfile, profilePath(name))
	local idx = readIndex()
	if idx.profiles then
		for i, v in ipairs(idx.profiles) do
			if v == tostring(name) then table.remove(idx.profiles, i) break end
		end
		if idx.autoload == tostring(name) then idx.autoload = nil end
		writeIndex(idx)
	end
	return ok
end

function UILib.ListConfigs() return readIndex().profiles or {} end
function UILib.GetAutoload() return readIndex().autoload end

function UILib.SetAutoload(name)
	local idx = readIndex()
	idx.autoload = name and tostring(name) or nil
	writeIndex(idx)
	return true
end

-- Call after building the UI: restoring values needs the flags to
-- exist first.
function UILib.RunAutoload()
	local name = UILib.GetAutoload()
	if not name then return false end
	return UILib.LoadConfig(name)
end

function UILib.Init(Options)
	Options = Options or {}
	if Options.Theme  then UILib.SetTheme(Options.Theme, false) end
	if Options.Parent then DefaultParent = Options.Parent end
	return UILib
end

function UILib.Unload()
	for _, g in ipairs(_allGuis) do
		if g and g.Parent then g:Destroy() end
	end
	_allGuis = {}
	if _notifSg then _notifSg:Destroy(); _notifSg = nil end
	if _tipSg   then _tipSg:Destroy();   _tipSg   = nil end
	_notifs = {}
	_tipFrame, _tipLbl = nil, nil
	if _overlayWatch then _overlayWatch:Disconnect(); _overlayWatch = nil end
	_openOverlay = nil
	_blurRefs = 0
	if _blur then _blur:Destroy(); _blur = nil end
	for k in pairs(Flags) do Flags[k] = nil end
	table.clear(Bound)
	table.clear(Reactions)
	table.clear(Searchables)
end

UILib.init        = UILib.Init
UILib.unload      = UILib.Unload
UILib.settheme    = UILib.SetTheme
UILib.saveconfig  = UILib.SaveConfig
UILib.loadconfig  = UILib.LoadConfig
UILib.notify      = UILib.ShowNotification
UILib.panel       = UILib.CreatePanel
UILib.section     = UILib.CreateSection
UILib.button      = UILib.CreateButton
UILib.toggle      = UILib.CreateToggle
UILib.slider      = UILib.CreateSlider
UILib.input       = UILib.CreateTextInput
UILib.keybind     = UILib.CreateKeybind
UILib.dropdown    = UILib.CreateDropdown
UILib.group       = UILib.CreateGroup
UILib.colorpicker = UILib.CreateColorPicker
UILib.cardlist    = UILib.CreateCardList
UILib.code        = UILib.CreateCode
UILib.statuslog   = UILib.CreateStatusLog
UILib.inputlist   = UILib.CreateInputList
UILib.label       = UILib.CreateLabel
UILib.paragraph   = UILib.CreateParagraph
UILib.keyvalue    = UILib.CreateKeyValue
UILib.progressbar = UILib.CreateProgressBar
UILib.divider     = UILib.CreateDivider
UILib.space       = UILib.CreateSpace
UILib.hstack      = UILib.CreateHStack
UILib.vstack      = UILib.CreateVStack
UILib.image       = UILib.CreateImage
UILib.video       = UILib.CreateVideo
UILib.viewport    = UILib.CreateViewport
UILib.draggable   = UILib.MakeDraggable
