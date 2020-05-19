import jester, asyncdispatch, os, strutils
import htmlgen as h

var settings = newSettings()

if existsEnv("PORT"):
  settings.port = Port(parseInt(getEnv("PORT")))

routes:
  get "/":
    resp h.p("Hello from Openblog")

runForever()
