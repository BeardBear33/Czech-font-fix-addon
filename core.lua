-- ========= Uživatelský seznam fontů v AddOnu =========
local CFF_Fonts = {
  { name = "FRIZQT",   file = "Interface\\AddOns\\CzechFontFix\\Fonts\\FRIZQT__.ttf" },
  { name = "MORPHEUS", file = "Interface\\AddOns\\CzechFontFix\\Fonts\\MORPHEUS.ttf" },
  { name = "SKURRI",   file = "Interface\\AddOns\\CzechFontFix\\Fonts\\SKURRI.ttf" },
  { name = "CYR-LAT",  file = "Interface\\AddOns\\CzechFontFix\\Fonts\\Cyr-lat.ttf" },
  { name = "ARTEMISIA",  file = "Interface\\AddOns\\CzechFontFix\\Fonts\\GFSArtemisia.ttf" },
  { name = "ALBERTSHAL", file = "Interface\\AddOns\\CzechFontFix\\Fonts\\Albertsthal.ttf" },
  { name = "USIS",     file = "Interface\\AddOns\\CzechFontFix\\Fonts\\USIS.ttf" },
  { name = "SUSANE NOUVEAU", file = "Interface\\AddOns\\CzechFontFix\\Fonts\\Susanne_Nouveau.ttf" },
  { name = "RATYPE",   file = "Interface\\AddOns\\CzechFontFix\\Fonts\\vVWweRraType.ttf" },
  { name = "ATHENA",   file = "Interface\\AddOns\\CzechFontFix\\Fonts\\Athena.ttf" },
}

-- ================== Defaulty ==================
local defaults = {
  fontIndex         = 1,   -- FRIZQT
  size              = 13,

  fontIndexGossip   = nil,
  fontIndexChat     = nil,
  fontIndexBubble   = nil,
  fontIndexMailbox  = nil,
  fontIndexTooltip  = nil,

  sizeGossip        = nil,
  sizeChat          = nil,
  sizeBubble        = nil,
  sizeMailbox       = nil,
  sizeTooltip       = nil,

  applyGossip       = true,
  applyChat         = false,
  applyBubble       = true,
  applyMailbox      = true,
  applyTooltip      = true,
  
}

local mainPanel, fontPanel, sizePanel

-- ================== Helpers ==================
local function tblcopy(src)
  local dst = {}
  for k, v in pairs(src) do
    if type(v) == "table" then
      local inner = {}
      for k2, v2 in pairs(v) do inner[k2] = v2 end
      dst[k] = inner
    else
      dst[k] = v
    end
  end
  return dst
end

local function loadSaved()
  if type(CFF_Saved) ~= "table" then
    CFF_Saved = tblcopy(defaults)
    return
  end
  for k, v in pairs(defaults) do
    if CFF_Saved[k] == nil then
      if type(v) == "table" then CFF_Saved[k] = tblcopy(v) else CFF_Saved[k] = v end
    end
  end
end

local function round1(x)
  return math.floor((x * 10) + 0.5) / 10
end

local function getFontIndexForKind(kind)
  local cfg = CFF_Saved or defaults
  local defIdx = defaults.fontIndex or 1

  if kind == "Gossip" then
    return (cfg.fontIndexGossip  and CFF_Fonts[cfg.fontIndexGossip]  and cfg.fontIndexGossip)  or defIdx
  elseif kind == "Chat" then
    return (cfg.fontIndexChat    and CFF_Fonts[cfg.fontIndexChat]    and cfg.fontIndexChat)    or defIdx
  elseif kind == "Bubble" then
    return (cfg.fontIndexBubble  and CFF_Fonts[cfg.fontIndexBubble]  and cfg.fontIndexBubble)  or defIdx
  elseif kind == "Mailbox" then
    return (cfg.fontIndexMailbox and CFF_Fonts[cfg.fontIndexMailbox] and cfg.fontIndexMailbox) or defIdx
  elseif kind == "Tooltip" then
    return (cfg.fontIndexTooltip and CFF_Fonts[cfg.fontIndexTooltip] and cfg.fontIndexTooltip) or defIdx
  end

  return defIdx
end

local function getCfg(kind)
  local cfg = CFF_Saved
  if not cfg then
    cfg = tblcopy(defaults)
    CFF_Saved = cfg
  end

  local fontIndex = getFontIndexForKind(kind)
  local f = CFF_Fonts[fontIndex] or CFF_Fonts[defaults.fontIndex or 1] or CFF_Fonts[1]
  local font = f.file

  local baseSize = tonumber(cfg.size) or defaults.size or 13

  if kind then
    local overrideKey = "size"..kind
    local override = tonumber(cfg[overrideKey])
    if override and override > 0 then
      return font, override
    end
  end

  return font, baseSize
end

local CFF_Orig = setmetatable({}, { __mode = "k" })
local function rememberOriginal(fs)
  if fs and not CFF_Orig[fs] and fs.GetFont then
    local path, size = fs:GetFont()
    if path and size then
      CFF_Orig[fs] = { path = path, size = size }
    end
  end
end
local function restoreOriginal(fs)
  local o = fs and CFF_Orig[fs]
  if o and fs.SetFont then
    fs:SetFont(o.path, o.size)
  end
