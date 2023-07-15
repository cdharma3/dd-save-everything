var script_class = "tool"

# Globals
var terrain_brush
var terrain_list
var terrain_buttons
var biome_dropdown
# HACK: Reference to Master node, needed because 
# it is not exposed in the modding api directly
var Master: Node

# Script constants
# TODO: Add support for multiple biome presets in the future
const BIOMES_PATH: String = "user://preset1.dungeondraft_biomes"

func init_globals():
    Master = Global.Editor.get_parent()
    terrain_brush = Global.Editor.Toolset.ToolPanels["TerrainBrush"]
    # TODO: Replace magic numbers in get_child with proper node ids
    terrain_list = terrain_brush.Align.get_child(7).get_child(0)
    terrain_buttons = terrain_brush.Align.get_child(7).get_child(1).get_children()
    biome_dropdown = terrain_brush.Align.get_child(6)


# Biome dictionary
var biomes: Dictionary

# Script entry point
func start():
    # Initialize global variables, must be called before any other functions!
    init_globals()

    # Override signals
    var conns = biome_dropdown.get_signal_connection_list("item_selected")
    biome_dropdown.disconnect("item_selected", conns[0].target, conns[0].method)
    biome_dropdown.connect("item_selected", self, "set_biome")
    
    for i in range(0, len(terrain_buttons)):
        conns = terrain_buttons[i].get_signal_connection_list("pressed")
        terrain_buttons[i].disconnect("pressed", conns[0].target, conns[0].method)
        terrain_buttons[i].connect("pressed", self, "popup_terrain_window", [i])

    # HACK: Disconnecting undefined method from 'about_to_show' signal
    Master.Editor.TerrainWindow.disconnect("about_to_show", Master.Editor.TerrainWindow, "_on_TerrainWindow_about_to_show")
    Master.Editor.TerrainWindow.connect("popup_hide", self, "sync_biome")

    # Load biomes into biomes dictionary, then override
    # the default biomes terrain set with our own
    if load_biomes() != 0:
        log_err("Some sort of error when loading biomes!")

    # Setup terrain preset buttons
    var new_button = terrain_brush.CreateButton("New Biome", Global.Root + "icons/add.png")
    new_button.connect("pressed", self, "new_biome")
    terrain_brush.Align.move_child(new_button, 6)

    var save_button = terrain_brush.CreateButton("Save Biome", "res://ui/icons/menu/save.png")
    save_button.connect("pressed", self, "save_biomes")
    save_button.hint_tooltip = "WARNING: This will overwrite your current preset file"
    terrain_brush.Align.move_child(save_button, 7)

    var load_button = terrain_brush.CreateButton("Load Biome", "res://ui/icons/menu/redo.png")
    load_button.connect("pressed", self, "load_biomes")
    terrain_brush.Align.move_child(load_button, 8)

    
# Utilities
func sync_biome():
    ## Sync currently set biome with terrain list
    var cur_biome = biomes.keys()[biome_dropdown.selected]
    log_info("Updating biome " + cur_biome)
    
    for i in range(0, terrain_list.get_item_count()):
        biomes[cur_biome][i] = Global.World.Level.Terrain.GetTexture(i).resource_path
    
func new_biome():
    ## Add a new biome to the biomes dictionary
    # TODO: Add ability to customize new biome name
    biomes["new_biome"] = ["", "", "", ""]
    update_biomes()

func save_biomes(): 
    # Save current biomes state to preset file
    log_info("Saving file " + BIOMES_PATH + "...")
    var file = File.new()
    file.open(BIOMES_PATH, File.WRITE)
    file.store_line(JSON.print(biomes, "\t"))
    file.close()

func load_biomes() -> int:
    log_info("Loading terrain presets...")

    # Populate biomes
    var file = File.new()
    file.open(BIOMES_PATH, File.READ)
    var line = file.get_as_text()
    biomes = JSON.parse(line).result
    file.close()

    if not biomes:
        log_err("Failed to load preset " + BIOMES_PATH)
        return -1

    # Override biome dropdown to link into script
    update_biomes()
    return 0

func update_biomes():
    log_info("Loading biomes...")
    biome_dropdown.clear()
    for biome in biomes.keys():
        biome_dropdown.add_item(biome)
    set_biome(0)

func set_biome(index):
    log_info("Setting biome to " + biomes.keys()[index])

    var textures = biomes[biomes.keys()[index]]
    for i in range(0, len(textures)):
        var texture = load_texture(textures[i])
        if texture:
            Global.World.Level.Terrain.SetTexture(texture, i)
            terrain_list.set_item_icon(i, texture)
            terrain_list.set_item_text(i, parse_resource_name(texture))
    

func load_texture(texture_path):
    log_info("Loading texture " + texture_path)
    if ResourceLoader.exists(texture_path):
        return ResourceLoader.load(texture_path)
    
    var image = Image.new()
    if image.load(texture_path) != 0:
        log_err(texture_path + " not found!")
        return null

    var image_texture = ImageTexture.new()
    image_texture.create_from_image(image)
    image_texture.resource_path = texture_path
    return image_texture

func parse_resource_name(resource) -> String:
    return resource.resource_path.split("/")[-1].split(".")[0].capitalize()

func popup_terrain_window(index):
    ## HACK: Wrapper function around the open terrain window buttons
    ## Currently it seems like the TerrainWindow is using the show
    ## method, which on hide does **not** emit the popup_hide signal.
    ## Thus this wrapper forces the window to 'Open' briefly, hides it
    ## immediately then popup immediately after
    var terrain_window = Master.Editor.TerrainWindow
    terrain_window.Open(index)
    terrain_window.hide()
    terrain_window.popup()

# Logging utilities
func log_info(msg):
    print("[terrain-presets] INFO: " + msg)

func log_warn(msg):
    print("[terrain-presets] WARN: " + msg)

func log_err(msg):
    print("[terrain-presets] ERR: " + msg)