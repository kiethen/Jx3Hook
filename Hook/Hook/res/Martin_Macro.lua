collectgarbage("collect")

Martin_Macro = {}
--Martin_Macro.bChannel = false
--Martin_Macro.nStepper = 0

Martin_Macro.nSkilldwID = 0
Martin_Macro.nSkillLevel = 0
Martin_Macro.tnSkilldwID = 0
Martin_Macro.tnSkillLevel = 0
--Martin_Macro.bEndCode = nil
--Martin_Macro.bBeginCode = ""

function Martin_Macro.GetFileCode()
  local f = assert(io.open("C:\\Windows\\testRead.txt", 'r'))
  local string = f:read("*all")
  f:close()
  Martin_Macro.StrCodes = string
  OutputMessage("MSG_SYS", Martin_Macro.StrCodes.."\n")
end


--获取周围敌对目标数量
function Martin_Macro.GetEnemyNum(szMaxR,szSym,szValue)

	local EnemyNum=0
	local player = GetClientPlayer()
	if not player then return end
	for i,v in pairs(GetNearbyPlayerList()) do
		local hPlayer = GetPlayer(v)
		if hPlayer and player.dwID ~= hPlayer.dwID then
			local nDist = math.floor(GetCharacterDistance(player.dwID,v)/64)
			if nDist < tonumber(szMaxR) then
				if IsEnemy(player.dwID,hPlayer.dwID) then
					if hPlayer.nMoveState ~= MOVE_STATE.ON_DEATH then
						EnemyNum = EnemyNum + 1
					end
				end
			end
		end
	end
	
    if szSym == "=" then
        if EnemyNum == tonumber(szValue) then
            return true
        end
        
    elseif szSym == "<" then
        if EnemyNum < tonumber(szValue) then
            return true
        end

    elseif szSym == "<=" then
        if EnemyNum <= tonumber(szValue) then
            return true
        end

    elseif szSym == ">" then
        if EnemyNum > tonumber(szValue) then
            return true
        end

    elseif szSym == ">=" then
        if EnemyNum >= tonumber(szValue) then
            return true
        end

    end

    return false
    
end

--判断上一次释放技能
function Martin_Macro.MySkill(PlayerID,SkillID,SkillLv)

	local player = GetClientPlayer()
	local ttp,tid = player.GetTarget()

	if player.dwID == PlayerID then
        if Table_GetSkillName(SkillID,SkillLv) ~= nil and Table_GetSkillName(SkillID,SkillLv) ~= "" then
            Martin_Macro.nSkilldwID = SkillID
            Martin_Macro.nSkillLevel = SkillLv    
        end
    elseif tid == PlayerID then
        if Table_GetSkillName(SkillID,SkillLv) ~= nil and Table_GetSkillName(SkillID,SkillLv) ~= "" then
            Martin_Macro.tnSkilldwID = SkillID
            Martin_Macro.tnSkillLevel = SkillLv    
        end
	end

end

--注册技能监控事件
RegisterEvent("SYS_MSG", function()
	if arg0 == "UI_OME_SKILL_HIT_LOG" and arg3 == SKILL_EFFECT_TYPE.SKILL then
        if Table_GetSkillName(arg4,arg5) ~= nil and Table_GetSkillName(arg4,arg5) ~= "" then
            Martin_Macro.MySkill(arg1,arg4,arg5)
        end
	elseif arg0 == "UI_OME_SKILL_EFFECT_LOG" and arg4 == SKILL_EFFECT_TYPE.SKILL then
        if Table_GetSkillName(arg5,arg6) ~= nil and Table_GetSkillName(arg5,arg6) ~= "" then
            Martin_Macro.MySkill(arg1,arg5,arg6)
        end
	elseif (arg0 == "UI_OME_SKILL_BLOCK_LOG" or arg0 == "UI_OME_SKILL_SHIELD_LOG" or arg0 == "UI_OME_SKILL_MISS_LOG" or arg0 == "UI_OME_SKILL_DODGE_LOG") and arg3 == SKILL_EFFECT_TYPE.SKILL then
        if Table_GetSkillName(arg4,arg5) ~= nil and Table_GetSkillName(arg4,arg5) ~= "" then
            Martin_Macro.MySkill(arg1,arg4,arg5)
        end
	end
end)

RegisterEvent("DO_SKILL_CAST",  function()
    if Table_GetSkillName(arg1,arg2) ~= nil and Table_GetSkillName(arg1,arg2) ~= "" then
      Martin_Macro.MySkill(arg0,arg1,arg2)
    end
end)

function Martin_Macro.CheckCast(szRule,szKeyName)

    if szRule == "cast" then
        if Table_GetSkillName(Martin_Macro.nSkilldwID,Martin_Macro.nSkillLevel) == szKeyName then
            Martin_Macro.nSkilldwID = 0
            Martin_Macro.nSkillLevel = 0
            Martin_Macro.tnSkilldwID = 0
            Martin_Macro.tnSkillLevel = 0
            return true
        end
    elseif szRule == "tcast" then
        if Table_GetSkillName(Martin_Macro.tnSkilldwID,Martin_Macro.tnSkillLevel) == szKeyName then
            Martin_Macro.nSkilldwID = 0
            Martin_Macro.nSkillLevel = 0
            Martin_Macro.tnSkilldwID = 0
            Martin_Macro.tnSkillLevel = 0
            return true
        end
    end
	return false

end

--根据指定BUFF ID判断对象是否有BUFF 返回BUFF层数
function Martin_Macro.BuffChackById(hPlayer, dwBUFFID)

	if hPlayer then
        for i = 1,hPlayer.GetBuffCount(),1 do
            local dwID, nLevel, bCanCancel, nEndFrame, nIndex, nStackNum, dwSkillSrcID, bValid = hPlayer.GetBuff(i - 1)
            if dwID == dwBUFFID then--指定BUFF
                return nStackNum
            end
        end
	end

    return 0

end

--根据指定BUFF Name判断对象是否有BUFF
function Martin_Macro.BuffChackByName(hPlayer, szBuffName, bMbuff)

    local QiChangList = {"镇山河", "吞日月", "碎星辰", "凌太虚", "冲阴阳", "破苍穹", "化三清", "生太极"}

	if hPlayer then
        if bMbuff == false then
            for i = 1,hPlayer.GetBuffCount(),1 do
                local dwID, nLevel, bCanCancel, nEndFrame, nIndex, nStackNum, dwSkillSrcID, bValid = hPlayer.GetBuff(i - 1)
                if Table_GetBuffName(dwID, nLevel) == szBuffName then
                     return true
                end
            end
        else

            for i = 1,hPlayer.GetBuffCount(),1 do
                local dwID, nLevel, bCanCancel, nEndFrame, nIndex, nStackNum, dwSkillSrcID, bValid = hPlayer.GetBuff(i - 1)

                 for i,v in pairs(QiChangList) do
                    if szBuffName == v then  --气场类型BUFF
                        if Table_GetBuffName(dwID, nLevel) == szBuffName then
                            local hNpc = GetNpc(dwSkillSrcID) --获取气场对象
                            if hNpc.dwEmployer == GetClientPlayer().dwID then
                                return true
                            end
                        end
                    end
                 end

                if Table_GetBuffName(dwID, nLevel) == szBuffName then
                     if GetClientPlayer().dwID == dwSkillSrcID then
                        return true
                     end
                end
            end
        end
	end
    return false

end

--根据指定BUFF Name 返回BUFF层数
function Martin_Macro.ChackBuffByNameRetNum(hPlayer, szBuffName, bMbuff)

	if hPlayer then
        if bMbuff == false then
            for i = 1,hPlayer.GetBuffCount(),1 do
                local dwID, nLevel, bCanCancel, nEndFrame, nIndex, nStackNum, dwSkillSrcID, bValid = hPlayer.GetBuff(i - 1)
                if Table_GetBuffName(dwID, nLevel) == szBuffName then
                     return nStackNum
                end
            end
        else
            for i = 1,hPlayer.GetBuffCount(),1 do
                local dwID, nLevel, bCanCancel, nEndFrame, nIndex, nStackNum, dwSkillSrcID, bValid = hPlayer.GetBuff(i - 1)
                if GetClientPlayer().dwID == dwSkillSrcID then
                    if Table_GetBuffName(dwID, nLevel) == szBuffName then
                         return nStackNum
                    end
                end
            end
        end
    

	end
    return 0

end

