--
-- A test project of a verlet engine for a kendama simulator / game
-- This project utilizes verlet integration and the separating axis theorem to create a 2D physics simulation of the japanese yo-yo like toy, kendama
--


-----------------------------------------------------------------------------------------------------------------------
-- Corona SDK Initializations
-----------------------------------------------------------------------------------------------------------------------
local composer = require( "composer" )
local scene = composer.newScene()
display.setStatusBar( display.HiddenStatusBar ) 

-- Sets the background
local background = display.newRect( 0, 0, display.contentWidth, display.contentHeight )
background.anchorX = 0
background.anchorY = 0
background:setFillColor( .98 )

-- This block variable is used to generate the points in line with the display width/height
local block = display.contentWidth / 20

-- The dama object (ball)
local dama = display.newImageRect( "Dama.png", 40, 40 )
dama.x, dama.y = 160, 325

-- The ken object (cups)
local ken = display.newImageRect( "Ken.png", block * 4, block * 8 )
ken.anchorX = 0.5
ken.anchorY = 0.25

-- Text to display what collision is occuring
local text = display.newText( "", 160, 40, native.systemFontBold, 12 )
text:setFillColor(0, 0, 0)

-- Test lines array (table) to hold the rendered lines
local testLines = {}

-----------------------------------------------------------------------------------------------------------------------
-- Verlet Engine Attributes
-----------------------------------------------------------------------------------------------------------------------
local verletEngine = {}
verletEngine["vPoints"] = {}
verletEngine["vLines"] = {}
verletEngine["vBodies"] = {}
verletEngine["vCBodies"] = {}
verletEngine["vCenters"] = {}
verletEngine["vNormals"] = {}
verletEngine["vBounce"] = 0.5
verletEngine["vGravity"] = 0.3
verletEngine["vFriction"] = 0.95
verletEngine["vIterations"] = 4

-----------------------------------------------------------------------------------------------------------------------
-- Verlet Engine Functions
-----------------------------------------------------------------------------------------------------------------------

-- Adds a new point to the verlet engine
-- Parameters include the current position, previous position, and "clickability" of the point
function verletEngine.addPoint(currX, currY, prevX, prevY, clickable)
	local point = { x = currX, y = currY, oldx = prevX, oldy = prevY, touch = clickable  }
	table.insert(verletEngine.vPoints, point)
end

-- Creates a line linking two points together
function verletEngine.addLine( point1, point2 )
	local dx = point2.x - point1.x
	local dy = point2.y - point1.y
	local distance =  math.sqrt(dx * dx + dy * dy)
	local line = { p0 = point1, p1 = point2, length = distance }
	table.insert(verletEngine.vLines, line)
end

-- Creates a body between a set of points that do not interact (collide) with other bodies
function verletEngine.addBody( points )
	table.insert(verletEngine.vBodies, points)
end

-- Creates a collision body between a set of points that can be physically collide with other collision bodies
function verletEngine.addCBody( points )
	table.insert(verletEngine.vCBodies, points)
end

-- Adds specific points to a list to be used by the verlet engine as the center of bodies
function verletEngine.addCenters( point )
	table.insert(verletEngine.vCenters, point)
end

-- Called on every frame, this function updates the new positions of the verlet points and checks/remediates any collisions that occur
local function onEveryFrame( event )
	verletEngine.updatePoints()
	for i = 1, verletEngine.vIterations do
		verletEngine.updateLines()
		verletEngine.constrainPoints()
	end
	local x = verletEngine.vPoints[46].x - verletEngine.vPoints[47].x
	local y = verletEngine.vPoints[46].y - verletEngine.vPoints[46].y
	local distance = math.sqrt(x*x + y*y)
	if(distance < 8*block) then 
		for i = 1, table.getn(verletEngine.vBodies[1]) do
			if(verletEngine.handleCollisions( verletEngine.vCBodies[1], verletEngine.vCBodies[2], 1 )) then
				text.text = "SPIKE"
			elseif(verletEngine.handleCollisions( verletEngine.vCBodies[3], verletEngine.vCBodies[2], 2 )) then
			elseif(verletEngine.handleCollisions( verletEngine.vCBodies[4], verletEngine.vCBodies[2], 3 )) then
				text.text = "BIG CUP"
			elseif(verletEngine.handleCollisions( verletEngine.vCBodies[5], verletEngine.vCBodies[2], 4 )) then
				text.text = "BIG CUP"
			elseif(verletEngine.handleCollisions( verletEngine.vCBodies[6], verletEngine.vCBodies[2], 5 )) then
				text.text = "SMALL CUP"
			elseif(verletEngine.handleCollisions( verletEngine.vCBodies[7], verletEngine.vCBodies[2], 6 )) then
				text.text = "SMALL CUP"
			elseif(verletEngine.handleCollisions( verletEngine.vCBodies[8], verletEngine.vCBodies[2], 7 )) then
			elseif(verletEngine.handleCollisions( verletEngine.vCBodies[9], verletEngine.vCBodies[2], 8 )) then
			elseif(verletEngine.handleCollisions( verletEngine.vCBodies[10], verletEngine.vCBodies[2], 9 )) then
			elseif(verletEngine.handleCollisions( verletEngine.vCBodies[11], verletEngine.vCBodies[2], 10 )) then
				text.text = "BOTTOM CUP"
			else
			end	
		end
	else
	end
	verletEngine.renderPoints()
	verletEngine.renderRope()
end

-- Updates the verlet points, calculating each new position according to the previous position
function verletEngine.updatePoints()
	for i = 1, table.getn(verletEngine.vPoints) do
		local p = verletEngine.vPoints[i]
		if p.touch == false  then
			local vx = (p.x - p.oldx) * verletEngine.vFriction
			local vy = (p.y - p.oldy) * verletEngine.vFriction
			p.oldx = p.x
			p.oldy = p.y
			p.x = p.x + vx
			p.y = p.y + vy
			p.y = p.y + verletEngine.vGravity
		end
	end
end

