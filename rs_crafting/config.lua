Config = {}

Config.CraftTime = 10000

Config.Prompt = {
    key = `INPUT_INTERACT_OPTION1`, -- Cambia esta tecla según sea necesario
    text = "Crafting Menu",        -- Texto personalizado del prompt
    distance = 1.5                  -- Distancia a la que se activa el prompt
}

Config.Prompt2 = {
    key = `INPUT_INTERACT_OPTION1`, -- Cambia esta tecla según sea necesario
    text = "Crafting Menu",        -- Texto personalizado del prompt
    distance = 1.5                 -- Distancia a la que se activa el prompt
}

Config.Texts = {
    craftingMenu = "Crafting Menu",
    selectCategory = "Select item to craft",
    close = "Close",
    crafting = "Crafting...",
    quantityPlaceholder = "Quantity",
    craftButton = "Craft",
    ingredientsButton = "Ingredients or Materials",
    Notify = {
        crafting = "Crafting",
        notjob = "You don't have the necessary job",
        notmaterials = "You don't have enough materials",
        space = "You don't have enough space",
        success = "Successful Crafting",
        invalid = "Invalid crafting type",
    },
}

Config.ShowBlip = true
Config.BlipZone = {
    -- Location blip for craft enterprise
    {coords = vector3(-314.34, 809.98, 118.98),       blips = 1879260108, blipsName = "Valentine Saloon",},      -- Valentine Saloon
    {coords = vector3(2640.24, -1228.82, 53.38),      blips = 1879260108, blipsName = "Saint Denis Saloon",},    -- Saint Denis Saloon
}

Config.CraftingZones = {
    [1] = {
        coords = {
            vector3(-314.34, 809.98, 118.98),    -- Valentine Saloon
            vector3(2640.24, -1228.82, 53.38),   -- Saint Denis Saloon
        },
        craftingItems = {
            {
                Items = {
                    {
                        Text = "Bread",    -- name of the recipe
                        Category = "Meal", -- Category = false, is displayed directly in the list -- Category = "Meal", For example, it is shown within the food category
                        Job = {"saloonvl", "saloonsd"},   -- you can add as many jobs as you want, even just one so only that business sees the recipe -- Job = false, all players can access the crafting
                        Animation = 'craft',            -- type of animation, -- 'craft', -- 'spindlecook', -- 'knifecooking', -- 'fish', -- 'plane', -- 'saw',
                        Items = {                       -- list of required items for crafting
                            -- name = item name in the DB -- label = name shown in the menu -- count = required amount
                            {name = "bread", label = "Bread", count = 1}, 
                            {name = "water", label = "Water", count = 2},
                            -- Add the necessary items for the recipe.
                        },
                        Reward = {
                            -- name = item name in the DB -- count = amount of rewards
                            {name = "bread", count = 5}
                        },
                    },
                    {
                        Text = "Water",      -- name of the recipe
                        Category = "Drink", -- Category = false, is displayed directly in the list -- Category = "Drink", For example, it is shown within the beverage category
                        Job = {"salonvl", "salonsd"},   -- you can add as many jobs as you want, even just one so only that business sees the recipe -- Job = fasle, all players can access the crafting
                        Animation = 'craft',            -- type of animation, -- 'craft', -- 'spindlecook', -- 'knifecooking', -- 'fish', -- 'plane', -- 'saw',
                        Items = {                       -- list of required items for crafting
                            -- name = item name in the DB -- label = name shown in the menu -- count = required amount
                            {name = "bread", label = "Bread", count = 1}, 
                            {name = "water", label = "Water", count = 2},
                            -- Add the necessary items for the recipe.
                        },
                        Reward = {
                            -- name = item name in the DB -- count = amount of rewards
                            {name = "water", count = 5}
                        },
                    },
                    -- add more recipes for these locations
                }
            },
        }
    },

    -- add more crafting zones by continuing with [2]
}

