sql.Query ("CREATE TABLE IF NOT EXISTS soundcloud_player_playlists (Name TEXT, Contents TEXT)")

function scb.playlists_frame (tupe)

	tupe = tupe or "client"

	PlSframe = vgui.Create ("DPanel", BrowserFrame)
	PlSframe:SetPos (1,200)
	PlSframe:SetSize (498,199)
	PlSframe.Paint = function (self,w,h)
		draw.RoundedBox (0,0,0,w,h,CWhite) end

	PlSLocal = vgui.Create ("DButton", PlSframe)
	PlSLocal:SetPos (175,0)
	PlSLocal:SetSize (150,30)
	PlSLocal:SetColor (CDarkGray)
	PlSLocal:SetFont ("SCRoboto24")
	PlSLocal:SetText ("#scp_category_playlists")
	PlSLocal.Paint = function (self,w,h) 
		draw.RoundedBox (0,0,0,w,h,CWhite)
		draw.RoundedBox (0,0,25,w,5,CDarkGray)
		end
	PlSLocal.DoClick = function ()
		if IsValid (PlSListTF) and PlSListTF != nil then PlSListTF:SetVisible (false) PlSListTF:Remove () end
		clPlSListF:SetVisible (true)
		end

	clPlSListF = vgui.Create ("DScrollPanel", PlSframe)
	clPlSListF:SetSize (454,155)
	clPlSListF:SetPos (40,40)
	clPlSListF.Paint = function (self,w,h)
		draw.RoundedBox (0,0,0,w,h,CLightGray) end

	scb.paintscrollbar (clPlSListF)

	scb.cl_plst_opened = tupe
	scb.playlists_load (tupe)

	PlSCreateBtn = vgui.Create ("DButton", PlSframe)
	PlSCreateBtn:SetPos (5,40)
	PlSCreateBtn:SetSize (30, 30)
	PlSCreateBtn:SetText ("")
	PlSCreateBtn.Paint = function (self,w,h)
		draw.RoundedBox (0,0,0,w,h,CDarkGray) 
		draw.RoundedBox (0,4,13,22,4,CWhite) 
		draw.RoundedBox (0,13,4,4,22,CWhite) end
	PlSCreateBtn.DoClick = function () 
		scb.playlist_create () end

	end

function scb.playlists_load ()

	cl_playlists = sql.Query ("#scp_select_name_contents_from_soundcloud_player_playlists")
	if istable (cl_playlists) then
		for i = 1, #cl_playlists do
			scb.create_plst_btn (cl_playlists[i].Name, i, util.JSONToTable (cl_playlists[i].Contents), clPlSListF)
		end
	end

	end

function scb.create_plst_btn (name, pos, contents, parent)

	PlsButton = vgui.Create ("DButton", parent)
	PlsButton:SetSize (454,22)
	PlsButton:SetPos (0,(pos-1)*22)
	PlsButton:SetText (" "..name)
	PlsButton:SetFont ("SCRoboto18")
	PlsButton:SetContentAlignment(4)
	PlsButton:SetColor (CWhite)
	PlsButton:SetVisible (true)
	PlsButton.Paint = function (self,w,h)
		draw.RoundedBox (0,0,0,w,h-2, CGray) end
	PlsButton.DoClick = function () 
		scb.playlist_show (name) 
		end 
	end