-- Constrains the points within the display screen and "kills" the energy of the points, slowing them down as time moves forward
function verletEngine.constrainPoints()
	for i = 1, table.getn(verletEngine.vPoints) do
		local p = verletEngine.vPoints[i]
		if p.touch == false  then
			local vx = (p.x - p.oldx) * verletEngine.vFriction
			local vy = (p.y - p.oldy) * verletEngine.vFriction
			if (p.x > display.contentWidth) then
				p.x = display.contentWidth
				p.oldx = p.x + vx * verletEngine.vBounce
			end
			if (p.x < 0) then
				p.x = 0
				p.oldx = p.x + vx * verletEngine.vBounce
			end
			if (p.y > display.contentHeight) then
				p.y = display.contentHeight
				p.oldy = p.y + vy * verletEngine.vBounce
			end
			if (p.y < 0) then
				p.y = 0
				p.oldy = p.y + vy * verletEngine.vBounce
			end
		end
	end
end

-- Updates the verlet lines, calculating each new lines according to the previous lines
function verletEngine.updateLines()
	for i = 1, table.getn(verletEngine.vLines) do
		local s = verletEngine.vLines[i]
		local dx = s.p1.x - s.p0.x
		local dy = s.p1.y - s.p0.y
		local distance = math.sqrt(dx * dx + dy * dy)
		local difference = s.length - distance
		local percent = difference / distance / 2
		local offsetX = dx * percent
		local offsetY = dy * percent
		
		if s.p0.touch == false  then
			s.p0.x = s.p0.x - offsetX
			s.p0.y = s.p0.y - offsetY
		end
		if s.p1.touch == false  then
			s.p1.x = s.p1.x + offsetX
			s.p1.y = s.p1.y + offsetY
		end
	end
end

-- Calls the check collision function
function verletEngine.handleCollisions(shape1, shape2, c)
	if(verletEngine.checkCollisions(shape1, shape2, c)) then
		return true
	end
	return false
end

-- Checks for collisions between a pair of collision bodies
-- Uses the separating axis theorem to detect collision between two shapes
-- If the is no overlap between one of the projections of the points onto the normals, then there is no collision and the algorithm can kick out
function verletEngine.checkCollisions(shape1, shape2, c)
	local normals = {}
	-- Get axes for shape 1
	for j = 1, table.getn(shape1) do
		local point1x = shape1[j].x
		local point1y = shape1[j].y
		local point2x
		local point2y
		if( j == table.getn(shape1)) then
			point2x = shape1[1].x
			point2y = shape1[1].y
		else
			point2x = shape1[j+1].x
			point2y = shape1[j+1].y
		end
		
		local normalx = ( point2y - point1y )
		local normaly = ( point1x - point2x )
		
		table.insert(normals, { x = normalx, y = normaly } )
	end
	-- Get axes for shape 2
	for j = 1, table.getn(shape2) do
		local point1x = shape2[j].x
		local point1y = shape2[j].y
		local point2x
		local point2y
		if( j == table.getn(shape2)) then
			point2x = shape2[1].x
			point2y = shape2[1].y
		else
			point2x = shape2[j+1].x
			point2y = shape2[j+1].y
		end
		
		local normalx = ( point2y - point1y )
		local normaly = ( point1x - point2x )
		
		table.insert(normals, { x = normalx, y = normaly } )
	end
	local minOverlap
	local mtv = normals[1]
	-- For each axis, project each vertex
	for i = 1, table.getn(normals) do
		local minVal1 = normals[i].x * shape1[1].x + normals[i].y * shape1[1].y
		local maxVal1 = normals[i].x * shape1[1].x + normals[i].y * shape1[1].y
		local minVal2 = normals[i].x * shape2[1].x + normals[i].y * shape2[1].y
		local maxVal2 = normals[i].x * shape2[1].x + normals[i].y * shape2[1].y
		-- Project shape1's vertices
		for j = 1, table.getn(shape1) do
			local p = normals[i].x * shape1[j].x + normals[i].y * shape1[j].y
			if( p < minVal1 ) then
				minVal1 = p
			elseif( p > maxVal1 ) then
				maxVal1 = p
			end
		end
		-- Project shape2
		for j = 1, table.getn(shape2) do
			local p = normals[i].x * shape2[j].x + normals[i].y * shape2[j].y
			if( p < minVal2 ) then
				minVal2 = p
			elseif( p > maxVal2 ) then
				maxVal2 = p
			end
		end
		-- Compare for overlap
		if(not(minVal1 <= maxVal2 and minVal2 <= maxVal1)) then
			return false
		end
		minOverlap = getOverlap(minVal1, maxVal1, minVal2, maxVal2)
		-- If there's overlap, get it
		o = getOverlap(minVal1, maxVal1, minVal2, maxVal2)
		if( o < minOverlap ) then
			minOverlap = o
			mtv = normals[i]
		end
	end
	local length = math.sqrt(mtv.x * mtv.x + mtv.y * mtv.y)
	mtv.x = mtv.x / length
	mtv.y = mtv.y / length
	-- Collision occurred, do something
	for i = 1, table.getn(shape2) do
		if( shape2[i].x > verletEngine.vCenters[c].x ) then 
			shape2[i].x = shape2[i].x + 0.1 * verletEngine.vBounce
		end
		if( shape2[i].x < verletEngine.vCenters[c].x ) then 
			shape2[i].x = shape2[i].x - 0.1 * verletEngine.vBounce
		end
		if( shape2[i].y > verletEngine.vCenters[c].y ) then 
			shape2[i].y = shape2[i].y + 0.1 * verletEngine.vBounce
		end
		if( shape2[i].y < verletEngine.vCenters[c].y ) then 
			shape2[i].y = shape2[i].y - 0.1 * verletEngine.vBounce
		end		
	end
	return true
end

-- Gets the overlap between two ranges
function getOverlap(aStart, aEnd, bStart, bEnd)
	return math.max(0, math.min(aEnd, bEnd) - math.max(aStart, bStart))
end

-- Takes the points and renders them; the only "points" seen are the ken and dama (cup and ball)
function verletEngine.renderPoints()
	ken.x = verletEngine.vPoints[1].x
	ken.y = verletEngine.vPoints[1].y
	dama.x = verletEngine.vPoints[46].x
	dama.y = verletEngine.vPoints[46].y
	-- rotation = angle between 2 lines point 32's prev and current
	local angle = angleBetweenTouches2(verletEngine.vPoints[32].x, verletEngine.vPoints[32].y, verletEngine.vPoints[32].oldx, verletEngine.vPoints[32].oldy)
	dama.rotation = angle * 180 / math.pi
end