end

local function CFF_ApplyInterfaceFonts()
  if not mainPanel or not fontPanel or not sizePanel then return end

  local cfg = CFF_Saved or defaults
  local idx = cfg.fontIndex or defaults.fontIndex or 1
  local f = CFF_Fonts[idx] or CFF_Fonts[defaults.fontIndex or 1] or CFF_Fonts[1]
  local font = f.file
  local defaultSize = tonumber(cfg.size) or defaults.size or 13

  local function apply(panel)
    if not panel or not panel.GetRegions then return end
    for i = 1, panel:GetNumRegions() do
      local r = select(i, panel:GetRegions())
      if r and r.GetObjectType and r:GetObjectType() == "FontString" and r.SetFont and r.GetFont then
        local _, size, flags = r:GetFont()
        r:SetFont(font, size or defaultSize, flags)
      end
    end
  end

  apply(mainPanel)
  apply(fontPanel)
  apply(sizePanel)
end

-- ================== Gossip ==================
local function CFF_ApplyToGossipGreetingTitle()
  local font, size = getCfg("Gossip")
  if GossipGreetingText and GossipGreetingText.SetFont then
    rememberOriginal(GossipGreetingText)
    GossipGreetingText:SetFont(font, size)
  end
  if GossipTitleText and GossipTitleText.SetFont then
    rememberOriginal(GossipTitleText)
    GossipTitleText:SetFont(font, size)
  end
end

local function CFF_ResetGossipGreetingTitle()
  if GossipGreetingText then restoreOriginal(GossipGreetingText) end
  if GossipTitleText then restoreOriginal(GossipTitleText) end
end

local function CFF_ApplyToGossipButtons()
  local font, size = getCfg("Gossip")
  local i = 1
  while true do
    local btn = _G["GossipTitleButton"..i]
    if not btn then break end
    local fs = btn.GetFontString and btn:GetFontString()
    if fs and fs.SetFont then
      rememberOriginal(fs)
      fs:SetFont(font, size)
    end
    i = i + 1
  end
end

local function CFF_ResetGossipButtons()
  local i = 1
  while true do
    local btn = _G["GossipTitleButton"..i]
    if not btn then break end
    local fs = btn.GetFontString and btn:GetFontString()
    if fs then restoreOriginal(fs) end
    i = i + 1
  end
end

local function CFF_ApplyGossip()
  CFF_ApplyToGossipGreetingTitle()
  CFF_ApplyToGossipButtons()
end

local function CFF_ResetGossip()
  CFF_ResetGossipGreetingTitle()
  CFF_ResetGossipButtons()
end

-- ================== Chat okna ==================
local function CFF_ApplyToChat()
  local font, size = getCfg("Chat")
  local n = NUM_CHAT_WINDOWS or 7
  for i = 1, n do
    local frame = _G["ChatFrame"..i]
    if frame and frame.SetFont then
      rememberOriginal(frame)
      frame:SetFont(font, size)
    end
  end

  if ChatFontNormal then rememberOriginal(ChatFontNormal); ChatFontNormal:SetFont(font, size) end
end

local function CFF_ResetChat()
  local n = NUM_CHAT_WINDOWS or 7
  for i = 1, n do
    local frame = _G["ChatFrame"..i]
    if frame then restoreOriginal(frame) end
  end
  if ChatFontNormal then restoreOriginal(ChatFontNormal) end
end

-- ================== Chat bubbles ==================
local bubbleTicker

local function setBubbleFS(fs, font, size)
  if not fs then return end
  if fs.GetObjectType and fs:GetObjectType() == "FontString" then
    rememberOriginal(fs)
    if fs.SetFont then fs:SetFont(font, size) end
  end
end
local function restoreBubbleFS(fs)
  if not fs then return end
  if fs.GetObjectType and fs:GetObjectType() == "FontString" then
    restoreOriginal(fs)
  end
end

local function ScanBubbles(apply)
  local numChildren = WorldFrame:GetNumChildren()
  if apply then
    local font, size = getCfg("Bubble")
    for i = 1, numChildren do
      local child = select(i, WorldFrame:GetChildren())
      if child and child.GetNumRegions then
        local numRegions = child:GetNumRegions()
        for r = 1, numRegions do
          local region = select(r, child:GetRegions())
          setBubbleFS(region, font, size)
        end
      end
    end
  else
    for i = 1, numChildren do
      local child = select(i, WorldFrame:GetChildren())
      if child and child.GetNumRegions then
        local numRegions = child:GetNumRegions()
        for r = 1, numRegions do
          local region = select(r, child:GetRegions())
          restoreBubbleFS(region)
        end
      end
    end
  end
end

local function StartBubbleTicker()
  if bubbleTicker then return end
  bubbleTicker = CreateFrame("Frame", "CFF_BubbleTicker", UIParent)
  local elapsed, interval = 0, 0.25
  bubbleTicker:SetScript("OnUpdate", function(_, e)
    elapsed = elapsed + e
    if elapsed >= interval then
      elapsed = 0
      ScanBubbles(true)
    end
  end)
end

