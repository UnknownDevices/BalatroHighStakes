HighStakes = HighStakes or {}

local hst_mod = SMODS.current_mod

HighStakes.has_aij = next(SMODS.find_mod("allinjest")) ~= nil

SMODS.Atlas({key = "modicon", path = "modicon.png", px = 29, py = 29, atlas_table = "ASSET_ATLAS"}):register()
SMODS.Atlas({key = "stickers", path = "stickers.png", px = 71, py = 95, atlas_table = "ASSET_ATLAS"}):register()
SMODS.Atlas({key = "stakes", path = "stakes.png", px = 29, py = 29, atlas_table = "ASSET_ATLAS"}):register()
SMODS.Atlas({key = "stake_stickers", path = "stake_stickers.png", px = 71, py = 95, atlas_table = "ASSET_ATLAS"}):register()

function HighStakes.sticker_chance(name)
    return (hst_mod.config.sticker_chances[name] or 30) / 100
end

function HighStakes.sticker_rolls_in(area)
    return area ~= nil and (area == G.shop_jokers or area == G.pack_cards)
end

function HighStakes.vanilla_sticker_chance(sticker, center, area)
    if not HighStakes.sticker_rolls_in(area) then return 0 end
    if sticker == 'eternal' then
        return (G.GAME.modifiers.enable_eternals_in_shop and center.eternal_compat) and HighStakes.sticker_chance('eternal') or 0
    elseif sticker == 'perishable' then
        return (G.GAME.modifiers.enable_perishables_in_shop and center.perishable_compat) and HighStakes.sticker_chance('perishable') or 0
    end
    return 0
end

function HighStakes.roll_exclusive_sticker(key, card, area, unblocked_chance, chance)
    local sticker = SMODS.Stickers[key]
    if unblocked_chance <= 0 then return end
    if not SMODS.Sticker.should_apply(sticker, card, card.config.center, area, true) then return end
    if sticker.last_roll > 1 - math.min(1, chance / unblocked_chance) then
        sticker:apply(card, true)
    end
end

local hst_init_game_object_ref = Game.init_game_object
function Game:init_game_object()
    local ret = hst_init_game_object_ref(self)
    ret.hst_fragile_odds = SMODS.Stickers.hst_fragile.odds
    ret.hst_treacherous_rate = SMODS.Stickers.hst_treacherous.requirement_rate
    return ret
end

function HighStakes.fragile_odds()
    return G.GAME and G.GAME.hst_fragile_odds or SMODS.Stickers.hst_fragile.odds
end

function HighStakes.treacherous_rate()
    return G.GAME and G.GAME.hst_treacherous_rate or SMODS.Stickers.hst_treacherous.requirement_rate
end

-- Badges are displayed in registration order
local hst_stickers = {}
for _, file in ipairs({
    "items/stickers/heavy.lua",
    "items/stickers/fragile.lua",
    "items/stickers/linked.lua",
    "items/stickers/treacherous.lua",
}) do
    local items = assert(SMODS.load_file(file))()
    for _, item in ipairs(items.items) do
        hst_stickers[#hst_stickers + 1] = item
    end
end
table.sort(hst_stickers, function(a, b) return (a.order or math.huge) < (b.order or math.huge) end)
for _, sticker in ipairs(hst_stickers) do
    SMODS.Sticker(sticker)
end

for _, stake in ipairs(assert(SMODS.load_file("items/stakes.lua"))().items) do
    SMODS.Stake(stake)
end

assert(SMODS.load_file("src/config_tab.lua"))()
assert(SMODS.load_file("src/console_commands.lua"))()
