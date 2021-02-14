--White
CBWhite = Color(255,255,255,255)
CWhite = Color(220,220,220,255)
CTWhite = Color(220,220,220,100)
--Gray
CGray = Color(100,100,100,255)
CTGray = Color(100,100,100,240)
CDarkGray = Color(50,50,50,255)
CLightGray = Color(150,150,150,255)
--Black
CBlack = Color (0,0,0,255)
CLTBlack = Color (0,0,0,220)
CTBlack = Color (0,0,0,230)
CVTBlack = Color (0,0,0,240)
--Red
CRed = Color (255,100,70,255)
--Yellow
CYellow = Color (255,255,100,255)
--Green
CGreen = Color (100,255,100,255)
--Invis
CNil = Color(0,0,0,0)

scb.littleplays = {
	{ x = 184, y = 84},
	{ x = 196, y = 90},
	{ x = 184, y = 96}
	}

scb.largeplays = {
	{ x = 6, y = 6},
	{ x = 26, y = 15},
	{ x = 6, y = 24}
	}

scb.back1 = {
	{ x = 4, y = 15},
	{ x = 14, y = 5},
	{ x = 18, y = 5},
	{ x = 8, y = 15}
	}

scb.back2 = {
	{ x = 4, y = 15},
	{ x = 8, y = 15},
	{ x = 18, y = 25},
	{ x = 14, y = 25}
	}

scb.del1 = {
	{ x = 6, y = 8},
	{ x = 8, y = 6},
	{ x = 24, y = 22},
	{ x = 22, y = 24}
	}

scb.del2 = {
	{ x = 22, y = 6},
	{ x = 24, y = 8},
	{ x = 8, y = 24},
	{ x = 6, y = 22}
	}

scb.ren = {
	{ x = 22, y = 6},
	{ x = 24, y = 8},
	{ x = 8, y = 22}
	}

defart300 = "https://i.imgsafe.org/5563ec5ff5.png"
defart100 = "https://i.imgsafe.org/4322fc01e9.jpg"
defart47 = "https://i.imgsafe.org/4322f58d51.jpg"

defart299 = "https://i.imgsafe.org/a12f1eec62.png"

surface.CreateFont("SCRoboto14",{
	font = "Roboto",
	size = 14,
	weight = 300
	})

surface.CreateFont("SCRoboto16",{
	font = "Roboto",
	size = 16,
	weight = 700,
	extended = true
	})

surface.CreateFont("SCRoboto18",{
	font = "Roboto",
	size = 18,
	weight = 700,
	extended = true
	})

surface.CreateFont("SCRoboto20",{
	font = "Roboto",
	size = 20,
	weight = 300,
	extended = true
	})

surface.CreateFont("SCRoboto24",{
	font = "Roboto",
	size = 24,
	weight = 500,
	extended = true
	})

surface.CreateFont("SCInterstate14",{
	font = "GLInterstateRegular",
	size = 14,
	weight = 500,
	extended = true
	})

surface.CreateFont("SCInterstate14B",{
	font = "GLInterstateRegular",
	size = 14,
	weight = 1000,
	extended = true
	})

surface.CreateFont("SCInterstate18",{
	font = "GLInterstateRegular",
	size = 16,
	weight = 500,
	extended = true
	})

surface.CreateFont("SCInterstate24",{
	font = "GLInterstateRegular",
	size = 23,
	weight = 500,
	extended = true
	})

function scb.showerror (text)

	local textlen = scb.gettextlen(text, "SCRoboto24")

	if IsValid(Notifier) and Notifier != nil then Notifier:SetVisible (false) end

	Notifier = vgui.Create ("DPanel")
		Notifier:SetSize (textlen + 100, 55)
		Notifier:Center ()
		Notifier:MakePopup ()
		Notifier.Paint = function (self, w, h)
			draw.RoundedBox (0,0,0,w,h,CWhite)
			surface.SetDrawColor(CBlack)
			surface.DrawOutlinedRect( 0, 0, w, h)
			end
	NLabel = vgui.Create ("DLabel", Notifier)
		NLabel:SetPos (50, 0)
		NLabel:SetSize (textlen, 30)
		NLabel:SetColor (CBlack)
		NLabel:SetFont ("SCRoboto24")
		NLabel:SetText (text)
	NButton = vgui.Create ("DButton", Notifier)
		NButton:SetPos ((textlen+50)/2, 30)
		NButton:SetSize (50, 20)
		NButton:SetColor (CBlack)
		NButton:SetText ("OK")
		NButton.Paint = function (self,w,h) surface.SetDrawColor(CBlack) surface.DrawOutlinedRect( 0, 0, w, h) end
		NButton.DoClick = function () Notifier:SetVisible (false) end

	end

