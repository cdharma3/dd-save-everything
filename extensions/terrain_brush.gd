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
    load_biomes()
    
    # Add save button to terrain list
    var save_button = terrain_brush.CreateButton("Save", "res://ui/icons/menu/save.png")
    save_button.connect("pressed", self, "load_biomes")
    
# Utilities
func load_biomes():
    var terrain_brush = Global.Editor.Toolset.ToolPanels["TerrainBrush"]
    var biome_dropdown = terrain_brush.Align.get_child(6)

    log_info("Loading terrain presets...")

    # Populate biomes
    var file = File.new()
    file.open(BIOMES_PATH, File.READ)
    biomes = JSON.parse_string(file.get_as_text())
    file.close()

    if !biomes:
        log_err("Failed to parse preset " + BIOMES_PATH)

    # Override biome dropdown to link into script
    biome_dropdown.clear()
    for biome in biomes.keys():
        biome_dropdown.add_item(biome)
    
    print(biome_dropdown.get_signals_)
    biome_dropdown.connect("item_selected", self, "set_biome")

func set_biome(index):
    var terrain_brush = Global.Editor.Toolset.ToolPanels["TerrainBrush"]
    var terrain_list = terrain_brush.Align.get_child(7).get_child(0)

    var textures = biomes[index]
    for i in range(0, len(textures)):
        var texture = load_texture(textures[i])
        Global.World.Level.Terrain.set_texture(i, texture)
        terrain_list.set_item_icon(i, texture)
        terrain_list.set_item_text(i, texture.get_display_name())
    

func load_texture(texture_path):
    if ResourceLoader.exists(texture_path):
        return ResourceLoader.load(texture_path)
    
    var image = Image.new()
    if image.load(texture_path) != 0:
        log_err(texture_path + " not found!")
        return null

    var image_texture = ImageTexture.create_from_image(image)
    image_texture.resource_path = texture_path
    return image_texture

func save_biomes(terrain_brush):
    # Load biomes from file, or create new biome file
    #var biomes_file = File.new()
    #biomes_file.open(BIOMES_PATH, File.WRITE_READ)
    #biomes = 
    print(Master.Library["Terrain"])
    #terrain_brush.ResetBiome(Global.World.Level)
    #Global.World.Level.Terrain.SetTexture(Global.World.Level.Terrain.GetTexture(1), 0)

# Logging utilities
func log_info(msg):
    print("[terrain-presets] INFO: " + msg)

func log_warn(msg):
    print("[terrain-presets] WARN: " + msg)

func log_err(msg):
    print("[terrain-presets] ERR: " + msg)