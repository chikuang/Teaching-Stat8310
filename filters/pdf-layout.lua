-- Keep long PDF code listings inside the text block and allow page breaks.
function CodeBlock(block)
  if not quarto.doc.is_format("pdf") then return nil end
  local _, count = block.text:gsub("\n", "")
  if count < 50 then return nil end
  -- Highlight the complete listing before adding page-break opportunities,
  -- so splitting a long function does not flag its closing braces as errors.
  local latex = pandoc.write(pandoc.Pandoc({block}), "latex")
  local start = latex:find("\\begin{Highlighting}", 1, true)
  local finish = latex:find("\\end{Highlighting}", 1, true)
  if not start or not finish then return nil end
  local first = latex:find("\n", start, true) + 1
  local body, lines = latex:sub(first, finish - 1), {}
  for line in body:gmatch("([^\n]*)\n") do lines[#lines + 1] = line end
  local chunks, since_break = {}, 0
  for i, line in ipairs(lines) do
    chunks[#chunks + 1] = line
    since_break = since_break + 1
    if i < #lines and (since_break >= 40 or (since_break >= 20 and line == "")) then
      chunks[#chunks + 1] = "\\end{Highlighting}\n\\end{Shaded}\n\n\\begin{Shaded}\n\\begin{Highlighting}[]"
      since_break = 0
    end
  end
  return pandoc.RawBlock("latex", latex:sub(1, first - 1) ..
    table.concat(chunks, "\n") .. "\n" .. latex:sub(finish))
end


-- Images that fill the local line must not also inherit paragraph indentation.
function Para(block)
  if quarto.doc.is_format("pdf") and #block.content == 1 and
      block.content[1].t == "Image" then
    block.content:insert(1, pandoc.RawInline("latex", "\\noindent "))
    return {
      pandoc.RawBlock("latex", "\\begingroup\\setlength{\\parfillskip}{0pt plus 1fil}"),
      block,
      pandoc.RawBlock("latex", "\\par\\endgroup")
    }
  end
end

-- Render prose mathematics with the math font instead of losing Unicode
-- glyphs in Latin Modern Roman. Code blocks and inline code stay literal.
local prose_math = {["≥"] = "\\geq", ["θ"] = "\\theta", ["σ"] = "\\sigma"}
function Str(text)
  if not quarto.doc.is_format("pdf") then return nil end
  if text.text == "⏳" then
    return pandoc.RawInline("latex", "{\\CourseStatusFont ⏳}")
  end
  local out, remaining, changed = pandoc.List(), text.text, false
  while #remaining > 0 do
    local first, last, symbol
    for glyph, command in pairs(prose_math) do
      local a, b = remaining:find(glyph, 1, true)
      if a and (not first or a < first) then first, last, symbol = a, b, command end
    end
    if not first then out:insert(pandoc.Str(remaining)); break end
    if first > 1 then out:insert(pandoc.Str(remaining:sub(1, first - 1))) end
    out:insert(pandoc.Math("InlineMath", symbol))
    changed, remaining = true, remaining:sub(last + 1)
  end
  if changed then return out end
end

function Math(math)
  if not quarto.doc.is_format("pdf") then return nil end
  math.text = math.text:gsub("＝", "=")
  -- Put the conditional-independence equality chain on separate lines.
  if math.mathtype == "DisplayMath" and
      math.text:find("\\stackrel{\\text { always }}", 1, true) and
      math.text:find("\\operatorname{Pr}(F \\mid H \\cap G)", 1, true) then
    math.text = [[\begin{aligned}
\operatorname{Pr}(G \mid H)\operatorname{Pr}(F \mid H\cap G)
 &\stackrel{\text{always}}{=} \operatorname{Pr}(F\cap G\mid H) \\
 &\stackrel{\text{independence}}{=} \operatorname{Pr}(F\mid H)\operatorname{Pr}(G\mid H), \\
\operatorname{Pr}(F\mid H\cap G) &= \operatorname{Pr}(F\mid H).
\end{aligned}]]
  end
  return math
end