function scb.notify (frame)

	if frame == "player" then

		if IsValid(PlayerFrame) and scb.settings.plrsize == "default" then 
			if IsValid (notifier) then notifier:Remove () end

				notifier = vgui.Create ("DPanel", PlayerFrame)
				notifier:SetPos (105, 30)
				notifier:SetSize (100, 0)
				notifier:SizeTo (100, 30, 0.3)
				notifier.Paint = function (self, w, h)
					draw.RoundedBox (8,0,10,w,20,CDarkGray)
					surface.SetDrawColor (CDarkGray)
					draw.NoTexture ()
					surface.DrawPoly({{x=40, y=10}, {x=50, y=0}, {x=60, y=10}})
				end

				notifierl = vgui.Create ("DLabel", notifier)
				notifierl:SetPos (0, 10)
				notifierl:SetSize (100, 20)
				notifierl:SetFont("SCRoboto20")
				notifierl:SetColor(CWhite)
				notifierl:SetText("Added")
				notifierl:SetContentAlignment(5)

				timer.Simple (2, function () if IsValid (notifier) then notifier:SizeTo (100, 0, 0.3) timer.Simple (0.3, function () if IsValid (notifier) then notifier:Remove () end end) end end)

			end

	end
	
	end

function scb.chooser (info)

	if IsValid (PlayerFrame) and PlayerFrame:IsVisible() then

		if IsValid (s_chooserf) then s_chooserf:Remove () timer.Destroy ("scb_chooser") end

		if scb.settings.plrsize == "default" then

			s_chooserf = vgui.Create ("DPanel", InvisFrame)
			s_chooserf:SetPos (0, 0)
			s_chooserf:SetSize (300,300)
			s_chooserf.Paint = function (self, w, h) draw.RoundedBox(0 ,0 ,0 ,w, h, CVTBlack) end

			s_chooserl = vgui.Create ("DLabel", s_chooserf)
			s_chooserl:SetPos (0, 70)
			s_chooserl:SetSize (300, 30)
			s_chooserl:SetFont("SCRoboto24")
			s_chooserl:SetColor(CWhite)
			s_chooserl:SetText("Server has started a stream.")
			s_chooserl:SetContentAlignment(5)

			s_chooserl = vgui.Create ("DLabel", s_chooserf)
			s_chooserl:SetPos (0, 95)
			s_chooserl:SetSize (300, 30)
			s_chooserl:SetFont("SCRoboto24")
			s_chooserl:SetColor(CWhite)
			s_chooserl:SetText("Do you want to switch to it?")
			s_chooserl:SetContentAlignment(5)

			s_chooserl1 = vgui.Create ("DLabel", s_chooserf)
			s_chooserl1:SetPos (0, 120)
			s_chooserl1:SetSize (300, 30)
			s_chooserl1:SetFont("SCRoboto24")
			s_chooserl1:SetColor(CWhite)
			s_chooserl1:SetText("9")
			s_chooserl1:SetContentAlignment(5)

			s_choosery = vgui.Create ("DButton", s_chooserf)
			s_choosery:SetPos (80, 150)
			s_choosery:SetSize (60, 30)
			s_choosery:SetColor (CWhite)
			s_choosery:SetFont("SCRoboto24")
			s_choosery:SetText ("Yes")
			s_choosery.Paint = function (self,w,h) surface.SetDrawColor(CWhite) surface.DrawOutlinedRect( 0, 0, w, h) end
			s_choosery.DoClick = function () scb.switch_stream (info, "sv") timer.Stop ("scb_chooser") s_chooserf:Remove() end

			s_choosern = vgui.Create ("DButton", s_chooserf)
			s_choosern:SetPos (160, 150)
			s_choosern:SetSize (60, 30)
			s_choosern:SetColor (CWhite)
			s_choosern:SetFont("SCRoboto24")
			s_choosern:SetText ("No")
			s_choosern.Paint = function (self,w,h) surface.SetDrawColor(CWhite) surface.DrawOutlinedRect( 0, 0, w, h) end
			s_choosern.DoClick = function () timer.Stop ("scb_chooser") s_chooserf:Remove() end

			timer_elap = 9

			timer.Create ("scb_chooser",1 ,10 , function ()

				timer_elap = timer_elap-1
				if IsValid (s_chooserl1) then s_chooserl1:SetText(timer_elap) end

				if timer_elap == 0 then
					if IsValid(scb.cl_stream) then scb.switch_stream (info, "sv") else scb.sv_stream:SetVolume(scb.settings.volume/100) end
					s_chooserf:Remove() 
				end

				end)

		else

			s_chooserf = vgui.Create ("DPanel", PlayerFrame)
			s_chooserf:SetPos (0, 30)
			s_chooserf:SetSize (400, 50)
			s_chooserf.Paint = function (self, w, h) draw.RoundedBox(0 ,0 ,0 ,w, h, CVTBlack) end

			s_chooserl = vgui.Create ("DLabel", s_chooserf)
			s_chooserl:SetPos (0, 10)
			s_chooserl:SetSize (250, 30)
			s_chooserl:SetFont("SCRoboto24")
			s_chooserl:SetColor(CWhite)
			s_chooserl:SetText("Switch to the server? 10")
			s_chooserl:SetContentAlignment(5)

			s_choosery = vgui.Create ("DButton", s_chooserf)
			s_choosery:SetPos (250, 10)
			s_choosery:SetSize (60, 30)
			s_choosery:SetColor (CWhite)
			s_choosery:SetFont("SCRoboto24")
			s_choosery:SetText ("Yes")
			s_choosery.Paint = function (self,w,h) surface.SetDrawColor(CWhite) surface.DrawOutlinedRect( 0, 0, w, h) end
			s_choosery.DoClick = function () scb.switch_stream (info, "sv") s_chooserf:Remove() end

			s_choosern = vgui.Create ("DButton", s_chooserf)
			s_choosern:SetPos (320, 10)
			s_choosern:SetSize (60, 30)
			s_choosern:SetColor (CWhite)
			s_choosern:SetFont("SCRoboto24")
			s_choosern:SetText ("No")
			s_choosern.Paint = function (self,w,h) surface.SetDrawColor(CWhite) surface.DrawOutlinedRect( 0, 0, w, h) end
			s_choosern.DoClick = function () timer.Stop ("scb_chooser") s_chooserf:Remove() end

			timer_elap = 9

			timer.Create ("scb_chooser",1 ,10 , function ()

				timer_elap = timer_elap-1
				if IsValid (s_chooserl) then s_chooserl:SetText("Switch to the server? "..timer_elap) end
				
				if timer_elap == 0 then
					scb.switch_stream (info, "sv")
					s_chooserf:Remove() 
				end

			end)

		end
	else
		scb.play_track (info, "sv")
	end
	end

