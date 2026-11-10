local module = {}

local RunService = game:GetService("RunService")
local IsServer = RunService:IsServer()

self = module

if IsServer then
	script:Destroy()
	return module
end

local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local DefaultGui = script:WaitForChild("Gui")

local NewGui = nil

local MenusList = {}
local NextOrderMenu = 0
local NextOrderOption = 0

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local Sounds = script:WaitForChild("Sounds")
local Templates = script:WaitForChild("Templates")
local ButtonTemplate = Templates:WaitForChild("Button")
local OptionsTemplate = Templates:WaitForChild("Options")
local MenuButtonTemplate = Templates:WaitForChild("ButtonMenu")
local TextBoxTemplate = Templates:WaitForChild("TextBoxFrame")
local ToggleTemplate = Templates:WaitForChild("ToggleFrame")

local function SetDefaultValues()
	MenusList = {}
	NextOrderMenu = 0
	NextOrderOption = 0
end

local function SetMenu(Object: Instance, MenuName: string)
	
	if not Object then
		warn("Object is nil")
		return
	end
	
	if MenuName == nil then
		warn("MenuName must be a string")
		return
	end

	local Menu = module:GetMenu(MenuName)

	if not Menu then
		warn("Menu not found")
		return
	end

	local Option = Menu.Options

	Object.Parent = Option
end

function module:GetMenu(Name: string)
	
	if Name == nil then
		warn("Name is nil")
		return
	end
	
	for _, Menu in pairs(MenusList) do
		local MenuName = Menu.Button.Name
		if MenuName:lower() == Name:lower() then
			return Menu
		end
	end
	
end

function module:PlayDefaultSound(SoundName)
	
	local Sound = Sounds:WaitForChild(SoundName)
	
	if not Sound then return end
	
	Sound:Play()
	
end

function module:Notify(Title: string, Description: string, Duration: number, ButtonName: string, CallBack: any)
	
	if Title == nil then
		warn("Title is nil")
		return
	end
	
	if Description == nil then
		warn("Description is nil")
		return
	end
	
	if Duration == nil then
		Duration = 3
	end
	
	local Callback = Instance.new("BindableFunction")

	Callback.OnInvoke = function(Button)
		
		module:PlayDefaultSound("Click")
		
		if Button == ButtonName then
			
			if typeof(CallBack) == "function" then
				CallBack(Button)
			else
				warn("Callback is not a function")
			end
		
		end
		
		Callback:Destroy()
		
	end
	
	module:PlayDefaultSound("Notify")
	
	local Config = {
		Title = tostring(Title),
		Text = tostring(Description),
		Duration = Duration,
		Button2 = "Close",

		Callback = Callback,

	}
	
	if ButtonName then
		Config.Button1 = tostring(ButtonName)
	else
		Config.Button2 = nil
		Config.Button1 = "Close"
	end
	
	StarterGui:SetCore("SendNotification", Config)
	
	task.delay(Duration, function()
		if not Callback then return end
		if not Callback.Parent then return end
		Callback:Destroy()
	end)
	
end

function module.new(ResetGui: boolean)
	
	if ResetGui == nil then
		ResetGui = true
	end
	
	if ResetGui then
		SetDefaultValues()
		if NewGui then
			NewGui:Destroy()
		end
	end
	
	local Functions = {}
	
	local Gui = NewGui
	
	if ResetGui then
		Gui = DefaultGui:Clone()
	else
		Gui = NewGui
		if not Gui then
			Gui = DefaultGui:Clone()
		end
	end
	
	Gui.Parent = PlayerGui
	
	local Main = Gui:WaitForChild("Main")
	local TopBar = Main:WaitForChild("TopBar")
	local Title = TopBar:WaitForChild("Title")
	local CloseButton = TopBar:WaitForChild("CloseButton")
	local Button = Gui:WaitForChild("Button")
	
	local OpenAnimation = TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, 0, 0.5, 0)})
	local CloseAnimation = TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Position = UDim2.new(0.5, 0, -0.5, 0)})
	
	local function ActivateButton()
		module:PlayDefaultSound("Click")
		if not ResetGui then return end
		Functions:SetEnabled(not Functions:IsEnabled(), true)
	end
	
	CloseButton.Activated:Connect(ActivateButton)
	Button.Activated:Connect(ActivateButton)
	
	NewGui = Gui
	
	function Functions:SetTitle(Text: string?)
		
		if Text == nil then
			warn("Text must be a string")
			return Functions
		end
		
		if not Title then
			warn("Title not found")
			return Functions
		end
		
		Title.Text = Text
		return Functions
	end
	
	function Functions:SetEnabled(Enabled: boolean, PlayAnimation: boolean)
		
		if type(Enabled) ~= "boolean" then
			warn("Enabled must be a boolean")
			return Functions
		end
		
		if PlayAnimation == nil then
			PlayAnimation = true
		end
		
		if type(PlayAnimation) ~= "boolean" then
			warn("PlayAnimation must be a boolean")
			return Functions
		end
		
		if Enabled then
			Main.Position = UDim2.new(0.5, 0, 0.5, 0)
		else
			Main.Position = UDim2.new(0.5, 0, -0.5, 0)
		end
		
		if PlayAnimation then
			Main.Visible = true
			if Enabled then
				OpenAnimation:Play()
			else
				CloseAnimation:Play()
				CloseAnimation.Completed:Wait()
				Main.Visible = false
			end
		else
			Main.Visible = Enabled
		end
		
		return Functions
	end
	
	function Functions:IsEnabled(): boolean
		return Main.Visible
	end
	
	function Functions:Get(): ScreenGui
		return Gui
	end
	
	if ResetGui then
		Functions:SetEnabled(false, false)
	end
	
	Functions:SetTitle("Menu")
	
	return Functions
