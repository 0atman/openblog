build:
	nimble build --passL: -static -d:ssl openblog.nim

run: build
	./openblog

heroku:
	git push heroku master
	heroku logs --tail

watch:
	watchmedo shell-command --drop --ignore-directories --patterns="*.nim" --ignore-patterns="*#*" --recursive --command='clear && make --no-print-directory build && echo "✔️ Build succeeded!"' .
