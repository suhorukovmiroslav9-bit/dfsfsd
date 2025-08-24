local function LoadScript()
    local success, err = pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/ВАШ_НИК/xeno-script/main/xeno.lua", true))()
    end)
    
    if not success then
        warn("Ошибка загрузки: " .. err)
    else
        print("Скрипт успешно загружен!")
    end
end

LoadScript()
