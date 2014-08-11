collectgarbage("collect")

Martin_Config = {}
Martin_Config.nStepper = 0
Martin_Config.nFram = 4

RegisterCustomData("Martin_Config.nFram")

function Martin_Config.OnFrameBreathe()

    if Martin_Config.nStepper % Martin_Config.nFram == 0 then
        Martin_Macro.Run()
    end

    Martin_Config.nStepper = Martin_Config.nStepper + 1

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
Player_AppendAddonMenu({meun})

function Martin_Config.Debug()
    collectgarbage("collect")
    Martin_Macro.GetFileCode()
    OutputMessage("MSG_SYS", "======加载成功======".."\n")
    OutputMessage("MSG_SYS", "======当前执行频率:"..16/Martin_Config.nFram.."次/秒, 可在头像菜单处修改======".."\n")
end

collectgarbage("collect")