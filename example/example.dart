import 'package:objd/core.dart';
import 'package:objd_crafting/objd_crafting.dart';

main(List<String> args) {
  createProject(Project(
    name: "My Crafting Pack",
    target: "../",
    generate: BasicCraftingTable(),
  ));
}

class BasicCraftingTable extends Widget {
  BasicCraftingTable();

  @override
  Widget generate(Context context) {
    return CraftingTable(
      name: "craft",
      blockModel: Item(Block.crafting_table, count: 1),
      placeholder: Item(Block.gray_stained_glass_pane,
          count: 1, name: TextComponent("")),
      invisibleHitbox: false,
      recipes: [
        Recipe.fromJson(
          {
            "pattern": [
              "##",
              "##",
            ],
            "key": {
              "#": {"item": "minecraft:oak_planks"}
            },
            "result": {"item": "minecraft:crafting_table"}
          },
        )
      ],
    );
  }
}

class ComplexCraftingTable extends Widget {
  ComplexCraftingTable();

  @override
  Widget generate(Context context) {
    return CraftingTable(
      name: "craft",
      blockModel: Item(ItemType.sheep_spawn_egg, count: 1, model: 3190001),
      onDestroy: Summon(EntityType.item, location: Location.rel(y: 0.7), nbt: {
        "Item": Item(ItemType.sheep_spawn_egg,
            name: TextComponent("Custom Crafting Table", italic: false),
            count: 1,
            model: 3190001,
            nbt: {
              "EntityTag": Summon(EntityType.armor_stand,
                  tags: ["craftPlacer"],
                  nbt: {"Invisible": 1, "Small": 1}).getMap()
            }).getMap(),
      }),
      main: [
        Execute.asat(Entity(tags: ["craftPlacer"]), children: [
          File.execute("set", create: false),
          Command("playsound minecraft:block.wood.place block @a ~ ~ ~"),
          Kill(Entity.Selected())
        ])
      ],
      placeholder: Item(ItemType.stone_hoe,
          model: 3190001, count: 1, hideFlags: 63, name: TextComponent("")),
      guiModel: Item(ItemType.stone_hoe,
          slot: Slot.chest(1),
          model: 3190002,
          count: 1,
          hideFlags: 63,
          name: TextComponent("")),
      recipes: [
        Recipe.fromJson(
          {
            "pattern": [
              "##",
              "##",
            ],
            "key": {
              "#": {"item": "minecraft:oak_planks"}
            },
            "result": {"item": "minecraft:crafting_table"}
          },
        )
      ],
    );
  }
}