local function StopBubbleTicker()
  if bubbleTicker then
    bubbleTicker:SetScript("OnUpdate", nil)
    bubbleTicker:Hide()
    bubbleTicker = nil
  end
end

local function CFF_ApplyBubbles()
  StartBubbleTicker()
  ScanBubbles(true)
end
local function CFF_ResetBubbles()
  ScanBubbles(false)
  StopBubbleTicker()
end

-- ================== Mailbox ==================
local function CFF_ApplyMailbox()
  local font, size = getCfg("Mailbox")

  local function applyFS(fs)
    if fs and fs.GetObjectType and fs:GetObjectType() == "FontString" and fs.SetFont then
      rememberOriginal(fs)
      fs:SetFont(font, size)
    end
  end

  local function applyFrame(fr)
    if not fr then return end

    if fr.GetRegions then
      for i = 1, fr:GetNumRegions() do
        applyFS(select(i, fr:GetRegions()))
      end
    end

    if fr.GetChildren then
      for i = 1, fr:GetNumChildren() do
        local child = select(i, fr:GetChildren())
        if child and child.GetRegions then
          for j = 1, child:GetNumRegions() do
            applyFS(select(j, child:GetRegions()))
          end
        end
      end
    end
  end

  applyFrame(MailFrame)
  applyFrame(InboxFrame)
  applyFrame(SendMailFrame)
  applyFrame(OpenMailFrame)

  local function applyObj(obj)
    if obj and obj.SetFont and obj.GetFont then
      rememberOriginal(obj)
      obj:SetFont(font, size)
    end
  end

  applyObj(SendMailSubjectEditBox)
  applyObj(SendMailBodyEditBox)
  applyObj(OpenMailBodyText)
  applyObj(OpenMailSender)
  applyObj(OpenMailSubject)
end

local function CFF_ResetMailbox()
  local function resetFS(fs)
    if fs and fs.GetObjectType and fs:GetObjectType() == "FontString" then
      restoreOriginal(fs)
    end
  end

  local function resetFrame(fr)
    if not fr then return end

    if fr.GetRegions then
      for i = 1, fr:GetNumRegions() do
        resetFS(select(i, fr:GetRegions()))
      end
    end

    if fr.GetChildren then
      for i = 1, fr:GetNumChildren() do
        local child = select(i, fr:GetChildren())
        if child and child.GetRegions then
          for j = 1, child:GetNumRegions() do
            resetFS(select(j, child:GetRegions()))
          end
        end
      end
    end
  end

  resetFrame(MailFrame)
  resetFrame(InboxFrame)
  resetFrame(SendMailFrame)
  resetFrame(OpenMailFrame)

  resetFS(SendMailSubjectEditBox)
  resetFS(SendMailBodyEditBox)
  resetFS(OpenMailBodyText)
  resetFS(OpenMailSender)
  resetFS(OpenMailSubject)
end

-- ================== Tooltipy ==================
local function CFF_ApplyTooltipFrame(tt)
  if not tt or not tt.GetRegions then return end
  local font, size = getCfg("Tooltip")

  for i = 1, tt:GetNumRegions() do
    local r = select(i, tt:GetRegions())
    if r and r.GetObjectType and r:GetObjectType() == "FontString" and r.SetFont and r.GetFont then
      rememberOriginal(r)
      local _, _, flags = r:GetFont()
      r:SetFont(font, size, flags)
    end
  end
end

local function CFF_ResetTooltipFrame(tt)
  if not tt or not tt.GetRegions then return end
  for i = 1, tt:GetNumRegions() do
    local r = select(i, tt:GetRegions())
    if r and r.GetObjectType and r:GetObjectType() == "FontString" then
      restoreOriginal(r)
    end
  end
end

local CFF_TooltipList = {
  GameTooltip,
  ItemRefTooltip,
  ShoppingTooltip1,
  ShoppingTooltip2,
  ShoppingTooltip3,
  WorldMapTooltip,
}

local function CFF_ApplyTooltips()
  for _, tt in ipairs(CFF_TooltipList) do
    if tt then CFF_ApplyTooltipFrame(tt) end
  end
end

local function CFF_ResetTooltips()
  for _, tt in ipairs(CFF_TooltipList) do
    if tt then CFF_ResetTooltipFrame(tt) end
  end
end

local function CFF_HookTooltip(tt)
  if not tt or tt.__CFF_Hooked then return end
  tt.__CFF_Hooked = true

  if tt.HookScript then
    tt:HookScript("OnShow", function()
      if CFF_Saved.applyTooltip then CFF_ApplyTooltipFrame(tt) else CFF_ResetTooltipFrame(tt) end
    end)

    tt:HookScript("OnTooltipSetItem", function()
      if CFF_Saved.applyTooltip then CFF_ApplyTooltipFrame(tt) end
    end)
    tt:HookScript("OnTooltipSetSpell", function()
      if CFF_Saved.applyTooltip then CFF_ApplyTooltipFrame(tt) end
    end)
    tt:HookScript("OnTooltipSetUnit", function()
      if CFF_Saved.applyTooltip then CFF_ApplyTooltipFrame(tt) end
    end)
  end
end

