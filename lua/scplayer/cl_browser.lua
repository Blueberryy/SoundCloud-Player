if game.SinglePlayer() then scb.settings.admin = 0 end

function scb.openframe ()
	if !LocalPlayer():IsSuperAdmin() and scb.settings.admin == 1 then scb.settings.admin = 0 end

	if IsValid (BrowserFrame) and BrowserFrame != nil then return end

	if IsValid (PlayerFrame) and PlayerFrame != nil then PlayerFrame:MakePopup () end

	BrowserFrame = vgui.Create ("DFrame")
		BrowserFrame:SetSize(500,400)
		BrowserFrame:Center()
		BrowserFrame:SetTitle("#scp_browser_title")
		BrowserFrame:SetVisible(true)
		BrowserFrame:SetDraggable (false)
		BrowserFrame:ShowCloseButton (false)
		BrowserFrame:MakePopup()
		BrowserFrame:ParentToHUD ()
		BrowserFrame.Paint = function (self,w,h)
			draw.RoundedBox (0,0,0,500,24,CDarkGray)
			draw.RoundedBox (0,0,60,500,140,CLightGray)
			draw.RoundedBox (0,0,24,500,36,CWhite)
			draw.RoundedBox (0,0,60,500,h-60,CNil)
			draw.RoundedBox (0,499,0,1,h,CBlack)
			surface.SetDrawColor(CBlack)
			surface.DrawOutlinedRect( 0, 0, w, h)
			surface.SetDrawColor(CDarkGray)
			surface.DrawOutlinedRect( 89, 30, 341, 24) end

	CloseButton = vgui.Create ("DButton", BrowserFrame)
		CloseButton:SetPos (476, 0)
		CloseButton:SetSize (20,24)
		CloseButton:SetText ("r")
		CloseButton:SetFont ("Marlett")
		CloseButton:SetColor (CWhite)
		CloseButton.DoClick = function () BrowserFrame:Remove () if IsValid (PlayerFrame) then PlayerFrame:SetMouseInputEnabled(false) PlayerFrame:SetKeyboardInputEnabled(false) end end
		CloseButton.Paint = function (self, w, h) draw.RoundedBox (0,0,0,w,h,CNil) end



	LinkInput = vgui.Create ("DTextEntry", BrowserFrame)
		LinkInput:SetPos (90,31)
		LinkInput:SetSize (340,22)
		LinkInput:SetFont ("SCRoboto18")
		LinkInput.OnEnter = function ()
			if string.match (LinkInput:GetText(), "soundcloud.com") then scb.checklink (LinkInput:GetText())
			elseif LinkInput:GetText() == "" then scb.showerror ("#scp_enter_something_to_search")
			else scb.search (LinkInput:GetText(), "tracks") end
		end

	LoadButton = vgui.Create ("DButton", BrowserFrame)
		LoadButton:SetPos (430, 30)
		LoadButton:SetSize (60,24)
		LoadButton:SetText ("#scp_load")
		LoadButton:SetFont ("SCRoboto18")
		LoadButton:SetColor (CWhite)
		LoadButton.Paint = function (self,w,h)
			draw.RoundedBoxEx (8,0,0,w,h,CDarkGray,false,true,false,true) end
		LoadButton.DoClick = function ()
			scb.checklink (LinkInput:GetText ())
		end

	SearchButton = vgui.Create ("DButton", BrowserFrame)
		SearchButton:SetPos (10, 30)
		SearchButton:SetSize (80,24)
		SearchButton:SetText ("#scp_search")
		SearchButton:SetFont ("SCRoboto18")
		SearchButton:SetColor (CWhite)
		SearchButton.Paint = function (self,w,h)
			draw.RoundedBoxEx (8,0,0,w,h,CDarkGray,true,false,true,false) end
		SearchButton.DoClick = function ()
			if LinkInput:GetText() == "" then scb.showerror ("#scp_enter_something_to_search")
			elseif !string.match(LinkInput:GetText (),"soundcloud.com") then scb.search (LinkInput:GetText (), "tracks")
			else scb.showerror ("#scp_you_cannot_search_a_link") end 
		end

	if LocalPlayer():IsSuperAdmin() and !game.SinglePlayer() then
		AdminButton = vgui.Create ("DButton", BrowserFrame)
		AdminButton:SetPos (400, 0)
		AdminButton:SetSize (60,24)
		AdminButton:SetText ("#scp_admin")
		AdminButton:SetFont ("SCRoboto18")
		AdminButton.Paint = function (self, w, h) draw.RoundedBox (0,0,0,w,h,CNil) end
		if scb.settings.admin == 0 then 
			AdminButton:SetColor (CLightGray)
		else
			AdminButton:SetColor (CRed)
		end
		AdminButton.DoClick = function () 
			if scb.settings.admin == 1 then 
				AdminButton:SetColor (CLightGray)
				scb.settings.admin = 0 scb.showerror ("#scp_admin_mode_deactivated")
			else
				AdminButton:SetColor (CRed)
				scb.settings.admin = 1 scb.showerror ("#scp_admin_mode_activated") 
			end
			scb.changesettings () 
		end
	end

	scb.playlists_frame ()
	scb.playlists_load ()

	end

