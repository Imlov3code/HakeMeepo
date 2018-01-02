local HeroMeepo = {}

HeroMeepo.font 								= Renderer.LoadFont("Tahoma", 22, Enum.FontWeight.EXTRABOLD)
HeroMeepo.optionHeroMeepo					= Menu.AddOption({ "Utility", "[Meepo Beta version]" }, "Enable", "Auto Meepo combo or farming On/Off")
HeroMeepo.optionMeepoToBaseLowHP			= Menu.AddOption({ "Utility","[Meepo Beta version]"}, "Meepo Run to Base HP Percent", 30, 40, 60)

HeroMeepo.optionAutoMeepoComboKey 			= Menu.AddKeyOption({ "Utility","[Meepo Beta version]" }, "Meepo blink Poof Combo key", Enum.ButtonCode.KEY_F)
HeroMeepo.optionAutoMeepoSelectedAllMeepo   = Menu.AddKeyOption({ "Utility","[Meepo Beta version]" }, "Poof all to selected meepo key", Enum.ButtonCode.KEY_SPACE)
--HeroMeepo.optionMeepoToforestKey 			= Menu.AddKeyOption({ "Utility","[Meepo Beta version]" }, "Meepo Bots auto jungle key", Enum.ButtonCode.KEY_SPACE)
--HeroMeepo.optionMeepoToIDLEKey 			= Menu.AddKeyOption({ "Utility","[Meepo Beta version]" }, "Meepo Bots auto sets IDLE key", Enum.ButtonCode.KEY_SPACE)

-- TEMPORARY
HeroMeepo.List 					= {}
HeroMeepo.CampsClean 			= {}
HeroMeepo.TEAM 					= nil
HeroMeepo.TEAM_CONTAIN 			= 'radiant'

--farming & attack special
HeroMeepo.MeepoNPC 				= 0
HeroMeepo.MeepoThink 			= 1
HeroMeepo.MeepoLastThink 		= 2

HeroMeepo.Meepo_THINK_IDLE 		= 0
HeroMeepo.Meepo_THINK_MOVE 		= 1
HeroMeepo.Meepo_THINK_ATTACK 	= 2
HeroMeepo.Meepo_THINK_HEAL 		= 3

-- forest special
HeroMeepo.THINK_FOREST 			= 4
HeroMeepo.THINK_STACK 			= 5
HeroMeepo.THINK_GOLD_RUNE 		= 6
HeroMeepo.THINK_ATTACK_POOF 	= 7

-- attack special
HeroMeepo.THINK_VISION_ATTACK 	= 8
HeroMeepo.THINK_DEFEND 			= 9
HeroMeepo.THINK_POOF_STRIKE 	= 10
HeroMeepo.THINK_TEAMFIGHT 		= 11
HeroMeepo.THINK_EARTHBIND       = 12

--
local clock 						= os.clock
HeroMeepo.LastCastTime 				= os.clock()

HeroMeepo.CampLocation = {
    radiant_ancient_camp_1 		= Vector(-2700, -250, 384),
    radiant_ancient_camp_2 		= Vector(150, -2000, 384),
    dire_ancient_camp_1 		= Vector(-700, 2300, 384),
    dire_ancient_camp_2 		= Vector(3600, -700, 256),
    radiant_small_camp 			= Vector(3250, -4500, 256),
    dire_small_camp 			= Vector(-3050, 4800, 384),
    radiant_mid_camp_1 			= Vector(-3900, 600, 256),
    radiant_mid_camp_3 			= Vector(650, -4600, 384),
    dire_mid_camp_1 			= Vector(-1650, 3968, 256),
    dire_mid_camp_3 			= Vector(2800, 100, 384),
    radiant_large_camp_1 		= Vector(-4700, -350, 256),
    radiant_large_camp_2 		= Vector(-600, -3300, 256),
    radiant_large_camp_3 		= Vector(4500, -4300, 256),
    dire_large_camp_1 			= Vector(-4350, 3700, 256),
    dire_large_camp_2 			= Vector(-300, 3400, 256),
    dire_large_camp_3 			= Vector(4350, 750, 384)
}

HeroMeepo.MiniCampLocation = {
    radiant_small_camp 			= Vector(3250, -4500, 256),
    dire_small_camp 			= Vector(-3050, 4800, 384),
    radiant_mid_camp_1 			= Vector(-3900, 600, 256),
    radiant_mid_camp_3 			= Vector(650, -4600, 384),
    dire_mid_camp_1 			= Vector(-1650, 3968, 256),
    dire_mid_camp_3 			= Vector(2800, 100, 384),
}

