local function decrypt(v75, v76)
    local v77 = {}

    for v145 = 1, #v75 do 
        local char_code = bit32.bxor(string.byte(v75:sub(v145, v145)), string.byte(v76:sub(1 + (v145 % #v76), 1 + (v145 % #v76))))
        table.insert(v77, string.char(char_code % 256))
    end 
    return table.concat(v77)
end

print("Service 1:", decrypt("\41\179\208\198\136\62\39", "\84\121\223\177\191\237\76")) -- Players
print("Service 2:", decrypt("\143\65\204\165\52\99\53\211\173\95\202\165", "\161\219\54\169\192\90\48\80")) -- TweenService
