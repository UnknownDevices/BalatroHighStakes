-- Settings tab in the Mods menu.

local mod = SMODS.current_mod

-- Stakes are only built at boot, so restart when stakes are reconfigured.
local hst_boot_config = copy_table(mod.config)
local hst_restart_count = 0

local function hst_update_restart()
    local changed = 0
    for key, value in pairs(mod.config) do
        if (hst_boot_config[key] ~= false) ~= (value ~= false) then changed = changed + 1 end
    end
    SMODS.full_restart = (SMODS.full_restart or 0) + changed - hst_restart_count
    hst_restart_count = changed
end

local function hst_text_row(text, scale, colour)
    return {n = G.UIT.R, config = {align = "cm", padding = 0.05}, nodes = {
        {n = G.UIT.T, config = {text = text, scale = scale, colour = colour}},
    }}
end

local function hst_find_node(node, key, value)
    if node.config and node.config[key] == value then return node end
    for _, child in ipairs(node.nodes or {}) do
        local found = hst_find_node(child, key, value)
        if found then return found end
    end
end

local function hst_toggle(args)
    local info = args.info or {}
    args.info = nil
    local toggle = {n = G.UIT.R, config = {align = "cr", padding = 0}, nodes = { create_toggle(args) }}
    local w, scale = args.w or 3, args.scale or 1
    local inset = 0.3 * w + 0.1 - 0.46 * scale
    local nodes = { toggle }
    for _, line in ipairs(info) do
        nodes[#nodes + 1] = {n = G.UIT.R, config = {align = "cr"}, nodes = {
            {n = G.UIT.T, config = {text = line, scale = 0.25, colour = G.C.UI.TEXT_INACTIVE}},
            {n = G.UIT.B, config = {w = inset, h = 0.1}},
        }}
    end
    return {n = G.UIT.C, config = {align = "cr"}, nodes = nodes}
end

local function hst_stake_effect(stake)
    local effect = HighStakes.stake_text(stake)
    return (table.concat(effect, " "):gsub("{[^}]*}", ""))
end

-- A toggle that greys out and ignores clicks while disabled
local function hst_dependent_toggle(args, enabled)
    local toggle = hst_toggle(args)
    local box = hst_find_node(toggle, 'button', 'toggle_button').config
    local label = hst_find_node(toggle, 'text', args.label).config
    box.hst_enabled = enabled
    box.func = 'hst_dependent_toggle'
    box.hst_label = label
    return toggle
end

G.FUNCS.hst_dependent_toggle = function(e)
    G.FUNCS.toggle(e)
    local enabled = e.config.hst_enabled()
    e.config.button = enabled and 'toggle_button' or nil
    e.config.outline_colour = enabled and G.C.WHITE or G.C.UI.TEXT_INACTIVE
    e.config.hst_label.colour = enabled and G.C.UI.TEXT_LIGHT or G.C.UI.TEXT_INACTIVE
end

local hst_sticker_columns = {
    { title = 'hst_config_vanilla', stickers = {
        { key = 'eternal', label = 'eternal' },
        { key = 'perishable', label = 'perishable' },
        { key = 'rental', label = 'rental' },
    } },
    { title = "High Stakes", stickers = {
        { key = 'heavy', label = 'hst_heavy' },
        { key = 'fragile', label = 'hst_fragile' },
        { key = 'linked', label = 'hst_linked' },
        { key = 'treacherous', label = 'hst_treacherous' },
    } },
}
local hst_default_config = assert(SMODS.load_file("config.lua"))()

local hst_shared_rolls = {
    { 'eternal', 'perishable', 'fragile' },
    { 'eternal', 'linked' },
}

local function hst_chance_cap(key)
    local chances = mod.config.sticker_chances
    local cap = 100
    for _, group in ipairs(hst_shared_rolls) do
        local others, shared = 0, false
        for _, other in ipairs(group) do
            if other == key then shared = true else others = others + chances[other] end
        end
        if shared then cap = math.min(cap, 100 - others) end
    end
    return math.max(0, cap)
end

-- Enforce sliders' dynamic min and max range
G.FUNCS.hst_chance_slider = function(e)
    G.FUNCS.slider(e)
    local bar = e.children[1]
    local args = bar.config.ref_table
    local value = args.ref_table[args.ref_value]
    if value ~= args.hst_prev then
        local cap = hst_chance_cap(args.ref_value)
        if value > cap then
            value = cap
            args.ref_table[args.ref_value] = value
            bar.T.w = (value - args.min) / (args.max - args.min) * args.w
            bar.config.w = bar.T.w
        end
        args.hst_prev = value
    end
    local text = value .. "%"
    if args.text ~= text then args.text = text end
end

