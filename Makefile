all: break.min.js sfx cache.manifest

cache.manifest: gfx/* sfx/* style.css break.min.js index.html
	echo "CACHE MANIFEST" > cache.manifest
	echo "#" `date` >> cache.manifest
	#echo style.css >> cache.manifest
	echo break.min.js >> cache.manifest
	find sfx/ -iname *.ogg >> cache.manifest
	find sfx/ -iname *.mp3 >> cache.manifest
	find gfx/ -iname *.png >> cache.manifest
	echo "NETWORK:" >> cache.manifest
	echo "/*" >> cache.manifest
	echo "*" >> cache.manifest

sfx/*: csound/*
	mkdir -p sfx
	csound csound/pong.csd --output=sfx/pong.wav
	csound csound/ping.csd --output=sfx/ping.wav
	csound csound/explosion.csd --output=sfx/explosion.wav
	csound csound/nuke.csd --output=sfx/nuke.wav
	csound csound/thud.csd --output=sfx/thud.wav
	oggenc sfx/*.wav
	oggenc wav/multiball.wav -o sfx/multiball.ogg
	lame sfx/pong.wav sfx/pong.mp3
	lame sfx/ping.wav sfx/ping.mp3
	lame sfx/nuke.wav sfx/nuke.mp3
	lame sfx/thud.wav sfx/thud.mp3
	lame sfx/explosion.wav sfx/explosion.mp3
	lame wav/multiball.wav sfx/multiball.mp3

clean:
	rm -rf sfx/
	rm break.min.js
	rm cache.manifest

break.min.js: break.js
	java -jar compiler.jar --formatting=pretty_print --js break.js --compilation_level SIMPLE_OPTIMIZATIONS  --js_output_file break.min.js

monitor:
	coffee -wc *.coffee
