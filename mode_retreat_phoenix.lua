require( GetScriptDirectory().."/mode_retreat_generic" )
Utility = require(GetScriptDirectory().."/Utility")

DiveStartLocation = nil

function OnStart()
  mode_generic_retreat.OnStart();
  local npcBot = GetBot();
  npcBot:Action_Chat("Run!!", true);
end

function OnEnd()
  mode_generic_retreat.OnEnd();
end

function GetDesire()
  local radius = 1000;
  local npcBot = GetBot();
  local enemies = npcBot:GetNearbyHeroes(radius, true, BOT_MODE_NONE);
  local teammate = npcBot:GetNearbyHeroes(radius, false, BOT_MODE_NONE);


  local desire = mode_generic_retreat.GetDesire();
  if #teammate <= 2 and #enemies >= 3 then
    desire = BOT_ACTION_DESIRE_MODERATE;
  end
  -- print ("Phoenix desire run: "..desire);
  -- print ("Phoenix active mode: "..Utility.BOT_MODE_STRING(npcBot:GetActiveMode()));
  -- print ("Phoenix desire mode: "..npcBot:GetActiveModeDesire());
  -- if desire > 0 then
  -- end

  return desire;
end

function Think()
  print ("Phoenix desire run think");
  local npcBot = GetBot();

  if npcBot:GetHealth() == 0 then
    print ("Phoenix is dead");
    return false;
  end

  willDive, diveLocation = ConsiderDiveRetreat();
  willDiveStop = ConsiderDiveRetreatStop();
  castSunRayStopDesire = ConsiderSunRayStop();
  castSupernovaDesire = ConsiderSupernova();
  -- abilityIcarusDive = npcBot:GetAbilityByName( "phoenix_icarus_dive" );
  local abilityIcarusDiveStop = npcBot:GetAbilityByName( "phoenix_icarus_dive_stop" );
  local abilitySunRayStop = npcBot:GetAbilityByName( "phoenix_sun_ray_stop" );
  local abilitySupernova = npcBot:GetAbilityByName( "phoenix_supernova" );

  if castSunRayStopDesire > BOT_ACTION_DESIRE_NONE then
    npcBot:Action_Chat("Stopping SunRay", false);
    print("Stopping SunRay");
    npcBot:Action_UseAbility( abilitySunRayStop );
  end

  if willDive > BOT_ACTION_DESIRE_NONE then
    print ("will dive: "..willDive);
    IcarusDiveRetreat(diveLocation);
  end

  if castSupernovaDesire > BOT_ACTION_DESIRE_NONE then
    npcBot:Action_UseAbility( abilitySupernova );
  end

  if willDiveStop > BOT_ACTION_DESIRE_NONE then
    DiveStartLocation = nil
    npcBot:Action_Chat("Stopping Dive", false);
    npcBot:Action_UseAbility( abilityIcarusDiveStop );
  end


  mode_generic_retreat.Think();
end

function ConsiderSunRayStop()
  local npcBot = GetBot();
  local abilitySunRayStop = npcBot:GetAbilityByName( "phoenix_sun_ray_stop" );
  local abilitySunRay     = npcBot:GetAbilityByName( "phoenix_sun_ray" );

  if abilitySunRayStop:IsHidden() then 
    return BOT_ACTION_DESIRE_NONE;
  end

  if not abilitySunRayStop:IsFullyCastable() then 
    return BOT_ACTION_DESIRE_NONE;
  end

  if not abilitySunRay:IsActivated() then 
    return BOT_ACTION_DESIRE_NONE;
  end

  local desire = npcBot:GetActiveModeDesire();
  npcBot:Action_Chat("Stop Sunray: "..desire, false);

  return BOT_MODE_DESIRE_HIGH;
end

