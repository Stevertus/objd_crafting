
import 'dart:convert';

import 'package:objd/core.dart';

class Recipe {

  bool _isShapeless = false;
  bool exactlyPlaced = false;
  int exactResult;
  
  Item result;
  Map<int,Item> ingredients;

  int id; 
  Score _idScore;
  static int recipeId = 0;

  Recipe(this.ingredients,this.result,{this.id,this.exactlyPlaced = false,this.exactResult}){
    _getid();
  }

  Recipe.shapeless(List<Item> ingreds,this.result,{this.id,this.exactlyPlaced = false,this.exactResult}){
    ingredients = {};
    for (var i = 0; i < ingreds.length; i++) {
      ingredients[i + 1] = ingreds[i];
    }
    _getid();
    _isShapeless = true;
  }

  Recipe.fromJson(Map<String,dynamic> json,{this.id,this.exactResult}){
    
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
    _getid();
  }

  _getid(){
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
      if(exactResult != null && exactResult > 0) _resScore.set(exactResult)
    ]);
    
  }

}