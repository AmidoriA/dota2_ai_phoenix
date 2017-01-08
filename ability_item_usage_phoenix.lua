Utility = require(GetScriptDirectory().."/Utility")
DiveRetreating = false
DiveStartLocation = nil
SunRayUnitTarget = nil

function AbilityUsageThink()
  local npcBot = GetBot();


  -- min = math.floor(DotaTime() / 60)
  -- sec = DotaTime() % 60
  -- local debug_msg = ""
  -- debug_msg = "Mode: "..Utility.BOT_MODE_STRING(npcBot:GetActiveMode());
  -- print(debug_msg)
  -- npcBot:Action_Chat(debug_msg, false)

  -- debug_msg = "Desire: "..npcBot:GetActiveModeDesire();
  -- print(debug_msg)
  -- npcBot:Action_Chat(debug_msg, false)

  -- Check if we're already using an ability
  if ( npcBot:IsUsingAbility() ) then return end;

  abilitySunRay = npcBot:GetAbilityByName( "phoenix_sun_ray" );
  
  abilitySupernova = npcBot:GetAbilityByName( "phoenix_supernova" );
  abilityIcarusDive = npcBot:GetAbilityByName( "phoenix_icarus_dive" );
  abilityIcarusDiveStop = npcBot:GetAbilityByName( "phoenix_icarus_dive_stop" );
  abilityFireSpirits = npcBot:GetAbilityByName( "phoenix_fire_spirits" );
  abilityLaunchFireSpirits = npcBot:GetAbilityByName( "phoenix_launch_fire_spirits" );

  if abilitySunRay:IsActivated() and SunRayUnitTarget ~= nil then
    print (abilitySunRay:IsActivated())
    npcBot:Action_MoveToLocation(SunRayUnitTarget:GetLocation());
  end

  -- Consider using each ability
  castSunRayDesire, castSunRayTarget, SunRayUnitTarget = ConsiderSunRay();
  -- castDiveRetreatDesire, castDiveRetreatTarget = ConsiderDiveRetreat();
  -- castDiveRetreatDesire = 0;
  castSupernovaDesire = ConsiderSupernova();
  -- castSunRayStopDesire = ConsiderSunRayStop();
  -- castDiveRetreatStopDesire = ConsiderDiveRetreatStop();
  -- castDiveRetreatStopDesire = 0;
  comboDesire, comboLocation = ConsiderCombo();
  castFireSpiritsDesire = ConsiderFireSpirits();
  castLaunchFireSpiritsDesire, location = ConsiderLaunchFireSpirits();

  local highestDesire = 0;
  local desiredSkill = "";

  if ( comboDesire > highestDesire) then
    highestDesire = comboDesire;
    desiredSkill = "combo";
  end

  -- if ( castDiveRetreatStopDesire > highestDesire) then
  --   highestDesire = castDiveRetreatStopDesire;
  --   desiredSkill = "phoenix_icarus_dive_retreat_stop";
  -- end

  -- if ( castDiveRetreatDesire > highestDesire) then
  --   highestDesire = castDiveRetreatDesire;
  --   desiredSkill = "phoenix_icarus_dive_retreat";
  -- end

  -- if ( castSunRayStopDesire > highestDesire) then
  --   highestDesire = castSunRayStopDesire;
  --   desiredSkill = "phoenix_sun_ray_stop";
  -- end

  if ( castSunRayDesire > highestDesire) then
    highestDesire = castSunRayDesire;
    desiredSkill = "phoenix_sun_ray";
  end

  if ( castSupernovaDesire > highestDesire) then
    highestDesire = castSupernovaDesire;
    desiredSkill = "phoenix_supernova";
  end

  if ( castFireSpiritsDesire > highestDesire) then
    highestDesire = castFireSpiritsDesire;
    desiredSkill = "phoenix_fire_spirits";
  end

  if highestDesire == 0 then return;
  elseif desiredSkill == "phoenix_sun_ray" then 
    npcBot:Action_UseAbilityOnLocation( abilitySunRay, castSunRayTarget );
  elseif desiredSkill == "phoenix_icarus_dive_retreat" then 
    IcarusDiveRetreat( castDiveRetreatTarget );
  elseif desiredSkill == "phoenix_supernova" then
    npcBot:Action_UseAbility( abilitySupernova );
  elseif desiredSkill == "phoenix_icarus_dive_retreat_stop" then
    DiveRetreating = false
    DiveStartLocation = nil
    npcBot:Action_UseAbility( abilityIcarusDiveStop );
  elseif desiredSkill == "phoenix_fire_spirits" then
    npcBot:Action_UseAbility( abilityFireSpirits );
  elseif desiredSkill == "phoenix_sun_ray_stop" then
    npcBot:Action_UseAbility( abilitySunRayStop );
  elseif desiredSkill == "combo" then
    npcBot:Action_Chat("combo", false);
    UseCombo(comboLocation);
  end 
end

