if CLIENT then
surface.CreateFont("WaypointMarkerFont", {
	font = "Trebuchet MS",
	outline = true,
	size = 26
	
})
end



hook.Add("HUDPaint", "DrawWaypoints", function ()

	local waypoints = ents.FindByClass("waypoint_marker")
	for k,v in ipairs(waypoints) do

		local point = v:GetPos() + v:OBBCenter()
		
		local opacity = (point:DistToSqr(LocalPlayer():GetPos()))^2
		//print(opacity)
		//print(opacity/4)
		local fade = math.Clamp(((opacity/4)/100)*125, 0, 125)
		//print(fade)

		local colors = {
		[1] = Color(255,0,0,fade),
		[2] = Color(0,255,0,fade),
		[3] = Color(0,0,255,fade),
		[4] = Color(255,255,0,fade),
		[5] = Color(255,0,255,fade),
		["black"] = Color(0,0,0,fade)
		}

		//if opacity/4 > 100 then
			local scale = math.Clamp( ( (point:DistToSqr(LocalPlayer():GetPos())) / 500)^2, 15, 20)
			local point2D = point:ToScreen()
			point2D.x = math.Clamp(point2D.x, 0, ScrW())
			point2D.y = math.Clamp(point2D.y, 0, ScrH())
			point2D.visible = true
			local diamond = {
				{x = point2D.x + 0*scale, y = point2D.y + 1*scale}, --up
				{x = point2D.x + 1*scale, y = point2D.y + 0*scale}, --right
				{x = point2D.x + 0*scale, y = point2D.y - 1*scale}, --down
				{x = point2D.x - 1*scale, y = point2D.y + 0*scale} --left
			}
			local border = {
				{x = point2D.x + 0*scale, y = point2D.y + 1.2*scale}, --up
				{x = point2D.x + 1.2*scale, y = point2D.y + 0*scale}, --right
				{x = point2D.x + 0*scale, y = point2D.y - 1.2*scale}, --down
				{x = point2D.x - 1.2*scale, y = point2D.y + 0*scale} --left
			}

			surface.SetDrawColor(colors["black"])
			surface.DrawPoly(border)
			surface.SetDrawColor(colors[v:GetColorType()])
			surface.DrawPoly(diamond)
			draw.SimpleTextOutlined(v:GetWaypointName(), "WaypointMarkerFont", point2D.x, point2D.y + -16-(1*scale), Color(255,255,255,fade),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER, 1, Color(0,0,0,fade))

		end

	//end


end)