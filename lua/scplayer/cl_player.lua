function scb.play_track (info, tag)

	if !istable(info) then 
		scb.showerror ("#scp_something_went_wrong_no_track_data_try_again")
		return 
	end

	local key = ""

	if tag == "cl" then key = scb.primary_key else key = scb.reserve_key end

	sound.PlayURL ("http://api.soundcloud.com/tracks/"..info.id .."/stream?client_id="..key, "", function (stream, id, str)
		if tag == "cl" then

			if IsValid(scb.sv_stream) then scb.sv_stream:SetVolume(0) end
			if IsValid(scb.cl_stream) then scb.cl_stream:Stop() end

			scb.cl_stream = stream

			if IsValid (scb.cl_stream) then scb.cl_stream:SetVolume (scb.settings.volume/100) end

			scb.queue_refresh ()

			if scb.settings.plrsize == "default" then scb.player_def (info, scb.cl_stream, tag) else scb.player_lit (info, scb.cl_stream, tag) end
			scb.finished = false

		else

			if IsValid(scb.cl_stream) then 
				scb.cl_stream:Pause()
				if timer.Exists("scb_queue") then timer.Pause("scb_queue") end
			end
			if IsValid(scb.sv_stream) then scb.sv_stream:Stop() end
			scb.sv_stream = stream

			if scb.settings.plrsize == "default" then scb.player_def (info, scb.sv_stream, tag) else scb.player_lit (info, scb.sv_stream, tag) end
			scb.finished = false

			if IsValid (scb.sv_stream) then scb.sv_stream:SetVolume (scb.settings.volume/100) end

		end

	end)
	end

function scb.switch_stream (info, tag)

	if IsValid (scb.sv_stream) and IsValid (scb.cl_stream) then

		if tag == "sv" then

			scb.cl_stream:Pause() 
			if timer.Exists("scb_queue") then timer.Pause("scb_queue") end

			scb.sv_stream:SetVolume(scb.settings.volume/100)
			if scb.settings.plrsize == "default" then scb.player_def (info, scb.sv_stream, tag) else scb.player_lit (info, scb.sv_stream, tag) end
			scb.tag = tag

		else

			scb.sv_stream:SetVolume(0)
			if timer.Exists("scb_queue") then timer.UnPause("scb_queue") end

			scb.cl_stream:SetVolume(scb.settings.volume/100)
			scb.cl_stream:Play()
			if scb.settings.plrsize == "default" then scb.player_def (info, scb.cl_stream, tag) else scb.player_lit (info, scb.cl_stream, tag) end
			scb.tag = tag

		end

		end
	end

function scb.player_switch (tag)

	if IsValid(PlayerSwitch) and PlayerSwitch:IsVisible() then PlayerSwitch:Remove() end

		if IsValid (PlayerFrame) then 
			if IsValid (scb.sv_stream) and scb.sv_stream:GetState() == 1 and IsValid (scb.cl_stream) and istable (scb.queue[1]) then
				
				PlayerSwitch = vgui.Create  ("DButton", PlayerFrame)
				PlayerSwitch:SetPos (60, 0)
				PlayerSwitch:SetSize (30,30)
				PlayerSwitch:SetText ("")
				PlayerSwitch.Paint = function (self, w, h) if PlayerSwitch:IsHovered() then surface.SetDrawColor (CLightGray) surface.DrawOutlinedRect (2, 2, 26, 26) end 
					draw.RoundedBox (0,10,10,10,3,CWhite) 
					draw.RoundedBox (0,10,17,10,3,CWhite)
					draw.NoTexture()
					surface.SetDrawColor (CWhite)
					surface.DrawPoly ({ {x = 5, y = 13} , {x = 10, y = 7} , {x = 10, y = 13} })
					surface.DrawPoly ({ {x = 20, y = 17} , {x = 25, y = 17} , {x = 20, y = 23} })
				end
				PlayerSwitch.DoClick = function () if tag == "sv" then scb.switch_stream (scb.queue[1], "cl") else scb.switch_stream (scb.sv_queue[1], "sv") end end		

			end
		end

	end

