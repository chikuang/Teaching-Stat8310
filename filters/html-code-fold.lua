-- Use Quarto's native folding for non-executable R/JAGS examples too.
-- Executable cells inherit code-fold and code-summary from the HTML format.
function CodeBlock(code)
  if not quarto.doc.is_format("html") then return nil end
  if code.classes:includes("r") and not code.classes:includes("cell-code") then
    code.classes:insert("cell-code")
    code.attributes["code-summary"] = "Show code"
    return code
  end
end