end

function module:Menu()
	
	local Functions = {}
	
	local GuiFunctions = module.new(false)
	local Gui = GuiFunctions:Get()
	local Main = Gui:WaitForChild("Main")
	local Menus = Main:WaitForChild("Menus")
	local OptionsFolder = Main:WaitForChild("Options")
	
	local Menu = MenuButtonTemplate:Clone()
	local Options = OptionsTemplate:Clone()
	
	function Functions:SetName(Name: string)
		
		if Name == nil then
			warn("Name must be a string")
			return Functions
		end
		
		local Final = tostring(Name)
		
		Options.Name = Final
		Menu.Name = Final
		
		return Functions
		
	end
	
	function Functions:GetMenuName()
		return Options.Name
	end
	
	function Functions:SetTitle(Text: string?)
		
		if Text == nil then
			warn("Text must be a string")
			return Functions
		end
		
		local Final = tostring(Text)
		
		Menu.Text = Final
		return Functions
	end
	
	function Functions:SetEnabled()
		
		Options.Visible = true
		
		for _, Option in OptionsFolder:GetChildren() do
			if not Option:IsA("ScrollingFrame") or Option == Options then continue end
			
			Option.Visible = false
			
		end
		
		return Functions
	end
	
	function Functions:Disable()
		Menu:Destroy()
		return Functions
	end
	
	function Functions:SetOrder(Order: number)
		
		if type(Order) ~= "number" then
			warn("Order must be a number")
			return Functions
		end
		
		Options.LayoutOrder = Order
		return Functions
	end
	
	Functions:SetName("Unknown")
	Functions:SetTitle("Unknown")
	
	Menu.Parent = Menus
	Options.Parent = OptionsFolder
	
	if #MenusList == 0 then
		Options.Visible = true
	else
		Options.Visible = false
	end
	
	Menu.LayoutOrder = NextOrderMenu + 1
	NextOrderMenu += 1
	
	Menu.Activated:Connect(function()
		module:PlayDefaultSound("Click")
		Functions:SetEnabled()
	end)
	
	local Data = {
		Button = Menu,
		Options = Options,
		Functions = Functions
	}
	
	table.insert(MenusList, Data)
	
	return Functions
end

function module:Button()
	
	local Functions = {}
	
	local ActivedFunction = nil
	
	local GuiFunctions = module.new(false)
	local Gui = GuiFunctions:Get()
	
	local Main = Gui:WaitForChild("Main")
	local Options = Main:WaitForChild("Options")
	
	local Button = ButtonTemplate:Clone()
	
	function Functions:SetTitle(Text: string?)
		
		if Text == nil then
			warn("Text must be a string")
			return Functions
		end
		
		local Final = tostring(Text)
		
		Button.Name = Final
		Button.Text = Final
		
		return Functions
		
	end
	
	function Functions:SetEnabled(Enabled: boolean)
		
		if type(Enabled) ~= "boolean" then
			warn("Enabled must be a boolean")
			return Functions
		end
		
		Button.Visible = Enabled
		
		return Functions
		
	end
	
	function Functions:BindFunction(Function: any)
		
		if type(Function) ~= "function" then
			warn("Function must be a function")
			return Functions
		end
		
		ActivedFunction = Function
		
		return Functions
		
	end
	
	function Functions:SetMenu(MenuName: string)
		
		SetMenu(Button, MenuName)
		
		return Functions
		
	end
	
	function Functions:Disable()
		Button:Destroy()
		return Functions
	end
	
	function Functions:Get()
		return Button
	end
	
	Functions:SetTitle("Unknown")
	
	Button.LayoutOrder = NextOrderOption
	NextOrderOption += 1
	
	Button.Activated:Connect(function()
		
		module:PlayDefaultSound("Click")
		
		if ActivedFunction then
			ActivedFunction()
		end
		
	end)
	
	return Functions
end