function scb.player_def (info, stream, tag)

	if IsValid (PlayerFrame) then PlayerFrame:Remove () end
	scb.tag = tag
	timer.Stop ("CurTrackTime")

	PlayerFrame = vgui.Create( "DFrame" )
	PlayerFrame:SetSize ( 300, 330 )
	PlayerFrame:SetPos (scb.pos[1], scb.pos[2])
	PlayerFrame:SetTitle ("")
	PlayerFrame:SetVisible (true)
	PlayerFrame:ShowCloseButton (false)
	PlayerFrame:SetDraggable (true)
	PlayerFrame:ParentToHUD ()
	PlayerFrame.Paint = function (self,w,h)
		if !GetConVar("cl_drawhud"):GetBool() or (IsValid (LocalPlayer():GetActiveWeapon()) and LocalPlayer():GetActiveWeapon():GetClass() == "gmod_camera") then self:SetAlpha (0) else self:SetAlpha (255) end
		draw.RoundedBox (0,0,0,w,30,CDarkGray) end
	PlayerFrame.OnCursorExited = function ()
		scb.pos[1] = select(1, PlayerFrame:GetPos())
		scb.pos[2] = select(2, PlayerFrame:GetPos()) end
	

	PlayerClose = vgui.Create ("DButton", PlayerFrame)
	PlayerClose:SetPos (270, 0)
	PlayerClose:SetSize (30,30)
	PlayerClose:SetText ("r")
	PlayerClose:SetFont ("Marlett")
	PlayerClose:SetColor (CWhite)
	PlayerClose.DoClick = function () 
		PlayerFrame:Remove()
		if IsValid(scb.cl_stream) then scb.cl_stream:Stop()	end
		if IsValid(scb.sv_stream) then scb.sv_stream:SetVolume(0) end
		if timer.Exists ("CurTrackTime") then timer.Stop ("CurTrackTime") end
		if timer.Exists ("scb_queue") then timer.Stop ("scb_queue") end
	end
	PlayerClose.Paint = function (self, w, h) if PlayerClose:IsHovered() then surface.SetDrawColor (CLightGray) surface.DrawOutlinedRect (2, 2, 26, 26) end draw.RoundedBox (0,0,0,w,h,CNil) end
	PlayerClose.Think = function ()
		if IsValid(stream) and stream:GetState() != 1 then 
			if !scb.finished then
				stream:Play() 
			else
				if tag == "cl" and !istable(scb.queue[2]) and IsValid(scb.sv_stream) and scb.sv_stream:GetState() == 1 then scb.switch_stream (scb.sv_queue[1], "sv")
				elseif tag == "sv"  and IsValid(scb.cl_stream) and istable(scb.queue[1]) and !istable(scb.sv_queue[2]) then scb.switch_stream (scb.queue[1], "cl")
				else print( "wtf" ) PlayerFrame:Remove() end
			end
		end
	end

	scb.player_switch (tag)

	PlayerTag = vgui.Create ("DLabel", PlayerFrame)
	PlayerTag:SetPos (10,0)
	PlayerTag:SetSize (50,30)
	PlayerTag:SetFont ("SCRoboto18")
	PlayerTag:SetColor (CWhite)
	if tag == "cl" then PlayerTag:SetText ("#scp_tag_local") else PlayerTag:SetText ("#scp_tag_server") end

	http.Fetch (info.artwork_url, function ( body, len, headers, code )
		if string.match (body, "cannot find original") then 
			if info.user.avatar_url == nil then info.artwork_url_edited = defart300
			else info.artwork_url_edited = string.Replace(info.user.avatar_url, "large", "t300x300") end
			ArtPIC:OpenURL(info.artwork_url_edited)
		end
		end)

	scb.player_volume (stream, plrsize)
	VCFrame:SetVisible (false)
	scb.player_visualization (stream, false)
	if scb.settings.visualizer == 1 then scb.player_visualization (stream, true) end

	PlayerVisualizer = vgui.Create ("DButton", PlayerFrame)
	PlayerVisualizer:SetPos (170, 0)
	PlayerVisualizer:SetSize (30,30)
	PlayerVisualizer:SetText ("")
	PlayerVisualizer.DoClick = function () 
		if VisPanel:IsVisible () then 
			scb.player_visualization (stream, false) scb.settings.visualizer = 0 scb.changesettings ()
		else scb.player_visualization (stream, true) scb.settings.visualizer = 1 scb.changesettings () end 
		end
	PlayerVisualizer.Paint = function (self, w, h) if PlayerVisualizer:IsHovered() then surface.SetDrawColor (CLightGray) surface.DrawOutlinedRect (2, 2, 26, 26) end 
		draw.RoundedBox (0,9,13,2,9,CWhite) 
		draw.RoundedBox (0,14,10,2,12,CWhite) 
		draw.RoundedBox (0,19,16,2,6,CWhite) 
	end

	PlayerQueue = vgui.Create ("DButton", PlayerFrame)
	PlayerQueue:SetPos (140, 0)
	PlayerQueue:SetSize (30,30)
	PlayerQueue:SetText ("")
	PlayerQueue.DoClick = function () if IsValid (QueueF) then QueueF:Remove () else scb.player_queue (tag) end end
	PlayerQueue.Paint = function (self, w, h) if PlayerQueue:IsHovered() then surface.SetDrawColor (CLightGray) surface.DrawOutlinedRect (2, 2, 26, 26) end 
		draw.RoundedBox (0,6,9,2,2,CWhite) 
		draw.RoundedBox (0,6,14,2,2,CWhite) 
		draw.RoundedBox (0,6,19,2,2,CWhite) 
		draw.RoundedBox (0,11,9,12,2,CWhite) 
		draw.RoundedBox (0,11,14,12,2,CWhite) 
		draw.RoundedBox (0,11,19,12,2,CWhite) 
	end

	PlayerVolume = vgui.Create ("DButton", PlayerFrame)
	PlayerVolume:SetPos (210, 0)
	PlayerVolume:SetSize (30,30)
	PlayerVolume:SetText ("y")
	PlayerVolume:SetFont ("Marlett")
	PlayerVolume:SetColor (CWhite)
	PlayerVolume.DoClick = function () 
		if IsValid(VCFrame) then if VCFrame:IsVisible () then VCFrame:SetVisible (false) else scb.player_volume (stream) end else scb.player_volume (stream) end end
	PlayerVolume.Paint = function (self, w, h) if PlayerVolume:IsHovered() then surface.SetDrawColor (CLightGray) surface.DrawOutlinedRect (2, 2, 26, 26) end draw.RoundedBox (0,0,0,w,h,CNil) end

	PlayerResize = vgui.Create ("DButton", PlayerFrame)
	PlayerResize:SetPos (240, 0)
	PlayerResize:SetSize (30,30)
	PlayerResize:SetText ("0")
	PlayerResize:SetFont ("Marlett")
	PlayerResize:SetColor (CWhite)
	PlayerResize.DoClick = function () 
		scb.settings.plrsize = "little" 
		scb.changesettings ()
		scb.player_lit (info, stream, tag) end
	PlayerResize.Paint = function (self, w, h) if PlayerResize:IsHovered() then surface.SetDrawColor (CLightGray) surface.DrawOutlinedRect (2, 2, 26, 26) end draw.RoundedBox (0,0,0,w,h,CNil) end

	ArtPIC = vgui.Create ("HTML", PlayerFrame)
	ArtPIC:SetPos (0,30)
	ArtPIC:SetSize (320,320)
	if info.artwork_url == nil then 
		if info.user.avatar_url == nil then
			info.artwork_url_edited = defart300
		else info.artwork_url_edited = string.Replace(info.user.avatar_url, "large", "t300x300") end
	else info.artwork_url_edited = string.Replace(info.artwork_url, "large", "t300x300") 
	end
	ArtPIC:OpenURL(info.artwork_url_edited)

	InvisFrame = vgui.Create( "DPanel" , PlayerFrame)
	InvisFrame:SetSize (300, 300 )
	InvisFrame:SetPos (0,30)

	ArtistLBL = vgui.Create ("DLabel", InvisFrame)
	ArtistLBL:SetPos (17,5)
	ArtistLBL:SetSize (280,20)
	ArtistLBL:SetFont ("SCInterstate18")
	ArtistLBL:SetColor (CBWhite)
	ArtistLBL:SetText (info.user.username)

	local ti = {}
	ti.src = string.Explode (" ", info.title)
	ti.lbl1 = ""
	ti.lbl2 = ""
	ti.lbl3 = ""

	for i = 1, #ti.src do
		if scb.gettextlen (ti.lbl1.." "..ti.src[i], "SCInterstate24") <= 280 then 
			ti.lbl1 = ti.lbl1.." "..ti.src[i]
		else
			for i1 = i, #ti.src do
				if scb.gettextlen (ti.lbl2.." "..ti.src[i1], "SCInterstate24") <= 280 then 
					ti.lbl2 = ti.lbl2.." "..ti.src[i1]
				else
					for i2 = i1, #ti.src do
						ti.lbl3 = ti.lbl3.." "..ti.src[i2]
					end
				break end
			end
		break end
	end

	TrackLBL = vgui.Create ("DLabel", InvisFrame)
	TrackLBL:SetPos (11,35)
	TrackLBL:SetSize (280,72)
	TrackLBL:SetFont ("SCInterstate24")
	TrackLBL:SetColor (CBWhite)
	TrackLBL:SetText (ti.lbl1.."\n"..ti.lbl2.."\n"..ti.lbl3)
	TrackLBL:SetMouseInputEnabled (true)
	TrackLBL.DoClick = function () gui.OpenURL (info.permalink_url) end
	TrackLBL.Paint = function (self) if self:IsHovered() then self:SetColor (CLightGray) else self:SetColor (CBWhite) end end

	CurPosLBL = vgui.Create ("DLabel", InvisFrame)
	CurPosLBL:SetPos (27,250)
	CurPosLBL:SetSize (50,14)
	CurPosLBL:SetFont ("SCRoboto14")
	CurPosLBL:SetColor (CRed)
	CurPosLBL:SetText ("0:00")

	curlen = 0
	if IsValid (stream) then curlen = math.floor (stream:GetTime ()) end

	timer.Create ("CurTrackTime", 1, math.floor (info.duration/1000)-curlen, function ()

		if IsValid (stream) and IsValid(CurPosLBL) then

			if curlen <= math.ceil (info.duration/1000) then curlen = curlen + 1 end
			local curhr = math.floor (curlen/3600)
			local curmin = math.floor (curlen/60-curhr*60)
			local cursec = math.floor (curlen-curhr*3600-curmin*60)
				if cursec < 10 then cursec = tostring ("0"..cursec) end
			if curhr == 0 then CurPosLBL:SetText (curmin..":"..cursec)
			else if curmin < 10 then curmin = tostring ("0"..curmin) end

			CurPosLBL:SetText (curhr..":"..curmin..":"..cursec) end

			if curlen >= math.floor (info.duration/1000) then scb.finished = true else scb.finished = false end

		end
		end)

	MaxPosLBL = vgui.Create ("DLabel", InvisFrame)
	MaxPosLBL:SetPos (250,250)
	MaxPosLBL:SetSize (50,14)
	MaxPosLBL:SetFont ("SCRoboto14")
	MaxPosLBL:SetColor (CBWhite)
	MaxPosLBL:SetText ("00:00")
		local maxlen = (math.floor(info.duration/1000))
		local maxhr = math.floor (maxlen/3600)
		local maxmin = math.floor (maxlen/60-maxhr*60)
		local maxsec = math.floor (maxlen-maxhr*3600-maxmin*60)
	if maxhr > 0 then MaxPosLBL:SetPos (235,250) end
	if maxmin > 9 then MaxPosLBL:SetPos (240,250) end
		if maxsec < 10 then maxsec = tostring ("0"..maxsec) end
		if maxhr == 0 then MaxPosLBL:SetText (maxmin..":"..maxsec)
		else if maxmin < 10 then maxmin = tostring ("0"..maxmin) end
		MaxPosLBL:SetText (maxhr..":"..maxmin..":"..maxsec) end

	LenBar = vgui.Create ("DPanel", InvisFrame)
	LenBar:SetSize (265, 3)
	LenBar:SetPos (17, 270)
	LenBar.Paint = function (self,w,h) if IsValid (stream) then
		draw.RoundedBox (0,0,0,w,h,CWhite)
		draw.RoundedBox (0,0,0,math.floor((stream:GetTime()*1000/info.duration)*265+1),h,CRed) end
	end

	InvisFrame.Paint = function (self,w,h)
		draw.RoundedBox (0,10,5,ArtistLBL:GetTextSize()+14,22,CVTBlack)
		draw.RoundedBox (0,10,33,scb.gettextlen (ti.lbl1, "SCInterstate24")+8,26,CVTBlack)
		if ti.lbl2 != "" then draw.RoundedBox (0,10,59,scb.gettextlen (ti.lbl2, "SCInterstate24")+8,26,CVTBlack) end
		if ti.lbl3 != "" then draw.RoundedBox (0,10,85,scb.gettextlen (ti.lbl3, "SCInterstate24")+8,26,CVTBlack) end
		draw.RoundedBox (0,22,248,CurPosLBL:GetTextSize()+10,18,CVTBlack)
		draw.RoundedBox (0,MaxPosLBL:GetPos()-5,248,MaxPosLBL:GetTextSize()+10,18,CVTBlack)
		draw.RoundedBox (0,0,240,w,40,CTBlack)
		end

	end