-- Here I create a new line every frame - could be optimized. Had problems trying to just keep the line and move it around
function verletEngine.renderLines()
	for i = 1, table.getn(verletEngine.vLines) do
		local s = verletEngine.vLines[i]
		local dx = s.p1.x - s.p0.x
		local dy = s.p1.y - s.p0.y
		testLines[i]:removeSelf()
		testLines[i] = nil
		testLines[i] = display.newLine( verletEngine.vLines[i].p0.x, verletEngine.vLines[i].p0.y, verletEngine.vLines[i].p1.x, verletEngine.vLines[i].p1.y )
		testLines[i]:setStrokeColor(0, 0, 0, 1 )
	end
end

-- Custom render function to render only the lines of the rope
function verletEngine.renderRope()
	for i = 169, table.getn(verletEngine.vLines) do
		local s = verletEngine.vLines[i]
		local dx = s.p1.x - s.p0.x
		local dy = s.p1.y - s.p0.y
		testLines[i]:removeSelf()
		testLines[i] = nil
		testLines[i] = display.newLine( verletEngine.vLines[i].p0.x, verletEngine.vLines[i].p0.y, verletEngine.vLines[i].p1.x, verletEngine.vLines[i].p1.y )
		testLines[i]:setStrokeColor(0, 0, 0, 1 )
	end
end

-- Rotates a body by a supplied angle amount
function verletEngine.rotateBody( shape, angle )
	local originalX = verletEngine.vBodies[1][1].x
	local originalY = verletEngine.vBodies[1][1].y
	local angleRad = angle*math.pi/180
	for i = 1, table.getn(verletEngine.vBodies[1]) do
		-- Move object center to 0,0
		verletEngine.vBodies[1][i].x = verletEngine.vBodies[1][i].x - originalX
		verletEngine.vBodies[1][i].y = verletEngine.vBodies[1][i].y - originalY
		local coordX = verletEngine.vBodies[1][i].x
		local coordY = verletEngine.vBodies[1][i].y
		
		-- Rotate all points desired angle
		verletEngine.vBodies[1][i].x = verletEngine.vBodies[1][i].x * math.cos(angle) - math.sin(angle) * verletEngine.vBodies[1][i].y
		verletEngine.vBodies[1][i].y = coordX * math.sin(angle) + math.cos(angle) * verletEngine.vBodies[1][i].y
		
		-- Move object back to original location
		verletEngine.vBodies[1][i].x = verletEngine.vBodies[1][i].x + originalX
		verletEngine.vBodies[1][i].y = verletEngine.vBodies[1][i].y + originalY
	end
end

-----------------------------------------------------------------------------------------------------------------------
---------------------------------- ENGINE PHYSICS SIMULATION BEGINS HERE ----------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

-- The following sections create the points and structural line that make up the kendama

-----------------------------------------------------------------------------------------------------------------------
-- Ken points
-----------------------------------------------------------------------------------------------------------------------
verletEngine.addPoint( 10*block, 12*block, 10*block, 12*block, true )
verletEngine.addPoint( 10*block, 10*block, 10*block, 10*block, true )
verletEngine.addPoint( 9.66*block, 10.5*block, 9.66*block, 10.5*block, true )
verletEngine.addPoint( 9.5*block, 11.5*block, 9.5*block, 11.5*block, true )
verletEngine.addPoint( 8.5*block, 11*block, 8.5*block, 11*block, true )
verletEngine.addPoint( 8*block, 11.25*block, 8*block, 11.25*block, true )
verletEngine.addPoint( 9.5*block, 12.25*block, 9.5*block, 12.25*block, true )
verletEngine.addPoint( 8*block, 13.25*block, 8*block, 13.25*block, true )
verletEngine.addPoint( 8.5*block, 13.5*block, 8.5*block, 13.5*block, true )
verletEngine.addPoint( 9.5*block, 13*block, 9.5*block, 13*block, true )
verletEngine.addPoint( 9.33*block, 15*block, 9.33*block, 15*block, true )
verletEngine.addPoint( 9*block, 16.5*block, 9*block, 16.5*block, true )
verletEngine.addPoint( 8.75*block, 16.75*block, 8.75*block, 16.75*block, true )
verletEngine.addPoint( 9*block, 17*block, 9*block, 17*block, true )
verletEngine.addPoint( 8.75*block, 17.75*block, 8.75*block, 17.75*block, true )
verletEngine.addPoint( 9*block, 18*block, 9*block, 18*block, true )
verletEngine.addPoint( 10*block, 17*block, 10*block, 17*block, true )
verletEngine.addPoint( 11*block, 18*block, 11*block, 18*block, true )
verletEngine.addPoint( 11.25*block, 17.75*block, 11.25*block, 17.75*block, true )
verletEngine.addPoint( 11*block, 17*block, 11*block, 17*block, true )
verletEngine.addPoint( 11.25*block, 16.75*block, 11.25*block, 16.75*block, true )
verletEngine.addPoint( 11*block, 16.5*block, 11*block, 16.5*block, true )
verletEngine.addPoint( 10.66*block, 15*block, 10.66*block, 15*block, true )
verletEngine.addPoint( 10.5*block, 13*block, 10.5*block, 13*block, true )
verletEngine.addPoint( 11.5*block, 13.25*block, 11.5*block, 13.25*block, true )
verletEngine.addPoint( 12*block, 13.125*block, 12*block, 13.125*block, true )
verletEngine.addPoint( 10.5*block, 12.25*block, 10.5*block, 12.25*block, true )
verletEngine.addPoint( 12*block, 11.25*block, 12*block, 11.25*block, true )
verletEngine.addPoint( 11.5*block, 11.125*block, 11.5*block, 11.125*block, true )
verletEngine.addPoint( 10.5*block, 11.5*block, 10.5*block, 11.5*block, true )
verletEngine.addPoint( 10.33*block, 10.5*block, 10.33*block, 10.5*block, true )