-- ================== Event: LOGIN & Gossip hook ==================
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", function()
  loadSaved()
  
  for _, tt in ipairs(CFF_TooltipList) do
    CFF_HookTooltip(tt)
  end

  if GameFontNormal    then restoreOriginal(GameFontNormal)    end
  if GameFontHighlight then restoreOriginal(GameFontHighlight) end
  if GameFontWhite     then restoreOriginal(GameFontWhite)     end

  if GossipFrame and GossipFrame.HookScript then
    GossipFrame:HookScript("OnShow", function()
      if CFF_Saved.applyGossip then CFF_ApplyGossip() else CFF_ResetGossip() end
    end)
  end
  if hooksecurefunc and type(GossipFrameUpdate) == "function" then
    hooksecurefunc("GossipFrameUpdate", function()
      if CFF_Saved.applyGossip then CFF_ApplyToGossipButtons() else CFF_ResetGossipButtons() end
    end)
  end
  if MailFrame and MailFrame.HookScript then
    MailFrame:HookScript("OnShow", function()
      if CFF_Saved.applyMailbox then CFF_ApplyMailbox() else CFF_ResetMailbox() end
    end)
  end

  if CFF_Saved.applyChat    then CFF_ApplyToChat()   else CFF_ResetChat()   end
  if CFF_Saved.applyBubble  then CFF_ApplyBubbles()  else CFF_ResetBubbles() end
  if CFF_Saved.applyMailbox then CFF_ApplyMailbox()  else CFF_ResetMailbox() end
  if CFF_Saved.applyTooltip then CFF_ApplyTooltips() else CFF_ResetTooltips() end

  CFF_ApplyInterfaceFonts()

  DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00CFF: Loaded.|r")
end)

-- ================== Options panely ==================

mainPanel = CreateFrame("Frame", "CFF_MainPanel", UIParent)
mainPanel.name   = "Czech Font Fix"

fontPanel = CreateFrame("Frame", "CFF_FontPanel", UIParent)
fontPanel.name   = "Font"
fontPanel.parent = "Czech Font Fix"

sizePanel = CreateFrame("Frame", "CFF_SizePanel", UIParent)
sizePanel.name   = "Velikosti"
sizePanel.parent = "Czech Font Fix"

local fontDropGlobal, fontDropGossip, fontDropChat, fontDropBubble, fontDropMailbox, fontDropTooltip
local gSizeSlider, cSizeSlider, bSizeSlider, mSizeSlider, tSizeSlider
local gossipCheck, chatCheck, bubbleCheck, mailboxCheck, tooltipCheck

-------------------------------
-- Hlavní panel: checkboxy  ---
-------------------------------
do
  local title = mainPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
  title:SetPoint("TOPLEFT", 16, -16)
  title:SetText("Czech Font Fix")

  local sub = mainPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
  sub:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
  sub:SetWidth(520)
  sub:SetJustifyH("LEFT")
  sub:SetText("Zapni, kde se má font použít: Gossip, Chat, Chat bubbles, Mailbox.\n" ..
              "Detailní nastavení fontu a velikostí najdeš v podkategoriích „Font“ a „Velikosti“.")

  gossipCheck = CreateFrame("CheckButton", "CFF_ApplyGossipCheck", mainPanel, "InterfaceOptionsCheckButtonTemplate")
  gossipCheck:SetPoint("TOPLEFT", sub, "BOTTOMLEFT", 0, -20)
  _G["CFF_ApplyGossipCheckText"]:SetText("Použít pro Gossip okna")
  gossipCheck:SetScript("OnClick", function(self)
    CFF_Saved.applyGossip = self:GetChecked() and true or false
    if CFF_Saved.applyGossip then CFF_ApplyGossip() else CFF_ResetGossip() end
  end)

  chatCheck = CreateFrame("CheckButton", "CFF_ApplyChatCheck", mainPanel, "InterfaceOptionsCheckButtonTemplate")
  chatCheck:SetPoint("TOPLEFT", gossipCheck, "BOTTOMLEFT", 0, -6)
  _G["CFF_ApplyChatCheckText"]:SetText("Použít pro chatová okna")
  chatCheck:SetScript("OnClick", function(self)
    CFF_Saved.applyChat = self:GetChecked() and true or false
    if CFF_Saved.applyChat then CFF_ApplyToChat() else CFF_ResetChat() end
  end)

  bubbleCheck = CreateFrame("CheckButton", "CFF_ApplyBubbleCheck", mainPanel, "InterfaceOptionsCheckButtonTemplate")
  bubbleCheck:SetPoint("TOPLEFT", chatCheck, "BOTTOMLEFT", 0, -6)
  _G["CFF_ApplyBubbleCheckText"]:SetText("Použít pro chat bubbles")
  bubbleCheck:SetScript("OnClick", function(self)
    CFF_Saved.applyBubble = self:GetChecked() and true or false
    if CFF_Saved.applyBubble then CFF_ApplyBubbles() else CFF_ResetBubbles() end
  end)

  mailboxCheck = CreateFrame("CheckButton", "CFF_ApplyMailboxCheck", mainPanel, "InterfaceOptionsCheckButtonTemplate")
  mailboxCheck:SetPoint("TOPLEFT", bubbleCheck, "BOTTOMLEFT", 0, -6)
  _G["CFF_ApplyMailboxCheckText"]:SetText("Použít pro mailbox")
  mailboxCheck:SetScript("OnClick", function(self)
    CFF_Saved.applyMailbox = self:GetChecked() and true or false
    if CFF_Saved.applyMailbox then CFF_ApplyMailbox() else CFF_ResetMailbox() end
  end)
  
  tooltipCheck = CreateFrame("CheckButton", "CFF_ApplyTooltipCheck", mainPanel, "InterfaceOptionsCheckButtonTemplate")
  tooltipCheck:SetPoint("TOPLEFT", mailboxCheck, "BOTTOMLEFT", 0, -6)
  _G["CFF_ApplyTooltipCheckText"]:SetText("Použít pro tooltipy")
  tooltipCheck:SetScript("OnClick", function(self)
    CFF_Saved.applyTooltip = self:GetChecked() and true or false
    if CFF_Saved.applyTooltip then CFF_ApplyTooltips() else CFF_ResetTooltips() end
  end)


  mainPanel.default = function()
    CFF_Saved = tblcopy(defaults)

    gossipCheck:SetChecked(CFF_Saved.applyGossip)
    chatCheck:SetChecked(CFF_Saved.applyChat)
    bubbleCheck:SetChecked(CFF_Saved.applyBubble)
    mailboxCheck:SetChecked(CFF_Saved.applyMailbox)
	tooltipCheck:SetChecked(CFF_Saved.applyTooltip)

    if CFF_Saved.applyGossip  then CFF_ApplyGossip()   else CFF_ResetGossip()   end
    if CFF_Saved.applyChat    then CFF_ApplyToChat()   else CFF_ResetChat()     end
    if CFF_Saved.applyBubble  then CFF_ApplyBubbles()  else CFF_ResetBubbles()  end
    if CFF_Saved.applyMailbox then CFF_ApplyMailbox()  else CFF_ResetMailbox()  end
	if CFF_Saved.applyTooltip then CFF_ApplyTooltips() else CFF_ResetTooltips() end

    CFF_ApplyInterfaceFonts()
  end

  mainPanel.refresh = function()
    loadSaved()
    gossipCheck:SetChecked(CFF_Saved.applyGossip)
    chatCheck:SetChecked(CFF_Saved.applyChat)
    bubbleCheck:SetChecked(CFF_Saved.applyBubble)
    mailboxCheck:SetChecked(CFF_Saved.applyMailbox)
	tooltipCheck:SetChecked(CFF_Saved.applyTooltip)

    CFF_ApplyInterfaceFonts()
  end
