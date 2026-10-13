return {
    descriptions = {
        Mod = {
            highstakes = {
                name = "High Stakes",
                text = {
                    "Four new {C:attention}Stakes{} after Gold Stake, and a fifth",
                    "when played with {C:attention}All in Jest{}",
                },
            },
        },
        Stake = {
            stake_hst_gray = {
                name = "Gray Stake",
                text = {
                    "Shop can have {C:attention}Heavy{} Jokers",
                    "{C:inactive,s:0.8}(Can't be moved)",
                    "{s:0.8}Applies all previous Stakes",
                },
            },
            stake_hst_brown = {
                name = "Brown Stake",
                text = {
                    "Boss Blind on Ante",
                    "{C:attention}6{} or {C:attention}7{} is a Pit Blind",
                    "{s:0.8}Applies all previous Stakes",
                },
            },
            stake_hst_pink = {
                name = "Pink Stake",
                text = {
                    "Shop can have {C:attention}Linked{} Jokers",
                    "{C:inactive,s:0.8}(All are sold or destroyed together)",
                    "{s:0.8}Applies all previous Stakes",
                },
            },
            stake_hst_teal = {
                name = "Teal Stake",
                text = {
                    "Shop can have {C:attention}Fragile{} Jokers",
                    "{C:inactive,s:0.8}(#1# in #2# chance to be destroyed each round)",
                    "{s:0.8}Applies all previous Stakes",
                },
            },
            stake_hst_platinum = {
                name = "Platinum Stake",
                text = {
                    "Shop can have {C:attention}Treacherous{} Jokers",
                    "{C:inactive,s:0.8}(+#1#% required score each round)",
                    "{s:0.8}Applies all previous Stakes",
                },
            },
        },
        Other = {
            hst_heavy = {
                name = "Heavy",
                text = {
                    "Can't be moved",
                },
            },
            hst_fragile = {
                name = "Fragile",
                text = {
                    "{C:green}#1# in #2#{} chance",
                    "to be {C:red}destroyed{}",
                    "at end of round",
                },
            },
            hst_linked = {
                name = "Linked",
                text = {
                    "All {C:attention}Linked{} Jokers",
                    "are {C:red}destroyed{} or",
                    "{C:attention}sold{} together",
                },
            },
            hst_treacherous = {
                name = "Treacherous",
                text = {
                    "{C:red}+#1#%{} required",
                    "score each round",
                },
            },
            hst_gray_sticker = {
                name = "Gray Sticker",
                text = {
                    "Used this Joker",
                    "to win on {C:attention}Gray",
                    "{C:attention}Stake{} difficulty",
                },
            },
            hst_brown_sticker = {
                name = "Brown Sticker",
                text = {
                    "Used this Joker",
                    "to win on {C:attention}Brown",
                    "{C:attention}Stake{} difficulty",
                },
            },
            hst_pink_sticker = {
                name = "Pink Sticker",
                text = {
                    "Used this Joker",
                    "to win on {C:attention}Pink",
                    "{C:attention}Stake{} difficulty",
                },
            },
            hst_teal_sticker = {
                name = "Teal Sticker",
                text = {
                    "Used this Joker",
                    "to win on {C:attention}Teal",
                    "{C:attention}Stake{} difficulty",
                },
            },
            hst_platinum_sticker = {
                name = "Platinum Sticker",
                text = {
                    "Used this Joker",
                    "to win on {C:attention}Platinum",
                    "{C:attention}Stake{} difficulty",
                },
            },
        },
    },
    misc = {
        labels = {
            hst_heavy = "Heavy",
            hst_fragile = "Fragile",
            hst_linked = "Linked",
            hst_treacherous = "Treacherous",
        },
        dictionary = {
            hst_broken_ex = "Broken!",
            hst_config_stakes = "Stakes",
            hst_config_stickers = "Stickers",
            hst_config_vanilla = "Vanilla",
            hst_config_blue_stake_rework = "Blue Stake Rework",
            hst_config_blue_stake_rework_1 = "Blue Stake takes on the effect of Pink Stake,",
            hst_config_blue_stake_rework_2 = "and Pink Stake is disabled",
            hst_config_restart = "Changes restart the game when leaving the Mods menu",
            hst_config_cap_1 = "(Eternal, Perishable, and Fragile combined chance must be below 100%)",
            hst_config_cap_2 = "(Eternal and Linked combined chance must be below 100%)",
        },
        v_dictionary = {
            hst_config_chance = "#1# chance",
            hst_config_chance_info = "Chance of #1# to appear, default is #2#%",
        },
    },
}
