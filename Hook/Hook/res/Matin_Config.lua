collectgarbage("collect")

Martin_Config = {}
Martin_Config.nStepper = 0
Martin_Config.nFram = 4
Martin_Config.bAuto = false
Martin_Config.bFace = true

RegisterCustomData("Martin_Config.nFram")
RegisterCustomData("Martin_Config.bFace")

function Martin_Config.OnFrameBreathe()

    if Martin_Config.bFace then
        Martin_Macro.FaceToTarget() --面向目标
    end

    if Martin_Config.nStepper % Martin_Config.nFram == 0 then
        Martin_Macro.Run()
    end

    Martin_Config.nStepper = Martin_Config.nStepper + 1

    if Martin_Config.bAuto == false then
        local nKey, bShift, bCtrl, bAlt = Hotkey.Get("Martin")
        if Hotkey.IsKeyDown(nKey) == false then
            Martin_Config.CloseWindow()
        end
    end

end

function Martin_Config.OpenWindow()

    local frame = Station.Lookup("Lowest/Martin_Config") --定义窗体为frame
    if not frame then --如果没有发现窗体，则打开窗体
        Wnd.OpenWindow("C:\\Windows\\config.ini", "Martin_Config")
    end
    frame:Show() --将窗体显示出来

end

function Martin_Config.CloseWindow()

    local frame = Station.Lookup("Lowest/Martin_Config") --定义窗体为frame
    if frame then --如发现窗体, 则关闭它
        Martin_Config.nStepper = 0
        Wnd.CloseWindow(frame)
    end

end

local meun = {szOption = "土鳖一键PVP",}
local firstlevelmenu = {szOption = "执行频率",}
table.insert(firstlevelmenu,{szOption = "16 次/秒",bMCheck = true,bCheck = true,bChecked = function() if Martin_Config.nFram == 1 then return true end end,fnAction = function() Martin_Config.nFram = 1 OutputMessage("MSG_SYS", "======修改执行频率为:"..16/Martin_Config.nFram.."次/秒, 可在头像菜单处修改======".."\n") end})
table.insert(firstlevelmenu,{szOption = "8   次/秒",bMCheck = true,bCheck = true,bChecked = function() if Martin_Config.nFram == 2 then return true end end,fnAction = function() Martin_Config.nFram = 2 OutputMessage("MSG_SYS", "======修改执行频率为:"..16/Martin_Config.nFram.."次/秒, 可在头像菜单处修改======".."\n") end})
table.insert(firstlevelmenu,{szOption = "4   次/秒",bMCheck = true,bCheck = true,bChecked = function() if Martin_Config.nFram == 4 then return true end end,fnAction = function() Martin_Config.nFram = 4 OutputMessage("MSG_SYS", "======修改执行频率为:"..16/Martin_Config.nFram.."次/秒, 可在头像菜单处修改======".."\n") end})
table.insert(meun,firstlevelmenu)
local secondlevelmenu = {szOption = "自动面向",}
table.insert(secondlevelmenu,{szOption = "开启",bMCheck = true,bCheck = true,bChecked = function() return Martin_Config.bFace end,fnAction = function() Martin_Config.bFace = not Martin_Config.bFace OutputMessage("MSG_SYS", "======开启自动面向======".."\n") end})
table.insert(secondlevelmenu,{szOption = "关闭",bMCheck = true,bCheck = true,bChecked = function() return not Martin_Config.bFace end,fnAction = function() Martin_Config.bFace = not Martin_Config.bFace OutputMessage("MSG_SYS", "======关闭自动面向======".."\n") end})
table.insert(meun,secondlevelmenu)
Player_AppendAddonMenu({meun})

local function MyRun()
    --Output(Hotkey.GetBinding(false))
    --Output(Hotkey.Get("Martin"))
    Martin_Config.OpenWindow()
    --Martin_Macro.Run()
end

local function MyOpen()
    OutputMessage("MSG_SYS", "======开始执行======".."\n")
    Martin_Config.bAuto = true
    Martin_Config.OpenWindow()
end

local function MyClose()
    OutputMessage("MSG_SYS", "======结束执行======".."\n")
    Martin_Config.bAuto = false
    Martin_Config.CloseWindow()
end

Hotkey.AddBinding("Martin","触发键","土鳖一键PVP",function() MyRun() end,nil)
Hotkey.AddBinding("Martin_Open","启动","",function() MyOpen() end,nil)
Hotkey.AddBinding("Martin_Close","关闭","",function() MyClose() end,nil)
--AppendCommand("土鳖一键PVP",MyRun())

function Martin_Config.Debug()
    collectgarbage("collect")
    Martin_Macro.GetFileCode()
    OutputMessage("MSG_SYS", "======加载成功======".."\n")
    OutputMessage("MSG_SYS", "======当前执行频率:"..16/Martin_Config.nFram.."次/秒, 可在头像菜单处修改======".."\n")
end

collectgarbage("collect")