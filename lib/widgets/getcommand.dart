import 'package:objd/core.dart';

class GetCommand extends Widget {
  bool useBarrel;
  GetCommand(this.useBarrel);

  List<TextComponent> show = [];

  @override
  Widget generate(Context context) {
    show.add(TextComponent('execute if block ~ ~ ~ minecraft:${useBarrel ? 'chest' : 'barrel'}{"Items":[',color: Color.Yellow));
    for (var i = 1; i < 9; i++) {
      show.add(TextComponent.blockNbt(Location.here(),path:"Items[{Slot:${Slot.craft(i).id}b}]"));
    }
    show.add(TextComponent(']} run scoreboard players set @s ${context.packId}ID [change]'));

    return Tellraw(Entity.Selected(),show: show);
  }
}