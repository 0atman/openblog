# nim-heroku-example

Example [nim](http://nim-lang.org) app deployed using the [nim heroku buildpack](http://github.com/vic/heroku-buildpack-nim).


This [example app](http://nim-heroku-example.herokuapp.com) uses the [jester web framework](https://github.com/dom96/jester)

Usage
-----

```shell

# Get this example app
git clone git://github.com/vic/nim-heroku-example.git
cd nim-heroku-example

# Create a heroku app
heroku create --stack cedar --buildpack https://github.com/vic/heroku-buildpack-nim.git

# Deploy using development version of Nim
heroku config:set NIM_BRANCH=devel
git push heroku master
```