function scb.player_lit (info, stream, tag)

	timer.Stop ("CurTrackTime")

	if IsValid (PlayerFrame) and PlayerFrame != nil then PlayerFrame:Remove () end

	PlayerFrame = vgui.Create( "DFrame" )
		PlayerFrame:SetSize ( 400, 80 )
		PlayerFrame:SetPos (scb.pos[1], scb.pos[2])
		PlayerFrame:SetTitle ("")
		PlayerFrame:SetVisible (true)
		PlayerFrame:ShowCloseButton (false)
		PlayerFrame:ParentToHUD ()
	PlayerFrame.OnCursorExited = function ()
		scb.pos[1] = select(1, PlayerFrame:GetPos())
		scb.pos[2] = select(2, PlayerFrame:GetPos()) end

	scb.player_volume (stream, plrsize)
	VCFrame:SetVisible (false)

	PlayerClose = vgui.Create ("DButton", PlayerFrame)
		PlayerClose:SetPos (370, 0)
		PlayerClose:SetSize (30,30)
		PlayerClose:SetText ("r")
		PlayerClose:SetFont ("Marlett")
		PlayerClose:SetColor (CWhite)
		PlayerClose.Paint = function (self, w, h) if PlayerClose:IsHovered() then surface.SetDrawColor (CLightGray) surface.DrawOutlinedRect (2, 2, 26, 26) end draw.RoundedBox (0,0,0,w,h,CNil) end
		PlayerClose.DoClick = function () 
			PlayerFrame:SetVisible (false) 
			if IsValid(scb.cl_stream) then scb.cl_stream:Stop()	end
			if IsValid(scb.sv_stream) then scb.sv_stream:SetVolume(0) end
			if timer.Exists ("CurTrackTime") then timer.Stop ("CurTrackTime") end
			if timer.Exists ("scb_queue") then timer.Stop ("scb_queue") end 
		end

	PlayerClose.Think = function () 
		if IsValid(stream) and stream:GetState() != 1 then 
			if !scb.finished then
				stream:Play() 
			else
				if tag == "cl" and !istable(scb.queue[2]) and IsValid(scb.sv_stream) and scb.sv_stream:GetState() == 1 then scb.switch_stream (scb.sv_queue[1], "sv")
				elseif tag == "sv"  and IsValid(scb.cl_stream) and !istable(scb.sv_queue[2]) and istable(scb.queue[1]) then scb.switch_stream (scb.sv_queue[1], "cl")
				else PlayerFrame:Remove() end
			end
		end
	end

	ArtPIC = vgui.Create ("HTML", PlayerFrame)
		ArtPIC:SetPos (2,31)
		ArtPIC:SetSize (70,70)
		if info.artwork_url == nil then 
			if info.user.avatar_url == nil then
				info.artwork_url_edited = defart300
			else info.artwork_url_edited = string.Replace(info.user.avatar_url, "large", "badge") end
		else info.artwork_url_edited = string.Replace(info.artwork_url, "large", "badge") 
		end
		ArtPIC:OpenURL(info.artwork_url_edited)

	http.Fetch (info.artwork_url, function ( body, len, headers, code )
		if string.match (body, "cannot find original") then 
			if info.user.avatar_url == nil then info.new_artwork_url = defart100
			else info.new_artwork_url = string.Replace(info.user.avatar_url, "large", "badge") end
			ArtPIC:OpenURL(info.new_artwork_url)
		end
		end)

	TrackLBL = vgui.Create ("DLabel", PlayerFrame)
		TrackLBL:SetPos (55,35)
		TrackLBL:SetSize (345,20)
		TrackLBL:SetFont ("SCInterstate14")
		TrackLBL:SetColor (CWhite)
		TrackLBL:SetText (info.user.username.." - "..info.title)
		TrackLBL:SetMouseInputEnabled (true)
		TrackLBL.DoClick = function () gui.OpenURL (info.permalink_url) end
		TrackLBL.Paint = function () if TrackLBL:IsHovered() then TrackLBL:SetColor (CLightGray) else TrackLBL:SetColor (CBWhite) end end

	PlayerVolume = vgui.Create ("DButton", PlayerFrame)
		PlayerVolume:SetPos (310, 0)
		PlayerVolume:SetSize (30,30)
		PlayerVolume:SetText ("y")
		PlayerVolume:SetFont ("Marlett")
		PlayerVolume:SetColor (CWhite)
		PlayerVolume.DoClick = function () 
			if IsValid(VCFrame) then if VCFrame:IsVisible () then VCFrame:SetVisible (false) else scb.player_volume (stream, "little") end else scb.player_volume (stream, "little") end end
		PlayerVolume.Paint = function (self, w, h) if PlayerVolume:IsHovered() then surface.SetDrawColor (CLightGray) surface.DrawOutlinedRect (2, 2, 26, 26) end draw.RoundedBox (0,0,0,w,h,CNil) end

	PlayerResize = vgui.Create ("DButton", PlayerFrame)
		PlayerResize:SetPos (340, 0)
		PlayerResize:SetSize (30,30)
		PlayerResize:SetText ("1")
		PlayerResize:SetFont ("Marlett")
		PlayerResize:SetColor (CWhite)
		PlayerResize.DoClick = function () 
			scb.settings.plrsize = "default" 
			scb.changesettings ()
			scb.player_def (info, stream, tag) end
		PlayerResize.Paint = function (self, w, h) if PlayerResize:IsHovered() then surface.SetDrawColor (CLightGray) surface.DrawOutlinedRect (2, 2, 26, 26) end draw.RoundedBox (0,0,0,w,h,CNil) end

	CurPosLBL = vgui.Create ("DLabel", PlayerFrame)
		CurPosLBL:SetPos (63,62)
		CurPosLBL:SetSize (50,14)
		CurPosLBL:SetFont ("SCRoboto14")
		CurPosLBL:SetColor (CRed)
		CurPosLBL:SetText ("0:00")

	MaxPosLBL = vgui.Create ("DLabel", PlayerFrame)
		MaxPosLBL:SetPos (365,62)
		MaxPosLBL:SetSize (50,14)
		MaxPosLBL:SetFont ("SCRoboto14")
		MaxPosLBL:SetColor (CBWhite)
		MaxPosLBL:SetText ("00:00")
			local maxlen = (math.floor(info.duration/1000))
			local maxhr = math.floor (maxlen/3600)
			local maxmin = math.floor (maxlen/60-maxhr*60)
			local maxsec = math.floor (maxlen-maxhr*3600-maxmin*60)
		if maxhr > 0 then MaxPosLBL:SetPos (355,62) end
		if maxmin > 9 then MaxPosLBL:SetPos (360,62) end
				if maxsec < 10 then maxsec = tostring ("0"..maxsec) end
				if maxhr == 0 then MaxPosLBL:SetText (maxmin..":"..maxsec)
				else if maxmin < 10 then maxmin = tostring ("0"..maxmin) end
			MaxPosLBL:SetText (maxhr..":"..maxmin..":"..maxsec) end

	LenBar = vgui.Create ("DPanel", PlayerFrame)
		LenBar:SetSize (245, 3)
		LenBar:SetPos (97, 70)
		LenBar.Paint = function (self,w,h) if IsValid(stream) and stream:IsValid () then
			draw.RoundedBox (0,0,0,w,h,CWhite)
			draw.RoundedBox (0,0,0,math.floor((stream:GetTime()*1000/info.duration)*245+1),h,CRed) end
		end
	
	curlen = 0
	if stream != nil and stream:IsValid () then curlen = stream:GetTime () end

	timer.Create ("CurTrackTime", 1, math.floor (info.duration/1000)-curlen, function ()

		if IsValid (stream) then

			if curlen <= math.ceil (info.duration/1000) then curlen = curlen + 1 end
			local curhr = math.floor (curlen/3600)
			local curmin = math.floor (curlen/60-curhr*60)
			local cursec = math.floor (curlen-curhr*3600-curmin*60)
				if cursec < 10 then cursec = tostring ("0"..cursec) end
			if curhr == 0 then CurPosLBL:SetText (curmin..":"..cursec)
			else if curmin < 10 then curmin = tostring ("0"..curmin) end
				CurPosLBL:SetText (curhr..":"..curmin..":"..cursec) end	

			if curlen >= math.floor (info.duration/1000 - 1) then scb.finished = true else scb.finished = false end
		end
		end)

	PlayerFrame.Paint = function (self,w,h)
		if !GetConVar("cl_drawhud"):GetBool() or (IsValid (LocalPlayer():GetActiveWeapon()) and LocalPlayer():GetActiveWeapon():GetClass() == "gmod_camera") then self:SetAlpha (0) else self:SetAlpha (255) end
		draw.RoundedBox (0,0,30,w,130,CWhite)
		draw.RoundedBox (0,0,0,w,30,CDarkGray)
		draw.RoundedBox (0,52,33,TrackLBL:GetTextSize()+8,24,CVTBlack)
		draw.RoundedBox (0,59,60,CurPosLBL:GetTextSize()+8,18,CVTBlack)
		draw.RoundedBox (0,MaxPosLBL:GetPos()-5,60,MaxPosLBL:GetTextSize()+10,18,CVTBlack)
		draw.RoundedBox (0,52,60,w-54,18,CTBlack)
		end

	end

