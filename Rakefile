MANIFEST = 'cache.manifest'


GFX = FileList['gfx/*']

CSD = FileList['csound/*.csd']
WAV = CSD.pathmap('sfx/%n.wav')
MP3 = CSD.pathmap('sfx/%n.mp3')
OGG = CSD.pathmap('sfx/%n.ogg')
OTHERS = %w(break.min.js sfx/multiball.ogg sfx/soundscape.ogg) 

task :default => [MANIFEST]

task :monitor do
    sh "coffee -wc *.coffee"
end

task :clean do
    sh *(%w(rm -f break.min.js) + MP3 + OGG + WAV + [MANIFEST])
end

file MANIFEST => OGG + GFX + OTHERS + %w(index.html) do |t|
    lines = ["CACHE MANIFEST", "# #{Time.now}"]
    lines << t.prerequisites
    lines += %w(NETWORK: /* *)
    lines << ''
    File.open(t.name, 'w') do |f|
        f.write(lines.join("\r\n"))
    end
    puts "wrote #{t.name}"
end

file 'break.min.js' => ['break.js'] do |t|
	#sh "java -jar compiler.jar --formatting=pretty_print --js #{t.prerequisites[0]} --compilation_level SIMPLE_OPTIMIZATIONS  --js_output_file #{t.name}"
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

