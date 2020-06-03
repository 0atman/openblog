build:
	nimble build -d:ssl
	echo "✔️ Build succeeded!"

serve: build
	./openblog

release:
	nimble build -d:ssl -d:release

heroku:
	git push heroku master
	heroku logs --tail

clear:
	clear

watch:
	watchmedo auto-restart --ignore-directories --patterns="*.nim" --ignore-patterns="*#*" --recursive make clear serve
