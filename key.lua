-- ============================================
-- KEY ACTIVATION SYSTEM - RIDO SCRIPT (FIXED)
-- ============================================

local KEY_FILE = "/data/local/tmp/.rido_license"
local KEYS_URL = "https://raw.githubusercontent.com/ahayriski20-ship-it/Rido/0429ac4f2daff0aa085292716c94bf6897fbb81a/keys.json"
local MAIN_SCRIPT_URL = "https://raw.githubusercontent.com/ahayriski20-ship-it/Rido/0429ac4f2daff0aa085292716c94bf6897fbb81a/sc.lua"

-- Fungsi request dengan timeout (max 5 detik)
local function requestWithTimeout(url, timeout)
    timeout = timeout or 5
    local result = nil
    local finished = false
    
    -- Gunakan coroutine untuk timeout
    local co = coroutine.create(function()
        result = gg.makeRequest(url).content
        finished = true
    end)
    
    coroutine.resume(co)
    
    -- Tunggu maksimal timeout detik
    local start = os.time()
    while not finished and (os.time() - start) < timeout do
        gg.sleep(100)
    end
    
    return result
end

-- Fungsi mendapatkan waktu real (dengan timeout)
local function getRealTimestamp()
    local sources = {
        "https://worldtimeapi.org/api/ip",
        "https://timeapi.io/api/Time/current/zone?timeZone=Asia/Jakarta"
    }
    
    for _, url in ipairs(sources) do
        local resp = requestWithTimeout(url, 3)
        if resp and #resp > 10 then
            local success, timeData = pcall(function()
                -- Coba parse sebagai JSON
                local startIdx = resp:find("{")
                if startIdx then
                    local jsonStr = resp:sub(startIdx)
                    return load("return " .. jsonStr)()
                end
                return nil
            end)
            
            if success and timeData then
                local datetime = timeData.datetime or timeData.utc_datetime
                if datetime then
                    local year = tonumber(datetime:sub(1,4))
                    local month = tonumber(datetime:sub(6,7))
                    local day = tonumber(datetime:sub(9,10))
                    if year and month and day then
                        return os.time({
                            year = year,
                            month = month,
                            day = day,
                            hour = 0,
                            min = 0,
                            sec = 0
                        })
                    end
                end
            end
        end
    end
    
    -- Fallback ke waktu lokal
    return os.time()
end

