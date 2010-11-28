-- format.lua
-- Transform selected text into formated style - removes duplicate spaces
-- and wrap text on column given by edge.column property
-- In order to work, this should be in SciteStartup.lua:
-- 
-- -- shortcut Ctrl+Shift+G Format paragraph [*]
-- function call_format_paragraph()
--   format_paragraph()
-- end
-- 

function format_paragraph()
  fm = editor.SelectionStart
  to = editor.SelectionEnd
  startcol = editor.Column[fm]
  boundcol = 0+props["edge.column"]
  boundary = "%s%w"
  
  if fm ~= to then
    text   = string.gsub(editor:textrange(fm,to),"%s+"," ")
    output = ""
    oldi = 0
    while oldi<string.len(text) do
      i = string.find(text,boundary,oldi+1)
      if i==nil then i = string.len(text) end
      
      wordlen = i - oldi
      if startcol + wordlen > boundcol then
        output = output .. "\n"
        startcol = 0
      end
      output = output .. string.sub(text,oldi+1,i)
      startcol = startcol + wordlen
      
      oldi = i
    end
    editor:BeginUndoAction()
    editor:SetSel(fm,to)
    editor:ReplaceSel(output)
    editor:EndUndoAction()
  end
end
