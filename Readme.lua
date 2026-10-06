local userInputService = game:GetService("UserInputService")
local textService = game:GetService("TextService")
local tweenService = game:GetService("TweenService")
local workspaceService = game:GetService("Workspace")
local starterGui = game:GetService("StarterGui")

local FONT = Enum.Font.GothamMedium
local FONT_BOLD = Enum.Font.GothamBold
local SIDEBAR_WIDTH = 90
local HEADER_HEIGHT = 34
local MAX_LIST_ROWS = 6

local THEME = {
	background = Color3.fromRGB(13, 13, 15),
	panel = Color3.fromRGB(19, 19, 22),
	control = Color3.fromRGB(26, 26, 30),
	line = Color3.fromRGB(36, 36, 41),
	accent = Color3.fromRGB(200, 48, 68),
	accentDark = Color3.fromRGB(96, 30, 40),
	text = Color3.fromRGB(150, 150, 156),
	textBright = Color3.fromRGB(225, 225, 228),
}

local Library = { THEME = THEME }

local function make(class, props)
	local instance = Instance.new(class)
	local parent = props.Parent
	props.Parent = nil

	for key, value in next, props do
		instance[key] = value
	end

	instance.Parent = parent

	return instance
end

local function textLabel(props)
	props.BackgroundTransparency = 1
	props.Font = props.Font or FONT
	props.TextSize = props.TextSize or 11
	props.TextColor3 = props.TextColor3 or THEME.text
	props.TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Left

	return make("TextLabel", props)
end

local function addStroke(parent, color)
	return make("UIStroke", {
		Color = color or THEME.line,
		Thickness = 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = parent,
	})
end

local function round(parent, radius)
	make("UICorner", { CornerRadius = UDim.new(0, radius), Parent = parent })
end

local function isPress(input)
	return input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch
end

Library.make = make
Library.textLabel = textLabel
Library.addStroke = addStroke
Library.round = round
Library.isPress = isPress

local showToast = nil

function Library.notify(content)
	warn("[magma] " .. content)

	if showToast and showToast(content) then
		return
	end

	pcall(function()
		starterGui:SetCore("SendNotification", { Title = "magma", Text = content, Duration = 5 })
	end)
end

