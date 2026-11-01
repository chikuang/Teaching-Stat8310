-- The early chapters use CSS-only callout classes. Preserve their source and
-- HTML while giving the PDF the corresponding coloured, page-breakable boxes.
local legacy = {
  ["callout-example"] = "example",
  ["callout-theorem"] = "theorem",
  ["callout-definition"] = "definition",
  ["callout-algorithm"] = "algorithm",
  ["callout-property"] = "property",
  ["callout-exercise"] = "exercise",
  ["callout-question"] = "question",
}

function Div(div)
  if not quarto.doc.is_format("pdf") then
    return nil
  end
  for _, class in ipairs(div.classes) do
    local kind = legacy[class]
    if kind then
      -- Older PDF-only fallback titles are redundant once a real box exists.
      local label = kind:sub(1, 1):upper() .. kind:sub(2)
      local function fallback(block)
        if block.t ~= "Para" and block.t ~= "Div" then return false end
        local text = pandoc.utils.stringify(block)
        return text:match("^" .. label .. " %d+%. ") ~= nil
      end
      if div.content[1] and fallback(div.content[1]) then
        div.content:remove(1)
      end
      local title = div.attributes.title or ""
      -- Let Pandoc escape special characters and render any title mathematics.
      local title_doc = pandoc.read(title, "markdown")
      local title_tex = pandoc.write(title_doc, "latex"):gsub("%s+$", "")
      local environment = "courselegacy" .. kind
      div.content:insert(1, pandoc.RawBlock("latex",
        "\\begin{" .. environment .. "}{" .. title_tex .. "}"))
      div.content:insert(pandoc.RawBlock("latex", "\\end{" .. environment .. "}"))
      div.classes = div.classes:filter(function(value) return value ~= class end)
      return div
    end
  end
end
