local MyHeroScript = {}

-- options
MyHeroScript.optionEnable = Menu.AddOption({ "MyScript" }, "1. Enabled scripts {{overall}}", "Helpers helper")
MyHeroScript.optionComboKey = Menu.AddKeyOption({ "MyScript" }, "2. General combo key", Enum.ButtonCode.KEY_SPACE)
MyHeroScript.optionTargetStyle = Menu.AddOption({ "MyScript", "3. Target selector" }, "0. Targeting style {{overall targeting}}", "", 0, 1, 1)
MyHeroScript.optionTargetRange = Menu.AddOption({ "MyScript", "3. Target selector" }, "1. Target acquisition range {{overall targeting}}", "target needs to be in range of your cursor", 200, 1000, 50)
MyHeroScript.optionMoveToCursor = Menu.AddOption({ "MyScript", "3. Target selector" }, "2. Move to Cursor Pos {{overall targeting}}", "if no enemy in acquisition range, your hero will move to cursor pos")

MyHeroScript.optionTargetCheckAM = Menu.AddOption({ "MyScript", "1.2 Target selector", "4. Target exclusions" }, "Exclude AM with agha {{targetselect}}", "if enabled, script will not combo/target an anti-mage with agha spell shield off cooldown")
MyHeroScript.optionTargetCheckLotus = Menu.AddOption({ "MyScript", "1.2 Target selector", "4. Target exclusions" }, "Exclude active lotus orb {{targetselect}}", "if enabled, script will not combo/target an enemy with lotus orb active")
MyHeroScript.optionTargetCheckBlademail = Menu.AddOption({ "MyScript", "1.2 Target selector", "4. Target exclusions" }, "Exclude blademail {{targetselect}}", "if enabled, script will not combo/target an enemy with blademail active, if own HP is low")
MyHeroScript.optionTargetCheckNyx = Menu.AddOption({ "MyScript", "1.2 Target selector", "4. Target exclusions" }, "Exclude spiked carapace {{targetselect}}", "if enabled, script will not combo/target a nyx if spiked carapace is active")
MyHeroScript.optionTargetCheckUrsa = Menu.AddOption({ "MyScript", "1.2 Target selector", "4. Target exclusions" }, "Exclude enraged ursa {{targetselect}}", "if enabled, script will not combo/target an ursa if enraged")
MyHeroScript.optionTargetCheckAbbadon = Menu.AddOption({ "MyScript", "1.2 Target selector", "4. Target exclusions" }, "Exclude abaddon ult {{targetselect}}", "if enabled, script will not combo/target an enemy that has the burrowed time modifier")
MyHeroScript.optionTargetCheckDazzle = Menu.AddOption({ "MyScript", "1.2 Target selector", "4. Target exclusions" }, "Exclude shallow grave {{targetselect}}", "if enabled, script will not combo/target an enemy that got shallow graved (except you are AXE)")

MyHeroScript.OptionHeroLifeStealer = Menu.AddOption({ "MyScript", "4. Hero Scripts", "1. Strength heroes", "Life Stealer" }, "0. Life Stealer Combo", "On/Off")
MyHeroScript.OptionHeroLifeStealerBlink = Menu.AddOption({ "MyScript", "4. Hero Scripts", "1. Strength heroes", "Life Stealer" }, "1. Use blink in combo {{Life Stealer}}", "On/Off")
MyHeroScript.OptionHeroLifeStealerUltimate = Menu.AddOption({ "MyScript", "4. Hero Scripts", "1. Strength heroes", "Life Stealer" }, "2 Use Ultimate in combo {{Life Stealer}}", "On/Off")
MyHeroScript.OptionHeroLifeStealerUltimateHP = Menu.AddOption({ "MyScript", "4. Hero Scripts", "1. Strength heroes", "Life Stealer", "3 auto use ultimate with HP percent" }, "1. HP treshold", "HP treshold in %", 5, 50, 5)

MyHeroScript.OptionHeroWeaver = Menu.AddOption({ "MyScript", "4. Hero Scripts", "2. Agility heroes", "Weaver" }, "0. Weaver Combo", "On/Off")
MyHeroScript.OptionHeroWeaverAutoCastUltimate = Menu.AddOption({ "MyScript", "4. Hero Scripts", "2. Agility heroes", "Weaver" }, "1 Use Ultimate in combo {{Weaver}}", "On/Off")
MyHeroScript.OptionHeroWeaverHPPercent = Menu.AddOption({ "MyScript", "4. Hero Scripts", "2. Agility heroes", "Weaver", "2 auto use ultimate with HP percent" }, "1. HP treshold", "HP treshold in %", 5, 50, 5)

