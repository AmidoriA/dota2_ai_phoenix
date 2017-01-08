function GetDesire()
  local npcBot = GetBot();
  return npcBot:GetPushLaneDesire(LANE_BOT);
end