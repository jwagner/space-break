round = Math.round
floor = Math.floor
random = Math.random
sqrt = Math.sqrt
min = Math.min
max = Math.max
abs = Math.abs

WIDTH = 640
HEIGHT = 480
SLOW = false
INITIAL_VELOCITY = 200

MENU_X = -WIDTH*0
GAME_X = -WIDTH*1
HIGHSCORES_X = -WIDTH*2
CREDITS_X = -WIDTH*3
# ugly
if(navigator.userAgent.match(/iPad/i))
    SLOW = true

AUDIO = true
RESOURCES =
    background: 'gfx/background.jpg'
    brick_orange: 'gfx/brick_orange.png'
    brick_green: 'gfx/brick_green.png'
    brick_blue: 'gfx/brick_blue.png'
    brick_immortal: 'gfx/brick_immortal.png'
    brick_tnt: 'gfx/brick_tnt.png'
    brick_nuke: 'gfx/brick_nuke.png'
    brick_hard0: 'gfx/brick_hard0.png'
    brick_hard1: 'gfx/brick_hard1.png'
    brick_hard2: 'gfx/brick_hard2.png'
    brick_xtraball: 'gfx/brick_xtraball.png'
    brick_explosion: 'gfx/explosion.png'
    ball: 'gfx/ball.png'
    paddle: 'gfx/paddle.png'
    pong: 'sfx/pong.ogg'
    ping: 'sfx/ping.ogg'
    thud: 'sfx/thud.ogg'
    explosion: 'sfx/explosion.ogg'
    nuke: 'sfx/nuke.ogg'
    multiball: 'sfx/multiball.ogg'
INTERVAL = false
TWAT = null
game = null

LEVELS = []
LEVELS.push (scene) ->
    for row in [0...2]
        for col in [0...7]
            if col&1
                continue
            x = col*(Brick.width)+Brick.width
            y = row*(Brick.height+2)+Brick.height+80
            if row == 1
                scene.bricks.push(new ImmortalBrick(v2(x, y)))
            else
                scene.bricks.push(new TntBrick(v2(x, y)))


LEVELS.push (scene) ->
    positions = [
        v2(150, 100)
        v2(150, 130)
        v2(150, 160)
        v2(150, 190)
        v2(150, 220)
        v2(150, 250)

        v2(230, 160)

        v2(310, 100)
        v2(310, 130)
        v2(310, 160)
        v2(310, 190)
        v2(310, 220)
        v2(310, 250)

        v2(450, 160)
        v2(450, 190)
        v2(450, 220)
        v2(450, 250)


    ]
    for position in positions
        scene.bricks.push(new Brick(v2(position.x, position.y+50)))
    scene.bricks.push(new TntBrick(v2(450, 100)))

LEVELS.push (scene) ->
    for row in [0...5]
        for col in [0...7]
            x = col*(Brick.width)+Brick.width
            y = row*(Brick.height+2)+Brick.height+80
            color = ['orange', 'green'][(row&1)^(col&1)]
            scene.bricks.push(new ColorBrick(v2(x, y), color))

LEVELS.push (scene) ->
    for row in [0...5]
        for col in [0...7]
            x = col*(Brick.width)+Brick.width
            y = row*(Brick.height+2)+Brick.height+80
            color = ['orange', 'blue'][(row&1)^(col&1)]
            if row == 1 and (col)%3 == 0
                scene.bricks.push(new TntBrick(v2(x, y)))
            else
                scene.bricks.push(new ColorBrick(v2(x, y), color))


make_level = (height) ->
    (scene) ->
        cols = floor(WIDTH/(Brick.width))-1
        rows = floor((HEIGHT-100)*height/(Brick.height+10))
        for row in [0...rows]
            for col in [0...cols]
                x = col*(Brick.width)+Brick.width
                y = row*(Brick.height+2)+Brick.height+80
                switch row%3
                    when 0
                        if row == 0 and col == ~~(cols/2)
                            scene.bricks.push(new XtraBallBrick(v2(x, y)))
                        else
                            scene.bricks.push(new HardBrick(v2(x, y)))
                    when 1
                        scene.bricks.push(new Brick(v2(x, y)))
                    when 2
                        if col%3 == 0
                            scene.bricks.push(new TntBrick(v2(x, y)))
                        else
                            scene.bricks.push(new HardBrick(v2(x, y)))
 