MyHeroScript.optionHeroStormSpirit = Menu.AddOption({ "MyScript","4. Hero Scripts", "3. Intelligence heroes", "Storm Spirit" }, "0. Storm Spirit Combo", "Storm Spirit full combo")
MyHeroScript.optionHeroStormSpiritStyle = Menu.AddOption({ "MyScript","4. Hero Scripts", "3. Intelligence heroes", "Storm Spirit" }, "1. combo style {{StormSpirit}}", "Normal Mode or Fast Mode", 0, 1, 1)
MyHeroScript.optionHeroStormSpiritUltRadius = Menu.AddOption({ "MyScript","4. Hero Scripts", "3. Intelligence heroes", "Storm Spirit" }, "2. Ults cursor to Targets", "max cursor for ultimates", 5, 240, 5)

-- menu set values
Menu.SetValueName(MyHeroScript.optionTargetStyle, 0, 'locked target')
Menu.SetValueName(MyHeroScript.optionTargetStyle, 1, 'free target')
Menu.SetValueName(MyHeroScript.optionHeroStormSpiritStyle, 0, 'Normal Mode')
Menu.SetValueName(MyHeroScript.optionHeroStormSpiritStyle, 1, 'Fast Mode')
-- variables
MyHeroScript.LockedTarget = nil
MyHeroScript.myUnitName = nil
MyHeroScript.lastTick = 0
MyHeroScript.lastAttackTime2 = 0
MyHeroScript.lastCastTime = 0
MyHeroScript.LastTarget = nil
MyHeroScript.StormHasAttacked = true

-- to init variables
function MyHeroScript.ResetGlobalVariables()
	MyHeroScript.LockedTarget = nil
	MyHeroScript.myUnitName = nil
	MyHeroScript.lastTick = 0
	MyHeroScript.lastAttackTime2 = 0
	MyHeroScript.lastCastTime = 0
	MyHeroScript.LastTarget = nil
	MyHeroScript.StormHasAttacked = true
end

-- main callback
function MyHeroScript.OnGameStart()
	MyHeroScript.ResetGlobalVariables()
end

function MyHeroScript.OnGameEnd()
	MyHeroScript.ResetGlobalVariables()
end

function MyHeroScript.OnProjectile(projectile)
	if not projectile then return end

	local myHero = Heroes.GetLocal()
	if not myHero then return end

	if NPC.GetUnitName(myHero) == "npc_dota_hero_storm_spirit" then
		if projectile.isAttack and projectile.source == myHero and Entity.IsNPC(projectile.source) then
			MyHeroScript.StormHasAttacked = true
		end
	end

	if projectile.source ~= Heroes.GetLocal() then return end
	if not projectile.isAttack then return end
end

function MyHeroScript.OnUpdate()
	if not Menu.IsEnabled(MyHeroScript.optionEnable) then 
		return 
	end
	
	if not Engine.IsInGame() then
		MyHeroScript.ResetGlobalVariables()
	end
	
	local myHero = Heroes.GetLocal()
	if not myHero then 
		return 
	end
	
	if not Entity.IsAlive(myHero) then 
		return 
	end
	
	if MyHeroScript.myUnitName == nil then
		MyHeroScript.myUnitName = NPC.GetUnitName(myHero)
	end
	
	if NPC.GetUnitName(myHero) ~= MyHeroScript.myUnitName then
		MyHeroScript.myUnitName = NPC.GetUnitName(myHero)
	end
	
	local enemy = MyHeroScript.getComboTarget(myHero)

	if Menu.IsKeyDown(MyHeroScript.optionComboKey) then
		if Menu.GetValue(MyHeroScript.optionTargetStyle) < 1 then
			if MyHeroScript.LockedTarget == nil then
				if enemy then
					MyHeroScript.LockedTarget = enemy
				else
					MyHeroScript.LockedTarget = nil
				end
			end
		else
			if enemy then
				MyHeroScript.LockedTarget = enemy
			else
				MyHeroScript.LockedTarget = nil
			end
		end
	else
		MyHeroScript.LockedTarget = nil
	end

	if MyHeroScript.LockedTarget ~= nil then
		if not Entity.IsAlive(MyHeroScript.LockedTarget) then
			MyHeroScript.LockedTarget = nil
		elseif Entity.IsDormant(MyHeroScript.LockedTarget) then
			MyHeroScript.LockedTarget = nil
		elseif not NPC.IsEntityInRange(myHero, MyHeroScript.LockedTarget, 20000) then
			MyHeroScript.LockedTarget = nil
		end
	end
	
	local comboTarget
	if MyHeroScript.LockedTarget ~= nil then
		comboTarget = MyHeroScript.LockedTarget
	else
		if not Menu.IsKeyDown(MyHeroScript.optionComboKey) then
			comboTarget = enemy
		end
	end
	
	if comboTarget then
		if NPC.GetUnitName(myHero) == "npc_dota_hero_life_stealer" then
			MyHeroScript.LifeStealerCombo(myHero, comboTarget)
		elseif NPC.GetUnitName(myHero) == "npc_dota_hero_weaver" then
			MyHeroScript.WeaverCombo(myHero, comboTarget)
		elseif NPC.GetUnitName(myHero) == "npc_dota_hero_storm_spirit" then
			MyHeroScript.StormSpiritCombo(myHero, comboTarget)
		end
	end

	--if MyHeroScript.LockedTarget == nil then
	--	if Menu.IsEnabled(MyHeroScript.optionMoveToCursor) then
	--		if Menu.IsKeyDown(MyHeroScript.optionComboKey) then
	--			MyHeroScript.GenericMainAttack(myHero, "Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION", nil, Input.GetWorldCursorPos())
	--			return
	--		end
	--	end	
	--end
