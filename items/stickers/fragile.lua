local FRAGILE = 'hst_fragile'

local function hst_fragile_allowed(card, center)
    local ability = card and card.ability or {}
    return center.perishable_compat and not ability.eternal and not ability.perishable
end

-- Vanilla rolls Eternal and Perishable in create_card AFTER Steamodded's sticker
-- rolls, so Fragile skips that roll and rolls here instead, once it knowns
-- whether either landed.
local hst_fragile_create_card_ref = create_card
function create_card(_type, area, ...)
    local card = hst_fragile_create_card_ref(_type, area, ...)
    if card and card.ability and HighStakes.sticker_rolls_in(area) and hst_fragile_allowed(card, card.config.center) then
        local center = card.config.center
        HighStakes.roll_exclusive_sticker(FRAGILE, card, area, 1
            - HighStakes.vanilla_sticker_chance('eternal', center, area)
            - HighStakes.vanilla_sticker_chance('perishable', center, area),
            HighStakes.sticker_chance('fragile'))
    end
    return card
end

-- Eternal or Perishable gained after creation still has to
-- respect the exclusion, so they refuse a Fragile Joker themselves.
local hst_fragile_set_eternal_ref = Card.set_eternal
function Card:set_eternal(_eternal)
    if _eternal and self.ability[FRAGILE] then return end
    return hst_fragile_set_eternal_ref(self, _eternal)
end

local hst_fragile_set_perishable_ref = Card.set_perishable
function Card:set_perishable(_perishable)
    if _perishable and self.ability[FRAGILE] then return end
    return hst_fragile_set_perishable_ref(self, _perishable)
end

for _, key in ipairs({'eternal', 'perishable'}) do
    local sticker = SMODS.Stickers[key]
    local apply_ref = sticker.apply
    sticker.apply = function(self, card, val)
        if val and card.ability[FRAGILE] then return end
        return apply_ref(self, card, val)
    end
end

local fragile = {
    object_type = "Sticker",
    key = "fragile",
    atlas = "stickers",
    pos = { x = 1, y = 0 },
    badge_colour = HEX('6de768'),
    order = 1,
    sets = { Joker = true },
    odds = 10,

    loc_vars = function(self, info_queue, card)
        local numerator, denominator = SMODS.get_probability_vars(card, 1, HighStakes.fragile_odds(), 'hst_fragile')
        return { vars = { numerator, denominator } }
    end,

    should_apply = function(self, card, center, area, bypass_roll)
        if bypass_roll == nil then return false end
        if not hst_fragile_allowed(card, center) then return false end
        return SMODS.Sticker.should_apply(self, card, center, area, bypass_roll)
    end,

    apply = function(self, card, val)
        if val and card.ability.set == 'Joker' and not hst_fragile_allowed(card, card.config.center) then return end
        SMODS.Sticker.apply(self, card, val)
    end,

    calculate = function(self, card, context)
        if context.end_of_round and not context.repetition and not context.individual
        and G.jokers and card.area == G.jokers and not card.getting_sliced then
            if SMODS.pseudorandom_probability(card, 'hst_fragile', 1, HighStakes.fragile_odds(), 'hst_fragile') then
                SMODS.destroy_cards(card, { destroy_func = function(c) return c:shatter() end })
                return { message = localize('hst_broken_ex'), colour = G.C.RED }
            end
            return { message = localize('k_safe_ex') }
        end
    end,
}

return { name = {"Stickers"}, items = {fragile} }