local function hst_slider(label, info, args)
    args.ref_table[args.ref_value] = math.max(args.min, math.min(args.max, args.ref_table[args.ref_value]))
    local slider = create_slider(args)
    hst_find_node(slider, 'func', 'slider').config.func = 'hst_chance_slider'
    args.hst_prev = args.ref_table[args.ref_value]
    args.text = args.hst_prev .. "%"
    return {n = G.UIT.C, config = {align = "cr"}, nodes = {
        {n = G.UIT.R, config = {align = "cr", padding = 0}, nodes = {
            {n = G.UIT.C, config = {align = "cm", minh = args.h}, nodes = {
                {n = G.UIT.T, config = {text = label, scale = 0.4, colour = G.C.UI.TEXT_LIGHT}},
            }},
            slider,
        }},
        {n = G.UIT.R, config = {align = "cr"}, nodes = {
            {n = G.UIT.T, config = {text = info, scale = 0.25, colour = G.C.UI.TEXT_INACTIVE}},
            {n = G.UIT.B, config = {w = 0.1, h = 0.1}},
        }},
    }}
end

local function hst_subpage(rows)
    return create_UIBox_generic_options({
        back_func = 'hst_back_config',
        contents = {
            {n = G.UIT.R, config = {r = 0.1, minw = 6, align = "tm", padding = 0.2, colour = G.C.BLACK}, nodes = {
                {n = G.UIT.C, config = {align = "tm", padding = 0.1}, nodes = rows},
            }},
        },
    })
end

G.FUNCS.hst_config_stakes = function(e)
    local rows = { hst_text_row(localize('hst_config_stakes'), 0.5, G.C.WHITE) }
    for _, stake in ipairs(HighStakes.stakes) do
        -- Brown Stake is skipped without All in Jest.
        if HighStakes.stake_available(stake) then
            local ref_value = 'show_' .. stake.key .. '_stake'
            rows[#rows + 1] = {n = G.UIT.R, config = {align = "cr"}, nodes = {
                hst_toggle({
                    label = HighStakes.stake_name(stake),
                    info = {"(" .. hst_stake_effect(stake) .. ")"},
                    ref_table = mod.config,
                    ref_value = ref_value,
                    callback = function(value)
                        if stake.key == 'pink' and not value then mod.config.blue_stake_pink = false end
                        hst_update_restart()
                    end,
                }),
            }}
            if stake.key == 'pink' then
                rows[#rows + 1] = {n = G.UIT.R, config = {align = "cr"}, nodes = {
                    hst_dependent_toggle({
                        label = localize('hst_config_blue_stake_rework'),
                        info = {localize('hst_config_blue_stake_rework_1'), localize('hst_config_blue_stake_rework_2')},
                        ref_table = mod.config,
                        ref_value = 'blue_stake_pink',
                        callback = hst_update_restart,
                    }, function() return mod.config[ref_value] ~= false end),
                }}
            end
        end
    end
    rows[#rows + 1] = hst_text_row(localize('hst_config_restart'), 0.3, G.C.UI.TEXT_INACTIVE)
    G.FUNCS.overlay_menu({ definition = hst_subpage(rows) })
end

G.FUNCS.hst_config_stickers = function(e)
    local columns = {}
    for _, column in ipairs(hst_sticker_columns) do
        local title = column.title:find('^hst_') and localize(column.title) or column.title
        local entries = { hst_text_row(title, 0.4, G.C.WHITE) }
        for _, sticker in ipairs(column.stickers) do
            local default = hst_default_config.sticker_chances[sticker.key]
            local name = localize(sticker.label, 'labels')
            entries[#entries + 1] = {n = G.UIT.R, config = {align = "cr"}, nodes = {
                hst_slider(localize { type = 'variable', key = 'hst_config_chance', vars = { name } },
                    localize { type = 'variable', key = 'hst_config_chance_info', vars = { name, default } }, {
                    ref_table = mod.config.sticker_chances,
                    ref_value = sticker.key,
                    min = 0,
                    max = 100,
                    w = 2.5,
                    h = 0.4,
                }),
            }}
        end
        columns[#columns + 1] = {n = G.UIT.C, config = {align = "tm", padding = 0.1}, nodes = entries}
    end
    G.FUNCS.overlay_menu({ definition = hst_subpage({
        hst_text_row(localize('hst_config_stickers'), 0.5, G.C.WHITE),
        {n = G.UIT.R, config = {align = "tm", padding = 0.1}, nodes = columns},
        hst_text_row(localize('hst_config_cap_1'), 0.3, G.C.UI.TEXT_INACTIVE),
        hst_text_row(localize('hst_config_cap_2'), 0.3, G.C.UI.TEXT_INACTIVE),
    }) })
end

G.FUNCS.hst_back_config = function(e)
    SMODS.LAST_SELECTED_MOD_TAB = 'config'
    G.FUNCS.overlay_menu({ definition = create_UIBox_mods({}) })
end

mod.config_tab = function()
    return {n = G.UIT.ROOT, config = {r = 0.1, minw = 6, align = "tm", padding = 0.2, colour = G.C.BLACK}, nodes = {
        {n = G.UIT.C, config = {align = "tm", padding = 0.2}, nodes = {
            {n = G.UIT.R, config = {align = "cm", padding = 0.2}, nodes = {
                UIBox_button({label = {localize('hst_config_stakes')}, button = 'hst_config_stakes', minw = 4}),
                UIBox_button({label = {localize('hst_config_stickers')}, button = 'hst_config_stickers', minw = 4}),
            }},
        }},
    }}
end
