#!/usr/bin/env python3
"""按裁定记录把 classic_text.dart 的经文字段更新为最终底本内容。

数据源 = 参照库 + adjudicated-overrides.json 的裁定值；替换后运行 verify_classic.py。
"""
import json
import re

DART = "app/lib/src/content/classic_text.dart"
REF = ".scratch/yi-app/content/reference-wikisource.json"
OVR = ".scratch/yi-app/content/adjudicated-overrides.json"


def esc(s: str) -> str:
    assert "'" not in s and "\\" not in s, s
    return s


def main() -> None:
    src = open(DART, encoding="utf-8").read()
    ref = json.load(open(REF, encoding="utf-8"))
    ovr = json.load(open(OVR, encoding="utf-8"))
    ref_by_num = {int(k): v for k, v in ref.items()}

    pattern = re.compile(
        r"(GuaText\(\s*number:\s*(\d+),\s*name:\s*'[^']+',\s*)"
        r"guaCi:\s*'[^']*',\s*yaoCi:\s*\[.*?\],",
        re.S,
    )

    def repl(m: re.Match) -> str:
        num = int(m.group(2))
        r = ref_by_num[num]
        keys = list(r["yao"].keys())
        assert len(keys) == 6
        gua_ci = r["gua_ci"]
        yao = {i + 1: r["yao"][k] for i, k in enumerate(keys)}
        for key, item in ovr.items():
            n, field = key.split(",")
            if int(n) != num:
                continue
            if field == "gua_ci":
                gua_ci = item["value"]
            elif field.startswith("yao_"):
                yao[int(field[4:])] = item["value"]
            else:
                raise ValueError(f"未知字段 {field}")
        yao_lines = "".join(f"\n        '{esc(yao[i])}'," for i in range(1, 7))
        return (
            f"{m.group(1)}guaCi: '{esc(gua_ci)}',\n"
            f"      yaoCi: [{yao_lines}\n      ],"
        )

    new = pattern.sub(repl, src)
    open(DART, "w", encoding="utf-8").write(new)
    print(f"已应用 {len(ovr)} 条裁定。")


if __name__ == "__main__":
    main()