--通过技能名获取技能ID 等级
function Martin_Macro.GetSkillID(szSkillName)

	--local hPlayer = GetClientPlayer()
	--local aSkill = hPlayer.GetAllSkillList() or {}
	--for k, v in pairs(aSkill) do
		--local szName = Table_GetSkillName(k, v)
        --if szSkillName == szName then
			--return k, v
		--end
	--end
    local player = GetClientPlayer()
	local nSkillID = g_SkillNameToID[szSkillName]
    local nSkillLv = player.GetSkillLevel(nSkillID)
	return nSkillID, nSkillLv

end

--判断自身是否有xx技能
--function Martin_Macro.CheckHaveSkill(szRule, szSkillName)
    --local ret = false

	--local hPlayer = GetClientPlayer()
	--local aSkill = hPlayer.GetAllSkillList() or {}

	--for k, v in pairs(aSkill) do
		--local szName = Table_GetSkillName(k, v)
		--if szName == szSkillName then
			--ret = true
            --break
		--end
	--end

    --if szRule == "haveskill" then
        --return ret
    --elseif szRule == "noskill" then
        --return not ret
    --end

    
--end

-- 计算目标距离，多玩盒子的GetDistance只能判断水平，高度不算在内
function Martin_Macro.MyGetDistance(szRule, nDce)

	local player = GetClientPlayer()
	local ttp,tid = player.GetTarget()
	local tplayer = GetTargetHandle(ttp,tid)
	if tplayer then
		local distance = math.floor(((player.nX - tplayer.nX) ^ 2 + (player.nY - tplayer.nY) ^ 2 + (player.nZ/8 - tplayer.nZ/8) ^ 2) ^ 0.5)/64
        nDce = tonumber(("%.2f"):format(nDce))
        if szRule == "=" then
            if distance == nDce then
                return true
            end  
        elseif szRule == ">" then            
            if distance > nDce then
                return true
            end
        elseif szRule == "<" then
            if distance < nDce then
                return true
            end
        elseif szRule == "=" then
            if distance == nDce then
                return true
            end
        elseif szRule == "<=" then
            if distance <= nDce then
                return true
            end
        elseif szRule == "<=" then
            if distance <= nDce then
                return true
            end
        end
        
        return false
	end

end

-- 计算目标高度
function Martin_Macro.CheckHeight(szRule, nDce)

	local player = GetClientPlayer()
	local tplayer = GetTargetHandle(player.GetTarget())

	if tplayer then
		local distance = (player.nZ/8 - tplayer.nZ/8)/64
        nDce = tonumber(("%.2f"):format(nDce))
        if szRule == "=" then
            if distance == nDce then
                return true
            end  
        elseif szRule == ">" then            
            if distance > nDce then
                return true
            end
        elseif szRule == "<" then
            if distance < nDce then
                return true
            end
        elseif szRule == "=" then
            if distance == nDce then
                return true
            end
        elseif szRule == "<=" then
            if distance <= nDce then
                return true
            end
        elseif szRule == "<=" then
            if distance <= nDce then
                return true
            end
        end
        
        return false
	end

end

--计算转向角度并转向目标
function Martin_Macro.FaceToTarget()

    local player = GetClientPlayer()
    local ttp,tid = player.GetTarget()
    if tid == 0 or tid == player.dwID then
        return
    end

    local tplayer = GetTargetHandle(ttp,tid)  
    local tanX = tplayer.nX - player.nX
    local tanY = tplayer.nY - player.nY

    TurnTo(math.atan2(tanY,tanX)*128/math.pi)

end

--计算面向 0 ~ 180 face>45  noface
function Martin_Macro.CheckFace(szRule,szSym,szValue)

    local player = GetClientPlayer()
    local ttp,tid = player.GetTarget()
    local tplayer = GetTargetHandle(ttp,tid)

    if not tplayer then
		return false
	end

    local tanX = tplayer.nX - player.nX
    local tanY = tplayer.nY - player.nY
    local meface = math.abs((player.nFaceDirection - math.atan2(tanY,tanX)*128/math.pi)*360/256)

    --if (math.atan2(tanY,tanX)*128/math.pi) < 0 then
		--meface = (math.abs(player.nFaceDirection - (256 - math.abs(math.atan2(tanY,tanX)*128/math.pi))))
	--else
		--meface = (math.abs(player.nFaceDirection - math.abs(math.atan2(tanY,tanX)*128/math.pi)))
	--end

    if meface > 180 then
        meface = 360 - meface
    end

    if szValue == "noface" then
        if meface > 90 then
            return true
        end
    elseif szRule == "face" then
        szValue = tonumber(szValue)
        if szSym == "=" then
            if meface == szValue then
                return true
            end          
        elseif szSym == ">" then
            if meface > szValue then
                return true
            end
        elseif szSym == ">=" then
            if meface >= szValue then
                return true
            end
        elseif szSym == "<" then
            if meface < szValue then
                return true
            end
        elseif szSym == "<=" then
            if meface <= szValue then
                return true
            end
        end
    end

    return false

end

--是否在读条
function Martin_Macro.CheckSkillPrepare(szRule, szSkillName)

	local player = GetClientPlayer()
	local target = GetTargetHandle(player.GetTarget())
    local breturn

    if szSkillName == "prepare" or szRule == "prepare" then
        breturn = true
    elseif szSkillName == "noprepare" or szRule == "noprepare" then
        breturn = false
    end
    
    if target then
        local bPrepare, dwID, nLevel, nFrameProgress = target.GetSkillPrepareState() 

        if szRule == "" then
            if bPrepare == true then
                if nFrameProgress > 0.1 then
                    return breturn
                end
            end

        elseif Table_GetSkillName(dwID,nLevel) == szSkillName then
                if nFrameProgress > 0.1 then
                    return breturn
                end
        end
    end

    return not breturn

end

--自身是否在读条
function Martin_Macro.CheckBroken(szRule, szSkillName)

	local player = GetClientPlayer()
    local breturn

    if szSkillName == "broken" or szRule == "broken" then
        breturn = true
    elseif szSkillName == "nobroken" or szRule == "nobroken" then
        breturn = false
    end
    
    local bPrepare, dwID, nLevel, nFrameProgress = player.GetSkillPrepareState() 

    if szRule == "" then
        if bPrepare == true then
             return breturn
        end

    elseif Table_GetSkillName(dwID,nLevel) == szSkillName then
             return breturn
    end

    return not breturn

end


local PetList = {
    ["灵蛇"] = 9998,
    ["圣蝎"] = 9956,
    ["风蜈"] = 9996,
    ["天蛛"] = 9997,
    ["玉蟾"] = 9999,
}

--检查WD宠物状态
function Martin_Macro.CheckPet(szRule,szKeyName)

    local player = GetClientPlayer()
    local pet = GetClientPlayer().GetPet()
    local breturn

    if szKeyName == "pet" or szRule == "pet" then
        breturn = true
        
    elseif szKeyName == "nopet" or szRule == "nopet" then
        breturn = false
    end

    if szRule:find("pet") == nil then
        if pet then
            return breturn
        end
    else
        if pet then
            for bit, dwID in pairs(PetList) do
                if dwID == pet.dwTemplateID then
                    if bit == szKeyName then
                        return breturn
                    else
                        break
                    end
                end
            end  
        end
    end

    return not breturn

end

--buff类
function Martin_Macro.CheckBuff(szRule,szBuffName,szSym,szNum)

	local player = GetClientPlayer()
	local target = GetTargetHandle(player.GetTarget())
    local dummy
    local bMbuff = false
    local breturn

    if szRule == "buff" then
        dummy = player
        breturn = true

    elseif szRule == "nobuff" then
        dummy = player
        breturn = false

    elseif szRule == "tbuff" then
        dummy = target
        breturn = true

    elseif szRule == "tnobuff" then
        dummy = target
        breturn = false

    elseif szRule == "mbuff" then
        dummy = target
        bMbuff = true
        breturn = true

    elseif szRule == "nombuff" then
        dummy = target
        bMbuff = true
        breturn = false

    end

    if szSym == "" then
        if Martin_Macro.BuffChackByName(dummy, szBuffName, bMbuff) then
            return breturn
        end
        
    else
        --判断层数
        local nStackNum = Martin_Macro.ChackBuffByNameRetNum(dummy, szBuffName, bMbuff)

        if szSym == ">" then
            if nStackNum > tonumber(szNum) then
                return breturn
            end
        elseif szSym == "<" then
            if nStackNum < tonumber(szNum) then
                return breturn
            end
        elseif szSym == "=" then
            if nStackNum == tonumber(szNum) then
                return breturn
            end
        elseif szSym == "<=" then
            if nStackNum <= tonumber(szNum) then
                return breturn
            end
        elseif szSym == ">=" then
            if nStackNum >= tonumber(szNum) then
                return breturn
            end
        end
    end

    return not breturn
