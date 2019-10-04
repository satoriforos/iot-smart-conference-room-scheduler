----------------------------------------- 
--
-- Extend String functionality to do
-- token splitting and parsing
--
-----------------------------------------
local str = {}

-----------------------------------------
-- Explodes a string by a token, returning
-- all parts of the string that were split
-- by that token
-- 
-- @author Satori Foros 2015-06
-- 
-- @param text string, eg "one,two,three"
-- @param token sting, e.g. ","
-- @return table {[0] = one, [1] = two, ...}
-----------------------------------------
function str.explode(text, token)
  if (not type(text) == "string" or text:len() == 0) then return text end
  if (not type(token) == "string" or text:len() == 0) then return text end
  result = {}

  tokenLength = token:len()

  local function _explode(haystack, token)
    local splitIndex = haystack:find(token)
    if (splitIndex == nil) then 
      table.insert(result, haystack)
      return 
    end

    local a = haystack:sub(0, splitIndex-1)
    local b = haystack:sub(splitIndex+tokenLength)
    table.insert(result,a)
    _explode(b, token)
  end
  _explode(text, token)
  return result
end

-----------------------------------------
-- Splits a string by a token,
-- returning the first and second part of 
-- the string before and after the token
-- 
-- @author Satori Foros 2015-06
-- 
-- @param text string, eg "one,two,three"
-- @param token sting 
-- @return string, string
-----------------------------------------
function str.split(text, token)
  if (not type(text) == "string" or text:len() == 0) then return text end
  if (not type(token) == "string" or text:len() == 0) then return text end
  local splitIndex = text:find(token)
  if (splitIndex == nil) then return text end
  local tokenLength = token:len()
  local headers = text:sub(0, splitIndex-1)
  local body = text:sub(splitIndex+tokenLength)
  return headers, body
end

return str
