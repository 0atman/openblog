import jester
import asyncdispatch
import os
import strutils
import htmlgen
import strformat
import FeedNim
import tables
import yaml, streams

type Blog = object
  name: string
  url: string
  rss: string
  tags: seq[string]

proc loadBlogs(filename: string): seq[Blog] =
  var yamlStream = newFileStream filename
  yamlStream.load result
  yamlStream.close

proc makeAndCheckTags(blogs: seq[Blog]): Table[string, seq[Blog]] =
  var tags = initTable[string, seq[Blog]]()
  echo "checking blog list..."
  for blog in blogs:
    discard getRSS blog.rss

    for rawTag in blog.tags:
      let tag = rawTag.toLowerAscii.replace(" ", "-")
      if tag in tags:
        tags[tag].add blog
      else:
        tags[tag] = @[blog]
  echo fmt"...{blogs.len} blogs loaded!"
  return tags

func index(tags: Table[string, seq[Blog]]): string =
  var tagLinks: seq[string]
  for tag in tags.keys:
    tagLinks.add a(href="/tag/" & tag, tag)

  html(
    head(link(rel="stylesheet", href="https://newcss.net/new.min.css")),
    body(
      header(h1("Open Blog Directory")),
      tagLinks.join("</br>")))

func tagPage(tagname: string, tags: Table[string, seq[Blog]]): string =
  if not (tagname in tags):
    return "no blogs with that tag"
  var blogList: seq[string]
  for blog in tags[tagname]:
    blogList.add li(a(href=blog.url, blog.name))
  html(
    head(link(rel="stylesheet", href="https://newcss.net/new.min.css")),
    body(
      header(h1(tagname)),
      blogList.join "\n",
  ))

when is_main_module:
  let blogs = loadBlogs "list.yaml"
  let tags = makeAndCheckTags(blogs)

  var settings = newSettings()
  if existsEnv "PORT":
    settings.port = Port(parseInt(getEnv("PORT")))

  routes:
    get "/":
      resp index(tags)
    get "/tag/@tagname":
      resp tagPage(@"tagname", tags)

  runForever()