function scb.playlist_create ()

	if IsValid(CrPlstframe) and CrPlstframe != nil then CrPlstframe:Remove() end

	CrPlstframe = vgui.Create ("DFrame")
	CrPlstframe:SetSize(200,100)
	CrPlstframe:Center()
	CrPlstframe:SetTitle("#scp_create_playlist")
	CrPlstframe:SetVisible(true)
	CrPlstframe:SetDraggable (false)
	CrPlstframe:ShowCloseButton (true)
	CrPlstframe:MakePopup()
	CrPlstframe.Paint = function (self,w,h)
		draw.RoundedBox (0,0,0,w,h,CGray) surface.SetDrawColor(CBlack) surface.DrawOutlinedRect( 0, 0, w, h) end

	NameEntry = vgui.Create ("DTextEntry", CrPlstframe)
	NameEntry:SetPos (10,30)
	NameEntry:SetFont ("SCRoboto18")
	NameEntry:SetTextColor (CDarkGray)
	NameEntry:SetSize (180,20)
	NameEntry.OnEnter = function () 
		if NameEntry:GetValue() == "" then scb.showerror ("#scp_you_cannot_create_playlist_with_this_name") else
			if sql.Query ("SELECT Contents FROM soundcloud_player_playlists WHERE Name = '"..NameEntry:GetValue().."'") == nil then
				sql.Query ("INSERT INTO soundcloud_player_playlists (Name, Contents) VALUES ('"..NameEntry:GetValue().."', '')") 
				scb.playlists_load ()
				scb.showerror ("#scp_playlist_was_successfully_created")
				if IsValid (ItemPreview) then scb.load_track (scb.gl_info) end
			else scb.showerror ("#scp_playlist_already_exists") 
			end
			CrPlstframe:SetVisible (false)
		end

		end

	CreateBtn = vgui.Create ("DButton", CrPlstframe)
	CreateBtn:SetSize (180,30)
	CreateBtn:SetPos (10,60)
	CreateBtn:SetFont ("SCRoboto24")
	CreateBtn:SetColor (CGray)
	CreateBtn:SetText ("#scp_create_playlist")
	CreateBtn.Paint = function (self,w,h)
		draw.RoundedBox (0,0,0,w,h,CWhite) end

	CreateBtn.DoClick = function ()
		if NameEntry:GetValue() == "" then scb.showerror ("#scp_you_cannot_create_playlist_with_this_name") else
			if sql.Query ("SELECT Contents FROM soundcloud_player_playlists WHERE Name = '"..NameEntry:GetValue().."'") == nil then
				sql.Query ("INSERT INTO soundcloud_player_playlists (Name, Contents) VALUES ('"..NameEntry:GetValue().."', '')") 
				scb.playlists_load ()
				scb.showerror ("#scp_playlist_was_successfully_created")
				if IsValid (ItemPreview) then scb.load_track (scb.gl_info) end
			else scb.showerror ("#scp_playlist_already_exists") 
			end
			CrPlstframe:SetVisible (false)
		end

		end

	end

