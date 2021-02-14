AddCSLuaFile ()
AddCSLuaFile ("scplayer/cl_misc.lua")
AddCSLuaFile ("scplayer/cl_browser.lua")
AddCSLuaFile ("scplayer/cl_player.lua")
AddCSLuaFile ("scplayer/cl_playlists.lua")
AddCSLuaFile ("scplayer/cl_queue.lua")

scb = {}

scb.reserve_key = ("723bb3b64d04057d0c11ae48cc57ab80") -- sorry :c
scb.primary_key = ("831fdf2953440ea6e18c24717406f6b2")



if SERVER then
	
	scb.queue = {}

	resource.AddSingleFile("resource/fonts/GLInterstate-Regular.TTF")

	resource.AddSingleFile("materials/scplayer/sc_logo.png")
	resource.AddSingleFile("materials/scplayer/scplayer_logo.png")

	include ("scplayer/sv_scplayer.lua")

	concommand.Add ("scplayer_reset", function () scb.queue = {} end)

else

	scb.settings = {}
	scb.queue = {}
	scb.sv_queue = {}
	scb.tag = "cl"
	scb.finished = true
	scb.pos = {100, 30}

	if !file.Exists ("soundcloudplayer", "DATA") then file.CreateDir("soundcloudplayer") file.Write ("soundcloudplayer/settings.txt" , util.TableToJSON ( {admin = 0, volume = 100, visualizer = 0, plrsize = "default"} ) )  end
	scb.settings = util.JSONToTable ( file.Read ("soundcloudplayer/settings.txt"))

	include ("scplayer/cl_queue.lua")
	include ("scplayer/cl_misc.lua")
	include ("scplayer/cl_browser.lua")
	include ("scplayer/cl_player.lua")
	include ("scplayer/cl_playlists.lua")

	list.Set("DesktopWindows", "scplayer", {
		title="#scp_title",
		icon="scplayer/scplayer_logo.png",
		onewindow= true,
		init=function(icon, window)
			window:Remove()
			RunConsoleCommand("scplayer") 
		end
		})

	concommand.Add ("scplayer_reset", function () scb.queue = {} scb.sv_queue = {} scb.cl_stream = nil scb.sv_stream = nil end)

end