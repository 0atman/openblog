[Package]
name          = "openblog"
version       = "0.0.1"
author        = "Tristram Oaten <tristram@oaten.name>"
description   = "Open blog aggregator"
license       = "BSD"

bin           = "openblog"

[Deps]
Requires: "nim >= 0.10.0, jester, FeedNim"
