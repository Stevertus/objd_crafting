import 'package:objd/core.dart';

/// Checks the Location of the chest before starting the crafting process
class CheckArea extends Widget {
  Widget onDestroy;
  TextComponent displayName;
  Block _block = Block.chest;
  bool invisible;

  CheckArea(this.onDestroy, this.displayName,bool isBarrel, this.invisible) {
    if(isBarrel != null && isBarrel){
      _block = Block.barrel;
      invisible = false;
    } 
    _setTable = SetBlock(
        Block.nbt(_block,
            states: invisible ? {"type": "left"} : null,
            nbt: displayName != null ? {"CustomName": displayName.toJson()} : null),
        location: Location.here());
  }
  

  SetBlock _setTable;

  @override
  Widget generate(Context context) {
    return For.of([
      // add Result nbt tag to divide result and usual items
      If(Score.fromSelected(context.packId + "ID").matchesRange(Range(from: 0)),
          Then: [
            Data.modify(Location.here(),
                path: "Items[{Slot:15b}].tag.${context.packId}Result",
                modify: DataModify.set(1)),
          ]),
      // break detection
      If.not(_block, Then: [
        Kill(Entity(type: EntityType.item, nbt: {
          "Item": {
            "tag": {"${context.packId}Placeholder": 1}
          }
        })),
        Kill(Entity(type: EntityType.item, nbt: {
          "Item": {
            "id": _block.toString()
          }
        })),
        Kill(Entity(type: EntityType.item, nbt: {
          "Item": {
            "tag": {"${context.packId}Result": 1}
          }
        })),
        if (onDestroy != null) onDestroy,
        Kill(Entity.Selected())
      ]),
      // testing for block in east direction(which updates state)
      if(invisible) If(
          // block is there, but table did not yet recognize
          Condition.and([
            Location.rel(x: 1),
            Condition.not(
                Tag("${context.packId}BlockE", entity: Entity.Selected()))
          ]),
          Then: [
            _setTable,
            Entity.Selected().addTag("${context.packId}BlockE")
          ]),
      if(invisible) If(
          // block is not there anymore, but table has tag still
          Condition.and([
            Condition.not(Location.rel(x: 1)),
            Tag("${context.packId}BlockE", entity: Entity.Selected())
          ]),
          Then: [
            _setTable,
            Entity.Selected().removeTag("${context.packId}BlockE")
          ]),
    ]);
  }
}
