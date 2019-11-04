-- by DJTB
-- v1.0 (2019-04-11)
-- Read LICENSE before making changes

surface.CreateFont("ErrorFont", {
	font = "Open Sans",
	size = 500,
	weight = 1000,
	antialias = true,
	scanlines = 2.5,
})

surface.CreateFont("ErrorFontBlurred", {
	font = "Open Sans",
	size = 500,
	weight = 1000,
	antialias = true,
	blursize = 10
})

local str = "ERROR"
local head = ""
local forcealpha

local texts = {
	[0] = "Developer mode activated",
	[.25] = "",
	[.5] = "> An unkown error occured",
	[1] = "> Code : 0xFFF",
	[4] = "> Waiting for a fix...",
	[6] = "> Hotfix found ! Delete hl2.exe",
	[7] = "> Insuffisant access, self-assign admin rights",
	[7.5] = "> Complete",
	[10] = "> hl2.exe has been deleted !",
	[15] = "> Say goodbye to this server",
	[18] = "> You're not welcome here"
}

local tcolor = Color(0, 200, 0, 240)
local function create(s)
	MsgC(string.rep("\n", 1024))
	local start = CurTime()
	local len = 0
	local sW, sH = ScrW(), ScrH()
	local main = vgui.Create("DFrame")
	main:SetSize(sW, sH)
	main:SetTitle("")
	main:SetDraggable(false)
	main:ShowCloseButton(false)
	main:MakePopup()
	main.Paint = function(self, w, h)
		local alpha = forcealpha or math.random(180, 200)

		surface.SetDrawColor(0, 0, 0, alpha)
		surface.DrawRect(0, 0, w, h)
		
		draw.SimpleText(head, "ErrorFontBlurred", w / 2, h / 6, Color(200, 0, 0, math.random(220, 255)), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleTextOutlined(head, "ErrorFont", w / 2, h / 6, Color(200, 0, 0, math.random(220, 255)), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, ColorAlpha(color_black, alpha))

		local y = 0
		for k, v in SortedPairs(texts) do
			if (CurTime() - start) < k then continue end
			surface.SetFont("DebugFixed")
			surface.SetTextPos(0, y)
			surface.SetTextColor(tcolor)
			surface.DrawText(v)
			y = y + 15
		end
	end
	main:SetMouseInputEnabled(true)
	main:SetKeyboardInputEnabled(true)

	local ctexts = table.Copy(texts)
	hook.Add("Think", "Console", function()
		for k, v in SortedPairs(ctexts) do
			if (CurTime() - start) < k then continue end
			MsgC(tcolor, v.."\n")
			ctexts[k] = nil
		end
	end)

	timer.Create("Console", 1, #texts + 1, function()
		head = str:sub(1, len)
		len = len + 1
	end)

	timer.Create("TextAppears", .1, #str + 1, function()
		head = str:sub(1, len)
		len = len + 1
	end)

	local intensity = 1
	timer.Create("ScreenShake", 1, 4, function()
		util.ScreenShake(vector_origin, 10 * intensity, 10, 5, 0)
		intensity = intensity + 1
	end)

	timer.Create("NoExit", .1, 0, function()
		gui.HideGameUI()
	end)

	timer.Simple(19, function()
		RunConsoleCommand("r_shader_srgb", "0")
		forcealpha = 255
	end)

	timer.Simple(20, function()
		hook.Remove("Think", "Console")
		timer.Remove("NoExit")
		main:Remove()
		s:Stop()
	end)
	RunConsoleCommand("r_shader_srgb", "1")
end

sound.PlayURL("https://www.dropbox.com/s/n7lqzcb29hb99xx/hackerman.mp3?dl=1", "no block", function(s)
	create(s)
end)
