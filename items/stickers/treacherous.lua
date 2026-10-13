local TREACHEROUS = 'hst_treacherous'

-- Jokers on their way out stop counting right
-- away instead of once their dissolve finishes.
local function hst_treacherous_count()
    local count = 0
    for _, joker in ipairs(G.jokers and G.jokers.cards or {}) do
        if joker.ability[TREACHEROUS] and not joker.getting_sliced and not joker.hst_treacherous_sold then
            count = count + 1
        end
    end
    return count
end

function HighStakes.treacherous_factor()
    return 1 + HighStakes.treacherous_rate() * hst_treacherous_count()
end

local hst_treacherous_sell_card_ref = Card.sell_card
function Card:sell_card()
    if self.ability[TREACHEROUS] then self.hst_treacherous_sold = true end
    return hst_treacherous_sell_card_ref(self)
end

-- Whether something holds the round open even once the score beats the
-- requirement. Electric Snow from AIJ is known
local function hst_treacherous_round_held_open()
    if G.GAME.current_round.hands_left < 1 then return false end
    return next(SMODS.find_card("j_aij_electric_snow"))
end

-- Rescales the active Blind's requirement to the Treacherous Jokers held now.
-- The whole requirement is scaled rather than a flat amount added, so changes
-- other effects make to it keep their meaning. The Wall halving it when
-- disabled still halves the Treacherous share, and All in Jest's requirement
-- bookkeeping and Extravaganza's Towering Blaze growth are scaled along with it.
local function hst_treacherous_sync()
    local blind = G.GAME and G.GAME.blind
    if not (blind and blind.in_blind) then return end
    if G.STATE == G.STATES.NEW_ROUND or G.STATE == G.STATES.GAME_OVER then return end

    local applied = blind.hst_treacherous_factor or 1
    local factor = HighStakes.treacherous_factor()
    if factor == applied then return end

    local ratio = factor / applied
    blind.chips = blind.chips * ratio
    blind.chip_text = number_format(blind.chips)
    if blind.aij_original_chips then blind.aij_original_chips = blind.aij_original_chips * ratio end
    if blind.aij_added_chips then blind.aij_added_chips = blind.aij_added_chips * ratio end
    if G.GAME.extv_towering_blaze then
        G.GAME.extv_towering_blaze.added = G.GAME.extv_towering_blaze.added * ratio
    end
    blind.hst_treacherous_factor = factor
    blind:wiggle()
    if factor < applied then blind.hst_treacherous_check_win = true end
end

local function hst_treacherous_check_win()
    local blind = G.GAME and G.GAME.blind
    if not (blind and blind.hst_treacherous_check_win and G.STATE == G.STATES.SELECTING_HAND) then return end
    blind.hst_treacherous_check_win = nil
    G.E_MANAGER:add_event(Event({
        trigger = 'immediate',
        func = function()
            if G.STATE == G.STATES.SELECTING_HAND and G.GAME.blind.in_blind
            and G.GAME.chips - G.GAME.blind.chips >= 0 and not hst_treacherous_round_held_open() then
                G.STATE = G.STATES.NEW_ROUND
                G.STATE_COMPLETE = false
            end
            return true
        end
    }))
end

-- Redraws the Blind select screen's three choices so their requirements
-- match the Treacherous Jokers held, such as after selling one there.
local function hst_treacherous_refresh_blind_select()
    if not (G.blind_select and G.blind_select_opts) then return end
    for _, type in ipairs({'Small', 'Big', 'Boss'}) do
        local opt = G.blind_select_opts[string.lower(type)]
        local par = opt and opt.parent
        if par and par.config.object == opt then
            local offset_y = opt.alignment.offset.y
            opt:remove()
            opt = UIBox{
                T = {par.T.x, 0, 0, 0},
                definition = {n=G.UIT.ROOT, config={align = "cm", colour = G.C.CLEAR}, nodes={
                    UIBox_dyn_container({create_UIBox_blind_choice(type)}, false, get_blind_main_colour(type),
                        type == 'Boss' and mix_colours(G.C.BLACK, get_blind_main_colour(type), 0.8) or nil)
                }},
                config = {align = "bmi", offset = {x = 0, y = offset_y}, major = par, xy_bond = 'Weak'}
            }
            par.config.object = opt
            par.config.object:recalculate()
            opt.parent = par
            G.blind_select_opts[string.lower(type)] = opt
        end
    end
end

local hst_treacherous_game_update_ref = Game.update
function Game:update(dt)
    local ret = hst_treacherous_game_update_ref(self, dt)
    if G.STAGE == G.STAGES.RUN and G.GAME and G.GAME.blind and G.jokers then
        hst_treacherous_sync()
        hst_treacherous_check_win()
        if G.STATE == G.STATES.BLIND_SELECT then
            local factor = HighStakes.treacherous_factor()
            if G.hst_treacherous_shown ~= nil and G.hst_treacherous_shown ~= factor then
                hst_treacherous_refresh_blind_select()
            end
            G.hst_treacherous_shown = factor
        else
            G.hst_treacherous_shown = nil
        end
    end
    return ret
end

-- All in Jest loads after High stakes,
-- so its own set_blind hook wraps this one, and it fills in its
-- bookkeeping before calling down here, so that is in place to be scaled.
local hst_treacherous_set_blind_ref = Blind.set_blind
function Blind:set_blind(blind, reset, silent)
    if blind and not reset then
        self.hst_treacherous_factor = 1
        self.hst_treacherous_check_win = nil
    end
    local ret = hst_treacherous_set_blind_ref(self, blind, reset, silent)
    if blind and not reset then hst_treacherous_sync() end
    return ret
end

local hst_treacherous_blind_save_ref = Blind.save
function Blind:save()
    local blindTable = hst_treacherous_blind_save_ref(self)
    blindTable.hst_treacherous_factor = self.hst_treacherous_factor
    return blindTable
end

local hst_treacherous_blind_load_ref = Blind.load
function Blind:load(blindTable)
    local ret = hst_treacherous_blind_load_ref(self, blindTable)
    self.hst_treacherous_factor = blindTable.hst_treacherous_factor
    -- Saves from before the factor was tracked stored the Joker count instead.
    if not self.hst_treacherous_factor and blindTable.hst_treacherous then
        self.hst_treacherous_factor = 1 + SMODS.Stickers[TREACHEROUS].requirement_rate * blindTable.hst_treacherous
    end
    return ret
end

local treacherous = {
    object_type = "Sticker",
    key = "treacherous",
    atlas = "stickers",
    pos = { x = 3, y = 0 },
    badge_colour = HEX('e77e68'),
    order = 3,
    sets = { Joker = true },
    requirement_rate = 0.2,

    loc_vars = function(self, info_queue, card)
        return { vars = { HighStakes.treacherous_rate() * 100 } }
    end,

    should_apply = function(self, card, center, area, bypass_roll)
        if bypass_roll == nil and not HighStakes.sticker_rolls_in(area) then return false end
        self.rate = HighStakes.sticker_chance('treacherous')
        return SMODS.Sticker.should_apply(self, card, center, area, bypass_roll)
    end,
}

return { name = {"Stickers"}, items = {treacherous} }