-----------------------------------------------------------------------------------------------------------------------
-- Dama points
-----------------------------------------------------------------------------------------------------------------------
verletEngine.addPoint( 10*block, 19.05*block, 10*block, 19.05*block, false )
verletEngine.addPoint( 9.25*block, 19.3*block, 9.25*block, 19.3*block, false )
verletEngine.addPoint( 8.83*block, 19.9*block, 8.83*block, 19.9*block, false )
verletEngine.addPoint( 8.75*block, 20.5*block, 8.75*block, 20.5*block, false )
verletEngine.addPoint( 8.8*block, 20.7*block, 8.8*block, 20.7*block, false )
verletEngine.addPoint( 9*block, 21.1*block, 9*block, 21.1*block, false )
verletEngine.addPoint( 9.5*block, 21.45*block, 9.5*block, 21.45*block, false )
verletEngine.addPoint( 10*block, 20*block, 10*block, 20*block, false )
verletEngine.addPoint( 10.5*block, 21.45*block, 10.5*block, 21.45*block, false )
verletEngine.addPoint( 11*block, 21.1*block, 11*block, 21.1*block, false )
verletEngine.addPoint( 11.2*block, 20.7*block, 11.2*block, 20.7*block, false )
verletEngine.addPoint( 11.25*block, 20.5*block, 11.25*block, 20.5*block, false )
verletEngine.addPoint( 11.2*block, 19.9*block, 11.2*block, 19.9*block, false )
verletEngine.addPoint( 10.82*block, 19.3*block, 10.82*block, 19.3*block, false )
verletEngine.addPoint( 10*block, 20.25*block, 10*block, 20.25*block, false )

-----------------------------------------------------------------------------------------------------------------------
-- Body center points
-----------------------------------------------------------------------------------------------------------------------
verletEngine.addPoint( 10*block, 13.25*block, 10*block, 13.25*block, true ) -- 47
verletEngine.addPoint( 10*block, 11*block, 10*block, 11*block, true ) -- 48
verletEngine.addPoint( 8.75*block, 11.5*block, 8.75*block, 11.5*block, true ) -- 49 
verletEngine.addPoint( 8.75*block, 13*block, 8.75*block, 13*block, true ) -- 50 
verletEngine.addPoint( 11.25*block, 13*block, 11.25*block, 13*block, true ) -- 51
verletEngine.addPoint( 11.25*block, 11.5*block, 11.25*block, 11.5*block, true ) -- 52
verletEngine.addPoint( 10*block, 15.75*block, 10*block, 15.75*block, true ) -- 53
verletEngine.addPoint( 10*block, 16.75*block, 10*block, 16.75*block, true ) -- 54
verletEngine.addPoint( 9.25*block, 17.25*block, 9.25*block, 17.25*block, true ) -- 55
verletEngine.addPoint( 10.75*block, 17.25*block, 10.75*block, 17.25*block, true ) -- 56
verletEngine.addPoint( 9.25*block, 20.5*block, 9.25*block, 20.5*block, false ) -- 57
verletEngine.addPoint( 10.75*block, 20.5*block, 10.75*block, 20.5*block, false ) -- 58

-----------------------------------------------------------------------------------------------------------------------
-- Rope points
-----------------------------------------------------------------------------------------------------------------------
verletEngine.addPoint( 10*block, 12.5*block, 10*block, 12.5*block, false )
verletEngine.addPoint( 10*block, 13*block, 10*block, 13*block, false )
verletEngine.addPoint( 10*block, 13.5*block, 10*block, 13.5*block, false )
verletEngine.addPoint( 10*block, 14*block, 10*block, 14*block, false )
verletEngine.addPoint( 10*block, 14.5*block, 10*block, 14.5*block, false )
verletEngine.addPoint( 10*block, 15*block, 10*block, 15*block, false )
verletEngine.addPoint( 10*block, 15.5*block, 10*block, 15.5*block, false )
verletEngine.addPoint( 10*block, 16*block, 10*block, 16*block, false )
verletEngine.addPoint( 10*block, 16.5*block, 10*block, 16.5*block, false )
verletEngine.addPoint( 10*block, 17*block, 10*block, 17*block, false )
verletEngine.addPoint( 10*block, 17.5*block, 10*block, 17.5*block, false )
verletEngine.addPoint( 10*block, 18*block, 10*block, 18*block, false )
verletEngine.addPoint( 10*block, 18.5*block, 10*block, 18.5*block, false )

-----------------------------------------------------------------------------------------------------------------------
-- Ken lines
-----------------------------------------------------------------------------------------------------------------------
verletEngine.addLine( verletEngine.vPoints[1], verletEngine.vPoints[2] )
verletEngine.addLine( verletEngine.vPoints[2], verletEngine.vPoints[3] )
verletEngine.addLine( verletEngine.vPoints[3], verletEngine.vPoints[4] )
verletEngine.addLine( verletEngine.vPoints[4], verletEngine.vPoints[5] )
verletEngine.addLine( verletEngine.vPoints[5], verletEngine.vPoints[6] )
verletEngine.addLine( verletEngine.vPoints[6], verletEngine.vPoints[7] )
verletEngine.addLine( verletEngine.vPoints[7], verletEngine.vPoints[8] )
verletEngine.addLine( verletEngine.vPoints[8], verletEngine.vPoints[9] )
verletEngine.addLine( verletEngine.vPoints[9], verletEngine.vPoints[10] )
verletEngine.addLine( verletEngine.vPoints[10], verletEngine.vPoints[11] )
verletEngine.addLine( verletEngine.vPoints[11], verletEngine.vPoints[12] )
verletEngine.addLine( verletEngine.vPoints[12], verletEngine.vPoints[13] )
verletEngine.addLine( verletEngine.vPoints[13], verletEngine.vPoints[14] )
verletEngine.addLine( verletEngine.vPoints[14], verletEngine.vPoints[15] )
verletEngine.addLine( verletEngine.vPoints[15], verletEngine.vPoints[16] )
verletEngine.addLine( verletEngine.vPoints[16], verletEngine.vPoints[17] )
verletEngine.addLine( verletEngine.vPoints[17], verletEngine.vPoints[18] )
verletEngine.addLine( verletEngine.vPoints[18], verletEngine.vPoints[19] )
verletEngine.addLine( verletEngine.vPoints[19], verletEngine.vPoints[20] )
verletEngine.addLine( verletEngine.vPoints[20], verletEngine.vPoints[21] )
verletEngine.addLine( verletEngine.vPoints[21], verletEngine.vPoints[22] )
verletEngine.addLine( verletEngine.vPoints[22], verletEngine.vPoints[23] )
verletEngine.addLine( verletEngine.vPoints[23], verletEngine.vPoints[24] )
verletEngine.addLine( verletEngine.vPoints[24], verletEngine.vPoints[25] )
verletEngine.addLine( verletEngine.vPoints[25], verletEngine.vPoints[26] )
verletEngine.addLine( verletEngine.vPoints[26], verletEngine.vPoints[27] )
verletEngine.addLine( verletEngine.vPoints[27], verletEngine.vPoints[28] )
verletEngine.addLine( verletEngine.vPoints[28], verletEngine.vPoints[29] )
verletEngine.addLine( verletEngine.vPoints[29], verletEngine.vPoints[30] )
verletEngine.addLine( verletEngine.vPoints[30], verletEngine.vPoints[31] )
verletEngine.addLine( verletEngine.vPoints[31], verletEngine.vPoints[2] )

