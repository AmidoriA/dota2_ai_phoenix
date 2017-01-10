Utility = require(GetScriptDirectory().."/Utility")
DiveRetreating = false
DiveStartLocation = nil
SunRayUnitTarget = nil

function AbilityUsageThink()
  local npcBot = GetBot();

  if npcBot.initAttr == false or npcBot.initAttr == nil then
    initAttr();
  end

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

  -- print(npcBot.alias);

  abilitySunRay = npcBot:GetAbilityByName( "phoenix_sun_ray" );
  abilitySunRayStop = npcBot:GetAbilityByName( "phoenix_sun_ray_stop" );
  abilitySupernova = npcBot:GetAbilityByName( "phoenix_supernova" );
  abilityIcarusDive = npcBot:GetAbilityByName( "phoenix_icarus_dive" );
  abilityIcarusDiveStop = npcBot:GetAbilityByName( "phoenix_icarus_dive_stop" );
  abilityFireSpirits = npcBot:GetAbilityByName( "phoenix_fire_spirits" );
  abilityLaunchFireSpirits = npcBot:GetAbilityByName( "phoenix_launch_fire_spirit" );

  if abilitySunRay:IsActivated() and SunRayUnitTarget ~= nil and not abilitySunRayStop:IsHidden() then
    return SunRayFollowTarget();
  end

  -- if ( npcBot:IsUsingAbility() ) then return end;

  -- Consider using each ability
  castSunRayDesire, castSunRayTarget, SunRayUnitTarget = ConsiderSunRay();
  castSupernovaDesire = ConsiderSupernova();
  castDiveChasingDesire, chasingLocation = ConsiderChasing();
  comboDesire, comboLocation = ConsiderCombo();
  castFireSpiritsDesire = ConsiderFireSpirits();
  castLaunchFireSpiritsDesire, fireSpiritLocations = ConsiderLaunchFireSpirits();

  -- fire spirit can cast during other skill. Not need to be a candidate
  if castLaunchFireSpiritsDesire ~= BOT_ACTION_DESIRE_NONE then
    for k,v in pairs(fireSpiritLocations) do
      npcBot:Action_UseAbilityOnLocation( abilityLaunchFireSpirits, v );
      npcBot:Action_Chat("Launch!!!", true);
    end
  end

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

  if ( castDiveChasingDesire > highestDesire) then
    highestDesire = castDiveChasingDesire;
    desiredSkill = "phoenix_dive_chasing";
  end

  if ( castLaunchFireSpiritsDesire > highestDesire) then
    highestDesire = castLaunchFireSpiritsDesire;
    desiredSkill = "phoenix_launch_fire_spirit";
  end

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
  elseif desiredSkill == "phoenix_dive_chasing" then 
    npcBot:DiveToLocation(chasingLocation);
    npcBot:Action_Chat("Dive chasing someone");
  elseif desiredSkill == "phoenix_sun_ray" then 
    npcBot:Action_UseAbilityOnLocation( abilitySunRay, castSunRayTarget );
    npcBot:SetTarget(SunRayUnitTarget);
  elseif desiredSkill == "phoenix_supernova" then
    npcBot:Action_UseAbility( abilitySupernova );
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

  -- local radius = abilitySupernova:GetSpecialValueInt("aura_radius");
  local radius = 1000;
  local enemies = npcBot:GetNearbyHeroes(radius, true, BOT_MODE_NONE);
  local teammate = npcBot:GetNearbyHeroes(radius, false, BOT_MODE_NONE);

  if #teammate >= 2 and #enemies >= 2 then
    return BOT_ACTION_DESIRE_VERYHIGH ;
  end

  return BOT_ACTION_DESIRE_NONE;
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

function UseCombo(target)
  local npcBot = GetBot();
  npcBot:DiveToLocation(target);
end

function ConsiderFireSpirits()
  local npcBot = GetBot();
  if IsComboReady() and npcBot:GetMana() < 300 then
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

  local locations = {}

  npcBot:Action_Chat("ConsiderLaunchFireSpirits", true);
  local enemies = npcBot:GetNearbyHeroes(1500, true, BOT_MODE_NONE);
  for k,v in pairs(enemies) do
    table.insert(locations, v:GetLocation());
  --   -- if not v:HasModifier("modifier_phoenix_fire_spirit_burn") then
  --   -- end
  end
  return BOT_ACTION_DESIRE_MODERATE, locations;
end

function SunRayFollowTarget()
  local npcBot = GetBot();
  local idealDistance = 900;
  local ignoreDistance = 1500;
  print ('Sunray target');

  if SunRayUnitTarget == nil then
    return false;
  end

  if not SunRayUnitTarget:CanBeSeen() or npcBot:GetUnitToUnitDistance(SunRayUnitTarget) > ignoreDistance then
    -- find other target
    local weakestEnemy, hp = Utility.GetWeakestHero(1000);
    if weakestEnemy == nil then
      SunRayUnitTarget = nil;
      npcBot:Action_UseAbility(abilitySunRayStop);
    end

    SunRayUnitTarget = weakestEnemy;
  end

  targetLocation = SunRayUnitTarget:GetLocation();
  npcBot:Action_MoveToLocation(targetLocation);
  local abilitySunRayToggleMove = npcBot:GetAbilityByName( "phoenix_sun_ray_toggle_move" );

  if GetUnitToLocationDistance(npcBot, targetLocation) <= idealDistance then
    if abilitySunRayToggleMove:IsActivated() then
       npcBot:Action_UseAbility(abilitySunRayToggleMove);
     end
    return false;
  end

  npcBot:Action_UseAbility(abilitySunRayToggleMove);

  -- if GetUnitToLocationDistance(npcBot, targetLocation) > idealDistance then
  --   if not abilitySunRayToggleMove:IsActivated() then
  --     npcBot:Action_UseAbility(abilitySunRayToggleMove);
  --   end
  -- elseif GetUnitToLocationDistance(npcBot, targetLocation) <= idealDistance then
  --   if abilitySunRayToggleMove:IsActivated() then
  --     npcBot:Action_UseAbility(abilitySunRayToggleMove);
  --   end
  -- end

  return true;
end

function ConsiderChasing()
  local npcBot = GetBot();
  local idealDistance = 1200;
  local notCareDistance = 3000;

  if not abilityIcarusDive:IsFullyCastable() then
    return BOT_ACTION_DESIRE_NONE;
  end

  if abilitySunRay:IsActivated() then 
    return BOT_ACTION_DESIRE_NONE;
  end

  local target = npcBot:GetTarget();
  if target == nil then
    print ("target == nil");
    return BOT_ACTION_DESIRE_NONE;
  end

  if npcBot:GetUnitToUnitDistance(target) > notCareDistance then
    return BOT_ACTION_DESIRE_NONE;
  end

  if npcBot:GetUnitToUnitDistance(target) < idealDistance then
    return BOT_ACTION_DESIRE_NONE;
  end

  return BOT_ACTION_DESIRE_MODERATE, target:GetLocation();
end

function initAttr() 
  local npcBot = GetBot();
  local HeroSettings = require( GetScriptDirectory().."/Hero/phoenix");
  for k,v in pairs(HeroSettings) do
    npcBot[k] = v;
  end
  npcBot.initAttr = true;
end

function ItemUsageThink()
  Utility.UseItems();
end