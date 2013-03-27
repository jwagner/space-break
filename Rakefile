MANIFEST_DEV = 'cache.manifest'
MANIFEST_OGG = 'dist/cache.manifest'
MANIFEST_IOS = 'dist/cache.ios.manifest'

GFX = FileList['gfx/*']

CSD = FileList['csound/*.csd']
WAV = CSD.pathmap('sfx/%n.wav')
MP3 = CSD.pathmap('sfx/%n.mp3')
OGG = CSD.pathmap('sfx/%n.ogg')
OTHERS = %w(sfx/multiball.ogg sfx/soundscape.ogg) 
JS = %w(break.js yepnope.js)
JS_MIN = %w(break.min.js yepnope.js)
CSS = %w(style.css)
HTML = %w(index.html)
OGG_DEPS = OGG + GFX + OTHERS + JS + CSS + HTML

task :default => [MANIFEST_DEV]

task :monitor do
    sh "coffee -wc *.coffee"
end

task :clean do
    sh *(%w(rm -f break.min.js) + MP3 + OGG + WAV + [MANIFEST_DEV])
end

task :clean_dist do
    sh "rm -rf dist && mkdir dist"
end

task :build_dist => [:clean_dist, MANIFEST_OGG, 'break.min.js'] do
    sh "mkdir dist/sfx && cp sfx/*.ogg dist/sfx"
    sh "mkdir dist/gfx && cp gfx/* dist/gfx"
    sh *(%w(cp .htaccess) + JS_MIN + CSS + HTML + %w(dist))
    sh "cp dist/break.min.js dist/break.js"
end

task :publish => [:build_dist] do
    sh "rsync -rv dist/ 29a.ch:/var/www/29a.ch/space-break"
end

file MANIFEST_DEV => OGG + GFX + OTHERS + %w(index.html) do |t|
    write_manifest(t.name, t.prerequisites)
end

file MANIFEST_OGG => OGG_DEPS do |t|
    write_manifest(t.name, t.prerequisites)
end

def write_manifest(name, entries)
    lines = ["CACHE MANIFEST", "# #{Time.now}"]
    lines << entries
    lines += %w(NETWORK: /* *)
    lines << ''
    File.open(name, 'w') do |f|
        f.write(lines.join("\r\n"))
    end
    puts "wrote manifest #{name} (#{entries.length} entries)"
end

file 'break.min.js' => ['break.js'] do |t|
	#sh "java -jar compiler.jar --formatting=pretty_print --js #{t.prerequisites[0]} --compilation_level SIMPLE_OPTIMIZATIONS  --js_output_file #{t.name}"
	sh "java -jar compiler.jar --js #{t.prerequisites[0]} --compilation_level SIMPLE_OPTIMIZATIONS  --js_output_file #{t.name}"
end

rule '.wav' => [proc {|f| f.pathmap 'csound/%n.csd'}] do |t|
    sh 'csound', t.source, "--output=#{t.name}"
end

rule '.mp3' => ['.wav'] do |t|
    sh *(%w(lame -v --resample 48) + ['--ta', 'Jonas Wagner', '--tc', 'http://29a.ch/', t.source, t.name])
end

rule '.ogg' => ['.wav'] do |t|
    sh 'oggenc', '-a', 'Jonas Wagner', '-c', 'DESCRIPTION=http://29a.ch/', t.source
end