--Search & Load Functions--

function scb.checklink (data)
	if !string.match (data, "soundcloud.com") then scb.showerror ("#scp_provide_a_soundcloud_link")
	else
		http.Fetch ("http://api.soundcloud.com/resolve.json?url="..data.."&client_id="..scb.primary_key, function ( body, len, headers, code )
			body = util.JSONToTable(body)
			if isstring(body) or istable(body) and body != nil then
				if body.errors != nil then scb.showerror ("#scp_the_link_is_not_supported") else
					if body.kind == "user" then scb.load_user (body)
					elseif body.streamable == nil or body.streamable == false then scb.showerror ("#scp_the_track_cant_be_streamed")
					elseif body.kind == "track" then scb.load_track (body) 
					elseif body.kind == "playlist" then scb.load_playlist (body) 
					else scb.showerror ("#scp_this_link_type_is_not_supported") end
				end
			else scb.showerror ("#scp_the_link_or_track_is_not_supported") end
		end, function () scb.showerror ("#scp_the_link_is_not_supported") end)
	end
	end

function scb.search (text, tupe)

	tupe = tupe or "track"

	local texttable = {}

	for i = 1, string.len (text) do 
		texttable[i] = string.format("%X",(string.byte( text, i, i )))
	end

	local ltext = "%"..string.Implode ("%", texttable)

	http.Fetch ("http://api.soundcloud.com/"..tupe..".json?client_id="..scb.primary_key.."&q="..ltext.."&linked_partitioning=1&limit=30", 
		function ( body, len, headers, code )
			scb.search_results (util.JSONToTable(body), tupe, text)
		end)

	end

function scb.search_next (data, tupe, text)
	http.Fetch (data, function ( body, len, headers, code )
		scb.search_results (util.JSONToTable(body), tupe, text)
	end)
	end

function scb.search_results (data, tupe, text)

	scb.headercloser ()

	if IsValid (SearchOptionsFrame) and SearchOptionsFrame != nil then SearchOptionsFrame:SetVisible (false) end

	SearchOptionsFrame = vgui.Create ("DPanel", BrowserFrame)
	SearchOptionsFrame:SetSize(300,40)
	SearchOptionsFrame:SetPos(500,0)
	SearchOptionsFrame:SetVisible(true)
	SearchOptionsFrame.Paint = function (self,w,h) 
		draw.RoundedBox (0,0,0,w,1,CBlack)
	end

		TracksCat = vgui.Create ("DButton", SearchOptionsFrame)
		if tupe == "tracks" then catstate = true else catstate = false end
		scb.searchcats (TracksCat, "#scp_category_tracks", 1, catstate, "search")
		TracksCat.DoClick = function () scb.search (text, "tracks") end

		PlaylistsCat = vgui.Create ("DButton", SearchOptionsFrame)
		if tupe == "playlists" then catstate = true else catstate = false end
		scb.searchcats (PlaylistsCat, "#scp_category_playlists", 2, catstate, "search")
		PlaylistsCat.DoClick = function () scb.search (text, "playlists") end

		UsersCat = vgui.Create ("DButton", SearchOptionsFrame)
		if tupe == "users" then catstate = true else catstate = false end
		scb.searchcats (UsersCat, "#scp_category_users", 3, catstate, "search")
		UsersCat.DoClick = function () scb.search (text, "users") end

	scb.createitemlist (data, tupe, "search", text)

	end

