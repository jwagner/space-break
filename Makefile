break.min.js: break.js
	java -jar compiler.jar --js break.js --compilation_level ADVANCED_OPTIMIZATIONS  --js_output_file break.min.js

monitor:
	coffee -wc *.coffee