end

function MyHeroScript.getComboTarget(myHero)

	if not myHero then return end

	local targetingRange = Menu.GetValue(MyHeroScript.optionTargetRange)
	local mousePos = Input.GetWorldCursorPos()

	local enemyTable = Heroes.InRadius(mousePos, targetingRange, Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_ENEMY)
		if #enemyTable < 1 then return end

	local nearestTarget = nil
	local distance = 99999

	for i, v in ipairs(enemyTable) do
		if v and Entity.IsHero(v) then
			if MyHeroScript.targetChecker(v) ~= nil then
				local enemyDist = (Entity.GetAbsOrigin(v) - mousePos):Length2D()
				if enemyDist < distance then
					nearestTarget = v
					distance = enemyDist
				end
			end
		end
	end

	return nearestTarget or nil

end

function MyHeroScript.targetChecker(genericEnemyEntity)

	local myHero = Heroes.GetLocal()
		if not myHero then return end

	if genericEnemyEntity and not NPC.IsDormant(genericEnemyEntity) and not NPC.IsIllusion(genericEnemyEntity) and Entity.GetHealth(genericEnemyEntity) > 0 then

		if Menu.IsEnabled(MyHeroScript.optionTargetCheckAM) then
			if NPC.GetUnitName(genericEnemyEntity) == "npc_dota_hero_antimage" and NPC.HasItem(genericEnemyEntity, "item_ultimate_scepter", true) and NPC.HasModifier(genericEnemyEntity, "modifier_antimage_spell_shield") and Ability.IsReady(NPC.GetAbility(genericEnemyEntity, "antimage_spell_shield")) then
				return
			end
		end
		if Menu.IsEnabled(MyHeroScript.optionTargetCheckLotus) then
			if NPC.HasModifier(genericEnemyEntity, "modifier_item_lotus_orb_active") then
				return
			end
		end
		if Menu.IsEnabled(MyHeroScript.optionTargetCheckBlademail) then
			if NPC.HasModifier(genericEnemyEntity, "modifier_item_blade_mail_reflect") and Entity.GetHealth(Heroes.GetLocal()) <= 0.25 * Entity.GetMaxHealth(Heroes.GetLocal()) then
				return
			end
		end
		if Menu.IsEnabled(MyHeroScript.optionTargetCheckNyx) then
			if NPC.HasModifier(genericEnemyEntity, "modifier_nyx_assassin_spiked_carapace") then
				return
			end
		end
		if Menu.IsEnabled(MyHeroScript.optionTargetCheckUrsa) then
			if NPC.HasModifier(genericEnemyEntity, "modifier_ursa_enrage") then
				return
			end
		end
		if Menu.IsEnabled(MyHeroScript.optionTargetCheckAbbadon) then
			if NPC.HasModifier(genericEnemyEntity, "modifier_abaddon_borrowed_time") then
				return
			end
		end
		if Menu.IsEnabled(MyHeroScript.optionTargetCheckDazzle) then
			if NPC.HasModifier(genericEnemyEntity, "modifier_dazzle_shallow_grave") and NPC.GetUnitName(myHero) ~= "npc_dota_hero_axe" then
				return
			end
		end
		if NPC.HasModifier(genericEnemyEntity, "modifier_skeleton_king_reincarnation_scepter_active") then
			return
		end
		if NPC.HasModifier(genericEnemyEntity, "modifier_winter_wyvern_winters_curse") then
			return
		end

	return genericEnemyEntity
	end	