HeroMeepo.MicroCampLocation = {
    radiant_small_camp 			= Vector(3250, -4500, 256),
    radiant_mid_camp_1 			= Vector(-3900, 600, 256),
    dire_small_camp 			= Vector(-3050, 4800, 384),
    dire_mid_camp_1 			= Vector(-1650, 3968, 256),
}

HeroMeepo.BuildingLocation = {
    radiant_fountain 			= Vector(-7600, -7300, 640),
    dire_fountain 				= Vector(7800, 7250, 640)
}

function HeroMeepo.Reset()
	HeroMeepo.List = {}
end

function HeroMeepo.OnUpdate()
    if not Menu.IsEnabled(HeroMeepo.optionHeroMeepo) then return end
	if not Engine.IsInGame() then HeroMeepo.Reset() end
	
	if GameRules.GetGameState() < 4 then return end
	if GameRules.GetGameState() > 5 then return end
	
	local myHero = Heroes.GetLocal()
	if not myHero then return end
	if NPC.GetUnitName(myHero) ~= "npc_dota_hero_meepo" then return end
	if not Entity.IsAlive(myHero) then return end
	
    if not HeroMeepo.TEAM then
        HeroMeepo.TEAM = Entity.GetTeamNum(myHero)

        if HeroMeepo.TEAM == 3 then
            HeroMeepo.TEAM_CONTAIN = 'dire'
        end

        Log.Write(HeroMeepo.TEAM_CONTAIN)
    end

	local meepo_bots_counter 		= 0
    local LocalTimeTick 			= os.time()
	local meepo_divided_we_stand 	= NPC.GetAbility(myHero, "meepo_divided_we_stand")
	
	if Ability.GetLevel(meepo_divided_we_stand) > 0 and Ability.GetLevel(meepo_divided_we_stand) <= 3 then
		meepo_bots_counter = meepo_bots_counter + 1
	end

    if (GameRules.GetGameTime() - GameRules.GetGameStartTime()) / 60 % 1 < 0.01 then
        HeroMeepo.CampsClean = {}
    end
	
	local enemy = Input.GetNearestHeroToCursor(Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_ENEMY)
	
	if enemy then 
		HeroMeepo.MainMeepoHeroCombo(myHero, enemy)
	end

    if meepo_bots_counter > 0 then
       for i = 1, NPCs.Count() do 
         local npc = NPCs.Get(i)
         local name = NPC.GetUnitName(npc)
         if name ~= nil and Entity.IsSameTeam(myHero, npc) and Entity.GetHealth(npc) > 0 then
            if name == "npc_dota_hero_meepo" then
                if myHero ~= npc then
					local v = Entity.GetIndex(npc)
					HeroMeepo.List[v] = {}
					HeroMeepo.List[v][HeroMeepo.MeepoNPC]       = npc
					HeroMeepo.List[v][HeroMeepo.MeepoThink]     = HeroMeepo.MeepoThink
					HeroMeepo.List[v][HeroMeepo.MeepoLastThink] = os.time()
                end
             end
          end
       end
    end
	
	for i, entity in pairs(HeroMeepo.List) do
        HeroMeepo.MakeMeepoBotAction(entity, LocalTimeTick)
        HeroMeepo.MakeMeepoBotThink(entity, LocalTimeTick)
    end
end

