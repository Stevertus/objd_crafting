# Crafting API
The objd_crafting extension for objD gives you a customizable API for a Craftingtable, that works with nbt data.
This documentation focuses on the **CraftingTable** and **Recipe** Widgets and generating a crafting package with objD. If you want to use template packages or the online generator, take a look at this article:  [https://stevertus.com/tools/objd_crafting](https://stevertus.com/tools/objd_crafting) 
## Installation
To install the crafting module just include `objd_crafting` in the pubspec.yaml:
```yaml
dependencies:
  ...
  objd_crafting:
  ...
```
## CraftingTable
The CraftingTable is the core widget to instantiate a custom crafter. It generates a pack(with a custom namespace) itself as well as the needed functions depending on the inputs.
The Crafter is a modified chest with an armorstand inside to implement the logic.

| Constructor | (all optional) |
|--|--|
| name | your custom namespace for the pack and all the scores |
|displayName| a TextComponent for the name that is displayed in the GUI|
| id | the starting id of your recipes(automatically increases) |
| recipes | a list of your recipes|
| recipeSource | another file location for a recipe function|
|recipeResultSource |another file location for the result function|
|placeholder| an Item that blocks all the slots that are not used|
|guiModel| an Item that is retextured to display a GUI; replaces a placeholder by specifing the Slot of the Item|
|blockModel| replaces the head slot of the Armorstand to display a model for the block |
|invisibleHitbox|bool whether to include code to make the chest invisible(default = true)|
|useBarrel|set to true if you want to use a barrel instead|
|giveCommandFunction|bool whether to include a function to generate recipes in minecraft|
|main|a List of Widgets that are executed every tick|
|onDestroy| a Widget that is executed when the crafting table is destroyed|

After you specified all your wanted options and visuals, you get a fully working datapack. 
Ingame run the `set` function to create a new craftingtable at the current location. Obviously you can also trigger this with other packs as well.
In this craftingtable you can then use your specified recipes.
## Recipes
The recipes of a craftingtable are instantiated in the recipes field. A basic recipe takes in ingredient Items with the slot and a result Item.

|Recipe|  |
|--|--|
| Map<slot,Item> | The ingredients as a Map with the Slot(1 to 9) on the one side and your Item on the other |
|Item| your result Item|
|id| overrides the automatically generated id(optional) |
|exactlyPlaced| bool that requires to leave all unused slots empty(default = false) |
|exactResult| a number that limits the result count(optional) |

**Example:**
```dart
Recipe(
          {
            1: Item(Blocks.oak_planks),
            2: Item(Blocks.oak_planks),
            4: Item(Blocks.oak_planks),
            5: Item(Blocks.oak_planks),
          },
          Item(Blocks.crafting_table,Count:2,nbt:{"MyNBT":1})
)
```
You can also set the Count variable of any of the items to generate a ratio. In this case you craft 2 craftingtables out of 4 oak_planks.

### Recipe.shapeless
The API also supports shapeless crafting. That means you can set the ingredients in any shape and it would be the same result.
 
|Recipe.shapeless|  |
|--|--|
| List\<Item> | The ingredients in any shape(without slots) |
|...| stays the same|

**Example:**

```dart
Recipe.shapeless(
    [
       Item(Blocks.oak_planks),
       Item(Items.diamond)
    ],
    Item(Items.diamond_sword)
)
```
### Recipe.fromJson
With objD you can also import usual minecraft recipes in json data. objD automatically parses that and converts it to a command.

|Recipe.fromJson|  |
|--|--|
| Map | The recipe in json form |
|...| stays the same|

**Example:**

```dart
Recipe.fromJson(
  {
	"type": "minecraft:crafting_shaped",
    "pattern": [
      "## ",
      "## ",
      "   "
    ],
    "key": {
      "#": {"item": "minecraft:oak_planks"}
    },
    "result": {
	    "item": "minecraft:crafting_table",
	    "Count": 2
	    "nbt": {
				"MyNBT":1
		}
    }
  }
)
```
Which would result into the same recipe as the beginning. Also note that the json is extended by the Count and nbt properties as well.

**Example with shapeless crafting:**

```dart
Recipe.fromJson(
{
    "type": "minecraft:crafting_shapeless",
    "ingredients": [
        {
            "item": "minecraft:oak_planks"
        },
        {
            "item": "minecraft:diamond"
        }
    ],
    "result": {
        "item": "minecraft:diamond_sword"
    }
}
)
```