function Library.createUi(subtitle)
	local logoText = '<font color="rgb(225,225,228)">mag</font><font color="rgb(200,48,68)">ma</font>'

	if subtitle then
		logoText = logoText .. ' <font color="rgb(110,110,118)">| ' .. subtitle .. '</font>'
	end

	local guiParent = gethui and gethui() or game:GetService("CoreGui")
	local camera = workspaceService.CurrentCamera
	local viewport = camera and camera.ViewportSize or Vector2.new(800, 400)
	local windowWidth = math.min(500, viewport.X - 40)
	local windowHeight = math.min(280, viewport.Y - 40)

	local connections = {}
	local binds = {}
	local activeDrag = nil
	local listeningBind = nil
	local openPopup = nil
	local tooltipToken = 0
	local menuKey = Enum.KeyCode.RightShift
	local menuLocked = false

	local gui = make("ScreenGui", {
		Name = "MagmaGui",
		ResetOnSpawn = false,
		DisplayOrder = 1000000,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = guiParent,
	})

	local dim = make("Frame", {
		Name = "Dim",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Visible = false,
		ZIndex = 0,
		Parent = gui,
	})

	local window = make("Frame", {
		Name = "Window",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(windowWidth, windowHeight),
		BackgroundColor3 = THEME.background,
		BorderSizePixel = 0,
		Active = true,
		Parent = gui,
	})

	round(window, 14)
	addStroke(window)

	local header = make("Frame", {
		Size = UDim2.new(1, 0, 0, HEADER_HEIGHT),
		BackgroundTransparency = 1,
		Active = true,
		Parent = window,
	})

	textLabel({
		Position = UDim2.fromOffset(14, 0),
		Size = UDim2.new(1, -28, 1, 0),
		Text = logoText,
		RichText = true,
		Font = FONT_BOLD,
		TextSize = 16,
		Parent = header,
	})

	make("Frame", {
		Position = UDim2.new(0, 0, 1, -1),
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = THEME.accentDark,
		BorderSizePixel = 0,
		Parent = header,
	})

	make("Frame", {
		Position = UDim2.fromOffset(SIDEBAR_WIDTH, HEADER_HEIGHT),
		Size = UDim2.new(0, 1, 1, -HEADER_HEIGHT),
		BackgroundColor3 = THEME.line,
		BorderSizePixel = 0,
		Parent = window,
	})

	local sidebar = make("Frame", {
		Position = UDim2.fromOffset(0, HEADER_HEIGHT + 8),
		Size = UDim2.new(0, SIDEBAR_WIDTH, 1, -(HEADER_HEIGHT + 8)),
		BackgroundTransparency = 1,
		Parent = window,
	})

	make("UIListLayout", {
		Padding = UDim.new(0, 3),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = sidebar,
	})

	make("UIPadding", { PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6), Parent = sidebar })

	local popupLayer = make("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ZIndex = 50,
		Parent = window,
	})

	local catcher = make("TextButton", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		Visible = false,
		ZIndex = 51,
		Parent = popupLayer,
	})

	local function closePopup()
		if openPopup then
			openPopup:Destroy()
			openPopup = nil
		end

		catcher.Visible = false
	end

	table.insert(connections, catcher.Activated:Connect(closePopup))

	local function beginPopup(anchor, width, height)
		closePopup()
		catcher.Visible = true

		local base = popupLayer.AbsolutePosition
		local position = anchor.AbsolutePosition - base
		local y = position.Y + anchor.AbsoluteSize.Y + 2

		if y + height > windowHeight - 4 then
			y = math.max(position.Y - height - 2, 4)
		end

		local popup = make("Frame", {
			Position = UDim2.fromOffset(math.min(position.X, windowWidth - width - 4), y),
			Size = UDim2.fromOffset(width, height),
			BackgroundColor3 = THEME.panel,
			BorderSizePixel = 0,
			ZIndex = 52,
			Parent = popupLayer,
		})

		addStroke(popup)
		round(popup, 8)
		openPopup = popup

		return popup
	end

	local function showTooltip(anchor, text)
		tooltipToken += 1

		local token = tooltipToken
		local base = popupLayer.AbsolutePosition
		local position = anchor.AbsolutePosition - base
		local size = textService:GetTextSize(text, 10, FONT, Vector2.new(180, 200))

		local tip = make("Frame", {
			Position = UDim2.fromOffset(math.min(position.X + 10, windowWidth - size.X - 20), position.Y + 14),
			Size = UDim2.fromOffset(size.X + 10, size.Y + 8),
			BackgroundColor3 = THEME.control,
			BorderSizePixel = 0,
			ZIndex = 60,
			Parent = popupLayer,
		})

		addStroke(tip)
		round(tip, 6)

		textLabel({
			Position = UDim2.fromOffset(5, 4),
			Size = UDim2.new(1, -10, 1, -8),
			Text = text,
			TextSize = 10,
			TextWrapped = true,
			TextColor3 = THEME.textBright,
			ZIndex = 61,
			Parent = tip,
		})

		task.delay(2.5, function()
			if tooltipToken == token then
				tip:Destroy()
			end
		end)
	end

	table.insert(connections, userInputService.InputChanged:Connect(function(input)
		if activeDrag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			activeDrag(input)
		end
	end))

	table.insert(connections, userInputService.InputEnded:Connect(function(input)
		if isPress(input) then
			activeDrag = nil
		end
	end))

	table.insert(connections, header.InputBegan:Connect(function(input)
		if not isPress(input) then
			return
		end

		local start = input.Position
		local origin = window.Position

		activeDrag = function(moved)
			local delta = moved.Position - start
			window.Position = UDim2.new(origin.X.Scale, origin.X.Offset + delta.X, origin.Y.Scale, origin.Y.Offset + delta.Y)
		end
	end))

	local function makeGear(parent, position, callback)
		local button = make("TextButton", {
			Size = UDim2.fromOffset(14, 14),
			Position = position,
			BackgroundTransparency = 1,
			Text = "",
			ZIndex = 3,
			Parent = parent,
		})

		local ring = make("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(8, 8),
			BackgroundTransparency = 1,
			Parent = button,
		})

		make("UICorner", { CornerRadius = UDim.new(1, 0), Parent = ring })

		make("UIStroke", {
			Color = THEME.text,
			Thickness = 2,
			Parent = ring,
		})

		if callback then
			table.insert(connections, button.Activated:Connect(callback))
		end

		return button
	end

	local function makeHamburger(parent)
		local holder = make("Frame", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -6, 0.5, 0),
			Size = UDim2.fromOffset(10, 9),
			BackgroundTransparency = 1,
			Parent = parent,
		})

		for index = 0, 2 do
			make("Frame", {
				Position = UDim2.fromOffset(0, index * 4),
				Size = UDim2.new(1, 0, 0, 1),
				BackgroundColor3 = THEME.text,
				BorderSizePixel = 0,
				Parent = holder,
			})
		end
	end

	local function addTooltipMark(row, label, text, tip)
		if not tip then
			return
		end

		local width = textService:GetTextSize(text, 11, FONT, Vector2.new(1000, 100)).X

		local mark = make("TextButton", {
			Position = UDim2.new(0, label.Position.X.Offset + width + 5, 0, 0),
			Size = UDim2.fromOffset(12, 14),
			BackgroundTransparency = 1,
			Text = "?",
			TextColor3 = THEME.text,
			TextSize = 10,
			Font = FONT,
			ZIndex = 3,
			Parent = row,
		})

		table.insert(connections, mark.Activated:Connect(function()
			showTooltip(mark, tip)
		end))
	end

	local function openColorPicker(anchor, current, onChange)
		local popup = beginPopup(anchor, 142, 118)
		local hue, saturation, value = current:ToHSV()

		local square = make("Frame", {
			Position = UDim2.fromOffset(6, 6),
			Size = UDim2.fromOffset(130, 84),
			BackgroundColor3 = Color3.fromHSV(hue, 1, 1),
			BorderSizePixel = 0,
			ZIndex = 53,
			Parent = popup,
		})

		local white = make("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0,
			ZIndex = 54,
			Parent = square,
		})

		make("UIGradient", {
			Transparency = NumberSequence.new(0, 1),
			Parent = white,
		})

		local black = make("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = Color3.new(0, 0, 0),
			BorderSizePixel = 0,
			ZIndex = 55,
			Parent = square,
		})

		make("UIGradient", {
			Rotation = 90,
			Transparency = NumberSequence.new(1, 0),
			Parent = black,
		})

		local marker = make("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.fromOffset(6, 6),
			BackgroundTransparency = 1,
			ZIndex = 57,
			Parent = square,
		})

		make("UIStroke", { Color = Color3.new(1, 1, 1), Thickness = 1, Parent = marker })

		local bar = make("Frame", {
			Position = UDim2.fromOffset(6, 98),
			Size = UDim2.fromOffset(130, 10),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0,
			ZIndex = 53,
			Parent = popup,
		})

		local keypoints = {}

		for index = 0, 6 do
			table.insert(keypoints, ColorSequenceKeypoint.new(index / 6, Color3.fromHSV(index / 6, 1, 1)))
		end

		make("UIGradient", { Color = ColorSequence.new(keypoints), Parent = bar })

		local hueMarker = make("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.fromOffset(3, 14),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0,
			ZIndex = 56,
			Parent = bar,
		})

		local function refresh()
			square.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
			marker.Position = UDim2.fromScale(saturation, 1 - value)
			hueMarker.Position = UDim2.fromScale(hue, 0.5)
			onChange(Color3.fromHSV(hue, saturation, value))
		end

		refresh()

		table.insert(connections, square.InputBegan:Connect(function(input)
			if not isPress(input) then
				return
			end

			local function update(moved)
				saturation = math.clamp((moved.Position.X - square.AbsolutePosition.X) / square.AbsoluteSize.X, 0, 1)
				value = 1 - math.clamp((moved.Position.Y - square.AbsolutePosition.Y) / square.AbsoluteSize.Y, 0, 1)
				refresh()
			end

			activeDrag = update
			update(input)
		end))

		table.insert(connections, bar.InputBegan:Connect(function(input)
			if not isPress(input) then
				return
			end

			local function update(moved)
				hue = math.clamp((moved.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 0.999)
				refresh()
			end

			activeDrag = update
			update(input)
		end))
	end

	local Section = {}
	Section.__index = Section

	local function newRow(section, height)
		return make("Frame", {
			Size = UDim2.new(1, 0, 0, height),
			BackgroundTransparency = 1,
			Parent = section.holder,
		})
	end

	function Section:AddLabel(text, options)
		options = options or {}

		if options.wrap then
			local wrapRow = make("Frame", {
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				Parent = self.holder,
			})

			local wrapLabel = textLabel({
				Position = UDim2.fromOffset(2, 0),
				Size = UDim2.new(1, -4, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				Text = text,
				TextSize = 10,
				TextWrapped = true,
				TextYAlignment = Enum.TextYAlignment.Top,
				Parent = wrapRow,
			})

			return {
				SetText = function(_, value)
					wrapLabel.Text = value
				end,
			}
		end

		local row = newRow(self, 16)

		local label = textLabel({
			Position = UDim2.fromOffset(2, 0),
			Size = UDim2.new(1, -20, 1, 0),
			Text = text,
			Parent = row,
		})

		addTooltipMark(row, label, text, options.tooltip)

		if options.gear then
			makeGear(row, UDim2.new(1, -14, 0, 1), options.gear)
		end

		return {
			SetText = function(_, value)
				label.Text = value
			end,
		}
	end

	function Section:AddButton(text, callback)
		local row = newRow(self, 22)

		local button = make("TextButton", {
			Size = UDim2.new(1, 0, 1, -2),
			BackgroundColor3 = THEME.control,
			BorderSizePixel = 0,
			Text = text,
			TextColor3 = THEME.textBright,
			TextSize = 11,
			Font = FONT,
			AutoButtonColor = true,
			Parent = row,
		})

		addStroke(button)
		round(button, 7)

		if callback then
			table.insert(connections, button.Activated:Connect(callback))
		end

		return button
	end

	function Section:AddToggle(text, default, callback, options)
		options = options or {}

		local toggle = { Value = default == true, Callback = callback, rightOffset = 2 }
		local row = newRow(self, 16)
		local indent = options.indent and 14 or 0

		local trackWidth = 26
		local trackHeight = 14
		local trackX = indent + 2

		local function pill(width, height, transparency, color)
			local frame = make("Frame", {
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.fromOffset(trackX - (width - trackWidth) / 2, 8),
				Size = UDim2.fromOffset(width, height),
				BackgroundColor3 = color,
				BackgroundTransparency = transparency,
				BorderSizePixel = 0,
				Parent = row,
			})

			round(frame, height)

			return frame
		end

		local glowOuter = pill(40, 26, 1, THEME.accent)
		local glowInner = pill(33, 20, 1, THEME.accent)
		local box = pill(trackWidth, trackHeight, 0, THEME.control)
		local boxStroke = addStroke(box)

		local knob = make("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 2, 0.5, 0),
			Size = UDim2.fromOffset(10, 10),
			BackgroundColor3 = THEME.text,
			BorderSizePixel = 0,
			ZIndex = 2,
			Parent = box,
		})

		round(knob, 5)

		local button = make("TextButton", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Text = "",
			Parent = row,
		})

		local label = textLabel({
			Position = UDim2.fromOffset(indent + 36, 0),
			Size = UDim2.new(1, -(indent + 36), 1, 0),
			Text = text,
			Parent = row,
		})

		addTooltipMark(row, label, text, options.tooltip)

		function toggle:Set(value, silent)
			self.Value = value
			box.BackgroundColor3 = value and THEME.accent or THEME.control
			boxStroke.Color = value and THEME.accent or THEME.line
			label.TextColor3 = value and THEME.textBright or THEME.text

			local info = TweenInfo.new(0.15)
			tweenService:Create(knob, info, {
				Position = UDim2.new(0, value and 14 or 2, 0.5, 0),
				BackgroundColor3 = value and Color3.new(1, 1, 1) or THEME.text,
			}):Play()
			tweenService:Create(glowOuter, info, { BackgroundTransparency = value and 0.88 or 1 }):Play()
			tweenService:Create(glowInner, info, { BackgroundTransparency = value and 0.7 or 1 }):Play()

			if not silent and self.Callback then
				task.spawn(self.Callback, value)
			end
		end

		function toggle:AddKeybind(default)
			local bind = { Key = nil }
			local keyButton = make("TextButton", {
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.new(1, -self.rightOffset, 0, 0),
				Size = UDim2.fromOffset(40, 16),
				BackgroundTransparency = 1,
				Text = "Bind",
				TextColor3 = THEME.text,
				TextSize = 10,
				Font = FONT,
				TextXAlignment = Enum.TextXAlignment.Right,
				ZIndex = 3,
				Parent = row,
			})

			self.rightOffset += 44

			local function describe(key)
				if typeof(key) == "EnumItem" then
					return key.Name
				end

				return "Bind"
			end

			function bind:Set(key)
				self.Key = key
				keyButton.Text = describe(key)
			end

			bind.Toggle = toggle
			table.insert(binds, bind)

			table.insert(connections, keyButton.Activated:Connect(function()
				listeningBind = bind
				keyButton.Text = "..."
			end))

			bind.Button = keyButton
			bind.Describe = describe

			if default then
				bind:Set(default)
			end

			return self
		end

		function toggle:AddColor(default, onChange)
			local color = default or THEME.accent

			local swatch = make("TextButton", {
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.new(1, -self.rightOffset, 0, 3),
				Size = UDim2.fromOffset(24, 10),
				BackgroundColor3 = color,
				BorderSizePixel = 0,
				Text = "",
				ZIndex = 3,
				Parent = row,
			})

			addStroke(swatch)
			round(swatch, 4)
			self.rightOffset += 28

			table.insert(connections, swatch.Activated:Connect(function()
				openColorPicker(swatch, color, function(newColor)
					color = newColor
					swatch.BackgroundColor3 = newColor

					if onChange then
						onChange(newColor)
					end
				end)
			end))

			return self
		end

		table.insert(connections, button.Activated:Connect(function()
			toggle:Set(not toggle.Value)
		end))

		toggle:Set(toggle.Value, true)

		return toggle
	end

	function Section:AddSlider(text, minimum, maximum, default, rounding, callback, options)
		options = options or {}

		local slider = { Value = default, Callback = callback }
		local row = newRow(self, 28)
		local trackInset = options.gear and 18 or 0

		local label = textLabel({
			Position = UDim2.fromOffset(2, 0),
			Size = UDim2.new(1, -60, 0, 14),
			Text = text,
			TextColor3 = THEME.textBright,
			Parent = row,
		})

		local valueLabel = textLabel({
			Position = UDim2.new(1, -62 - trackInset, 0, 0),
			Size = UDim2.fromOffset(60, 14),
			TextXAlignment = Enum.TextXAlignment.Right,
			TextSize = 10,
			Parent = row,
		})

		addTooltipMark(row, label, text, options.tooltip)

		local track = make("Frame", {
			Position = UDim2.fromOffset(2, 18),
			Size = UDim2.new(1, -4 - trackInset, 0, 4),
			BackgroundColor3 = THEME.control,
			BorderSizePixel = 0,
			Parent = row,
		})

		local fill = make("Frame", {
			Size = UDim2.fromScale(0, 1),
			BackgroundColor3 = THEME.accent,
			BorderSizePixel = 0,
			Parent = track,
		})

		local thumb = make("Frame", {
			Size = UDim2.fromOffset(10, 10),
			BackgroundColor3 = THEME.textBright,
			BorderSizePixel = 0,
			ZIndex = 2,
			Parent = track,
		})

		round(track, 2)
		round(fill, 2)
		round(thumb, 5)

		local hit = make("TextButton", {
			Position = UDim2.fromOffset(0, 12),
			Size = UDim2.new(1, -trackInset, 0, 16),
			BackgroundTransparency = 1,
			Text = "",
			Parent = row,
		})

		local function render()
			local fraction = (slider.Value - minimum) / (maximum - minimum)

			fill.Size = UDim2.fromScale(fraction, 1)
			thumb.Position = UDim2.new(fraction, -5, 0.5, -5)

			if options.disabledAtMin and slider.Value <= minimum then
				valueLabel.Text = "Disabled"
			else
				valueLabel.Text = tostring(slider.Value) .. (options.suffix or "")
			end
		end

		function slider:Set(value, silent)
			local factor = 10 ^ rounding
			value = math.clamp(math.floor(value * factor + 0.5) / factor, minimum, maximum)
			self.Value = value
			render()

			if not silent and self.Callback then
				task.spawn(self.Callback, value)
			end
		end

		table.insert(connections, hit.InputBegan:Connect(function(input)
			if not isPress(input) then
				return
			end

			local function update(moved)
				local fraction = math.clamp((moved.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
				slider:Set(minimum + (maximum - minimum) * fraction)
			end

			activeDrag = update
			update(input)
		end))

		if options.gear then
			makeGear(row, UDim2.new(1, -14, 0, 14), options.gear)
		end

		slider:Set(default, true)

		return slider
	end

	function Section:AddDropdown(text, values, default, callback, options)
		options = options or {}

		local multi = options.multi == true
		local dropdown = { Callback = callback, Values = values }
		local row = newRow(self, 38)
		local boxInset = options.gear and 18 or 0

		dropdown.Value = multi and {} or default

		if multi and type(default) == "table" then
			for _, name in next, default do
				dropdown.Value[name] = true
			end
		end

		local label = textLabel({
			Position = UDim2.fromOffset(2, 0),
			Size = UDim2.new(1, -4, 0, 14),
			Text = text,
			TextColor3 = THEME.textBright,
			Parent = row,
		})

		addTooltipMark(row, label, text, options.tooltip)

		local box = make("TextButton", {
			Position = UDim2.fromOffset(0, 17),
			Size = UDim2.new(1, -boxInset, 0, 19),
			BackgroundColor3 = THEME.control,
			BorderSizePixel = 0,
			Text = "",
			AutoButtonColor = false,
			Parent = row,
		})

		addStroke(box)
		round(box, 7)

		local valueLabel = textLabel({
			Position = UDim2.fromOffset(6, 0),
			Size = UDim2.new(1, -22, 1, 0),
			TextSize = 10,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = box,
		})

		if multi then
			makeHamburger(box)
		else
			textLabel({
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.new(1, -4, 0, 0),
				Size = UDim2.fromOffset(12, 19),
				Text = "▼",
				TextSize = 8,
				TextXAlignment = Enum.TextXAlignment.Center,
				Parent = box,
			})
		end

		local function describe()
			if not multi then
				return tostring(dropdown.Value or "")
			end

			local names = {}

			for _, name in next, values do
				if dropdown.Value[name] then
					table.insert(names, name)
				end
			end

			return table.concat(names, ", ")
		end

		function dropdown:Set(value, silent)
			self.Value = value
			valueLabel.Text = describe()

			if not silent and self.Callback then
				task.spawn(self.Callback, self.Value)
			end
		end

		function dropdown:SetValues(newValues)
			values = newValues
			self.Values = newValues

			if multi then
				local filtered = {}

				for _, name in next, newValues do
					if self.Value[name] then
						filtered[name] = true
					end
				end

				self.Value = filtered
			elseif self.Value and not table.find(newValues, self.Value) then
				self.Value = nil
			end

			valueLabel.Text = describe()

			if self.Callback then
				task.spawn(self.Callback, self.Value)
			end
		end

		table.insert(connections, box.Activated:Connect(function()
			local rows = math.min(#values, MAX_LIST_ROWS)
			local popup = beginPopup(box, box.AbsoluteSize.X, rows * 18 + 4)

			local scroll = make("ScrollingFrame", {
				Position = UDim2.fromOffset(2, 2),
				Size = UDim2.new(1, -4, 1, -4),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				ScrollBarThickness = 2,
				CanvasSize = UDim2.new(),
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				ZIndex = 53,
				Parent = popup,
			})

			make("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = scroll })

			local items = {}

			local function paint()
				for name, item in next, items do
					local selected = multi and dropdown.Value[name] or (not multi and dropdown.Value == name)
					item.TextColor3 = selected and THEME.accent or THEME.text
				end
			end

			for index, name in next, values do
				local item = make("TextButton", {
					Size = UDim2.new(1, 0, 0, 18),
					BackgroundTransparency = 1,
					Text = "  " .. name,
					TextColor3 = THEME.text,
					TextSize = 10,
					Font = FONT,
					TextXAlignment = Enum.TextXAlignment.Left,
					LayoutOrder = index,
					ZIndex = 54,
					Parent = scroll,
				})

				items[name] = item

				table.insert(connections, item.Activated:Connect(function()
					if multi then
						local copy = table.clone(dropdown.Value)
						copy[name] = not copy[name] or nil
						dropdown:Set(copy)
						paint()
					else
						dropdown:Set(name)
						closePopup()
					end
				end))
			end

			paint()
		end))

		if options.gear then
			makeGear(row, UDim2.new(1, -14, 0, 20), options.gear)
		end

		dropdown:Set(dropdown.Value, true)

		return dropdown
	end

	function Section:AddInput(text, default, callback, placeholder)
		local input = { Value = tostring(default or ""), Callback = callback }
		local row = newRow(self, 38)

		textLabel({
			Position = UDim2.fromOffset(2, 0),
			Size = UDim2.new(1, -4, 0, 14),
			Text = text,
			TextColor3 = THEME.textBright,
			Parent = row,
		})

		local box = make("TextBox", {
			Position = UDim2.fromOffset(0, 17),
			Size = UDim2.new(1, 0, 0, 19),
			BackgroundColor3 = THEME.control,
			BorderSizePixel = 0,
			Text = input.Value,
			PlaceholderText = placeholder or "",
			PlaceholderColor3 = THEME.text,
			TextColor3 = THEME.textBright,
			TextSize = 10,
			Font = FONT,
			TextXAlignment = Enum.TextXAlignment.Left,
			ClearTextOnFocus = false,
			Parent = row,
		})

		addStroke(box)
		round(box, 7)
		make("UIPadding", { PaddingLeft = UDim.new(0, 6), Parent = box })

		function input:Set(value, silent)
			self.Value = tostring(value)
			box.Text = self.Value

			if not silent and self.Callback then
				task.spawn(self.Callback, self.Value)
			end
		end

		table.insert(connections, box.FocusLost:Connect(function()
			input:Set(box.Text)
		end))

		return input
	end

	function Section:AddColor(text, default, callback)
		local color = default or THEME.accent
		local row = newRow(self, 16)

		textLabel({
			Position = UDim2.fromOffset(2, 0),
			Size = UDim2.new(1, -30, 1, 0),
			Text = text,
			Parent = row,
		})

		local swatch = make("TextButton", {
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -2, 0, 3),
			Size = UDim2.fromOffset(24, 10),
			BackgroundColor3 = color,
			BorderSizePixel = 0,
			Text = "",
			Parent = row,
		})

		addStroke(swatch)
		round(swatch, 4)

		table.insert(connections, swatch.Activated:Connect(function()
			openColorPicker(swatch, color, function(newColor)
				color = newColor
				swatch.BackgroundColor3 = newColor

				if callback then
					callback(newColor)
				end
			end)
		end))

		local object = { Value = color, Swatch = swatch }

		function object:Set(newColor, silent)
			color = newColor
			self.Value = newColor
			swatch.BackgroundColor3 = newColor

			if not silent and callback then
				callback(newColor)
			end
		end

		return object
	end

	function Section:AddKeybind(text, default, callback)
		local row = newRow(self, 16)

		textLabel({
			Position = UDim2.fromOffset(2, 0),
			Size = UDim2.new(1, -70, 1, 0),
			Text = text,
			Parent = row,
		})

		local keyButton = make("TextButton", {
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -2, 0, 0),
			Size = UDim2.fromOffset(70, 16),
			BackgroundTransparency = 1,
			Text = "",
			TextColor3 = THEME.textBright,
			TextSize = 10,
			Font = FONT,
			TextXAlignment = Enum.TextXAlignment.Right,
			Parent = row,
		})

		local bind = { Key = default, Button = keyButton }

		function bind.Describe(key)
			if typeof(key) == "EnumItem" then
				return key.Name
			end

			return "None"
		end

		function bind:Set(key)
			self.Key = key
			keyButton.Text = self.Describe(key)

			if callback then
				callback(key)
			end
		end

		table.insert(connections, keyButton.Activated:Connect(function()
			listeningBind = bind
			keyButton.Text = "..."
		end))

		keyButton.Text = bind.Describe(default)

		return bind
	end

	local Tab = {}
	Tab.__index = Tab

	function Tab:AddSection(name, column)
		local holderColumn = self.columns[column or 1]

		local frame = make("Frame", {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundColor3 = THEME.panel,
			BorderSizePixel = 0,
			Parent = holderColumn,
		})

		addStroke(frame)
		round(frame, 10)

		textLabel({
			Position = UDim2.fromOffset(8, 0),
			Size = UDim2.new(1, -16, 0, 22),
			Text = name,
			TextColor3 = THEME.textBright,
			Parent = frame,
		})

		make("Frame", {
			Position = UDim2.fromOffset(0, 22),
			Size = UDim2.new(1, 0, 0, 1),
			BackgroundColor3 = THEME.accentDark,
			BorderSizePixel = 0,
			Parent = frame,
		})

		local holder = make("Frame", {
			Position = UDim2.fromOffset(0, 24),
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			Parent = frame,
		})

		make("UIListLayout", {
			Padding = UDim.new(0, 4),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = holder,
		})

		make("UIPadding", {
			PaddingTop = UDim.new(0, 4),
			PaddingBottom = UDim.new(0, 8),
			PaddingLeft = UDim.new(0, 6),
			PaddingRight = UDim.new(0, 6),
			Parent = holder,
		})

		return setmetatable({ holder = holder }, Section)
	end

	local tabs = {}
	local selectedTab = nil

	local function selectTab(tab)
		closePopup()

		for _, other in next, tabs do
			local active = other == tab

			other.content.Visible = active
			other.bar.Visible = active
			other.button.BackgroundTransparency = active and 0.35 or 1
			other.button.TextColor3 = active and THEME.textBright or THEME.text
		end

		selectedTab = tab
	end

	local function addTab(name)
		local tab = setmetatable({}, Tab)

		tab.button = make("TextButton", {
			Size = UDim2.new(1, 0, 0, 24),
			BackgroundColor3 = THEME.control,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Text = "  " .. name,
			TextColor3 = THEME.text,
			TextSize = 11,
			Font = FONT,
			TextXAlignment = Enum.TextXAlignment.Left,
			LayoutOrder = #tabs + 1,
			Parent = sidebar,
		})

		round(tab.button, 8)

		tab.bar = make("Frame", {
			Size = UDim2.new(0, 3, 1, -12),
			Position = UDim2.fromOffset(2, 6),
			BackgroundColor3 = THEME.accent,
			BorderSizePixel = 0,
			Visible = false,
			Parent = tab.button,
		})

		round(tab.bar, 2)

		tab.content = make("ScrollingFrame", {
			Position = UDim2.fromOffset(SIDEBAR_WIDTH + 9, HEADER_HEIGHT + 8),
			Size = UDim2.new(1, -(SIDEBAR_WIDTH + 17), 1, -(HEADER_HEIGHT + 14)),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = 3,
			ScrollBarImageColor3 = THEME.accentDark,
			CanvasSize = UDim2.new(),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			Visible = false,
			Parent = window,
		})

		local columnsHolder = make("Frame", {
			Size = UDim2.new(1, -4, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			Parent = tab.content,
		})

		make("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 6),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = columnsHolder,
		})

		tab.columns = {}

		for index = 1, 2 do
			local column = make("Frame", {
				Size = UDim2.new(1 / 2, -3, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				LayoutOrder = index,
				Parent = columnsHolder,
			})

			make("UIListLayout", {
				Padding = UDim.new(0, 6),
				SortOrder = Enum.SortOrder.LayoutOrder,
				Parent = column,
			})

			tab.columns[index] = column
		end

		table.insert(connections, tab.button.Activated:Connect(function()
			selectTab(tab)
		end))

		table.insert(tabs, tab)

		return tab
	end

	local function setMenuVisible(visible)
		window.Visible = visible

		if visible then
			dim.Visible = true
			tweenService:Create(dim, TweenInfo.new(0.25), { BackgroundTransparency = 0.5 }):Play()
		else
			closePopup()
			tweenService:Create(dim, TweenInfo.new(0.25), { BackgroundTransparency = 1 }):Play()

			task.delay(0.25, function()
				if not window.Visible then
					dim.Visible = false
				end
			end)
		end
	end

	local menuButton = make("TextButton", {
		Name = "MenuButton",
		Position = UDim2.new(0, 10, 0.5, -20),
		Size = UDim2.fromOffset(40, 40),
		BackgroundColor3 = THEME.background,
		BorderSizePixel = 0,
		Text = "M",
		TextColor3 = THEME.accent,
		TextSize = 18,
		Font = FONT_BOLD,
		AutoButtonColor = false,
		Active = true,
		Parent = gui,
	})

	round(menuButton, 14)
	addStroke(menuButton, THEME.accent)

	table.insert(connections, menuButton.InputBegan:Connect(function(input)
		if not isPress(input) then
			return
		end

		local start = input.Position
		local origin = menuButton.Position
		local moved = false

		activeDrag = function(current)
			local delta = current.Position - start

			if delta.Magnitude > 8 and not menuLocked then
				moved = true
			end

			if moved then
				menuButton.Position = UDim2.new(origin.X.Scale, origin.X.Offset + delta.X, origin.Y.Scale, origin.Y.Offset + delta.Y)
			end
		end

		local connection = nil

		connection = input.Changed:Connect(function()
			if input.UserInputState ~= Enum.UserInputState.End then
				return
			end

			connection:Disconnect()

			if not moved then
				setMenuVisible(not window.Visible)
			end
		end)
	end))

	table.insert(connections, userInputService.InputBegan:Connect(function(input, processed)
		if listeningBind then
			local bind = listeningBind
			listeningBind = nil

			if input.UserInputType == Enum.UserInputType.Keyboard then
				if input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.Backspace then
					bind:Set(nil)
				else
					bind:Set(input.KeyCode)
				end
			elseif input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.MouseButton3 then
				bind:Set(input.UserInputType)
			else
				bind.Button.Text = bind.Describe(bind.Key)
			end

			return
		end

		if processed then
			return
		end

		if menuKey and input.KeyCode == menuKey then
			setMenuVisible(not window.Visible)
			return
		end

		for _, bind in next, binds do
			if bind.Key and input.KeyCode == bind.Key then
				bind.Toggle:Set(not bind.Toggle.Value)
			end
		end
	end))

	local toastHolder = make("Frame", {
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 12),
		Size = UDim2.fromOffset(320, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		ZIndex = 80,
		Parent = gui,
	})

	make("UIListLayout", {
		Padding = UDim.new(0, 4),
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = toastHolder,
	})

	local toastOrder = 0

	showToast = function(text)
		if not toastHolder.Parent then
			return false
		end

		toastOrder += 1

		local toast = make("TextLabel", {
			Size = UDim2.new(0, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundColor3 = THEME.background,
			BackgroundTransparency = 0.1,
			BorderSizePixel = 0,
			Text = text,
			TextColor3 = THEME.textBright,
			TextSize = 11,
			Font = FONT,
			TextWrapped = true,
			LayoutOrder = toastOrder,
			ZIndex = 81,
			Parent = toastHolder,
		})

		round(toast, 8)
		addStroke(toast, THEME.accentDark)

		make("UIPadding", {
			PaddingLeft = UDim.new(0, 10),
			PaddingRight = UDim.new(0, 10),
			PaddingTop = UDim.new(0, 5),
			PaddingBottom = UDim.new(0, 5),
			Parent = toast,
		})

		make("UISizeConstraint", { MaxSize = Vector2.new(320, 120), Parent = toast })

		task.delay(4, function()
			if not toast.Parent then
				return
			end

			tweenService:Create(toast, TweenInfo.new(0.25), { BackgroundTransparency = 1, TextTransparency = 1 }):Play()

			task.delay(0.3, function()
				toast:Destroy()
			end)
		end)

		return true
	end

	local function destroy()
		showToast = nil

		for _, connection in next, connections do
			connection:Disconnect()
		end

		table.clear(connections)
		gui:Destroy()
	end

	return {
		gui = gui,
		window = window,
		tabs = tabs,
		connections = connections,
		addTab = addTab,
		selectTab = selectTab,
		setMenuVisible = setMenuVisible,
		menuButton = menuButton,
		menuHome = menuButton.Position,
		setMenuKey = function(key)
			menuKey = key
		end,
		setMenuLocked = function(value)
			menuLocked = value
		end,
		getMenuLocked = function()
			return menuLocked
		end,
		destroy = destroy,
	}
end

function Library.buildMenuTab(ui, tab, cleanup)
	local menuSection = tab:AddSection("Menu", 1)

	menuSection:AddKeybind("Menu Keybind", Enum.KeyCode.RightShift, function(key)
		ui.setMenuKey(key)
	end)

	menuSection:AddToggle("Lock Menu Button", false, function(value)
		ui.setMenuLocked(value)
	end)

	menuSection:AddButton("Reset Button Position", function()
		ui.menuButton.Position = ui.menuHome
	end)

	menuSection:AddButton("Hide Menu", function()
		ui.setMenuVisible(false)
	end)

	local actionSection = tab:AddSection("Actions", 2)

	actionSection:AddButton("Unload", function()
		cleanup()
	end)
end

return Library
