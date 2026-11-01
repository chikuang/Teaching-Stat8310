-- Resolve course links against the chapters actually included in this PDF.
-- Reading the merged headers also handles Pandoc's duplicate-ID suffixes.
-- HTML keeps Quarto's ordinary QMD-to-HTML links.
local chapter_titles = {}

local function chapter_title(path)
  if chapter_titles[path] ~= nil then
    return chapter_titles[path]
  end
  local root = quarto.project.directory or "."
  local file = io.open(root .. "/" .. path, "r")
  if not file then
    return nil
  end
  local contents = file:read("*a")
  file:close()
  -- Parse only the chapter heading: executable QMD chunks are not ordinary
  -- Markdown fences and can produce spurious unclosed-Div warnings here.
  for line in contents:gmatch("[^\r\n]+") do
    if line:match("^#%s+") then
      local document = pandoc.read(line, "markdown")
      chapter_titles[path] = pandoc.utils.stringify(document.blocks[1].content)
      return chapter_titles[path]
    end
  end
end

function Pandoc(document)
  if not FORMAT:match("latex") then
    return nil
  end
  local chapters, identifiers = {}, {}
  document:walk({Header = function(header)
    identifiers[header.identifier] = true
    if header.level == 1 then
      chapters[pandoc.utils.stringify(header.content)] = header.identifier
    end
  end})
  return document:walk({Link = function(link)
    local path, fragment = link.target:match("^([^:#?]+%.qmd)#?(.*)$")
    if not path then
      return nil
    end
    local title = chapter_title(path)
    local identifier = title and chapters[title]
    if identifier then
      link.target = "#" .. (fragment ~= "" and identifiers[fragment] and fragment or identifier)
      return link
    elseif title then
      -- Retain a useful forward reference without a broken internal link.
      local content = link.content:clone()
      content:insert(pandoc.Space())
      content:insert(pandoc.Str("(not included in this edition)"))
      return pandoc.Span(content)
    end
  end})
end
