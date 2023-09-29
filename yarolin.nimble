# Package

version       = "0.1.0"
author        = "Fabricio Pashaj"
description   = "Yet Another Result/Option Library In Nim"
license       = "MIT"
srcDir        = "src"


# Dependencies

requires "nim >= 1.9"

import strformat
import std/compilesettings

task docs_gen, "Build documentation for the package":
  const switch = "--outdir:htmldocs --index:on"
  exec fmt"nim doc {switch} src/yarolin/results.nim"
  exec fmt"nim doc {switch} src/yarolin/options.nim"
  exec"nim buildIndex -o:htmldocs/index.html htmldocs"
