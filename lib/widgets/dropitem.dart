import 'package:objd/core.dart';

class DropItem extends Widget {
  DropItem();

  @override
  Widget generate(Context context) {
    return If(
      Data.get(Entity.Selected(), path: "HandItems[0].Count"),
      Then: [
        Execute.at(Entity.Player(), children: [
          Summon(
            EntityType.item,
            tags: [
              context.packId + "Dropped",
            ],
            nbt: {
              "PickupDelay": 0,
              "Item": {
                "id": "minecraft:stone",
                "Count": 1,
              }
            },
          ),
          Data.modify(
            Entity(tags: [context.packId + "Dropped"], limit: 1)
                .sort(Sort.nearest),
            path: "Item",
            modify: DataModify.set(Entity.Selected(), fromPath: "HandItems[0]"),
          ),
        ]),
        Data.merge(Entity.Selected(), nbt: {"HandItems": []})
      ],
    );
  }
}
