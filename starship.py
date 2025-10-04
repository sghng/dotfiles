#!/usr/bin/env python3
import re
from dataclasses import dataclass
from pathlib import Path
from sys import argv


@dataclass
class M:
    name: str
    bg: str
    symbol: str = ""
    fmt: str = "$symbol $version"

    def __str__(self):
        lines = [f"[{self.name}]"]
        if self.symbol:
            lines.append(f'symbol = "{self.symbol}"')
        lines.append(
            f'format = "([](bg:{self.bg} fg:prev_bg)[ {self.fmt} ](bg:prev_bg fg:bright-white))"'
        )
        return "\n".join(lines)


MODULES = [
    M("bun", "#791A49", ""),
    M("c", "#1C4679", ""),
    M("cpp", "#00599C", ""),
    M("cmake", "#DF3C3C", ""),
    M("java", "#ED8B00", ""),
    M("lua", "#000080", ""),
    M("nodejs", "#339933", ""),
    M(
        "python",
        "#987A26",
        "",
        r"$symbol $pyenv_prefix$version( \\\\($virtualenv\\\\))",
    ),
    M("quarto", "#447099"),
    M("rlang", "#3867B6", ""),
    M("conda", "#53B553", "", "$symbol $environment"),
]


config = Path(argv[1])
content = config.read_text()

modules = "\n\n".join(str(m) for m in MODULES)
fmt = "".join(f"${m.name}" for m in MODULES)

for pattern, repl in [
    (r"(^# >>>\n).*?(^# <<<)", rf"\1\n{modules}\n\n\2"),
    (r"(^\\\n).*?(^\\)", rf"\1{fmt}\\\n\2"),
]:
    content = re.sub(pattern, repl, content, count=1, flags=re.DOTALL | re.MULTILINE)

config.write_text(content)
