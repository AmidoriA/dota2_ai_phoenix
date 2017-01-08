-- Utility = require(GetScriptDirectory().."/Utility")

function GetDesire()
  -- local npcBot = GetBot();
  -- local abilitySupernova = npcBot:GetAbilityByName( "phoenix_supernova" );

  -- if npcBot:GetTarget() == nil then
  --   return 0;
  -- end

  -- if Utility.GetHeroLevel() > 6 and abilitySupernova:IsFullyCastable() then
  --   return 0.6;
  -- end

  -- local abilitySunRay = npcBot:GetAbilityByName( "phoenix_sun_ray" );
  -- local abilitySunRayStop = npcBot:GetAbilityByName( "phoenix_sun_ray_stop" );

  -- if abilitySunRay:IsActivated() and (not abilitySunRayStop:IsHidden()) then
  --   return 0.05;
  -- end

  return 0.01;
end