function HeroMeepo.MainMeepoHeroCombo(myHero, enemy)
	if not Menu.IsEnabled(HeroMeepo.optionHeroMeepo) then return end
	if not NPC.IsEntityInRange(myHero, enemy, 3000) then return end
	
	local meepo_earthbind 			= NPC.GetAbility(myHero, "meepo_earthbind")
	local meepo_poof 				= NPC.GetAbility(myHero, "meepo_poof")
	local meepo_geostrike 			= NPC.GetAbility(myHero, "meepo_geostrike")
	local meepo_divided_we_stand 	= NPC.GetAbility(myHero, "meepo_divided_we_stand")
	local myMana 					= NPC.GetMana(myHero)
	
	local blink = NPC.GetItem(myHero, "item_blink", true)
	
	if Menu.IsKeyDown(HeroMeepo.optionAutoMeepoComboKey) and Entity.GetHealth(enemy) > 0 then
		if not NPC.IsEntityInRange(myHero, enemy, 450) then
			if blink and Ability.IsCastable(blink, myMana) and NPC.IsEntityInRange(myHero, enemy, 1200) then
				Ability.CastPosition(blink, (Entity.GetAbsOrigin(enemy) + (Entity.GetAbsOrigin(myHero) - Entity.GetAbsOrigin(enemy)):Normalized():Scaled(350)))
				return
			end
		end
			
		if os.clock() > HeroMeepo.LastCastTime then
			if NPC.IsEntityInRange(myHero, enemy, 1250) then
				if enemy and meepo_earthbind and Ability.IsCastable(meepo_earthbind, myMana) then
					local earthbind_range = 1250
					local earthbind_radius = 220
					local enemies = NPC.GetUnitsInRadius(myHero, earthbind_range + earthbind_radius, Enum.TeamType.TEAM_ENEMY)
					if not enemies or #enemies <= 0 then return end
					local earthBindPrediction = Ability.GetCastPoint(meepo_earthbind) + (Entity.GetAbsOrigin(enemy):__sub(Entity.GetAbsOrigin(myHero)):Length2D() / 1600) + (NetChannel.GetAvgLatency(Enum.Flow.FLOW_OUTGOING) * 2)

					if os.clock() - HeroMeepo.LastCastTime > 0.1 + NetChannel.GetAvgLatency(Enum.Flow.FLOW_OUTGOING) * 2 then
						Ability.CastPosition(meepo_earthbind, HeroMeepo.castLinearPrediction(myHero, enemy, earthBindPrediction))
						HeroMeepo.LastCastTime = os.clock()
						return
					end
				end
			end
				
			if NPC.IsEntityInRange(myHero, enemy, 350) then
				if enemy and meepo_poof and Ability.IsCastable(meepo_poof, myMana) and HeroMeepo.IsSuitableToCastSpell(myHero) then
					Ability.CastTarget(meepo_poof, myHero)
					HeroMeepo.LastCastTime = os.clock() + 0.3
					return
				end
			end
		end
        
        HeroMeepo.GenericAttackIssuer("Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET", myHero, enemy, nil)
	end
end

function HeroMeepo.OnDraw()
	local myHero = Heroes.GetLocal()
    if not myHero then return end
	if not Entity.IsAlive(myHero) then return end 
	if not Engine.IsInGame() then HeroMeepo.Reset() return end 
	
	if NPC.GetUnitName(myHero) ~= "npc_dota_hero_meepo" then return end
		
    local size = 30
    for i, entity in pairs(HeroMeepo.List) do
        local npc = entity[HeroMeepo.MeepoNPC]
        local origin = Entity.GetAbsOrigin(npc)
        local x, y, visible = Renderer.WorldToScreen(origin)
        Renderer.SetDrawColor(255, 215, 0, 255)
        Renderer.DrawText(HeroMeepo.font, x - size, y - size, HeroMeepo.MakeDebugBotMeepo(entity), 1)
    end
end

function HeroMeepo.MakeDebugBotMeepo(entity)
    if entity[HeroMeepo.MeepoThink] == HeroMeepo.Meepo_THINK_IDLE then
        return 'IDLE'
    end

    if entity[HeroMeepo.MeepoThink] == HeroMeepo.Meepo_THINK_MOVE then
        return 'MOVE'
    end

    if entity[HeroMeepo.MeepoThink] == HeroMeepo.Meepo_THINK_ATTACK then
        return 'ATTACK'
    end

    if entity[HeroMeepo.MeepoThink] == HeroMeepo.Meepo_THINK_HEAL then
        return 'HEAL'
    end

    if entity[HeroMeepo.MeepoThink] == HeroMeepo.THINK_STACK then
        return 'STACK'
    end

    if entity[HeroMeepo.MeepoThink] == HeroMeepo.THINK_GOLD_RUNE then
        return 'GOLD'
    end

    if entity[HeroMeepo.MeepoThink] == HeroMeepo.THINK_POOF_STRIKE then
        return 'POOF STRIKE'
    end

    if entity[HeroMeepo.MeepoThink] == HeroMeepo.THINK_FOREST then
        return 'FOREST'
    end

    if entity[HeroMeepo.MeepoThink] == HeroMeepo.THINK_VISION_ATTACK then
        return 'VISION ATTACK'
    end

    if entity[HeroMeepo.MeepoThink] == HeroMeepo.THINK_TEAMFIGHT then
        return 'TEAMFIGHT'
    end

    return 'NONE'
end