function scb.player_volume (stream, plrsize)

	if IsValid (VCFrame) and VCFrame != nil then VCFrame:Remove () end

		VCFrame = vgui.Create ("DPanel", PlayerFrame)
		VCFrame:SetPos (210,30)
		VCFrame:SetSize (30, 150)
		VCFrame.Paint = function (self,w,h) draw.RoundedBox (0,0,0,w,h,CDarkGray) end

		VlmLine = vgui.Create ("DPanel", VCFrame)
		VlmLine:SetPos (13, 15)
		VlmLine:SetSize (4, 100)
		VlmLine.Paint = function (self,w,h) draw.RoundedBox (0,0,100-scb.settings.volume,w,scb.settings.volume,CRed) end

		VlmLBL = vgui.Create ("DLabel", VCFrame)
		VlmLBL:SetPos (0, 130)
		VlmLBL:SetSize (28,20)
		VlmLBL:SetContentAlignment (5)
		VlmLBL:SetFont ("SCRoboto14")
		VlmLBL:SetColor (CBWhite)
		VlmLBL:SetText (scb.settings.volume)

		VlmGrip = vgui.Create ("DButton", VCFrame)
		VlmGrip:SetPos (7, 7)
		VlmGrip:SetSize (16,116)
		VlmGrip:SetText ("")
		VlmGrip.Paint = function (self,w,h) draw.RoundedBox (8,0,100-scb.settings.volume,16,16,CLightGray) end
		VlmGrip.DoClick = function ()
			scb.settings.volume = (100-select(2,VCFrame:CursorPos ())+15)
			scb.settings.volume = math.Round(scb.settings.volume)
			if scb.settings.volume < 0 then scb.settings.volume = 0 end
			if scb.settings.volume > 100 then scb.settings.volume = 100 end
			stream:SetVolume (scb.settings.volume/100)
			VlmLBL:SetText (scb.settings.volume)
			scb.changesettings ()
		end
		VlmGrip.OnCursorMoved = function ()
			if VlmGrip:IsDown () then 
				scb.settings.volume = (100-select(2,VCFrame:CursorPos ())+15)
				if scb.settings.volume < 0 then scb.settings.volume = 0 end
				if scb.settings.volume > 100 then scb.settings.volume = 100 end
				stream:SetVolume (scb.settings.volume/100)
				VlmLBL:SetText (scb.settings.volume)
				scb.changesettings ()
			end
		end

		VCFrame.Think = function ()
			if !PlayerVolume:IsHovered() and !VCFrame:IsHovered() and !VlmLine:IsHovered() and !VlmGrip:IsHovered() then
				VCFrame:Remove ()
			end
		end

	if plrsize == "little" then 

		VCFrame:SetPos (248, 30)
		VCFrame:SetSize (150, 30)
		VCFrame.Paint = function (self,w,h) draw.RoundedBox (0,0,0,w,h,CGray) end

		VlmLine:SetPos (15, 13)
		VlmLine:SetSize (100, 4)
		VlmLine.Paint = function (self,w,h) draw.RoundedBox (0,0,0,scb.settings.volume,h,CRed) end

		VlmLBL:SetPos (120, 5)

		VlmGrip:SetSize (116,16)

		VlmGrip.Paint = function (self,w,h) draw.RoundedBox (8,scb.settings.volume, 0, 16, 16,CLightGray) end
		VlmGrip.DoClick = function ()
			scb.settings.volume = VCFrame:CursorPos ()-15
			scb.settings.volume = math.Round(scb.settings.volume)
			if scb.settings.volume < 0 then scb.settings.volume = 0 end
			if scb.settings.volume > 100 then scb.settings.volume = 100 end
			stream:SetVolume (scb.settings.volume/100)
			VlmLBL:SetText (scb.settings.volume)
			scb.changesettings ()
		end
		VlmGrip.OnCursorMoved = function ()
			if VlmGrip:IsDown () then 
				scb.settings.volume = VCFrame:CursorPos ()-15
				if scb.settings.volume < 0 then scb.settings.volume = 0 end
				if scb.settings.volume > 100 then scb.settings.volume = 100 end
				stream:SetVolume (scb.settings.volume/100)
				VlmLBL:SetText (scb.settings.volume)
				scb.changesettings ()
			end
		end

	end

	end

