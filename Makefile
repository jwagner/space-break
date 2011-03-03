all: break.min.js sfx/pong.ogg

sfx/pong.ogg: sfx/pong.wav
	oggenc sfx/pong.wav

sfx/pong.wav: csound/pong.csd
	mkdir -p sfx
	csound csound/pong.csd --output=sfx/pong.wav

break.min.js: break.js
	java -jar compiler.jar --js break.js --compilation_level ADVANCED_OPTIMIZATIONS  --js_output_file break.min.js

monitor:
	coffee -wc *.coffee
