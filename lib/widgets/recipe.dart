
import 'dart:convert';

import 'package:objd/core.dart';
/// A basic recipe takes in ingredient Items with the slot and a result Item.
class Recipe {

  bool _isShapeless = false;
  bool exactlyPlaced = false;
  int exactResult;
  
  Item result;
  Map<int,Item> ingredients;

  int id; 
  Score _idScore;
  static int recipeId = 0;
/// The recipes of a craftingtable are instantiated in the recipes field. A basic recipe takes in ingredient Items with the slot and a result Item.
///
/// |Recipe|  |
/// |--|--|
/// | Map<slot,Item> | The ingredients as a Map with the Slot(1 to 9) on the one side and your Item on the other |
/// |Item| your result Item|
/// |id| overrides the automatically generated id(optional) |
/// |exactlyPlaced| bool that requires to leave all unused slots empty(default = false) |
/// |exactResult| a number that limits the result count(optional) |
///
/// **Example:**
/// ```dart
/// Recipe(
///           {
///             1: Item(Block.oak_planks),
///             2: Item(Block.oak_planks),
///             4: Item(Block.oak_planks),
///             5: Item(Block.oak_planks),
///           },
///           Item(Block.crafting_table,Count:2,nbt:{"MyNBT":1})
/// )
/// ```
/// You can also set the Count variable of any of the items to generate a ratio. In this case you craft 2 craftingtables out of 4 oak_planks.
  Recipe(this.ingredients,this.result,{this.id,this.exactlyPlaced = false,this.exactResult});

/// The API also supports shapeless crafting. That means you can set the ingredients in any shape and it would be the same result.
/// 
/// |Recipe.shapeless|  |
/// |--|--|
/// | List\<Item> | The ingredients in any shape(without slots) |
/// |...| stays the same|
///
/// **Example:**
///
/// ```dart
/// Recipe.shapeless(
///     [
///        Item(Block.oak_planks),
///        Item(ItemType.diamond)
///     ],
///     Item(ItemType.diamond_sword)
/// )
/// ```
  Recipe.shapeless(List<Item> ingreds,this.result,{this.id,this.exactlyPlaced = false,this.exactResult}){
    ingredients = {};
    for (var i = 0; i < ingreds.length; i++) {
      ingredients[i + 1] = ingreds[i];
    }
    _isShapeless = true;
  }
/// With objD you can also import usual minecraft recipes in json data. objD automatically parses that and converts it to a command.
  Recipe.fromJson(Map<String,dynamic> json,{this.id,this.exactlyPlaced = false,this.exactResult}){
    
    exists(String key,[value]){
      if(value != null) return json[key] != null && json[key] == value;
      return json[key] != null;
    }

    if(exists("type","minecraft:crafting_shapeless"))
      _isShapeless = true;
    int i = 1;
    if(exists("ingredients")) json["ingredients"].forEach((item){
      ingredients[i] = Item.fromJson(item);
      i++;
    });
    if(exists("result")) result = Item.fromJson(json["result"]);

    if(exists("pattern") && exists("key")){
      ingredients = {};
      Map<int,String> pattern = {};
      Map<String,dynamic> keys = json["key"];
      i = 1;
      json["pattern"].forEach((row){
        if(row.length > 0 && row[0] != " ") pattern[i] = row[0];
        if(row.length > 1 && row[1] != " ") pattern[i+1] = row[1];
        if(row.length > 2 && row[2] != " ") pattern[i+2] = row[2];
        i+= 3;
      });
      pattern.forEach((int i,String key){
        ingredients[i] = Item.fromJson(keys[key]);
      });
    }
  }

  setid(){
    if(this.id != null) return;

    id = recipeId;
    recipeId++;
  }
  
  Widget getCommands({String packid = "tpcraft",bool useBarrel = false}){
    Block _block = Block.chest;
    if(useBarrel != null && useBarrel) _block = Block.barrel; 
     _idScore = Score.fromSelected(packid + "ID");
    List<Map> items = [];
    List<Widget> res = [];
    List<int> unused = [1,2,3,4,5,6,7,8,9];

    ingredients.forEach((int i,Item it){
      if(i < 1 || i > 9) throw("Please insert a number between 1 and 9 as recipe ingredient!");
      unused.remove(i);
      Item cloned = Item.clone(it);
      cloned.count = null;
      cloned.slot = Slot.craft(i);
      if(_isShapeless) cloned.slot = null;
      items.add(cloned.getMap());

      if(it.count != null && it.count > 0){
        Score mycount = Score.fromSelected(packid + "Count$i");
        res.addAll([
            Extend("load",child:Score.con(it.count)),
            If.not(mycount.matchesRange(Range(from: it.count)),Then:[mycount.reset()]), 
            mycount.divideByScore(Score.con(it.count))
        ]);
      }

    });

    List<Condition> unusedConditions = [];
    if(exactlyPlaced) unused.forEach((i){
      unusedConditions.add(
        Condition.not(
          Block.nbt(_block,strNbt: '{"Items":[{"Slot":${Slot.craft(i).id}b}]}'),
        )
      );
    });

    String strItems = "";
    strItems = json.encode(items);
    strItems = strItems.replaceAllMapped(RegExp(r'"Slot":\d+'), (match) => "${match.group(0)}b");


    If setid = If(
      Condition.and([
        Block.nbt(_block,strNbt: '{"Items":$strItems}'),
        if(unusedConditions.length > 0) ...unusedConditions
      ]),
        Then:[
          _idScore.set(this.id)
        ]
      );

    return For.of([
      setid,
      if(res.length > 0)
      If(_idScore.matches(this.id),Then:res,encapsulate: false)]
      );
  }

  Widget getResult({String packid = "tpcraft"}){
    Score _resScore = Score.fromSelected(packid + "Count");
     _idScore = Score.fromSelected(packid + "ID");
    Widget replace = ReplaceItem.block(Location.here(),slot:Slot.Container15,item:result);
    Widget count;
    if(result.count != null) {
      count = For.of([
        Extend("load",child:Score.con(result.count)),
        _resScore.multiplyByScore(Score.con(result.count)) 
      ]);
    }
    return If(_idScore.matches(id),Then: [
      replace,
      count,
      if(exactResult != null && exactResult > 0) If(_resScore.matchesRange(Range(from: exactResult + 1)),Then:[_resScore.set(exactResult)])
    ]);
    
  }

}