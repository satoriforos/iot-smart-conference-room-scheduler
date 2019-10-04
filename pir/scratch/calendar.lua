-----------------------------------------
-- 
-- FIXME: This class is not working properly
-- 
-----------------------------------------

-----------------------------------------
-- Date formatting
-- 
-- @author Satori Foros 2015-06
-- @example calendar = Calendar()
-----------------------------------------
Calendar = {
  drift = 0, -- numeric difference between internal clock and unix timestamp
}
Calendar.__index = Calendar

setmetatable(Calendar, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})


-----------------------------------------
-- Constructor method for Calendar
-- @author Satori Foros 2015-06
-----------------------------------------
function Calendar.new()
  local self = setmetatable({}, Calendar)
  return self
end


-----------------------------------------
-- Convert a string to unix time format
-- 
-- @author Satori Foros 2015-06
-- @source https://forums.coronalabs.com/topic/29019-convert-string-to-date/
--
-- @parameter string date time, e.g. "Thursday, 09-Jul-15 01:45:21 UTC"
-- 
-- @return number e.g. 1436406321
-- 
-- @example calendar:request("http://example.com/test.htm")
-----------------------------------------
function Calendar:stringToTimestamp(dateString)
    local pattern = "(%d+)%-(%d+)%-(%d+)T(%d+):(%d+):(%d+)([%+%-])(%d+)%:(%d+)"
    local xyear, xmonth, xday, xhour, xminute, 
        xseconds, xoffset, xoffsethour, xoffsetmin = dateString:match(pattern)
    local convertedTimestamp = os.time({year = xyear, month = xmonth, 
        day = xday, hour = xhour, min = xminute, sec = xseconds})
    local offset = xoffsethour * 60 + xoffsetmin
    if xoffset == "-" then offset = offset * -1 end
    return convertedTimestamp + offset
end
