var script_class = "tool"

# HACK: Reference to Master node, needed because 
# it is not exposed in the modding api directly
var Master: Node

# Script constants
# TODO: Add support for multiple biome presets in the future
const BIOMES_PATH: String = "user://preset1.dungeondraft_biomes"

# Biome dictionary
var biomes: Dictionary

# Script entry point
func start():
    # Set Master
    Master = Global.Editor.get_parent()

    # Init global variables
    var terrain_brush = Global.Editor.Toolset.ToolPanels["TerrainBrush"]

    # Load biomes into biomes dictionary, then override
    # the default biomes terrain set with our own
    if load_biomes() != 0:
        log_err("Some sort of error when loading biomes!")

    # Add save button to terrain list
    var save_button = terrain_brush.CreateButton("Save", "res://ui/icons/menu/save.png")
    save_button.connect("pressed", self, "load_biomes")
    
# Utilities
func load_biomes() -> int:
    var terrain_brush = Global.Editor.Toolset.ToolPanels["TerrainBrush"]
    var biome_dropdown = terrain_brush.Align.get_child(6)

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
    log_info("Overriding biome dropdown menu...")
    biome_dropdown.clear()
    for biome in biomes.keys():
        biome_dropdown.add_item(biome)
    
    var conns = biome_dropdown.get_signal_connection_list("item_selected")
    biome_dropdown.disconnect("item_selected", conns[0].target, conns[0].method)
    biome_dropdown.connect("item_selected", self, "set_biome")
    return 0

func set_biome(index):
    log_info("Setting biome " + biomes.keys()[index])
    var terrain_brush = Global.Editor.Toolset.ToolPanels["TerrainBrush"]
    var terrain_list = terrain_brush.Align.get_child(7).get_child(0)

    var textures = biomes[biomes.keys()[index]]
    for i in range(0, len(textures)):
        var texture = load_texture(textures[i])
        Global.World.Level.Terrain.SetTexture(texture, i)
        terrain_list.set_item_icon(i, texture)
        terrain_list.set_item_text(i, parse_resource_name(texture))
    

func load_texture(texture_path):
    log_info("Loading texture " + texture_path + "...")
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

# Logging utilities
func log_info(msg):
    print("[terrain-presets] INFO: " + msg)

func log_warn(msg):
    print("[terrain-presets] WARN: " + msg)

func log_err(msg):
    print("[terrain-presets] ERR: " + msg)