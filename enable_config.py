#!/usr/bin/env python3
"""Enable center-single-window-vertically in a niri config.kdl.

Idempotent: enables an existing commented-out line, skips if already
enabled, otherwise inserts after the center-focused-column line.
Prints what it did. Exits 0 in all non-error cases.
"""
import re
import sys

OPT = "    center-single-window-vertically\n"
ANCHOR = '    center-focused-column "on-overflow"\n'


def main(path: str) -> None:
    with open(path) as f:
        text = f.read()
    if re.search(r"^[ \t]*center-single-window-vertically\s*$", text, re.M):
        print("option already enabled, leaving config alone")
    elif re.search(r"^[ \t]*//[ \t]*center-single-window-vertically\s*$", text, re.M):
        text = re.sub(
            r"^[ \t]*//[ \t]*center-single-window-vertically\s*$",
            OPT.rstrip("\n"),
            text,
            count=1,
            flags=re.M,
        )
        with open(path, "w") as f:
            f.write(text)
        print("option re-enabled")
    elif ANCHOR in text:
        text = text.replace(ANCHOR, ANCHOR + "\n" + OPT, 1)
        with open(path, "w") as f:
            f.write(text)
        print("option added after center-focused-column")
    else:
        print("could not find layout anchor; add this inside layout {} manually:")
        print(OPT)


if __name__ == "__main__":
    main(sys.argv[1])
