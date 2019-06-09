import 'package:objd/basic/condition.dart';
import 'package:objd/basic/widgets.dart';
import 'package:objd/core.dart';

import 'checkarea.dart';
import 'chestfile.dart';
import 'getcommand.dart';
import 'recipe.dart';
import 'setarmorstand.dart';
/// The CraftingTable is the core widget to instantiate a custom crafter.
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

/// The CraftingTable is the core widget to instantiate a custom crafter. It generates a pack(with a custom namespace) itself as well as the needed functions depending on the inputs.
/// The Crafter is a modified chest with an armorstand inside to implement the logic.
/// 
/// | Constructor | (all optional) |
/// |--|--|
/// | name | your custom namespace for the pack and all the scores |
/// |displayName| a TextComponent for the name that is displayed in the GUI|
/// | id | the starting id of your recipes(automatically increases) |
/// | recipes | a list of your recipes|
/// | recipeSource | another file location for a recipe function|
/// |recipeResultSource |another file location for the result function|
/// |placeholder| an Item that blocks all the slots that are not used|
/// |guiModel| an Item that is retextured to display a GUI; replaces a placeholder by specifing the Slot of the Item|
/// |blockModel| replaces the head slot of the Armorstand to display a model for the block |
/// |invisibleHitbox|bool whether to include code to make the chest invisible(default = true)|
/// |useBarrel|set to true if you want to use a barrel instead|
/// |giveCommandFunction|bool whether to include a function to generate recipes in minecraft|
/// |main|a List of Widgets that are executed every tick|
/// |onDestroy| a Widget that is executed when the crafting table is destroyed|
///
/// After you specified all your wanted options and visuals, you get a fully working datapack. 
/// Ingame run the `set` function to create a new craftingtable at the current location. Obviously you can also trigger this with other packs as well.
/// In this craftingtable you can then use your specified recipes.
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
    if(id != null && recipes != null) recipes.forEach((rec) => rec.setid());
    if(displayName == null) displayName = TextComponent("Custom Crafting Table");
  }

  @override
  Widget generate(Context context) {

    return Pack(
        name: this.name,
        load: File("load"),
        main: File("main",
            child: For.of([
              /// Main File
              if(this.main != null) ...this.main,
              Execute(
                as: Entity(
                    type: EntityType.armor_stand, tags: [name + "Table"]),
                at: Entity.Selected(),
                If: Condition(
                  Entity.Player(distance: Range(to: 6)),
                ),
                /// runs subfunctions
                children: [
                   File.execute("checkarea",child:CheckArea(onDestroy,displayName,useBarrel,invisibleHitbox)),
                   File.execute("crafting",create: false),
                ]
              ),
            ])),
        files: [
          /// Crafting file
          File("crafting", child: ChestFile(recipes != null, recipeSource, recipeResultSource,placeholder,guiModel,useBarrel)),
          /// all Recipes
          if (recipes != null)
            File(
              "recipes/$name",
              child: For(
                to: recipes.length - 1,
                create: (i) => recipes[i].getCommands(packid: name,useBarrel: useBarrel),
              ),
            ),
          /// all Recipe Results
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