end

function MyHeroScript.WeaverCombo(myHero, enemy)
	if not Menu.IsEnabled(MyHeroScript.OptionHeroWeaver) then 
		return 
	end
	
	if not NPC.IsEntityInRange(myHero, enemy, 3000) then 
		return 
	end
	
	local weaver_the_swarm = NPC.GetAbility(myHero, "weaver_the_swarm")
	local weaver_shukuchi = NPC.GetAbility(myHero, "weaver_shukuchi")
	local weaver_geminate_attack = NPC.GetAbility(myHero, "weaver_geminate_attack")
	local weaver_time_lapse = NPC.GetAbility(myHero, "weaver_time_lapse")
	
	local myMana = NPC.GetMana(myHero)
	local attackRange = NPC.GetAttackRange(myHero)
	
	if Menu.IsEnabled(MyHeroScript.OptionHeroWeaverAutoCastUltimate) then
		MyHeroScript.WeaverAutoCastUltimate(myHero, myMana, weaver_time_lapse)
	end

	if Menu.IsKeyDown(MyHeroScript.optionComboKey) and Entity.IsAlive(enemy) and not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE) then
		if NPC.HasModifier(enemy, "modifier_item_diffusal_blade_slow") then
			MyHeroScript.GenericMainAttack(myHero, "Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET", enemy, nil)
			return
		else
			if os.clock() > MyHeroScript.lastTick then
				if not NPC.HasModifier(myHero, "modifier_weaver_shukuchi") then 
					if weaver_the_swarm and Ability.IsCastable(weaver_the_swarm, myMana) then
						local SwarmPrediction = Ability.GetCastPoint(weaver_the_swarm) + (Entity.GetAbsOrigin(enemy):__sub(Entity.GetAbsOrigin(myHero)):Length2D() / 1200) + (NetChannel.GetAvgLatency(Enum.Flow.FLOW_OUTGOING) * 2)
						Ability.CastPosition(weaver_the_swarm, MyHeroScript.castLinearPrediction(myHero, enemy, SwarmPrediction))
						MyHeroScript.lastTick = os.clock() + 0.4
						return
					end
				end
				
				if weaver_shukuchi and Ability.IsCastable(weaver_shukuchi, myMana) and not NPC.IsEntityInRange(myHero, enemy, 500) then
					Ability.CastNoTarget(weaver_shukuchi)
					MyHeroScript.lastTick = os.clock() + 0.1
					return
				end
			end
			
			if NPC.HasModifier(myHero, "modifier_weaver_shukuchi") then
				if (NPC.IsHero(enemy) and not Entity.IsSameTeam(myHero, enemy)) and Entity.IsAlive(enemy) then
					if not NPC.IsEntityInRange(myHero, enemy, 175) or (NPC.IsRunning(enemy) and not NPC.IsEntityInRange(myHero, enemy, 175)) then
						MyHeroScript.GenericMainAttack(myHero, "Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION", nil, Entity.GetAbsOrigin(enemy))
						--MyHeroScript.GenericMainAttack(myHero, "Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION", nil, Input.GetWorldCursorPos())
						return
					else
						if attackRange and not NPC.IsRunning(enemy) then
							MyHeroScript.GenericMainAttack(myHero, "Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET", enemy, nil)
							return
						end
					end
				end
			end
			
			MyHeroScript.GenericMainAttack(myHero, "Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET", enemy, nil)
			return
		end
	end
end

function MyHeroScript.WeaverAutoCastUltimate(myHero, myMana, weaver_time_lapse)
	if not myHero then return end
	local myHPperc = (Entity.GetHealth(myHero) / Entity.GetMaxHealth(myHero)) * 100
	local scepter = NPC.GetItem(myHero, "item_ultimate_scepter", true)
	
	local scepterBuffed = false
	
	if NPC.HasItem(myHero, "item_ultimate_scepter", true) or NPC.HasModifier(myHero, "modifier_item_ultimate_scepter_consumed") then
		scepterBuffed = true
	end
	
	if myHPperc > 0 and myHPperc <= Menu.GetValue(MyHeroScript.OptionHeroWeaverHPPercent) then
		for i, v in ipairs(Entity.GetUnitsInRadius(myHero, 750, Enum.TeamType.TEAM_BOTH)) do
			if v and not Entity.IsDormant(v) then
				if weaver_time_lapse and Ability.IsCastable(weaver_time_lapse, myMana) then
					if (NPC.IsHero(v) and not Entity.IsSameTeam(myHero, v)) or not NPC.IsCreep(v) and Entity.IsAlive(v) then
						if scepterBuffed == false then
							Ability.CastNoTarget(weaver_time_lapse)
							return
						else
							Ability.CastTarget(weaver_time_lapse, myHero)
							return
						end
					end
				end
			end
		end
	end