function HeroMeepo.MakeMeepoBotAction(entity, time)
    if time < entity[HeroMeepo.MeepoLastThink] then return end
	
	local myHero = Heroes.GetLocal()
	if not myHero then return end

	local name = NPC.GetUnitName(myHero)
	if name ~= 'npc_dota_hero_meepo' then return end

    -- attack closest enemies
	local meepo_earthbind 			= NPC.GetAbility(myHero, "meepo_earthbind")
	local meepo_poof 				= NPC.GetAbility(myHero, "meepo_poof")
	
    local DISTANCE_ENEMY 		= 950
    local DISTANCE_DANGER 		= 1200

    local origin 			= Entity.GetAbsOrigin(entity[HeroMeepo.MeepoNPC])
    local creeps 			= NPC.GetUnitsInRadius(entity[HeroMeepo.MeepoNPC], DISTANCE_ENEMY, Enum.TeamType.TEAM_ENEMY)
    local min_distance 		= 1500
    local min_distance_hero = 1200
    local target 			= nil
    local hero_target 		= nil
	
    if not NPC.HasModifier(entity[HeroMeepo.MeepoNPC], "modifier_fountain_aura_buff") then
        for i, npc in ipairs(creeps) do
            local target_origin = Entity.GetAbsOrigin(npc)
            local distance = (origin - target_origin):Length()
            if Entity.GetHealth(npc) > 0 then
                if NPC.IsLaneCreep(npc) or Entity.IsHero(npc) or NPC.IsStructure(npc) then
                    if Entity.IsHero(npc) and distance < min_distance_hero then
                        min_distance_hero = distance
                        hero_target = npc
                    end
					
                    if distance < min_distance then
                        target = npc
                        min_distance = distance

						if entity[HeroMeepo.MeepoThink] ~= HeroMeepo.THINK_HEAL and Entity.IsHero(npc) then
							if distance < Ability.GetCastRange(meepo_earthbind) then
								HeroMeepo.MeepoEarthBind(entity, target)
							end
							
							if distance < 375 then
								HeroMeepo.MeepoPoofStrike(entity)
							end
						end
                    end
                end
            end
        end
    end

     -- checking if enemies is near, change states
    if hero_target then
        target = hero_target
    end

    if Menu.IsKeyDown(HeroMeepo.optionAutoMeepoSelectedAllMeepo) then		
		HeroMeepo.MakeMeepoBotFastPoofStrike(entity)
    end
	
	--if not target and Menu.IsKeyDown(HeroMeepo.optionMeepoToIDLEKey) then
    --    entity[HeroMeepo.MeepoThink] = HeroMeepo.Meepo_THINK_IDLE
    --end

	-- 1. Check woods and meepo's level.
	-- if not target and Menu.IsKeyDown(HeroMeepo.optionMeepoToforestKey) then
	--    entity[HeroMeepo.MeepoThink] = HeroMeepo.THINK_FOREST
	--end
	
    if target and entity[HeroMeepo.MeepoThink] ~= HeroMeepo.THINK_HEAL then
        if NPC.IsHero(target) then
            entity[HeroMeepo.MeepoThink] = HeroMeepo.THINK_TEAMFIGHT
        end
    end
	
    if target and entity[HeroMeepo.MeepoThink] == HeroMeepo.THINK_TEAMFIGHT then
        if NPC.IsHero(target) then
			if entity[HeroMeepo.MeepoThink] ~= HeroMeepo.THINK_HEAL then
				if Entity.GetHealth(entity[HeroMeepo.MeepoNPC]) * 100 / Entity.GetMaxHealth(entity[HeroMeepo.MeepoNPC]) >= Menu.GetValue(HeroMeepo.optionMeepoToBaseLowHP) then
					HeroMeepo.GenericAttackIssuer("Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET", entity[HeroMeepo.MeepoNPC], target, nil)
				end
			end
		end
    end
	
    -- check danger
    if Entity.GetHealth(entity[HeroMeepo.MeepoNPC]) * 100 / Entity.GetMaxHealth(entity[HeroMeepo.MeepoNPC]) < Menu.GetValue(HeroMeepo.optionMeepoToBaseLowHP) then
        for i = 1, Heroes.Count() do
            local enemy = Heroes.Get(i)
            if not NPC.IsIllusion(enemy) and not Entity.IsSameTeam(entity[HeroMeepo.MeepoNPC], enemy) 
            and not Entity.IsDormant(enemy) and Entity.IsAlive(enemy) then 
				if (Entity.GetAbsOrigin(entity[HeroMeepo.MeepoNPC]) - Entity.GetAbsOrigin(enemy)):Length() < DISTANCE_DANGER then
					entity[HeroMeepo.MeepoThink] = HeroMeepo.Meepo_THINK_HEAL
				else
					entity[HeroMeepo.MeepoThink] = HeroMeepo.Meepo_THINK_HEAL
				end
            end
        end
    end
end

