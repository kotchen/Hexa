import 'package:flutter_test/flutter_test.dart';
import 'package:yi_app/src/content/classic_text.dart';
import 'package:yi_app/src/domain/hexagram.dart';

void main() {
  group('内容库完整性', () {
    test('六十四卦：卦序 1–64、全名唯一、与 HexagramMap 映射一致', () {
      expect(ClassicLibrary.all, hasLength(64));
      expect(ClassicLibrary.all.map((g) => g.number), equals(List.generate(64, (i) => i + 1)));
      expect(ClassicLibrary.all.map((g) => g.name).toSet(), hasLength(64));

      // 独立卦象表（通行本卦序 → 六爻阴阳，自下而上；1=阳 0=阴）
      const patterns = [
        '111111', '000000', '100010', '010001', '111010', '010111',
        '010000', '000010', '111011', '110111', '111000', '000111',
        '101111', '111101', '001000', '000100', '100110', '011001',
        '110000', '000011', '100101', '101001', '000001', '100000',
        '100111', '111001', '100001', '011110', '010010', '101101',
        '001110', '011100', '001111', '111100', '000101', '101000',
        '101011', '110101', '001010', '010100', '110001', '100011',
        '111110', '011111', '000110', '011000', '010110', '011010',
        '101110', '011101', '100100', '001001', '001011', '110100',
        '101100', '001101', '011011', '110110', '010011', '110010',
        '110011', '001100', '101010', '010101',
      ];
      for (var i = 0; i < 64; i++) {
        final lines = patterns[i].split('').map((c) => c == '1' ? 7 : 8).toList();
        expect(HexagramMap.nameFor(lines), ClassicLibrary.all[i].name,
            reason: '第 ${i + 1} 卦映射不符');
      }
    });

    test('每卦卦辞非空、六条爻辞非空；仅乾有用九、仅坤有用六', () {
      for (final g in ClassicLibrary.all) {
        expect(g.guaCi, isNotEmpty, reason: g.name);
        expect(g.yaoCi, hasLength(6));
        for (final y in g.yaoCi) {
          expect(y, isNotEmpty, reason: g.name);
        }
      }
      expect(ClassicLibrary.all.where((g) => g.yong9 != null).map((g) => g.name), ['乾为天']);
      expect(ClassicLibrary.all.where((g) => g.yong6 != null).map((g) => g.name), ['坤为地']);
    });

    test('用九用六内容正确', () {
      expect(ClassicLibrary.forName('乾为天').yong9, '见群龙无首，吉。');
      expect(ClassicLibrary.forName('坤为地').yong6, '利永贞。');
    });

    test('全部 64 卦解读已提供，不再有缺省 null（解读尚未完成）状态', () {
      final qian = ClassicLibrary.forName('乾为天');
      expect(qian.guaCiVernacular, isNotNull);
      expect(qian.yaoCiVernacular, isNotNull);
      expect(qian.yong9Vernacular, isNotNull);
      expect(qian.yong9Action, isNotNull);

      final gou = ClassicLibrary.forName('天风姤');
      expect(gou.guaCiVernacular, isNotNull); // 任务 01 已批准样例

      final sui = ClassicLibrary.forName('泽雷随'); // 第 17 卦
      expect(sui.guaCiVernacular, isNotNull);
      expect(sui.guaCiAction, isNotNull);
      expect(sui.yaoCiVernacular, isNotNull);
      expect(sui.yaoCiAction, isNotNull);

      final dun = ClassicLibrary.forNumber(33); // 遁，任务 04 补齐
      expect(dun.guaCiVernacular, isNotNull);
      expect(dun.guaCiAction, isNotNull);
      expect(dun.yaoCiVernacular, isNotNull);
      expect(dun.yaoCiAction, isNotNull);

      final jing = ClassicLibrary.forNumber(48); // 井，任务 05 补齐
      expect(jing.guaCiVernacular, isNotNull);
      expect(jing.yaoCiVernacular, isNotNull);

      // 任务 06：第 49–64 卦（革至未济）全部补齐。
      for (var n = 49; n <= 64; n++) {
        final g = ClassicLibrary.forNumber(n);
        expect(g.guaCiVernacular, isNotNull, reason: '${g.name} 卦辞白话');
        expect(g.guaCiAction, isNotNull, reason: '${g.name} 卦辞行动参考');
        expect(g.yaoCiVernacular, hasLength(6), reason: g.name);
        expect(g.yaoCiAction, hasLength(6), reason: g.name);
        for (var i = 0; i < 6; i++) {
          expect(g.yaoCiVernacular![i], isNotNull, reason: '${g.name} 第 ${i + 1} 爻白话');
          expect(g.yaoCiAction![i], isNotNull, reason: '${g.name} 第 ${i + 1} 爻行动参考');
        }
      }

      final wei = ClassicLibrary.forNumber(64); // 未济
      expect(wei.guaCiVernacular, isNotNull);
      expect(wei.yaoCiVernacular, isNotNull);
    });

    test('内容库提供出处与版本号', () {
      expect(ClassicLibrary.contentVersion, isNotEmpty);
      expect(ClassicLibrary.sourceCitation, contains('周易'));
      expect(ClassicLibrary.sourceCitation, contains('校核'));
    });
  });
}
