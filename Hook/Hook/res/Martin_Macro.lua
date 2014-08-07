collectgarbage("collect")

Martin_Macro = {}
--Martin_Macro.bChannel = false
--Martin_Macro.nStepper = 0

Martin_Macro.nSkilldwID = 0
Martin_Macro.nSkillLevel = 0
Martin_Macro.tnSkilldwID = 0
Martin_Macro.tnSkillLevel = 0
Martin_Macro.bEndCode = nil
Martin_Macro.bBeginCode = ""

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
                if GetClientPlayer().dwID == dwSkillSrcID then
                    if Table_GetBuffName(dwID, nLevel) == szBuffName then
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

    if target then
        local bPrepare, dwID, nLevel, nFrameProgress = target.GetSkillPrepareState() 
        --if szRule == "prepare" then 
            --bPrepare, dwID, nLevel, nFrameProgress = player.GetSkillPrepareState() 
        --elseif szRule == "tprepare" and target then
            --bPrepare, dwID, nLevel, nFrameProgress = target.GetSkillPrepareState()
        --end

        if szSkillName == "prepare" then
            if bPrepare == true then
                if nFrameProgress > 0.4 then
                    return true
                end
                
            end  
        elseif Table_GetSkillName(dwID,nLevel) == szSkillName then
                if nFrameProgress > 0.4 then
                    return true
                end
        end
    end

    return false

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

function Martin_Macro.CheckForce(szRUle,szForceName)

	local player = GetClientPlayer()
	local ttype, tid = player.GetTarget()
	local target = GetTargetHandle(player.GetTarget())

	if szRule == "tforce" and target and ttype == 4 then
		if g_tStrings.tForceTitle[target.dwForceID] == szForceName then
			return true
		end
	elseif szRule == "tnoforce" and target and ttype == 4 then
		if g_tStrings.tForceTitle[target.dwForceID] ~= szForceName then
			return true
		end
	end

	return false

end

function Martin_Macro.CheckKungfuMount(szRule,szKungfuName)

	local player = GetClientPlayer()
	local target = GetTargetHandle(player.GetTarget())

	if szRule == "mount" then
		if player.GetKungfuMount().szSkillName == szKungfuName then
			return true
		end
	elseif szRule == "nomount" then
		if player.GetKungfuMount().szSkillName ~= szKungfuName then
			return true
		end
	elseif szRule == "tmount" and target and ttype == 4  and target then
		if target.GetKungfuMount().szSkillName == szKungfuName then
			return true
		end
	elseif szRule == "tnomount" and target and ttype == 4  and target then
		if target.GetKungfuMount().szSkillName ~= szKungfuName then
			return true
		end
	end

	return false

end

function Martin_Macro.CheckState(szRule, sParam)

    if szRule == "state" then
        if sParam == "无减伤" then
            local szOption = "nobuff:罗汉金身|御|御天|守如山|镇山河|鬼斧神工|太虚|回神|泉凝月|云栖松|转乾坤|天地低昂|笑醉狂|贪魔体"
            return Martin_Macro.CalculateMacroConditionResult(szOption)
        elseif sParam == "无免伤" then
            local szOption = "nobuff:罗汉金身|御|御天|守如山|镇山河|鬼斧神工|太虚|回神"
            return Martin_Macro.CalculateMacroConditionResult(szOption)
        elseif sParam == "被控制" then
            local szOption = "status:被击倒|眩晕|定身|锁足|僵直"
            return Martin_Macro.CalculateMacroConditionResult(szOption)
        elseif sParam == "可控制" then
            local szOption = "nobuff:梦泉虎跑|龙跃于渊|镇山河|力拔|素衿|折骨|生太极|千斤坠|转乾坤|星楼月影|蛊虫狂暴|啸日|生死之交|绝伦逸群|风蜈献祭|纵轻骑|碧蝶献祭|御天|不工|灵辉|超然|贪魔体|青阳"
            return Martin_Macro.CalculateMacroConditionResult(szOption)
        elseif sParam == "非被控" then
            local szOption = "nostatus:被击倒|眩晕|定身|锁足|僵直"
            return Martin_Macro.CalculateMacroConditionResult(szOption)
        end

    elseif szRule == "tstate" then
        if sParam == "可控制" then
            local szOption = "tnobuff:梦泉虎跑|龙跃于渊|镇山河|力拔|素衿|折骨|生太极|千斤坠|转乾坤|星楼月影|蛊虫狂暴|啸日|生死之交|绝伦逸群|风蜈献祭|纵轻骑|碧蝶献祭|御天|不工|灵辉|超然|贪魔体|青阳"
            return Martin_Macro.CalculateMacroConditionResult(szOption)
        elseif sParam == "非被控" then
            local szOption = "tnostatus:被击倒|眩晕|定身|锁足|僵直"
            return Martin_Macro.CalculateMacroConditionResult(szOption)
        elseif sParam == "无免伤" then
            local szOption = "tnobuff:罗汉金身|御|御天|守如山|镇山河|鬼斧神工|太虚|回神"
            return Martin_Macro.CalculateMacroConditionResult(szOption)
        elseif sParam == "被控制" then
            local szOption = "tstatus:被击倒|眩晕|定身|锁足|僵直"
            return Martin_Macro.CalculateMacroConditionResult(szOption)
        elseif sParam == "无减伤" then
            local szOption = "tnobuff:罗汉金身|御|御天|守如山|镇山河|鬼斧神工|太虚|回神|泉凝月|云栖松|转乾坤|天地低昂|笑醉狂|贪魔体"
            return Martin_Macro.CalculateMacroConditionResult(szOption)
        elseif sParam == "有减伤" then
            local szOption = "tbuff:罗汉金身|御|御天|守如山|镇山河|鬼斧神工|太虚|回神|泉凝月|云栖松|转乾坤|天地低昂|笑醉狂|贪魔体"
            return Martin_Macro.CalculateMacroConditionResult(szOption)
        end
    end