function scb.headercloser ()
		
	BrowserFrame:SizeTo (800,400,0.5)
	BrowserFrame:MoveTo ((ScrW()-800)/2,(ScrH()-400)/2,0.5)

	if IsValid (SearchOptionsFrame) and SearchOptionsFrame != nil then SearchOptionsFrame:SetVisible (false) end
	if IsValid (PlaylistPreview) and PlaylistPreview != nil then PlaylistPreview:SetVisible (false) end
	if IsValid (UserPreview) and UserPreview != nil then UserPreview:SetVisible (false) end

	if IsValid (ItemList) and ItemList != nil then ItemList:SetVisible (false) end

	end

function scb.load_track (info) 

	scb.gl_info = info

	if IsValid (ItemPreview) and ItemPreview != nil then ItemPreview:Remove ()end

	ItemPreview = vgui.Create ("DPanel", BrowserFrame)
	ItemPreview:SetSize (0,140)
	ItemPreview:SizeTo (499,140,0.3)
	ItemPreview:SetPos (0,60)
	ItemPreview:SetVisible (true)

	SCImage = vgui.Create("DImage", ItemPreview)
		SCImage:SetSize (104, 32)
		SCImage:SetPos (394, 48)
		SCImage:SetImage ("scplayer/sc_logo.png")

	http.Fetch (info.artwork_url, function ( body, len, headers, code )
		if string.match (body, "cannot find original") then 
			if info.user.avatar_url == nil then info.new_artwork_url = defart100
			else info.new_artwork_url = info.user.avatar_url end
		TrackPic:OpenURL(info.new_artwork_url)
		end
		end)

	AddToPlst = vgui.Create ("DPanel", ItemPreview)
	AddToPlst:SetPos (50, 101)
	AddToPlst:SetSize (150,0)
	AddToPlst:SizeTo (150,40,0.2,0.3)
	AddToPlst.Paint = function (self,w,h) 
		draw.RoundedBox (0,0,0,w-1,h,CDarkGray)
		draw.RoundedBox (0,w-1,0,1,h,CBlack)  end
	AddToPlst.OnCursorEntered = function ()
		ItemPreview:MoveToFront()
		AddToPlst:MoveToFront()
		AddToPlst:SizeTo (150, 120, 0.1)
		ItemPreview:SizeTo (499, 220, 0.1)
	end
	AddToPlst.Think = function ()
		if (AddToPlst:CursorPos () > 160 or select (2, AddToPlst:CursorPos ()) > 120 or AddToPlst:CursorPos () < 0 or select (2, AddToPlst:CursorPos ()) < 0) and ItemPreview:GetTall () > 140 then 
			AddToPlst:SizeTo (150, 40, 0.1)
			ItemPreview:SizeTo (499, 140, 0.1)
		end
	end

	ATPlbl = vgui.Create ("DLabel", AddToPlst)
	ATPlbl:SetSize (150, 40)
	ATPlbl:SetContentAlignment (5)
	ATPlbl:SetText ("#scp_add_to_playlist")
	ATPlbl:SetFont ("SCRoboto24")
	ATPlbl:SetColor (CWhite)

	ATPlst = vgui.Create ("DScrollPanel", AddToPlst)
	ATPlst:SetSize (150, 80)
	ATPlst:SetPos (0,39)
	ATPlst.Paint = function (self, w, h)
		draw.RoundedBox (0,0,0,w,h,CNil)
	end
	scb.paintscrollbar (ATPlst)

	if istable (cl_playlists) then
		for i = 1, #cl_playlists do
			local plst = vgui.Create ("DButton", ATPlst)
			plst:SetPos (2, (i-1)*20)
			plst:SetSize (146, 20)
			plst:SetText (" "..cl_playlists[i].Name)
			plst:SetFont ("SCRoboto16")
			plst:SetContentAlignment(4)
			plst:SetColor (CWhite)
			plst.Paint = function (self, w, h)
				draw.RoundedBox (0,0,0,w,h-2, CGray) end
			plst.DoClick = function () 
				scb.playlist_addtrack (cl_playlists[i].Name, info.id)
				scb.playlist_show (cl_playlists[i].Name)  end
		end
	end


	PlayBtn = vgui.Create ("DButton", ItemPreview)
	PlayBtn:SetPos (200, 101)
	PlayBtn:SetSize (100,0)
	PlayBtn:SizeTo (100,39,0.2,0.4)
	PlayBtn:SetText ("#scp_play")
	PlayBtn:SetFont ("SCRoboto24")
	PlayBtn:SetColor (CWhite)
	PlayBtn.Paint = function (self,w,h) 
		draw.RoundedBox (0,0,0,w,h,CDarkGray)
		draw.RoundedBox (0,w-1,0,1,h,CBlack)  end
	PlayBtn.DoClick = function () 
		if scb.settings.admin == 0 then 
			scb.queue[1] = info 
			if IsValid (scb.cl_stream) then scb.cl_stream:Stop() end
			scb.play_track (scb.queue[1], "cl") 
			scb.queue_refresh ()
		else
			net.Start ("scb_adminplay") net.WriteTable (info) net.SendToServer() 
		end
	end

	AddToQueueBtn = vgui.Create ("DButton", ItemPreview)
	AddToQueueBtn:SetPos (300, 101)
	AddToQueueBtn:SetSize (150,0)
	AddToQueueBtn:SizeTo (150,39,0.2,0.5)
	AddToQueueBtn:SetText ("#scp_add_to_queue")
	AddToQueueBtn:SetFont ("SCRoboto24")
	AddToQueueBtn:SetColor (CWhite)
	AddToQueueBtn.Paint = function (self,w,h) 
		draw.RoundedBox (0,0,0,w,h,CDarkGray)  end
	AddToQueueBtn.DoClick = function () 
		if scb.settings.admin == 0 then 
			scb.queue_addtrack (info) 
		else
			net.Start ("scb_adminqueue") 
			net.WriteTable (info) 
			net.SendToServer()
		end
		scb.notify ("player")
	end

	TrackPic = vgui.Create ("HTML", ItemPreview)
	TrackPic:SetPos (1,1)
	TrackPic:SetSize (120,120)
	if info.artwork_url == nil then 
		if info.user.avatar_url == nil then
			info.artwork_url = defart100
		else info.artwork_url = info.user.avatar_url end
	end
	TrackPic:OpenURL(info.artwork_url)

	TrackArtist = vgui.Create ("DLabel", ItemPreview)
	TrackArtist:SetPos (112,5)
	TrackArtist:SetSize (scb.gettextlen (info.user.username, "SCInterstate18"),20)
	TrackArtist:SetFont ("SCInterstate18")
	TrackArtist:SetColor (CBWhite)
	TrackArtist:SetText (info.user.username)
	TrackArtist:SetMouseInputEnabled(true)
	TrackArtist.DoClick = function () 
		scb.headercloser ()
		http.Fetch ("http://api.soundcloud.com/resolve.json?url="..info.user.permalink_url.."&client_id="..scb.primary_key, function ( body, len, headers, code ) scb.load_user (util.JSONToTable(body)) end)
	end
	TrackArtist.Paint = function () if TrackArtist:IsHovered() then TrackArtist:SetColor (CLightGray) else TrackArtist:SetColor (CBWhite) end end

	TrackTitle = vgui.Create ("DLabel", ItemPreview)
	TrackTitle:SetPos (112,31)
	TrackTitle:SetSize (scb.gettextlen (info.title, "SCInterstate24"),24)
	TrackTitle:SetFont ("SCInterstate24")
	TrackTitle:SetColor (CBWhite)
	TrackTitle:SetText (info.title)
	TrackTitle:SetMouseInputEnabled (true)
	TrackTitle.DoClick = function () gui.OpenURL (info.permalink_url) end
	TrackTitle.Paint = function () if TrackTitle:IsHovered() then TrackTitle:SetColor (CLightGray) else TrackTitle:SetColor (CBWhite) end end

	TrackCreated = vgui.Create ("DLabel", ItemPreview)
	TrackCreated:SetPos (420,83)
	TrackCreated:SetSize (80,14)
	TrackCreated:SetFont ("SCRoboto16")
	TrackCreated:SetColor (CGray)

	local date = string.Explode("/", string.Explode (" ", info.created_at)[1])
	date [1], date [3] = date [3], date [1]
	TrackCreated:SetText (string.Implode(".", date))

	TrackLen = vgui.Create ("DLabel", ItemPreview)
	TrackLen:SetPos (110,83)
	TrackLen:SetSize (390,14)
	TrackLen:SetFont ("SCRoboto16")
	TrackLen:SetColor (CGray)
	local trcklen = (math.floor(tonumber(info.duration)/1000))
	local trckhr = math.floor (trcklen/3600)
	local trckmin = math.floor (trcklen/60-trckhr*60)
	local trcksec = math.floor (trcklen-trckhr*3600-trckmin*60)
		if trcksec < 10 then trcksec = tostring ("0"..trcksec) end
	if trckhr == 0 then TrackLen:SetText (trckmin..":"..trcksec)
	else if trckmin < 10 then trckmin = tostring ("0"..trckmin) end
		TrackLen:SetText (trckhr..":"..trckmin..":"..trcksec) end

	TrackPlays = vgui.Create ("DLabel", ItemPreview)
	TrackPlays:SetPos (200, 83)
	TrackPlays:SetSize (50, 14)
	TrackPlays:SetFont ("SCRoboto16")
	TrackPlays:SetColor (CGray)
		info.playback_count = tonumber(info.playback_count)
			pc_mil = math.floor(info.playback_count/1000000)
			pc_huntho = (math.floor(info.playback_count/10000)-pc_mil*100)
			if pc_huntho <10 then pc_huntho = "0"..pc_huntho end
			if pc_huntho/10 == math.floor(pc_huntho/10) then pc_huntho = pc_huntho/10 end
			pc_mil = pc_mil.."."..pc_huntho.."M"
			pc_tho = math.floor(info.playback_count/1000)
			if (math.floor(info.playback_count/100)-pc_tho*10) == 0 then pc_tho = pc_tho.."K"
			else pc_tho = pc_tho.."."..(math.floor(info.playback_count/100)-pc_tho*10).."K" end
			pc_hun = info.playback_count - math.floor(info.playback_count/1000)*1000
			if pc_hun <10 then pc_hun = "00"..pc_hun
			elseif pc_hun <100 then pc_hun = "0"..pc_hun end
		if info.playback_count >= 1000000 then info.smartplays = pc_mil
		elseif info.playback_count >= 100000 then info.smartplays = math.floor(info.playback_count/1000).."K"
		elseif info.playback_count >= 10000 then info.smartplays = pc_tho
		elseif info.playback_count >= 1000 then info.smartplays = math.floor(info.playback_count/1000)..","..pc_hun
		else info.smartplays = info.playback_count end
	TrackPlays:SetText (info.smartplays)

	ItemPreview.Paint = function (self,w,h) 
		draw.RoundedBox (0,105,5,TrackArtist:GetTextSize()+14,22,CTBlack)
		draw.RoundedBox (0,105,30,TrackTitle:GetTextSize()+14,28,CTBlack)
		draw.RoundedBox (0,0,0,w,1,CBlack)
		draw.RoundedBox (0,1,80,w-2,21,CWhite)
		surface.SetDrawColor (CGray)
		draw.NoTexture ()
		surface.DrawPoly(scb.littleplays)
	end

	end