end

function MyHeroScript.StormSpiritCombo(myHero, enemy)
	if not Menu.IsEnabled(MyHeroScript.optionHeroStormSpirit) then 
		return 
	end

	local AbilityRemnant = NPC.GetAbility(myHero, "storm_spirit_static_remnant")
	local AbilityVortex = NPC.GetAbility(myHero, "storm_spirit_electric_vortex")
	local AbilityOverload = NPC.GetAbility(myHero, "storm_spirit_overload")
	local AbilityLightning = NPC.GetAbility(myHero, "storm_spirit_ball_lightning")

	local inUltimate = NPC.HasModifier(myHero, "modifier_storm_spirit_ball_lightning")

	local myMana = NPC.GetMana(myHero)
	local aghanims = NPC.GetItem(myHero, "item_ultimate_scepter", true)
	
	local enemiesHp = (Entity.GetHealth(enemy) / Entity.GetMaxHealth(enemy)) * 100
	local MyManaMissing = NPC.GetMaxMana(myHero) - NPC.GetMana(myHero)
	local GetMyMana = (NPC.GetMana(myHero) / NPC.GetMaxMana(myHero)) * 100

	local orchid = NPC.GetItem(myHero, "item_orchid", true)
	local bloodStone = NPC.GetItem(myHero, "item_bloodstone", true)
	local bloodthorn = NPC.GetItem(myHero, "item_bloodthorn", true)
	local Lienkens = NPC.GetItem(myHero, "item_sphere", true)
	
	--
	
	local IncreaseAttackSpeedTicket = 0
	local CastLightingTicket = 0
	
	if Ability.GetLevel(AbilityLightning) <= 2 then
		CastLightingTicket = 0.6
	else
		CastLightingTicket = 0.4
	end

	if orchid or bloodthorn or bloodStone or Lienkens then
		IncreaseAttackSpeedTicket = 0.2
	end

	CastLightingTicket = CastLightingTicket + IncreaseAttackSpeedTicket
	
	--
	
	local radius 	= Menu.GetValue(MyHeroScript.optionHeroStormSpiritUltRadius) -- 60 seems to be an optimal value.
	local dir 		= Entity.GetAbsRotation(enemy):GetForward():Normalized()
	local front_pos = Entity.GetAbsOrigin(enemy) + dir:Scaled(radius)
	local back_pos 	= Entity.GetAbsOrigin(enemy) - dir:Scaled(radius)
	
	if Menu.GetValue(MyHeroScript.optionHeroStormSpiritStyle) == 0 then
		if Menu.IsKeyDown(MyHeroScript.optionComboKey) and Entity.GetHealth(enemy) > 0 and enemiesHp > 0 then
			--if MyHeroScript.heroCanCastSpells(myHero) == true then
				if not NPC.IsEntityInRange(myHero, enemy, 600) then
					if AbilityLightning and Ability.IsCastable(AbilityLightning, myMana) then
						if os.clock() - MyHeroScript.lastCastTime > CastLightingTicket + NetChannel.GetAvgLatency(Enum.Flow.FLOW_OUTGOING) * 2 then
							Ability.CastPosition(AbilityLightning, Entity.GetAbsOrigin(enemy))
							MyHeroScript.lastCastTime = os.clock()
							return
						end
					end
				else
					if not NPC.HasModifier(myHero, "modifier_storm_spirit_overload") and not NPC.IsSilenced(myHero) then
						local range = Ability.GetCastRange(AbilityVortex)
						if AbilityVortex and Ability.IsCastable(AbilityVortex, myMana) then
							if os.clock() - MyHeroScript.lastCastTime > Ability.GetCastPoint(AbilityVortex) + NetChannel.GetAvgLatency(Enum.Flow.FLOW_OUTGOING) * 2 then
								if aghanims or NPC.HasItem(myHero, "item_ultimate_scepter", true) then
									if NPC.IsEntityInRange(myHero, enemy, range) then
										Ability.CastNoTarget(AbilityVortex)										
										MyHeroScript.lastCastTime = os.clock()
										return
									end
								else
									if not aghanims or not NPC.HasItem(myHero, "item_ultimate_scepter", true) then
										if NPC.IsEntityInRange(myHero, enemy, range) then
											Ability.CastTarget(AbilityVortex, enemy)
											MyHeroScript.lastCastTime = os.clock()
											return
										end
									end
								end
							end
						end	

						if AbilityRemnant and Ability.IsCastable(AbilityRemnant, myMana) then
							if enemy and not NPC.IsIllusion(enemy) and not Entity.IsSameTeam(myHero, enemy) then 
								if NPC.IsEntityInRange(myHero, enemy, 200) then
									if os.clock() - MyHeroScript.lastCastTime > 0.7 + NetChannel.GetAvgLatency(Enum.Flow.FLOW_OUTGOING) * 2 then 
										Ability.CastNoTarget(AbilityRemnant)
										MyHeroScript.lastCastTime = os.clock() 
										return
									end
								end
							end
						end

						if AbilityLightning and Ability.IsCastable(AbilityLightning, myMana) then
							if not NPC.HasModifier(myHero, "modifier_storm_spirit_overload") then
								if os.clock() - MyHeroScript.lastCastTime > CastLightingTicket + NetChannel.GetAvgLatency(Enum.Flow.FLOW_OUTGOING) * 2 then
									if (Entity.GetAbsOrigin(myHero) - front_pos):Length2D() < radius then
										Ability.CastPosition(AbilityLightning, back_pos)
										MyHeroScript.lastCastTime = os.clock()
										return
									else
										Ability.CastPosition(AbilityLightning, front_pos)
										MyHeroScript.lastCastTime = os.clock()
										return
									end
								end
							end
						end
					end
				end
			--end
			
			if NPC.HasModifier(myHero, "modifier_storm_spirit_overload") then
				Player.AttackTarget(Players.GetLocal(), myHero, enemy, false)
			end
		end
	else
		--Log.Write("Fast Mode")
		if Menu.IsKeyDown(MyHeroScript.optionComboKey) and Entity.GetHealth(enemy) > 0 and enemiesHp > 0 then
			if not NPC.IsEntityInRange(myHero, enemy, NPC.GetAttackRange(myHero)) then
				if AbilityLightning and Ability.IsCastable(AbilityLightning, myMana) then
					if MyHeroScript.StormHasAttacked then
						if (Entity.GetAbsOrigin(myHero) - front_pos):Length2D() < radius then
							Ability.CastPosition(AbilityLightning, back_pos)
						else
							Ability.CastPosition(AbilityLightning, front_pos)
						end
						
						MyHeroScript.StormHasAttacked = false
					end
				end
			else
				if not NPC.HasModifier(myHero, "modifier_storm_spirit_overload") then
					local range = Ability.GetCastRange(AbilityVortex)
					if AbilityVortex and Ability.IsCastable(AbilityVortex, myMana) then
						if MyHeroScript.StormHasAttacked then
							if aghanims or NPC.HasItem(myHero, "item_ultimate_scepter", true) or NPC.HasModifier(myHero, "modifier_item_ultimate_scepter_consumed") then
								if NPC.IsEntityInRange(myHero, enemy, range) then
									Ability.CastNoTarget(AbilityVortex)
									return
								end
							else
								if not aghanims or not NPC.HasItem(myHero, "item_ultimate_scepter", true) then
									if NPC.IsEntityInRange(myHero, enemy, range) then
										Ability.CastTarget(AbilityVortex, enemy)
										return
									end
								end
							end
						end	
					end
							
					if AbilityRemnant and Ability.IsCastable(AbilityRemnant, myMana) then
						if enemy and not NPC.IsIllusion(enemy) and not Entity.IsSameTeam(myHero, enemy) then
							if NPC.IsEntityInRange(myHero, enemy, 200) then
								if MyHeroScript.StormHasAttacked then
									Ability.CastNoTarget(AbilityRemnant)
									MyHeroScript.StormHasAttacked = false
									return
								end
							end
						end
					end

					if AbilityLightning and Ability.IsCastable(AbilityLightning, myMana) then
						 if MyHeroScript.StormHasAttacked and (not NPC.IsEntityInRange(myHero, enemy, NPC.GetAttackRange(myHero)) or not NPC.HasModifier(myHero, "modifier_storm_spirit_overload")) then
							if NPC.HasModifier(enemy, "modifier_storm_spirit_electric_vortex_pull") then
									Ability.CastPosition(AbilityLightning, Entity.GetAbsOrigin(myHero))
							elseif (Entity.GetAbsOrigin(myHero) - front_pos):Length2D() < radius then
								Ability.CastPosition(AbilityLightning, back_pos)
							else
								Ability.CastPosition(AbilityLightning, front_pos)
							end

							MyHeroScript.StormHasAttacked = false
						end
					end
				end
			end
			
			Player.AttackTarget(Players.GetLocal(), myHero, enemy, false)
		end
	end
