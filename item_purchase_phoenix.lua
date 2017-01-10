------------------------------------------------------------
--- AUTHOR: PLATINUM_DOTA2 (Pooya J.)
--- EMAIL ADDRESS: platinum.dota2@gmail.com
------------------------------------------------------------
require( GetScriptDirectory().."/item_purchase_custom" )
Utility = require(GetScriptDirectory().."/Utility")
----------
-- local abilities = {
-- 	"phoenix_icarus_dive"
-- 	"phoenix_icarus_dive_stop"
-- 	"phoenix_fire_spirits"
-- 	"phoenix_launch_fire_spirit"
-- 	"phoenix_sun_ray"
-- 	"phoenix_sun_ray_stop"
-- 	"phoenix_sun_ray_toggle_move"
-- 	"phoenix_sun_ray_toggle_move_empty"
-- 	"phoenix_supernova"
-- }

local npcBot = GetBot();

npcBot.AbilityPriority = {
	"phoenix_icarus_dive",
	"phoenix_sun_ray",
	"phoenix_sun_ray",
	"phoenix_fire_spirits",
	"phoenix_sun_ray",										-- 5
	"phoenix_supernova",
	"phoenix_sun_ray",
	"phoenix_fire_spirits",
	"phoenix_fire_spirits",
	"special_bonus_respawn_reduction_20", -- 10
	"phoenix_fire_spirits",--
	"phoenix_supernova",
	"phoenix_icarus_dive",
	"phoenix_icarus_dive",
	"special_bonus_gold_income_15", --15
	"phoenix_icarus_dive",
	--17
	"phoenix_supernova",--18
  --19
  "special_bonus_spell_amplify_8", -- 20
	"special_bonus_unique_phoenix_1"-- 25
};

npcBot.ItemsToBuy = {
"item_tango",
"item_flask",
-- "item_ward_observer",
"item_clarity",
"item_boots",
"item_magic_stick",
"item_ring_of_regen",
"item_ring_of_protection",
"item_branches",
"item_branches",
"item_circlet",
"item_energy_booster",
"item_ring_of_health",
"item_recipe_aether_lens",
"item_mystic_staff",
"item_platemail",
"item_recipe_shivas_guard",
"item_relic",
"item_recipe_radiance"
};

LevelUp = function()
	item_purchase_custom.LevelUp();
end

ItemPurchaseThink = function()
	item_purchase_custom.ItemPurchaseThink (
		LevelUp
	);
end

function BuybackUsageThink()
	return 0.0;
end