function scb.load_user (info, tupe)

	tupe = tupe or "tracks"

	scb.headercloser ()

	UserPreview = vgui.Create ("DPanel", BrowserFrame)
	UserPreview:SetSize(300,100)
	UserPreview:SetPos(500,0)
	UserPreview:SetVisible(true)

	UserPic = vgui.Create ("HTML", UserPreview)
	UserPic:SetPos (0,1)
	UserPic:SetSize (120,120)
	if info.avatar_url == nil then info.avatar_url = defart100 end
	UserPic:OpenURL(info.avatar_url)

	UserName = vgui.Create ("DLabel", UserPreview)
	UserName:SetPos (112,11)
	UserName:SetSize (190,24)
	UserName:SetFont ("SCInterstate24")
	UserName:SetColor (CBWhite)
	UserName:SetText (info.username)
	UserName:SetMouseInputEnabled(true)
	UserName.DoClick = function () gui.OpenURL (info.permalink_url) end

	UserPreview.Paint = function (self,w,h) 
		draw.RoundedBox (0,0,0,w,h-20,CLightGray)
		draw.RoundedBox (0,105,5,UserName:GetTextSize()+14,38,CTBlack)
		draw.RoundedBox (0,0,0,w,1,CBlack)
		draw.RoundedBox (0,0,101,w,1,CBlack)
	end

	http.Fetch ("http://api.soundcloud.com/users/"..info.id.."/"..tupe.."?client_id="..scb.primary_key, function ( body, len, headers, code )
		scb.createitemlist (util.JSONToTable(body), "tracks", "usertracks") 
		end)

		TracksCat = vgui.Create ("DButton", UserPreview)
		if tupe == "tracks" then catstate = true else catstate = false end
		scb.searchcats (TracksCat, "#scp_category_tracks", 2, catstate, "usertracks")
		TracksCat.DoClick = function () 
			tupe = "tracks"
			scb.load_user (info, tupe)
			end

		PlaylistsCat = vgui.Create ("DButton", UserPreview)
		if tupe == "playlists" then catstate = true else catstate = false end
		scb.searchcats (PlaylistsCat, "#scp_category_playlists", 3, catstate, "userplsts")
		PlaylistsCat.DoClick = function () 
			tupe = "playlists"
			scb.load_user (info, tupe)
			end

	end

