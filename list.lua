function scan_sym()
    local ret = ""
    local file_names = io.popen([[ls -pa ./symbols | grep -v /]]):lines()
    for file_name in file_names do
        if file_name:find(".kicad_sym") then
            ret = ret .. "- " .. file_name .. "\n"
            local file = io.open('./symbols/' .. file_name):read("a")
            local index = 0
            while true do
                local a, b, c = file:find("symbol \"(.-)\"", index)
                if a==nil then break end
                index = b
                if string.find(c, "_%d_%d") == nil then
                    ret = ret .. "    - " .. c .. "\n"
                end
            end
        end
    end
    return ret
end

function scan_fp()
    local ret = ""
    local file_names = io.popen([[ls -pa ./footprints | grep -e /]]):lines()
    for file_name in file_names do
        if file_name:find(".pretty") then
            ret = ret .. "- " .. file_name .. "\n"
            local footprints = io.popen([[ls -pa ./footprints/]]..file_name..[[ | grep -v /]]):lines()
            for fp in footprints do
                if fp:find(".kicad_mod") then
                    ret = ret .. "    - " .. fp .. "\n"
                end
            end
        end
    end
    return ret
end

function update_readme()
    local file = io.open("./README.md", "r"):read("a")
    file = file:gsub("(<!%-%- start_symbol_list %-%->\n).-(<!%-%- end_symbol_list %-%->)",
        "%1"..scan_sym().."%2")
    file = file:gsub("(<!%-%- start_footprint_list %-%->\n).-(<!%-%- end_footprint_list %-%->)",
        "%1"..scan_fp().."%2")
    io.open("./README.md", "w+"):write(file)
end

update_readme()
