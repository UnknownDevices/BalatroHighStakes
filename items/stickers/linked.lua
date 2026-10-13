local LINKED = 'hst_linked'

local function hst_linked_allowed(card)
    return not (card and card.ability and card.ability.eternal)
end

-- Linked skips Steamodded's roll and rolls here,
-- once vanilla has rolled Eternal, so that neither
-- lowers the other's chance.
local hst_linked_create_card_ref = create_card
function create_card(_type, area, ...)
    local card = hst_linked_create_card_ref(_type, area, ...)
    if card and card.ability and HighStakes.sticker_rolls_in(area) and hst_linked_allowed(card) then
        HighStakes.roll_exclusive_sticker(LINKED, card, area,
            1 - HighStakes.vanilla_sticker_chance('eternal', card.config.center, area),
            HighStakes.sticker_chance('linked'))
    end
    return card
end

-- Eternal gained after creation still has to refuse a Linked Joker.
local hst_linked_set_eternal_ref = Card.set_eternal
function Card:set_eternal(_eternal)
    if _eternal and self.ability[LINKED] then return end
    return hst_linked_set_eternal_ref(self, _eternal)
end

do
    local sticker = SMODS.Stickers.eternal
    local apply_ref = sticker.apply
    sticker.apply = function(self, card, val)
        if val and card.ability[LINKED] then return end
        return apply_ref(self, card, val)
    end
end

-- Every other Linked Joker still in the Joker area that hasn't already been
-- pulled into a chain.
local function hst_claim_linked_partners(card)
    local partners = {}
    for _, joker in ipairs(G.jokers and G.jokers.cards or {}) do
        if joker ~= card and joker.ability[LINKED] and not joker.hst_link_resolved
        and not joker.getting_sliced and not joker.REMOVED then
            joker.hst_link_resolved = true
            partners[#partners + 1] = joker
        end
    end
    return partners
end

local hst_linked_sell_card_ref = Card.sell_card
function Card:sell_card()
    local partners
    if self.ability[LINKED] and G.jokers and self.area == G.jokers and not self.hst_link_resolved then
        self.hst_link_resolved = true
        partners = hst_claim_linked_partners(self)
    end
    local ret = hst_linked_sell_card_ref(self)
    for _, partner in ipairs(partners or {}) do
        if SMODS.is_eternal(partner, {}) then
            partner.hst_link_resolved = nil
        else
            partner:sell_card()
        end
    end
    return ret
end

-- Steamodded destroys a Joker through one of these three, each returning
-- false when something saved it.
local function hst_linked_after_destroy(card, ret)
    if ret == false then
        card.hst_link_resolved = nil
        return
    end
    if card.getting_sliced and card.ability[LINKED] and not card.hst_link_resolved
    and G.jokers and card.area == G.jokers then
        card.hst_link_resolved = true
        local partners = hst_claim_linked_partners(card)
        if partners[1] then
            local queued = {}
            for _, destroyed in ipairs(SMODS.destroy_cards(partners) or {}) do queued[destroyed] = true end
            -- Eternal partners are skipped by destroy_cards and stay linked.
            for _, partner in ipairs(partners) do
                if not queued[partner] then partner.hst_link_resolved = nil end
            end
        end
    end
end

local hst_linked_start_dissolve_ref = Card.start_dissolve
function Card:start_dissolve(...)
    local ret = hst_linked_start_dissolve_ref(self, ...)
    hst_linked_after_destroy(self, ret)
    return ret
end

local hst_linked_shatter_ref = Card.shatter
function Card:shatter(...)
    local ret = hst_linked_shatter_ref(self, ...)
    hst_linked_after_destroy(self, ret)
    return ret
end

local hst_linked_pinch_and_remove_ref = SMODS.pinch_and_remove
function SMODS.pinch_and_remove(card, ...)
    local ret = hst_linked_pinch_and_remove_ref(card, ...)
    hst_linked_after_destroy(card, ret)
    return ret
end

local linked = {
    object_type = "Sticker",
    key = "linked",
    atlas = "stickers",
    pos = { x = 2, y = 0 },
    badge_colour = HEX('a868e7'),
    order = 4,
    sets = { Joker = true },

    should_apply = function(self, card, center, area, bypass_roll)
        if bypass_roll == nil then return false end
        if not hst_linked_allowed(card) then return false end
        return SMODS.Sticker.should_apply(self, card, center, area, bypass_roll)
    end,

    apply = function(self, card, val)
        if val and not hst_linked_allowed(card) then return end
        SMODS.Sticker.apply(self, card, val)
    end,
}

return { name = {"Stickers"}, items = {linked} }