-----------------------------------------------------------------------------------------------------------------------
-- Structural point lines
-----------------------------------------------------------------------------------------------------------------------
verletEngine.addLine( verletEngine.vPoints[2], verletEngine.vPoints[4] )
verletEngine.addLine( verletEngine.vPoints[2], verletEngine.vPoints[30] )
verletEngine.addLine( verletEngine.vPoints[3], verletEngine.vPoints[31] )
verletEngine.addLine( verletEngine.vPoints[3], verletEngine.vPoints[30] )
verletEngine.addLine( verletEngine.vPoints[4], verletEngine.vPoints[31] )
verletEngine.addLine( verletEngine.vPoints[48], verletEngine.vPoints[3] )
verletEngine.addLine( verletEngine.vPoints[48], verletEngine.vPoints[4] )
verletEngine.addLine( verletEngine.vPoints[48], verletEngine.vPoints[31] )
verletEngine.addLine( verletEngine.vPoints[48], verletEngine.vPoints[30] )

-----------------------------------------------------------------------------------------------------------------------
-- Structural cup lines
-----------------------------------------------------------------------------------------------------------------------
verletEngine.addLine( verletEngine.vPoints[5], verletEngine.vPoints[7] )
verletEngine.addLine( verletEngine.vPoints[4], verletEngine.vPoints[6] )
verletEngine.addLine( verletEngine.vPoints[49], verletEngine.vPoints[4] )
verletEngine.addLine( verletEngine.vPoints[49], verletEngine.vPoints[5] )
verletEngine.addLine( verletEngine.vPoints[49], verletEngine.vPoints[6] )
verletEngine.addLine( verletEngine.vPoints[49], verletEngine.vPoints[7] )

verletEngine.addLine( verletEngine.vPoints[7], verletEngine.vPoints[9] )
verletEngine.addLine( verletEngine.vPoints[8], verletEngine.vPoints[10] )
verletEngine.addLine( verletEngine.vPoints[50], verletEngine.vPoints[7] )
verletEngine.addLine( verletEngine.vPoints[50], verletEngine.vPoints[8] )
verletEngine.addLine( verletEngine.vPoints[50], verletEngine.vPoints[9] )
verletEngine.addLine( verletEngine.vPoints[50], verletEngine.vPoints[10] )

verletEngine.addLine( verletEngine.vPoints[24], verletEngine.vPoints[26] )
verletEngine.addLine( verletEngine.vPoints[25], verletEngine.vPoints[27] )
verletEngine.addLine( verletEngine.vPoints[51], verletEngine.vPoints[24] )
verletEngine.addLine( verletEngine.vPoints[51], verletEngine.vPoints[25] )
verletEngine.addLine( verletEngine.vPoints[51], verletEngine.vPoints[26] )
verletEngine.addLine( verletEngine.vPoints[51], verletEngine.vPoints[27] )

verletEngine.addLine( verletEngine.vPoints[27], verletEngine.vPoints[29] )
verletEngine.addLine( verletEngine.vPoints[28], verletEngine.vPoints[30] )
verletEngine.addLine( verletEngine.vPoints[52], verletEngine.vPoints[27] )
verletEngine.addLine( verletEngine.vPoints[52], verletEngine.vPoints[28] )
verletEngine.addLine( verletEngine.vPoints[52], verletEngine.vPoints[29] )
verletEngine.addLine( verletEngine.vPoints[52], verletEngine.vPoints[30] )

-----------------------------------------------------------------------------------------------------------------------
-- Structural main body lines
-----------------------------------------------------------------------------------------------------------------------
verletEngine.addLine( verletEngine.vPoints[4], verletEngine.vPoints[23] )
verletEngine.addLine( verletEngine.vPoints[11], verletEngine.vPoints[30] )
verletEngine.addLine( verletEngine.vPoints[7], verletEngine.vPoints[23] )
verletEngine.addLine( verletEngine.vPoints[11], verletEngine.vPoints[27] )
verletEngine.addLine( verletEngine.vPoints[10], verletEngine.vPoints[23] )
verletEngine.addLine( verletEngine.vPoints[11], verletEngine.vPoints[24] )
verletEngine.addLine( verletEngine.vPoints[4], verletEngine.vPoints[24] )
verletEngine.addLine( verletEngine.vPoints[10], verletEngine.vPoints[30] )
verletEngine.addLine( verletEngine.vPoints[10], verletEngine.vPoints[27] )
verletEngine.addLine( verletEngine.vPoints[7], verletEngine.vPoints[24] )
verletEngine.addLine( verletEngine.vPoints[47], verletEngine.vPoints[4] )
verletEngine.addLine( verletEngine.vPoints[47], verletEngine.vPoints[11] )
verletEngine.addLine( verletEngine.vPoints[47], verletEngine.vPoints[23] )
verletEngine.addLine( verletEngine.vPoints[47], verletEngine.vPoints[30] )

-----------------------------------------------------------------------------------------------------------------------
-- Lower body lines
-----------------------------------------------------------------------------------------------------------------------
verletEngine.addLine( verletEngine.vPoints[11], verletEngine.vPoints[22] )
verletEngine.addLine( verletEngine.vPoints[12], verletEngine.vPoints[23] )
verletEngine.addLine( verletEngine.vPoints[53], verletEngine.vPoints[11] )
verletEngine.addLine( verletEngine.vPoints[53], verletEngine.vPoints[12] )
verletEngine.addLine( verletEngine.vPoints[53], verletEngine.vPoints[22] )
verletEngine.addLine( verletEngine.vPoints[53], verletEngine.vPoints[23] )

