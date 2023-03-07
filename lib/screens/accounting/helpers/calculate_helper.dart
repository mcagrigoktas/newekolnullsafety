class AccountingCalculateHelper {
  AccountingCalculateHelper._();
  static List<double> amountToInstallament(double? amount, int installamentCount, [bool allEqual = false]) {
    if (allEqual) {
      return Iterable.generate(installamentCount).map((e) => amount! / installamentCount).toList();
    }
    var _i1 = (amount! / installamentCount).ceil();
    while (_i1 % 5 != 0) _i1--;
    final _artan = amount - installamentCount * _i1;

    final _i2 = [
      ...Iterable.generate(installamentCount).map((e) => _i1.toDouble()).toList(),
    ];

    for (var _i = 0; _i < (_artan / 5) - 1; _i++) {
      _i2[_i] += 5;
    }
    final _artan2 = (amount - _i2.fold<double>(0.0, (p, e) => p + e));
    if (_artan2 > 0) {
      _i2.first += _artan2;
    } else {
      _i2.last += _artan2;
    }
    return _i2;
  }
}