end


function MyHeroScript.LifeStealerCombo(myHero, enemy)
	if not Menu.IsEnabled(MyHeroScript.OptionHeroLifeStealer) then 
		return 
	end
	
	if not NPC.IsEntityInRange(myHero, enemy, 3000) then 
		return 
	end
		
	local life_stealer_rage = NPC.GetAbility(myHero, "life_stealer_rage")
	local life_stealer_open_wounds = NPC.GetAbility(myHero, "life_stealer_open_wounds")
	local life_stealer_infest = NPC.GetAbility(myHero, "life_stealer_infest")
	
	local blink = NPC.GetItem(myHero, "item_blink", true)
	local myMana = NPC.GetMana(myHero)
	
	if Menu.IsEnabled(MyHeroScript.OptionHeroLifeStealerUltimate) then
		MyHeroScript.LifeStealerAutoUseUltimate(myHero, myMana, life_stealer_infest)
	end
	
	if Menu.IsKeyDown(MyHeroScript.optionComboKey) and Entity.IsAlive(enemy) and not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE) then
		if not NPC.IsEntityInRange(myHero, enemy, 500) then
			if Menu.IsEnabled(MyHeroScript.OptionHeroLifeStealerBlink) and blink and Ability.IsReady(blink) and NPC.IsEntityInRange(myHero, enemy, 1200) then
				Ability.CastPosition(blink, Entity.GetAbsOrigin(enemy))
				return
			end
		end
		
		if os.clock() > MyHeroScript.lastTick then
			if life_stealer_open_wounds and Ability.IsCastable(life_stealer_open_wounds, myMana) and NPC.IsEntityInRange(myHero, enemy, Ability.GetCastRange(life_stealer_open_wounds) - 50) then
				Ability.CastTarget(life_stealer_open_wounds, enemy)
				MyHeroScript.lastTick = os.clock() + 0.2
				return
			end

			if life_stealer_rage and Ability.IsCastable(life_stealer_rage, myMana) and NPC.IsEntityInRange(myHero, enemy, 450) then
				Ability.CastNoTarget(life_stealer_rage)
				MyHeroScript.lastTick = os.clock() + 0.1
				return
			end
		end
		
		if NPC.HasModifier(enemy, "modifier_life_stealer_open_wounds") or NPC.HasModifier(myHero, "modifier_life_stealer_rage") then
			if MyHeroScript.SleepReady(0.1) then
				Player.AttackTarget(Players.GetLocal(), myHero, enemy, false)
				MyHeroScript.lastTick = os.clock()
				return
			end
		end
		
		MyHeroScript.GenericMainAttack(myHero, "Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET", enemy, nil)
	end