LEVELS.push make_level(0.4)
LEVELS.push make_level(0.5)
LEVELS.push make_level(0.7)
LEVELS.push (scene) ->
    for row in [0...5]
        for col in [0...7]
            x = col*(Brick.width)+Brick.width
            y = row*(Brick.height+2)+Brick.height+80
            if row == 0
                scene.bricks.push(new XtraBallBrick(v2(x, y)))
            else
                scene.bricks.push(new HardBrick(v2(x, y)))


 

resources = {}

class JSPerfHub
    colors: ['red', 'orange', 'yellow', 'green', 'blue']
    sampleWidth: 2
    constructor: (id='perfhub') ->
        @canvas = document.getElementById(id)
        @ctx = @canvas.getContext('2d')
        @buckets = {}
        # ordered set of keys
        @buckets.keys = []
        @buckets.values = []
        @sample = 0
        @t = new Date()
        @scale = Infinity
        @bucketSize = @canvas.width/@sampleWidth
        @ctx.font = '12px geo'
        @fontHeight = 16

        @visible = false
        @canvas.onclick = =>
            @visible = not @visible

     start: ->
        @sample = (@sample+1)%@bucketSize
        @t = new Date()
    

    tick: (name) ->
        bucket = @buckets[name]
        if not bucket
            bucket = @buckets[name] =
                average: 0
                samples: 0 for [0..@bucketSize]
            @buckets.keys.push(name)
            @buckets.values.push(bucket)
        t = new Date()
        td = t-@t
        @t = t
        bucket.average -= bucket.samples[@sample]/@bucketSize
        bucket.samples[@sample] = td
        bucket.average += td/@bucketSize

    draw: ->
        if not @visible
            return
        total = 0
        textSpacing = 4
        textHeight = 2*textSpacing+@fontHeight*(@buckets.keys.length+2)
        availableHeight = @canvas.height-textHeight
        for bucket in @buckets.values
            total += bucket.average
        if availableHeight/total < @scale
            @scale = availableHeight/total/2
            @ctx.fillStyle = 'black'
            @ctx.fillRect(0, 0, @canvas.width, @canvas.height)
        x = @canvas.width-@sampleWidth
        y = @canvas.height
        total = 0
        i = 0
        @ctx.fillStyle = '#111'
        @ctx.fillRect(0, 0, @canvas.width, textHeight)
        @ctx.drawImage(@canvas, -1, 0)
        for name in @buckets.keys
            color = @colors[(i++)%@colors.length]
            bucket = @buckets[name]
            sample = bucket.samples[@sample]
            height = sample*@scale
            y -= height
            @ctx.fillStyle = color
            @ctx.fillRect(x, y, @sampleWidth, height)
            @ctx.fillText("#{name}: #{round(bucket.average*100)/100} ms", textSpacing, textSpacing+@fontHeight*i)
            total += bucket.average
        @ctx.fillStyle = 'white'
        @ctx.fillText("total: #{round(total*100)/100} ms / #{round(1000/total)} fps", textSpacing, textSpacing+@fontHeight*(@buckets.keys.length+1))
        @ctx.fillStyle = 'black'
        @ctx.fillRect(x, 0, @sampleWidth, y)
        return

class InputHandler
    constructor: (@element) ->
        @target = WIDTH/2
        # handle scoping
        window.addEventListener('mousemove', ((e) => @onmove(e)), false)
        ontouch = (e) =>
            @onmove(e.touches[0])
            e.preventDefault()
        @element.addEventListener('touchstart', ontouch, false)
        @element.addEventListener('touchmove', ontouch, false)
        # we assume that there is no offsetParent and the offset will never
        # change
        @left = @element.parentNode.parentNode.offsetLeft

    onmove: (e) ->
        @target = e.clientX-@left

class V2
    constructor: (@x, @y) ->

    iadd: (v) ->
        @x += v.x
        @y += v.y
        this

    set: (@x, @y) ->
        this

    add: (v) ->
        new V2(@x+v.x, @y+v.y)

    sub: (v) ->
        new V2(@x-v.x, @y-v.y)

    mul: (v) ->
        new V2(@x*v.x, @y*v.y)
 
    muls: (s) ->
        new V2(@x*s, @y*s)

    imuls: (s) ->
        @x *= s
        @y *= s
        this

    divs: (s) ->
        this.muls(1/s)

    mag: (s) ->
        sqrt(@x*@x+@y*@y)

    normalize: ->
        this.divs(this.mag())

    copy: ->
        new V2(@x, @y)

    valueOf: ->
        throw 'Tried to use V2 as scalar'

    toString: ->
        "v2(#{@x}, #{@y})"


