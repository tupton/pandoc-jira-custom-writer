-- This is a JIRA custom writer for pandoc.
--
-- Invoke with: pandoc --to jira.lua
--
-- Note:  you need not have lua installed on your system to use this
-- custom writer.  However, if you do have lua installed, you can
-- use it to test changes to the script.  'lua sample.lua' will
-- produce informative error messages if your code contains
-- syntax errors.

-- Character escaping
local function escape(s)
  return s:gsub("{", "\\{")
end

-- Blocksep is used to separate block elements.
function Blocksep()
  return "\n\n"
end

-- This function is called once for the whole document. Parameters:
-- body is a string, metadata is a table, variables is a table.
-- This gives you a fragment.  You could use the metadata table to
-- fill variables in a custom lua template.  Or, pass `--template=...`
-- to pandoc, and pandoc will add do the template processing as
-- usual.
function Doc(body, metadata, variables)
  return body
end

-- The functions that follow render corresponding pandoc elements.
-- s is always a string, attr is always a table of attributes, and
-- items is always an array of strings (the items in a list).
-- Comments indicate the types of other variables.

function Str(s)
  return escape(s)
end

function Space()
  return " "
end

function SoftBreak()
  return "\n"
end

function LineBreak()
  return "\n\n"
end

function Emph(s)
  return ("_%s_"):format(s)
end

function Strong(s)
  return ("*%s*"):format(s)
end

function Subscript(s)
  return ("~%s~"):format(s)
end

function Superscript(s)
  return ("^%s^"):format(s)
end

function SmallCaps(s)
  return Str(s)
end

function Strikeout(s)
  return ("-%s-"):format(s)
end

function Link(s, src, tit, attr)
  return ("[%s|%s]"):format(escape(s), src)
end

function Image(s, src, tit, attr)
  return ("!%s|%s!"):format(escape(s), src)
end

function Code(s, attr)
  return ("{{%s}}"):format(s)
end

function InlineMath(s)
  return ("//( %s //)"):format(escape(s))
end

function DisplayMath(s)
  return ("{code}\n//( %s //){code}"):format(escape(s))
end

function Note(s)
  return Str(s)
end

function Span(s, attr)
  return s
end

function RawInline(format, str)
  return format == "jira"
    and str
    or ""
end

function Cite(s, cs)
  return ("??%s??"):format(escape(s))
end

function Plain(s)
  return s
end

function Para(s)
  return s
end

-- lev is an integer, the header level.
function Header(lev, s, attr)
  return ("h%d. %s"):format(lev, s)
end

function BlockQuote(s)
  return ("{quote}\n%s\n{quote}"):format(s)
end

function HorizontalRule()
  return "----"
end

function LineBlock(ls)
  return table.concat(ls, '\n')
end

function CodeBlock(s, attr)
  local lang = (attr.class or ''):match('^%a+')
  return ("{code%s}\n%s\n{code}"):format(
    lang and (":" .. lang) or '',
    s
  )
end

function BulletList(items)
  local buffer = {}
  for _, item in pairs(items) do
    table.insert(buffer, "* " .. item)
  end
  return table.concat(buffer, "\n")
end

function OrderedList(items)
  local buffer = {}
  for _, item in pairs(items) do
    table.insert(buffer, "# " .. item)
  end
  return table.concat(buffer, "\n")
end

function DefinitionList(items)
  return BulletList(items)
end

function CaptionedImage(src, tit, caption, attr)
   return Image(caption, src, tit, attr)
end

-- Caption is a string, aligns is an array of strings,
-- widths is an array of floats, headers is an array of
-- strings, rows is an array of arrays of strings.
function Table(caption, aligns, widths, headers, rows)
  local buffer = {}
  local function add(s)
    table.insert(buffer, s)
  end
  local header_row = {}
  local empty_header = true
  for _, h in pairs(headers) do
    table.insert(header_row, h)
    empty_header = empty_header and h == ""
  end
  if empty_header then
    head = ""
  else
    add(("||%s||"):format(table.concat(header_row, "||")))
  end
  for _, row in pairs(rows) do
    local content_row = {}
    for _, c in pairs(row) do
        table.insert(content_row, c)
    end
    add(("|%s|"):format(table.concat(content_row, "|")))
  end
  return table.concat(buffer,'\n')
end

function RawBlock(format, str)
  return format == "jira" and str or ""
end

function Div(s, attr)
  return Para(s, attr)
end

-- The following code will produce runtime warnings when you haven't defined
-- all of the functions you need for the custom writer, so it's useful
-- to include when you're working on a writer.
local meta = {}
meta.__index =
  function(_, key)
    io.stderr:write(string.format("WARNING: Undefined function '%s'\n",key))
    return function() return "" end
  end
setmetatable(_G, meta)