end

function MyHeroScript.LifeStealerAutoUseUltimate(myHero, myMana, life_stealer_infest)
	if not myHero then return end

	local myHPperc = (Entity.GetHealth(myHero) / Entity.GetMaxHealth(myHero)) * 100

	if myHPperc <= Menu.GetValue(MyHeroScript.OptionHeroLifeStealerUltimateHP) then
		for i, v in ipairs(Entity.GetUnitsInRadius(myHero, 750, Enum.TeamType.TEAM_BOTH)) do
			if v and not Entity.IsDormant(v) then
				if life_stealer_infest and Ability.IsCastable(life_stealer_infest, myMana) then
					if (NPC.IsHero(v) and Entity.IsSameTeam(myHero, v)) or NPC.IsCreep(v) and Entity.IsAlive(v) then
						if not NPC.IsEntityInRange(myHero, v, 150) then
							MyHeroScript.GenericMainAttack(myHero, "Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION", nil, Entity.GetAbsOrigin(v))
							return
						else
							Ability.CastTarget(life_stealer_infest, v)
							return
						end
					end
				end
			end
		end
	end
end

function MyHeroScript.GenericMainAttack(myHero, attackType, target, position)
	if not myHero then return end
	if not target and not position then return end

	--if MyHeroScript.isHeroChannelling(myHero) == true then return end
	--if MyHeroScript.heroCanCastItems(myHero) == false then return end
	--if MyHeroScript.IsInAbilityPhase(myHero) == true then return end
	
	MyHeroScript.GenericAttackIssuer(attackType, target, position, myHero)
end