V2.random = ->
    new V2(random()-0.5, random()-0.5).normalize()
v2 = (x, y) -> new V2(x, y)


class AudioPlayerPools
    constructor: ->
        @pool = {}
        @maxPoolSize = 3

    play: (name) ->
        if not AUDIO
            return
        pool = @pool[name]
        if not pool
            #pool = @pool[name] = [resources[name]]
            pool = [resources[name].cloneNode(true)]
        for audio in pool
            if audio.readyState == 4 and audio.paused or audio.ended
                if audio.currentTime == 0
                    audio.play()
                    console.log('reuse')
                    return
                else
                    # hack for chrome/webkit
                    audio.currentTime = 0
                    audio.pause()
        audio = audio.cloneNode(true)
        console.log('clone')
        #audio.currentTime = 0.0
        audio.play()
        if pool.length < @maxPoolSize
            pool.push(audio)

class AudioPlayerChannels
    constructor: ->
        @maxChannels = 12
        @channels = []
        for i in [0...@maxChannels]
            @channels.push(document.createElement('audio'))

    play: (name) ->
        if not AUDIO
            return
        for audio in @channels
            if audio.paused or audio.ended
                if audio.currentTime == 0
                    audio.src = resources[name].src
                    audio.play()
                    console.log('reuse')
                    return
                else
                    # hack for chrome/webkit
                    audio.currentTime = 0
                    audio.pause()

audioPlayer = new AudioPlayerChannels()

class Rect
    constructor: (@center, @width, @height) ->
        @left = @center.x - @width*0.5
        @right = @center.x + @width*0.5
        @top = @center.y - @height*0.5
        @bottom = @center.y + @height*0.5

    recalc: ->
        @left = @center.x - @width*0.5
        @right = @center.x + @width*0.5
        @top = @center.y - @height*0.5
        @bottom = @center.y + @height*0.5


rect = (x, y, width, height) -> new Rect(v2(x, y), width, height)

# center -> new center of circle after moveing
rect_circle_collision = (rect, circle, center) ->
    new_rect = new Rect(rect.center, rect.width+circle.radius*2,
        rect.height+circle.radius*2)
    if not (center.x < new_rect.left or center.x > new_rect.right or center.y > new_rect.bottom or center.y < new_rect.top)
        # find axis of collision
        if new_rect.left < circle.center.x < new_rect.right
            'y'
        else if new_rect.top < circle.center.y < circle.center.top
            'x'
        else
            'xy'


class Circle
    constructor: (@center, @radius) ->


class Ball
    constructor: (@position, @velocity) ->
        @shape = new Circle(@position, 10)

    draw: (ctx) ->
        img = resources['ball']
        ctx.drawImage(img, @shape.center.x-img.width*0.5, @shape.center.y-img.height*0.5)


class ScoreTracker
    constructor: ->
        @total = 0
        @multiplier = 1
        @pending = 0
        @hits = 0

    add: (n) ->
        @pending += n
        @hits += 1
        @multiplier = floor(sqrt(@hits))

    earn: ->
        @total += @pending*@multiplier
        @reset()

    reset: ->
        @multiplier = 1
        @hits = 0
        @pending = 0


class Brick
    image: 'brick_orange'
    sound: 'pong'
    score: 100

    constructor: (@position) ->
        @shape = new Rect(@position, Brick.width, Brick.height)
        @destroyed = false

    draw: (ctx) ->
        ctx.drawImage(resources[@image], @shape.left, @shape.top)

    hit: (scene) ->
        @destroyed = true
        scene.score.add(@score)

Brick.width = 80
Brick.height = 30

class ImmortalBrick extends Brick
    image: 'brick_immortal'
    sound: 'thud'
    hit: (scene, explosion) ->
        if explosion
            super(scene)


class ColorBrick extends Brick
    constructor: (position, color) ->
        super(position)
        @image = "brick_#{color}"


class HardBrick extends Brick
    image: 'brick_hard0'
    hits: 0
    score: 200
    sound: 'ping'

    hit: (scene) ->
        @hits++
        if @hits > 2
            super(scene)
        else
            @image = "brick_hard#{@hits}"
            scene.score.add(100)

