local bagsearch = CreateFrame'Frame'
bagsearch:SetScript('OnEvent', function()
	this[event](this)
end)
bagsearch:RegisterEvent'ADDON_LOADED'

function bagsearch:ADDON_LOADED()
	if arg1 ~= '!bagsearch' then
		return
	end
	
	local searchbox = CreateFrame('EditBox', nil, UIParent, 'InputBoxTemplate')
	searchbox:SetAutoFocus(false)
	searchbox:SetMaxLetters(15)
	searchbox:SetFontObject(GameFontHighlightSmall)
	searchbox:SetPoint('CENTER', UIParent:GetCenter())
	searchbox:SetWidth(96)
	searchbox:SetHeight(18)
	do
		local tex = searchbox:CreateTexture(nil, 'OVERLAY')
		tex:SetTexture[[Interface\AddOns\!bagsearch\UI-Searchbox-Icon]]
		tex:SetPoint('LEFT', 0, -2)
		tex:SetWidth(14)
		tex:SetHeight(14)
	end
	do
		local btn = CreateFrame('Button', nil, searchbox)
		btn:SetPoint('RIGHT', -3, 0)
		btn:SetWidth(17)
		btn:SetHeight(17)
		local tex = btn:CreateTexture(nil, 'ARTWORK')
		tex:SetTexture[[Interface\AddOns\!bagsearch\ClearBroadcastIcon]]
		tex:SetPoint('TOPLEFT', 0, 0)
		tex:SetWidth(17)
		tex:SetHeight(17)
		tex:SetAlpha(.5)
		btn.tex = tex
		btn:SetScript('OnEnter', function()
			this.tex:SetAlpha(1)
		end)
		btn:SetScript('OnLeave', function()
			this.tex:SetAlpha(.5)
		end)
		btn:SetScript('OnMouseUp', function()
			this.tex:SetPoint('TOPLEFT', 1, -1)
		end)
		btn:SetScript('OnMouseDown', function()
			this.tex:SetPoint('TOPLEFT', 0, 0)
		end)
	end

	searchbox:SetScript('OnTextChanged', function()
		self.test = self:fuzzy_matcher(this:GetText())
		local orig = PlaySound
		PlaySound = function() end
		OpenAllBags()
		OpenAllBags(true)
		PlaySound = orig
	end)

	self.test = function() return true end
end

do
	local orig = GetContainerItemInfo
	function GetContainerItemInfo(...)
		local bag, slot = unpack(arg)
	    local ret = bagsearch:pack(orig(unpack(arg)))
	    local link = GetContainerItemLink(bag, slot)
	    ret[3] = ret[3] or (link and not bagsearch.test(gsub(link, '.*%[(.*)%].*', '%1'))) and 1 or nil
	    return unpack(ret)
	end
end

function bagsearch:pack(...)
	return arg
end

function bagsearch:fuzzy_matcher(input)
	local uppercaseInput = strupper(input)
	local pattern = '.*'
	for i = 1, strlen(uppercaseInput) do
		if strfind(strsub(uppercaseInput, i, i), '[%w%s]') then
			pattern = pattern .. strsub(uppercaseInput, i, i) .. '.-'
 		end
	end
	return function(candidate)
		return ({ strfind(strupper(candidate), pattern) })[1] and true or false
	end
end