end

--气场BUFF类
function Martin_Macro.CheckQiChangBuff(szRule,szBuffName)

	local player = GetClientPlayer()
	local target = GetTargetHandle(player.GetTarget())
	local dummy
	local bcanceldummy
	local breturn

    if szRule =="qc" then   --自身友方气场
        dummy = player
        bcanceldummy = true
        breturn = true
    elseif szRule == "deqc" then    --自身敌方气场
        dummy = player
        bcanceldummy = false
        breturn = true
    elseif szRule =="noqc" then
        dummy = player
        bcanceldummy = true
        breturn = false
    elseif szRule == "nodeqc" then
        dummy = player
        bcanceldummy = false
        breturn = false
    elseif szRule == "tqc" and target then  --目标友方气场
        dummy = target
        bcanceldummy = true
        breturn = true
    elseif szRule == "tdeqc" and target then    --目标敌方气场
        dummy = target
        bcanceldummy = false
        breturn = true
    elseif szRule == "tnoqc" and target then
        dummy = target
        bcanceldummy = true
        breturn = false
    elseif szRule == "tnodeqc" and target then
        dummy = target
        bcanceldummy = false
        breturn = false
    end

    for i = 1,dummy.GetBuffCount(),1 do
        local dwID, nLevel, bCanCancel, nEndFrame, nIndex, nStackNum, dwSkillSrcID, bValid = dummy.GetBuff(i - 1)
		if Table_GetBuffName(dwID,nLevel) == szBuffName and bCanCancel == bcanceldummy then
			return breturn
		end
    end

	return not breturn

end

function Martin_Macro.CheckBuffType(szRule,szBuffType)

	local player = GetClientPlayer()
	local target = GetTargetHandle(player.GetTarget())
	local dummy
	local bcanceldummy
	local breturn
    
	if szRule =="btype" then
		dummy = player
		bcanceldummy = true --增益 , 可自己取消
		breturn = true
	elseif szRule == "detype" then
		dummy = player
		bcanceldummy = false --减益 , 不可自己取消
		breturn = true
	elseif szRule == "tbtype" and target then
		dummy = target
		bcanceldummy = true
		breturn = true
	elseif szRule == "tdetype" and target then
		dummy = target
		bcanceldummy = false
		breturn = true
	end

    for i = 1,dummy.GetBuffCount(),1 do
        local dwID, nLevel, bCanCancel, nEndFrame, nIndex, nStackNum, dwSkillSrcID, bValid = dummy.GetBuff(i - 1)
        if bCanCancel == bcanceldummy then
            if g_tStrings.tBuffDetachType[GetBuffInfo(dwID,nLevel,{}).nDetachType] ~= nil and g_tStrings.tBuffDetachType[GetBuffInfo(dwID,nLevel,{}).nDetachType] ~= "" then
    			if g_tStrings.tBuffDetachType[GetBuffInfo(dwID,nLevel,{}).nDetachType]:find(szBuffType) then
				    return breturn
			    end           
            end
        end
    end

	return not breturn

end

function Martin_Macro.CheckBuffTime(szRule,szBuffName,szSym,nTime)

	local player = GetClientPlayer()
	local target = GetTargetHandle(player.GetTarget())
    local dummy
    local bMbuff = false

    if szRule == "bufftime" then
        dummy = player
    elseif szRule == "tbufftime" then
        dummy = target
    elseif szRule == "mbufftime" then
        dummy = target
        bMbuff = true
    end

    if bMbuff == false then
        for i = 1,dummy.GetBuffCount(),1 do
            local dwID, nLevel, bCanCancel, nEndFrame, nIndex, nStackNum, dwSkillSrcID, bValid = dummy.GetBuff(i - 1)
            if Table_GetBuffName(dwID, nLevel) == szBuffName then
                local nTimeLeft = tonumber(("%.2f"):format((nEndFrame - GetLogicFrameCount())/16))
                if szSym == ">" then
                    if nTimeLeft > tonumber(nTime) then
                        return true
                    end
                elseif szSym == "<" then
                    if nTimeLeft < tonumber(nTime) then
                        return true
                    end
                elseif szSym == "=" then
                    if nTimeLeft == tonumber(nTime) then
                        return true
                    end
                elseif szSym == "<=" then
                    if nTimeLeft <= tonumber(nTime) then
                        return true
                    end
                elseif szSym == ">=" then
                    if nTimeLeft >= tonumber(nTime) then
                        return true
                    end
                end
            end
        end
    else
        for i = 1,dummy.GetBuffCount(),1 do
            local dwID, nLevel, bCanCancel, nEndFrame, nIndex, nStackNum, dwSkillSrcID, bValid = dummy.GetBuff(i - 1)
            if  dwSkillSrcID == player.dwID then
                if Table_GetBuffName(dwID, nLevel) == szBuffName then
                    local nTimeLeft = tonumber(("%.2f"):format((nEndFrame - GetLogicFrameCount())/16))
                    if szSym == ">" then
                        if nTimeLeft > tonumber(nTime) then
                            return true
                        end
                    elseif szSym == "<" then
                        if nTimeLeft < tonumber(nTime) then
                            return true
                        end
                    elseif szSym == "=" then
                        if nTimeLeft == tonumber(nTime) then
                            return true
                        end
                    elseif szSym == "<=" then
                        if nTimeLeft <= tonumber(nTime) then
                            return true
                        end
                    elseif szSym == ">=" then
                        if nTimeLeft >= tonumber(nTime) then
                            return true
                        end
                    end
                end
            end
        end
    end

	return false

end

--检查是否在马上
function Martin_Macro.CheckHorse(szRule)

	local player = GetClientPlayer()
	local target = GetTargetHandle(player.GetTarget())

	if szRule == "horse" then
		if player.bOnHorse then
			return true
		end
	elseif szRule == "nohorse" then
		if not player.bOnHorse then
			return true
		end
	elseif szRule == "thorse" and target then
		if target.bOnHorse then
			return true
		end
	elseif szRule == "tnohorse" and target then
		if not target.bOnHorse then
			return true
		end
	end

	return false

end

function Martin_Macro.CheckFight(szRule)

	local player = GetClientPlayer()
	local target = GetTargetHandle(player.GetTarget())

	if szRule == "fight" then
		if player.bFightState then
			return true
		end
	elseif szRule == "nofight" then
		if not player.bFightState then
			return true
		end
	elseif szRule == "tfight" and target then
		if target.bFightState then
			return true
		end
	elseif szRule == "tnofight" and target then
		if not target.bFightState then
			return true
		end
	end
	return false

end

--cd类
function Martin_Macro.CheckSkillCD(szRule,szSkillName)

	local player = GetClientPlayer()
	local nSkillID = g_SkillNameToID[szSkillName]
	local bCool,nLeft,nTotal = player.GetSkillCDProgress(nSkillID,player.GetSkillLevel(nSkillID))

	if szRule == "cd" then
		if nLeft > 0 then
			return true
		end
	elseif szRule == "nocd" then
		if nLeft == 0 then
			return true
		end
	end

	return false

end

function Martin_Macro.CheckSkillCDTime(szSkillName,szRule,nTime)

	local player = GetClientPlayer()
	local nSkillID = g_SkillNameToID[szSkillName]
	local bCool,nLeft,nTotal = player.GetSkillCDProgress(nSkillID,player.GetSkillLevel(nSkillID))

    nLeft = nLeft / 16

	if szRule == "<" then
		if nLeft < nTime then
			return true
		end
	elseif szRule == ">" then
		if nLeft > nTime then
			return true
		end
	elseif szRule == "=" then
		if nLeft == nTime then
			return true
		end
	elseif szRule == "<=" then
		if nLeft <= nTime then
			return true
		end
	elseif szRule == ">=" then
		if nLeft >= nTime then
			return true
		end
    end

	return false

end

function Martin_Macro.IsMaxMoon()

    local a= Station.Lookup("Normal/Player")
    local b= a:Lookup("", "Handle_MingJiao")
    local maxmoon= b:Lookup("Animate_MoonValue"):IsVisible()
    
    return maxmoon

