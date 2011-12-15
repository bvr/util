-- SciTEStartup.lua an initialisation script for SciTE

require("utils")
require("format")
require("COMMON")
require("highlighting_identical_text")
require("paired_tags")
require("SciTEOpenFilename")

-- variables for user list selection
local _UserListSelection = nil
local next_user_id = 13

function OnUserListSelection(tp,str)
  if _UserListSelection then
    return _UserListSelection(str)
  else
    return false
  end
end

-- function to show user list and handle selection
function user_list(list,start,fn)
  local s = ''
  local sep = ';'
  local n = table.getn(list)
  for i = start,n-1 do
      s = s..list[i]..sep
  end
  s = s..list[n]
  _UserListSelection = fn
  editor.AutoCSeparator = string.byte(sep)
  editor:UserListShow(next_user_id,s)
  editor.AutoCSeparator = string.byte(' ')
end

-- shortcut Ctrl+Shift+B Next ?? [*]
function next_param()
  from = editor.SelectionStart
  curfrom, curto = editor:findtext("??",0,from,from+200)
  if(curfrom ~= nil) then
    editor:SetSel(curfrom,curto)
    editor:ReplaceSel("")
  end
end

-- open or activate file favorite.properties and mark all groups - [item]
function open_favorites()
  scite.Open(props.SciteDefaultHome .. "\\favorite.properties")
  for m in editor:match("\[[^\[]*\]",SCFIND_REGEXP) do
    editor:MarkerAdd(editor:LineFromPosition(m.pos),1)
  end
end

-- open or activate project file
function open_project()
--~   _ALERT(props.SciteDefaultHome .. "\\favorite.properties")
  scite.Open(props.SciteDirectoryHome .. "\\project.txt")
  for m in editor:match("\[[^\[]*\]",SCFIND_REGEXP) do
    editor:MarkerAdd(editor:LineFromPosition(m.pos),1)
  end
end

-- shortcut Ctrl+Shift+C Open C/H [$(file.patterns.cpp)]
function open_cpp_h()
  ext = string.lower(props.FileExt)
  if ext == "cpp" then
    scite.Open(props.FileName .. ".h")
  else
    scite.Open(props.FileName .. ".cpp")
  end
end

-- shortcut Alt+Right Center Line [*]
function center_line()
  from = editor.SelectionStart
  editor:DocumentEnd()
  endofdoc = editor:LineFromPosition(editor.SelectionStart)
  editor:SetSel(from,from)
  lineheight = editor:TextHeight(0)
  lineinwindow = editor:PointYFromPosition(editor.SelectionStart)/lineheight
  linesonscreen = editor.LinesOnScreen
  editor:LineScroll(0,lineinwindow-linesonscreen/2)
end

-- Scans this file (SciTEStartup.lua) looking for lines like "-- shortcut Ctrl+O Name [pattern]"
-- and adds all this functions into Tools menu
function create_shortcuts()
  home = props.SciteDefaultHome
  gotShortCut = false
  gotPattern = false

  -- TODO: fill tool numbers from top (100 or more)
  n = 30
  macro_file_content = ""
  fp = io.open(home .. "\\SciTEStartup.lua")
  repeat
    line = fp:read("*l")
    if (line ~= nil) then
      if (gotShortCut) then
        from, to, functionName = string.find(line, "function ([%w_]*)")
        if (to ~= nil) then
          if(not gotPattern) then
--          _ALERT("Funcname without pattern: " .. functionName)
            pattern = "*"
          end
          props["command.name." .. n .. "." .. pattern] = description
          props["command.subsystem." .. n .. "." .. pattern] = 3
          props["command." .. n .. "." .. pattern] = functionName
          props["command.shortcut." .. n .. "." .. pattern] = keys
          props["command.mode." .. n .. "." .. pattern] = 'savebefore:no'

          n = n + 1
          gotShortCut = false
          gotPattern = false
        end
      else
        from, to, keys, description = string.find(line, "^-- shortcut ([%S]*) ([^\[]*)")
        if (to ~= nil) then
          gotShortCut = true
          -- v hranatych zavorkach je pattern pro nektere soubory
          from, to, pattern = string.find(line, "%[(.*)%]")
          if (to ~= nil) then
            gotPattern = true;
          end
        end
      end
    end
  until line == nil
end

-- shortcut Ctrl+P Insert <P> sign [$(file.patterns.html)]
function insert_p()
  fm = editor.SelectionStart
  to = editor.SelectionEnd
  editor:ReplaceSel("<p>" .. editor:textrange(fm,to) .. "</p>\n")
end

-- shortcut Ctrl+Shift+G Format paragraph [*]
function call_format_paragraph()
  format_paragraph()
end

-- shortcut Ctrl+Shift+1 Fold Top Level [*]
function fold1()
  FoldSome(0)
end

-- shortcut Ctrl+Shift+2 Fold Level 2 [*]
function fold2()
  FoldSome(1)
end

