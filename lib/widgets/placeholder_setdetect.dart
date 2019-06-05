import 'package:objd/core.dart';

class PlaceholderSetDetect extends Widget {
  Item placeholder;
  Item guiModel;
  Block _block = Block.chest;

  PlaceholderSetDetect(this.placeholder, this.guiModel, bool useBarrel){
    if(useBarrel != null && useBarrel) _block = Block.barrel;
  }

  @override
  Widget generate(Context context) {
    return For(
      to: 26,
      create: (int i) {
        // leave out used slots
        if (i > 0 && i < 4) return Comment.Null();
        if (i > 9 && i < 13) return Comment.Null();
        if (i > 18 && i < 22) return Comment.Null();

        if (i == 15)
          return If.not(
              // not empty
              // and not Result item
              Condition.and([
                Block.nbt(_block, strNbt: "{Items:[{Slot:15b,Count:0b}]}"),
                Block.nbt(_block,
                    strNbt:
                        "{Items:[{Slot:15b,tag:{${context.packId}Result:1}}]}"),
              ]),
              Then: [
                // clear it and drop it
                Data.modify(
                  Entity.Selected(),
                  path: "HandItems[0]",
                  modify: DataModify.set(Location.here(),
                      fromPath: "Items[{Slot:15b}]"),
                ),
                Data.remove(Location.here(), path: "Items[{Slot:15b}]"),
              ]);

        Item replaceItem = placeholder;

        if (guiModel != null &&
            guiModel.slot != null &&
            guiModel.slot.id == i) {
          replaceItem = guiModel;
        }

        If throwItem = If.not(
          Condition.and([
            // not empty
            // and not Placeholder item
            Block.nbt(_block, strNbt: "{Items:[{Slot:${i}b,Count:0b}]}"),
            Block.nbt(_block,
                strNbt:
                    "{Items:[{Slot:${i}b,tag:{${context.packId}Placeholder:1}}]}"),
          ]),
          Then: [
            // Drop the Item
            Data.modify(Entity.Selected(),
                path: "HandItems[0]",
                modify: DataModify.set(Location.here(),
                    fromPath: "Items[{Slot:${i}b}]"))
          ],
        );

        return For.of(
          [
            // drops item
            throwItem,
            If.not(
              // not Placeholder
              Block.nbt(_block,
                  strNbt:
                      "{Items:[{Slot:${i}b,tag:{${context.packId}Placeholder:1}}]}"),
              Then: [
                // set Placeholder
                ReplaceItem.block(Location.here(),
                    slot: Slot.chest(i + 1), item: replaceItem),
              ],
            ),
          ],
        );
      },
    );
  }
}
