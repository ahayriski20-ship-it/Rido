

function LibAutoLibil2cpp(A0_8, A1_9)
    localpack = gg.getTargetInfo().nativeLibraryDir
    for i, i in pairs((gg.getRangesList(localpack .. "/libil2cpp.so"))) do
      if gg.getValues({
        {
          address = i.start,
          flags = gg.TYPE_DWORD
        },
        {
          address = i.start + 18,
          flags = gg.TYPE_WORD
        }
      })[1].value == 1179403647 then
        A0_8 = i.start + A0_8
      end
      assert(A0_8 ~= nil, "[rwmem]: error, provided address is nil.")
      _rw = {} 
      if type(A1_9) == "number" then
        i = ""
        for i = 1, A1_9 do
          _rw[i] = {
            address = A0_8 - 1 + i,
            flags = gg.TYPE_BYTE
          }
        end
        for i, i in ipairs(gg.getValues(_rw)) do
          i = i .. string.format("%02X", i.value & 255)
        end
        return i
      end
      Byte = {}
      A1_9:gsub("..", function(A0_10)
        local L1_11, L2_12, L3_13
        L1_11 = Byte
        L2_12 = Byte
        L2_12 = #L2_12
        L2_12 = L2_12 + 1
        L1_11[L2_12] = A0_10
        L1_11 = _rw
        L2_12 = Byte
        L2_12 = #L2_12
        L3_13 = {}
        L3_13.address = A0_8 - 1 + #Byte
        L3_13.flags = gg.TYPE_BYTE
        L3_13.value = A0_10 .. "h"
        L1_11[L2_12] = L3_13
      end
      )
      gg.setValues(_rw)
    end
  end




