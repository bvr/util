--[[--------------------------------------------------
Highlighting Identical Text
Version: 1.3.1
Author: mozers™, TymurGubayev
--]]----------------------------------------------------

local count_max = 50
local store_pos
local store_text
local mark_ident = 4
local mark_max = 5
local chars_count
local all_text
local word_pattern
local reserved_words

local max = props['highlighting.identical.text.max']
if max ~= '' then count_max = tonumber(max) end

function highlighting_identical_text_switch()
  local prop_name = 'highlighting.identical.text'
  props[prop_name] = 1 - tonumber(props[prop_name])
  EditorClearMarks(mark_ident)
  store_pos, store_text = 0, ''
end

local function isWord(all_text, text_start, text_end)
  if  ( (text_start==1)     or (all_text:sub(text_start-1, text_start-1):match(word_pattern)) ) and
    ( (text_end==#all_text) or (all_text:sub(text_end+1, text_end+1):match(word_pattern)) )    then
      return true
  end
  return false
end

local function isReservedWord(cur_text)
  if reserved_words == nil or reserved_words == '' then return false end
  for w in string.gmatch(reserved_words, "%w+") do
    if cur_text:lower() == w:lower() then return true end
  end
  return false
end

local function IdenticalTextFinder()
  local current_pos = editor.CurrentPos
  if current_pos == store_pos then return end
  store_pos = current_pos

  local wholeword = false
  local cur_text = editor:GetSelText()
  if cur_text:find('^%s+$') then return end
  if cur_text == '' then
    cur_text = GetCurrentWord()
    wholeword = true
    if isReservedWord(cur_text) then return end
  end
  if cur_text == store_text then return end
  store_text = cur_text

  EditorClearMarks(mark_ident)
  EditorClearMarks(mark_max)
  if wholeword then word_pattern = '[^' .. props['chars.alpha'] .. '_' .. ']' end
  ----------------------------------------------------------
  local match_table = {}
  local find_start = 1
  repeat
    local ident_text_start, ident_text_end = all_text:find(cur_text, find_start, true)
    if ident_text_start == nil then break end
    if ident_text_end == 0 then break end
    if ( not wholeword ) or
      ( isWord(all_text, ident_text_start, ident_text_end) ) then
        match_table[#match_table+1] = {ident_text_start-1, ident_text_end}
    end
    if count_max ~= 0 then
      if #match_table > count_max then
        local err_start, err_end
        if wholeword then
          err_start = editor:WordStartPosition(current_pos, true)
          err_end = editor:WordEndPosition(current_pos, true)
          EditorMarkText(err_start, err_end-err_start, mark_max)
          return
        else
          err_start = editor.SelectionStart
          err_end = editor.SelectionEnd
          EditorMarkText(err_start, err_end-err_start, mark_max)
          return
        end
      end
    end
    find_start = ident_text_end + 1
  until false
  ----------------------------------------------------------
  if #match_table > 1 then
    for i = 1, #match_table do
      EditorMarkText(match_table[i][1], match_table[i][2]-match_table[i][1], mark_ident)
    end
  end

end

-- Add user event handler OnUpdateUI
local old_OnUpdateUI = OnUpdateUI
function OnUpdateUI ()
  local result

  if old_OnUpdateUI then result = old_OnUpdateUI() end
  if props['FileName'] ~= '' then
    if tonumber(props["highlighting.identical.text"]) == 1 then
      if editor.Length ~= chars_count then
        all_text = editor:GetText()
        chars_count = editor.Length
      end
      IdenticalTextFinder()
    end
  end
  return result
end