verletEngine.addLine( verletEngine.vPoints[13], verletEngine.vPoints[21] )
verletEngine.addLine( verletEngine.vPoints[12], verletEngine.vPoints[20] )
verletEngine.addLine( verletEngine.vPoints[14], verletEngine.vPoints[22] )
verletEngine.addLine( verletEngine.vPoints[17], verletEngine.vPoints[12] )
verletEngine.addLine( verletEngine.vPoints[17], verletEngine.vPoints[22] )
verletEngine.addLine( verletEngine.vPoints[12], verletEngine.vPoints[14] )
verletEngine.addLine( verletEngine.vPoints[20], verletEngine.vPoints[22] )
verletEngine.addLine( verletEngine.vPoints[17], verletEngine.vPoints[13] )
verletEngine.addLine( verletEngine.vPoints[17], verletEngine.vPoints[21] )
verletEngine.addLine( verletEngine.vPoints[54], verletEngine.vPoints[12] )
verletEngine.addLine( verletEngine.vPoints[54], verletEngine.vPoints[14] )
verletEngine.addLine( verletEngine.vPoints[54], verletEngine.vPoints[20] )
verletEngine.addLine( verletEngine.vPoints[54], verletEngine.vPoints[22] )

-----------------------------------------------------------------------------------------------------------------------
-- Bottom cup lines
-----------------------------------------------------------------------------------------------------------------------
verletEngine.addLine( verletEngine.vPoints[14], verletEngine.vPoints[16] )
verletEngine.addLine( verletEngine.vPoints[15], verletEngine.vPoints[17] )
verletEngine.addLine( verletEngine.vPoints[55], verletEngine.vPoints[14] )
verletEngine.addLine( verletEngine.vPoints[55], verletEngine.vPoints[15] )
verletEngine.addLine( verletEngine.vPoints[55], verletEngine.vPoints[16] )
verletEngine.addLine( verletEngine.vPoints[55], verletEngine.vPoints[17] )

verletEngine.addLine( verletEngine.vPoints[17], verletEngine.vPoints[19] )
verletEngine.addLine( verletEngine.vPoints[18], verletEngine.vPoints[20] )
verletEngine.addLine( verletEngine.vPoints[56], verletEngine.vPoints[17] )
verletEngine.addLine( verletEngine.vPoints[56], verletEngine.vPoints[18] )
verletEngine.addLine( verletEngine.vPoints[56], verletEngine.vPoints[19] )
verletEngine.addLine( verletEngine.vPoints[56], verletEngine.vPoints[20] )

-----------------------------------------------------------------------------------------------------------------------
-- Dama lines
-----------------------------------------------------------------------------------------------------------------------
verletEngine.addLine( verletEngine.vPoints[32], verletEngine.vPoints[33] )
verletEngine.addLine( verletEngine.vPoints[33], verletEngine.vPoints[34] )
verletEngine.addLine( verletEngine.vPoints[34], verletEngine.vPoints[35] )
verletEngine.addLine( verletEngine.vPoints[35], verletEngine.vPoints[36] )
verletEngine.addLine( verletEngine.vPoints[36], verletEngine.vPoints[37] )
verletEngine.addLine( verletEngine.vPoints[37], verletEngine.vPoints[38] )
verletEngine.addLine( verletEngine.vPoints[38], verletEngine.vPoints[39] )
verletEngine.addLine( verletEngine.vPoints[39], verletEngine.vPoints[40] )
verletEngine.addLine( verletEngine.vPoints[40], verletEngine.vPoints[41] )
verletEngine.addLine( verletEngine.vPoints[41], verletEngine.vPoints[42] )
verletEngine.addLine( verletEngine.vPoints[42], verletEngine.vPoints[43] )
verletEngine.addLine( verletEngine.vPoints[43], verletEngine.vPoints[44] )
verletEngine.addLine( verletEngine.vPoints[44], verletEngine.vPoints[45] )
verletEngine.addLine( verletEngine.vPoints[45], verletEngine.vPoints[32] )

verletEngine.addLine( verletEngine.vPoints[32], verletEngine.vPoints[34] )
verletEngine.addLine( verletEngine.vPoints[32], verletEngine.vPoints[35] )
verletEngine.addLine( verletEngine.vPoints[32], verletEngine.vPoints[36] )
verletEngine.addLine( verletEngine.vPoints[32], verletEngine.vPoints[37] )
verletEngine.addLine( verletEngine.vPoints[32], verletEngine.vPoints[38] )
verletEngine.addLine( verletEngine.vPoints[32], verletEngine.vPoints[40] )
verletEngine.addLine( verletEngine.vPoints[32], verletEngine.vPoints[41] )
verletEngine.addLine( verletEngine.vPoints[32], verletEngine.vPoints[42] )
verletEngine.addLine( verletEngine.vPoints[32], verletEngine.vPoints[43] )
verletEngine.addLine( verletEngine.vPoints[32], verletEngine.vPoints[44] )
verletEngine.addLine( verletEngine.vPoints[32], verletEngine.vPoints[45] )

verletEngine.addLine( verletEngine.vPoints[39], verletEngine.vPoints[32] )
verletEngine.addLine( verletEngine.vPoints[39], verletEngine.vPoints[33] )
verletEngine.addLine( verletEngine.vPoints[39], verletEngine.vPoints[34] )
verletEngine.addLine( verletEngine.vPoints[39], verletEngine.vPoints[35] )
verletEngine.addLine( verletEngine.vPoints[39], verletEngine.vPoints[36] )
verletEngine.addLine( verletEngine.vPoints[39], verletEngine.vPoints[37] )
verletEngine.addLine( verletEngine.vPoints[39], verletEngine.vPoints[41] )
verletEngine.addLine( verletEngine.vPoints[39], verletEngine.vPoints[42] )
verletEngine.addLine( verletEngine.vPoints[39], verletEngine.vPoints[43] )
verletEngine.addLine( verletEngine.vPoints[39], verletEngine.vPoints[44] )
verletEngine.addLine( verletEngine.vPoints[39], verletEngine.vPoints[45] )

verletEngine.addLine( verletEngine.vPoints[35], verletEngine.vPoints[32] )
verletEngine.addLine( verletEngine.vPoints[35], verletEngine.vPoints[33] )
verletEngine.addLine( verletEngine.vPoints[35], verletEngine.vPoints[37] )
verletEngine.addLine( verletEngine.vPoints[35], verletEngine.vPoints[38] )
verletEngine.addLine( verletEngine.vPoints[35], verletEngine.vPoints[40] )
verletEngine.addLine( verletEngine.vPoints[35], verletEngine.vPoints[41] )
verletEngine.addLine( verletEngine.vPoints[35], verletEngine.vPoints[42] )
verletEngine.addLine( verletEngine.vPoints[35], verletEngine.vPoints[43] )
verletEngine.addLine( verletEngine.vPoints[35], verletEngine.vPoints[44] )
verletEngine.addLine( verletEngine.vPoints[35], verletEngine.vPoints[45] )