Config.CraftingProps = {
    {
        Items = {
            {
                Text = "Bread",
                Category = false, -- Category = false, is displayed directly in the list -- Category = "Drink", For example, it is shown within the beverage category
                Job = false, -- Job = false, all players can access the crafting -- Job = {"salonvl", "salonsd"}, Only players with those jobs can see and craft it
                Animation = 'knifecooking',-- type of animation, -- 'craft', -- 'spindlecook', -- 'knifecooking', -- 'fish', -- 'plane', -- 'saw',
                props = {"p_campfire05x", "p_campfire04x", "s_cookfire01x", "p_campfire01x"},
                Items = {
                    {name = "water", label = "Water", count = 2},
                    -- Add the necessary items for the recipe.
                },
                Reward = {
                    {name = "bread", count = 1}
                },
            },
            {
                Text = "Water",
                Category = false,
                Job = false,
                Animation = 'knifecooking',
                props = {"p_campfire05x", "p_campfire04x", "s_cookfire01x", "p_campfire01x"},
                Items = {
                    {name = "bread", label = "Bread", count = 1},
                    -- Add the necessary items for the recipe.
                },
                Reward = {
                    {name = "water", count = 1}
                },
            },
        }
    },
    -- add more prop, to open menu crafting
    --[[{
        Items = {
            {
                Text = "",
                Category = false, -- Category = false, is displayed directly in the list -- Category = "Drink", For example, it is shown within the beverage category
                Job = false, -- Job = false, all players can access the crafting -- Job = {"salonvl", "salonsd"}, Only players with those jobs can see and craft it
                Type = "", -- crafting type: item or weapon
                Animation = 'craft', -- type of animation, -- 'craft', -- 'spindlecook', -- 'knifecooking', -- 'fish', -- 'plane', -- 'saw',
                props =  {""},
                Items = {
                    {name = "", label = "", count = 1, image = ".png"},
                       --  Add the necessary items for the recipe.
                },
                Reward = {
                       -- name = item name in the DB -- count = amount of rewards
                    {name = "", count = 1, image = ".png"}
                },
            },
        }
    },]]--
}

Config.Anim = {
    ["craft"] = {
        dict = "mech_inventory@crafting@fallbacks",
        name = "full_craft_and_stow",
        flag = 27,
        type = 'standard'
    },
    ["spindlecook"] = {
        dict = "amb_camp@world_camp_fire_cooking@male_d@wip_base",
        name = "wip_base",
        flag = 17,
        type = 'standard',
        prop = {
            model = 'p_stick04x',
            coords = {
                x = 0.2,
                y = 0.04,
                z = 0.12,
                xr = 170.0,
                yr = 50.0,
                zr = 0.0
            },
            bone = 'SKEL_R_Finger13',
            subprop = {
                model = 's_meatbit_chunck_medium01x',
                coords = {
                    x = -0.30,
                    y = -0.08,
                    z = -0.30,
                    xr = 0.0,
                    yr = 0.0,
                    zr = 70.0
                }
            }
        }
    },
    ["knifecooking"] = {
        dict = "amb_camp@world_player_fire_cook_knife@male_a@wip_base",
        name = "wip_base",
        flag = 17,
        type = 'standard',
        prop = {
            model = 'w_melee_knife06',
            coords = {
                x = -0.01,
                y = -0.02,
                z = 0.02,
                xr = 190.0,
                yr = 0.0,
                zr = 0.0
            },
            bone = 'SKEL_R_Finger13',
            subprop = {
                model = 'p_redefleshymeat01xa',
                coords = {
                    x = 0.00,
                    y = 0.02,
                    z = -0.20,
                    xr = 0.0,
                    yr = 0.0,
                    zr = 0.0
                }
            }
        }
    },
    ["fish"] = {
        dict = "amb_camp@world_player_fire_cook_knife@male_a@wip_base",
        name = "wip_base",
        flag = 17,
        type = 'standard',
        prop = {
            model = 'w_melee_knife06',
            coords = {
                x = -0.01,
                y = -0.02,
                z = 0.02,
                xr = 190.0,
                yr = 0.0,
                zr = 0.0
            },
            bone = 'SKEL_R_Finger13',
            subprop = {
                model = 'p_cs_catfish_chop01x',
                coords = {
                    x = 0.00,
                    y = 0.02,
                    z = -0.20,
                    xr = 0.0,
                    yr = 0.0,
                    zr = 0.0
                }
            }
        }
    },
}