function LibManual(Lib, Offset, Replaced)
function scriptmod(b,c,d,e)
gg.setRanges(32) 
gg.searchNumber(b,c) 
local x=gg.getResults(100) 
gg.addListItems(x) local x = 
gg.getListItems(100) 
x=gg.getValues(x) x[1].address 
= x[1].address-d x[1].value =e 
gg.setValues(x) gg.removeListItems(x) 
local x=gg.getListItems(1) 
gg.removeListItems(x) gg.clearResults() end 
local info = gg.getTargetInfo()
localpack = info.nativeLibraryDir
local t = gg.getRangesList(localpack..'/'..Lib)
for _, __ in pairs(t) do
local t = gg.getValues({{address = __.start, flags = gg.TYPE_DWORD}, {address = __.start + 0x12, flags = gg.TYPE_WORD}})
if t[1].value == 0x464C457F then
Offset = __['start'] + Offset end
assert(Offset ~= nil, '[rwmem]: error, provided address is nil.')
_rw = {}
if type(Replaced) == 'number' then
_ = ''
for _ = 1, Replaced do _rw[_] = {address = (Offset - 1) + _, flags = gg.TYPE_BYTE} end
for v, __ in ipairs(gg.getValues(_rw)) do _ = _ .. string.format('%02X', __.value & 0xFF) end
return _
end
Byte = {} Replaced:gsub('..', function(x) 
Byte[#Byte + 1] = x _rw[#Byte] = {address = (Offset - 1) + #Byte, flags = gg.TYPE_BYTE, value = x .. 'h'} 
end)
gg.setValues(_rw)
end 
end



local memFrom, memTo, lib, num, lim, results, src, ok = 0, -1, nil, 0, 32, {}, nil, false
function name(n) if lib ~= n then  lib = n  local ranges = gg.getRangesList(lib)
    if #ranges == 0 then  gg.toast("️ENTRE NO JOGO E SELECIONE O PROCESSO CORRETAMENTE ") os.exit()
    else memFrom = ranges[1].start memTo = ranges[#ranges]["end"]  end  end end
function hex2tbl(hex)local ret = {} hex:gsub("%S%S", function(ch) ret[#ret + 1] = ch return "" end) return ret end
function original(orig) local tbl = hex2tbl(orig)  local len = #tbl
  if len == 0 then return end  local used = len  if len > lim then
    used = lim end  local s = ""  for i = 1, used do   if i ~= 1 then
      s = s .. ";" end   local v = tbl[i]   if v == "??" or v == "**" then
      v = "0~~0"   end    s = s .. v .. "r"  end  s = s .. "::" .. used
  gg.searchNumber(s, gg.TYPE_BYTE, false, gg.SIGN_EQUAL, memFrom, memTo)
  if len > used then    for i = used + 1, len do    local v = tbl[i]
      if v == "??" or v == "**" then    v = 256      else      v = ("0x" .. v) + 0     if v > 127 then        v = v - 256       end  end    tbl[i] = v  end end
  local found = gg.getResultCount()  results = {}  local count = 0  local checked = 0
  while not (found <= checked) do    local all = gg.getResults(8)   local total = #all    local start = checked
    if total < checked + used then    break end    for i, v in ipairs(all) do     v.address = v.address + myoffset    end
    gg.loadResults(all)    while total > start do      local good = true
      local offset = all[1 + start].address - 1     if len > used then     local get = {}       for i = lim + 1, len do      get[i - lim] = {          address = offset + i,        flags = gg.TYPE_BYTE,          value = 0      }   end      get = gg.getValues(get)      for i = lim + 1, len do       local ch = tbl[i]
          if ch ~= 256 and get[i - lim].value ~= ch then        good = false          break  end end end
      if good then       count = count + 1   results[count] = offset   checked = checked + used    else      local del = {}     for i = 1, used do      del[i] = all[i + start]      end     gg.removeResults(del)     end start = start + used   end  end end
function replaced(repl)  num = num + 1  local tbl = hex2tbl(repl)
  if src ~= nil then local source = hex2tbl(src)
    for i, v in ipairs(tbl) do   if v ~= "??" and v ~= "**" and v == source[i] then
        tbl[i] = "**"    end end  src = nil end  local cnt = #tbl  local set = {} local s = 0
  for _, addr in ipairs(results) do   for i, v in ipairs(tbl) do
      if v ~= "??" and v ~= "**" then     s = s + 1
        set[s] = {   address = addr + i,  value = v .. "r",   flags = gg.TYPE_BYTE     }
      end end end  if s ~= 0 then gg.setValues(set) end ok = true end 

b =[[

]]
  fileData = gg.EXT_STORAGE .. '/[###].dat'
  io.output(fileData):write(b):close()
  gg.loadList(fileData, gg.LOAD_APPEND)
  r = gg.getListItems()
  getReset = gg.getValues(r)
  gg.clearList()
  os.remove(fileData)



--------------MENU PRINCIPAL-----------

off = "  "
on = " ATIVADO "

function MENU_INICIO()
MENU_HOME = gg.choice({
	
" ➢ GHOST HACK 👻" ..GHOST,
" ➢ ZE PEDRINHA 🪨" ..ZEPEDR,
" ➢ AIM BOT 🎯" ..AIMBO,
" ➢ HEAD SHOT 🎯" ..HEADSHO,
" ➢ CEU PRETO 🌃" ..CEUPRET,
" ➢ NO RECOIL 🔫" ..NORECOI,
" ➢ SPEED 5x 🏃" ..SPEE,
" ➢ UNDER 🚓" ..UND,
" ➢ MENU ANTENA",
"  🛡️ BYPASS LOBBY 🛡️",
	
	               "⪼ Sair ⪻",
},nil,"SCRIPT VIP MMmods\nFree Fire 1.92.x\nVersao Completa")

if MENU_HOME == nil then else
if MENU_HOME == 1 then GHOSTHACK() end
if MENU_HOME == 2 then ZEPEDRA() end
if MENU_HOME == 3 then AIMBOT() end
if MENU_HOME == 4 then HEADSHOT() end
if MENU_HOME == 5 then CEUPRETO() end
if MENU_HOME == 6 then NORECOIL() end
if MENU_HOME == 7 then SPEED() end
if MENU_HOME == 8 then UNDERCAR() end
if MENU_HOME == 9 then MENUANTENA() end
if MENU_HOME == 10 then byp() end
if MENU_HOME == 11 then exit() end
end
SCRIPT_BASE_VIP = -1
end


-------------------FUNCOES CÓDIGOS------------

GHOST = off
function GHOSTHACK()
if GHOST == off then 
LibAutoLibil2cpp("0x197AF10", "0000A0E31EFF2FE1")
gg.clearResults()
gg.toast("Ghost Hack ON👻")
GHOST = on
elseif GHOST == on  then  
LibAutoLibil2cpp("0x197AF10", "704C2DE910B08DE2")
gg.clearResults()
gg.toast("❌Ghost Hack OFF ❌")
GHOST = off
end 
end

ZEPEDR = off
function ZEPEDRA()
if ZEPEDR == off then
gg.clearResults()
io.output(fileData):write([[
24627
Var #83AA5128|83aa5128|10|4479c000|0|0|0|0|r-xp|/data/data/com.chaozhuo.gameassistant/virtual/data/app/com.dts.freefireth/lib/libunity.so|b63128
Var #83AA5138|83aa5138|10|4479c000|0|0|0|0|r-xp|/data/data/com.chaozhuo.gameassistant/virtual/data/app/com.dts.freefireth/lib/libunity.so|b63138
Var #83AA5168|83aa5168|10|4479c000|0|0|0|0|r-xp|/data/data/com.chaozhuo.gameassistant/virtual/data/app/com.dts.freefireth/lib/libunity.so|b63168
]]):close()
gg.loadList(fileData, gg.LOAD_APPEND | gg.LOAD_VALUES)
os.remove(fileData)
gg.clearList()
gg.clearResults()
gg.toast(" Ze Pedrinha ON🗿")
ZEPEDR = on
elseif ZEPEDR == on then
gg.clearResults()
io.output(fileData):write([[
24627
Var #83AA5128|83aa5128|10|cafffe57|0|0|0|0|r-xp|/data/data/com.chaozhuo.gameassistant/virtual/data/app/com.dts.freefireth/lib/libunity.so|b63128
Var #83AA5138|83aa5138|10|cafffe53|0|0|0|0|r-xp|/data/data/com.chaozhuo.gameassistant/virtual/data/app/com.dts.freefireth/lib/libunity.so|b63138
Var #83AA5168|83aa5168|10|cafffe47|0|0|0|0|r-xp|/data/data/com.chaozhuo.gameassistant/virtual/data/app/com.dts.freefireth/lib/libunity.so|b63168
]]):close()
gg.loadList(fileData, gg.LOAD_APPEND | gg.LOAD_VALUES)
os.remove(fileData)
gg.clearList()
gg.clearResults()
gg.toast("❌Ze Pedrinha OFF ❌")
ZEPEDR = off
end
end

AIMBO = off
function AIMBOT()
if AIMBO == off then
gg.setRanges(gg.REGION_ANONYMOUS)
gg.searchNumber("1057048494;1054951342;1053273620", gg.TYPE_DWORD, false, gg.SIGN_EQUAL, 0, -1)
gg.getResults(20000)
gg.editAll("-20000", gg.TYPE_DWORD)
gg.clearResults()
gg.setRanges(gg.REGION_CODE_APP)
gg.searchNumber("-1.30928164e25;-3.69511377e20;1.25206298e-38;0.00001", gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1, 0)
gg.refineNumber("0.00001", gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1, 0)
revert = gg.getResults(10, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("1", gg.TYPE_FLOAT)
gg.clearResults()
gg.processResume()
gg.setRanges(gg.REGION_ANONYMOUS)
gg.searchNumber("1.35000002384", gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1, 0)
gg.getResults(1000)
gg.editAll("100", gg.TYPE_FLOAT)
gg.clearResults()
gg.setRanges(gg.REGION_ANONYMOUS)
gg.searchNumber("1057048494;1054951342;1053273620", gg.TYPE_DWORD, false, gg.SIGN_EQUAL, 0, -1)
gg.getResults(20000)
gg.editAll("-20000", gg.TYPE_DWORD)
gg.clearResults()
gg.setRanges(gg.REGION_CODE_APP)
gg.searchNumber("-1.30928164e25;-3.69511377e20;1.25206298e-38;0.00001", gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1, 0)
gg.refineNumber("0.00001", gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1, 0)
revert = gg.getResults(10, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("1", gg.TYPE_FLOAT)
gg.clearResults()
gg.processResume()
AIMBO = on
gg.processResume()
gg.toast("aimbot on")
elseif AIMBO == on then
gg.clearResults()
AIMBO = off
gg.toast("aimbot  off")
end
end

HEADSHO = off
function HEADSHOT()
if HEADSHO == off then
gg.setRanges(gg.REGION_C_ALLOC)
gg.searchNumber(":_Hipsb", gg.TYPE_BYTE, false, gg.SIGN_EQUAL, 0, -1)
gg.getResults(400)
gg.editAll(":_Headb", gg.TYPE_BYTE)
gg.toast("HS 100% | ON")
HEADSHO = on
gg.processResume()
elseif HEADSHO == on then
gg.getResults(400)
gg.editAll(":_Hipsb", gg.TYPE_BYTE)
gg.toast("HS 100% | OFF")
gg.clearResults()
HEADSHO = off
end
end

CEUPRET = off
function CEUPRETO()
if CEUPRET == off then
gg.clearResults()
io.output(fileData):write([[
24627
Var #832418B0|832418b0|10|3f800000|0|0|0|0|r-xp|/data/data/com.chaozhuo.gameassistant/virtual/data/app/com.dts.freefireth/lib/libunity.so|2ff8b0
]]):close()
gg.loadList(fileData, gg.LOAD_APPEND | gg.LOAD_VALUES)
os.remove(fileData)
gg.clearList()
gg.clearResults()
gg.toast("CEU PRETO ATIVADO")
CEUPRET = on
elseif CEUPRET == on then
gg.clearResults()
io.output(fileData):write([[
24627
Var #832418B0|832418b0|10|358637bd|0|0|0|0|r-xp|/data/data/com.chaozhuo.gameassistant/virtual/data/app/com.dts.freefireth/lib/libunity.so|2ff8b0
]]):close()
gg.loadList(fileData, gg.LOAD_APPEND | gg.LOAD_VALUES)
os.remove(fileData)
gg.clearList()
gg.clearResults()
gg.toast("❌ CEU ❌")
CEUPRET = off
end
end

NORECOI = off
function NORECOIL()
if NORECOI == off then
gg.setRanges(32)
gg.searchNumber("0.01748251915", 16, false, 536870912, 0, -1)
gg.getResults(999)
gg.editAll("-2.2958874e-41", 16)
NORECOI = on
gg.processResume()
gg.toast("no recoil on")
elseif NORECOI == on then
gg.setRanges(32)
gg.searchNumber("1016018816", 4, false, 536870912, 0, -5)
gg.getResults(999)
gg.editAll("0006018816", 4)
gg.clearResults()
NORECOI = off
gg.toast("no recoil off")
end
end

SPEE = off
function SPEED()
if SPEE == off then
gg.setRanges(gg.REGION_ANONYMOUS)
gg.searchNumber("2.80259693e-44F;1.20000004768F;0.18000000715F;1.40129846e-45F", gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1)
gg.refineNumber("1.20000004768", gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1)
gg.getResults(500, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("1.780", gg.TYPE_FLOAT)
gg.toast("speed 5x on")
SPEE = on
gg.processResume()
elseif SPEE == on then
gg.getResults(500, nil, nil, nil, nil, nil, nil, nil, nil)
gg.refineNumber("1.20000004768", gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1)
gg.editAll("2.80259693e-44F;1.20000004768F;0.18000000715F;1.40129846e-45F", gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1)
gg.clearResults()
gg.toast("speed 5x off")
SPEE = off
end
end

UND = off
function UNDERCAR()
if UND == off then
gg.clearResults()
io.output(fileData):write([[
13854
Var #7A984470|7a984470|10|c0000000|0|0|0|0|r-xp|/data/data/com.chaozhuo.gameassistant/virtual/data/app/com.dts.freefireth/lib/libil2cpp.so|3280470
]]):close()
gg.loadList(fileData, gg.LOAD_APPEND | gg.LOAD_VALUES)
os.remove(fileData)
gg.clearList()
gg.clearResults()
gg.toast("UNDER ATIVADO")
UND = on
elseif UND == on then
gg.clearResults()
io.output(fileData):write([[
13854
Var #7A984470|7a984470|10|38d1b717|0|0|0|0|r-xp|/data/data/com.chaozhuo.gameassistant/virtual/data/app/com.dts.freefireth/lib/libil2cpp.so|3280470
]]):close()
gg.loadList(fileData, gg.LOAD_APPEND | gg.LOAD_VALUES)
os.remove(fileData)
gg.clearList()
gg.clearResults()
gg.toast("❌ UNDER ❌")
UND = off
end
end







-------------------SUB MENU--------------

function speed4()
SUB_MENU4 = gg.multiChoice({
time .. " Speed Gamer [Paraquedas]",
"🔙Voltar"
},nil, "➮Mᴇɴᴜ  Speed 🏃")
if SUB_MENU4 == nil then else
if SUB_MENU4 [1] == true then speed() end
if SUB_MENU4 [2] == true then MENU_INICIO() end
end
SCRIPT_BASE_VIP = -1
end








------------FIM DA SCRIPT---------



---------FUNCOES DESATIVADAS BASE PARA USAR DE EXEMPLO ------------


---------FUNCAO AUTOMÁTICA EM libl2cpp--------
D46 = off
function gh1()
if D46 == off then 
LibAutoLibil2cpp("0x197AF10", "0000A0E31EFF2FE1")
gg.clearResults()
gg.toast("Ghost Hack ON👻")
D46 = on
elseif D46 == on  then  
LibAutoLibil2cpp("0x197AF10", "704C2DE910B08DE2")
gg.clearResults()
gg.toast("❌Ghost Hack OFF ❌")
D46 = off
end 
end


---------FUNCAO EM libl2cpp--------
ghp = off
function ghostpc()
if ghp == off then
LibManual("libil2cpp.so", "0x29B72E8", "0000A0E3") 
LibManual("libil2cpp.so", "0x29B72EC", "1EFF2FE1") 
gg.toast("💡 Ghost Hack Pc ON💡") 
 ghp = on
elseif ghp == on then
LibManual("libil2cpp.so", "0x29B72E8", "0000A0E3") 
LibManual("libil2cpp.so", "0x29B72EC", "1EFF2FE1") 
gg.toast("❌ Ghost Hack Pc OFF❌")
ghp = off
end
end


---------FUNCAO EM libunity--------
time = off
function speed()
if time == off then
LibManual("libunity.so", "0x342A0C", "5DE62F3E")
gg.toast("💡 Speed Gemer ON 💡")
time = on
elseif time == on then
LibManual("libunity.so", "0x342A0C", "0B2E113E")
gg.toast("❌ Speed Gemer OFF❌")
time = off
end
end


---------FUNCAO EM VAR CODE-----
ze = off
function pedra()
if ze == off then
gg.clearResults()
io.output(fileData):write([[
10231
Var #86635BE8|86635be8|10|4479c000|0|0|0|0|r-xp|/data/data/com.chaozhuo.gameassistant/virtual/data/app/com.dts.freefireth/lib/libunity.so|adabe8
Var #86635BF8|86635bf8|10|4479c000|0|0|0|0|r-xp|/data/data/com.chaozhuo.gameassistant/virtual/data/app/com.dts.freefireth/lib/libunity.so|adabf8
Var #86635C28|86635c28|10|4479c000|0|0|0|0|r-xp|/data/data/com.chaozhuo.gameassistant/virtual/data/app/com.dts.freefireth/lib/libunity.so|adac28
]]):close()
gg.loadList(fileData, gg.LOAD_APPEND | gg.LOAD_VALUES)
os.remove(fileData)
gg.sleep(50)
gg.clearList()
gg.clearResults()
gg.toast(" 💡Ze Pedrinha ON🗿💡")
ze = on
elseif ze == on then
gg.clearResults()
io.output(fileData):write([[
10231
Var #86635BE8|86635be8|10|cafffe57|0|0|0|0|r-xp|/data/data/com.chaozhuo.gameassistant/virtual/data/app/com.dts.freefireth/lib/libunity.so|adabe8
Var #86635BF8|86635bf8|10|cafffe53|0|0|0|0|r-xp|/data/data/com.chaozhuo.gameassistant/virtual/data/app/com.dts.freefireth/lib/libunity.so|adabf8
Var #86635C28|86635c28|10|cafffe47|0|0|0|0|r-xp|/data/data/com.chaozhuo.gameassistant/virtual/data/app/com.dts.freefireth/lib/libunity.so|adac28
]]):close()
gg.loadList(fileData, gg.LOAD_APPEND | gg.LOAD_VALUES)
os.remove(fileData)
gg.sleep(50)
gg.clearList()
gg.clearResults()
gg.toast("❌Ze Pedrinha OFF ❌")
ze = off
end
end




function exit()
print("❤️")
gg.toast("TACHAU")
os.exit()
end

function ScriptMod(a, b)gg.clearResults()gg.setRanges(32)gg.searchNumber(a, 2)gg.setVisible(false)gg.getResults(1000)gg.editAll(b, 2)gg.setVisible(false)gg.clearResults()end


while true do
  if gg.isVisible(true) then
    SCRIPT_BASE_VIP = 1
    gg.setVisible(false)
    gg.clearResults()
  end
  if SCRIPT_BASE_VIP == 1 then
    MENU_INICIO()
  end
  SCRIPT_BASE_VIP = -1
end