function scb.playlist_show (name) 

	if IsValid(PlSListTF) and PlSListTF != nil then PlSListTF:Remove() end

	PlSListTF = vgui.Create ("DPanel", PlSframe)
	PlSListTF:SetSize (494,155)
	PlSListTF:SetPos (0,40)
	PlSListTF:SetVisible (true)
	PlSListTF.Paint = function (self,w,h)
		draw.RoundedBox (0,40,0,w-40,h,CWhite)
		draw.RoundedBox (0,40,0,w-40,30,CGray) end

	Namelbl = vgui.Create ("DLabel", PlSListTF)
	Namelbl:SetPos (40, 0)
	Namelbl:SetSize (400, 30)
	Namelbl:SetColor (CWhite)
	Namelbl:SetFont ("SCRoboto24")
	Namelbl:SetText (" "..name)

	BackBut = vgui.Create ("DButton", PlSListTF)
	BackBut:SetPos (5,0)
	BackBut:SetSize (30,30)
	BackBut:SetText ("")
	BackBut:SetVisible (true)
	BackBut.Paint = function (self,w,h)
		draw.RoundedBox (0,0,0,w,h,CDarkGray) 
		draw.RoundedBox (0,6,13,20,4,CWhite) 
		surface.SetDrawColor (CWhite)
		draw.NoTexture ()
		surface.DrawPoly(scb.back1)
		surface.DrawPoly(scb.back2) end
	BackBut.DoClick = function ()
		scb.playlists_frame (scb.cl_plst_opened)
		if IsValid(PlSListTF) and PlSListTF != nil then PlSListTF:SetVisible(false) end
		if IsValid(TrckListF) and TrckListF != nil then TrckListF:Remove() end
		end

	DeleteBut = vgui.Create ("DButton", PlSListTF)
	DeleteBut:SetPos (5,35)
	DeleteBut:SetSize (30,30)
	DeleteBut:SetText ("")
	DeleteBut:SetVisible (true)
	DeleteBut.Paint = function (self,w,h)
		draw.RoundedBox (0,0,0,w,h,CDarkGray) 
		surface.SetDrawColor (CWhite)
		draw.NoTexture ()
		surface.DrawPoly(scb.del1)
		surface.DrawPoly(scb.del2) end
	DeleteBut.DoClick = function ()
		scb.playlist_delete (name)
		end

	RenameBut = vgui.Create ("DButton", PlSListTF)
	RenameBut:SetPos (5,70)
	RenameBut:SetSize (30,30)
	RenameBut:SetText ("")
	RenameBut:SetVisible (true)
	RenameBut.Paint = function (self,w,h)
		draw.RoundedBox (0,0,0,w,h,CDarkGray) 
		draw.RoundedBox (0,6,22,18,1,CWhite) 
		surface.SetDrawColor (CWhite)
		draw.NoTexture ()
		surface.DrawPoly(scb.ren) end
	RenameBut.DoClick = function ()
		scb.playlist_rename (name)
		end

	TrckListF = vgui.Create ("DScrollPanel", PlSListTF)
	TrckListF:SetPos (40,35)
	TrckListF:SetSize (454,120)
	TrckListF.Paint = function (self,w,h)
		draw.RoundedBox (0,0,0,w,h,CLightGray) end
	scb.paintscrollbar (TrckListF, CWhite, CLightGray)

	tempplst = util.JSONToTable (sql.Query ("SELECT Contents FROM soundcloud_player_playlists WHERE Name = '"..name.."'")[1].Contents)

	PlayAllBut = vgui.Create ("DButton", PlSListTF)
	PlayAllBut:SetPos (5,105)
	PlayAllBut:SetSize (30,30)
	PlayAllBut:SetText ("")
	PlayAllBut:SetVisible (true)
	PlayAllBut.Paint = function (self,w,h)
		draw.RoundedBox (0,0,0,w,h,CDarkGray) 
		surface.SetDrawColor (CWhite)
		draw.NoTexture ()
		surface.DrawPoly(scb.largeplays) end
	PlayAllBut.DoClick = function () if #tempplst == 0 then return end
		if scb.settings.admin == 0 then
			scb.queue = {}
			l1, l2, l3 = false, false, false
			for i = 1, #tempplst do
				http.Fetch ("http://api.soundcloud.com/tracks/"..tempplst[i].."?client_id="..scb.primary_key, function ( body, len, headers, code )
					scb.queue[i] = util.JSONToTable(body)
					if i == 1 then l1 = true end
					if i == 2 then l2 = true end
					if l1 and l2 and !l3 then l3 = true scb.play_track (scb.queue[1], "cl") scb.queue_refresh () end
				end)
			end
		else
			net.Start ("scb_adminplaylist")
			net.WriteTable (tempplst)
			net.SendToServer ()
		end

	end

	if istable (tempplst) then 

		tltrcks = 0

		tpnl = vgui.Create ("Panel", PlSListTF)
		tpnl:SetSize (494,155)
		tpnl:SetPos (0,0)
		tpnl:SetVisible (true)
		tpnl.Paint = function (self,w,h)
			draw.RoundedBox (0,0,0,w,h,CTWhite)
			surface.SetDrawColor (CBlack)
			surface.DrawOutlinedRect (134, 89, 222, 12)
			draw.RoundedBox (0,135, 90, (tltrcks/#tempplst)*220, 10, CDarkGray) end

		tlbl = vgui.Create ("DLabel", tpnl)
		tlbl:SetSize (400, 24)
		tlbl:SetPos (40, 30)
		tlbl:SetColor (CDarkGray)
		tlbl:SetContentAlignment(5)
		tlbl:SetFont ("SCRoboto24")

		tnlbl = vgui.Create ("DLabel", tpnl)
		tnlbl:SetSize (400, 24)
		tnlbl:SetPos (40, 60)
		tnlbl:SetColor (CDarkGray)
		tnlbl:SetContentAlignment(5)
		tnlbl:SetFont ("SCRoboto24")

		tpnl.Think = function ()
			tlbl:SetText ("#scp_loading")
			tnlbl:SetText (tltrcks.."/"..#tempplst)

			if tltrcks == #tempplst then tpnl:Remove() end
			end

		end

	TrckLine = {}
	TrckText = {}
	StrtButton = {}
	DelButton = {}
	MoveButton = {}
	trckinfo = {}

	if istable (tempplst) then

		for i = 1, #tempplst do

			if TrckListF:IsVisible () then
			
			http.Fetch ("http://api.soundcloud.com/tracks/"..tempplst[i].."?client_id="..scb.primary_key, function ( body, len, headers, code )

			trckinfo[i] = util.JSONToTable(body) 

			TrckLine[i] = vgui.Create ("DPanel", TrckListF)
			TrckLine[i]:SetPos (0,i*20-18)
			TrckLine[i]:SetSize (454,18)

			DelButton[i] = vgui.Create ("DButton", TrckLine[i])
			DelButton[i]:SetPos (418, 0)
			DelButton[i]:SetSize (18,18)
			DelButton[i]:SetText ("r")
			DelButton[i]:SetFont ("Marlett")
			DelButton[i]:SetColor (CWhite)
			DelButton[i].Paint = function (self, w, h) end
			DelButton[i].DoClick = function () scb.playlist_deletetrack (name, i) end

			TrckText[i] = vgui.Create ("DLabel", TrckLine[i])
			TrckText[i]:SetPos (5, 0)
			TrckText[i]:SetSize (400, 18)
			TrckText[i]:SetColor (CDarkGray)
			TrckText[i]:SetFont ("SCInterstate14B")

			if istable(trckinfo[i]) and istable(trckinfo[i].user) then
				TrckText[i]:SetText (i.." | "..trckinfo[i].user.username.." - "..trckinfo[i].title) 

				StrtButton[i] = vgui.Create ("DButton", TrckLine[i])
				StrtButton[i]:SetSize (425,18)
				StrtButton[i]:SetText ("")
				StrtButton[i].Paint = function () end
				StrtButton[i].DoClick = function () scb.load_track (trckinfo[i]) end

				MoveButton[i] = vgui.Create ("DButton", TrckLine[i])
				MoveButton[i]:SetPos (400, 0)
				MoveButton[i]:SetSize (18,18)
				MoveButton[i]:SetText ("v")
				MoveButton[i]:SetFont ("Marlett")
				MoveButton[i]:SetColor (CWhite)
				MoveButton[i].Paint = function (self, w, h) end
				MoveButton[i].DoClick = function () if IsValid(numentry) and numentry != nil then numentry:Remove() else scb.playlist_movetrack (name, i) end end
			else
				TrckText[i]:SetText ("#scp_error_reload_playlist")
			end 


			tltrcks = tltrcks + 1

			TrckLine[i].Paint = function (self,w,h) if ( IsValid (StrtButton[i]) and StrtButton[i]:IsHovered() ) or DelButton[i]:IsHovered() or ( IsValid (MoveButton[i]) and MoveButton[i]:IsHovered() ) then draw.RoundedBox (0,2,0,w-4,h,CLightGray) else draw.RoundedBox (0,2,0,w-4,h,CWhite) end end

			end)

			end
		end
	end

	end

function scb.playlist_delete (name)

	if IsValid(DlPlstframe) and DlPlstframe != nil then DlPlstframe:SetVisible(false) end

	DlPlstframe = vgui.Create ("DFrame")
	DlPlstframe:SetSize(150,70)
	DlPlstframe:Center()
	DlPlstframe:SetTitle("")
	DlPlstframe:SetVisible(true)
	DlPlstframe:SetDraggable (false)
	DlPlstframe:ShowCloseButton (false)
	DlPlstframe:MakePopup()
	DlPlstframe.Paint = function (self,w,h)
		draw.RoundedBox (0,0,0,w,h,CGray) surface.SetDrawColor(CBlack) surface.DrawOutlinedRect( 0, 0, w, h) end

	DlLbl = vgui.Create ("DLabel", DlPlstframe)
	DlLbl:SetPos (0,0)
	DlLbl:SetSize (150,30)
	DlLbl:SetColor (CWhite)
	DlLbl:SetContentAlignment(5)
	DlLbl:SetFont ("SCRoboto24")
	DlLbl:SetText ("#scp_are_you_sure")

	Btn = vgui.Create ("DButton", DlPlstframe)
	Btn:SetSize (50,25)
	Btn:SetPos (85,35)
	Btn:SetFont ("SCRoboto24")
	Btn:SetColor (CGray)
	Btn:SetText ("#scp_no")
	Btn.Paint = function (self,w,h)
		draw.RoundedBox (0,0,0,w,h,CWhite) end
	Btn.DoClick = function () DlPlstframe:SetVisible (false) end

	Btn = vgui.Create ("DButton", DlPlstframe)
	Btn:SetSize (50,25)
	Btn:SetPos (15,35)
	Btn:SetFont ("SCRoboto24")
	Btn:SetColor (CGray)
	Btn:SetText ("#scp_yes")
	Btn.Paint = function (self,w,h)
		draw.RoundedBox (0,0,0,w,h,CWhite) end
	Btn.DoClick = function ()
		sql.Query ("DELETE FROM soundcloud_player_playlists WHERE Name = '"..name.."'") 
		timer.Simple (0.5, function () if IsValid (ItemPreview) then scb.load_track (scb.gl_info) end end)
		DlPlstframe:SetVisible (false) 
		scb.showerror ("#scp_playlist_was_successfully_deleted")
		scb.playlists_frame (scb.cl_plst_opened)
		end

	end

function scb.playlist_rename (name)

	if IsValid(RnmPlstframe) and RnmPlstframe != nil then RnmPlstframe:SetVisible(false) end

	RnmPlstframe = vgui.Create ("DFrame")
	RnmPlstframe:SetSize(300,100)
	RnmPlstframe:Center()
	RnmPlstframe:SetTitle("#scp_rename_playlist")
	RnmPlstframe:SetVisible(true)
	RnmPlstframe:SetDraggable (false)
	RnmPlstframe:ShowCloseButton (true)
	RnmPlstframe:MakePopup()
	RnmPlstframe.Paint = function (self,w,h)
		draw.RoundedBox (0,0,0,w,h,CGray) surface.SetDrawColor(CBlack) surface.DrawOutlinedRect( 0, 0, w, h) end

	NameEntry = vgui.Create ("DTextEntry", RnmPlstframe)
	NameEntry:SetPos (10,30)
	NameEntry:SetSize (280,20)
	NameEntry:SetText (name)
	NameEntry:SetFont ("SCRoboto18")
	NameEntry.OnEnter = function ()
		if NameEntry:GetValue() == "" then scb.showerror ("#scp_you_cannot_create_playlist_with_this_name") else
			if sql.Query ("SELECT Contents FROM soundcloud_player_playlists WHERE Name = '"..NameEntry:GetValue().."'") == nil then
				sql.Query ("INSERT INTO soundcloud_player_playlists (Name, Contents) VALUES ('"..NameEntry:GetValue().."', '')") 
				scb.playlists_load ()
				scb.showerror ("#scp_playlist_was_successfully_created")
				if IsValid (ItemPreview) then scb.load_track (scb.gl_info) end
			else scb.showerror ("#scp_playlist_already_exists") 
			end
			CrPlstframe:SetVisible (false)
		end

		end

	RnmBtn = vgui.Create ("DButton", RnmPlstframe)
	RnmBtn:SetSize (280,30)
	RnmBtn:SetPos (10,60)
	RnmBtn:SetFont ("SCRoboto24")
	RnmBtn:SetColor (CGray)
	RnmBtn:SetText ("#scp_rename_playlist")
	RnmBtn.Paint = function (self,w,h)
		draw.RoundedBox (0,0,0,w,h,CWhite) end
	RnmBtn.DoClick = function ()
		if NameEntry:GetValue() == nil then scb.showerror ("#scp_you_cannot_name_playlist_like_that") else
			if sql.Query ("SELECT Contents FROM soundcloud_player_playlists WHERE Name = '"..NameEntry:GetValue().."'") == nil then
				sql.Query ("UPDATE soundcloud_player_playlists SET Name = '"..NameEntry:GetValue().."' WHERE Name = '"..name.."'") 
				scb.showerror ("#scp_playlist_was_successfully_renamed")
				Namelbl:SetText (" "..NameEntry:GetValue())
				RnmPlstframe:SetVisible (false)
			else scb.showerror ("#scp_playlist_already_exists") 
			end
		end
		end
	end

function scb.playlist_addtrack (name, id)

	local tplst = util.JSONToTable (sql.Query ("SELECT Contents FROM soundcloud_player_playlists WHERE Name = '"..name.."'")[1].Contents)
	if tplst == nil then
		tplst = {}
		tplst[1] = id
	else
		tplst [#tplst+1] = id
	end
	sql.Query ("UPDATE soundcloud_player_playlists SET Contents = '"..util.TableToJSON (tplst).."' WHERE Name = '"..name.."'")

	scb.showerror ("#scp_done")

	end

function scb.playlist_deletetrack (name, key)

	local tplst = util.JSONToTable (sql.Query ("SELECT Contents FROM soundcloud_player_playlists WHERE Name = '"..name.."'")[1].Contents)
	table.remove (tplst, key)
	sql.Query ("UPDATE soundcloud_player_playlists SET Contents = '"..util.TableToJSON (tplst).."' WHERE Name = '"..name.."'")
	scb.playlist_show (name)

	end

function scb.playlist_movetrack (name, key1)

	if IsValid(numentry) and numentry != nil then numentry:Remove() end

	local tplst = util.JSONToTable (sql.Query ("SELECT Contents FROM soundcloud_player_playlists WHERE Name = '"..name.."'")[1].Contents)

	numentry = vgui.Create ("DTextEntry", TrckListF)
	numentry:SetPos (0,key1*20-18)
	numentry:SetSize (22,18)
	numentry:SetFont ("SCRoboto16")
	numentry.OnEnter = function ()
		if !isnumber (tonumber (numentry:GetText())) then scb.showerror ("#scp_this_is_not_a_number") 
		else
			if tonumber (numentry:GetText()) > #tplst then key2 = #tplst 
			elseif tonumber (numentry:GetText()) < 1 then key2 = 1
			else key2 = tonumber (numentry:GetText()) end
			local cont = tplst[key1]
			table.remove (tplst, key1)
			table.insert (tplst, key2, cont)
			sql.Query ("UPDATE soundcloud_player_playlists SET Contents = '"..util.TableToJSON (tplst).."' WHERE Name = '"..name.."'")
			scb.playlist_show (name)
		end
	end


	end