function MyHeroScript.GenericAttackIssuer(attackType, target, position, npc)
	if not npc then return end
	if not target and not position then return end
	if os.clock() - MyHeroScript.lastAttackTime2 < 0.5 then return end

	if attackType == "Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET" then
		if target ~= nil then
			if target ~= MyHeroScript.LastTarget then
				Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET, target, Vector(0, 0, 0), ability, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, npc)
				MyHeroScript.LastTarget = target
				--MyHeroScript.Debugger(GameRules.GetGameTime(), npc, "attack", "DOTA_UNIT_ORDER_ATTACK_TARGET")
			end
		end
	end

	if attackType == "Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_MOVE" then
		if position ~= nil then
			if not NPC.IsAttacking(npc) or not NPC.IsRunning(npc) then
				if position:__tostring() ~= MyHeroScript.LastTarget then
					Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_MOVE, target, position, ability, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, npc)
					MyHeroScript.LastTarget = position:__tostring()
					--MyHeroScript.Debugger(GameRules.GetGameTime(), npc, "attackMove", "DOTA_UNIT_ORDER_ATTACK_MOVE")
				end
			end
		end
	end

	if attackType == "Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION" then
		if position ~= nil then
			if position:__tostring() ~= MyHeroScript.LastTarget then
				Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION, target, position, ability, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, npc)
				MyHeroScript.LastTarget = position:__tostring()
				--MyHeroScript.Debugger(GameRules.GetGameTime(), npc, "move", "DOTA_UNIT_ORDER_MOVE_TO_POSITION")
			end
		end
	end

	if target ~= nil then
		if target == MyHeroScript.LastTarget then
			if not NPC.IsAttacking(npc) then
				MyHeroScript.LastTarget = nil
				MyHeroScript.lastAttackTime2 = os.clock()
				return
			end
		end
	end

	if position ~= nil then
		if position:__tostring() == MyHeroScript.LastTarget then
			if not NPC.IsRunning(npc) then
				MyHeroScript.LastTarget = nil
				MyHeroScript.lastAttackTime2 = os.clock()
				return
			end
		end
	end
end

function MyHeroScript.SleepReady(sleep)
	if (os.clock() - MyHeroScript.lastTick) >= sleep then
		return true
	end
	
	return false
end

function MyHeroScript.castLinearPrediction(myHero, enemy, adjustmentVariable)
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
		else 
			return enemyOrigin:__add(enemyRotation:Normalized():Scaled(MyHeroScript.GetMoveSpeed(enemy) * adjustmentVariable * (1 - cosGamma)))
		end
	end
end

function MyHeroScript.GetMoveSpeed(enemy)
	if not enemy then return end

	local base_speed = NPC.GetBaseSpeed(enemy)
	local bonus_speed = NPC.GetMoveSpeed(enemy) - NPC.GetBaseSpeed(enemy)
	local modifierHex
    local modSheep = NPC.GetModifier(enemy, "modifier_sheepstick_debuff")
    local modLionVoodoo = NPC.GetModifier(enemy, "modifier_lion_voodoo")
    local modShamanVoodoo = NPC.GetModifier(enemy, "modifier_shadow_shaman_voodoo")

	if modSheep then
		modifierHex = modSheep
	end
	if modLionVoodoo then
		modifierHex = modLionVoodoo
	end
	if modShamanVoodoo then
		modifierHex = modShamanVoodoo
	end

	if modifierHex then
		if math.max(Modifier.GetDieTime(modifierHex) - GameRules.GetGameTime(), 0) > 0 then
			return 140 + bonus_speed
		end
	end

    	if NPC.HasModifier(enemy, "modifier_invoker_ice_wall_slow_debuff") then 
		return 100 
	end

	if NPC.HasModifier(enemy, "modifier_invoker_cold_snap_freeze") or NPC.HasModifier(enemy, "modifier_invoker_cold_snap") then
		return (base_speed + bonus_speed) * 0.5
	end

	if NPC.HasModifier(enemy, "modifier_spirit_breaker_charge_of_darkness") then
		local chargeAbility = NPC.GetAbility(enemy, "spirit_breaker_charge_of_darkness")
		if chargeAbility then
			local specialAbility = NPC.GetAbility(enemy, "special_bonus_unique_spirit_breaker_2")
			if specialAbility then
				 if Ability.GetLevel(specialAbility) < 1 then
					return Ability.GetLevel(chargeAbility) * 50 + 550
				else
					return Ability.GetLevel(chargeAbility) * 50 + 1050
				end
			end
		end
	end
			
    return base_speed + bonus_speed
end

return MyHeroScript