class TntBrick extends Brick
    image: 'brick_tnt'
    blastRadius: Brick.width
    sound: 'explosion'
    score: 200
    hit: (scene) ->
        super(scene)
        scene.sprites.push(new Animation(resources['brick_explosion'], 128, @shape.center))
        for brick in scene.bricks
            if not brick.destroyed and brick.shape.center.sub(@shape.center).mag() <= @blastRadius
                brick.hit(scene, true)

class NukeBrick extends Brick
    image: 'brick_nuke'
    sound: 'nuke'
    score: 1000
    hit: (scene) ->
        nukeEffect(game, @shape.center)
        super(scene)
        for brick in scene.bricks
            while not brick.destroyed
                brick.hit(scene, true)

class XtraBallBrick extends Brick
    image: 'brick_xtraball'
    hit: (scene) ->
        super(scene)
        audioPlayer.play('multiball')
        scene.balls.push(new Ball(@shape.center.copy(), v2(0, -INITIAL_VELOCITY)))


class Paddle
    image: 'paddle'
    constructor: (@position) ->
        @shape = new Rect(@position, 100, 20)
        @velocity = 0
        @acceleration = 0
        @target = @position.x

    draw: (ctx) ->
        ctx.drawImage(resources[@image], @shape.left-20, @shape.top-20)
        return
        sx = @shape.left-10
        sw = @shape.width*2-20
        sy = @shape.top+10
        sh = @shape.height*2-20
        ctx.drawImage(resources['background'], sx, sy, sw, sh, @shape.left, @shape.top, @shape.width, @shape.height)
        #ctx.fillStyle = 'rgba(255, 255, 255, 0.5)'
        #ctx.globalCompositeOperation = 'lighter'
        #ctx.fillRect(@shape.left, @shape.top, @shape.width, @shape.height)
        #ctx.globalCompositeOperation = 'source-over'


class Particle
    constructor: (@position, @velocity, @ttl) ->

class ParticleSystem
    constructor: (n) ->
        @particles = new Array(n)
        @t = 0
        @i = 0
        @gravity = v2(0, 300)
        for i in [0...n]
            @particles[i] = new Particle(v2(0,0), v2(0,0), 0)

    spawn: (location, direction, velocity, ttl, n) ->
        for i in [0..n]
            particle = @particles[@i]
            particle.position = location.copy()
            particle.velocity = direction.normalize().mul(v2(0.5-random(), 0.5-random())).normalize().muls(velocity*random())
            particle.ttl = @t+ttl
            @i = (@i+1)%@particles.length
        return

    tick: (t) ->
        @t += t
        for particle in @particles
            if particle.ttl > @t
                # gravity
                particle.velocity.iadd(@gravity.muls(t))
                particle.position.iadd(particle.velocity.muls(t))
        return

    draw: (ctx) ->
        for particle in @particles
            if particle.ttl > @t
                alpha = sqrt(particle.ttl - @t)
                ctx.fillStyle = "rgba(255, 205, 80, #{alpha})"
                ctx.fillRect(particle.position.x, particle.position.y, 1, 1)
        return

class Animation
    constructor: (@img, @width, @center) ->
        @frame = 0
        @frames = @img.width/@width

    draw: (ctx) ->
        x = @center.x - @width*0.5
        y = @center.y - @img.height*0.5
        frame = ~~@frame
        ctx.drawImage(@img, frame*@width, 0, @width, @img.height, x, y, @width, @img.height)
        @frame = (@frame+0.5)%@frames

