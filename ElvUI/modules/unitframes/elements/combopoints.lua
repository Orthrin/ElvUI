local E, L, V, P, G = unpack(select(2, ...));
local UF = E:GetModule("UnitFrames");

local CreateFrame = CreateFrame;
local UnitHasVehicleUI = UnitHasVehicleUI;
local GetComboPoints = GetComboPoints;
local MAX_COMBO_POINTS = MAX_COMBO_POINTS;

function UF:Construct_Combobar(frame)
	local CPoints = CreateFrame("Frame", nil, frame);
	CPoints:CreateBackdrop("Default");
	CPoints.Override = UF.UpdateComboDisplay;
	
	for i = 1, MAX_COMBO_POINTS do
		CPoints[i] = CreateFrame("StatusBar", frame:GetName() .. "ComboBarButton" .. i, CPoints);
		UF["statusbars"][CPoints[i]] = true;
		CPoints[i]:SetStatusBarTexture(E["media"].blankTex);
		CPoints[i]:GetStatusBarTexture():SetHorizTile(false);
		CPoints[i]:SetAlpha(0.15);
		CPoints[i]:CreateBackdrop("Default");
		CPoints[i].backdrop:SetParent(CPoints);
	end
	
	return CPoints;
end

function UF:Configure_ComboPoints(frame)
	local CPoints = frame.CPoints;
	CPoints:ClearAllPoints();
	local db = frame.db;
	if(not frame.CLASSBAR_DETACHED) then
		CPoints:SetParent(frame);
	else
		CPoints:SetParent(E.UIParent);
	end
	
	if(not frame.USE_CLASSBAR or db.combobar.autoHide) then
		CPoints:Hide();
	end
	
	local CLASSBAR_WIDTH = frame.CLASSBAR_WIDTH;
	if(frame.USE_MINI_CLASSBAR and not frame.CLASSBAR_DETACHED) then
		CPoints:Point("CENTER", frame.Health.backdrop, "TOP", -(frame.BORDER*3 + 6), -frame.SPACING);
		CPoints:SetFrameStrata("MEDIUM");
		if(CPoints.mover) then
			CPoints.mover:SetScale(0.000001);
			CPoints.mover:SetAlpha(0);
		end
	elseif(not frame.CLASSBAR_DETACHED) then
		CPoints:Point("BOTTOMLEFT", frame.Health.backdrop, "TOPLEFT", frame.BORDER, (frame.SPACING*3));
		CPoints:SetFrameStrata("LOW");
		if(CPoints.mover) then
			CPoints.mover:SetScale(0.000001);
			CPoints.mover:SetAlpha(0);
		end
	else
		CLASSBAR_WIDTH = db.combobar.detachedWidth - (frame.BORDER*2);
		
		if(not CPoints.mover) then
			CPoints:Width(CLASSBAR_WIDTH);
			CPoints:Height(frame.CLASSBAR_HEIGHT - (frame.BORDER + frame.SPACING*2));
			CPoints:ClearAllPoints();
			CPoints:Point("BOTTOM", E.UIParent, "BOTTOM", 0, 150);
			E:CreateMover(CPoints, "ComboBarMover", L["Combobar"], nil, nil, nil, "ALL,SOLO");
		else
			CPoints:ClearAllPoints();
			CPoints:Point("BOTTOMLEFT", CPoints.mover, "BOTTOMLEFT");
			CPoints.mover:SetScale(1);
			CPoints.mover:SetAlpha(1);
		end
		
		CPoints:SetFrameStrata("LOW");
	end
	
	CPoints:Width(CLASSBAR_WIDTH);
	CPoints:Height(frame.CLASSBAR_HEIGHT - (frame.BORDER + frame.SPACING*2));
	
	for i = 1, frame.MAX_CLASS_BAR do
		CPoints[i]:SetStatusBarColor(unpack(ElvUF.colors.ComboPoints[i]));
		CPoints[i]:Height(CPoints:GetHeight());
		if(frame.USE_MINI_CLASSBAR) then
			CPoints[i]:SetWidth((CLASSBAR_WIDTH - ((5 + (frame.BORDER*2 + frame.SPACING*2))*(frame.MAX_CLASS_BAR - 1)))/frame.MAX_CLASS_BAR);
		elseif(i ~= MAX_COMBO_POINTS) then
			CPoints[i]:SetWidth((CLASSBAR_WIDTH - (frame.MAX_CLASS_BAR*(frame.BORDER-frame.SPACING))+(frame.BORDER-frame.SPACING)) / frame.MAX_CLASS_BAR);
		end
		
		CPoints[i]:ClearAllPoints();
		if(i == 1) then
			CPoints[i]:Point("LEFT", CPoints);
		else
			if(frame.USE_MINI_CLASSBAR) then
				CPoints[i]:Point("LEFT", CPoints[i-1], "RIGHT", (5 + frame.BORDER*2 + frame.SPACING*2), 0);
			elseif(i == frame.MAX_CLASS_BAR) then
				CPoints[i]:Point("LEFT", CPoints[i-1], "RIGHT", frame.BORDER-frame.SPACING, 0);
				CPoints[i]:Point("RIGHT", CPoints);
			else
				CPoints[i]:Point("LEFT", CPoints[i-1], "RIGHT", frame.BORDER-frame.SPACING, 0);
			end
		end
		
		if(not frame.USE_MINI_CLASSBAR) then
			CPoints[i].backdrop:Hide();
		else
			CPoints[i].backdrop:Show();
		end
	end
	
	if(not frame.USE_MINI_CLASSBAR) then
		CPoints.backdrop:Show();
	else
		CPoints.backdrop:Hide();
	end
	
	if(frame.USE_CLASSBAR and not frame:IsElementEnabled("CPoints")) then
		frame:EnableElement("CPoints");
	elseif(not frame.USE_CLASSBAR and frame:IsElementEnabled("CPoints")) then
		frame:DisableElement("CPoints");
		CPoints:Hide();
	end