function HeroMeepo.MakeMeepoBotFastPoofStrike(entity)
    if not entity then return end
	
    local meepo_poof    	= NPC.GetAbility(entity[HeroMeepo.MeepoNPC], "meepo_poof")
    local myMana        	= NPC.GetMana(entity[HeroMeepo.MeepoNPC])
    local BotshealthBar     = Entity.GetHealth(entity[HeroMeepo.MeepoNPC]) * 100 / Entity.GetMaxHealth(entity[HeroMeepo.MeepoNPC])

    if BotshealthBar <= 45 then return end

    if meepo_poof and Ability.IsCastable(meepo_poof, myMana) and Ability.IsReady(meepo_poof) and HeroMeepo.IsSuitableToCastSpell(entity[HeroMeepo.MeepoNPC]) then
        for i = 1, NPCs.Count() do 
            local myHeroNPC = NPCs.Get(i)
            if NPC.GetUnitName(myHeroNPC) ~= nil and Entity.IsSameTeam(entity[HeroMeepo.MeepoNPC], myHeroNPC) and Entity.GetHealth(myHeroNPC) > 0 then
                if NPC.GetUnitName(myHeroNPC) == 'npc_dota_hero_meepo' and entity[HeroMeepo.MeepoNPC] ~= myHeroNPC then
                    if myHeroNPC then
						Ability.CastTarget(meepo_poof, myHeroNPC)
						HeroMeepo.LastCastTime = os.clock()
						break
						return
                    end
                end
            end
        end
    end
end

function HeroMeepo.MeepoEarthBind(entity, target)
    local spell = NPC.GetAbility(entity[HeroMeepo.MeepoNPC], "meepo_earthbind")
    if not spell or not Ability.IsCastable(spell, NPC.GetMana(entity[HeroMeepo.MeepoNPC])) then return end
	if entity[HeroMeepo.MeepoThink] == HeroMeepo.Meepo_THINK_HEAL then return end

    local range = 1250
    local radius = 220

    local enemies = NPC.GetUnitsInRadius(entity[HeroMeepo.MeepoNPC], range + radius, Enum.TeamType.TEAM_ENEMY)
    if not enemies or #enemies <= 0 then return end
	local earthBindPrediction = Ability.GetCastPoint(spell) + (Entity.GetAbsOrigin(target):__sub(Entity.GetAbsOrigin(entity[HeroMeepo.MeepoNPC])):Length2D() / 600) + (NetChannel.GetAvgLatency(Enum.Flow.FLOW_OUTGOING) * 2)

	if NPC.IsEntityInRange(entity[HeroMeepo.MeepoNPC], target, range) then
		if os.clock() - HeroMeepo.LastCastTime > 0.1 + NetChannel.GetAvgLatency(Enum.Flow.FLOW_OUTGOING) * 2 then
			Ability.CastPosition(spell, HeroMeepo.castLinearPrediction(entity[HeroMeepo.MeepoNPC], target, earthBindPrediction))
			HeroMeepo.LastCastTime = os.clock()
			return
		end
    end
end

function HeroMeepo.MeepoPoofStrike(entity)
    for i, MeepoBots in pairs(HeroMeepo.List) do
        local npc = MeepoBots[HeroMeepo.MeepoNPC]
        if MeepoBots ~= entity then
            local healthBar = ((Entity.GetHealth(MeepoBots[HeroMeepo.MeepoNPC]) * 100) / Entity.GetMaxHealth(entity[HeroMeepo.MeepoNPC]))
            local mana 		   = NPC.GetMana(MeepoBots[HeroMeepo.MeepoNPC])
            local spell 	   = NPC.GetAbility(MeepoBots[HeroMeepo.MeepoNPC], "meepo_poof")
			
            if healthBar > 43.0 and mana > 80 * 2 
			and Ability.IsCastable(spell, mana)
			and Ability.IsReady(spell)
			and HeroMeepo.IsSuitableToCastSpell(MeepoBots[HeroMeepo.MeepoNPC]) and entity[HeroMeepo.MeepoThink] ~= HeroMeepo.Meepo_THINK_HEAL then
				if os.clock() - HeroMeepo.LastCastTime > 0.1 + NetChannel.GetAvgLatency(Enum.Flow.FLOW_OUTGOING) * 2 then
					Ability.CastTarget(spell, entity[HeroMeepo.MeepoNPC])
					HeroMeepo.LastCastTime = os.clock()
				end
				entity[HeroMeepo.MeepoLastThink] = os.time() + 0.4
				return
            end
        end
    end
end

