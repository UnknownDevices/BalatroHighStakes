local HEAVY = 'hst_heavy'

local function hst_is_heavy(card)
    return card and card.ability and card.ability[HEAVY]
end

local function hst_is_pinned(card)
    return ((card.ability and card.ability.aij_pinned) or card.pinned) and not card.ignore_pinned
end

local function hst_is_wall(card)
    return hst_is_heavy(card) and not hst_is_pinned(card)
end

local function hst_walls_around(cards, index)
    local left, right
    for i = index - 1, 1, -1 do
        if hst_is_wall(cards[i]) then left = i break end
    end
    for i = index + 1, #cards do
        if hst_is_wall(cards[i]) then right = i break end
    end
    return left, right
end

local function hst_index_of(cards, card)
    for i, other in ipairs(cards) do
        if other == card then return i end
    end
end

-- A Heavy Joker shakes whenever something tries to move it
local HST_SHAKE_EVERY = 0.8
local function hst_shake(card)
    if card.hst_shook_at and G.TIMERS.REAL - card.hst_shook_at < HST_SHAKE_EVERY then return end
    card.hst_shook_at = G.TIMERS.REAL
    card:juice_up(0.1, 0.1)
end

-- align_cards re-sorts the Joker area by position every frame, so a dragged
-- Joker is held between its walls
local hst_heavy_drag_ref = Card.drag
function Card:drag(offset)
    local ret = hst_heavy_drag_ref(self, offset)
    local area = self.area
    if not (G.jokers and area == G.jokers and G.CONTROLLER.dragging.target == self) then return ret end
    if hst_is_heavy(self) or hst_is_pinned(self) then return ret end
    local index = hst_index_of(area.cards, self)
    if not index then return ret end
    local left, right = hst_walls_around(area.cards, index)
    if not (left or right) then return ret end
    local slot = (area.T.w - area.card_w) / math.max(#area.cards - 1, 1)
    local gap = 0.5 * math.min(area.card_w, slot)
    local centre = self.T.x + self.T.w / 2
    if left then
        local wall = area.cards[left]
        local limit = wall.T.x + wall.T.w / 2 + gap
        if centre < limit then
            centre = limit
            hst_shake(wall)
        end
    end
    if right then
        local wall = area.cards[right]
        local limit = wall.T.x + wall.T.w / 2 - gap
        if centre > limit then
            centre = limit
            hst_shake(wall)
        end
    end
    self.T.x = centre - self.T.w / 2
    return ret
end

-- Heavy Jokers can't be dragged, so pressing and holding one only makes it
-- shake, after a moment so that a plain click to select it doesn't
local HST_HOLD_BEFORE_SHAKE = 0.15
local hst_heavy_update_ref = Card.update
function Card:update(dt)
    local ret = hst_heavy_update_ref(self, dt)
    local controller = G.CONTROLLER
    local press = controller.cursor_down
    if G.jokers and self.area == G.jokers and hst_is_heavy(self)
    and controller.is_cursor_down and press.target == self
    and self.hst_let_go_press ~= press.time then
        if not self.states.collide.is then
            self.hst_let_go_press = press.time
        elseif G.TIMERS.TOTAL - press.time > HST_HOLD_BEFORE_SHAKE then
            hst_shake(self)
        end
    end
    return ret
end

-- A controller moves a held card one slot per d-pad press, by swapping it
-- with its neighbour. Refuse it when the neighbour is a wall.
local hst_heavy_focused_input_ref = Controller.capture_focused_input
function Controller:capture_focused_input(button, input_type, dt)
    local focused = self.focused.target
    if input_type == 'press' and (button == 'dpleft' or button == 'dpright')
    and focused and G.jokers and focused.area == G.jokers and focused == self.dragging.target
    and not hst_is_pinned(focused)
    and not (self.held_button_times['a'] and self.held_button_times['a'] < 0.12 and focused.area:can_highlight(focused)) then
        local neighbour = focused.area.cards[(focused.rank or 0) + (button == 'dpleft' and -1 or 1)]
        if hst_is_wall(neighbour) then
            hst_shake(neighbour)
            return true
        end
    end
    return hst_heavy_focused_input_ref(self, button, input_type, dt)
end

-- Handy's Precise selection moves a selected card straight in area.cards, one
-- slot (wrapping around the ends) or to an end. Heavy Jokers
-- don't move, a step into a wall does nothing, and "to the end" goes
-- to the end of the card's stretch, and whichever Heavy Joker is in the way
-- shakes.
G.E_MANAGER:add_event(Event({
    func = function()
        local control = Handy and Handy.controls and Handy.controls.dictionary
            and Handy.controls.dictionary.move_highlight
        if not control then return true end
        local hst_heavy_handy_execute_ref = control.execute
        control.execute = function(item, ctx, args, data)
            local area = data.area
            if not (G.jokers and area == G.jokers and data.swap and Handy.move_highlight.can_swap(area)) then
                return hst_heavy_handy_execute_ref(item, ctx, args, data)
            end
            local cards = area.cards
            local card = area.highlighted[1]
            local index = hst_index_of(cards, card)
            if not index or hst_is_pinned(card) then
                return hst_heavy_handy_execute_ref(item, ctx, args, data)
            end
            if hst_is_heavy(card) then
                hst_shake(card)
                return
            end
            local left, right = hst_walls_around(cards, index)
            if not (left or right) then
                return hst_heavy_handy_execute_ref(item, ctx, args, data)
            end
            local first, last = (left or 0) + 1, (right or #cards + 1) - 1
            if not data.to_end then
                local target = index + data.dx
                if target < first then
                    hst_shake(cards[left or right])
                    return
                elseif target > last then
                    hst_shake(cards[right or left])
                    return
                end
                return hst_heavy_handy_execute_ref(item, ctx, args, data)
            end
            local target = data.dx > 0 and last or first
            if target == index then
                local wall = data.dx > 0 and right or left
                if wall then hst_shake(cards[wall]) end
                return
            end
            item.triggers_count = item.triggers_count + 1
            table.remove(cards, index)
            table.insert(cards, target, card)
            play_sound("paper1", math.random() * 0.2 + 0.9, 0.35)
            return true
        end
        return true
    end
}))

-- set_ranks re-enables dragging for every card in the Joker area whenever a
-- card is added, removed or shuffled.
local hst_heavy_set_ranks_ref = CardArea.set_ranks
function CardArea:set_ranks()
    local ret = hst_heavy_set_ranks_ref(self)
    if G.jokers and self == G.jokers then
        for _, card in ipairs(self.cards) do
            if hst_is_heavy(card) then card.states.drag.can = false end
        end
    end
    return ret
end

-- Shuffles, such as from from Boss Blinds, count as moves. Walls
-- stay in their slots, and every other Joker is only shuffled within its own
-- stretch between them.
local hst_heavy_shuffle_ref = CardArea.shuffle
function CardArea:shuffle(_seed)
    if not (G.jokers and self == G.jokers) then return hst_heavy_shuffle_ref(self, _seed) end
    local wall_at, stretch_of = {}, {}
    local stretch = 1
    for i, card in ipairs(self.cards) do
        if hst_is_wall(card) then
            wall_at[i] = card
            stretch = stretch + 1
        else
            stretch_of[card] = stretch
        end
    end
    local ret = hst_heavy_shuffle_ref(self, _seed)
    if next(wall_at) then
        local stretches = {}
        for _, card in ipairs(self.cards) do
            local s = stretch_of[card]
            if s then
                stretches[s] = stretches[s] or {}
                table.insert(stretches[s], card)
            end
        end
        stretch = 1
        local placed = {}
        for i = 1, #self.cards do
            if wall_at[i] then
                self.cards[i] = wall_at[i]
                stretch = stretch + 1
            else
                placed[stretch] = (placed[stretch] or 0) + 1
                self.cards[i] = stretches[stretch][placed[stretch]]
            end
        end
        self:set_ranks()
    end
    return ret
end

local heavy = {
    object_type = "Sticker",
    key = "heavy",
    atlas = "stickers",
    pos = { x = 0, y = 0 },
    badge_colour = HEX('a868e7'),
    order = 2,
    sets = { Joker = true },

    should_apply = function(self, card, center, area, bypass_roll)
        if bypass_roll == nil and not HighStakes.sticker_rolls_in(area) then return false end
        self.rate = HighStakes.sticker_chance('heavy')
        return SMODS.Sticker.should_apply(self, card, center, area, bypass_roll)
    end,

    apply = function(self, card, val)
        SMODS.Sticker.apply(self, card, val)
        if G.jokers and card.area == G.jokers then
            card.states.drag.can = not val
        end
    end,
}

return { name = {"Stickers"}, items = {heavy} }