function ConsiderSunRay()
  local npcBot = GetBot();

  -- Make sure it's castable
  if not abilitySunRay:IsFullyCastable() 
  then 
    return BOT_ACTION_DESIRE_NONE, 0;
  end

  -- if abilitySunRay:GetLevel() < 2 then
  --   return BOT_ACTION_DESIRE_NONE, 0;
  -- end

  -- Get some of its values
  local nCastRange = 1300;

  -- Find vulnerable enemy 
  local WeakestEnemy = nil
  local WeakestHealth = 10000

  WeakestEnemy, WeakestHealth = Utility.GetWeakestHero(nCastRange)

  if WeakestEnemy == nil then
    return BOT_ACTION_DESIRE_NONE, 0;
  end

  return BOT_ACTION_DESIRE_MODERATE, WeakestEnemy:GetLocation(), WeakestEnemy;
end

function ConsiderSupernova()
  local npcBot = GetBot();

  if not abilitySupernova:IsFullyCastable() then 
    return BOT_ACTION_DESIRE_NONE;
  end

  if npcBot:GetActiveMode() == BOT_MODE_RETREAT then
    return BOT_ACTION_DESIRE_NONE;
  end

  -- local radius = abilitySupernova:GetSpecialValueInt("aura_radius");
  local radius = 1000;
  local enemies = npcBot:GetNearbyHeroes(radius, true, BOT_MODE_NONE);
  local teammate = npcBot:GetNearbyHeroes(radius, false, BOT_MODE_NONE);

  if #teammate >= 2 and #enemies >= 2 then
    return BOT_ACTION_DESIRE_MODERATE;
  end

  return BOT_ACTION_DESIRE_NONE;
end



function ConsiderDiveRetreat()
  if GameTime() < 20 then
    return BOT_ACTION_DESIRE_NONE, 0;
  end

  local npcBot = GetBot();
  if not abilityIcarusDive:IsFullyCastable() then 
    return BOT_ACTION_DESIRE_NONE, 0;
  end

  local mode = npcBot:GetActiveMode()
  local modeDesire = npcBot:GetActiveModeDesire()

  if mode ~= BOT_MODE_RETREAT then
    return BOT_ACTION_DESIRE_NONE, 0;
  end

  -- Not dive if not recently damaged or have health more than 50%
  if not npcBot:WasRecentlyDamagedByAnyHero(200) or (npcBot:GetHealth() * 100 / npcBot:GetMaxHealth() < 50) then
    return BOT_ACTION_DESIRE_NONE, 0;
  end


  local location = Vector(0, 0)
  if GetTeam() == TEAM_RADIANT then
    location = Utility.Locations["RadiantBase"]
  else
    location = Utility.Locations["DireBase"]
  end

  npcBot:Action_Chat("ConsiderDiveRetreat: "..Utility.BOT_MODE_STRING(mode), false);
  npcBot:Action_Chat("Desire: "..modeDesire, false);
  return BOT_ACTION_DESIRE_HIGH, location
end

function IcarusDiveRetreat(target)
  local npcBot = GetBot();
  DiveStartLocation = npcBot:GetLocation();
  DiveRetreating = true
  npcBot:Action_UseAbilityOnLocation( abilityIcarusDive, target );
  return true
end

function ConsiderCombo()
  local npcBot = GetBot();
  if not IsComboReady() then
    return BOT_ACTION_DESIRE_NONE, 0;
  end

  local radius = 1500;
  local enemies = npcBot:GetNearbyHeroes(radius, true, BOT_MODE_NONE);
  local teammate = npcBot:GetNearbyHeroes(radius, false, BOT_MODE_NONE);

  if #teammate < 2 or #enemies < 2 then
    return BOT_ACTION_DESIRE_NONE, 0;
  end

  local units = {}
  for k,v in pairs(enemies) do table.insert(units, v) end
  for k,v in pairs(teammate) do table.insert(units, v) end

  local location = Utility.GetCenter(units);
  return BOT_ACTION_DESIRE_MODERATE, location;
end

function IsComboReady()
  local npcBot = GetBot();
  return abilitySupernova:IsFullyCastable() and abilityIcarusDive:IsFullyCastable();
end

function  UseCombo(target)
  local npcBot = GetBot();
  npcBot:Action_UseAbilityOnLocation( abilityIcarusDive, target );
end

function ConsiderFireSpirits()
  local npcBot = GetBot();
  if npcBot:GetMana() < 300 then
    return BOT_ACTION_DESIRE_NONE;
  end

  if npcBot:GetHealth() < 500 then
    return BOT_ACTION_DESIRE_NONE;
  end

  if not abilityFireSpirits:IsFullyCastable() then
    return BOT_ACTION_DESIRE_NONE;
  end

  if abilityFireSpirits:IsHidden() then
    return BOT_ACTION_DESIRE_NONE;
  end

  local enemies = npcBot:GetNearbyHeroes(1500, true, BOT_MODE_NONE);
  if #enemies <= 1 then
    return BOT_ACTION_DESIRE_NONE;
  end

  return BOT_ACTION_DESIRE_MODERATE;
end

function ConsiderLaunchFireSpirits()
  local npcBot = GetBot();
  if abilityLaunchFireSpirits:IsHidden() then
    return BOT_ACTION_DESIRE_NONE;
  end

  local enemies = npcBot:GetNearbyHeroes(1500, true, BOT_MODE_NONE);
  for k,v in pairs(enemies) do
    if not v:HasModifier("modifier_phoenix_fire_spirit_burn") then
      return BOT_ACTION_DESIRE_HIGH, v:GetLocation();
    end
  end

  return BOT_ACTION_DESIRE_NONE;
end