end

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

        elseif szRule:find("prepare") ~= nil or szKeyName:find("prepare") ~= nil then
                return Martin_Macro.CheckSkillPrepare(szRule,szKeyName)

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
			if tStackDataTable[1][1] == false then
                return tStackDataTable[1][1]
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

function Martin_Macro.Run()

	collectgarbage("collect")

    Martin_Macro.bEndCode = nil
    Martin_Macro.bBeginCode = ""

    for szMsg in io.lines("C:\\Windows\\testRead.txt") do

        if GetClientPlayer().GetOTActionState() == 2 then
            return
        end

        local szRule, szCondition, szSkillName, szAddonCondition = Martin_Macro.Str_To_Lua(szMsg)

        if szRule == "cast" then
             if Martin_Macro.CalculateMacroConditionResult(szCondition) and Martin_Macro.CalculateMacroConditionResult(Martin_Macro.bBeginCode) and not Martin_Macro.CalculateMacroConditionResult(Martin_Macro.bEndCode) then
                if szSkillName == "轻功躲避" then
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
                elseif szSkillName == "跳" then
                    Camera_EnableControl(CONTROL_JUMP, true)
                elseif szSkillName == "跟随目标" then
                    Martin_Macro.Follow()
                else
                    local nSkillID, nSkillLv = Martin_Macro.GetSkillID(szSkillName)
                    if nSkillID ~= 2603 then
                        if szAddonCondition == "self" then
                            Martin_Macro.SkillSelf(nSkillID, nSkillLv)
                        else
                            --醉舞九天  凝神聚气 风来吴山  暴雨梨花针  玳弦急曲   笑醉狂   回血飘摇
                            if szSkillName == "醉舞九天" or szSkillName == "凝神聚气" or szSkillName == "风来吴山" or szSkillName == "暴雨梨花针" or szSkillName == "玳弦急曲" or szSkillName == "笑醉狂" or szSkillName == "回血飘摇" then
                                if Martin_Macro.CheckSkillCD("nocd",szSkillName) then
                                    OnUseSkill(nSkillID, nSkillLv)
                                    return
                                end
                            end
                            OnUseSkill(nSkillID, nSkillLv)
                        end
                    end
                end
            end

        elseif szRule == "end" then
                 Martin_Macro.bEndCode = szCondition

        elseif szRule == "before" then
                 Martin_Macro.bBeginCode = szCondition

        --elseif szRule == "config" then
            --if szCondition == "保护引导" then
                --Martin_Macro.bChannel = true
            --elseif szCondition == "不保护引导" then
                --Martin_Macro.bChannel = false
            --end          
        end
    end

        --if GetClientPlayer().GetOTActionState() == 2 and Martin_Macro.bChannel then
            --Martin_Macro.hfile:seek("set")
            --return
        --end

        --local szCode = Martin_Macro.hfile:read("*line")
        --Output(szCode)

        --if szCode == nil then
            --Martin_Macro.hfile:seek("set")
            --Martin_Macro.Run()
        --else
            --local szRule, szCondition, szSkillName = Martin_Macro.Str_To_Lua(szCode)
            
            --if szRule == "cast" then
                 --if Martin_Macro.CalculateMacroConditionResult(szCondition) then           
                    --local nSkillID, nSkillLv = Martin_Macro.GetSkillID(szSkillName)
                    --if nSkillID ~= 2603 then
                        --OnUseSkill(nSkillID, nSkillLv)
                    --end
                --end

            --elseif szRule == "config" then
                --if szCondition == "保护引导" then
                    --Martin_Macro.bChannel = true
                    --Martin_Macro.Run()

                --elseif szCondition == "不保护引导" then
                    --Martin_Macro.bChannel = false
                    --Martin_Macro.Run()
                --end          
            --end
        --end

end

OutputMessage("MSG_SYS", "======加载成功======".."\n")


--function Martin_Macro.OnFrameBreathe()

    --if Martin_Macro.nStepper % 5 == 0 then
        --Martin_Macro.Run()
    --end

    --Martin_Macro.nStepper = Martin_Macro.nStepper + 1

--end

--function Martin_Macro.OpenWindow()
    --local frame = Station.Lookup("Lowest/Martin_Macro") --定义窗体为frame
    --if not frame then --如果没有发现窗体，则打开窗体
        --Martin_Macro.hfile = assert(io.open("C:\\Windows\\testRead.txt", 'r'))
        --Martin_Macro.nStepper = 0
        --Martin_Macro.OnFrameBreathe()
        --Wnd.OpenWindow("C:\\Windows\\martin.ini", "Martin_Macro")
    --end
    --frame:Show() --将窗体显示出来
--end

--function Martin_Macro.CloseWindow()
    --local frame = Station.Lookup("Lowest/Martin_Macro") --定义窗体为frame
    --if frame then --如果没有发现窗体，则打开窗体
        --Martin_Macro.hfile:close()
        --Wnd.CloseWindow(frame)
    --end
--end

function Martin_Macro.OpenWindow()
    local frame=Station.Lookup("Normal/Martin_Macro") or Wnd.OpenWindow("C:\\Windows\\martin.ini", "Martin_Macro") --定义窗体为frame
	frame:Hide() --将窗体隐藏出来
	Martin_Macro.hTotal = frame:Lookup("Wnd_Content", "")
	Martin_Macro.hBox = Martin_Macro.hTotal:Lookup("Box_1")
end

Martin_Macro.OpenWindow()

collectgarbage("collect")