end

function Martin_Macro.IsMaxSun()

    local a= Station.Lookup("Normal/Player")
    local b= a:Lookup("", "Handle_MingJiao")
    local maxsun= b:Lookup("Animate_SunValue"):IsVisible() 

    return maxsun

end

--人物数值状态类
function Martin_Macro.CheckCharacterPointValue(szRule,szSym,szValue)

	local player = GetClientPlayer()
	local target = GetTargetHandle(player.GetTarget())
    
	local dummycurrent
	local dummymax

	if szRule == "life" then
		dummycurrent = player.nCurrentLife
		dummymax = player.nMaxLife
	elseif szRule == "tlife" and target then
		dummycurrent = target.nCurrentLife
		dummymax = target.nMaxLife
	elseif szRule == "mana" then
		dummycurrent = player.nCurrentMana
		dummymax = player.nMaxMana
	elseif szRule == "tmana" and target then
		dummycurrent = target.nCurrentMana
		dummymax = target.nMaxMana
	elseif szRule == "power" then
		dummycurrent = player.nAccumulateValue
		if player.dwForceID == 1 then --少林
			dummymax = 3
		elseif player.dwForceID == 4 then --纯阳
			dummymax = 10
		end
	elseif szRule == "rage" then
		dummycurrent = player.nCurrentRage
		dummymax = player.nMaxRage
	elseif szRule == "dance" then
        dummycurrent = Martin_Macro.BuffChackById(player, 409) -- 剑舞
		dummymax = 10
	elseif szRule == "energy" then
		dummycurrent = player.nCurrentEnergy
		dummymax = player.nMaxEnergy
	elseif szRule == "sun" then
		dummycurrent = player.nCurrentSunEnergy / 100
		dummymax = player.nMaxSunEnergy / 100
        if Martin_Macro.IsMaxSun() then
            dummycurrent = 100
        end 
	elseif szRule == "moon" then
		dummycurrent = player.nCurrentMoonEnergy / 100
		dummymax = player.nMaxMoonEnergy / 100
        if Martin_Macro.IsMaxMoon() then
            dummycurrent = 100
        end
	elseif szRule == "flypower" then
		dummycurrent = player.nSprintPower
		dummymax = player.nSprintPowerMax
	end

	local dummy = dummycurrent/dummymax 

	if szValue == "1.0" then
		dummy = tonumber(("%.2f"):format(dummy))
	elseif tonumber(szValue) >= 1 then
		dummy = dummycurrent
	else
		dummy = tonumber(("%.2f"):format(dummy))
	end

	local nValue = tonumber(szValue)

	if szSym == ">" then
		if dummy > nValue then
			return true
		end
	elseif szSym == "<" then
		if dummy < nValue then
			return true
		end
	elseif szSym == "=" then
		if dummy == nValue then
			return true
		end
	elseif szSym == "<=" then
		if dummy <= nValue then
			return true
		end
	elseif szSym == ">=" then
		if dummy >= nValue then
			return true
		end
	end

	return false

end

function Martin_Macro.CheckName(szRule,szValue)
	local player = GetClientPlayer()
	local target = GetTargetHandle(player.GetTarget())
	local ttarget = GetTargetHandle(target.GetTarget())
    
    local szName = ""

    if szValue == "$myname" then
        szName = player.szName    
    else
        szName = szValue
    end
    
    if szRule == "tname" then
        if target.szName == szName then
            return true
        end
    
    elseif szRule == "tnoname" then
        if target.szName ~= szName then
            return true
        end

    elseif szRule == "ttname" then
        if ttarget then
            if ttarget.szName == szName then
                return true
            end
        end

    elseif szRule == "ttnoname" then
        if ttarget then
            if ttarget.szName ~= szName then
                return true
            end
        end
    end
    
    return false
end

function Martin_Macro.CheckDeath(szRule)

	local player = GetClientPlayer()
	local target = GetTargetHandle(player.GetTarget())

	if szRule == "dead" and target then
		if target.nMoveState == MOVE_STATE.ON_DEATH then
			return true
		end
	elseif szRule == "nodead" and target then
		if target.nMoveState ~= MOVE_STATE.ON_DEATH then
			return true
		end
    end

	return false
end

function Martin_Macro.CheckAlliance(szRUle)

	local player = GetClientPlayer()
	local target = GetTargetHandle(player.GetTarget())

	if szRule == "ally" and target then
		if IsAlly(player.dwID,target.dwID) then
			return true
		end
	elseif szRule == "enemy" and target then
		if IsEnemy(player.dwID,target.dwID) then
			return true
		end
	elseif szRule == "neutral" and target then
		if IsNeutrality(player.dwID,target.dwID) then
			return true
		end
	end

	return false

end

--人物普通状态类
function Martin_Macro.CheckStatus(szRule,szStatus)

	local player = GetClientPlayer()
	local target = GetTargetHandle(player.GetTarget())
	local dummy
	local bcheckstate

	if szRule == "status" then
		dummy = player
		bcheckstate = true
	elseif szRule == "nostatus" then
		dummy = player
		bcheckstate = false
	elseif szRule == "tstatus" and target then
		dummy = target
		bcheckstate = true
	elseif szRule == "tnostatus" and target then
		dummy = target
		bcheckstate = false
	end

    if szStatus == "被僵直" then
        szStatus = "被击位移状态"
    elseif szStatus == "使僵直" then
        szStatus = "攻击位移状态"
    end

    --[MOVE_STATE.ON_FREEZE]			= "定身",
    --[MOVE_STATE.ON_ENTRAP]			= "定身",锁足
 
	if bcheckstate then
        if szStatus == "锁足" then
            if dummy.nMoveState == MOVE_STATE.ON_ENTRAP then
                return true
            end
        elseif szStatus == "定身" then
            if dummy.nMoveState == MOVE_STATE.ON_FREEZE then
                return true
            end
        elseif szStatus == g_tStrings.tPlayerMoveState[dummy.nMoveState] then
			return true
        end
	else
        if szStatus == "锁足" then
            if dummy.nMoveState ~= MOVE_STATE.ON_ENTRAP then
                return true
            end
        elseif szStatus == "定身" then
            if dummy.nMoveState ~= MOVE_STATE.ON_FREEZE then
                return true
            end
        elseif szStatus ~= g_tStrings.tPlayerMoveState[dummy.nMoveState] then
			return true
		end
	end

	return false

end

function Martin_Macro.CheckForce(szRule,szForceName)

	local player = GetClientPlayer()
	local ttype, tid = player.GetTarget()
	local target = GetTargetHandle(player.GetTarget())

    if ttype == TARGET.NPC then
        return true
    end

	if szRule == "tforce" and target and ttype == TARGET.PLAYER then
		if g_tStrings.tForceTitle[target.dwForceID] == szForceName then
			return true
		end
	elseif szRule == "tnoforce" and target and ttype == TARGET.PLAYER then
		if g_tStrings.tForceTitle[target.dwForceID] ~= szForceName then
			return true
		end
	end

	return false

end

function Martin_Macro.CheckKungfuMount(szRule,szKungfuName)

	local player = GetClientPlayer()
    local ttype, tid = player.GetTarget()
	local target = GetTargetHandle(player.GetTarget())

	if szRule == "mount" then
		if player.GetKungfuMount().szSkillName == szKungfuName then
			return true
		end
	elseif szRule == "nomount" then
		if player.GetKungfuMount().szSkillName ~= szKungfuName then
			return true
		end
	else
        if ttype == TARGET.NPC then
            return true
        end

        if szRule == "tmount" and target and ttype == TARGET.PLAYER  and target then
            if target.GetKungfuMount().szSkillName == szKungfuName then
                return true
            end
        elseif szRule == "tnomount" and target and ttype == TARGET.PLAYER  and target then
            if target.GetKungfuMount().szSkillName ~= szKungfuName then
                return true
            end
        end
    end

	return false

end

