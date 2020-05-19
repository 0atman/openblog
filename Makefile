build:
	nimble build --passL: -static -d:release openblog.nim

heroku:
	git push heroku master
	heroku logs --tail
