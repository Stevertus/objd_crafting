import 'package:objd/core.dart';

class SetArmorstand extends Widget {
  Item blockModel;
  TextComponent displayName;
  bool useBarrel;
  bool invisible;

  SetArmorstand(
    this.blockModel,
    this.displayName,
    this.useBarrel,
    this.invisible,
  );

  @override
  Widget generate(Context context) {
    return For.of([
      Execute(
        children: [
          ArmorStand.staticMarker(
            Location.rel(y: -0.5),
            head: blockModel,
            small: true,
            tags: ['${context.packId}Table'],
          )
        ],
      ).center(),
      SetBlock(
        Block.nbt(
          useBarrel ? Blocks.barrel : Blocks.chest,
          states: useBarrel || !invisible ? {} : {'type': 'left'},
          nbt: {'CustomName': displayName.toJson()},
        ),
        location: Location.here(),
      )
    ]);
  }
}