class Game
    constructor: (@canvas) ->
        @ctx = @canvas.getContext '2d'
        @input = new InputHandler(@canvas)
        @reset()

    reset: ->
        @scene =
            level: 0
            gameover: false
            score: new ScoreTracker()
            ballsLeft: 3
            bricks: []
            sprites:  []
            balls: [new Ball(v2(0, 0), v2(0, 0))]
            paddle: new Paddle(v2(WIDTH/2, HEIGHT-50))
        @particles = new ParticleSystem(100)
        @nextLevel()
        @perfhub = new JSPerfHub()
        @perfhub.start()

    nextLevel: ->
        @scene.ballsLeft += 1
        @scene.bricks = []
        if @scene.level < LEVELS.length
            LEVELS[@scene.level++](@scene)
        else
            LEVELS[LEVELS.length-1](@scene)
        @scene.score.earn()
        @scene.sprites = []
        @newBall()

    newBall: (ball) ->
        if not ball
            @scene.balls = [ball = @scene.balls[0]]
        if @scene.balls.length > 1
            balls = []
            for other_ball in @scene.balls
                if other_ball != ball
                    balls.push(other_ball)
            @scene.balls = balls
            return
        @scene.score.reset()
        if @scene.ballsLeft--
            ball = @scene.balls[0]
            x = max(min(WIDTH-ball.shape.radius, @scene.paddle.shape.center.x), ball.shape.radius)
            ball.shape.center.set(x, HEIGHT/3*2)
            ball.velocity = v2(random()-0.5, random()+1).normalize().muls(INITIAL_VELOCITY)
        else
            @scene.gameover = true

    tick: (t) ->
        @perfhub.tick('waiting')
        @physics(t)
        @perfhub.tick('physics')
        @render()
        @perfhub.tick('render')
        @perfhub.draw()
        @perfhub.tick('perfhub')
        @perfhub.start()
        return not @scene.gameover

    physics: (t) ->


        @paddlePhysics(t)
        for ball in @scene.balls
            @ballPhysics(t, ball)
        @particles.tick(t)
        for brick in @scene.bricks
            if not brick.destroyed
                return
        @nextLevel()

    ballPhysics: (t, ball) ->
        sound = 'pong'
        shape = ball.shape
        new_position = ball.position.add(ball.velocity.muls(t))
        if not (shape.radius <= new_position.x <= WIDTH-shape.radius)
            axis = 'x'
        if not (shape.radius <= new_position.y <= HEIGHT-shape.radius)
            if HEIGHT-shape.radius <= new_position.y
                @newBall(ball)
                return
            if axis is 'x'
                axis = 'xy'
            else
                axis = 'y'
        if not axis and not ((axis = rect_circle_collision(@scene.paddle.shape, shape, new_position)) and paddle = true)
            for brick in @scene.bricks
                if not brick.destroyed and axis = rect_circle_collision(brick.shape, shape, new_position)
                    brick.hit(@scene)
                    sound = brick.sound
                    break
            # makes it easier to get the ball up between blocks
            if axis is 'xy'
                axis = 'x'


        if axis is 'x'
            ball.velocity.x *= -1
        else if axis is 'y'
            ball.velocity.y *= -1
        else if axis is 'xy'
            ball.velocity.x *= -1
            ball.velocity.y *= -1
        if paddle
            ball.velocity.x += @scene.paddle.velocity*10
            if @scene.balls.length == 1
                @scene.score.earn()
        if axis
            audioPlayer.play(sound)
            # we don't want the ball to move to flat because it's annoying
            if abs(ball.velocity.y*2) < abs(ball.velocity.x)
                ball.velocity.x *= 0.8
            # speed up ball after every bounce with an upper limit of
            # 400 px/s
            ball.velocity = ball.velocity.normalize().muls(min(ball.velocity.mag()*1.01, 500))
            @particles.spawn(new_position.copy(), ball.velocity.muls(0.5), ball.velocity.mag(), 1.0, 25)
        else
            ball.position.iadd(ball.velocity.muls(t))
 

    paddlePhysics: (t) ->
        @scene.paddle.target = @input.target
        @scene.paddle.acceleration = (@scene.paddle.target - @scene.paddle.shape.center.x)*0.2
        @scene.paddle.velocity += @scene.paddle.acceleration
        @scene.paddle.velocity *= 0.7
        @scene.paddle.shape.center.x += @scene.paddle.velocity
        @scene.paddle.shape.recalc()
        for ball in @scene.balls
            shape = ball.shape
            if rect_circle_collision(@scene.paddle.shape, shape, shape.center)
                # try to push ball
                shape.center.x += @scene.paddle.velocity
                # but not over the edge
                if not (shape.radius <= shape.center.x <= WIDTH-shape.radius)
                    shape.center.x -= @scene.paddle.velocity
                    @scene.paddle.shape.center.x -= @scene.paddle.velocity
                    @scene.paddle.shape.recalc()
                break


    render: ->
        @ctx.drawImage(resources['background'], 0, 0)

        @particles.draw(@ctx)

        @scene.paddle.draw(@ctx)

        for brick in @scene.bricks
            if not brick.destroyed
                brick.draw(@ctx)

        for ball in @scene.balls
            ball.draw(@ctx)

        sprites = []
        for sprite in @scene.sprites
            sprite.draw(@ctx)
            if sprite.frame != 0
                sprites.push(sprite)
        @scene.sprites = sprites

        # draw hud
        @ctx.fillStyle = 'white'
        @ctx.textAlign = 'center'
        @ctx.textBaseline = 'top'
        @ctx.font = '60px geo'
        @ctx.fillText(@scene.score.total, WIDTH/2, -5)
        @ctx.font = '16px geo'
        @ctx.fillText("#{@scene.ballsLeft} balls left", WIDTH/2, 50)

        multiplier_colors = ['white', 'yellow', 'orange', 'red', 'green', 'magenta']
        if @scene.score.pending
            @ctx.font = '24px geo'
            colorIndex = min(floor((@scene.score.multiplier-1)/2), multiplier_colors.length)
            @ctx.fillStyle = multiplier_colors[colorIndex]
            if @scene.score.multiplier > 1
                text = "+ #{@scene.score.multiplier} x #{@scene.score.pending}"
            else
                text = "+ #{@scene.score.pending}"
            @ctx.fillText(text, WIDTH/2, 70)

        return