function Martin_Macro.CheckState(szRule, sParam)

    if szRule == "state" then
        if sParam == "无减伤" then
            local szOption = "nobuff:无相诀|转乾坤|天地低昂|贪魔体|蝶戏水|雾体"
            return Martin_Macro.CalculateMacroConditionResult(szOption)
        elseif sParam == "无免伤" then
            local szOption = "nobuff:守如山|镇山河|鬼斧神工|笑醉狂|御|御天|太虚|回神"
            return Martin_Macro.CalculateMacroConditionResult(szOption)
        elseif sParam == "被控制" then
            local szOption = "status:被击倒|被击退|被击飞|眩晕|定身|僵直|锁足"
            return Martin_Macro.CalculateMacroConditionResult(szOption)
        elseif sParam == "可控制" then
            local szOption = "nobuff:星楼月影|折骨|素衿|力拔|纵轻骑|转乾坤|生死之交|不工|玉泉鱼跃|梦泉虎跑|蛊虫狂暴|风蜈献祭|碧蝶献祭|圣体|灵辉|超然|出渊|飞将|零落|迷心蛊|菩提身|青阳|笑醉狂|烟雨行|龙跃于渊|流火飞星|霸体|啸日|镇山河|贪魔体|绝伦逸群|御天,noqc:生太极,nostatus:冲刺"
            return Martin_Macro.CalculateMacroConditionResult(szOption)
        elseif sParam == "非被控" then
            local szOption = "nostatus:被击倒|被击退|被击飞|眩晕|定身|僵直|锁足"
            return Martin_Macro.CalculateMacroConditionResult(szOption)
        end

    elseif szRule == "tstate" then
        if sParam == "可控制" then
            local szOption = "tnobuff:星楼月影|折骨|素衿|力拔|纵轻骑|转乾坤|生死之交|不工|玉泉鱼跃|梦泉虎跑|蛊虫狂暴|风蜈献祭|碧蝶献祭|圣体|灵辉|超然|出渊|飞将|零落|迷心蛊|菩提身|青阳|笑醉狂|烟雨行|龙跃于渊|流火飞星|霸体|啸日|镇山河|贪魔体|绝伦逸群|御天,tnoqc:生太极,tnostatus:冲刺"
            return Martin_Macro.CalculateMacroConditionResult(szOption)
        elseif sParam == "非被控" then
            local szOption = "tnostatus:被击倒|被击退|被击飞|眩晕|定身|僵直|锁足"
            return Martin_Macro.CalculateMacroConditionResult(szOption)
        elseif sParam == "无免伤" then
            local szOption = "tnobuff:守如山|镇山河|鬼斧神工|笑醉狂|御|御天|太虚|回神"
            return Martin_Macro.CalculateMacroConditionResult(szOption)
        elseif sParam == "被控制" then
            local szOption = "tstatus:被击倒|被击退|被击飞|眩晕|定身|僵直|锁足"
            return Martin_Macro.CalculateMacroConditionResult(szOption)
        elseif sParam == "无减伤" then
            local szOption = "tnobuff:无相诀|转乾坤|天地低昂|贪魔体|蝶戏水|雾体"
            return Martin_Macro.CalculateMacroConditionResult(szOption)
        end
    end

end

--是否可以释放XX技能
function Martin_Macro.CanUse(sParam)

	local szSkillId = Martin_Macro.GetSkillID(sParam)
	local szSkillLevel = GetClientPlayer().GetSkillLevel(szSkillId)

	local me, box = GetClientPlayer(), Martin_Macro.hBox
	if me and box then
		if szSkillLevel > 0 then
			box:EnableObject(false)
			box:SetObjectCoolDown(1)
			box:SetObject(UI_OBJECT_SKILL, szSkillId, szSkillLevel)
			UpdataSkillCDProgress(me, box)
			return box:IsObjectEnable() and not box:IsObjectCoolDown()
		end
	end
	return false

end

--目标是否在引导技能
function Martin_Macro.CheckChannal()
	local player = GetClientPlayer()
    local ttype, tid = player.GetTarget()
	local target = GetTargetHandle(player.GetTarget())
	
	if ttype == TARGET.NPC then
		return false
	end

    if target then
        if target.GetOTActionState() == 2 then
            return true --返回true条件成立
        end 
    end

    return false

end

--10尺内是否有自己的xx气场
function Martin_Macro.CheckQiChang(szRule,szValue)

    local Player = GetClientPlayer()
    szValue = "气场"..szValue
    local breturn

    if szRule == "sura" then
        breturn = true
    elseif szRule == "nosura" then
        breturn = false
    end

    for i,v in pairs(GetNearbyNpcList()) do
        local hNpc = GetNpc(v)
        if hNpc then
            local nDist = math.floor(((Player.nX - hNpc.nX) ^ 2 + (Player.nY - hNpc.nY) ^ 2 + (Player.nZ/8 - hNpc.nZ/8) ^ 2) ^ 0.5)/64
            if nDist < 10 then
                if hNpc.szName == szValue then
                    if hNpc.dwEmployer == Player.dwID then
                        return breturn
                    end
                end                          
            end
        end
    end

    return not breturn

end

