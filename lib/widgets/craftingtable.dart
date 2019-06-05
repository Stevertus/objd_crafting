import 'package:objd/basic/condition.dart';
import 'package:objd/basic/widgets.dart';
import 'package:objd/core.dart';

import 'checkarea.dart';
import 'chestfile.dart';
import 'getcommand.dart';
import 'recipe.dart';
import 'setarmorstand.dart';

class CraftingTable extends Widget {
  String name;
  TextComponent displayName;
  int id;
  List<Recipe> recipes;
  String recipeSource;
  String recipeResultSource;
  Item placeholder;
  Item guiModel;
  List<Widget> main;
  Item blockModel;
  Widget onDestroy;
  bool giveCommandFunction = false;
  bool useBarrel = false;
  bool invisibleHitbox;

  CraftingTable({
    this.name = "craft", 
    this.id = 0, 
    this.recipes, 
    this.recipeSource, 
    this.recipeResultSource,
    this.placeholder,
    this.blockModel,
    this.displayName,
    this.giveCommandFunction = false,
    this.onDestroy,
    this.guiModel,
    this.main,
    this.useBarrel = false,
    this.invisibleHitbox = true
    }) {
    Recipe.recipeId = id;
    if(displayName == null) displayName = TextComponent("Custom Crafting Table");
  }

  @override
  Widget generate(Context context) {

    return Pack(
        name: this.name,
        load: File("load"),
        main: File("main",
            child: For.of([
              // Main File
              if(this.main != null) ...this.main,
              Execute(
                as: Entity(
                    type: EntityType.armor_stand, tags: [name + "Table"]),
                at: Entity.Selected(),
                If: Condition(
                  Entity.Player(distance: Range(to: 6)),
                ),
                // runs subfunctions
                children: [
                   File.execute("checkarea",child:CheckArea(onDestroy,displayName,useBarrel,invisibleHitbox)),
                   File.execute("crafting",create: false),
                ]
              ),
            ])),
        files: [
          // Crafting file
          File("crafting", child: ChestFile(recipes != null, recipeSource, recipeResultSource,placeholder,guiModel,useBarrel)),
          // all Recipes
          if (recipes != null)
            File(
              "recipes/$name",
              child: For(
                to: recipes.length - 1,
                create: (i) => recipes[i].getCommands(packid: name,useBarrel: useBarrel),
              ),
            ),
          // all Recipe Results
          if (recipes != null)
            File(
              "recipes/res_$name",
              child: For(
                to: recipes.length - 1,
                create: (i) => recipes[i].getResult(packid: name),
              ),
            ),
          File("set",child: SetArmorstand(blockModel,displayName,useBarrel,invisibleHitbox)),
          if(giveCommandFunction != null && giveCommandFunction) File("getcommand",child:GetCommand(useBarrel))
        ]);
  }
}