class Loader
    constructor: (resources) ->
        @resources = {}
        @pending = 0
        @failed = 0
        @audio = true
        @load(resources)

    _success: (name, data) ->
        if not @resources[name]?
            @pending--
            @resources[name] = data

    _error: (name, error) ->
        @failed++
        @pending--
        error.resource = name
        throw error

    load: (resources) ->
        for name, src of resources
            if /\.(jpe?g|gif|png)$/.test src
                @loadImage(name, src)
            else if /\.(og(g|a)|mp3)$/.test src
                @loadAudio(name, src)
            else
                throw 'unknow resource type ' + src
            @pending++
        return

    loadImage: (name, src) ->
        img = new Image()
        img.onload = => @_success(name, img)
        img.onerror = (e) => @_error(name, e)
        img.src = src

    loadAudio: (name, src) ->
        audio = document.createElement('audio')
        audio.preload = 'auto'
        audio.autobuffer = true
        canplaythough = =>
            console.log('can play')
            audio.pause()
            audio.volume = 1.0
            @_success(name, audio)
        audio.addEventListener('canplaythrough', canplaythough, false)
        audio.addEventListener('ended', canplaythough, false)
        audio.addEventListener('error', ((e) =>  @_error(name, e)), false)
        if ((src.slice(-4) == '.ogg' || src.slice(-4) == '.oga') &&
                audio.canPlayType('audio/ogg; codecs="vorbis"') != 'probably' ||
                        /webkit/i.test(navigator.userAgent))
            console.log('using mp3')
            src = src.slice(0, src.length-3) + 'mp3'
        audio.src = src
        # get all the browsers to preload the audio file
        # what a mess
        play = =>
            audio.play()
            console.log('playing', audio)
            if audio.paused
                # mobile safari doesn't allow us to control media elements
                # so no audio :(
                @audio = false
                console.log('audio paused after play')
                @_error(name, 'audio not play()able')
            else
                audio.volume = 0
        setTimeout(play, 10*@pending)


main = ->
    canvas = document.getElementById 'c'
    canvas.width = WIDTH
    canvas.height = HEIGHT
    ctx = canvas.getContext '2d'
    loader = new Loader(RESOURCES)
    resources = loader.resources
    check = =>
        if loader.pending > 0
            ctx.fillStyle = 'white'
            ctx.clearRect(0, 0, WIDTH, HEIGHT)
            ctx.textAlign = 'center'
            ctx.textBaseline = 'top'
            ctx.font = '50px geo'
            ctx.fillText('LOADING', WIDTH/2, 100)
            ctx.font = '16px geo'
            ctx.fillText("#{loader.pending} resources left", WIDTH/2, 140)
 
            setTimeout(check, 1000)
        else
            AUDIO = loader.audio
            start_game(canvas)
    check()

scrollTo = (x) ->
    if game
        game.ctx.clearRect(0, 0, WIDTH, HEIGHT)
    if TWAT and TWAT.isRunning()
        TWAT.pause()
    document.getElementById('frame').style['left'] = "#{x}px"

window['newGame'] = newGame = ->
    scrollTo(GAME_X)
    main()