function scb.gettextlen (text, font)
	surface.SetFont(font)
	surface.GetTextSize(text)
	return surface.GetTextSize(text)
	end

function scb.searchcats (panel, title, num, state, tupe)

	if tupe == "search" then panel:SetPos ((num-1)*100, 0)
	else panel:SetPos ((num-1)*100, 60) end
	panel:SetSize (100,40)
	panel:SetText (title)
	panel:SetColor (CGray)
	panel:SetFont ("SCRoboto24")
		panel.Paint = function (self,w,h) 
			draw.RoundedBox (0,0,0,w,h,CWhite)
			if panel:IsHovered() then draw.RoundedBox (0,0,35,w,5,CLightGray) end
			if state then draw.RoundedBox (0,0,35,w,5,CDarkGray) end
		end
	end

function scb.createitemlist (data, tupe, tupe2, text)

	if IsValid (ItemList) and ItemList != nil then ItemList:SetVisible (false) end

	ItemList =  vgui.Create ("DScrollPanel", BrowserFrame)
	if tupe2 == "search" then 
		ItemList:SetSize(300,0)
		ItemList:SizeTo(299,359,0.5)
		ItemList:SetPos(500,40)
	else
		ItemList:SetSize(300,299)
		ItemList:SetPos(500,100)
	end
	ItemList:SetVisible(true)
	ItemList.Paint = function (self,w,h)
		draw.RoundedBox (0,0,0,w,h,CWhite)
		end

	scb.paintscrollbar (ItemList)

	Item = {}
	ItemArt = {}
	AuthorName = {}
	ItemName = {}
	ItemSelect = {}

	if istable(data.collection) and #data.collection == 0 then 
		templabel = vgui.Create ("DLabel", ItemList)
		templabel:SetPos (0, 150)
		templabel:SetSize (300, 50)
		templabel:SetColor (CBlack)
		templabel:SetFont ("SCRoboto24")
		templabel:SetText ("Seems like nothing is here!")
		templabel:SetContentAlignment(5)
	end

	itemtb = data.collection or data
		for i = 1, #itemtb do
			if itemtb[i] != nil then
				Item[i] = vgui.Create ("DPanel", ItemList)
				Item[i]:SetPos (0,i*50-50)
				Item[i]:SetSize (300,49)

				http.Fetch (itemtb[i].artwork_url, function ( body, len, headers, code )
					if string.match (body, "cannot find original") then 
						if tupe == "tracks" or tupe == "playlists" then
							if itemtb[i].user.avatar_url == nil then ItemArt[i]:OpenURL (defart47)
							else itemtb[i].artwork_url = itemtb[i].user.avatar_url end
							ItemArt[i]:OpenURL(string.Replace (itemtb[i].artwork_url, "large", "badge"))
						elseif tupe == "users" then
							if data.collection.avatar_url == nil then data.collection.avatar_url = defart47 end
							ItemArt[i]:OpenURL(string.Replace (itemtb[i].avatar_url, "large", "badge"))
						end
					end
					end)

				ItemArt[i] = vgui.Create ("HTML", Item[i])
				ItemArt[i]:SetPos(1,1)
				ItemArt[i]:SetSize(55,200)
				if tupe == "tracks" or tupe == "playlists" then
					if itemtb[i].artwork_url == nil then 
						if itemtb[i].user.avatar_url == nil then ItemArt[i]:OpenURL (defart47)
						else itemtb[i].artwork_url = itemtb[i].user.avatar_url end
					end
					ItemArt[i]:OpenURL(string.Replace (itemtb[i].artwork_url, "large", "badge"))
				elseif tupe == "users" then
					if data.collection.avatar_url == nil then data.collection.avatar_url = defart47 end
					ItemArt[i]:OpenURL(string.Replace (itemtb[i].avatar_url, "large", "badge"))
				end

				if istable (itemtb[i].user) and itemtb[i].user.username != nil then
					AuthorName[i] = vgui.Create ("DLabel", Item[i])
					AuthorName[i]:SetPos (60,6)
					AuthorName[i]:SetSize (240,14)
					AuthorName[i]:SetFont ("SCInterstate14")
					AuthorName[i]:SetColor (CBWhite)
					AuthorName[i]:SetText (itemtb[i].user.username)
				end

				ItemName[i] = vgui.Create ("DLabel", Item[i])
				ItemName[i]:SetColor (CBWhite)
				if isstring (itemtb[i].title) and itemtb[i].title !=nil then 
					ItemName[i]:SetSize (230,18)
					ItemName[i]:SetFont ("SCInterstate18")
					ItemName[i]:SetPos (60,26)
					ItemName[i]:SetText (itemtb[i].title) 
				elseif isstring (itemtb[i].username) and itemtb[i].username !=nil then 
					ItemName[i]:SetSize (230,24)
					ItemName[i]:SetFont ("SCInterstate18")
					ItemName[i]:SetText (itemtb[i].username) 
					ItemName[i]:SetPos (60,6)
				end

				Item[i].Paint = function (self,w,h)
					if i/2 == math.floor(i/2) then draw.RoundedBox (0,50,0,w,h,CGray) else draw.RoundedBox (0,50,0,w,h,CLightGray) end
					if tupe == "tracks" or tupe == "playlists" then 
						draw.RoundedBox (0,55,4, AuthorName[i]:GetTextSize() + 8,18,CVTBlack)
						draw.RoundedBox (0,55,25, ItemName[i]:GetTextSize() + 10,21,CVTBlack) 
					elseif tupe == "users" then
						draw.RoundedBox (0,55,2, ItemName[i]:GetTextSize() + 10,32,CVTBlack) 
					end
					end

				ItemSelect[i] = vgui.Create ("DButton", Item[i])
				ItemSelect[i]:SetPos (0, 0)
				ItemSelect[i]:SetSize (280,50)
				ItemSelect[i]:SetText ("")
				ItemSelect[i].Paint = function () end
				ItemSelect[i].DoClick = function ()
					scb.checklink (itemtb[i].permalink_url)
				end
			end
		end

			if isstring(data.next_href) then
			NextPage = vgui.Create ("DButton", ItemList)
			NextPage:SetPos (0, #itemtb*50)
			NextPage:SetSize (300,30)
			NextPage:SetFont ("SCRoboto20")
			NextPage:SetColor (CBlack)
			NextPage:SetText ("Next page")
			NextPage.Paint = function (self, w, h) draw.RoundedBox (0,0,0,w,h,CTWhite) end
			NextPage.DoClick = function ()
				scb.search_next (data.next_href, tupe, text)
			end
		end
	end

function scb.paintscrollbar (panel, col1, col2)
	col1 = col1 or CLightGray
	col2 = col2 or CDarkGray
	local sbar = panel:GetVBar()
	function sbar:Paint( w, h )	draw.RoundedBox( 0, 0, 0, w, h, col1 ) end
	function sbar.btnUp:Paint( w, h ) draw.RoundedBox( 4, 4, 4, w-8, h-8, col2 ) end
	function sbar.btnDown:Paint( w, h ) draw.RoundedBox( 4, 4, 4, w-8, h-8, col2 ) end
	function sbar.btnGrip:Paint( w, h )	draw.RoundedBox( 4, 4, 0, w-8, h, col2 ) end
	end

function scb.changesettings ()
	file.Write ("soundcloudplayer/settings.txt" , util.TableToJSON ( scb.settings ) ) 
	end