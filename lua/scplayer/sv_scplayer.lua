util.AddNetworkString("scb_adminplay")
util.AddNetworkString("scb_adminqueue")
util.AddNetworkString("scb_adminplaylist")
util.AddNetworkString("scb_queue_remove")
util.AddNetworkString("scb_queue_move")

util.AddNetworkString("scb_send_queue")
util.AddNetworkString("scb_broadcastplay")

function scb.queue_playtrack (info)

	curtimell = 0
	timer.Create ("scb_curtime", 1, math.floor(info.duration/1000) , function () curtimell = curtimell + 1 end)

	scb.queue_refresh ()

	net.Start ("scb_broadcastplay")
	net.WriteTable (info)
	net.Broadcast ()

	end

function scb.queue_refresh ()

	if istable(scb.queue[2]) then 
		timer.Create ("scb_queue", timer.RepsLeft("scb_curtime"), 1, function () 
			if istable(scb.queue[2]) then scb.queue_playtrack (scb.queue[2]) end 
			table.remove (scb.queue, 1)
			scb.queue_send ()
			end) 
		end
	scb.queue_send ()
	end

function scb.queue_addtrack (info, pos)

	pos = pos or "1"

	if pos == "1" then
		scb.queue[1] = info
		scb.queue_playtrack (info)
	else
		scb.queue[#scb.queue+1] = info
	end

	scb.queue_refresh ()

	end

function scb.queue_send ()
		
	templst = {}

	for i = 1, #scb.queue do
		if istable (scb.queue[i]) then
			templst[i] = {}
			templst[i].user = {} 
			templst[i].id = scb.queue[i].id
			templst[i].title = scb.queue[i].title
			templst[i].duration = scb.queue[i].duration
			templst[i].permalink_url = scb.queue[i].permalink_url
			templst[i].artwork_url = scb.queue[i].artwork_url
			templst[i].user.avatar_url = scb.queue[i].user.avatar_url
			templst[i].user.username = scb.queue[i].user.username
		end
	end
	
	net.Start ("scb_send_queue")
	net.WriteTable (templst)
	net.Broadcast ()

	end

net.Receive ("scb_adminplay", function (len, ply)
	if ply:IsSuperAdmin() then
		scb.queue_addtrack (net.ReadTable())
	end
	end)

net.Receive ("scb_adminqueue", function (len, ply)
	if ply:IsSuperAdmin() then
		scb.queue_addtrack (net.ReadTable(), "last")
	end
	end)

net.Receive ("scb_adminplaylist", function (len, ply)

	if ply:IsSuperAdmin() then

		l1, l2, l3 = false, false, false
		scb.queue = {}
		if timer.Exists ("scb_queue") then timer.Stop ("scb_queue") end
		tempplst = net.ReadTable()

			if #tempplst == 0 then 
				return
			elseif #tempplst == 1 then 
				http.Fetch ("http://api.soundcloud.com/tracks/"..tempplst[1].."?client_id="..scb.primary_key, function ( body, len, headers, code ) 
					scb.queue[1] = util.JSONToTable(body) 
					scb.queue_playtrack (scb.queue[1]) 
				end)
			else
				for i = 1, #tempplst do
					http.Fetch ("http://api.soundcloud.com/tracks/"..tempplst[i].."?client_id="..scb.primary_key, function ( body, len, headers, code )
						scb.queue[i] = util.JSONToTable(body)
						scb.queue_send ()
						if i == 1 then l1 = true end
						if i == 2 then l2 = true end
						if l1 and l2 and !l3 then l3 = true scb.queue_playtrack (scb.queue[1]) end
					end)
				end
			end
	end
	end)

net.Receive ("scb_queue_remove", function (len, ply)
	if ply:IsSuperAdmin() then
		local pos = net.ReadTable()[1]
		table.remove (scb.queue, pos)
		if pos == 1 then 
			if istable (scb.queue[1]) then 
				scb.queue_playtrack (scb.queue[1]) 
			end 
		end
		scb.queue_refresh ()
	end
	end)

net.Receive ("scb_queue_move", function (len, ply)
	if ply:IsSuperAdmin() then
		local pos = net.ReadTable()[1]
		table.insert (scb.queue, 2, scb.queue[pos])
		table.remove (scb.queue, pos+1)
		scb.queue_refresh ()
	end
	end)