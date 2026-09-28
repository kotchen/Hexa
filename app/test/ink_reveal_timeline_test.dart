import 'package:flutter_test/flutter_test.dart';
import 'package:yi_app/src/ui/ink_reveal_timeline.dart';

void main() {
  // 独立期望来自 ADR-0004：前导 300ms；每爻周期 400ms（生长 250 + 停顿 150）；
  // 变爻落定后 200ms 墨→朱；末爻后 300ms 进结果页；全程 3000ms。
  const changing = [9, 7, 6, 8, 7, 7]; // 初爻老阳、三爻老阴为变爻

  InkRevealTimeline timeline([List<int>? lines]) =>
      InkRevealTimeline(lines: lines ?? changing);

  group('自下而上逐爻生长', () {
    test('t=0 时六爻皆未开始', () {
      final f = timeline().frameAt(0);
      for (final yao in f) {
        expect(yao.grow, 0);
        expect(yao.settled, isFalse);
      }
    });

    test('前导期爻不开始：t=299 初爻仍未开始', () {
      expect(timeline().frameAt(299)[0].grow, 0);
    });

    test('t=300 初爻开始生长，进度为 0', () {
      final yao = timeline().frameAt(300)[0];
      expect(yao.grow, 0);
      expect(yao.settled, isFalse);
    });

    test('生长中点进度 0.5：t=425 初爻生长过半', () {
      expect(timeline().frameAt(425)[0].grow, 0.5);
    });

    test('t=550 初爻落定（生长 250ms 完成）', () {
      expect(timeline().frameAt(550)[0].settled, isTrue);
    });

    test('同刻上一爻已定、下一爻未开始：t=900 初爻已定、二爻生长 0.8、三爻未开始', () {
      final f = timeline().frameAt(900);
      expect(f[0].settled, isTrue);
      expect(f[1].grow, closeTo(0.8, 1e-9)); // (900-700)/250
      expect(f[2].grow, 0);
    });
  });

  group('变爻先墨后朱', () {
    test('落定瞬间仍是墨：t=550 初爻（老阳）朱色进度 0', () {
      expect(timeline().frameAt(550)[0].vermilion, 0);
    });

    test('转朱中点：t=650 初爻朱色进度 0.5', () {
      expect(timeline().frameAt(650)[0].vermilion, 0.5);
    });

    test('转朱完成：t=750 初爻朱色进度 1', () {
      expect(timeline().frameAt(750)[0].vermilion, 1);
    });

    test('不变爻始终不转朱：二爻（少阳）在任意时刻朱色进度为 0', () {
      final t = timeline();
      for (final ms in [550, 650, 750, 1000, 2000, 2999]) {
        expect(t.frameAt(ms)[1].vermilion, 0, reason: 't=$ms');
      }
    });

    test('老阴同老阳：t=1550+200 三爻（老阴）朱色进度 1', () {
      // 三爻（i=2）起点 300+2*400=1100，落定 1350，转朱完成 1550。
      expect(timeline().frameAt(1550)[2].vermilion, 1);
      expect(timeline().frameAt(1450)[2].vermilion, closeTo(0.5, 1e-9));
    });
  });

  group('全程时序', () {
    test('上爻起点 2300、落定 2550', () {
      final t = timeline();
      expect(t.frameAt(2299)[5].grow, 0);
      expect(t.frameAt(2300)[5].grow, 0);
      expect(t.frameAt(2550)[5].settled, isTrue);
    });

    test('t=2999 未结束，t=3000 完成', () {
      final t = timeline();
      expect(t.isFinished(2999), isFalse);
      expect(t.isFinished(3000), isTrue);
    });
  });
}
