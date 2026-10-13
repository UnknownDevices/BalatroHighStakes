return {
    descriptions = {
        Mod = {
            highstakes = {
                name = "High Stakes",
                text = {
                    "Cuatro {C:attention}pozos{} nuevos después del Pozo de oro,",
                    "y un quinto si se juega con {C:attention}All in Jest{}",
                },
            },
        },
        Stake = {
            stake_hst_gray = {
                name = "Pozo gris",
                text = {
                    "La tienda puede tener comodines {C:attention}pesados{}",
                    "{C:inactive,s:0.8}(No se pueden mover)",
                    "{s:0.8}Se aplica a todos los pozos anteriores",
                },
            },
            stake_hst_brown = {
                name = "Pozo marrón",
                text = {
                    "La Ciega Jefe de la Apuesta",
                    "{C:attention}6{} o {C:attention}7{} es una Ciega de Pozo",
                    "{s:0.8}Se aplica a todos los pozos anteriores",
                },
            },
            stake_hst_pink = {
                name = "Pozo rosa",
                text = {
                    "La tienda puede tener comodines {C:attention}enlazados{}",
                    "{C:inactive,s:0.8}(Se venden o destruyen todos juntos)",
                    "{s:0.8}Se aplica a todos los pozos anteriores",
                },
            },
            stake_hst_teal = {
                name = "Pozo turquesa",
                text = {
                    "La tienda puede tener comodines {C:attention}frágiles{}",
                    "{C:inactive,s:0.8}(#1# en #2# probabilidades de destruirse cada ronda)",
                    "{s:0.8}Se aplica a todos los pozos anteriores",
                },
            },
            stake_hst_platinum = {
                name = "Pozo de platino",
                text = {
                    "La tienda puede tener comodines {C:attention}traicioneros{}",
                    "{C:inactive,s:0.8}(+#1#% de puntuación requerida cada ronda)",
                    "{s:0.8}Se aplica a todos los pozos anteriores",
                },
            },
        },
        Other = {
            hst_heavy = {
                name = "Pesado",
                text = {
                    "No se puede mover",
                },
            },
            hst_fragile = {
                name = "Frágil",
                text = {
                    "{C:green}#1# en #2#{} probabilidades",
                    "de ser {C:red}destruido{}",
                    "al final de la ronda",
                },
            },
            hst_linked = {
                name = "Enlazado",
                text = {
                    "Todos los comodines",
                    "{C:attention}enlazados{} se {C:red}destruyen{}",
                    "o se {C:attention}venden{} juntos",
                },
            },
            hst_treacherous = {
                name = "Traicionero",
                text = {
                    "{C:red}+#1#%{} de puntuación",
                    "requerida cada ronda",
                },
            },
            hst_gray_sticker = {
                name = "Sticker gris",
                text = {
                    "Usaste este comodín",
                    "para ganar en la dificultad {C:attention}Pozo",
                    "{C:attention}gris{}",
                },
            },
            hst_brown_sticker = {
                name = "Sticker marrón",
                text = {
                    "Usaste este comodín",
                    "para ganar en la dificultad {C:attention}Pozo",
                    "{C:attention}marrón{}",
                },
            },
            hst_pink_sticker = {
                name = "Sticker rosa",
                text = {
                    "Usaste este comodín",
                    "para ganar en la dificultad {C:attention}Pozo",
                    "{C:attention}rosa{}",
                },
            },
            hst_teal_sticker = {
                name = "Sticker turquesa",
                text = {
                    "Usaste este comodín",
                    "para ganar en la dificultad {C:attention}Pozo",
                    "{C:attention}turquesa{}",
                },
            },
            hst_platinum_sticker = {
                name = "Sticker de platino",
                text = {
                    "Usaste este comodín",
                    "para ganar en la dificultad {C:attention}Pozo",
                    "{C:attention}de platino{}",
                },
            },
        },
    },
    misc = {
        labels = {
            hst_heavy = "Pesado",
            hst_fragile = "Frágil",
            hst_linked = "Enlazado",
            hst_treacherous = "Traicionero",
        },
        dictionary = {
            hst_broken_ex = "¡Roto!",
            hst_config_stakes = "Pozos",
            hst_config_stickers = "Stickers",
            hst_config_vanilla = "Vanilla",
            hst_config_blue_stake_rework = "Rediseño del Pozo azul",
            hst_config_blue_stake_rework_1 = "El Pozo azul toma el efecto del Pozo rosa,",
            hst_config_blue_stake_rework_2 = "y el Pozo rosa se desactiva",
            hst_config_restart = "Los cambios reinician el juego al salir del menú de mods",
            hst_config_cap_1 = "(La probabilidad combinada de Eterno, Perecedero y Frágil debe ser menor al 100%)",
            hst_config_cap_2 = "(La probabilidad combinada de Eterno y Enlazado debe ser menor al 100%)",
        },
        v_dictionary = {
            hst_config_chance = "Probabilidad de #1#",
            hst_config_chance_info = "Probabilidad de que aparezca #1#, por defecto #2#%",
        },
    },
}
