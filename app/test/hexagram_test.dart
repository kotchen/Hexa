import 'package:flutter_test/flutter_test.dart';
import 'package:yi_app/src/domain/hexagram.dart';

void main() {
  group('卦象映射', () {
    test('全七为乾为天', () {
      expect(HexagramMap.nameFor([7, 7, 7, 7, 7, 7]), '乾为天');
    });

    test('全八为坤为地', () {
      expect(HexagramMap.nameFor([8, 8, 8, 8, 8, 8]), '坤为地');
    });

    test('乾初爻变（下卦转巽）为天风姤', () {
      expect(HexagramMap.nameFor([8, 7, 7, 7, 7, 7]), '天风姤');
    });

    test('坤初爻变（下卦转震）为地雷复', () {
      expect(HexagramMap.nameFor([7, 8, 8, 8, 8, 8]), '地雷复');
    });

    test('常用卦名抽查', () {
      expect(HexagramMap.nameFor([7, 8, 7, 8, 7, 8]), '水火既济');
      expect(HexagramMap.nameFor([8, 7, 8, 7, 8, 7]), '火水未济');
      expect(HexagramMap.nameFor([7, 7, 7, 8, 8, 8]), '地天泰');
      expect(HexagramMap.nameFor([8, 8, 8, 7, 7, 7]), '天地否');
    });
  });
}
