var script_class = "tool"

# Script endpoint
func start():
    # Initialize biomes
    
    # Get terrain list 
    var terrain_brush = Global.Editor.Toolset.GetToolPanel("TerrainBrush")
    var terrain_list = terrain_brush.Align.get_child(7).get_child(0)
    print(terrain_list.get_item_icon(0))
    terrain_list.set_item_icon(0, terrain_list.get_item_icon(1))

func update(delta):
    # Get list of biomes
    var biomes = Global.Editor.Toolset.GetToolPanel("TerrainBrush").Align.get_child(6)
    for item in range(0, biomes.get_item_count()):
        print(biomes.get_item_text(item))