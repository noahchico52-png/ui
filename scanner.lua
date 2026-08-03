-- CleanUILibrary.luau
-- Library only. No showcase window. No demo tabs. No settings UI.

local Library = {}

function Library:CreateWindow(opts)
	opts = opts or {}

	local Window = {}
	Window.Title = opts.Title or "Window"
	Window.Tabs = {}

	function Window:CreateTab(name)
		local Tab = {}
		Tab.Name = name or "Tab"
		Tab.Sections = {}

		function Tab:CreateSection(title)
			local Section = {}
			Section.Title = title or "Section"
			Section.Elements = {}

			local function add(t)
				table.insert(Section.Elements, t)
				return t
			end

			function Section:CreateButton(opts)
				return add({
					Type = "Button",
					Text = opts.Text,
					Callback = opts.Callback
				})
			end

			function Section:CreateToggle(opts)
				return add({
					Type = "Toggle",
					Text = opts.Text,
					Default = opts.Default or false,
					Callback = opts.Callback
				})
			end

			function Section:CreateSlider(opts)
				return add({
					Type = "Slider",
					Text = opts.Text,
					Min = opts.Min or 0,
					Max = opts.Max or 100,
					Default = opts.Default or 0,
					Callback = opts.Callback
				})
			end

			function Section:CreateDropdown(opts)
				return add({
					Type = "Dropdown",
					Text = opts.Text,
					Values = opts.Values or {},
					Callback = opts.Callback
				})
			end

			function Section:CreateTextbox(opts)
				return add({
					Type = "Textbox",
					Text = opts.Text,
					Placeholder = opts.Placeholder,
					Callback = opts.Callback
				})
			end

			function Section:CreateKeybind(opts)
				return add({
					Type = "Keybind",
					Text = opts.Text,
					Default = opts.Default,
					Callback = opts.Callback
				})
			end

			function Section:CreateLabel(text)
				return add({
					Type = "Label",
					Text = text
				})
			end

			table.insert(Tab.Sections, Section)
			return Section
		end

		table.insert(Window.Tabs, Tab)
		return Tab
	end

	function Window:Notify(title, text, duration)
		return {
			Title = title,
			Text = text,
			Duration = duration or 5
		}
	end

	return Window
end

return Library
