local id = 1
function Callout(callout)
  if callout.attr.identifier ~= "" then
    -- callout already has an id
    return nil
  end
  callout.attr.identifier = "callout-" .. tostring(id)
  id = id + 1
  return quarto.Callout(callout)
end 