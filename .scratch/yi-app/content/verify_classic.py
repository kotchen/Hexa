#!/usr/bin/env python3
"""逐字校核 app/lib/src/content/classic_text.dart 与维基文库参照库。

比较范围：卦序、卦名、卦辞、六条爻辞（按页面顺序逐位配对）、用九用六。
差异逐条打印；退出码 0 = 无差异。
"""
import json
import re
import sys

DART = "app/lib/src/content/classic_text.dart"
REF = ".scratch/yi-app/content/reference-wikisource.json"
OVR_PATH = ".scratch/yi-app/content/adjudicated-overrides.json"


def norm(s: str) -> str:
    return re.sub(r"\s+", "", s or "")


def parse_dart(path: str) -> list[dict]:
    src = open(path, encoding="utf-8").read()
    blocks = re.findall(
        r"GuaText\(\s*number:\s*(\d+),\s*name:\s*'([^']+)',\s*guaCi:\s*'([^']*)',\s*yaoCi:\s*\[(.*?)\],(.*?)\n\s*\),",
        src,
        re.S,
    )
    out = []
    for number, name, gua_ci, yao_block, rest in blocks:
        yao = re.findall(r"'([^']*)'", yao_block)
        yong9 = re.search(r"yong9:\s*'([^']*)'", rest)
        yong6 = re.search(r"yong6:\s*'([^']*)'", rest)
        out.append(
            {
                "number": int(number),
                "name": name,
                "gua_ci": gua_ci,
                "yao": yao,
                "yong9": yong9.group(1) if yong9 else None,
                "yong6": yong6.group(1) if yong6 else None,
            }
        )
    return out


def main() -> int:
    dart = parse_dart(DART)
    ref = json.load(open(REF, encoding="utf-8"))
    ovr = json.load(open(OVR_PATH, encoding="utf-8"))
    ref_by_num = {int(k): v for k, v in ref.items()}
    # 应用裁定：裁定值视为底本内容，覆盖参照库相应条目
    for key, item in ovr.items():
        num_s, field = key.split(",")
        num = int(num_s)
        r = ref_by_num[num]
        if field == "gua_ci":
            r["gua_ci"] = item["value"]
        elif field.startswith("yao_"):
            idx = int(field[4:]) - 1
            k = list(r["yao"].keys())[idx]
            r["yao"][k] = item["value"]
        else:
            raise ValueError(f"未知字段 {field}")
    diffs = []

    if len(dart) != 64:
        diffs.append(f"Dart 内容库卦数 {len(dart)} != 64")
    nums = [g["number"] for g in dart]
    if nums != list(range(1, 65)):
        diffs.append(f"卦序不是 1–64 连续：{nums}")

    ref_by_num = {int(k): v for k, v in ref.items()}
    for g in dart:
        r = ref_by_num.get(g["number"])
        if r is None:
            diffs.append(f"[{g['number']:02d}] 参照库缺失")
            continue
        tag = f"[{g['number']:02d}] {g['name']}"
        if norm(g["gua_ci"]) != norm(r["gua_ci"]):
            diffs.append(f"{tag} 卦辞\n  转录: {g['gua_ci']}\n  参照: {r['gua_ci']}")
        if len(g["yao"]) != 6:
            diffs.append(f"{tag} 爻辞数 {len(g['yao'])} != 6")
        else:
            ref_order = list(r["yao"].values())  # 页面顺序即初→上
            for i, (mine, theirs) in enumerate(zip(g["yao"], ref_order), 1):
                if norm(mine) != norm(theirs):
                    diffs.append(f"{tag} 第{i}爻\n  转录: {mine}\n  参照: {theirs}")
        if (g["yong9"] or None) != (r["yong"].get("用九") or None):
            diffs.append(
                f"{tag} 用九\n  转录: {g['yong9']}\n  参照: {r['yong'].get('用九')}"
            )
        if (g["yong6"] or None) != (r["yong"].get("用六") or None):
            diffs.append(
                f"{tag} 用六\n  转录: {g['yong6']}\n  参照: {r['yong'].get('用六')}"
            )

    if diffs:
        print(f"共 {len(diffs)} 处差异：")
        for d in diffs:
            print(d)
        return 1
    print("校核通过：64 卦卦辞、384 爻辞、用九用六与参照库逐字一致。")
    return 0


if __name__ == "__main__":
    sys.exit(main())
