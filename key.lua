-- ============================================
-- KEY ACTIVATION SYSTEM - RIDO SCRIPT
-- keys.json: https://raw.githubusercontent.com/ahayriski20-ship-it/Rido/0429ac4f2daff0aa085292716c94bf6897fbb81a/keys.json
-- ============================================

local KEY_FILE = "/data/local/tmp/.rido_license"
local KEYS_URL = "https://raw.githubusercontent.com/ahayriski20-ship-it/Rido/0429ac4f2daff0aa085292716c94bf6897fbb81a/keys.json"
local MAIN_SCRIPT_URL = "https://raw.githubusercontent.com/ahayriski20-ship-it/Rido/0429ac4f2daff0aa085292716c94bf6897fbb81a/sc.lua"

-- Fungsi mendapatkan waktu real dari server (ANTI MUNDUR WAKTU)
local function getRealTimestamp()
    local sources = {
        "https://worldtimeapi.org/api/ip",
        "https://timeapi.io/api/Time/current/zone?timeZone=Asia/Jakarta",
        "http://worldtimeapi.org/api/timezone/Asia/Jakarta"
    }
    
    for _, url in ipairs(sources) do
        local resp = gg.makeRequest(url).content
        if resp then
            local success, timeData = pcall(function()
                return load("return " .. resp)()
            end)
            
            if success and timeData then
                local datetime = timeData.datetime or timeData.utc_datetime
                if datetime then
                    local year = tonumber(datetime:sub(1,4))
                    local month = tonumber(datetime:sub(6,7))
                    local day = tonumber(datetime:sub(9,10))
                    local hour = tonumber(datetime:sub(12,13))
                    local min = tonumber(datetime:sub(15,16))
                    local sec = tonumber(datetime:sub(18,19))
                    
                    return os.time({
                        year = year,
                        month = month,
                        day = day,
                        hour = hour or 0,
                        min = min or 0,
                        sec = sec or 0
                    })
                end
            end
        end
    end
    
    gg.alert("⚠️ PERINGATAN!\nTidak bisa verifikasi waktu real.\nPastikan koneksi internet aktif!")
    return os.time()
end

-- Ambil Device ID (untuk lock ke 1 device)
local function getDeviceID()
    local files = {
        "/data/system/batterystats.bin",
        "/data/system/packages.list",
        "/proc/version"
    }
    
    for _, file in ipairs(files) do
        local f = io.open(file, "r")
        if f then
            local content = f:read("*all")
            f:close()
            local hash = 0
            for i = 1, #content do
                hash = (hash + string.byte(content, i)) % 0xFFFFFFFF
            end
            return string.format("%x", hash):sub(1,8)
        end
    end
    
    return tostring(math.random(10000000, 99999999))
end

-- Simpan license ke file
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

-- Load license dari file
local function loadLicense()
    local content = gg.getFile(KEY_FILE)
    if content then
        local success, data = pcall(function()
            return load(content)()
        end)
        if success then
            return data
        end
    end
    return nil
end

-- Validasi key dari GitHub
local function validateKeyFromGitHub(key)
    local response = gg.makeRequest(KEYS_URL).content
    
    if not response then
        gg.alert("❌ GAGAL!\nTidak dapat mengakses server key.\nPeriksa koneksi internet!")
        return nil
    end
    
    local success, keysData = pcall(function()
        return load("return " .. response)()
    end)
    
    if not success or not keysData or not keysData.keys then
        gg.alert("❌ ERROR!\nFormat keys.json tidak valid!")
        return nil
    end
    
    return keysData.keys[key]
end

-- Tampilkan input key
local function promptKey()
    local input = gg.prompt({
        "🔑 MASUKAN ACTIVATION KEY"
    }, {
        ""
    }, {
        "text"
    })
    
    if not input then
        gg.alert("❌ Key wajib diisi!\nScript akan ditutup.")
        os.exit()
        return nil
    end
    
    local key = input[1]:upper():gsub("%s+", "")
    if key == "" then
        gg.alert("❌ Key tidak boleh kosong!")
        os.exit()
        return nil
    end
    
    return key
end

-- Fungsi utama cek license
local function checkLicense()
    local device_id = getDeviceID()
    local saved = loadLicense()
    local current_time = getRealTimestamp()
    
    -- CASE 1: Sudah punya license tersimpan
    if saved and saved.key then
        -- Re-validasi key ke GitHub
        local keyInfo = validateKeyFromGitHub(saved.key)
        
        if not keyInfo then
            gg.alert("❌ LISENSI TIDAK VALID!\nKey tidak ditemukan di server.\nHubungi support.")
            return false
        end
        
        -- Hitung expired
        local expiry_time = saved.activated_at + (saved.duration_days * 86400)
        local days_left = math.floor((expiry_time - current_time) / 86400)
        
        if current_time > expiry_time then
            gg.alert("❌ LISENSI EXPIRED!\n\nMasa aktif telah berakhir.\nHubungi owner untuk perpanjangan.")
            return false
        end
        
        if saved.device_id and saved.device_id ~= device_id then
            gg.alert("❌ LISENSI TERKUNCI!\n\nKey ini sudah digunakan di device lain.")
            return false
        end
        
        if days_left <= 3 then
            gg.alert("⚠️ PERINGATAN!\n\nLisensi akan expired dalam " .. days_left .. " hari!\nSegera perpanjang.")
        else
            gg.alert("✅ LISENSI AKTIF\n\nSisa masa aktif: " .. days_left .. " hari")
        end
        
        return true
    
    -- CASE 2: Belum punya license, minta input key
    else
        gg.alert("🔐 AKTIVASI DIPERLUKAN\n\nSilakan masukkan activation key yang telah Anda beli.")
        
        local key = promptKey()
        if not key then return false end
        
        local keyInfo = validateKeyFromGitHub(key)
        
        if not keyInfo then
            gg.alert("❌ KEY TIDAK VALID!\n\nKey '" .. key .. "' tidak ditemukan di server.")
            return false
        end
        
        local duration_days = keyInfo.duration_days or 7
        local activated_at = current_time
        
        saveLicense(key, device_id, activated_at, duration_days)
        
        local expiry_text = (duration_days == 99999) and "PERMANEN" or (duration_days .. " hari")
        
        gg.alert("✅ AKTIVASI BERHASIL!\n\nKey: " .. key .. "\nMasa aktif: " .. expiry_text .. "\n\nSelamat menggunakan!")
        
        return true
    end
end

-- ============================================
-- EKSEKUSI UTAMA
-- ============================================
if checkLicense() then
    -- Ambil dan jalankan sc.lua
    local scriptContent = gg.makeRequest(MAIN_SCRIPT_URL).content
    
    if scriptContent then
        local success, err = pcall(load(scriptContent))
        if not success then
            gg.alert("❌ Gagal menjalankan script utama!\nError: " .. tostring(err))
        end
    else
        gg.alert("❌ Gagal mengambil sc.lua dari server!\nPeriksa koneksi internet.")
    end
else
    os.exit()
end