function Martin_Macro.CheckMacroCondition(szRule, szKeyName)

    if szKeyName ~= "" then
        if szKeyName:find("distance") ~= nil or szKeyName:find("Distance") ~= nil then
            local szCurrentWord = ""
            local tStackDataTable = {"", ""}
            for i = 1, #szKeyName do
                local ch = szKeyName:sub(i, i)
                if ch == ">" or ch == "=" or ch == "<" then
                    tStackDataTable[1] = tStackDataTable[1] .. ch
                    szCurrentWord = ""
                else
                    szCurrentWord = szCurrentWord .. ch
                    if #szKeyName == i then		-- 最后一个字符, 这里要最后计算一次
                        tStackDataTable[2] = szCurrentWord
                    end
                end  
            end
            return Martin_Macro.MyGetDistance(tStackDataTable[1], tStackDataTable[2])

        elseif szKeyName:find("height") ~= nil then
            local szCurrentWord = ""
            local tStackDataTable = {"", ""}
            for i = 1, #szKeyName do
                local ch = szKeyName:sub(i, i)
                if ch == ">" or ch == "=" or ch == "<" then
                    tStackDataTable[1] = tStackDataTable[1] .. ch
                    szCurrentWord = ""
                else
                    szCurrentWord = szCurrentWord .. ch
                    if #szKeyName == i then		-- 最后一个字符, 这里要最后计算一次
                        tStackDataTable[2] = szCurrentWord
                    end
                end
            end
            return Martin_Macro.CheckHeight(tStackDataTable[1], tStackDataTable[2])


        elseif szKeyName:find("life") ~= nil or szKeyName:find("mana") ~= nil or szKeyName:find("power") ~= nil or szKeyName:find("rage") ~= nil or szKeyName:find("dance") ~= nil or szKeyName:find("energy") ~= nil or szKeyName:find("sun") ~= nil or szKeyName:find("moon") ~= nil or szKeyName:find("flypower") ~= nil then
            local szCurrentWord = ""
            local tStackDataTable = {"", "", ""}
            for i = 1, #szKeyName do
                local ch = szKeyName:sub(i, i)
                if ch == ">" or ch == "=" or ch == "<" then
                    tStackDataTable[1] = tStackDataTable[1] .. szCurrentWord
                    tStackDataTable[2] = tStackDataTable[2] .. ch
                    szCurrentWord = ""
                else
                    szCurrentWord = szCurrentWord .. ch
                    if #szKeyName == i then		-- 最后一个字符, 这里要最后计算一次
                        tStackDataTable[3] = szCurrentWord
                    end
                end
            end
            return Martin_Macro.CheckCharacterPointValue(tStackDataTable[1], tStackDataTable[2], tStackDataTable[3])

        elseif szKeyName:find("face") ~= nil then
            local szCurrentWord = ""
            local tStackDataTable = {"", "", ""}
            for i = 1, #szKeyName do
                local ch = szKeyName:sub(i, i)
                if ch == ">" or ch == "=" or ch == "<" then
                    tStackDataTable[1] = tStackDataTable[1] .. szCurrentWord
                    tStackDataTable[2] = tStackDataTable[2] .. ch
                    szCurrentWord = ""
                else
                    szCurrentWord = szCurrentWord .. ch
                    if #szKeyName == i then		-- 最后一个字符, 这里要最后计算一次
                        tStackDataTable[3] = szCurrentWord
                    end
                end  
            end
            return Martin_Macro.CheckFace(tStackDataTable[1], tStackDataTable[2], tStackDataTable[3])

        elseif szRule:find("bufftime") ~= nil then      
            local szCurrentWord = ""
            local tStackDataTable = {szRule, "", "", ""}
            for i = 1, #szKeyName do
                local ch = szKeyName:sub(i, i)
                if ch == ">" or ch == "=" or ch == "<" then
                    tStackDataTable[2] = tStackDataTable[2] .. szCurrentWord
                    tStackDataTable[3] = tStackDataTable[3] .. ch
                    szCurrentWord = ""
                else
                    szCurrentWord = szCurrentWord .. ch
                    if #szKeyName == i then		-- 最后一个字符, 这里要最后计算一次
                        tStackDataTable[4] = szCurrentWord
                    end
                end  
            end
            return Martin_Macro.CheckBuffTime(tStackDataTable[1], tStackDataTable[2], tStackDataTable[3], tStackDataTable[4])

        elseif szRule:find("enemynum") ~= nil then      
            local szCurrentWord = ""
            local tStackDataTable = {"", "", ""}
            for i = 1, #szKeyName do
                local ch = szKeyName:sub(i, i)
                if ch == ">" or ch == "=" or ch == "<" then
                    tStackDataTable[1] = tStackDataTable[1] .. szCurrentWord
                    tStackDataTable[2] = tStackDataTable[2] .. ch
                    szCurrentWord = ""
                else
                    szCurrentWord = szCurrentWord .. ch
                    if #szKeyName == i then		-- 最后一个字符, 这里要最后计算一次
                        tStackDataTable[3] = szCurrentWord
                    end
                end  
            end
            return Martin_Macro.GetEnemyNum(tStackDataTable[1], tStackDataTable[2], tStackDataTable[3])


        elseif szRule:find("buff") ~= nil then      
            local szCurrentWord = ""
            local tStackDataTable = {szRule, "", "", ""}
            for i = 1, #szKeyName do
                local ch = szKeyName:sub(i, i)
                if ch == ">" or ch == "=" or ch == "<" then
                    tStackDataTable[2] = tStackDataTable[2] .. szCurrentWord
                    tStackDataTable[3] = tStackDataTable[3] .. ch
                    szCurrentWord = ""
                else
                    szCurrentWord = szCurrentWord .. ch
                    if #szKeyName == i then		-- 最后一个字符, 这里要最后计算一次
                        tStackDataTable[4] = szCurrentWord
                    end
                end  
            end
            
            if tStackDataTable[2] == "" then
                return Martin_Macro.CheckBuff(tStackDataTable[1], tStackDataTable[4], tStackDataTable[2], tStackDataTable[3])
            else
                return Martin_Macro.CheckBuff(tStackDataTable[1], tStackDataTable[2], tStackDataTable[3], tStackDataTable[4])
            end

        elseif szRule:find("name") ~= nil then
                return Martin_Macro.CheckName(szRule,szKeyName)

        elseif szRule:find("qc") ~= nil then
                return Martin_Macro.CheckQiChangBuff(szRule,szKeyName)

        elseif szRule:find("sura") ~= nil then
                return Martin_Macro.CheckQiChang(szRule,szKeyName)

        elseif szRule:find("status") ~= nil then
                return Martin_Macro.CheckStatus(szRule,szKeyName)

        elseif szKeyName:find("ally") ~= nil or szRule:find("enemy") ~= nil or szRule:find("neutral") ~= nil then
                return Martin_Macro.CheckAlliance(szKeyName)

        elseif szKeyName:find("horse") ~= nil then
                return Martin_Macro.CheckHorse(szKeyName)

        elseif szKeyName:find("fight") ~= nil then
                return Martin_Macro.CheckFight(szKeyName)

        elseif szKeyName:find("dead") ~= nil then
                return Martin_Macro.CheckDeath(szKeyName)

        elseif szKeyName:find("tchannal") ~= nil or szKeyName:find("tChannal") ~= nil then
                return Martin_Macro.CheckChannal()

        elseif szRule:find("prepare") ~= nil or szKeyName:find("prepare") ~= nil then
                return Martin_Macro.CheckSkillPrepare(szRule,szKeyName)

        elseif szRule:find("broken") ~= nil or szKeyName:find("broken") ~= nil then
                return Martin_Macro.CheckBroken(szRule,szKeyName)

        elseif szRule:find("pet") ~= nil or szKeyName:find("pet") ~= nil then
                return Martin_Macro.CheckPet(szRule,szKeyName)

        elseif szRule:find("cast") ~= nil then
                return Martin_Macro.CheckCast(szRule,szKeyName)

        elseif szRule:find("canuse") ~= nil then
                return Martin_Macro.CanUse(szKeyName)

        --elseif szRule:find("haveskill") ~= nil or szRule:find("noskill") ~= nil then
                --return Martin_Macro.CheckHaveSkill(szRule,szKeyName)

        elseif szRule:find("type") ~= nil then
                return Martin_Macro.CheckBuffType(szRule,szKeyName)

        elseif szRule:find("state") ~= nil then
                return Martin_Macro.CheckState(szRule,szKeyName)

        elseif szRule:find("cdtime") ~= nil then
                local szCurrentWord = ""
                local tStackDataTable = {"", "", 0}
                for i = 1, #szKeyName do
                    local ch = szKeyName:sub(i, i)
                    if ch == ">" or ch == "=" or ch == "<" then
                        tStackDataTable[1] = tStackDataTable[1] .. szCurrentWord
                        tStackDataTable[2] = tStackDataTable[2] .. ch
                        szCurrentWord = ""
                    else
                        szCurrentWord = szCurrentWord .. ch
                        if #szKeyName == i then		-- 最后一个字符, 这里要最后计算一次
                            tStackDataTable[3] = tonumber(szCurrentWord)
                        end
                    end
                end
                return Martin_Macro.CheckSkillCDTime(tStackDataTable[1], tStackDataTable[2], tStackDataTable[3])

        elseif szRule:find("cd") ~= nil or szRule:find("Cd") or szRule:find("CD") or szRule:find("cD") then
                return Martin_Macro.CheckSkillCD(szRule,szKeyName)

        elseif szRule:find("mount") ~= nil then
                return Martin_Macro.CheckKungfuMount(szRule,szKeyName)

        elseif szRule:find("force") ~= nil then
                return Martin_Macro.CheckForce(szRule,szKeyName)

        end
    end

	return true

end

function Martin_Macro.CalculateMacroConditionResult(szMsg)
	
	if szMsg == nil then
		return false
	end

	local szCurrentWord = ""

	local nCurrentStackLevel = 1;						    -- 处理过程中的当前栈级
	local tStackDataTable = {[1] = {true, "+", ""}}			-- 用来保存不同栈级下的临时结果, 每个栈级有两个值, 分别是 {当前值, 下一次计算符号}

	local CalculateStackResult = function(bResult)
		if tStackDataTable[nCurrentStackLevel][2] == "+" then
			tStackDataTable[nCurrentStackLevel][1] = tStackDataTable[nCurrentStackLevel][1] and bResult
		elseif tStackDataTable[nCurrentStackLevel][2] == "|" then
			tStackDataTable[nCurrentStackLevel][1] = tStackDataTable[nCurrentStackLevel][1] or bResult
        else
            tStackDataTable[nCurrentStackLevel][1] = bResult
		end
		tStackDataTable[nCurrentStackLevel][2] = ""
		szCurrentWord = ""
		return tStackDataTable[nCurrentStackLevel][1]
	end

	for i = 1, #szMsg do
		local ch = szMsg:sub(i, i)
		local szRule = tStackDataTable[nCurrentStackLevel][3]
		---- 得到一个新的栈级, 则初始化这个栈级的默认内容
		if ch == "(" then
			nCurrentStackLevel = nCurrentStackLevel + 1
			tStackDataTable[nCurrentStackLevel] = {true, "+", ""}
			szCurrentWord = ""

		-- 栈级下降, 则在下降后计算结果, 并且计算原有栈级上的结果
		elseif ch == ")" then
			local bResult = CalculateStackResult(Martin_Macro.CheckMacroCondition(szRule, szCurrentWord))
			nCurrentStackLevel = nCurrentStackLevel - 1
			CalculateStackResult(bResult)

		-- 获得一个新的 Rule, 之后的计算都依靠这个Rule为依据
		elseif ch == ":" then
			szRule = szCurrentWord
            tStackDataTable[nCurrentStackLevel][3] = szRule
			szCurrentWord = ""

		-- 遇到一个 And 标记,计算之前的结果, 并且把符号记录到栈数据中
		elseif ch == "+" then
			CalculateStackResult(Martin_Macro.CheckMacroCondition(szRule, szCurrentWord))
			tStackDataTable[nCurrentStackLevel][2] = "+"

		-- 遇到一个 Or 标记,计算之前的结果, 并且把符号记录到栈数据中
		elseif ch == "|" then
			CalculateStackResult(Martin_Macro.CheckMacroCondition(szRule, szCurrentWord))
			tStackDataTable[nCurrentStackLevel][2] = "|"
            if tStackDataTable[nCurrentStackLevel][3]:find("no") then
                tStackDataTable[nCurrentStackLevel][2] = "+"
            end
            
        -- 遇到一个 , 标记,计算之前的结果, 为假则直接返回
		elseif ch == "," or ch == "，" then
            CalculateStackResult(Martin_Macro.CheckMacroCondition(szRule, szCurrentWord))
            szRule = szCurrentWord
            --tStackDataTable[nCurrentStackLevel][2] = "+"
            tStackDataTable[nCurrentStackLevel][3] = szRule
			if tStackDataTable[nCurrentStackLevel][1] == false then
                return tStackDataTable[nCurrentStackLevel][1]
            end

        -- 遇到一个 ; 标记,计算之前的结果
		elseif ch == ";" or ch == "；" then
            CalculateStackResult(Martin_Macro.CheckMacroCondition(szRule, szCurrentWord))
            szRule = szCurrentWord
            tStackDataTable[nCurrentStackLevel][2] = "|"
            tStackDataTable[nCurrentStackLevel][3] = szRule

		-- 正常情况下组织当前词, 如果发现到底了那就还要最后计算一次
		else
			szCurrentWord = szCurrentWord .. ch
			if #szMsg == i then		-- 最后一个字符, 这里要最后计算一次
				CalculateStackResult(Martin_Macro.CheckMacroCondition(szRule, szCurrentWord))
			end
		end
	end

	if nCurrentStackLevel ~= 1 then
		--Output("栈级出错!")
		return false
	end
    
	return tStackDataTable[1][1]