function module:TextBox()
	
	local Functions = {}
	local ActivedFunction = nil
	
	local TextBoxFrame = TextBoxTemplate:Clone()
	local Title = TextBoxFrame:WaitForChild("Title")
	local TextBox = TextBoxFrame:WaitForChild("TextBox")
	
	function Functions:SetTitle(Text: string?)
		
		if Text == nil then
			warn("Text must be a string")
			return Functions
		end
		
		Title.Text = tostring(Text)
		
		return Functions
		
	end
	
	function Functions:SetEnabled(Enabled: boolean)
		
		if type(Enabled) ~= "boolean" then
			warn("Enabled must be a boolean")
			return Functions
		end
		
		TextBoxFrame.Visible = Enabled
		
		return Functions
		
	end
	
	function Functions:GetText()
		return TextBox.Text
	end
	
	function Functions:SetText(Text: string?)
		
		if Text == nil then
			warn("Text must be a string")
			return Functions
		end
		
		TextBox.Text = tostring(Text)
		
		return Functions
	end
	
	function Functions:SetPlaceholderText(Text: string?)
		
		if Text == nil then
			warn("Text must be a string")
			return
		end
		
		TextBox.PlaceholderText = tostring(Text)
		
		return Functions
		
	end
	
	function Functions:BindFunction(Function: any)
		
		if type(Function) ~= "function" then
			warn("Function must be a function")
			return Functions
		end
		
		ActivedFunction = Function
		
		return Functions
	end
	
	function Functions:Disable()
		TextBoxFrame:Destroy()
		return Functions
	end
	
	function Functions:SetMenu(MenuName: string)
		
		SetMenu(TextBoxFrame, MenuName)
		
		return Functions
	end
	
	function Functions:Get()
		return TextBoxFrame
	end
	
	Functions:SetPlaceholderText("Unknown")
	Functions:SetText("Unknown")
	Functions:SetTitle("Unknown")
	
	TextBoxFrame.LayoutOrder = NextOrderOption
	NextOrderOption += 1
	
	TextBox.FocusLost:Connect(function(enterPressed)
		
		if not enterPressed then return end
		
		if ActivedFunction then
			ActivedFunction(TextBox.Text)
		end
		
	end)
	
	return Functions
end

function module:Toggle()
	
	local Functions = {}
	local ActivedFunction = nil
	
	local ToggleFrame = ToggleTemplate:Clone()
	local Title = ToggleFrame:WaitForChild("Title")
	local Toggle = ToggleFrame:WaitForChild("Toggle")
	local ToggleButton = Toggle:WaitForChild("Button")
	
	local ToggleColorRed = TweenService:Create(Toggle, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(170, 0, 0)})
	local ToggleColorGreen = TweenService:Create(Toggle, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(0, 170, 0)})
	
	local ToggleButtonOff = TweenService:Create(ToggleButton, TweenInfo.new(0.1), {Position = UDim2.new(0.2, 0, 0.5, 0)})
	local ToggleButtonOn = TweenService:Create(ToggleButton, TweenInfo.new(0.1), {Position = UDim2.new(0.8, 0, 0.5, 0)})
	
	local ToggleState = false
	
	function Functions:SetTitle(Text: string?)
		
		if Text == nil then
			warn("Text must be a string")
			return Functions
		end
		
		Title.Text = tostring(Text)
		
		return Functions
		
	end
	
	function Functions:SetEnabled(Enabled: boolean)
		
		if type(Enabled) ~= "boolean" then
			warn("Enabled must be a boolean")
			return Functions
		end
		
		ToggleFrame.Visible = Enabled
		
		return Functions
		
	end
	
	function Functions:SetState(State: boolean)
		
		if type(State) ~= "boolean" then
			warn("State must be a boolean")
			return Functions
		end
		
		ToggleState = State
		
		if State then
			ToggleColorGreen:Play()
			ToggleButtonOn:Play()
		else
			ToggleColorRed:Play()
			ToggleButtonOff:Play()
		end
		
		return Functions
		
	end
	
	function Functions:GetState()
		return ToggleState
	end
	
	function Functions:BindFunction(Function: any)
		
		if type(Function) ~= "function" then
			warn("Function must be a function")
			return Functions
		end
		
		ActivedFunction = Function
		
		return Functions
	end
	
	function Functions:SetMenu(MenuName: string)
		
		SetMenu(ToggleFrame, MenuName)
		
		return Functions
	end
	
	function Functions:Disable()
		ToggleFrame:Destroy()
		return Functions
	end
	
	function Functions:Get()
		return ToggleFrame
	end
	
	Functions:SetTitle("Unknown")
	
	ToggleFrame.LayoutOrder = NextOrderOption
	NextOrderOption += 1
	
	Toggle.Activated:Connect(function()
		
		module:PlayDefaultSound("Click")
		
		Functions:SetState(not ToggleState)
		
		if ActivedFunction then
			ActivedFunction(ToggleState)
		end
		
	end)
	
	return Functions
end

return module
