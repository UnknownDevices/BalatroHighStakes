local mod = SMODS.current_mod

HighStakes.stakes = {
    { key = 'gray', sticker = 'hst_heavy', colour = '7d8597' },
    { key = 'brown', colour = '8b5a3c', needs_aij = true },
    { key = 'pink', sticker = 'hst_linked', colour = 'e86fa8' },
    { key = 'teal', sticker = 'hst_fragile', colour = '1ac0c6',
        vars = function() return { 1, SMODS.Stickers.hst_fragile.odds } end },
    { key = 'platinum', sticker = 'hst_treacherous', colour = 'a6bde3', shiny = true,
        vars = function() return { SMODS.Stickers.hst_treacherous.requirement_rate * 100 } end },
}

function HighStakes.stake_name(def)
    return localize { type = 'name_text', set = 'Stake', key = 'stake_hst_' .. def.key }
end

function HighStakes.stake_text(def)
    local text = (G.localization.descriptions.Stake['stake_hst_' .. def.key] or {}).text or {}
    local effect, rest = {}, {}
    for _, line in ipairs(text) do
        if #rest == 0 and not line:find('^{C:inactive') and not line:find('^{s:') then
            effect[#effect + 1] = line
        else
            rest[#rest + 1] = line
        end
    end
    return effect, rest
end

function HighStakes.stake_available(def)
    return not def.needs_aij or HighStakes.has_aij
end

function HighStakes.blue_stake_pink()
    return mod.config.blue_stake_pink and mod.config.show_pink_stake ~= false
end

function HighStakes.stake_shown(def)
    if def.key == 'pink' and HighStakes.blue_stake_pink() then return false end
    return HighStakes.stake_available(def) and mod.config['show_' .. def.key .. '_stake'] ~= false
end

local function hst_sticker_tooltip(key)
    local sticker = SMODS.Stickers[key]
    local vars = {}
    if key == 'hst_fragile' then
        vars = { 1, sticker.odds }
    elseif key == 'hst_treacherous' then
        vars = { sticker.requirement_rate * 100 }
    elseif sticker and sticker.loc_vars then
        vars = (sticker:loc_vars({}, nil) or {}).vars or {}
    end
    return { set = 'Other', key = key, vars = vars }
end

local function hst_second_pit_blind_ante()
    if not G.GAME.modifiers.hst_second_pit_blind then return false end
    local ante = G.GAME.round_resets.ante
    local showdown = ante % G.GAME.win_ante == 0 and ante >= 2
    return ante == G.GAME.hst_second_pit_blind_ante and not showdown
end

if HighStakes.has_aij then
    G.E_MANAGER:add_event(Event({
        func = function()
            local hst_force_pit_blind_ref = All_in_Jest.force_pit_blind
            function All_in_Jest.force_pit_blind()
                return hst_force_pit_blind_ref() or hst_second_pit_blind_ante()
            end

            local hst_pit_blinds_in_play_ref = All_in_Jest.pit_blinds_in_play
            function All_in_Jest.pit_blinds_in_play()
                return hst_pit_blinds_in_play_ref() or hst_second_pit_blind_ante()
            end
            return true
        end
    }))

    local hst_reset_game_globals_ref = mod.reset_game_globals
    mod.reset_game_globals = function(run_start)
        if hst_reset_game_globals_ref then hst_reset_game_globals_ref(run_start) end
        if run_start then
            G.GAME.hst_second_pit_blind_ante = pseudorandom_element({ 6, 7 }, pseudoseed('hst_second_pit_blind'))
        end
    end
end

-- All in Jest's own Blue Stake rework is kept
-- alongside our own rework if both are on.
if HighStakes.blue_stake_pink() then
    local pink
    for _, def in ipairs(HighStakes.stakes) do
        if def.key == 'pink' then pink = def end
    end

    local function hst_aij_blue_stake_rework()
        return HighStakes.has_aij and All_in_Jest.config.blue_stake_rework
    end

    G.E_MANAGER:add_event(Event({
        func = function()
            local blue = G.P_STAKES.stake_blue
            blue.modifiers = function()
                G.GAME.modifiers['enable_' .. pink.sticker] = true
            end
            blue.loc_vars = function(self, info_queue)
                info_queue[#info_queue + 1] = hst_sticker_tooltip(pink.sticker)
            end
            return true
        end
    }))

    local hst_blue_source, hst_blue_built
    local hst_init_localization_ref = init_localization
    function init_localization()
        local stakes = G.localization.descriptions.Stake
        if stakes.stake_blue and stakes.stake_blue ~= hst_blue_built then
            hst_blue_source = stakes.stake_blue
        end
        local source = hst_blue_source or {}
        local source_text = source.text or {}

        -- Pink Stake's effect and note, without its "Applies all previous Stakes".
        local text, rest = HighStakes.stake_text(pink)
        for i = 1, #rest - 1 do text[#text + 1] = rest[i] end
        if hst_aij_blue_stake_rework() then
            for i = 1, #source_text - 1 do text[#text + 1] = source_text[i] end
        end
        text[#text + 1] = source_text[#source_text] or "{s:0.8}Applies all previous Stakes"

        hst_blue_built = { name = source.name or "Blue Stake", text = text }
        stakes.stake_blue = hst_blue_built
        return hst_init_localization_ref()
    end
end

local stakes = {}
local previous = 'gold'
for i, def in ipairs(HighStakes.stakes) do
    if HighStakes.stake_shown(def) then
        stakes[#stakes + 1] = {
            object_type = "Stake",
            key = def.key,
            applied_stakes = { previous },
            above_stake = previous,
            prefix_config = { applied_stakes = { mod = false }, above_stake = { mod = false } },
            atlas = 'stakes',
            pos = { x = i - 1, y = 0 },
            sticker_atlas = 'stake_stickers',
            sticker_pos = { x = i - 1, y = 0 },
            colour = HEX(def.colour),
            shiny = def.shiny,
            modifiers = function()
                if def.sticker then
                    G.GAME.modifiers['enable_' .. def.sticker] = true
                else
                    G.GAME.modifiers.hst_second_pit_blind = true
                end
            end,
            loc_vars = function(self, info_queue)
                if def.sticker then info_queue[#info_queue + 1] = hst_sticker_tooltip(def.sticker) end
                return { vars = def.vars and def.vars() or {} }
            end,
        }
        previous = 'hst_' .. def.key
    end
end

return { name = {"Stakes"}, items = stakes }
