import 'package:objd/core.dart';

extension Generator on Recipe {
  Widget getCommands({String packid = 'tpcraft', bool useBarrel = false}) {
    var _block = Blocks.chest;
    if (useBarrel != null && useBarrel) _block = Blocks.barrel;
    final _idScore = Score.fromSelected(packid + 'ID');
    var items = <Map>[];
    var res = <Widget>[];
    var unused = <int>[1, 2, 3, 4, 5, 6, 7, 8, 9];

    ingredients.forEach((int i, Item it) {
      if (i < 1 || i > 9) {
        throw ('Please insert a number between 1 and 9 as recipe ingredient!');
      }
      unused.remove(i);
      var cloned = it.copyWith(
        count: null,
        slot: type == RecipeType.shapeless ? null : Slot.craft(i),
      );
      items.add(cloned.getMap());

      if (it.count != null && it.count > 0) {
        var mycount = Score.fromSelected(packid + 'Count$i');
        res.addAll([
          Extend('load', child: Score.con(it.count)),
          If.not(
            mycount.matchesRange(Range.from(it.count)),
            then: [mycount.reset()],
          ),
          mycount.divideByScore(
            Score.con(it.count),
          )
        ]);
      }
    });

    var unusedConditions = <Condition>[];
    if (exactlyPlaced) {
      unused.forEach((i) {
        unusedConditions.add(Condition.not(
          Block.nbt(_block, nbt: {
            'Items': [
              {'Slot': Slot.craft(i).id}
            ]
          }),
        ));
      });
    }

    // var strItems = '';
    // strItems = json.encode(items);
    // strItems = strItems.replaceAllMapped(
    //     RegExp(r'"Slot":\d+'), (match) => '${match.group(0)}b');

    var setid = If(
      Condition.and([
        Block.nbt(_block, nbt: {'Items': items}),
        if (unusedConditions.isNotEmpty) ...unusedConditions
      ]),
      then: [_idScore.set(id)],
    );

    return For.of([
      setid,
      if (res.isNotEmpty)
        If(_idScore.matches(id), then: res, encapsulate: false)
    ]);
  }

  static int recipeId = 0;
  Recipe setid() {
    if (id != null) return this;
    final r = Recipe(
      ingredients,
      result,
      name: name,
      id: recipeId,
      exactlyPlaced: exactlyPlaced,
      exactResult: exactResult,
      type: type,
    );
    recipeId += 1;
    return r;
  }

  Widget getResult({String packid = 'tpcraft'}) {
    final _resScore = Score.fromSelected(packid + 'Count');
    final _idScore = Score.fromSelected(packid + 'ID');
    Widget replace = ReplaceItem.block(Location.here(),
        slot: Slot.Container15, item: result);
    Widget count;
    if (result.count != null) {
      count = For.of([
        Extend('load', child: Score.con(result.count)),
        _resScore.multiplyByScore(Score.con(result.count))
      ]);
    }
    return If(_idScore.matches(id), then: [
      replace,
      count,
      if (exactResult != null && exactResult > 0)
        If(_resScore.matchesRange(Range.from(exactResult + 1)),
            then: [_resScore.set(exactResult)])
    ]);
  }
}