end

--把指定的宏指令转换成Lua指令
function Martin_Macro.Str_To_Lua(strCodes)

    local szRule, szCondition, szSkillName, szAddonCondition = "", "", "", ""

    szRule = strCodes:gsub("%b[]",""):gsub("%s*",""):gsub("%/",""):gsub("%A+","")

    for k in strCodes:gmatch("%b[]") do
        if k:find("self") then
            szAddonCondition = k:sub(2,-2)
        else
           szCondition = k:sub(2,-2)
        end
	end

    szSkillName  = strCodes:gsub("%b[]",""):gsub("%s*",""):gsub("%/",""):gsub("%a+","")

    --
    return szRule, szCondition, szSkillName, szAddonCondition

end

--Martin_Macro.hfile = assert(io.open("C:\\Windows\\testRead.txt", 'r'))

--function Martin_Macro.SetFile()
    --Martin_Macro.hfile:seek("set")
--end

function Martin_Macro.SetWork()
	collectgarbage("collect")
end

function Martin_Macro.Follow()
    local player = GetClientPlayer()
    local target = GetTargetHandle(player.GetTarget())
    if target then
        local x,y,z = Scene_GameWorldPositionToScenePosition(target.nX,target.nY,target.nZ,false)
        AutoMoveToPoint(x,y,z)
    end
end

--释放可无目标技能
function Martin_Macro.SkillSelf(nSkillID, nSkillLv)

	local player = GetClientPlayer()
	local ttp,tid = player.GetTarget()

	if tid ~= 0 then
		SetTarget(TARGET.PLAYER, player.dwID)
	end

	OnUseSkill(nSkillID,nSkillLv)

	if tid ~= 0 then
		SetTarget(ttp, tid)
	end

end


--宏语句解析
local aCommand = {}

--注册宏命令 如 cast
local function AppendCommand(key, fn)
	key = StringLowerW(key)
	aCommand["/"..key] = fn
end

--找#开头的注释
local function GetPureMacro(szMacro)

	local szPureMacro = ""

	szMacro = "\n"..szMacro
	local i, j = StringFindW(szMacro, "\n#")
	while i do
		szPureMacro = szPureMacro..string.sub(szMacro, 1, i - 1)
		szMacro = string.sub(szMacro, j, -1)
		i, j = StringFindW(szMacro, "\n#")
		local i1, j1 = StringFindW(szMacro, "\n/")
		if not i or (i1 and i > i1) then
			i, j = i1, j1
		end
		if i then
			szMacro = string.sub(szMacro, i, -1)
		else
			szMacro = ""
		end
		i, j = StringFindW(szMacro, "\n#")
	end
	szPureMacro = szPureMacro..szMacro
	
	return szPureMacro

end

--取宏命令
local function GetCommand(szMacro)

	local szCmd, szLeft
	local i, j = StringFindW(szMacro, "\n/")
	if i then
		szCmd = string.sub(szMacro, 1, i - 1)
		szLeft = string.sub(szMacro, j, - 1)
	else
		szCmd, szLeft = szMacro, ""
	end
	while string.sub(szCmd, -1, -1) == "\n" do
		szCmd = string.sub(szCmd, 1, -2)
	end
	return szCmd, szLeft

end

--取[]内的判断语句, 和技能名称
local function GetCondition(szContent)
    --Output(szContent)
	local szSkill, szCondition, szAddonCondition = "", "", ""
	--local nEnd = StringFindW(szContent, "[")
	--if nEnd then
		--szContent = string.sub(szContent, nEnd + 1, -1)
		--nEnd = StringFindW(szContent, "]")
		--if nEnd then
			--szSkill = string.sub(szContent, nEnd + 1, -1)
			--szCondition = string.sub(szContent, 1, nEnd - 1)
		--end
	--else
		--szSkill = szContent
	--end
    for k in szContent:gmatch("%b[]") do
        if k:find("self") then
            szAddonCondition = k:sub(2,-2)
        else
           szCondition = k:sub(2,-2)
        end
	end

    szSkill  = szContent:gsub("%b[]",""):gsub("%s*",""):gsub("%/",""):gsub("%a+","")

	return szCondition, szSkill, szAddonCondition

end

--判断条件, 释放技能
local function Cast(szContent)

	local szCondition, szSkill, szAddonCondition = GetCondition(szContent)  --解析判断条件, 技能名称

	if Martin_Macro.CalculateMacroConditionResult(szCondition) then
		while string.sub(szSkill, 1, 1) == " " do
			szSkill = string.sub(szSkill, 2, -1)
		end

		while string.sub(szSkill, -1, -1) == " " do
			szSkill = string.sub(szSkill, 1, -2)
		end	

        if szSkill == "轻功躲避" then
            if Martin_Macro.CheckSkillCD("nocd","凌霄揽胜") then
                local nSkillID, nSkillLv = Martin_Macro.GetSkillID("凌霄揽胜")
                OnUseSkill(nSkillID, nSkillLv)
            elseif Martin_Macro.CheckSkillCD("nocd","瑶台枕鹤") then
                local nSkillID, nSkillLv = Martin_Macro.GetSkillID("瑶台枕鹤")
                OnUseSkill(nSkillID, nSkillLv)
            elseif Martin_Macro.CheckSkillCD("nocd","迎风回浪") then
                local nSkillID, nSkillLv = Martin_Macro.GetSkillID("迎风回浪")
                OnUseSkill(nSkillID, nSkillLv)
            else
                OnUseSkill(9007,1) --后撤
            end 
        elseif szSkill == "跳" then
            Camera_EnableControl(CONTROL_JUMP, true)
        elseif szSkill == "走向目标" then
            Martin_Macro.Follow()
        elseif szSkill == "跟随目标" then
            local player = GetClientPlayer()
            local dwType, dwID = player.GetTarget()
            if dwID then
                StartFollow(dwType, dwID)
            end
        else
            local nSkillID, nSkillLv = Martin_Macro.GetSkillID(szSkill)
            if nSkillID ~= 2603 then
                if szAddonCondition == "self" then
                    Martin_Macro.SkillSelf(nSkillID, nSkillLv)
                else
                    --醉舞九天  凝神聚气 风来吴山  暴雨梨花针  玳弦急曲   笑醉狂   回血飘摇
                    if szSkill == "醉舞九天" or szSkill == "凝神聚气" or szSkill == "风来吴山" or szSkill == "暴雨梨花针" or szSkill == "玳弦急曲" or szSkill == "笑醉狂" or szSkill == "回血飘摇" then
                        if Martin_Macro.CheckSkillCD("nocd",szSkill) then
                            OnUseSkill(nSkillID, nSkillLv)
                            return false
                        end
                    end
                    OnUseSkill(nSkillID, nSkillLv)
                end
            end
        end
	end