-- shortcut Ctrl+Shift+3 Fold Level 3 [*]
function fold3()
  FoldSome(2)
end

-- shortcut Ctrl+Shift+O Open Selected Filename [*]
function OpenSelFilename()
  OpenFilename()
end

-- toggle folds, with customizable fold range
-- khman 20060117, public domain
function FoldSome(from)
  local FOLDSTART = 1024 + from -- level to start folding (from 1024)
--~   local FOLDDEPTH = 7 - from    -- fold depth; comment out if no limit
  --------------------------------------------------------------------
  local FOLDEND = FOLDSTART + (FOLDDEPTH or 9999)
  if FOLDEND <= FOLDSTART or FOLDEND > 4096 then FOLDEND = 4096 end
  local start, ending, hide
  editor:Colourise(0, -1)       -- update doc's folding info
  for ln = 0, editor.LineCount - 1 do
    local foldRaw = editor.FoldLevel[ln]
    local foldLvl = math.mod(foldRaw, 4096)
    local foldHdr = math.mod(math.floor(foldRaw / 8192), 2) == 1
    -- fold if within limits and is a fold header
    if foldHdr and foldLvl >= FOLDSTART and foldLvl < FOLDEND then
      local expanded = editor.FoldExpanded[ln]
      if foldLvl == FOLDSTART and not start then -- start fold block
        -- fix a hide/show setting for whole doc, for consistency
        if hide == nil then hide = expanded end
        start = ln + 1 -- remember range
        ending = editor:GetLastChild(ln, foldLvl)
      end
      editor.FoldExpanded[ln] = not hide
    end
    -- if end of block, perform hide or show operation
    if start and ln == ending then
      if hide then
        editor:HideLines(start, ending)
      else
        editor:ShowLines(start, ending)
      end
      center_line()
      start, ending = nil, nil
    end
  end--for
end


-- variable for remembering tab position
local tab_position  = -1

local old_OnUpdateUI = OnUpdateUI
function OnUpdateUI()
	local result
	if old_OnUpdateUI then result = old_OnUpdateUI() end

  if editor.SelectionEnd then
    curpos = editor.SelectionEnd
  else
    curpos = editor.SelectionStart
  end
  curchar = editor:textrange(curpos,curpos+1)
  props["sellinefrom"] = editor:LineFromPosition(editor.SelectionStart)+1
  props["sellineto"] = editor:LineFromPosition(editor.SelectionEnd)+1
  props["selrange"] = editor:LineFromPosition(editor.SelectionEnd)
    - editor:LineFromPosition(editor.SelectionStart) + 1

  props["yy"] = os.date("%Y")
  props["mm"] = os.date("%m")
  props["dd"] = os.date("%d")
  temp = os.date("*t")
  props["logdate"] = string.format("%6s", temp.day .. "." .. temp.month .. ".")

  props["namespace"]
    = string.gsub(
        string.sub(props.FileDir,string.len(props.SciteDirectoryHome)+2),
        "\\","::")
  if props.namespace ~= "" then
    props["namespace"] = props.namespace .. "::"
  end
  props["namespace"] = string.gsub(props.namespace, "^lib::", "")

  props["hexcurrchar"] = HexifySimple(curchar)

  -- for english.txt file checking of already presented words
  ss = editor.SelectionStart
  if props.FileNameExt == 'anglicky.txt'
    and editor:textrange(ss-1,ss) == "\t" and ss ~= tab_position then
    -- and string.find(editor:GetCurLine(),"^.*\t$")
--~     _ALERT("search")
    en = split_two(editor:GetCurLine(),"\t")
    for m in editor:match(en) do
      line = editor:LineFromPosition(m.pos)
      if line ~= editor:LineFromPosition(ss) then
        _ALERT(props.FileNameExt ..":"..(line+1)..":"..get_line(line))
      end
    end
  end
  tab_position = ss

	return result
end

-- call on load - init Tools menu and load abbreviations
create_shortcuts()


--------------------------------------------------------------------------------
-- Testing
--------------------------------------------------------------------------------

--~ -- shortcut Ctrl+Shift+T Test [*]
function test()
--~   i = 1
--~   for m in editor:match("Title") do
--~     m:replace(i)
--~     i = i + 1
--~   end
--~   _ALERT(editor.Lexer)
--~   print(SCLEX_PYTHON)

  ln = editor:MarkerNext(0,MARKER_MAX)
  while ln ~= -1 do
    _ALERT(ln)
    ln = editor:MarkerNext(ln+1,MARKER_MAX)
  end
end

function replace_title()
  i = 1
  for m in editor:match("Title") do
    m:replace(i)
    i = i + 1
  end
end

function useful()
  editor:BeginUndoAction()
  -- edit stuff here
  editor.TargetStart = editor:PositionFromLine(0)
  editor.TargetEnd = editor.LineEndPosition[0]
  editor:ReplaceTarget("# Modified: "..os.date('%Y-%m-%d %H:%M:%S'))
  editor:EndUndoAction()
end

