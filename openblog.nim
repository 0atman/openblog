import jester
import asyncdispatch
import os
import strutils
import htmlgen
import json
import strformat
import FeedNim
import tables


const jsonlist = staticRead "list.json"
let bloglist = parseJson(jsonlist)["blogs"]

var tags = initTable[string, seq[JsonNode]]()

echo "checking blog list..."
for blog in bloglist:
  discard getRSS blog["rss"].getStr

  for rawTag in blog["tags"]:
    let tag = rawTag.getStr.toLowerAscii.replace(" ", "-")
    if tags.contains(tag):
      tags[tag].add blog
    else:
      tags[tag] = @[blog]

echo fmt"...{bloglist.len} blogs loaded!"
var settings = newSettings()

if existsEnv("PORT"):
  settings.port = Port(parseInt(getEnv("PORT")))

func index(tags: Table[string, seq[JsonNode]]): string =
  var tagLinks: seq[string]
  for tag in tags.keys:
    tagLinks.add a(href="/tag/" & tag, tag)

  html(
    head(link(rel="stylesheet", href="https://newcss.net/new.min.css")),
    body(
      header(h1("Open Blog Directory")),
      tagLinks.join("</br>")))

var titles: seq[string]
for blog in bloglist:
  titles.add p(blog["name"].getStr)


func tagPage(tagname: string, tags: Table[string, seq[JsonNode]]): string =
  if not tags.contains(tagname):
    return "no blogs with that tag"
  var blogList: seq[string]
  for blog in tags[tagname]:
    blogList.add li(a(href=blog["url"].getStr, blog["name"].getStr))
  html(
    head(link(rel="stylesheet", href="https://newcss.net/new.min.css")),
    body(
      header(h1(tagname)),
      blogList.join "\n",
  ))


routes:
  get "/":
    resp index(tags)
  get "/tag/@tagname":
    resp tagPage(@"tagname", tags)
  get "/list.json":
    resp bloglist

runForever()