function HeroMeepo.MakeMeepoBotThink(entity, time)
    if time < entity[HeroMeepo.MeepoLastThink] then return end
	if not Entity.IsAlive(entity[HeroMeepo.MeepoNPC]) then return end
	
	if Entity.GetHealth(entity[HeroMeepo.MeepoNPC]) * 100 / Entity.GetMaxHealth(entity[HeroMeepo.MeepoNPC]) < Menu.GetValue(HeroMeepo.optionMeepoToBaseLowHP) then
		entity[HeroMeepo.MeepoThink] = HeroMeepo.Meepo_THINK_HEAL
	end

    if entity[HeroMeepo.MeepoThink] == HeroMeepo.Meepo_THINK_HEAL then
       local team = HeroMeepo.TEAM
       local location = HeroMeepo.BuildingLocation['dire_fountain']
			
       if team ~= 3 then location = HeroMeepo.BuildingLocation['radiant_fountain'] end
			
       if not HeroMeepo.FastHeal(entity) then 
			HeroMeepo.GenericAttackIssuer("Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION", entity[HeroMeepo.MeepoNPC], nil, location)
       end
			
       entity[HeroMeepo.MeepoLastThink] = time + 0.1
	   return
    end

    if entity[HeroMeepo.MeepoThink] == HeroMeepo.THINK_FOREST then
        local only_small = 2
		
        if Entity.GetMaxHealth(entity[HeroMeepo.MeepoNPC]) > 820 then
            only_small = 1
        end
		
        if Entity.GetMaxHealth(entity[HeroMeepo.MeepoNPC]) > 1200 then
            only_small = false
        end
		
        local location = HeroMeepo.ClosestCamp(entity, only_small)
		
        if location then
			entity[HeroMeepo.MeepoThink] = HeroMeepo.THINK_FOREST
            local origin = Entity.GetAbsOrigin(entity[HeroMeepo.MeepoNPC])
            NPC.MoveTo(entity[HeroMeepo.MeepoNPC], location['origin'])
			
            if (origin - location['origin']):Length() <= 120 then
                entity[HeroMeepo.MeepoThink] = HeroMeepo.Meepo_THINK_ATTACK
            end
        else
            Log.Write('no camps...')
        end
    end

    if entity[HeroMeepo.MeepoThink] == HeroMeepo.Meepo_THINK_ATTACK then
        local target_range = 500
        local target = nil
        local min_distance = 9999
        local creeps = NPC.GetUnitsInRadius(entity[HeroMeepo.MeepoNPC], target_range, Enum.TeamType.TEAM_ENEMY)
        local origin = Entity.GetAbsOrigin(entity[HeroMeepo.MeepoNPC])
        for i, npc in ipairs(creeps) do
            local target_origin = Entity.GetAbsOrigin(npc)
            local distance = (origin - target_origin):Length()
            if Entity.GetHealth(npc) > 0 and min_distance > distance then
                target = npc
                min_distance = distance
            end
        end
		
        if target then
            local origin = Entity.GetAbsOrigin(entity[HeroMeepo.MeepoNPC])
            local mana = NPC.GetMana(entity[HeroMeepo.MeepoNPC])
            local spell = NPC.GetAbility(entity[HeroMeepo.MeepoNPC], "meepo_poof")
			
            if mana * 100 / NPC.GetMaxMana(entity[HeroMeepo.MeepoNPC]) > 50.0 
			and Ability.IsCastable(spell, mana) 
			and Ability.IsReady(spell) 
			and HeroMeepo.IsSuitableToCastSpell(entity[HeroMeepo.MeepoNPC]) then
                Ability.CastTarget(spell, entity[HeroMeepo.MeepoNPC])
                entity[HeroMeepo.MeepoLastThink] = time + 0.4
            end
			
            Player.AttackTarget(Players.GetLocal(), entity[HeroMeepo.MeepoNPC], target)
            entity[HeroMeepo.MeepoLastThink] = time + 0.4
        else
            local location = HeroMeepo.ClosestCamp(entity, false, 350)
			
            if location then
                HeroMeepo.CampCleaned(location) -- clean closest woodcamp if exists
            end
			
            entity[HeroMeepo.MeepoThink] = HeroMeepo.THINK_FOREST
        end
    end

    entity[HeroMeepo.MeepoLastThink] = time + 0.3
end

