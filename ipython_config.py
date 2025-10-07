# ruff: noqa: F821
c = c  # ty: ignore[unresolved-reference]
c.InteractiveShell.ast_node_interactivity = "all"
c.InteractiveShellApp.exec_lines = [
    "%config InlineBackend.figure_format = 'retina'",
    "%load_ext cython",
    "%load_ext rich",
    "%load_ext autotime",  # loads last
]
