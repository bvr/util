
-- gets range of given fold in lines. Returns two values surrounding block
function get_fold_range(minlevel)
  curline = editor:LineFromPosition(editor.SelectionStart)
--~   print("curline = " .. (editor.FoldLevel[curline] - base))
  if get_fold_of_line(curline) < minlevel then
    return nil,nil
  end
  fm = curline
  to = curline
  while get_fold_of_line(curline) >= minlevel do
    fm = fm - 1
  end
  while get_fold_of_line(curline) >= minlevel do
    to = to + 1
  end
  return fm+2,to
end

function print_fold_map()
  lastline = editor.LineCount
  for i = 0,lastline do
    print(get_fold_of_line(i) .. "\t" .. get_line(i))
  end
end


-- split string s on substring ch - returns pair of strings
function split_two(s,ch)
  local p = string.find(s,ch)
  if p then
     return string.sub(s,1,p-1),string.sub(s,p+1)
  else
     return s
  end
end

-- split string s on substring ch (eventually calls func on each substring
-- returns table of strings
function split(s,ch,func)
  ret = {}
  i = 1
  repeat
    s,tail = split_two(s,ch)
    ret[i] = s
    if func then func(s) end
    i = i + 1
    s = tail
  until s == nil
  return ret
end

-- get content of line num. If nil, get content of current line. Also omit crlf
function get_line(num)
  if num then
    ln,len = editor:GetLine(num)
  else
    ln,pos = editor:GetCurLine()
  end
  ln = string.gsub(string.gsub(ln,"\n$",""),"\r$","")
  return ln
end

-- get content of line relative from current about num. Omits crlf
function get_line_rel(num)
  curline = editor:LineFromPosition(editor.SelectionStart)
  return get_line(curline+num)
end

-- get indentation of current line as a string
function get_indent()
  to = editor.SelectionEnd
  editor:VCHome()
  indto = editor.SelectionStart
  editor:Home()
  indfrom = editor.SelectionStart
  indent = editor:textrange(indfrom,indto)
  editor:SetSel(to,to);
  return indent
end

function getregexp(regex)
  a,b=editor:findtext(regex,SCFIND_REGEXP,editor.SelectionStart,editor.SelectionStart+1000)
  if a~=nil then
    return editor:textrange(a,b)
  else
    return ""
  end
end

function getregexpback(regex)
  founda = nil
  foundb = editor.SelectionStart-1000
  repeat
    a,b=editor:findtext(regex,SCFIND_REGEXP,foundb,editor.SelectionStart)
    if a==nil then
      if founda~=nil then
        return editor:textrange(founda,foundb)
      else
        return ""
      end
    else
      founda = a
      foundb = b
    end
  until a==nil
end

-- calculate string of hex representation of s (max 10 chars)
function HexifySimple(s)
  local hexits = ""
  if s==nil then
    return "ERR"
  end
  for i = 1, math.min(string.len(s),10) do
    if (i ~= 1) then
      hexits = hexits .. " "
    end
    hexits = hexits .. string.format("%02X", string.byte(s, i))
  end
  if string.len(s) > 8 then
    hexits = hexits .. " ..."
  end
  return hexits
end

