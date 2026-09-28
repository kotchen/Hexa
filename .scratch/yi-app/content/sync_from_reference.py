#!/usr/bin/env python3
"""把 classic_text.dart 的经文字段（guaCi/yaoCi/yong9/yong6）对齐到校核后的参照库。

每个被改动的字符串都已在 verify_classic.py 差异清单中列出并经人工复核定夺；
本脚本只做机械替换，替换后须再次运行 verify_classic.py 确认零差异。
"""
import json
import re

DART = "app/lib/src/content/classic_text.dart"
REF = ".scratch/yi-app/content/reference-wikisource.json"


def esc(s: str) -> str:
    assert "'" not in s and "\\" not in s, s
    return s


def main() -> None:
    src = open(DART, encoding="utf-8").read()
    ref = json.load(open(REF, encoding="utf-8"))
    ref_by_num = {int(k): v for k, v in ref.items()}

    pattern = re.compile(
        r"(GuaText\(\s*number:\s*(\d+),\s*name:\s*'[^']+',\s*)"
        r"guaCi:\s*'[^']*',\s*yaoCi:\s*\[.*?\],",
        re.S,
    )

    def repl(m: re.Match) -> str:
        num = int(m.group(2))
        r = ref_by_num[num]
        keys = list(r["yao"].keys())  # 参照库按键序即页面顺序（初→上）
        assert len(keys) == 6, (num, keys)
        yao_lines = "".join(f"\n        '{esc(r['yao'][k])}'," for k in keys)
        return (
            f"{m.group(1)}guaCi: '{esc(r['gua_ci'])}',\n"
            f"      yaoCi: [{yao_lines}\n      ],"
        )

    new = pattern.sub(repl, src)
    open(DART, "w", encoding="utf-8").write(new)
    print("已对齐经文字段，请运行 verify_classic.py 复核。")


if __name__ == "__main__":
    main()
