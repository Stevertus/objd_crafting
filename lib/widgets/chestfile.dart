import 'package:objd/core.dart';

import 'dropitem.dart';
import 'placeholder_setdetect.dart';

class ChestFile extends Widget {
  ChestFile(
    this.hasRecipes,
    this.recipeSource,
    this.recipeResultSource,
    this.placeholder,
    this.guiModel,
    this.useBarrel,
  ) {
    if (placeholder != null && placeholder.tag == null) {
      placeholder = placeholder.copyWith(nbt: {});
    }
    if (guiModel != null) {
      guiModel = guiModel.copyWith(
          nbt: guiModel.tag ?? {}, slot: guiModel.slot ?? Slot.chest(3, 5));
    }
  }

  bool hasRecipes = true;
  bool useBarrel;
  String recipeSource;
  String recipeResultSource;
  Item placeholder;
  Item guiModel;

  Score _resID;
  Score _resCount;
  Score _resDCount;

  @override
  Widget generate(Context context) {
    if (placeholder != null) {
      placeholder.tag['${context.packId}Placeholder'] = 1;
    }
    if (guiModel != null) guiModel.tag['${context.packId}Placeholder'] = 1;

    _resID = Score.fromSelected(context.packId + 'ID');
    _resCount = Score.fromSelected(context.packId + 'Count');
    _resDCount = Score.fromSelected(context.packId + 'dCount');

    return For.of([
      /// TAKE OUT
      _resCount.setToData(
          Data.get(Location.here(), path: 'Items[{Slot:15b}].Count')),
      If(
          // previous count is realistic and bigger than the current count
          // then someone took something out of the chest
          Condition.and([
            _resID.matchesRange(Range.from(0)),
            _resDCount.matchesRange(Range(1, 999)),
            _resDCount.isBigger(_resCount)
          ]),
          then: [
            // Difference saved in _resDCount
            _resDCount.subtractScore(_resCount),
            // For all crafting slots
            For(
                from: 1,
                to: 9,
                create: (int i) {
                  var myslot = Slot.craft(i);
                  var count = Score.fromSelected(context.packId + 'Count$i');
                  return For.of([
                    // get current count
                    Score(Entity.Selected(), context.packId + 'Count$i')
                        .setToData(Data.get(Location.here(),
                            path: 'Items[{Slot:${myslot.id}b}].Count')),
                    // the difference is subtracted from slots count
                    count.subtractScore(_resDCount),
                    // and saved again
                    Data.fromScore(Location.here(),
                        path: 'Items[{Slot:${myslot.id}b}].Count', score: count)
                  ]);
                }),
            Comment.Null(),
            _resDCount.reset()
          ]),

      /// Set Placeholders & Checks
      if (placeholder != null)
        For.of([
          // Replace Empty Slots with placeholder and set drop item
          PlaceholderSetDetect(placeholder, guiModel, useBarrel),
          // Clear Player Inventory for Placeholder
          Clear(Entity.All(distance: Range.to(4)), placeholder),
          if (guiModel != null)
            Clear(Entity.All(distance: Range.to(4)), guiModel),

          DropItem(),
        ]),

      // reset relevant scores
      _resID.reset(),
      _resCount.set(1000),
      // get all slot counts
      For(
          from: 1,
          to: 9,
          create: (int i) {
            var myslot = Slot.craft(i);
            return Score(Entity.Selected(), context.packId + 'Count$i')
                .setToData(
              Data.get(Location.here(),
                  path: 'Items[{Slot:${myslot.id}b}].Count'),
            );
          }),
      // Execute matching functions
      if (hasRecipes)
        File.execute('recipes/' + context.packId, create: false),
      if (recipeSource != null)
        File.execute(recipeSource, create: false),

      // matches Result
      If(_resID.matchesRange(Range.from(0)), targetFileName: 'hasid', then: [
        // find the final Count
        _resCount.findSmallest(
          List.generate(
            9,
            (int i) => Score.fromSelected(context.packId + 'Count${i + 1}'),
          ),
          min: 1,
        ),
        if (hasRecipes)
          File.execute('recipes/res_' + context.packId, create: false),
        if (recipeResultSource != null)
          File.execute(recipeResultSource, create: false),
        Data.fromScore(
          Location.here(),
          path: 'Items[{Slot:15b}].Count',
          score: _resCount,
        ),

        _resDCount.setEqual(_resCount),
      ]),
      // Else clear slot
      If.not(_resID.matchesRange(Range.from(0)),
          then: [Data.remove(Location.here(), path: 'Items[{Slot:15b}]')]),
    ]);
  }
}
