#!/usr/bin/env python3
"""抓取维基文库《周易》通行本 64 卦经文（卦辞、爻辞、用九/用六），转简体后存为参照库。

仅用于校核本任务独立转录的内容库，不作为内容库本身。
"""
import json
import re
import subprocess
import sys
import time

from opencc import OpenCC

T2S = OpenCC("t2s")

# 通行本卦序 1–64 → 维基文库子页面名（繁体）
PAGES = [
    "乾", "坤", "屯", "蒙", "需", "訟", "師", "比",
    "小畜", "履", "泰", "否", "同人", "大有", "謙", "豫",
    "隨", "蠱", "臨", "觀", "噬嗑", "賁", "剝", "復",
    "无妄", "大畜", "頤", "大過", "坎", "離", "咸", "恆",
    "遯", "大壯", "晉", "明夷", "家人", "睽", "蹇", "解",
    "損", "益", "夬", "姤", "萃", "升", "困", "井",
    "革", "鼎", "震", "艮", "漸", "歸妹", "豐", "旅",
    "巽", "兌", "渙", "節", "中孚", "小過", "既濟", "未濟",
]

YAO_NAMES = ("初九", "九二", "九三", "九四", "九五", "上九",
             "初六", "六二", "六三", "六四", "六五", "上六", "用九", "用六")


def fetch_wikitext(page: str) -> str:
    url = f"https://zh.wikisource.org/wiki/周易/{page}?action=raw"
    for attempt in range(5):
        try:
            out = subprocess.run(
                ["curl", "-sL", "--max-time", "60", url],
                capture_output=True, text=True, check=True,
            )
        except subprocess.CalledProcessError:
            time.sleep(2 + attempt * 2)
            continue
        if out.stdout.startswith("-{") or "易經" in out.stdout:
            return out.stdout
        time.sleep(2 + attempt * 2)
    raise RuntimeError(f"{page} 抓取失败")


def clean(s: str) -> str:
    """去掉维基标记、转换标记，保留正文汉字与标点；{{另|正|异}} 保留正文字。"""
    s = s.replace("-{", "").replace("}-", "")
    s = re.sub(r"\{\{另\|([^|}]*)\|[^}]*\}\}", r"\1", s)
    s = re.sub(r"\{\{[^}]*\}\}", "", s)
    s = re.sub(r"<[^>]*>", "", s)
    s = re.sub(r"''+", "", s)
    s = re.sub(r"^[*#]+\s*", "", s)
    return s.strip()


def extract_jing(wikitext: str, page: str) -> dict:
    """从单卦页面提取卦辞、六条爻辞、用九/用六。

    易经段内：** 开头为卦辞行（卦名可能与正文连写），*# 开头为爻辞行，
    分隔符允许 ：或 ，（否卦等用逗号）。
    """
    m = re.search(r"易經：(.*?)\n\s*\n", wikitext, re.S)
    if not m:
        raise ValueError(f"{page} 未找到易經段")
    block = m.group(1)

    gua_ci = None
    yao = {}
    yong = {}
    for raw in block.splitlines():
        is_yao = raw.lstrip().startswith("*#")
        x = clean(raw)
        if not x:
            continue
        if is_yao:
            ym = re.match(
                r"^(初九|九二|九三|九四|九五|上九|初六|六二|六三|六四|六五|上六|用九|用六)\s*[:：，,]\s*(.+)$",
                x,
            )
            if ym:
                pos, text = ym.group(1), ym.group(2).strip()
                if pos in ("用九", "用六"):
                    yong[pos] = text
                else:
                    yao[pos] = text
        elif gua_ci is None:
            gua_ci = re.sub(r"\s+", "", x)
    return {"gua_ci": gua_ci, "yao": yao, "yong": yong}


def main() -> None:
    result = {}
    for i, page in enumerate(PAGES, 1):
        wt = fetch_wikitext(page)
        data = extract_jing(wt, page)
        # opencc t2s 会把「乾」误转为「干」，先保护再转换
        def protect(s: str) -> str:
            return s.replace("乾", "\uE000")

        def restore(s: str) -> str:
            return s.replace("\uE000", "乾")

        data["gua_ci"] = restore(T2S.convert(protect(data["gua_ci"] or "")))
        data["yao"] = {k: restore(T2S.convert(protect(v))) for k, v in data["yao"].items()}
        data["yong"] = {k: restore(T2S.convert(protect(v))) for k, v in data["yong"].items()}
        n_yao = len(data["yao"])
        flag = "OK " if (data["gua_ci"] and n_yao == 6) else "!! "
        print(f"{flag}[{i:02d}] {page}: 卦辞={'有' if data['gua_ci'] else '无'} 爻辞={n_yao} 用={list(data['yong'])}")
        result[f"{i:02d}"] = {"page": page, **data}
        time.sleep(1)
    with open(".scratch/yi-app/content/reference-wikisource.json", "w", encoding="utf-8") as f:
        json.dump(result, f, ensure_ascii=False, indent=1)
    print("已写入 reference-wikisource.json")


if __name__ == "__main__":
    main()
