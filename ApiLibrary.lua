local userInputService = game:GetService("UserInputService")
local textService = game:GetService("TextService")
local tweenService = game:GetService("TweenService")
local workspaceService = game:GetService("Workspace")
local playersService = game:GetService("Players")
local runService = game:GetService("RunService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local starterGui = game:GetService("StarterGui")
local teamsService = game:GetService("Teams")
local teleportService = game:GetService("TeleportService")
local httpService = game:GetService("HttpService")

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
	accentLight = Color3.fromRGB(235, 80, 100),
	text = Color3.fromRGB(150, 150, 156),
	textBright = Color3.fromRGB(225, 225, 228),
}

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

local GAME_UNIVERSES = { mm2 = 66654135 }

local ICON_SHAPES = {
	plus = { { "bar", 0.5, 0.5, 0.8, 0.18 }, { "bar", 0.5, 0.5, 0.18, 0.8 } },
	chevron = { { "bar", 0.3, 0.5, 0.55, 0.16, 40 }, { "bar", 0.7, 0.5, 0.55, 0.16, -40 } },
}

local function makeIcon(parent, name, color, size, position)
	local holder = make("Frame", {
		Position = position or UDim2.new(),
		Size = UDim2.fromOffset(size, size),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Parent = parent,
	})

	for _, shape in next, ICON_SHAPES[name] or ICON_SHAPES.plus do
		local kind = shape[1]
		local width = shape[4]
		local height = (kind == "dot" or kind == "ring") and width or shape[5]
		local rotation = 0

		if kind == "bar" or kind == "pill" then
			rotation = shape[6] or 0
		end

		local frame = make("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(shape[2], shape[3]),
			Size = UDim2.fromScale(width, height),
			BackgroundColor3 = color,
			BackgroundTransparency = (kind == "ring" or kind == "oval" or shape[7] == true) and 1 or 0,
			BorderSizePixel = 0,
			Rotation = rotation,
			Parent = holder,
		})

		if kind == "dot" or kind == "ring" or kind == "oval" or kind == "pill" then
			round(frame, 999)
		else
			round(frame, 1)
		end

		if kind == "ring" then
			make("UIStroke", { Color = color, Thickness = shape[5], Parent = frame })
		elseif kind == "oval" then
			make("UIStroke", { Color = color, Thickness = shape[6], Parent = frame })
		end
	end

	return holder
end

local function tweenTo(instance, duration, goal, style, direction)
	tweenService:Create(instance, TweenInfo.new(duration, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out), goal):Play()
end

local function makeBaseplateIcon(parent)
	local frame = make("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Parent = parent,
	})

	make("UIGradient", {
		Color = ColorSequence.new(Color3.fromRGB(104, 166, 232), Color3.fromRGB(214, 234, 250)),
		Rotation = 90,
		Parent = frame,
	})

	local sun = make("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.78, 0.2),
		Size = UDim2.fromScale(0.16, 0.16),
		BackgroundColor3 = Color3.fromRGB(255, 244, 190),
		BorderSizePixel = 0,
		Parent = frame,
	})

	round(sun, 999)

	local plate = make("Frame", {
		Position = UDim2.fromScale(0, 0.56),
		Size = UDim2.fromScale(1, 0.44),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Parent = frame,
	})

	make("UIGradient", {
		Color = ColorSequence.new(Color3.fromRGB(70, 76, 84), Color3.fromRGB(104, 111, 120)),
		Rotation = 90,
		Parent = plate,
	})

	for _, y in next, { 0.2, 0.44, 0.74 } do
		make("Frame", {
			Position = UDim2.fromScale(0, y),
			Size = UDim2.new(1, 0, 0, 1),
			BackgroundColor3 = Color3.fromRGB(150, 158, 170),
			BackgroundTransparency = 0.45,
			BorderSizePixel = 0,
			Parent = plate,
		})
	end

	for _, x in next, { 0.1, 0.3, 0.5, 0.7, 0.9 } do
		make("Frame", {
			Position = UDim2.fromScale(x, 0),
			Size = UDim2.new(0, 1, 1, 0),
			BackgroundColor3 = Color3.fromRGB(150, 158, 170),
			BackgroundTransparency = 0.45,
			BorderSizePixel = 0,
			Parent = plate,
		})
	end

	return frame
end

local function makeGameIcon(parent, id, size, position, radius)
	local holder = make("Frame", {
		Position = position or UDim2.new(),
		Size = size,
		BackgroundColor3 = THEME.control,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Parent = parent,
	})

	round(holder, radius or 10)

	if id == "universal" then
		makeBaseplateIcon(holder)
	else
		textLabel({
			Size = UDim2.fromScale(1, 1),
			Text = "MM2",
			TextColor3 = THEME.accent,
			Font = FONT_BOLD,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Center,
			Parent = holder,
		})

		local universe = GAME_UNIVERSES[id]

		if universe then
			make("ImageLabel", {
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				Image = string.format("rbxthumb://type=GameIcon&id=%d&w=150&h=150", universe),
				ScaleType = Enum.ScaleType.Crop,
				Parent = holder,
			})
		end
	end

	return holder
end

