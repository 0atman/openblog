import jester
import asyncdispatch
import os
import strutils
import htmlgen
import strformat
import FeedNim
import tables
import yaml, streams
import moustachu
import json


type Blog = object
  name: string
  url: string
  rss: string
  tags: seq[string]

proc loadBlogs(filename: string): seq[Blog] =
  ## parse the yaml list into a seq of `Blog`s
  var yamlStream = newFileStream filename
  yamlStream.load result
  yamlStream.close

proc makeAndCheckTags(blogs: seq[Blog]): Table[string, seq[Blog]] =
  ## Checks the rss links for each blog makes sense,
  ## and puts them in a tag lookup table
  var tags = initTable[string, seq[Blog]]()
  echo "checking blog list..."
  for blog in blogs:
    #discard blog.rss.getRSS

    for rawTag in blog.tags:
      let tag = rawTag.toLowerAscii.replace(" ", "-")
      if tag in tags:
        tags[tag].add blog
      else:
        tags[tag] = @[blog]
  echo fmt"...{blogs.len} blogs loaded!"
  return tags

proc renderPage(pageName: string, context: Context): string =
  let page = readFile "pages/" & pageName & ".html"
  let theme = readFile "pages/theme.html"
  html((theme & page).render(context))

proc indexNew(tags: Table[string, seq[Blog]]): string =
  var tagLinks: seq[string]
  for tag in tags.keys:
    tagLinks.add tag

  var context: Context = newContext()
  context["title"] = "Open Blog Directory"
  context["tags"] = tagLinks
  return renderPage("index", context)

proc tagPage(tagname: string, tags: Table[string, seq[Blog]]): string =
  if not (tagname in tags):
    return "no blogs with that tag"
  var blogList: seq[string]
  for blog in tags[tagname]:
    blogList.add a(href=blog.url, blog.name)
  var context: Context = newContext()
  context["title"] = "OBD Tag: " & tagname
  context["blogs"] = blogList
  echo context
  return renderPage("tag", context)

## Set up blogs and tags and start the server
when is_main_module:
  let blogs = loadBlogs "list.yaml"
  let tags = makeAndCheckTags(blogs)

  var settings = newSettings()
  if existsEnv "PORT":
    settings.port = Port(parseInt(getEnv("PORT")))

  routes:
    get "/":
      resp indexNew(tags)
    get "/tag/@tagname":
      resp tagPage(@"tagname", tags)

  runForever()