end

-------------------------------
-- Font panel: výběr fontů ---
-------------------------------
do
  local title = fontPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
  title:SetPoint("TOPLEFT", 16, -16)
  title:SetText("CFF - Nastavení fontu")

  local sub = fontPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
  sub:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
  sub:SetWidth(520)
  sub:SetJustifyH("LEFT")
  sub:SetText("Výběr fontu pro Gossip, Chat, Chat bubbles a Mailbox.\n" ..
              "Pokud sekce nemá vlastní font, použije se základní FRIZQT.")

  -- helper: společný init a onClick
  local function FontDrop_OnClick(self, kind, dropdown)
    if kind == "Gossip" then
      CFF_Saved.fontIndexGossip = self.value
      if CFF_Saved.applyGossip then CFF_ApplyGossip() end
    elseif kind == "Chat" then
      CFF_Saved.fontIndexChat = self.value
      if CFF_Saved.applyChat then CFF_ApplyToChat() end
    elseif kind == "Bubble" then
      CFF_Saved.fontIndexBubble = self.value
      if CFF_Saved.applyBubble then CFF_ApplyBubbles() end
    elseif kind == "Mailbox" then
      CFF_Saved.fontIndexMailbox = self.value
      if CFF_Saved.applyMailbox then CFF_ApplyMailbox() end
	elseif kind == "Tooltip" then
      CFF_Saved.fontIndexTooltip = self.value
      if CFF_Saved.applyTooltip then CFF_ApplyTooltips() end
    else
      CFF_Saved.fontIndex = self.value
      CFF_ApplyInterfaceFonts()
    end

    UIDropDownMenu_SetSelectedID(dropdown, self:GetID())
  end

  local function InitFontDrop(dropdown, kind)
    return function(self, level)
      local info
      local selectedIndex = (kind and getFontIndexForKind(kind))
                           or (CFF_Saved and CFF_Saved.fontIndex) or defaults.fontIndex or 1
      for i, data in ipairs(CFF_Fonts) do
        info = UIDropDownMenu_CreateInfo()
        info.text = data.name
        info.value = i
        info.func = function(btn) FontDrop_OnClick(btn, kind, dropdown) end
        info.checked = (selectedIndex == i)
        UIDropDownMenu_AddButton(info, level)
      end
    end
  end

  -- Globální font (jen interface)
  local globalLabel = fontPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
  globalLabel:SetPoint("TOPLEFT", sub, "BOTTOMLEFT", 0, -16)
  globalLabel:SetText("CFF panel font")

  fontDropGlobal = CreateFrame("Frame", "CFF_FontDropdown_Global", fontPanel, "UIDropDownMenuTemplate")
  fontDropGlobal:SetPoint("TOPLEFT", globalLabel, "BOTTOMLEFT", -16, -4)
  fontDropGlobal.initialize = InitFontDrop(fontDropGlobal, nil)
  fontDropGlobal.displayMode = "MENU"
  
  -- Tooltip font (vpravo od CFF panel font)
  local tLabel = fontPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
  tLabel:SetPoint("TOPLEFT", globalLabel, "TOPLEFT", 200, 0)
  tLabel:SetText("Tooltip font")

  fontDropTooltip = CreateFrame("Frame", "CFF_FontDropdown_Tooltip", fontPanel, "UIDropDownMenuTemplate")
  fontDropTooltip:SetPoint("TOPLEFT", tLabel, "BOTTOMLEFT", -16, -4)
  fontDropTooltip.initialize = InitFontDrop(fontDropTooltip, "Tooltip")
  fontDropTooltip.displayMode = "MENU"

  -- Gossip font
  local gLabel = fontPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
  gLabel:SetPoint("TOPLEFT", fontDropGlobal, "BOTTOMLEFT", 16, -18)
  gLabel:SetText("Gossip font")

  fontDropGossip = CreateFrame("Frame", "CFF_FontDropdown_Gossip", fontPanel, "UIDropDownMenuTemplate")
  fontDropGossip:SetPoint("TOPLEFT", gLabel, "BOTTOMLEFT", -16, -4)
  fontDropGossip.initialize = InitFontDrop(fontDropGossip, "Gossip")
  fontDropGossip.displayMode = "MENU"

  -- Chat font
  local cLabel = fontPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
  cLabel:SetPoint("TOPLEFT", fontDropGossip, "BOTTOMLEFT", 16, -18)
  cLabel:SetText("Chat font")

  fontDropChat = CreateFrame("Frame", "CFF_FontDropdown_Chat", fontPanel, "UIDropDownMenuTemplate")
  fontDropChat:SetPoint("TOPLEFT", cLabel, "BOTTOMLEFT", -16, -4)
  fontDropChat.initialize = InitFontDrop(fontDropChat, "Chat")
  fontDropChat.displayMode = "MENU"

  -- Bubbles font
  local bLabel = fontPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
  bLabel:SetPoint("TOPLEFT", fontDropChat, "BOTTOMLEFT", 16, -18)
  bLabel:SetText("Chat bubbles font")

  fontDropBubble = CreateFrame("Frame", "CFF_FontDropdown_Bubble", fontPanel, "UIDropDownMenuTemplate")
  fontDropBubble:SetPoint("TOPLEFT", bLabel, "BOTTOMLEFT", -16, -4)
  fontDropBubble.initialize = InitFontDrop(fontDropBubble, "Bubble")
  fontDropBubble.displayMode = "MENU"

  -- Mailbox font
  local mLabel = fontPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
  mLabel:SetPoint("TOPLEFT", fontDropBubble, "BOTTOMLEFT", 16, -18)
  mLabel:SetText("Mailbox font")

  fontDropMailbox = CreateFrame("Frame", "CFF_FontDropdown_Mailbox", fontPanel, "UIDropDownMenuTemplate")
  fontDropMailbox:SetPoint("TOPLEFT", mLabel, "BOTTOMLEFT", -16, -4)
  fontDropMailbox.initialize = InitFontDrop(fontDropMailbox, "Mailbox")
  fontDropMailbox.displayMode = "MENU"

  fontPanel.default = function()
    loadSaved()
    CFF_Saved.fontIndex        = defaults.fontIndex
    CFF_Saved.fontIndexGossip  = nil
    CFF_Saved.fontIndexChat    = nil
    CFF_Saved.fontIndexBubble  = nil
    CFF_Saved.fontIndexMailbox = nil
	CFF_Saved.fontIndexTooltip = nil

    UIDropDownMenu_Initialize(fontDropGlobal,  fontDropGlobal.initialize)
    UIDropDownMenu_Initialize(fontDropGossip,  fontDropGossip.initialize)
    UIDropDownMenu_Initialize(fontDropChat,    fontDropChat.initialize)
    UIDropDownMenu_Initialize(fontDropBubble,  fontDropBubble.initialize)
    UIDropDownMenu_Initialize(fontDropMailbox, fontDropMailbox.initialize)
	UIDropDownMenu_Initialize(fontDropTooltip, fontDropTooltip.initialize)

    if CFF_Saved.applyGossip  then CFF_ApplyGossip()   else CFF_ResetGossip()   end
    if CFF_Saved.applyChat    then CFF_ApplyToChat()   else CFF_ResetChat()     end
    if CFF_Saved.applyBubble  then CFF_ApplyBubbles()  else CFF_ResetBubbles()  end
    if CFF_Saved.applyMailbox then CFF_ApplyMailbox()  else CFF_ResetMailbox()  end

    CFF_ApplyInterfaceFonts()
  end

  fontPanel.refresh = function()
    loadSaved()
    UIDropDownMenu_Initialize(fontDropGlobal,  fontDropGlobal.initialize)
    UIDropDownMenu_Initialize(fontDropGossip,  fontDropGossip.initialize)
    UIDropDownMenu_Initialize(fontDropChat,    fontDropChat.initialize)
    UIDropDownMenu_Initialize(fontDropBubble,  fontDropBubble.initialize)
    UIDropDownMenu_Initialize(fontDropMailbox, fontDropMailbox.initialize)
	UIDropDownMenu_Initialize(fontDropTooltip, fontDropTooltip.initialize)
    CFF_ApplyInterfaceFonts()
  end