local function updateArrow(triangle, camera, position, color)
	if not triangle then
		return
	end

	local point, onScreen = camera:WorldToViewportPoint(position)
	local inFront = point.Z > 0

	if onScreen and inFront then
		triangle.Visible = false
		return
	end

	local center = camera.ViewportSize / 2
	local delta = Vector2.new(point.X, point.Y) - center

	if not inFront then
		delta = -delta
	end

	if delta.Magnitude < 1 then
		delta = Vector2.new(0, -1)
	end

	local direction = delta.Unit
	local radius = math.min(center.X, center.Y) - 36
	local tip = center + direction * radius
	local back = tip - direction * 16
	local side = Vector2.new(-direction.Y, direction.X) * 7

	triangle.PointA = tip
	triangle.PointB = back + side
	triangle.PointC = back - side
	triangle.Color = color
	triangle.Filled = true
	triangle.Visible = true
end


local function createUi(subtitle, gameId)
	local guiParent = (type(gethui) == "function" and gethui()) or playersService.LocalPlayer:WaitForChild("PlayerGui")
	local camera = workspaceService.CurrentCamera
	local viewport = camera and camera.ViewportSize or Vector2.new(800, 400)
	local windowWidth = math.min(520, viewport.X - 40)
	local windowHeight = math.min(300, viewport.Y - 40)

	local connections = {}
	local binds = {}
	local keybindRegistry = {}
	local activeDrag = nil
	local activeEnd = nil
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

	local blur = nil

	pcall(function()
		local lighting = game:GetService("Lighting")
		local old = lighting:FindFirstChild("MagmaBlur")

		if old then
			old:Destroy()
		end

		blur = Instance.new("BlurEffect")
		blur.Name = "MagmaBlur"
		blur.Size = 0
		blur.Parent = lighting
	end)

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

	local root = make("Frame", {
		Name = "Root",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(windowWidth, windowHeight),
		BackgroundTransparency = 1,
		Parent = gui,
	})

	local shadow = make("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(1, 36, 1, 36),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.6,
		BorderSizePixel = 0,
		ZIndex = 0,
		Parent = root,
	})

	round(shadow, 28)

	local window = make("Frame", {
		Name = "Window",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		Active = true,
		ZIndex = 1,
		Parent = root,
	})

	round(window, 16)

	make("UIGradient", {
		Color = ColorSequence.new(Color3.fromRGB(26, 17, 22), Color3.fromRGB(11, 11, 14)),
		Rotation = 90,
		Parent = window,
	})

	local windowStroke = addStroke(window, THEME.accent)
	windowStroke.Thickness = 1.5

	make("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, THEME.accent),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(60, 24, 32)),
			ColorSequenceKeypoint.new(1, THEME.accent),
		}),
		Rotation = 45,
		Parent = windowStroke,
	})

	local windowScale = make("UIScale", { Scale = 1, Parent = window })

	local header = make("Frame", {
		Size = UDim2.new(1, 0, 0, 38),
		BackgroundTransparency = 1,
		Active = true,
		Parent = window,
	})

	local logoWidth = textService:GetTextSize("magma", 17, FONT_BOLD, Vector2.new(400, 40)).X

	textLabel({
		Position = UDim2.fromOffset(16, 0),
		Size = UDim2.fromOffset(logoWidth + 6, 38),
		Text = '<font color="rgb(235,235,238)">mag</font><font color="rgb(220,60,80)">ma</font>',
		RichText = true,
		Font = FONT_BOLD,
		TextSize = 17,
		Parent = header,
	})

	if subtitle then
		local chipWidth = textService:GetTextSize(string.upper(subtitle), 9, FONT_BOLD, Vector2.new(400, 40)).X + 16

		local chip = make("Frame", {
			Position = UDim2.fromOffset(16 + logoWidth + 12, 10),
			Size = UDim2.fromOffset(chipWidth, 18),
			BackgroundColor3 = THEME.accent,
			BackgroundTransparency = 0.82,
			BorderSizePixel = 0,
			Parent = header,
		})

		round(chip, 9)
		addStroke(chip, THEME.accentDark)

		textLabel({
			Size = UDim2.fromScale(1, 1),
			Text = string.upper(subtitle),
			TextColor3 = THEME.accentLight,
			Font = FONT_BOLD,
			TextSize = 9,
			TextXAlignment = Enum.TextXAlignment.Center,
			Parent = chip,
		})
	end

	local headerLine = make("Frame", {
		Position = UDim2.new(0, 14, 1, -1),
		Size = UDim2.new(1, -28, 0, 1),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		Parent = header,
	})

	local headerGradient = make("UIGradient", {
		Color = ColorSequence.new(THEME.accent, THEME.accent),
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.35, 0.15),
			NumberSequenceKeypoint.new(0.65, 0.15),
			NumberSequenceKeypoint.new(1, 1),
		}),
		Offset = Vector2.new(-0.35, 0),
		Parent = headerLine,
	})

	tweenService:Create(headerGradient, TweenInfo.new(2.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), { Offset = Vector2.new(0.35, 0) }):Play()

	local SIDEBAR_W = 104

	make("Frame", {
		Position = UDim2.fromOffset(SIDEBAR_W, 46),
		Size = UDim2.new(0, 1, 1, -58),
		BackgroundColor3 = THEME.line,
		BackgroundTransparency = 0.3,
		BorderSizePixel = 0,
		Parent = window,
	})

	local sidebar = make("Frame", {
		Position = UDim2.fromOffset(0, 48),
		Size = UDim2.new(0, SIDEBAR_W, 1, -56),
		BackgroundTransparency = 1,
		Parent = window,
	})

	make("UIListLayout", {
		Padding = UDim.new(0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = sidebar,
	})

	make("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), Parent = sidebar })

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

	local popupClosers = {}

	local function closePopup()
		if openPopup then
			openPopup:Destroy()
			openPopup = nil
		end

		for _, closer in next, popupClosers do
			pcall(closer)
		end

		table.clear(popupClosers)
		catcher.Visible = false
	end

	table.insert(connections, catcher.Activated:Connect(closePopup))

	local function beginPopup(anchor, width, height, onClose)
		closePopup()
		catcher.Visible = true

		if onClose then
			table.insert(popupClosers, onClose)
		end

		local base = popupLayer.AbsolutePosition
		local position = anchor.AbsolutePosition - base
		local y = position.Y + anchor.AbsoluteSize.Y + 3

		if y + height > windowHeight - 4 then
			y = math.max(position.Y - height - 3, 4)
		end

		local popup = make("Frame", {
			Position = UDim2.fromOffset(math.min(position.X, windowWidth - width - 4), y),
			Size = UDim2.fromOffset(width, 0),
			BackgroundColor3 = Color3.fromRGB(20, 20, 25),
			BorderSizePixel = 0,
			ClipsDescendants = true,
			ZIndex = 52,
			Parent = popupLayer,
		})

		addStroke(popup, THEME.accentDark)
		round(popup, 9)
		tweenTo(popup, 0.14, { Size = UDim2.fromOffset(width, height) })
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
			Size = UDim2.fromOffset(size.X + 12, size.Y + 10),
			BackgroundColor3 = Color3.fromRGB(26, 26, 32),
			BorderSizePixel = 0,
			ZIndex = 60,
			Parent = popupLayer,
		})

		addStroke(tip, THEME.accentDark)
		round(tip, 8)

		textLabel({
			Position = UDim2.fromOffset(6, 5),
			Size = UDim2.new(1, -12, 1, -10),
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

			if activeEnd then
				local finish = activeEnd
				activeEnd = nil
				finish()
			end
		end
	end))

	table.insert(connections, header.InputBegan:Connect(function(input)
		if not isPress(input) then
			return
		end

		local start = input.Position
		local origin = root.Position

		activeDrag = function(moved)
			local delta = moved.Position - start
			root.Position = UDim2.new(origin.X.Scale, origin.X.Offset + delta.X, origin.Y.Scale, origin.Y.Offset + delta.Y)
		end
	end))

	local function hoverEffect(button, onEnter, onLeave)
		table.insert(connections, button.MouseEnter:Connect(onEnter))
		table.insert(connections, button.MouseLeave:Connect(onLeave))
	end

	local function pressEffect(button, scale)
		table.insert(connections, button.InputBegan:Connect(function(input)
			if isPress(input) then
				tweenTo(scale, 0.08, { Scale = 0.96 })
			end
		end))

		table.insert(connections, button.InputEnded:Connect(function(input)
			if isPress(input) then
				tweenTo(scale, 0.12, { Scale = 1 })
			end
		end))
	end

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

		round(ring, 999)
		make("UIStroke", { Color = THEME.text, Thickness = 2, Parent = ring })

		if callback then
			table.insert(connections, button.Activated:Connect(callback))
		end

		return button
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
			TextColor3 = THEME.accentLight,
			TextSize = 10,
			Font = FONT_BOLD,
			ZIndex = 3,
			Parent = row,
		})

		table.insert(connections, mark.Activated:Connect(function()
			showTooltip(mark, tip)
		end))
	end

	local function openColorPicker(anchor, current, onChange)
		local popup = beginPopup(anchor, 148, 124)
		local hue, saturation, value = current:ToHSV()

		local square = make("Frame", {
			Position = UDim2.fromOffset(7, 7),
			Size = UDim2.fromOffset(134, 88),
			BackgroundColor3 = Color3.fromHSV(hue, 1, 1),
			BorderSizePixel = 0,
			ZIndex = 53,
			Parent = popup,
		})

		round(square, 6)

		local white = make("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0,
			ZIndex = 54,
			Parent = square,
		})

		round(white, 6)
		make("UIGradient", { Transparency = NumberSequence.new(0, 1), Parent = white })

		local black = make("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = Color3.new(0, 0, 0),
			BorderSizePixel = 0,
			ZIndex = 55,
			Parent = square,
		})

		round(black, 6)
		make("UIGradient", { Rotation = 90, Transparency = NumberSequence.new(1, 0), Parent = black })

		local marker = make("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.fromOffset(9, 9),
			BackgroundTransparency = 1,
			ZIndex = 57,
			Parent = square,
		})

		round(marker, 999)
		make("UIStroke", { Color = Color3.new(1, 1, 1), Thickness = 2, Parent = marker })

		local bar = make("Frame", {
			Position = UDim2.fromOffset(7, 103),
			Size = UDim2.fromOffset(134, 10),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0,
			ZIndex = 53,
			Parent = popup,
		})

		round(bar, 5)

		local keypoints = {}

		for index = 0, 6 do
			table.insert(keypoints, ColorSequenceKeypoint.new(index / 6, Color3.fromHSV(index / 6, 1, 1)))
		end

		make("UIGradient", { Color = ColorSequence.new(keypoints), Parent = bar })

		local hueMarker = make("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.fromOffset(5, 14),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0,
			ZIndex = 56,
			Parent = bar,
		})

		round(hueMarker, 3)

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

	local function controlBox(parent, position, size)
		local box = make("TextButton", {
			Position = position,
			Size = size,
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0,
			Text = "",
			AutoButtonColor = false,
			Parent = parent,
		})

		round(box, 8)

		make("UIGradient", {
			Color = ColorSequence.new(Color3.fromRGB(36, 36, 43), Color3.fromRGB(24, 24, 29)),
			Rotation = 90,
			Parent = box,
		})

		local stroke = addStroke(box, THEME.line)
		local scale = make("UIScale", { Scale = 1, Parent = box })

		hoverEffect(box, function()
			tweenTo(stroke, 0.12, { Color = THEME.accentDark })
		end, function()
			tweenTo(stroke, 0.12, { Color = THEME.line })
		end)

		return box, stroke, scale
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
		local danger = text == "Unload"
		local row = newRow(self, 26)

		local button = make("TextButton", {
			Size = UDim2.new(1, 0, 1, -3),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0,
			Text = text,
			TextColor3 = danger and THEME.accentLight or THEME.textBright,
			TextSize = 11,
			Font = FONT_BOLD,
			AutoButtonColor = false,
			Parent = row,
		})

		round(button, 8)

		make("UIGradient", {
			Color = danger and ColorSequence.new(Color3.fromRGB(78, 26, 36), Color3.fromRGB(46, 16, 22))
				or ColorSequence.new(Color3.fromRGB(40, 40, 48), Color3.fromRGB(26, 26, 32)),
			Rotation = 90,
			Parent = button,
		})

		local stroke = addStroke(button, danger and THEME.accentDark or THEME.line)
		local scale = make("UIScale", { Scale = 1, Parent = button })

		hoverEffect(button, function()
			tweenTo(stroke, 0.12, { Color = THEME.accent })
		end, function()
			tweenTo(stroke, 0.12, { Color = danger and THEME.accentDark or THEME.line })
		end)

		pressEffect(button, scale)

		if callback then
			table.insert(connections, button.Activated:Connect(callback))
		end

		return button
	end

	function Section:AddToggle(text, default, callback, options)
		options = options or {}

		local toggle = { Value = default == true, Callback = callback, rightOffset = 2 }
		local row = newRow(self, 18)
		local indent = options.indent and 14 or 0
		local trackWidth = 28
		local trackHeight = 15
		local trackX = indent + 2

		local function pill(width, height, transparency, color)
			local frame = make("Frame", {
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.fromOffset(trackX - (width - trackWidth) / 2, 9),
				Size = UDim2.fromOffset(width, height),
				BackgroundColor3 = color,
				BackgroundTransparency = transparency,
				BorderSizePixel = 0,
				Parent = row,
			})

			round(frame, height)

			return frame
		end

		local glowOuter = pill(44, 28, 1, THEME.accent)
		local glowInner = pill(36, 22, 1, THEME.accent)
		local box = pill(trackWidth, trackHeight, 0, Color3.new(1, 1, 1))
		local boxStroke = addStroke(box, THEME.line)

		local boxGradient = make("UIGradient", {
			Color = ColorSequence.new(Color3.fromRGB(38, 38, 45), Color3.fromRGB(26, 26, 31)),
			Rotation = 90,
			Parent = box,
		})

		local knob = make("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 2, 0.5, 0),
			Size = UDim2.fromOffset(11, 11),
			BackgroundColor3 = THEME.text,
			BorderSizePixel = 0,
			ZIndex = 2,
			Parent = box,
		})

		round(knob, 999)

		local button = make("TextButton", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Text = "",
			Parent = row,
		})

		local label = textLabel({
			Position = UDim2.fromOffset(indent + 38, 0),
			Size = UDim2.new(1, -(indent + 38), 1, 0),
			Text = text,
			Parent = row,
		})

		addTooltipMark(row, label, text, options.tooltip)

		function toggle:Set(value, silent)
			self.Value = value

			boxGradient.Color = value and ColorSequence.new(THEME.accentLight, THEME.accent) or ColorSequence.new(Color3.fromRGB(38, 38, 45), Color3.fromRGB(26, 26, 31))
			boxStroke.Color = value and THEME.accent or THEME.line
			label.TextColor3 = value and THEME.textBright or THEME.text

			tweenTo(knob, 0.16, {
				Position = UDim2.new(0, value and 15 or 2, 0.5, 0),
				BackgroundColor3 = value and Color3.new(1, 1, 1) or THEME.text,
			}, Enum.EasingStyle.Back)

			tweenTo(glowOuter, 0.2, { BackgroundTransparency = value and 0.9 or 1 })
			tweenTo(glowInner, 0.2, { BackgroundTransparency = value and 0.74 or 1 })

			if not silent and self.Callback then
				task.spawn(self.Callback, value)
			end
		end

		function toggle:AddKeybind(default)
			local bind = { Key = nil }

			local keyButton = make("TextButton", {
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -self.rightOffset, 0.5, 0),
				Size = UDim2.fromOffset(44, 15),
				BackgroundColor3 = THEME.control,
				BorderSizePixel = 0,
				Text = "Bind",
				TextColor3 = THEME.text,
				TextSize = 9,
				Font = FONT_BOLD,
				AutoButtonColor = false,
				ZIndex = 3,
				Parent = row,
			})

			round(keyButton, 7)
			addStroke(keyButton, THEME.line)

			self.rightOffset += 48

			local function describe(key)
				if typeof(key) == "EnumItem" then
					return key.Name
				end

				return "Bind"
			end

			function bind:Set(key)
				self.Key = key
				keyButton.Text = describe(key)
				keyButton.TextColor3 = key and THEME.accentLight or THEME.text
			end

			bind.Toggle = toggle
			bind.Button = keyButton
			bind.Describe = describe
			table.insert(binds, bind)
			table.insert(keybindRegistry, { label = text .. " Key", bind = bind })

			table.insert(connections, keyButton.Activated:Connect(function()
				listeningBind = bind
				keyButton.Text = "..."
			end))

			if default then
				bind:Set(default)
			end

			return self
		end

		function toggle:AddColor(default, onChange)
			local color = default or THEME.accent

			local swatch = make("TextButton", {
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -self.rightOffset, 0.5, 0),
				Size = UDim2.fromOffset(26, 12),
				BackgroundColor3 = color,
				BorderSizePixel = 0,
				Text = "",
				AutoButtonColor = false,
				ZIndex = 3,
				Parent = row,
			})

			round(swatch, 6)
			addStroke(swatch, THEME.line)
			self.rightOffset += 30

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
		local row = newRow(self, 32)
		local trackInset = options.gear and 18 or 0

		local label = textLabel({
			Position = UDim2.fromOffset(2, 0),
			Size = UDim2.new(1, -70, 0, 16),
			Text = text,
			TextColor3 = THEME.textBright,
			Parent = row,
		})

		local chip = make("Frame", {
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -trackInset - 2, 0, 0),
			Size = UDim2.fromOffset(54, 15),
			BackgroundColor3 = THEME.control,
			BorderSizePixel = 0,
			Parent = row,
		})

		round(chip, 8)

		local valueLabel = textLabel({
			Size = UDim2.fromScale(1, 1),
			TextColor3 = THEME.accentLight,
			TextSize = 10,
			Font = FONT_BOLD,
			TextXAlignment = Enum.TextXAlignment.Center,
			Parent = chip,
		})

		addTooltipMark(row, label, text, options.tooltip)

		local track = make("Frame", {
			Position = UDim2.fromOffset(4, 23),
			Size = UDim2.new(1, -8 - trackInset, 0, 5),
			BackgroundColor3 = THEME.control,
			BorderSizePixel = 0,
			Parent = row,
		})

		round(track, 3)

		local fill = make("Frame", {
			Size = UDim2.fromScale(0, 1),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0,
			Parent = track,
		})

		round(fill, 3)

		make("UIGradient", {
			Color = ColorSequence.new(THEME.accentDark, THEME.accentLight),
			Parent = fill,
		})

		local glow = make("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.fromOffset(20, 20),
			BackgroundColor3 = THEME.accent,
			BackgroundTransparency = 0.78,
			BorderSizePixel = 0,
			Parent = track,
		})

		round(glow, 999)

		local thumb = make("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.fromOffset(12, 12),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0,
			ZIndex = 2,
			Parent = track,
		})

		round(thumb, 999)
		make("UIStroke", { Color = THEME.accent, Thickness = 2, Parent = thumb })

		local hit = make("TextButton", {
			Position = UDim2.fromOffset(0, 14),
			Size = UDim2.new(1, -trackInset, 0, 18),
			BackgroundTransparency = 1,
			Text = "",
			Parent = row,
		})

		local function render(animate)
			local fraction = (slider.Value - minimum) / (maximum - minimum)
			local fillGoal = UDim2.fromScale(fraction, 1)
			local thumbGoal = UDim2.new(fraction, 0, 0.5, 0)

			if animate then
				tweenTo(fill, 0.08, { Size = fillGoal })
				tweenTo(thumb, 0.08, { Position = thumbGoal })
				tweenTo(glow, 0.08, { Position = thumbGoal })
			else
				fill.Size = fillGoal
				thumb.Position = thumbGoal
				glow.Position = thumbGoal
			end

			if options.disabledAtMin and slider.Value <= minimum then
				valueLabel.Text = "Off"
			else
				valueLabel.Text = tostring(slider.Value) .. (options.suffix or "")
			end
		end

		function slider:Set(value, silent)
			local factor = 10 ^ rounding
			value = math.clamp(math.floor(value * factor + 0.5) / factor, minimum, maximum)
			self.Value = value
			render(false)

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
				local factor = 10 ^ rounding
				local value = math.clamp(math.floor((minimum + (maximum - minimum) * fraction) * factor + 0.5) / factor, minimum, maximum)

				slider.Value = value
				render(true)

				if slider.Callback then
					task.spawn(slider.Callback, value)
				end
			end

			tweenTo(thumb, 0.1, { Size = UDim2.fromOffset(15, 15) })
			tweenTo(glow, 0.1, { Size = UDim2.fromOffset(28, 28), BackgroundTransparency = 0.65 })

			activeDrag = update
			activeEnd = function()
				tweenTo(thumb, 0.12, { Size = UDim2.fromOffset(12, 12) })
				tweenTo(glow, 0.12, { Size = UDim2.fromOffset(20, 20), BackgroundTransparency = 0.78 })
			end

			update(input)
		end))

		if options.gear then
			makeGear(row, UDim2.new(1, -14, 0, 16), options.gear)
		end

		slider:Set(default, true)

		return slider
	end

	function Section:AddDropdown(text, values, default, callback, options)
		options = options or {}

		local multi = options.multi == true
		local dropdown = { Callback = callback, Values = values }
		local row = newRow(self, 40)
		local boxInset = options.gear and 18 or 0

		dropdown.Value = multi and {} or default

		if multi and type(default) == "table" then
			for _, name in next, default do
				dropdown.Value[name] = true
			end
		end

		local label = textLabel({
			Position = UDim2.fromOffset(2, 0),
			Size = UDim2.new(1, -4, 0, 15),
			Text = text,
			TextColor3 = THEME.textBright,
			Parent = row,
		})

		addTooltipMark(row, label, text, options.tooltip)

		local box, boxStroke = controlBox(row, UDim2.fromOffset(0, 18), UDim2.new(1, -boxInset, 0, 21))

		local valueLabel = textLabel({
			Position = UDim2.fromOffset(8, 0),
			Size = UDim2.new(1, -26, 1, 0),
			TextSize = 10,
			TextColor3 = THEME.textBright,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = box,
		})

		local arrow = make("Frame", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -6, 0.5, 0),
			Size = UDim2.fromOffset(12, 12),
			BackgroundTransparency = 1,
			Parent = box,
		})

		makeIcon(arrow, multi and "plus" or "chevron", THEME.accentLight, 10, UDim2.fromOffset(1, 1))

		local function describe()
			if not multi then
				return tostring(dropdown.Value or "Select...")
			end

			local names = {}

			for _, name in next, values do
				if dropdown.Value[name] then
					table.insert(names, name)
				end
			end

			return #names > 0 and table.concat(names, ", ") or "None"
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

			if rows == 0 then
				return
			end

			tweenTo(arrow, 0.15, { Rotation = 180 })
			tweenTo(boxStroke, 0.15, { Color = THEME.accent })

			local popup = beginPopup(box, box.AbsoluteSize.X, rows * 20 + 6, function()
				tweenTo(arrow, 0.15, { Rotation = 0 })
				tweenTo(boxStroke, 0.15, { Color = THEME.line })
			end)

			local scroll = make("ScrollingFrame", {
				Position = UDim2.fromOffset(3, 3),
				Size = UDim2.new(1, -6, 1, -6),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				ScrollBarThickness = 2,
				ScrollBarImageColor3 = THEME.accent,
				CanvasSize = UDim2.new(),
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				ZIndex = 53,
				Parent = popup,
			})

			make("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = scroll })

			local items = {}
			local marks = {}

			local function paint()
				for name, item in next, items do
					local selected = multi and dropdown.Value[name] or (not multi and dropdown.Value == name)

					item.TextColor3 = selected and THEME.accentLight or THEME.text
					item.BackgroundTransparency = selected and 0.88 or 1
					marks[name].Visible = selected and true or false
				end
			end

			for index, name in next, values do
				local item = make("TextButton", {
					Size = UDim2.new(1, 0, 0, 20),
					BackgroundColor3 = THEME.accent,
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Text = name,
					TextColor3 = THEME.text,
					TextSize = 10,
					Font = FONT,
					TextXAlignment = Enum.TextXAlignment.Left,
					AutoButtonColor = false,
					LayoutOrder = index,
					ZIndex = 54,
					Parent = scroll,
				})

				round(item, 6)
				make("UIPadding", { PaddingLeft = UDim.new(0, 18), Parent = item })

				local mark = make("Frame", {
					AnchorPoint = Vector2.new(0, 0.5),
					Position = UDim2.new(0, -10, 0.5, 0),
					Size = UDim2.fromOffset(5, 5),
					BackgroundColor3 = THEME.accentLight,
					BorderSizePixel = 0,
					Visible = false,
					ZIndex = 55,
					Parent = item,
				})

				round(mark, 999)
				items[name] = item
				marks[name] = mark

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
			makeGear(row, UDim2.new(1, -14, 0, 21), options.gear)
		end

		dropdown:Set(dropdown.Value, true)

		return dropdown
	end

	function Section:AddInput(text, default, callback, placeholder)
		local input = { Value = tostring(default or ""), Callback = callback }
		local row = newRow(self, 40)

		textLabel({
			Position = UDim2.fromOffset(2, 0),
			Size = UDim2.new(1, -4, 0, 15),
			Text = text,
			TextColor3 = THEME.textBright,
			Parent = row,
		})

		local holder = make("Frame", {
			Position = UDim2.fromOffset(0, 18),
			Size = UDim2.new(1, 0, 0, 21),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0,
			Parent = row,
		})

		round(holder, 8)

		make("UIGradient", {
			Color = ColorSequence.new(Color3.fromRGB(36, 36, 43), Color3.fromRGB(24, 24, 29)),
			Rotation = 90,
			Parent = holder,
		})

		local stroke = addStroke(holder, THEME.line)

		local box = make("TextBox", {
			Position = UDim2.fromOffset(8, 0),
			Size = UDim2.new(1, -16, 1, 0),
			BackgroundTransparency = 1,
			Text = input.Value,
			PlaceholderText = placeholder or "",
			PlaceholderColor3 = THEME.text,
			TextColor3 = THEME.textBright,
			TextSize = 10,
			Font = FONT,
			TextXAlignment = Enum.TextXAlignment.Left,
			ClearTextOnFocus = false,
			Parent = holder,
		})

		function input:Set(value, silent)
			self.Value = tostring(value)
			box.Text = self.Value

			if not silent and self.Callback then
				task.spawn(self.Callback, self.Value)
			end
		end

		table.insert(connections, box.Focused:Connect(function()
			tweenTo(stroke, 0.15, { Color = THEME.accent })
		end))

		table.insert(connections, box.FocusLost:Connect(function()
			tweenTo(stroke, 0.15, { Color = THEME.line })
			input:Set(box.Text)
		end))

		return input
	end

	function Section:AddColor(text, default, callback)
		local color = default or THEME.accent
		local row = newRow(self, 18)

		textLabel({
			Position = UDim2.fromOffset(2, 0),
			Size = UDim2.new(1, -36, 1, 0),
			Text = text,
			Parent = row,
		})

		local swatch = make("TextButton", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -2, 0.5, 0),
			Size = UDim2.fromOffset(28, 13),
			BackgroundColor3 = color,
			BorderSizePixel = 0,
			Text = "",
			AutoButtonColor = false,
			Parent = row,
		})

		round(swatch, 7)

		local stroke = addStroke(swatch, THEME.line)

		hoverEffect(swatch, function()
			tweenTo(stroke, 0.12, { Color = THEME.textBright })
		end, function()
			tweenTo(stroke, 0.12, { Color = THEME.line })
		end)

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
		local row = newRow(self, 18)

		textLabel({
			Position = UDim2.fromOffset(2, 0),
			Size = UDim2.new(1, -80, 1, 0),
			Text = text,
			Parent = row,
		})

		local keyButton = make("TextButton", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -2, 0.5, 0),
			Size = UDim2.fromOffset(76, 16),
			BackgroundColor3 = THEME.control,
			BorderSizePixel = 0,
			Text = "",
			TextColor3 = THEME.accentLight,
			TextSize = 9,
			Font = FONT_BOLD,
			AutoButtonColor = false,
			Parent = row,
		})

		round(keyButton, 8)
		addStroke(keyButton, THEME.line)

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
		table.insert(keybindRegistry, { label = text, bind = bind })

		return bind
	end

	local Tab = {}
	Tab.__index = Tab

	function Tab:AddSection(name, column)
		local holderColumn = self.columns[column or 1]

		local frame = make("Frame", {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0,
			Parent = holderColumn,
		})

		round(frame, 12)
		addStroke(frame, THEME.line)

		make("UIGradient", {
			Color = ColorSequence.new(Color3.fromRGB(28, 28, 34), Color3.fromRGB(18, 18, 22)),
			Rotation = 90,
			Parent = frame,
		})

		textLabel({
			Position = UDim2.fromOffset(10, 0),
			Size = UDim2.new(1, -20, 0, 28),
			Text = name,
			TextColor3 = THEME.textBright,
			Font = FONT_BOLD,
			TextSize = 11,
			Parent = frame,
		})

		local line = make("Frame", {
			Position = UDim2.fromOffset(8, 28),
			Size = UDim2.new(1, -16, 0, 1),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0,
			Parent = frame,
		})

		make("UIGradient", {
			Color = ColorSequence.new(THEME.accent, THEME.accentDark),
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.1),
				NumberSequenceKeypoint.new(1, 1),
			}),
			Parent = line,
		})

		local holder = make("Frame", {
			Position = UDim2.fromOffset(0, 30),
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			Parent = frame,
		})

		make("UIListLayout", {
			Padding = UDim.new(0, 5),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = holder,
		})

		make("UIPadding", {
			PaddingTop = UDim.new(0, 5),
			PaddingBottom = UDim.new(0, 9),
			PaddingLeft = UDim.new(0, 8),
			PaddingRight = UDim.new(0, 8),
			Parent = holder,
		})

		return setmetatable({ holder = holder }, Section)
	end

	local tabs = {}

	local function selectTab(tab)
		closePopup()

		for _, other in next, tabs do
			local active = other == tab

			other.content.Visible = active
			tweenTo(other.bar, 0.18, { Size = UDim2.new(0, 3, active and 1 or 0, active and -10 or 0) })
			tweenTo(other.background, 0.18, { BackgroundTransparency = active and 0.78 or 1 })
			other.label.TextColor3 = active and THEME.textBright or THEME.text
		end
	end

	local function addTab(name)
		local tab = setmetatable({}, Tab)

		tab.button = make("TextButton", {
			Size = UDim2.new(1, 0, 0, 30),
			BackgroundTransparency = 1,
			Text = "",
			AutoButtonColor = false,
			LayoutOrder = #tabs + 1,
			Parent = sidebar,
		})

		tab.background = make("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Parent = tab.button,
		})

		round(tab.background, 9)

		make("UIGradient", {
			Color = ColorSequence.new(THEME.accent, THEME.accentDark),
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(1, 1),
			}),
			Parent = tab.background,
		})

		tab.bar = make("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 0, 0.5, 0),
			Size = UDim2.new(0, 3, 0, 0),
			BackgroundColor3 = THEME.accentLight,
			BorderSizePixel = 0,
			Parent = tab.button,
		})

		round(tab.bar, 2)

		tab.label = textLabel({
			Position = UDim2.fromOffset(14, 0),
			Size = UDim2.new(1, -16, 1, 0),
			Text = name,
			TextColor3 = THEME.text,
			Font = FONT_BOLD,
			TextSize = 11,
			Parent = tab.button,
		})

		tab.content = make("ScrollingFrame", {
			Position = UDim2.fromOffset(SIDEBAR_W + 9, 48),
			Size = UDim2.new(1, -(SIDEBAR_W + 17), 1, -56),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = 3,
			ScrollBarImageColor3 = THEME.accent,
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

		hoverEffect(tab.button, function()
			if tab.content.Visible == false then
				tweenTo(tab.background, 0.12, { BackgroundTransparency = 0.92 })
			end
		end, function()
			if tab.content.Visible == false then
				tweenTo(tab.background, 0.12, { BackgroundTransparency = 1 })
			end
		end)

		table.insert(connections, tab.button.Activated:Connect(function()
			selectTab(tab)
		end))

		table.insert(tabs, tab)

		return tab
	end

	local function setMenuVisible(visible)
		root.Visible = visible

		if visible then
			dim.Visible = true
			windowScale.Scale = 0.94
			tweenTo(windowScale, 0.3, { Scale = 1 }, Enum.EasingStyle.Back)
			tweenTo(dim, 0.25, { BackgroundTransparency = 0.5 })

			if blur then
				tweenTo(blur, 0.3, { Size = 10 })
			end
		else
			closePopup()
			tweenTo(dim, 0.25, { BackgroundTransparency = 1 })

			if blur then
				tweenTo(blur, 0.25, { Size = 0 })
			end

			task.delay(0.25, function()
				if not root.Visible then
					dim.Visible = false
				end
			end)
		end
	end

	local menuButton = make("TextButton", {
		Name = "MenuButton",
		Position = UDim2.new(0, 12, 0.5, -22),
		Size = UDim2.fromOffset(44, 44),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		Text = "M",
		TextColor3 = Color3.new(1, 1, 1),
		TextSize = 19,
		Font = FONT_BOLD,
		AutoButtonColor = false,
		Active = true,
		ZIndex = 5,
		Parent = gui,
	})

	round(menuButton, 999)

	make("UIGradient", {
		Color = ColorSequence.new(THEME.accentLight, Color3.fromRGB(150, 30, 48)),
		Rotation = 45,
		Parent = menuButton,
	})

	addStroke(menuButton, Color3.fromRGB(255, 160, 175)).Thickness = 1.5

	local pulse = make("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = THEME.accent,
		BackgroundTransparency = 0.6,
		BorderSizePixel = 0,
		ZIndex = 4,
		Parent = menuButton,
	})

	round(pulse, 999)

	tweenService:Create(pulse, TweenInfo.new(1.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, -1, false), {
		Size = UDim2.fromScale(1.7, 1.7),
		BackgroundTransparency = 1,
	}):Play()

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
				setMenuVisible(not root.Visible)
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
			setMenuVisible(not root.Visible)
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
		Padding = UDim.new(0, 5),
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

		local toast = make("Frame", {
			Size = UDim2.new(0, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundColor3 = Color3.new(1, 1, 1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LayoutOrder = toastOrder,
			ZIndex = 81,
			Parent = toastHolder,
		})

		round(toast, 10)

		make("UIGradient", {
			Color = ColorSequence.new(Color3.fromRGB(34, 20, 26), Color3.fromRGB(16, 16, 20)),
			Rotation = 90,
			Parent = toast,
		})

		local stroke = addStroke(toast, THEME.accent)
		stroke.Transparency = 1

		make("UIPadding", {
			PaddingLeft = UDim.new(0, 26),
			PaddingRight = UDim.new(0, 12),
			PaddingTop = UDim.new(0, 6),
			PaddingBottom = UDim.new(0, 6),
			Parent = toast,
		})

		make("UISizeConstraint", { MaxSize = Vector2.new(320, 120), Parent = toast })

		local dot = make("Frame", {
			Position = UDim2.fromOffset(-16, 6),
			Size = UDim2.fromOffset(7, 7),
			BackgroundColor3 = THEME.accentLight,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ZIndex = 82,
			Parent = toast,
		})

		round(dot, 999)

		local message = textLabel({
			Size = UDim2.new(0, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.XY,
			Text = text,
			TextColor3 = THEME.textBright,
			TextTransparency = 1,
			TextWrapped = true,
			ZIndex = 82,
			Parent = toast,
		})

		tweenTo(toast, 0.25, { BackgroundTransparency = 0.05 })
		tweenTo(stroke, 0.25, { Transparency = 0.4 })
		tweenTo(dot, 0.25, { BackgroundTransparency = 0 })
		tweenTo(message, 0.25, { TextTransparency = 0 })

		task.delay(4, function()
			if not toast.Parent then
				return
			end

			tweenTo(toast, 0.3, { BackgroundTransparency = 1 })
			tweenTo(stroke, 0.3, { Transparency = 1 })
			tweenTo(dot, 0.3, { BackgroundTransparency = 1 })
			tweenTo(message, 0.3, { TextTransparency = 1 })

			task.delay(0.35, function()
				toast:Destroy()
			end)
		end)

		return true
	end

	local ui = {
		gui = gui,
		window = window,
		tabs = tabs,
		connections = connections,
		addTab = addTab,
		selectTab = selectTab,
		setMenuVisible = setMenuVisible,
		menuButton = menuButton,
		menuHome = menuButton.Position,
		keybindRegistry = keybindRegistry,
		setMenuKey = function(key)
			menuKey = key
		end,
		setMenuLocked = function(value)
			menuLocked = value
		end,
		getMenuLocked = function()
			return menuLocked
		end,
	}

	function ui.destroy()
		for _, connection in next, connections do
			connection:Disconnect()
		end

		if blur then
			blur:Destroy()
			blur = nil
		end

		gui:Destroy()
	end

	return ui
end


-- GUI-only startup: original gameplay/action logic has been removed.
local ui = createUi("GUI only", "gui")

local home = ui.addTab("Home")
local homeSection = home:AddSection("GUI Only", 1)
homeSection:AddLabel("Magma interface loaded.", {})
homeSection:AddLabel("Gameplay actions have been removed.", {})

local settings = ui.addTab("Settings")
local settingsSection = settings:AddSection("Interface", 1)
settingsSection:AddToggle("Show notifications", true, function(value)
    -- Placeholder setting; no gameplay behavior is attached.
    ui.showNotifications = value
end)
settingsSection:AddButton("Reset menu position", function()
    ui.menuButton.Position = ui.menuHome
end)
settingsSection:AddButton("Unload GUI", function()
    ui.destroy()
end)

ui.selectTab(home)

-- Close the GUI and disconnect its event handlers when the script is unloaded.
if type(shared) == "table" then shared.MagmaGuiOnly = ui end