function ConsiderSupernova()
  local npcBot = GetBot();
  local radius = 1000;
  local abilitySupernova = npcBot:GetAbilityByName( "phoenix_supernova" );
  if not abilitySupernova:IsFullyCastable() then
    return BOT_ACTION_DESIRE_NONE;
  end

  local enemies = npcBot:GetNearbyHeroes(radius, true, BOT_MODE_NONE);
  if #enemies ~= 1 then
    return BOT_ACTION_DESIRE_NONE;
  end

  local enemyHealthPercentage = enemies[1]:GetHealth() * 100.0 / enemies[1]:GetMaxHealth();
  if enemyHealthPercentage < 30 or enemies[1]:GetHealth() < 300 then
    return BOT_ACTION_DESIRE_MODERATE;
  end

  local healthPercentage = npcBot:GetHealth() * 100.0 / npcBot:GetMaxHealth();
  if healthPercentage > 30.0 then
    return BOT_ACTION_DESIRE_NONE;
  end

  return BOT_ACTION_DESIRE_MODERATE;
end

function ConsiderDiveRetreat()
  print ("ConsiderDiveRetreat");
  local npcBot = GetBot();
  if npcBot:DistanceFromFountain() < 500 then
    return BOT_ACTION_DESIRE_NONE, 0
  end

  local abilityIcarusDive = npcBot:GetAbilityByName( "phoenix_icarus_dive" );
  if GameTime() < 20 then
    return BOT_ACTION_DESIRE_NONE, 0;
  end

  if not abilityIcarusDive:IsFullyCastable() then
    print ("Cannot Dive, not IsFullyCastable()");
    return BOT_ACTION_DESIRE_NONE, 0;
  end

  local mode = npcBot:GetActiveMode();
  local modeDesire = npcBot:GetActiveModeDesire();

  -- if mode ~= BOT_MODE_RETREAT then
  --   return BOT_ACTION_DESIRE_NONE, 0;
  -- end

  -- Not dive if not recently damaged or have health more than 50%
  -- if not npcBot:WasRecentlyDamagedByAnyHero(200) or (npcBot:GetHealth() * 100 / npcBot:GetMaxHealth() < 50) then
  --   return BOT_ACTION_DESIRE_NONE, 0;
  -- end


  local location = Vector(0, 0);
  if GetTeam() == TEAM_RADIANT then
    location = Utility.Locations["RadiantBase"]
  else
    location = Utility.Locations["DireBase"]
  end

  npcBot:Action_Chat("ConsiderDiveRetreat: "..Utility.BOT_MODE_STRING(mode), true);
  npcBot:Action_Chat("Desire: "..modeDesire, true);
  return BOT_ACTION_DESIRE_HIGH, location
end

function IcarusDiveRetreat(target)
  print ("Diving!!");
  local npcBot = GetBot();
  local abilityIcarusDive = npcBot:GetAbilityByName( "phoenix_icarus_dive" );
  DiveStartLocation = npcBot:GetLocation();
  npcBot:Action_UseAbilityOnLocation( abilityIcarusDive, target );
  return true
end

function ConsiderDiveRetreatStop()
  local npcBot = GetBot();
  local abilityIcarusDiveStop = npcBot:GetAbilityByName( "phoenix_icarus_dive_stop" );
  
  if abilityIcarusDiveStop:IsHidden() then 
    return BOT_ACTION_DESIRE_NONE;
  end

  -- if DiveRetreating ~= true then
  --   return BOT_ACTION_DESIRE_NONE;
  -- end

  -- if not (npcBot:GetActiveMode() == BOT_MODE_RETREAT) then
  --   return BOT_ACTION_DESIRE_NONE;
  -- end

  -- if not abilityIcarusDive:IsActivated() then
  --   return BOT_ACTION_DESIRE_NONE;
  -- end

  if DiveStartLocation == nil then
    npcBot:Action_Chat("DiveStartLocation == nil. BUG!!", false);
    return BOT_ACTION_DESIRE_NONE;
  end

  local distance = Utility.GetDistance(npcBot:GetLocation(), DiveStartLocation);
  print("Distance: "..distance);
  if distance > 1000 then
    return BOT_ACTION_DESIRE_ABSOLUTE;
  end
  return BOT_ACTION_DESIRE_NONE;
end