function HeroMeepo.FastHeal(entity)
    local origin 	= Entity.GetAbsOrigin(entity[HeroMeepo.MeepoNPC])
    local location 	= HeroMeepo.BuildingLocation['dire_fountain']
	
    if HeroMeepo.TEAM ~= 3 then
        location = HeroMeepo.BuildingLocation['radiant_fountain']
    end
	
    local entity_distance = (origin - location):Length()
    if entity_distance < 1775 then
        return false
    end

    local min_distance = 9999999
    local mana = NPC.GetMana(entity[HeroMeepo.MeepoNPC])

    local travel = NPC.GetItem(entity[HeroMeepo.MeepoNPC], "item_travel_boots", true)
	local IsNeedToUseTravel = false
    if travel and Ability.IsCastable(travel, mana) and Ability.IsReady(travel) and HeroMeepo.IsSuitableToCastSpell(entity[HeroMeepo.MeepoNPC]) then
		for i = 1, Heroes.Count() do
            local enemy = Heroes.Get(i)
            if not NPC.IsIllusion(enemy) and not Entity.IsSameTeam(entity[HeroMeepo.MeepoNPC], enemy) and not Entity.IsDormant(enemy) and Entity.IsAlive(enemy) 
            and (Entity.GetAbsOrigin(entity[HeroMeepo.MeepoNPC]) - Entity.GetAbsOrigin(enemy)):Length() > 1200 then
				Ability.CastPosition(travel, location)
				break
				return true
            end
        end
    end
	
    return false
end

function HeroMeepo.ClosestCamp(entity, only_small, closest_only)
    local location = nil
    local origin = Entity.GetAbsOrigin(entity[HeroMeepo.MeepoNPC])
    local min_distance = 99999
    local camps = HeroMeepo.CampLocation
	
    if only_small == 1 then
        camps = HeroMeepo.MiniCampLocation
    elseif only_small == 2 then
        camps = HeroMeepo.MicroCampLocation
    end
    if closest_only then
        for i, camp in pairs(camps) do
            if string.match(i, HeroMeepo.TEAM_CONTAIN) then
                if (origin - camp):Length() <= closest_only then
                    location = {
                        name = i,
                        origin = camp,
                    }
                end
            end
        end
    else
        for i, camp in pairs(camps) do
            local distance = (origin - camp):Length()
            if string.match(i, HeroMeepo.TEAM_CONTAIN) then
                if distance < min_distance and not HeroMeepo.isCampCleaned(i) then
                    min_distance = distance
                    location = {
                        name = i,
                        origin = camp,
                    }
                end
            end
        end
    end
	
    return location
end

function HeroMeepo.CheckCanUseEarthBind(target)
    local stunRootList = {
        "modifier_stunned",
        "modifier_bashed",
        "modifier_alchemist_unstable_concoction", 
        "modifier_ancientapparition_coldfeet_freeze", 
        "modifier_axe_berserkers_call",
        "modifier_bane_fiends_grip",
        "modifier_bane_nightmare",
        "modifier_bloodseeker_rupture",
        "modifier_rattletrap_hookshot", 
        "modifier_earthshaker_fissure_stun", 
        "modifier_earth_spirit_boulder_smash",
        "modifier_enigma_black_hole_pull",
        "modifier_faceless_void_chronosphere_freeze",
        "modifier_jakiro_ice_path_stun", 
        "modifier_keeper_of_the_light_mana_leak_stun", 
        "modifier_kunkka_torrent", 
        "modifier_legion_commander_duel", 
        "modifier_lion_impale", 
        "modifier_magnataur_reverse_polarity", 
        "modifier_medusa_stone_gaze_stone", 
        "modifier_morphling_adaptive_strike", 
        "modifier_naga_siren_ensnare", 
        "modifier_nyx_assassin_impale", 
        "modifier_pudge_dismember", 
        "modifier_sandking_impale", 
        "modifier_shadow_shaman_shackles", 
        "modifier_techies_stasis_trap_stunned", 
        "modifier_tidehunter_ravage", 
        "modifier_treant_natures_guise",
        "modifier_windrunner_shackle_shot",
        "modifier_rooted", 
        "modifier_crystal_maiden_frostbite", 
        "modifier_ember_spirit_searing_chains", 
        "modifier_meepo_earthbind",
        "modifier_lone_druid_spirit_bear_entangle_effect",
        "modifier_slark_pounce_leash",
        "modifier_storm_spirit_electric_vortex_pull",
        "modifier_treant_overgrowth", 
        "modifier_abyssal_underlord_pit_of_malice_ensare", 
        "modifier_item_rod_of_atos_debuff",
        "modifier_eul_cyclone",
        "modifier_obsidian_destroyer_astral_imprisonment_prison",
        "modifier_shadow_demon_disruption"
            }
    
    local searchMod
    for _, modifier in ipairs(stunRootList) do
        if NPC.HasModifier(target, modifier) then
            searchMod = NPC.GetModifier(target, modifier)
            break
        end
    end

    return not searchMod