end

function UF:UpdateComboDisplay(event, unit)
	if (unit == "pet") then return; end
	local cpoints = self.CPoints
	local cp = (UnitHasVehicleUI("player") or UnitHasVehicleUI("vehicle")) and GetComboPoints("vehicle", "target") or GetComboPoints("player", "target");
	
	for i = 1, MAX_COMBO_POINTS do
		if(i <= cp) then
			cpoints[i]:SetAlpha(1);
		else
			cpoints[i]:SetAlpha(.15);
		end
	end
	
	local BORDER = E.Border;
	local SPACING = E.Spacing;
	local db = E.db["unitframe"]["units"].target;
	local USE_COMBOBAR = db.combobar.enable;
	local USE_MINI_COMBOBAR = db.combobar.fill == "spaced" and USE_COMBOBAR and not db.combobar.detachFromFrame;
	local COMBOBAR_HEIGHT = db.combobar.height;
	local USE_PORTRAIT = db.portrait.enable;
	local USE_PORTRAIT_OVERLAY = db.portrait.overlay and USE_PORTRAIT;
	local PORTRAIT_WIDTH = db.portrait.width;
	local PORTRAIT_OFFSET_Y = ((COMBOBAR_HEIGHT/2) + SPACING - BORDER);
	local HEALTH_OFFSET_Y;
	local DETACHED = db.combobar.detachFromFrame;
	
	if(not self.Portrait) then
		self.Portrait = db.portrait.style == "2D" and self.Portrait2D or self.Portrait3D;
	end

	if(USE_PORTRAIT_OVERLAY or not USE_PORTRAIT) then
		PORTRAIT_WIDTH = 0;
	end

	if(DETACHED) then
		PORTRAIT_OFFSET_Y = 0;
	end

	if(cpoints[1]:GetAlpha() == 1 or not db.combobar.autoHide) then
		cpoints:Show();
		if(USE_MINI_COMBOBAR) then
			HEALTH_OFFSET_Y = DETACHED and 0 or (SPACING + (COMBOBAR_HEIGHT/2));
			self.Portrait.backdrop:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, -PORTRAIT_OFFSET_Y);
			self.Health:Point("TOPRIGHT", self, "TOPRIGHT", -(BORDER+PORTRAIT_WIDTH), -HEALTH_OFFSET_Y);
		else
			HEALTH_OFFSET_Y = DETACHED and 0 or (SPACING + COMBOBAR_HEIGHT);
			self.Portrait.backdrop:SetPoint("TOPRIGHT", self, "TOPRIGHT");
			self.Health:Point("TOPRIGHT", self, "TOPRIGHT", -(BORDER+PORTRAIT_WIDTH), -(BORDER + HEALTH_OFFSET_Y));
		end
	else
		cpoints:Hide();
		self.Portrait.backdrop:SetPoint("TOPRIGHT", self, "TOPRIGHT");
		self.Health:Point("TOPRIGHT", self, "TOPRIGHT", -(BORDER+PORTRAIT_WIDTH), -BORDER);
	end
end