function scb.load_playlist (info)

	scb.headercloser ()

	PlaylistPreview = vgui.Create ("DPanel", BrowserFrame)
	PlaylistPreview:SetSize(300,100)
	PlaylistPreview:SetPos(500,0)
	PlaylistPreview:SetVisible(true)

	PlaylistPic = vgui.Create ("HTML", PlaylistPreview)
	PlaylistPic:SetPos (0,1)
	PlaylistPic:SetSize (120,120)
		if info.artwork_url == nil then 
			if info.user.avatar_url == nil then info.user.avatar_url = defart47
			else info.artwork_url = info.user.avatar_url end
		end
	PlaylistPic:OpenURL(info.artwork_url)

	PlaylistAuthor = vgui.Create ("DLabel", PlaylistPreview)
	PlaylistAuthor:SetPos (112,12)
	PlaylistAuthor:SetSize (190,18)
	PlaylistAuthor:SetFont ("SCInterstate18")
	PlaylistAuthor:SetColor (CBWhite)
	PlaylistAuthor:SetText (info.user.username)
	PlaylistAuthor:SetMouseInputEnabled(true)
	PlaylistAuthor.DoClick = function () gui.OpenURL (info.user.permalink_url) end

	PlaylistTitle = vgui.Create ("DLabel", PlaylistPreview)
	PlaylistTitle:SetPos (112,37)
	PlaylistTitle:SetSize (190,24)
	PlaylistTitle:SetFont ("SCInterstate24")
	PlaylistTitle:SetColor (CBWhite)
	PlaylistTitle:SetText (info.title)
	PlaylistTitle:SetMouseInputEnabled(true)
	PlaylistTitle.DoClick = function () gui.OpenURL (info.permalink_url) end

	PlaylistPreview.Paint = function (self,w,h) 
		draw.RoundedBox (0,0,0,w-1,h,CLightGray)
		draw.RoundedBox (0,105,10,PlaylistAuthor:GetTextSize()+14,22,CTBlack)
		draw.RoundedBox (0,105,36,PlaylistTitle:GetTextSize()+14,28,CTBlack)
		draw.RoundedBox (0,0,0,w,1,CBlack)
		draw.RoundedBox (0,0,101,w,1,CBlack)
		end

	scb.createitemlist (info.tracks, "tracks", "plsttracks") 

	ConvertBtn = vgui.Create ("DButton", PlaylistPreview)
	ConvertBtn:SetPos (100,80)
	ConvertBtn:SetSize (199,20)
	ConvertBtn:SetText ("#scp_convert_to_local_playlist")
	ConvertBtn:SetColor (CDarkGray)
	ConvertBtn:SetFont ("SCRoboto18")
	ConvertBtn.Paint = function (self,w,h) 
		draw.RoundedBox (0,0,0,w,h,CWhite)
		end
	ConvertBtn.DoClick = function () 
		if sql.Query ("SELECT Contents FROM soundcloud_player_playlists WHERE Name = '"..info.title.."'") == nil then
			sql.Query ("INSERT INTO soundcloud_player_playlists (Name, Contents) VALUES ('"..info.title.."', '')") 
			scb.showerror ("#scp_playlist_was_successfully_created")
			for i = 1, #info.tracks do
				scb.playlist_addtrack (info.title, info.tracks[i].id) 
			end
			scb.playlists_load ()
		else scb.showerror ("#scp_playlist_already_exists") 
		end
		end 
	end

concommand.Add ("scplayer", scb.openframe)