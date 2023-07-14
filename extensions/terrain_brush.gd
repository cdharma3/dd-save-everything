var script_class = "tool"

# Script entry point
func start():
    # Load biomes from file, or create new biome file
    var biomes_file = File.new()
    biomes_file.open("user://se_biomes.txt", File.WRITE_READ)

    # Initialize biomes
    var biomes = Global.Editor.Toolset.GetToolPanel("TerrainBrush").Align.get_child(6)
    for item in range(0, biomes.get_item_count()):
        print(biomes.get_item_text(item))

    # Get terrain list 
    var terrain_brush = Global.Editor.Toolset.GetToolPanel("TerrainBrush")
    var terrain_list = terrain_brush.Align.get_child(7).get_child(0)
    print(terrain_list.get_item_icon(0))
    terrain_list.set_item_icon(0, terrain_list.get_item_icon(1))

func update(delta):
    print(Global.Editor.Toolset.GetToolPanel("TerrainBrush").Align.get_child(7).get_child(0))
    var test_ter = Global.Editor.Toolset.GetToolPanel("TerrainBrush").Align.get_child(7).get_child(0)
    test_ter.set_item_icon(0, test_ter.get_item_icon(1))
    test_ter.set_item_text(0, test_ter.get_item_text(1))