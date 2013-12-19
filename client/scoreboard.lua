class 'ZEDBoard'

function ZEDBoard:__init()
	self.Players = {}
	self.ServerName = ""
	self.ScrollPosition = 0
	self.PossibleItems = (Render.Height - 200)/(Render:GetTextHeight("T")+2)
	self.blacklist = {Action.LookLeft, Action.LookRight, Action.LookUp, Action.LookDown}
    Network:Subscribe( "ZEDUpdateBoard", self, self.UpdateBoard )
    Events:Subscribe( "Render", self, self.Render )
    Events:Subscribe( "LocalPlayerInput", self, self.LocalPlayerInput )
    Events:Subscribe( "KeyDown", self, self.KeyDown )
    Events:Subscribe( "KeyUp", self, self.KeyUp )
    Events:Subscribe( "MouseScroll", self, self.MouseScroll )
end

function ZEDBoard:UpdateBoard( args )
	self.Players = args.players
	self.ServerName = args.name
end

function ZEDBoard:Render( args )
	if(Key:IsDown(9))then
		local y = 40
		Render:FillArea(Vector2(Render.Width/5-20,y), Vector2(Render.Width /5*3+40, 80 + (Render.Height - 200)), Color(0,0,0,150))
		Render:DrawText( Vector2(Render.Width/2 - Render:GetTextWidth(self.ServerName)/2,y+10), self.ServerName, Color(255,255,255), 20 )
		Render:DrawText( Vector2(Render.Width/2 - Render:GetTextWidth("Players: " .. #self.Players)/2,y+30), "Players: " .. #self.Players, Color(255,255,255), 20 )
		y = y + 60
		for i = math.floor(self.ScrollPosition) + 1,math.floor(self.ScrollPosition) + 1+self.PossibleItems,1 do
			if(self.Players[i])then
				local x = Render.Width /5
				Render:FillArea(Vector2(x,y), Vector2(Render.Width /5*3, Render:GetTextHeight("T") + 2), self.Players[i].color)
				Render:DrawText( Vector2(x+1,y+2), i .. ": " .. self.Players[i].name, Color(0,0,0) )
				y = y + Render:GetTextHeight("T") + 2
			end
		end	
	end
end

function ZEDBoard:MouseScroll( args )
	self.ScrollPosition = self.ScrollPosition - args.delta
	if(self.ScrollPosition < 0)then self.ScrollPosition = 0 end
	if(#self.Players > self.PossibleItems)then
		if(self.ScrollPosition > #self.Players - self.PossibleItems)then
			self.ScrollPosition = #self.Players - self.PossibleItems
		end
	else
		self.ScrollPosition = 0
	end
end
local keyIsDown = false
function ZEDBoard:KeyDown( args )
	if(args.key == 9 and not keyIsDown)then
		keyIsDown = true
		Mouse:SetPosition(Vector2(Render.Width/2, Render.Height/2))
		Mouse:SetVisible(true)
	end
end
function ZEDBoard:KeyUp( args )
	if(args.key == 9)then
		keyIsDown = false
		Mouse:SetVisible(false)
	end
end

function ZEDBoard:LocalPlayerInput( args )
	if(Key:IsDown(9))then
		for index, action in ipairs(self.blacklist) do
			if action == args.input then
				return false
			end
		end
	 
		return true
	end
end


local zedboard = ZEDBoard()