function scb.player_visualization (stream, act)

	vis_rawmagnitudes = {}
	vis_magnitudes = {}
		for i = 1, 26 do vis_magnitudes[i] = 0 end
	vis_table = {}
	vis_color = CNil

	if act == true then 
		if IsValid(PlayerFrame) then PlayerFrame:SizeTo (300, 430, 0.5) end
		if IsValid(VisPanel) then VisPanel:SetVisible ( act ) end
	end

	VisPanel = vgui.Create ("DPanel", PlayerFrame)
		VisPanel:SetSize ( 280, 100 )
		VisPanel:SetPos (10,330)
		VisPanel.Paint = function (self,w,h)
			if IsValid(stream) then
				draw.RoundedBox (0,0,0,w,h,CBlack)
				stream:FFT (vis_rawmagnitudes, FFT_2048)
				if vis_rawmagnitudes[32] == nil then return end
				for i = 1, 26 do
					for ii = 1, 32 do
						vis_rawmagnitudes[i] =  math.max (vis_rawmagnitudes[i*32], vis_rawmagnitudes[i*32+ii])
					end	
					vis_rawmagnitudes[i] = math.pow (vis_rawmagnitudes[i], 1/3)*40
					if vis_rawmagnitudes[i] > vis_magnitudes[i]
						then vis_magnitudes [i] = vis_rawmagnitudes[i]
						else vis_magnitudes [i] = vis_magnitudes[i] - 0.2
					end

					vis_table[i] = math.abs (math.Round (vis_magnitudes[i])) + 1
					for i3 = 1, vis_table[i] do
						if i3 > 18 then vis_color = CNil 
							elseif i3 > 14 then vis_color = CRed 
							elseif i3 > 8 then vis_color = CYellow 
							else vis_color = CGreen 
						end
						draw.RoundedBox (0, i*10, 95-i3*5, 6, 4, vis_color)
					end
				end
			end
		end

	if act == false then VisPanel:SetVisible (false) if IsValid(PlayerFrame) then PlayerFrame:SizeTo (300, 330, 0.5) end end

	end