window['menu'] = ->
    scrollTo(MENU_X)

window['highscores'] = gameover = ->
    scrollTo(HIGHSCORES_X)
    if TWAT and not TWAT.isRunning()
        TWAT.resume()

window['credits'] = ->
    scrollTo(CREDITS_X)


start_game = (canvas) ->
    window['game'] = game = new Game(canvas)
    t0 = new Date()
    callback = ->
        t1 = new Date()
        td = t1-t0
        t0 = t1
        if not game.tick(td*0.001)
            if INTERVAL
                clearInterval(INTERVAL)
            gameover()
            return false
        return true
    if requestAnimFrame
        f = ->
            if callback()
                requestAnimFrame(f, canvas)
        requestAnimFrame(f, canvas)
    else
        INTERVAL = setInterval(callback, 1000/30)
    game.render()

canvas = (w, h) ->
    c = document.createElement('canvas')
    c.width = w
    c.height = h
    return c

# copy paste from jswars - not pretty
nukeEffect = (game, position) ->
    cx = position.x
    cy = position.y
    ctx = game.ctx
    width = WIDTH
    height = HEIGHT
    if SLOW
        scale = 8
    else
        scale = 4
    w = floor(width/scale)
    h = floor(height/scale)
    buffer = canvas(w, h)
    #document.body.appendChild(buffer)
    buffer_clear = canvas(width, height)
    bctx = buffer.getContext('2d')
    bctx_clear = buffer_clear.getContext('2d')
    bctx_clear.drawImage(game.canvas, 0, 0)
    bctx.drawImage(game.canvas, 0, 0, w, h)
    ctx.drawImage(buffer, 0, 0, width, height)
    maxi = width*height*4
    bdata = ctx.getImageData(0, 0, width, height)
    t = 0
    oldtick = game.tick
    amplitude = 100
    period = Math.PI*2/200
    v = -2
    sdata = bctx.getImageData(0, 0, w, h)

    game.tick = (td) ->
        sqrt = Math.sqrt
        sin = Math.sin
        round = Math.round
        sdatadata = sdata.data
        bdatadata = bdata.data
        abs = Math.abs
        min = Math.min
        max=Math.max
        t += td
        for x in [0..w]
            for y in [0..h]
                i = (y*w+x)*4
                bx = x*scale
                by_ = y*scale
                xd = cx-bx
                yd = cy-by_
                d = sqrt(xd*xd+yd*yd)
                o = sin(d*period+t*v)*(amplitude/(1+(d/100)*(d/100))/t)
                bx = round(bx+o*(xd/d))
                by_ = round(by_+o*(yd/d))
                bi = (by_*width+bx)*4
                if(bi > maxi || bi < 1)
                    sdata[i+3] = 0
                else
                    sdatadata[i] = min(255, bdatadata[bi]*3.5)
                    sdatadata[i+1] = min(255, bdatadata[bi+1]*1.5)
                    sdatadata[i+2] = min(255, bdatadata[bi+2]*1.0)
                    sdatadata[i+3] = min(255, 15*abs(o))
        
        bctx.putImageData(sdata, 0, 0)
        ctx.drawImage(buffer_clear, 0, 0)
        ctx.drawImage(buffer, 0, 0, width, height)
        if t > 1.5
            game.tick = oldtick
        return true

requestAnimFrame = window['requestAnimationFrame'] || window['webkitRequestAnimationFrame'] || window['mozRequestAnimationFrame']


applicationCache.encached = applicationCache.onnoupdate = ->
    console.log('cached')

applicationCache.onupdateready = ->
    applicationCache.swapCache()
    window.location.href = window.location.href
    console.log('cache swaped')

window.twatr = ->
    window.twat = TWAT = new TWTR.Widget({
      id: 'twatr',
      version: 2,
      type: 'search',
      search: '#html5',
      interval: 6000,
      title: '',
      subject: '',
      width: 540,
      height: 200,
      theme: {
        shell: {
          background: 'transparent',
          color: '#ffffff'
        },
        tweets: {
          background: 'rgba(255, 255, 255, 0.8)',
          color: '#444444',
          links: '#1985b5'
        }
      },
      features: {
        scrollbar: false,
        loop: true,
        live: true,
        hashtags: true,
        timestamp: true,
        avatars: true,
        toptweets: true,
        behavior: 'default'
      }
    }).render().start()
