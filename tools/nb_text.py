#!/usr/bin/env python3
"""노트북에서 마크다운 셀 + 텍스트 출력만 추출(이미지/base64 제외).

OBSERVATORY 데이터 지식 갱신용 재사용 도구.
사용: uv run python OBSERVATORY/tools/nb_text.py <notebook.ipynb> [max_out_lines]
"""
import json
import sys

MAX_OUT = int(sys.argv[2]) if len(sys.argv) > 2 else 40


def text_of(output):
    t = output.get("output_type")
    if t == "stream":
        return "".join(output.get("text", []))
    if t in ("execute_result", "display_data"):
        data = output.get("data", {})
        return data.get("text/plain") and "".join(data["text/plain"]) or ""
    if t == "error":
        return "\n".join(output.get("traceback", []))
    return ""


def main(path):
    nb = json.load(open(path))
    for i, cell in enumerate(nb.get("cells", [])):
        src = "".join(cell.get("source", [])).rstrip()
        if not src:
            continue
        if cell["cell_type"] == "markdown":
            print(f"\n# [MD cell {i}]\n{src}")
        elif cell["cell_type"] == "code":
            print(f"\n# [CODE cell {i}]\n{src}")
            outs = []
            for o in cell.get("outputs", []):
                txt = text_of(o).rstrip()
                if txt:
                    outs.append(txt)
            if outs:
                joined = "\n".join(outs).splitlines()
                shown = joined[:MAX_OUT]
                print("# --- OUT ---")
                print("\n".join(shown))
                if len(joined) > MAX_OUT:
                    print(f"# ...(+{len(joined) - MAX_OUT} more output lines)")


if __name__ == "__main__":
    main(sys.argv[1])
