all: break.min.js sfx

sfx: csound/*
	mkdir -p sfx
	csound csound/pong.csd --output=sfx/pong.wav
	csound csound/ping.csd --output=sfx/ping.wav
	csound csound/explosion.csd --output=sfx/explosion.wav
	oggenc sfx/*.wav
	lame sfx/pong.wav sfx/pong.mp3
	lame sfx/ping.wav sfx/ping.mp3
	lame sfx/explosion.wav sfx/explosion.mp3

clean:
	rm -rf sfx/
	rm break.min.js

break.min.js: break.js
	java -jar compiler.jar --js break.js --compilation_level ADVANCED_OPTIMIZATIONS  --js_output_file break.min.js

monitor:
	coffee -wc *.coffee