end

--前置判断
local function Before(szContent)
    local szCondition, szSkill, szAddonCondition = GetCondition(szContent)  --解析判断条件, 技能名称
	if Martin_Macro.CalculateMacroConditionResult(szCondition) then
        return true
    end
    return false
end

local function End(szContent)
    local szCondition, szSkill, szAddonCondition = GetCondition(szContent)  --解析判断条件, 技能名称
	if Martin_Macro.CalculateMacroConditionResult(szCondition) then
        return false
    end
    return true
end

--模块化设计 goto flag
local function Goto(szContent, szLeftMacro)

    local szCondition, szFlag, szAddonCondition = GetCondition(szContent)  --解析判断条件, 技能名称
    
    while string.sub(szFlag, 1, 1) == " " do
        szFlag = string.sub(szFlag, 2, -1)
    end

    while string.sub(szFlag, -1, -1) == " " do
        szFlag = string.sub(szFlag, 1, -2)
    end	

	if Martin_Macro.CalculateMacroConditionResult(szCondition) then
        --从剩下的语句中找到对应的flag, 并返回
        local szCmd, szLeft = "" , szLeftMacro
        while true do
            szCmd, szLeft = GetCommand(szLeft)  --取宏命令
            if szCmd == "" then
                if szLeft == "" then
                    break
                end
            else
                local szKey, szParam
                local i = StringFindW(szCmd, " ")
                if i then
                    szKey = string.sub(szCmd, 1, i - 1)
                    szParam = string.sub(szCmd, i + 1, -1)
                else
                    szKey, szParam = szCmd, ""
                end
                szKey = StringLowerW(szKey)
                if szKey == "/flag" and szParam == szFlag then
                    return szLeft
                end
            end
        end
    end
end

--执行判断
local function ProcessCommand(szCmd, szLeft)

	local szKey, szParam
	local i = StringFindW(szCmd, " ")
	if i then
		szKey = string.sub(szCmd, 1, i - 1)
		szParam = string.sub(szCmd, i + 1, -1)
	else
		szKey, szParam = szCmd, ""
	end
	szKey = StringLowerW(szKey)

    if szKey == "/flag" then
        return false
    end

	if szKey and aCommand[szKey] then
		local r = aCommand[szKey](szParam, szLeft)
		if r == nil then
			r = true
		end
		return r
	end

	return false

end

AppendCommand("cast", Cast)
AppendCommand("end", End)
AppendCommand("before", Before)
AppendCommand("goto", Goto)

--开始
function Martin_Macro.Run()

    collectgarbage("collect")

    szMacro = GetPureMacro(Martin_Macro.StrCodes) --去除#注释部分宏语句
    local r
    local szCmd, szLeft = "" , szMacro

    while true do
        if GetClientPlayer().GetOTActionState() == 2 then
            break
        end

        szCmd, szLeft = GetCommand(szLeft)  --取宏命令
        if szCmd == "" then
            if szLeft == "" then
                break
            end
        else
            r = ProcessCommand(szCmd, szLeft)   --执行宏语句
            if r == false then
                break
            elseif r ~= nil and r ~= true then
                szLeft = r
            end
        end
    end

    --local Run = coroutine.create(function()
            --Martin_Macro.bEndCode = nil
            --Martin_Macro.bBeginCode = ""

            --for szMsg in Martin_Macro.StrCodes:gmatch("[^/]+") do

                --if GetClientPlayer().GetOTActionState() == 2 then
                    --return
                --end

                --local szRule, szCondition, szSkillName, szAddonCondition = Martin_Macro.Str_To_Lua(szMsg)

                --if szRule == "cast" then
                     --if Martin_Macro.CalculateMacroConditionResult(szCondition) and Martin_Macro.CalculateMacroConditionResult(Martin_Macro.bBeginCode) and not Martin_Macro.CalculateMacroConditionResult(Martin_Macro.bEndCode) then
                        --if szSkillName == "轻功躲避" then
                            --if Martin_Macro.CheckSkillCD("nocd","凌霄揽胜") then
                                --local nSkillID, nSkillLv = Martin_Macro.GetSkillID("凌霄揽胜")
                                --OnUseSkill(nSkillID, nSkillLv)
                            --elseif Martin_Macro.CheckSkillCD("nocd","瑶台枕鹤") then
                                --local nSkillID, nSkillLv = Martin_Macro.GetSkillID("瑶台枕鹤")
                                --OnUseSkill(nSkillID, nSkillLv)
                            --elseif Martin_Macro.CheckSkillCD("nocd","迎风回浪") then
                                --local nSkillID, nSkillLv = Martin_Macro.GetSkillID("迎风回浪")
                                --OnUseSkill(nSkillID, nSkillLv)
                            --else
                                --OnUseSkill(9007,1) --后撤
                            --end 
                        --elseif szSkillName == "跳" then
                            --Camera_EnableControl(CONTROL_JUMP, true)
                        --elseif szSkillName == "跟随目标" then
                            --Martin_Macro.Follow()
                        --else
                            --local nSkillID, nSkillLv = Martin_Macro.GetSkillID(szSkillName)
                            --if nSkillID ~= 2603 then
                                --if szAddonCondition == "self" then
                                    --Martin_Macro.SkillSelf(nSkillID, nSkillLv)
                                --else
                                    ----醉舞九天  凝神聚气 风来吴山  暴雨梨花针  玳弦急曲   笑醉狂   回血飘摇
                                    --if szSkillName == "醉舞九天" or szSkillName == "凝神聚气" or szSkillName == "风来吴山" or szSkillName == "暴雨梨花针" or szSkillName == "玳弦急曲" or szSkillName == "笑醉狂" or szSkillName == "回血飘摇" then
                                        --if Martin_Macro.CheckSkillCD("nocd",szSkillName) then
                                            --OnUseSkill(nSkillID, nSkillLv)
                                            --return
                                        --end
                                    --end
                                    --OnUseSkill(nSkillID, nSkillLv)
                                --end
                            --end
                        --end
                    --end

                --elseif szRule == "end" then
                         --Martin_Macro.bEndCode = szCondition

                --elseif szRule == "before" then
                         --Martin_Macro.bBeginCode = szCondition

                ----elseif szRule == "config" then
                    ----if szCondition == "保护引导" then
                        ----Martin_Macro.bChannel = true
                    ----elseif szCondition == "不保护引导" then
                        ----Martin_Macro.bChannel = false
                    ----end          
                --end
            --end
                ----if GetClientPlayer().GetOTActionState() == 2 and Martin_Macro.bChannel then
                    ----Martin_Macro.hfile:seek("set")
                    ----return
                ----end

                ----local szCode = Martin_Macro.hfile:read("*line")
                ----Output(szCode)

                ----if szCode == nil then
                    ----Martin_Macro.hfile:seek("set")
                    ----Martin_Macro.Run()
                ----else
                    ----local szRule, szCondition, szSkillName = Martin_Macro.Str_To_Lua(szCode)
                    
                    ----if szRule == "cast" then
                         ----if Martin_Macro.CalculateMacroConditionResult(szCondition) then           
                            ----local nSkillID, nSkillLv = Martin_Macro.GetSkillID(szSkillName)
                            ----if nSkillID ~= 2603 then
                                ----OnUseSkill(nSkillID, nSkillLv)
                            ----end
                        ----end

                    ----elseif szRule == "config" then
                        ----if szCondition == "保护引导" then
                            ----Martin_Macro.bChannel = true
                            ----Martin_Macro.Run()

                        ----elseif szCondition == "不保护引导" then
                            ----Martin_Macro.bChannel = false
                            ----Martin_Macro.Run()
                        ----end          
                    ----end
                ----end

        --end
    --)
    --coroutine.resume(Run)

end

function Martin_Macro.OpenWindow()
    local frame=Station.Lookup("Normal/Martin_Macro") or Wnd.OpenWindow("C:\\Windows\\martin.ini", "Martin_Macro") --定义窗体为frame
	frame:Hide() --将窗体隐藏出来
	Martin_Macro.hTotal = frame:Lookup("Wnd_Content", "")
	Martin_Macro.hBox = Martin_Macro.hTotal:Lookup("Box_1")
end

Martin_Macro.OpenWindow()

collectgarbage("collect")