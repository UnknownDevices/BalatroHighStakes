-- DebugPlus console commands. Skipped if DebugPlus isn't present.

local ok, dp_api = pcall(require, "debugplus-api")
if not ok or not dp_api.isVersionCompatible(1) then return end

local debugplus = dp_api.registerID("HighStakes")
if not debugplus then return end

local function hst_find_sticker_key(id)
    for _, key in ipairs({ id, "hst_" .. id }) do
        if SMODS.Stickers[key] then return key end
    end
end

local function hst_has_sticker(card, key)
    return card.ability[key] or (key == "pinned" and card.pinned)
end

debugplus.addCommand({
    name = "sticker",
    shortDesc = "Add, remove or enable Joker stickers",
    desc = "Usage:\nsticker add <sticker_id> - Adds the sticker to the highlighted Jokers (every Joker if none are highlighted),"
        .. " eg. 'sticker add linked'. Incompatible Jokers are skipped."
        .. "\nsticker remove <sticker_id> - Removes the sticker the same way."
        .. "\nsticker shop <sticker_id> - Toggles the sticker appearing on shop and Booster Pack Jokers for this run, as a Stake would.",
    exec = function(args, rawArgs, dp)
        if G.STAGE ~= G.STAGES.RUN then
            return "This command must be run during a run.", "ERROR"
        end
        local action = args[1]
        if action ~= "add" and action ~= "remove" and action ~= "shop" then
            return "Unknown subcommand. For more info, run 'help sticker'", "ERROR"
        end
        if not args[2] then
            return "Please provide a sticker id, eg. 'sticker " .. action .. " heavy'.", "ERROR"
        end
        local key = hst_find_sticker_key(args[2])
        if not key then
            return "No sticker found with id '" .. args[2] .. "'.", "ERROR"
        end
        local label = localize(key, "labels")

        if action == "shop" then
            if type(SMODS.Stickers[key].should_apply) ~= "function" then
                return label .. " isn't rolled through Steamodded's sticker rolls; use a Stake or Challenge modifier instead.", "ERROR"
            end
            local flag = "enable_" .. key
            G.GAME.modifiers[flag] = not G.GAME.modifiers[flag] or nil
            return label .. (G.GAME.modifiers[flag] and " now appears" or " no longer appears") .. " in shops and Booster Packs this run"
        end

        local targets = G.jokers.highlighted[1] and G.jokers.highlighted or G.jokers.cards
        local changed = 0
        for _, joker in ipairs(targets) do
            local had = hst_has_sticker(joker, key)
            if action == "add" and not had then
                joker:add_sticker(key, true)
            elseif action == "remove" and had then
                joker:remove_sticker(key)
            end
            if (not had) ~= (not hst_has_sticker(joker, key)) then
                changed = changed + 1
                joker:juice_up(0.3, 0.4)
            end
        end
        return (action == "add" and "Added " or "Removed ") .. label .. (action == "add" and " to " or " from ")
            .. changed .. " of " .. #targets .. " Joker(s)"
    end
})