-- Ambil Device ID (cepat, tanpa I/O blocking)
local function getDeviceID()
    -- Gunakan nilai dari build.prop via gg.getFile (lebih cepat)
    local buildProp = gg.getFile("/system/build.prop")
    if buildProp then
        local hash = 0
        for i = 1, math.min(#buildProp, 500) do
            hash = (hash + string.byte(buildProp, i)) % 0xFFFFFFFF
        end
        return string.format("%x", hash):sub(1,8)
    end
    return tostring(math.random(10000000, 99999999))
end

-- Simpan license (synchronous, cepat)
local function saveLicense(key, device_id, activated_at, duration_days)
    local data = {
        key = key,
        device_id = device_id,
        activated_at = activated_at,
        duration_days = duration_days
    }
    local json = "return " .. gg.json.encode(data)
    gg.saveFile(KEY_FILE, json)
    return true
end

-- Load license
local function loadLicense()
    local content = gg.getFile(KEY_FILE)
    if content and #content > 10 then
        local success, data = pcall(function()
            return load(content)()
        end)
        if success then
            return data
        end
    end
    return nil
end

-- Validasi key (dengan timeout)
local function validateKeyFromGitHub(key)
    local response = requestWithTimeout(KEYS_URL, 5)
    
    if not response or #response < 10 then
        gg.alert("❌ GAGAL!\nTidak dapat mengakses server key.\nCek koneksi internet!")
        return nil
    end
    
    local success, keysData = pcall(function()
        local startIdx = response:find("{")
        if startIdx then
            local jsonStr = response:sub(startIdx)
            return load("return " .. jsonStr)()
        end
        return nil
    end)
    
    if not success or not keysData or not keysData.keys then
        gg.alert("❌ ERROR!\nFormat keys.json tidak valid!")
        return nil
    end
    
    return keysData.keys[key]
end

-- Tampilkan input key (non-blocking)
local function promptKey()
    local input = gg.prompt({
        "🔑 MASUKAN ACTIVATION KEY"
    }, {
        ""
    }, {
        "text"
    })
    
    if not input then
        return nil
    end
    
    local key = input[1]:upper():gsub("%s+", "")
    if key == "" then
        return nil
    end
    
    return key
end

-- Loading indicator
local function showLoading(message)
    gg.alert(message)
end

-- Fungsi utama cek license
local function checkLicense()
    -- Tampilkan loading singkat
    showLoading("⏳ Memeriksa lisensi...")
    gg.sleep(500)
    
    local device_id = getDeviceID()
    local saved = loadLicense()
    local current_time = getRealTimestamp()
    
    -- CASE 1: Sudah punya license
    if saved and saved.key then
        local keyInfo = validateKeyFromGitHub(saved.key)
        
        if not keyInfo then
            gg.alert("❌ LISENSI TIDAK VALID!\nKey tidak ditemukan di server.")
            return false
        end
        
        local expiry_time = saved.activated_at + (saved.duration_days * 86400)
        local days_left = math.floor((expiry_time - current_time) / 86400)
        
        if current_time > expiry_time then
            gg.alert("❌ LISENSI EXPIRED!\nMasa aktif telah berakhir.")
            return false
        end
        
        if saved.device_id and saved.device_id ~= device_id then
            gg.alert("❌ LISENSI TERKUNCI!\nKey sudah digunakan di device lain.")
            return false
        end
        
        if days_left <= 3 then
            gg.alert("⚠️ PERINGATAN!\nLisensi akan expired dalam " .. days_left .. " hari!")
        end
        
        return true
    end
    
    -- CASE 2: Belum punya license
    gg.alert("🔐 AKTIVASI DIPERLUKAN\n\nMasukkan activation key yang telah Anda beli.")
    
    local key = promptKey()
    if not key then 
        os.exit()
        return false 
    end
    
    showLoading("⏳ Memverifikasi key...")
    gg.sleep(500)
    
    local keyInfo = validateKeyFromGitHub(key)
    
    if not keyInfo then
        gg.alert("❌ KEY TIDAK VALID!\nKey '" .. key .. "' tidak ditemukan.")
        return false
    end
    
    local duration_days = keyInfo.duration_days or 7
    local activated_at = current_time
    
    saveLicense(key, device_id, activated_at, duration_days)
    
    local expiry_text = (duration_days == 99999) and "PERMANEN" or (duration_days .. " hari")
    
    gg.alert("✅ AKTIVASI BERHASIL!\n\nKey: " .. key .. "\nMasa aktif: " .. expiry_text)
    
    return true
end

-- ============================================
-- EKSEKUSI UTAMA
-- ============================================

-- Non-blocking execution
local function main()
    if checkLicense() then
        -- Ambil sc.lua dengan timeout
        local scriptContent = requestWithTimeout(MAIN_SCRIPT_URL, 8)
        
        if scriptContent and #scriptContent > 50 then
            local success, err = pcall(function()
                local func = load(scriptContent)
                if func then
                    func()
                end
            end)
            if not success then
                gg.alert("❌ Gagal menjalankan script!\nError: " .. tostring(err))
            end
        else
            gg.alert("❌ Gagal mengambil sc.lua!\nPeriksa koneksi internet.")
        end
    else
        os.exit()
    end
end

-- Jalankan dengan pcall untuk mencegah error crash
local ok, err = pcall(main)
if not ok then
    gg.alert("Terjadi error: " .. tostring(err))
    os.exit()
end