function scb.player_queue (tag)

	if IsValid (QueueF) then QueueF:Remove () end

	QueueF = vgui.Create( "DPanel", PlayerFrame )
	QueueF:SetPos (0,30)
	QueueF:SetSize (300, 0)
	QueueF:SizeTo (300, 220, 0.2)
	QueueF.Paint = function (self,w,h)
		draw.RoundedBox (0,0,0,w,h,CDarkGray) end

	QTracksSP = vgui.Create ("DScrollPanel", QueueF)
	QTracksSP:SetPos (0,0)
	QTracksSP:SetSize (300, 220)

	scb.paintscrollbar (QTracksSP)

	qtrck = {}
	qtrckdel = {}
	qtrckmove = {}
	qtrckavatar = {}
	qtrcklbl = {}

	if tag == "cl" then
		qtrcks = scb.queue
		for i = 1, #qtrcks do

				if qtrcks[i] != nil then
					qtrck[i] = vgui.Create ("DPanel", QTracksSP)
					qtrck[i]:SetPos (0,i*20-20)
					qtrck[i]:SetSize (300,20)
					qtrck[i].Paint = function (self,w,h)
						if i == 1 then draw.RoundedBox (0,0,0,w,h,CGray) else draw.RoundedBox (0,0,0,w,h,CDarkGray) end
						end

					ilbl = vgui.Create ("DLabel", qtrck[i])
					ilbl:SetSize (20,20)
					ilbl:SetPos (0,0)
					ilbl:SetContentAlignment(5)
					ilbl:SetFont ("SCRoboto18")
					ilbl:SetColor (CBWhite)
					ilbl:SetText (i) 

					http.Fetch (qtrcks[i].artwork_url, function ( body, len, headers, code )
						if string.match (body, "cannot find original") then 
							if qtrcks[i].user.avatar_url == nil then qtrcks[i].new_artwork_url_temp = defart100
							else qtrcks[i].new_artwork_url_temp = string.Replace(qtrcks[i].user.avatar_url, "large", "tiny") end
						qtrckavatar[i]:OpenURL(qtrcks[i].new_artwork_url_temp)
						end
						end)

					qtrckavatar[i] = vgui.Create ("HTML", qtrck[i])
					qtrckavatar[i]:SetPos(21,1)
					qtrckavatar[i]:SetSize(25,200)
						if qtrcks[i].artwork_url == nil then 
							if qtrcks[i].user.avatar_url == nil then qtrckavatar[i]:OpenURL (defart47)
							else qtrcks[i].artwork_url = qtrcks[i].user.avatar_url end
						end
					qtrckavatar[i]:OpenURL(string.Replace (qtrcks[i].artwork_url, "large", "tiny"))

					qtrcklbl[i] = vgui.Create ("DLabel", qtrck[i])
					qtrcklbl[i]:SetColor (CBWhite)
					qtrcklbl[i]:SetSize (190,18)
					qtrcklbl[i]:SetFont ("SCInterstate18")
					qtrcklbl[i]:SetPos (50,1)
					qtrcklbl[i]:SetText (qtrcks[i].title) 

					qtrckdel[i] = vgui.Create ("DButton", qtrck[i])
					qtrckdel[i]:SetPos (260, 1)
					qtrckdel[i]:SetSize (18,18)
					qtrckdel[i]:SetText ("X")
					qtrckdel[i]:SetFont ("SCRoboto20")
					qtrckdel[i]:SetColor (CWhite)
					qtrckdel[i].Paint = function (self, w, h) end

					if i != 1 then
						qtrckdel[i].DoClick = function () table.remove (scb.queue, i) scb.player_queue ("cl") end
					else
						qtrckdel[i].DoClick = function () 
							if istable(scb.queue[2]) then
								scb.play_track (scb.queue[2], "cl")
								table.remove (scb.queue, 1)
								scb.queue_refresh ()
							else
								if IsValid(scb.sv_stream) and scb.sv_stream:GetState() == 1 then table.remove (scb.queue, 1) scb.switch_stream (scb.sv_queue[1], "sv")
								else scb.cl_stream:Stop() PlayerFrame:Remove() end
							end
						end
					end

					if i != 1 then
						qtrckmove[i] = vgui.Create ("DButton", qtrck[i])
						qtrckmove[i]:SetPos (240, 0)
						qtrckmove[i]:SetSize (18,18)
						qtrckmove[i]:SetText ("5")
						qtrckmove[i]:SetFont ("Marlett")
						qtrckmove[i]:SetColor (CWhite)
						qtrckmove[i].Paint = function (self, w, h) end
						if i == 2 then 
							qtrckmove[i].DoClick = function () 
								if istable(scb.queue[2]) then
									scb.play_track (scb.queue[2], "cl")
									table.remove (scb.queue, 1)
									scb.queue_refresh ()
								else
									scb.cl_stream:Stop()
									PlayerFrame:Remove()
								end 
							end
						else
							qtrckmove[i].DoClick = function () table.insert (scb.queue, 2, scb.queue[i]) table.remove (scb.queue, i+1) scb.player_queue ("cl") end
						end
					end
				end
		end
	else 
		qtrcks = scb.sv_queue
		for i = 1, #qtrcks do

			if qtrcks[i] != nil then

				qtrck[i] = vgui.Create ("DPanel", QTracksSP)
				qtrck[i]:SetPos (0,i*20-20)
				qtrck[i]:SetSize (300,20)
				qtrck[i].Paint = function (self,w,h)
					if i == 1 then draw.RoundedBox (0,0,0,w,h,CGray) else draw.RoundedBox (0,0,0,w,h,CDarkGray) end
					end

				ilbl = vgui.Create ("DLabel", qtrck[i])
				ilbl:SetSize (20,20)
				ilbl:SetPos (0,0)
				ilbl:SetContentAlignment(5)
				ilbl:SetFont ("SCRoboto18")
				ilbl:SetColor (CBWhite)
				ilbl:SetText (i) 
				http.Fetch (qtrcks[i].artwork_url, function ( body, len, headers, code )
					if string.match (body, "cannot find original") then 
						if qtrcks[i].user.avatar_url == nil then qtrcks[i].new_artwork_url_temp = defart100
						else qtrcks[i].new_artwork_url_temp = string.Replace(qtrcks[i].user.avatar_url, "large", "tiny") end
					qtrckavatar[i]:OpenURL(qtrcks[i].new_artwork_url_temp)
					end
					end)

				qtrckavatar[i] = vgui.Create ("HTML", qtrck[i])
				qtrckavatar[i]:SetPos(21,1)
				qtrckavatar[i]:SetSize(25,200)
					if qtrcks[i].artwork_url == nil then 
						if qtrcks[i].user.avatar_url == nil then qtrckavatar[i]:OpenURL (defart47)
						else qtrcks[i].artwork_url = qtrcks[i].user.avatar_url end
					end
				qtrckavatar[i]:OpenURL(string.Replace (qtrcks[i].artwork_url, "large", "tiny"))

				qtrcklbl[i] = vgui.Create ("DLabel", qtrck[i])
				qtrcklbl[i]:SetColor (CBWhite)
				qtrcklbl[i]:SetSize (190,18)
				qtrcklbl[i]:SetFont ("SCInterstate18")
				qtrcklbl[i]:SetPos (50,1)
				qtrcklbl[i]:SetText (qtrcks[i].title) 

				if LocalPlayer():IsSuperAdmin() then

					qtrckdel[i] = vgui.Create ("DButton", qtrck[i])
					qtrckdel[i]:SetPos (260, 0)
					qtrckdel[i]:SetSize (20,16)
					qtrckdel[i]:SetText ("x")
					qtrckdel[i]:SetFont ("SCRoboto20")
					qtrckdel[i]:SetColor (CWhite)
					qtrckdel[i].Paint = function (self, w, h) end
					qtrckdel[i].DoClick = function () net.Start ("scb_queue_remove") net.WriteTable ({i}) net.SendToServer() end

					if i > 2 then
						qtrckmove[i] = vgui.Create ("DButton", qtrck[i])
						qtrckmove[i]:SetPos (240, 0)
						qtrckmove[i]:SetSize (18,18)
						qtrckmove[i]:SetText ("5")
						qtrckmove[i]:SetFont ("Marlett")
						qtrckmove[i]:SetColor (CWhite)
						qtrckmove[i].Paint = function (self, w, h) end
						qtrckmove[i].DoClick = function () net.Start ("scb_queue_move") net.WriteTable ({i}) net.SendToServer () end
					end

				end

			end
		end
	end
	end

net.Receive ("scb_broadcastplay", function ()

	info = net.ReadTable()

	if scb.tag == "cl" and IsValid (scb.cl_stream) and scb.cl_stream:GetState() == 1 then
		scb.chooser (info)
		sound.PlayURL ("http://api.soundcloud.com/tracks/"..info.id .."/stream?client_id="..scb.reserve_key, "", function (stream)
			if IsValid(scb.sv_stream) then scb.sv_stream:Stop() end
			scb.sv_stream = stream
			scb.sv_stream:SetVolume(0)
		end)
	else
		scb.play_track (info, "sv")
	end

	scb.player_switch (tag)

	end)

net.Receive ("scb_send_queue", function ()

	scb.sv_queue = net.ReadTable()
	if scb.settings.plrsize == "default" and IsValid(QueueF) and QueueF:IsVisible() then scb.player_queue ("sv") end

	end)

hook.Add("OnContextMenuOpen","makesense",function () if IsValid (PlayerFrame) then PlayerFrame:MakePopup(true) end end)
hook.Add("OnContextMenuClose","makenosense",function () if IsValid (PlayerFrame) then PlayerFrame:SetMouseInputEnabled(false) PlayerFrame:SetKeyboardInputEnabled(false) end end)