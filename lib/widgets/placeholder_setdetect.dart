import 'package:objd/core.dart';

class PlaceholderSetDetect extends Widget {
  Item placeholder;
  Item? guiModel;
  Block _block = Blocks.chest;

  PlaceholderSetDetect(this.placeholder, this.guiModel, bool useBarrel) {
    if (useBarrel) _block = Blocks.barrel;
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

        if (i == 15) {
          return If.not(
              // not empty
              // and not Result item
              Condition.and([
                Block.nbt(
                  _block,
                  nbt: {
                    'Items': [
                      {'Slot': Byte(15), 'Count': Byte(0)}
                    ]
                  },
                  strNbt: '{Items:[{Slot:15b,Count:0b}]}',
                ),
                Block.nbt(
                  _block,
                  nbt: {
                    'Items': [
                      {
                        'Slot': Byte(15),
                        'tag': {'${context.packId}Result': 1}
                      }
                    ]
                  },
                ),
              ]),
              then: [
                // clear it and drop it
                Data.modify(
                  Entity.Selected(),
                  path: 'HandItems[0]',
                  modify: DataModify.set(Location.here(),
                      fromPath: 'Items[{Slot:15b}]'),
                ),
                Data.remove(Location.here(), path: 'Items[{Slot:15b}]'),
              ]);
        }

        var replaceItem = placeholder;

        if (guiModel != null &&
            guiModel!.slot != null &&
            guiModel!.slot!.id == i) {
          replaceItem = guiModel!;
        }

        var throwItem = If.not(
          Condition.and([
            // not empty
            // and not Placeholder item
            Block.nbt(
              _block,
              nbt: {
                'Items': [
                  {'Slot': Byte(i), 'Count': Byte(0)}
                ]
              },
            ),
            Block.nbt(
              _block,
              nbt: {
                'Items': [
                  {
                    'Slot': Byte(i),
                    'tag': {'${context.packId}Placeholder': 1},
                  }
                ],
              },
            ),
          ]),
          then: [
            // Drop the Item
            Data.modify(
              Entity.Selected(),
              path: 'HandItems[0]',
              modify: DataModify.set(
                Location.here(),
                fromPath: 'Items[{Slot:${i}b}]',
              ),
            )
          ],
        );

        return For.of(
          [
            // drops item
            throwItem,
            If.not(
              // not Placeholder
              Block.nbt(
                _block,
                nbt: {
                  'Items': [
                    {'Slot': Byte(i)}
                  ],
                  'tag': {'${context.packId}Placeholder': 1}
                },
              ),
              then: [
                // set Placeholder
                ReplaceItem.block(
                  Location.here(),
                  slot: Slot.chest(i + 1),
                  item: replaceItem,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