end

function HeroMeepo.CampCleaned(location)
    local name = location['name']
    if HeroMeepo.CampsClean[name] ~= nil then return true end
    HeroMeepo.CampsClean[name] = true
    return true
end

function HeroMeepo.isCampCleaned(location)
    if HeroMeepo.CampsClean[location] ~= nil then return true end
    return false
end

function HeroMeepo.ReadySleep(n)  -- seconds
    local t0 = clock()
    while clock() - t0 <= n do end
end

function HeroMeepo.castLinearPrediction(myHero, enemy, adjustmentVariable)
	if not myHero then return end
	if not enemy then return end

	local enemyRotation = Entity.GetRotation(enemy):GetVectors()
	enemyRotation:SetZ(0)
    local enemyOrigin = NPC.GetAbsOrigin(enemy)
	enemyOrigin:SetZ(0)

	local cosGamma = (NPC.GetAbsOrigin(myHero) - enemyOrigin):Dot2D(enemyRotation:Scaled(100)) / ((NPC.GetAbsOrigin(myHero) - enemyOrigin):Length2D() * enemyRotation:Scaled(100):Length2D())
	if enemyRotation and enemyOrigin then
		if not NPC.IsRunning(enemy) then
		return enemyOrigin
		else return enemyOrigin:__add(enemyRotation:Normalized():Scaled(HeroMeepo.GetMoveSpeed(enemy) * adjustmentVariable * (1 - cosGamma)))
		end
	end
end

function HeroMeepo.getBestPosition(unitsAround, radius)
	if not unitsAround or #unitsAround < 1 then
		return 
	end

	local countEnemies = #unitsAround

	if countEnemies == 1 then 
		return Entity.GetAbsOrigin(unitsAround[1]) 
	end

	local maxCount = 1
	local bestPosition = Entity.GetAbsOrigin(unitsAround[1])
	for i = 1, (countEnemies - 1) do
		for j = i + 1, countEnemies do
			if unitsAround[i] and unitsAround[j] then
				local pos1 = Entity.GetAbsOrigin(unitsAround[i])
				local pos2 = Entity.GetAbsOrigin(unitsAround[j])
				local mid = pos1:__add(pos2):Scaled(0.5)

				local heroesCount = 0
				for k = 1, countEnemies do
					if NPC.IsPositionInRange(unitsAround[k], mid, radius, 0) then
						heroesCount = heroesCount + 1
					end
				end

				if heroesCount > maxCount then
					maxCount = heroesCount
					bestPos = mid
				end
			end
		end
	end
	return bestPos
end

function HeroMeepo.GenericAttackIssuer(attackType, npc, target, position)
    if not npc or (npc and not Entity.IsAlive(npc)) then return end
    if not target and not position then return end

    if HeroMeepo[tostring(npc)] ~= nil then
        if os.clock() - HeroMeepo[tostring(npc)] < 1.0 then
            return
        end
    end

    if attackType == "Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET" and Menu.IsKeyDown(HeroMeepo.optionAutoMeepoComboKey) then
        if target ~= nil then
            Player.AttackTarget(Players.GetLocal(), npc, target, false)
            HeroMeepo[tostring(npc)] = os.clock()
            return
        end
    end

    if attackType == "Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_MOVE" then
        if position ~= nil then
            if #NPC.GetUnitsInRadius(npc, NPC.GetAttackRange(npc)+50, 1) < 1 then
                Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_MOVE, target, position, ability, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, npc)
                HeroMeepo[tostring(npc)] = os.clock()
                return
            end
        end
    end

    if attackType == "Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION" then
        if position ~= nil then
            if not NPC.IsRunning(npc) then
                NPC.MoveTo(npc, position, false, false)
                HeroMeepo[tostring(npc)] = os.clock()
                return
            end
        end
    end
end

function HeroMeepo.GetMoveSpeed(npc)
    local base_speed 	= NPC.GetBaseSpeed(npc)
    local bonus_speed 	= NPC.GetMoveSpeed(npc) - NPC.GetBaseSpeed(npc)

    return base_speed + bonus_speed
end

function HeroMeepo.IsSuitableToCastSpell(myHero)
    if NPC.IsSilenced(myHero) or NPC.IsStunned(myHero) or not Entity.IsAlive(myHero) then return false end
    if NPC.HasState(myHero, Enum.ModifierState.MODIFIER_STATE_INVISIBLE) then return false end
    if NPC.HasModifier(myHero, "modifier_teleporting") then return false end
    if NPC.IsChannellingAbility(myHero) then return false end

    return true
end

return HeroMeepo