verletEngine.addLine( verletEngine.vPoints[43], verletEngine.vPoints[45] )
verletEngine.addLine( verletEngine.vPoints[43], verletEngine.vPoints[32] )
verletEngine.addLine( verletEngine.vPoints[43], verletEngine.vPoints[33] )
verletEngine.addLine( verletEngine.vPoints[43], verletEngine.vPoints[34] )
verletEngine.addLine( verletEngine.vPoints[43], verletEngine.vPoints[36] )
verletEngine.addLine( verletEngine.vPoints[43], verletEngine.vPoints[37] )
verletEngine.addLine( verletEngine.vPoints[43], verletEngine.vPoints[38] )
verletEngine.addLine( verletEngine.vPoints[43], verletEngine.vPoints[40] )
verletEngine.addLine( verletEngine.vPoints[43], verletEngine.vPoints[41] )

-----------------------------------------------------------------------------------------------------------------------
-- Dama middle
-----------------------------------------------------------------------------------------------------------------------
verletEngine.addLine( verletEngine.vPoints[33], verletEngine.vPoints[46] )
verletEngine.addLine( verletEngine.vPoints[35], verletEngine.vPoints[46] )
verletEngine.addLine( verletEngine.vPoints[37], verletEngine.vPoints[46] )
verletEngine.addLine( verletEngine.vPoints[41], verletEngine.vPoints[46] )

-----------------------------------------------------------------------------------------------------------------------
-- Rope lines
-----------------------------------------------------------------------------------------------------------------------
verletEngine.addLine( verletEngine.vPoints[1], verletEngine.vPoints[59] )
verletEngine.addLine( verletEngine.vPoints[59], verletEngine.vPoints[60] )
verletEngine.addLine( verletEngine.vPoints[60], verletEngine.vPoints[61] )
verletEngine.addLine( verletEngine.vPoints[61], verletEngine.vPoints[62] )
verletEngine.addLine( verletEngine.vPoints[62], verletEngine.vPoints[63] )
verletEngine.addLine( verletEngine.vPoints[63], verletEngine.vPoints[64] )
verletEngine.addLine( verletEngine.vPoints[64], verletEngine.vPoints[65] )
verletEngine.addLine( verletEngine.vPoints[65], verletEngine.vPoints[66] )
verletEngine.addLine( verletEngine.vPoints[66], verletEngine.vPoints[67] )
verletEngine.addLine( verletEngine.vPoints[67], verletEngine.vPoints[68] )
verletEngine.addLine( verletEngine.vPoints[68], verletEngine.vPoints[69] )
verletEngine.addLine( verletEngine.vPoints[69], verletEngine.vPoints[70] )
verletEngine.addLine( verletEngine.vPoints[70], verletEngine.vPoints[71] )
verletEngine.addLine( verletEngine.vPoints[71], verletEngine.vPoints[39] )


-- The following sections create the bodies and collision bodies of the kendama

-----------------------------------------------------------------------------------------------------------------------
-- Ken body
-----------------------------------------------------------------------------------------------------------------------
local kenBody = {}
for i = 1, 31 do
	table.insert(kenBody, verletEngine.vPoints[i])
end
for i = 47, 58 do
	table.insert(kenBody, verletEngine.vPoints[i])
end
verletEngine.addBody( kenBody )

-----------------------------------------------------------------------------------------------------------------------
-- Dama body
-----------------------------------------------------------------------------------------------------------------------
local damaBody = {}
for i = 32, 46 do
	table.insert(damaBody, verletEngine.vPoints[i])
end
verletEngine.addBody( damaBody )

-----------------------------------------------------------------------------------------------------------------------
-- Ken collision body
-----------------------------------------------------------------------------------------------------------------------
local kenCBody = {}
table.insert(kenCBody, verletEngine.vPoints[2])
table.insert(kenCBody, verletEngine.vPoints[3])
table.insert(kenCBody, verletEngine.vPoints[4])
table.insert(kenCBody, verletEngine.vPoints[30])
table.insert(kenCBody, verletEngine.vPoints[31])
verletEngine.addCBody( kenCBody )

-----------------------------------------------------------------------------------------------------------------------
-- Dama collision body
-----------------------------------------------------------------------------------------------------------------------
local damaCBody = {}
for i = 32, 45 do
	table.insert(damaCBody, verletEngine.vPoints[i])
end
verletEngine.addCBody( damaCBody )

-----------------------------------------------------------------------------------------------------------------------
-- Main body collision body
-----------------------------------------------------------------------------------------------------------------------
local mainCBody = {}
table.insert(mainCBody, verletEngine.vPoints[4])
table.insert(mainCBody, verletEngine.vPoints[7])
table.insert(mainCBody, verletEngine.vPoints[10])
table.insert(mainCBody, verletEngine.vPoints[11])
table.insert(mainCBody, verletEngine.vPoints[23])
table.insert(mainCBody, verletEngine.vPoints[24])
table.insert(mainCBody, verletEngine.vPoints[27])
table.insert(mainCBody, verletEngine.vPoints[30])
verletEngine.addCBody( mainCBody )

-----------------------------------------------------------------------------------------------------------------------
-- Cup collision bodies
-----------------------------------------------------------------------------------------------------------------------
local cupCBody1 = {}
for i = 4, 7 do
	table.insert(cupCBody1, verletEngine.vPoints[i])
end
verletEngine.addCBody( cupCBody1 )

local cupCBody2 = {}
for i = 7, 10 do
	table.insert(cupCBody2, verletEngine.vPoints[i])
end
verletEngine.addCBody( cupCBody2 )

local cupCBody3 = {}
for i = 24, 27 do
	table.insert(cupCBody3, verletEngine.vPoints[i])
end
verletEngine.addCBody( cupCBody3 )

local cupCBody4 = {}
for i = 27, 30 do
	table.insert(cupCBody4, verletEngine.vPoints[i])
end
verletEngine.addCBody( cupCBody4 )

-----------------------------------------------------------------------------------------------------------------------
-- Lower body collision bodies
-----------------------------------------------------------------------------------------------------------------------
local lowerCBody1 = {}
table.insert(lowerCBody1, verletEngine.vPoints[11])
table.insert(lowerCBody1, verletEngine.vPoints[12])
table.insert(lowerCBody1, verletEngine.vPoints[22])
table.insert(lowerCBody1, verletEngine.vPoints[23])
verletEngine.addCBody( lowerCBody1 )

