function scb.queue_addtrack (info)

	scb.queue[#scb.queue+1] = info

	if #scb.queue == 1 then scb.play_track (scb.queue[1], "cl") end

	scb.queue_refresh ()

	end

function scb.queue_refresh ()

	if IsValid (scb.cl_stream) then curtime = math.floor (scb.cl_stream:GetTime()) else curtime = 0 end 

		timer.Create ("scb_queue", scb.queue[1].duration/1000 - curtime, 1, function ()
			
			if istable(scb.queue[2]) then scb.play_track (scb.queue[2], "cl") end 
			table.remove (scb.queue, 1)
		end) 
	end