end

--------------------------------
-- Size panel: velikosti fontu --
--------------------------------
do
  local title = sizePanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
  title:SetPoint("TOPLEFT", 16, -16)
  title:SetText("CFF – Nastavení velikosti písma")

  local sub = sizePanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
  sub:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
  sub:SetWidth(520)
  sub:SetJustifyH("LEFT")
  sub:SetText("Nastavení velikosti písma pro Gossip, Chat, Chat bubbles a Mailbox.\n" ..
              "Velikosti podporují i desetinná čísla (např. 12.5).\n" ..
              "Pokud sekce nemá vlastní velikost, použije se výchozí hodnota 13.")

  -- Gossip velikost
  local gSizeLabel = sizePanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
  gSizeLabel:SetPoint("TOPLEFT", sub, "BOTTOMLEFT", 0, -16)
  gSizeLabel:SetText("Gossip velikost (vlastní)")

  gSizeSlider = CreateFrame("Slider", "CFF_GossipSizeSlider", sizePanel, "OptionsSliderTemplate")
  gSizeSlider:SetPoint("TOPLEFT", gSizeLabel, "BOTTOMLEFT", 0, -18)
  gSizeSlider:SetMinMaxValues(8, 24)
  gSizeSlider:SetValueStep(0.1)
  _G["CFF_GossipSizeSliderLow"]:SetText("8")
  _G["CFF_GossipSizeSliderHigh"]:SetText("24")
  _G["CFF_GossipSizeSliderText"]:SetText("")
  gSizeSlider:SetScript("OnValueChanged", function(self, val)
    local base = tonumber(CFF_Saved.size) or defaults.size
    local v = round1(tonumber(val) or base)
    CFF_Saved.sizeGossip = v
    _G[self:GetName().."Text"]:SetText(string.format(" %.1f", v))
    if CFF_Saved.applyGossip then CFF_ApplyGossip() end
  end)

  -- Chat velikost
  local cSizeLabel = sizePanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
  cSizeLabel:SetPoint("TOPLEFT", gSizeSlider, "BOTTOMLEFT", 0, -22)
  cSizeLabel:SetText("Chat velikost (vlastní)")

  cSizeSlider = CreateFrame("Slider", "CFF_ChatSizeSlider", sizePanel, "OptionsSliderTemplate")
  cSizeSlider:SetPoint("TOPLEFT", cSizeLabel, "BOTTOMLEFT", 0, -18)
  cSizeSlider:SetMinMaxValues(8, 24)
  cSizeSlider:SetValueStep(0.1)
  _G["CFF_ChatSizeSliderLow"]:SetText("8")
  _G["CFF_ChatSizeSliderHigh"]:SetText("24")
  _G["CFF_ChatSizeSliderText"]:SetText("")
  cSizeSlider:SetScript("OnValueChanged", function(self, val)
    local base = tonumber(CFF_Saved.size) or defaults.size
    local v = round1(tonumber(val) or base)
    CFF_Saved.sizeChat = v
    _G[self:GetName().."Text"]:SetText(string.format(" %.1f", v))
    if CFF_Saved.applyChat then CFF_ApplyToChat() end
  end)

  -- Bubbles velikost
  local bSizeLabel = sizePanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
  bSizeLabel:SetPoint("TOPLEFT", cSizeSlider, "BOTTOMLEFT", 0, -22)
  bSizeLabel:SetText("Chat bubliny (vlastní)")

  bSizeSlider = CreateFrame("Slider", "CFF_BubbleSizeSlider", sizePanel, "OptionsSliderTemplate")
  bSizeSlider:SetPoint("TOPLEFT", bSizeLabel, "BOTTOMLEFT", 0, -18)
  bSizeSlider:SetMinMaxValues(8, 24)
  bSizeSlider:SetValueStep(0.1)
  _G["CFF_BubbleSizeSliderLow"]:SetText("8")
  _G["CFF_BubbleSizeSliderHigh"]:SetText("24")
  _G["CFF_BubbleSizeSliderText"]:SetText("")
  bSizeSlider:SetScript("OnValueChanged", function(self, val)
    local base = tonumber(CFF_Saved.size) or defaults.size
    local v = round1(tonumber(val) or base)
    CFF_Saved.sizeBubble = v
    _G[self:GetName().."Text"]:SetText(string.format(" %.1f", v))
    if CFF_Saved.applyBubble then CFF_ApplyBubbles() end
  end)

  -- Mailbox velikost
  local mSizeLabel = sizePanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
  mSizeLabel:SetPoint("TOPLEFT", bSizeSlider, "BOTTOMLEFT", 0, -22)
  mSizeLabel:SetText("Mailbox velikost (vlastní)")

  mSizeSlider = CreateFrame("Slider", "CFF_MailboxSizeSlider", sizePanel, "OptionsSliderTemplate")
  mSizeSlider:SetPoint("TOPLEFT", mSizeLabel, "BOTTOMLEFT", 0, -18)
  mSizeSlider:SetMinMaxValues(8, 24)
  mSizeSlider:SetValueStep(0.1)
  _G["CFF_MailboxSizeSliderLow"]:SetText("8")
  _G["CFF_MailboxSizeSliderHigh"]:SetText("24")
  _G["CFF_MailboxSizeSliderText"]:SetText("")
  mSizeSlider:SetScript("OnValueChanged", function(self, val)
    local base = tonumber(CFF_Saved.size) or defaults.size
    local v = round1(tonumber(val) or base)
    CFF_Saved.sizeMailbox = v
    _G[self:GetName().."Text"]:SetText(string.format(" %.1f", v))
    if CFF_Saved.applyMailbox then CFF_ApplyMailbox() end
  end)
  
  -- Tooltip velikost
  local tSizeLabel = sizePanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
  tSizeLabel:SetPoint("TOPLEFT", gSizeLabel, "TOPLEFT", 200, 0)
  tSizeLabel:SetText("Tooltip velikost (vlastní)")

  tSizeSlider = CreateFrame("Slider", "CFF_TooltipSizeSlider", sizePanel, "OptionsSliderTemplate")
  tSizeSlider:SetPoint("TOPLEFT", tSizeLabel, "BOTTOMLEFT", 0, -18)
  tSizeSlider:SetMinMaxValues(8, 24)
  tSizeSlider:SetValueStep(0.1)
  _G["CFF_TooltipSizeSliderLow"]:SetText("8")
  _G["CFF_TooltipSizeSliderHigh"]:SetText("24")
  _G["CFF_TooltipSizeSliderText"]:SetText("")
  tSizeSlider:SetScript("OnValueChanged", function(self, val)
    local base = tonumber(CFF_Saved.size) or defaults.size
    local v = round1(tonumber(val) or base)
    CFF_Saved.sizeTooltip = v
    _G[self:GetName().."Text"]:SetText(string.format(" %.1f", v))
    if CFF_Saved.applyTooltip then CFF_ApplyTooltips() end
  end)

  sizePanel.default = function()
    loadSaved()
    CFF_Saved.size        = defaults.size
    CFF_Saved.sizeGossip  = nil
    CFF_Saved.sizeChat    = nil
    CFF_Saved.sizeBubble  = nil
    CFF_Saved.sizeMailbox = nil
	CFF_Saved.sizeTooltip = nil

    local base = tonumber(CFF_Saved.size) or defaults.size

    gSizeSlider:SetValue(tonumber(CFF_Saved.sizeGossip)  or base)
    cSizeSlider:SetValue(tonumber(CFF_Saved.sizeChat)    or base)
    bSizeSlider:SetValue(tonumber(CFF_Saved.sizeBubble)  or base)
    mSizeSlider:SetValue(tonumber(CFF_Saved.sizeMailbox) or base)
	tSizeSlider:SetValue(tonumber(CFF_Saved.sizeTooltip) or base)

    if CFF_Saved.applyGossip  then CFF_ApplyGossip()   else CFF_ResetGossip()   end
    if CFF_Saved.applyChat    then CFF_ApplyToChat()   else CFF_ResetChat()     end
    if CFF_Saved.applyBubble  then CFF_ApplyBubbles()  else CFF_ResetBubbles()  end
    if CFF_Saved.applyMailbox then CFF_ApplyMailbox()  else CFF_ResetMailbox()  end

    CFF_ApplyInterfaceFonts()
  end

  sizePanel.refresh = function()
    loadSaved()
    local base = tonumber(CFF_Saved.size) or defaults.size

    gSizeSlider:SetValue(tonumber(CFF_Saved.sizeGossip)  or base)
    cSizeSlider:SetValue(tonumber(CFF_Saved.sizeChat)    or base)
    bSizeSlider:SetValue(tonumber(CFF_Saved.sizeBubble)  or base)
    mSizeSlider:SetValue(tonumber(CFF_Saved.sizeMailbox) or base)
	tSizeSlider:SetValue(tonumber(CFF_Saved.sizeTooltip) or base)


    CFF_ApplyInterfaceFonts()
  end
end

if not InterfaceOptionsFrame or not InterfaceOptions_AddCategory then
  UIParentLoadAddOn("Blizzard_Options")
end
InterfaceOptions_AddCategory(mainPanel)
InterfaceOptions_AddCategory(fontPanel)
InterfaceOptions_AddCategory(sizePanel)

SLASH_CFF1 = "/cff"
SlashCmdList.CFF = function()
  if not InterfaceOptionsFrame or not InterfaceOptions_AddCategory then
    UIParentLoadAddOn("Blizzard_Options")
  end
  InterfaceOptionsFrame:Show()
  InterfaceOptionsFrame_OpenToCategory(mainPanel)
  InterfaceOptionsFrame_OpenToCategory(mainPanel)
end