local lowerCBody2 = {}
table.insert(lowerCBody2, verletEngine.vPoints[12])
table.insert(lowerCBody2, verletEngine.vPoints[13])
table.insert(lowerCBody2, verletEngine.vPoints[14])
table.insert(lowerCBody2, verletEngine.vPoints[20])
table.insert(lowerCBody2, verletEngine.vPoints[21])
table.insert(lowerCBody2, verletEngine.vPoints[22])
verletEngine.addCBody( lowerCBody2 )

-----------------------------------------------------------------------------------------------------------------------
-- Bottom cup bodies
-----------------------------------------------------------------------------------------------------------------------
local bottomCupCBody1 = {}
table.insert(bottomCupCBody1, verletEngine.vPoints[14])
table.insert(bottomCupCBody1, verletEngine.vPoints[15])
table.insert(bottomCupCBody1, verletEngine.vPoints[16])
table.insert(bottomCupCBody1, verletEngine.vPoints[17])
verletEngine.addCBody( bottomCupCBody1 )

local bottomCupCBody2 = {}
table.insert(bottomCupCBody2, verletEngine.vPoints[17])
table.insert(bottomCupCBody2, verletEngine.vPoints[18])
table.insert(bottomCupCBody2, verletEngine.vPoints[19])
table.insert(bottomCupCBody2, verletEngine.vPoints[20])
verletEngine.addCBody( bottomCupCBody2 )


-- The following section adds the centers of the bodies to the verlet engine's center list

-----------------------------------------------------------------------------------------------------------------------
-- Collision centers
-----------------------------------------------------------------------------------------------------------------------
verletEngine.addCenters( verletEngine.vPoints[47] )
verletEngine.addCenters( verletEngine.vPoints[48] )
verletEngine.addCenters( verletEngine.vPoints[49] )
verletEngine.addCenters( verletEngine.vPoints[50] )
verletEngine.addCenters( verletEngine.vPoints[51] )
verletEngine.addCenters( verletEngine.vPoints[52] )
verletEngine.addCenters( verletEngine.vPoints[53] )
verletEngine.addCenters( verletEngine.vPoints[54] )
verletEngine.addCenters( verletEngine.vPoints[55] )
verletEngine.addCenters( verletEngine.vPoints[56] )
verletEngine.addCenters( verletEngine.vPoints[57] )
verletEngine.addCenters( verletEngine.vPoints[58] )

-----------------------------------------------------------------------------------------------------------------------
-- Touch Events / Other
-----------------------------------------------------------------------------------------------------------------------

-- Render the lines the first time
for i = 169, table.getn(verletEngine.vLines) do
		testLines[i] = display.newLine( verletEngine.vLines[i].p0.x, verletEngine.vLines[i].p0.y, verletEngine.vLines[i].p1.x, verletEngine.vLines[i].p1.y )
end

-- Activate multitouch
system.activate( "multitouch" )

-- Attributes to help multitouch
local markX
local markY
local test = 0
local newX = 0
local newY = 0

-- Adds an event listener to the ken, allowing it to be draggable
function ken:touch( event )
    if event.phase == "began" then
		display.getCurrentStage():setFocus( self, event.id )
		self.isFocus = true
		self.markX = {}
		self.markY = {}
		for i = 1, table.getn(verletEngine.vBodies[1]) do
			self.markX[i] = verletEngine.vBodies[1][i].x
			self.markY[i] = verletEngine.vBodies[1][i].y
		end
	elseif self.isFocus then
		if event.phase == "moved" then	
			for i = 1, table.getn(verletEngine.vBodies[1]) do
				-- markX == new rotated coordinates
				-- Check for rotation
				-- THIS SECTION IS CAUSING THE BUG -- IT CHANGES THE COORDINATES OF THE POINT TO THE MOVED AMOUNT PLUS THE SAVED COORD <-- SKIPS ANY ROTATIONS MADE
				-- NEED TO MAKE A WAY TO CHANGE THIS MARK X/Y TO THE NEW ROTATED X/Y
				verletEngine.vBodies[1][i].x = (event.x - event.xStart) + self.markX[i]
				verletEngine.vBodies[1][i].y = (event.y - event.yStart) + self.markY[i]
				--verletEngine.handleCollisions( verletEngine.vCBodies[1], verletEngine.vCBodies[2] )
			end
		elseif event.phase == "ended" or event.phase == "cancelled" then
			display.getCurrentStage():setFocus( self, nil )
			self.isFocus = false
		end
	end
    return true
end

-- Adds an event listener for multiple touches to the screen
-- Multiple touches rotate the ken at a fixed amount
function multitouch( event )
	local oldAngle = 0
	local newAngle = 0
	local originX = verletEngine.vPoints[1].x
	local originY = verletEngine.vPoints[1].y
	if( event.phase == "began" ) then
		-- Store old line position
		markX = event.x
		markY = event.y
	elseif( event.phase == "moved" ) then
		-- Get new line position (event.x/y)
		-- Calculate angle between both lines
		local angle = angleBetweenTouches(markX, markY, event.x, event.y)
		newX = event.x
		newY = event.y
		-- Send that angle to rotate the body
		verletEngine.rotateBody( verletEngine.vBodies[1], -angle )
		ken.rotation = ken.rotation - angle * 180 / math.pi
		markX = event.x
		markY = event.y
	end
end

-- Angle on ken
function angleBetweenTouches( x1,y1, x2, y2)
	local angle1 = math.atan2(y1-verletEngine.vPoints[1].y, x1-verletEngine.vPoints[1].x)
	local angle2 = math.atan2(y2-verletEngine.vPoints[1].y, x2-verletEngine.vPoints[1].x)
	return (angle1 - angle2)
end

-- Angle on dama
function angleBetweenTouches2( x1,y1, x2, y2)
	local angle1 = math.atan2(y1-verletEngine.vPoints[46].y, x1-verletEngine.vPoints[46].x)
	local angle2 = math.atan2(y2-verletEngine.vPoints[46].y, x2-verletEngine.vPoints[46].x)
	return (angle1 - angle2)
end

Runtime:addEventListener( "touch", multitouch )
ken:addEventListener( "touch", ken )
Runtime:addEventListener( "enterFrame", onEveryFrame )