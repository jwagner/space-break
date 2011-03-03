WIDTH = 640
HEIGHT = 480
RESOURCES =
    background: 'gfx/background0.jpg'
    brick: 'gfx/brick.png'
    ball: 'gfx/ball.png'
    paddle: 'gfx/paddle.png'
    pong: 'sfx/pong.ogg'

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
        x = @sample*@sampleWidth
        y = @canvas.height
        total = 0
        i = 0
        @ctx.fillStyle = '#111'
        @ctx.fillRect(0, 0, @canvas.width, textHeight)
        for name in @buckets.keys
            color = @colors[(i++)%@colors.length]
            bucket = @buckets[name]
            sample = bucket.samples[@sample]
            height = sample*@scale
            y -= height
            @ctx.fillStyle = color
            @ctx.fillRect(x, y, @sampleWidth, height)
            @ctx.fillText("#{name}: #{Math.round(bucket.average*100)/100} ms", textSpacing, textSpacing+@fontHeight*i)
            total += bucket.average
        @ctx.fillStyle = 'white'
        @ctx.fillText("total: #{Math.round(total*100)/100} ms / #{Math.round(1000/total)} fps", textSpacing, textSpacing+@fontHeight*(@buckets.keys.length+1))
        @ctx.fillStyle = 'black'
        @ctx.fillRect(x, 0, @sampleWidth, y)
        return


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
        Math.sqrt(@x*@x+@y*@y)

    normalize: ->
        this.divs(this.mag())

    copy: ->
        new V2(@x, @y)

    valueOf: ->
        throw 'Tried to use V2 as scalar'

    toString: ->
        "v2(#{@x}, #{@y})"


V2.random = ->
    new V2(Math.random()-0.5, Math.random()-0.5).normalize()
v2 = (x, y) -> new V2(x, y)


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


class Brick
    constructor: (@position) ->
        @shape = new Rect(@position, Brick.width, Brick.height)
        @destroyed = false

    draw: (ctx) ->
        ctx.drawImage(resources['brick'], @shape.left-5, @shape.top-5)


Brick.width = 40
Brick.height = 20

class Paddle
    constructor: (@position) ->
        @shape = new Rect(@position, 100, 20)
        @velocity = 0
        @acceleration = 0
        @target = @position.x

    draw: (ctx) ->
        ctx.drawImage(resources['paddle'], @shape.left-20, @shape.top-20)


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
            particle.velocity = direction.normalize().mul(v2(0.5-Math.random(), 0.5-Math.random())).normalize().muls(velocity*Math.random())
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
                alpha = Math.sqrt(particle.ttl - @t)
                ctx.fillStyle = "rgba(255, 205, 80, #{alpha})"
                ctx.fillRect(particle.position.x, particle.position.y, 1, 1)
        return



class Game
    constructor: (@canvas) ->
        @ctx = @canvas.getContext '2d'
        @scene =
            level: 0
            gameover: false
            score: 0
            balls: 3
            bricks: []
            ball: new Ball(v2(0, 0), v2(0, 0))
            paddle: new Paddle(v2(WIDTH/2, HEIGHT-50))
        @particles = new ParticleSystem(100)
        @nextLevel()
        @canvas.onmousemove = (e) =>
            @scene.paddle.target = e.clientX
        @perfhub = new JSPerfHub()
        @perfhub.start()

    nextLevel: ->
        @scene.balls += 2
        @scene.bricks = []
        cols = Math.floor(WIDTH/(Brick.width+10))
        rows = Math.floor((HEIGHT-100)*0.6/(Brick.height+10))
        for row in [0...rows]
            for col in [0...cols]
                x = col*(Brick.width+10)+Brick.width+(row&1)*20
                y = row*(Brick.height+10)+Brick.height+80
                @scene.bricks.push(new Brick(v2(x, y)))
        @newBall()

    newBall: ->
        if @scene.balls--
            ball = @scene.ball
            ball.shape.center.set(WIDTH/2, HEIGHT/3*2)
            ball.velocity = v2(Math.random()-0.5, Math.random()+1).normalize().muls(200)
        else
            @gameover = true

    tick: (t) ->
        if not @gameover
            @perfhub.tick('waiting')
            @physics(t)
            @perfhub.tick('physics')
            @render()
            @perfhub.tick('render')
            @perfhub.draw()
            @perfhub.tick('perfhub')
            @perfhub.start()

    physics: (t) ->

        ball = @scene.ball
        shape = ball.shape

        @scene.paddle.acceleration = (@scene.paddle.target - @scene.paddle.shape.center.x)*0.1
        @scene.paddle.velocity += @scene.paddle.acceleration
        @scene.paddle.velocity *= 0.7
        @scene.paddle.shape.center.x += @scene.paddle.velocity
        @scene.paddle.shape.recalc()
        if rect_circle_collision(@scene.paddle.shape, shape, shape.center)
            # try to push ball
            shape.center.x += @scene.paddle.velocity
            # but not over the edge
            if not (shape.radius <= shape.center.x <= WIDTH-shape.radius)
                shape.center.x -= @scene.paddle.velocity
                @scene.paddle.shape.center.x -= @scene.paddle.velocity
                @scene.paddle.shape.recalc()


        new_position = ball.position.add(ball.velocity.muls(t))
        if not (shape.radius <= new_position.x <= WIDTH-shape.radius)
            axis = 'x'
        if not (shape.radius <= new_position.y <= HEIGHT-shape.radius)
            if HEIGHT-shape.radius <= new_position.y
                @newBall()
                return
            if axis is 'x'
                axis = 'xy'
            else
                axis = 'y'
        if not axis and not ((axis = rect_circle_collision(@scene.paddle.shape, shape, new_position)) and paddle = true)
            for brick in @scene.bricks
                if not brick.destroyed and axis = rect_circle_collision(brick.shape, shape, new_position)
                    audio = resources['pong']
                    if audio.paused || audio.ended
                        audio.currentTime = 0
                        audio.play()
                    brick.destroyed = true
                    @scene.score += 100
                    break

        if axis is 'x'
            ball.velocity.x *= -1
        else if axis is 'y'
            ball.velocity.y *= -1
        else if axis is 'xy'
            ball.velocity.x *= -1
            ball.velocity.y *= -1
        if paddle
            ball.velocity.x += @scene.paddle.velocity*10
        if axis
            # we don't want the ball to move to flat because it's annoying
            if Math.abs(ball.velocity.y*2) < Math.abs(ball.velocity.x)
                ball.velocity.x *= 0.8
            # speed up ball after every bounce with an upper limit of
            # 400 px/s
            ball.velocity = ball.velocity.normalize().muls(Math.min(ball.velocity.mag()*1.01, 400))
            @particles.spawn(new_position.copy(), ball.velocity.muls(0.5), ball.velocity.mag(), 1.0, 25)
        else
            ball.position.iadd(ball.velocity.muls(t))
        @particles.tick(t)
        for brick in @scene.bricks
            if not brick.destroyed
                return
        @nextLevel()


    render: ->
        @ctx.globalAlpha = 0.5
        @ctx.drawImage(resources['background'], 0, 0)
        @ctx.globalAlpha = 1.0
        @particles.draw(@ctx)
        @scene.paddle.draw(@ctx)
        for brick in @scene.bricks
            if not brick.destroyed
                brick.draw(@ctx)
        @scene.ball.draw(@ctx)


        @ctx.fillStyle = 'rgba(255, 255, 255, 0.6)'
        @ctx.textAlign = 'center'
        @ctx.textBaseline = 'top'
        @ctx.font = '50px geo'
        @ctx.fillText(@scene.score, WIDTH/2, -5)
        @ctx.font = '16px geo'
        if not @gameover
            @ctx.fillText("#{@scene.balls} balls left", WIDTH/2, 40)
        else
            @ctx.fillStyle = 'rgba(255, 0, 0, 1.0)'
            @ctx.fillText("GAME OVER", WIDTH/2, 60)
        return


class Loader
    constructor: (resources) ->
        @resources = {}
        @pending = 0
        @failed = 0
        @load(resources)

    _success: (name, data) ->
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
        canplaythough = =>
            audio.currentTime = 0.0
            audio.pause()
            audio.volume = 1.0
            @_success(name, audio)
        audio.addEventListener('canplaythrough', canplaythough, false)
        audio.addEventListener('error', ((e) =>  @_error(name, e)), false)
        audio.src = src
        # gets all the browsers to preload the audio file
        audio.load()
        audio.play()
        audio.volume = 0


main = ->
    canvas = document.getElementById 'c'
    canvas.width = WIDTH
    canvas.height = HEIGHT
    ctx = canvas.getContext '2d'
    loader = new Loader(RESOURCES)
    resources = loader.resources
    check = =>
        if loader.pending > 0
            ctx.clearRect(0, 0, WIDTH, HEIGHT)
            ctx.textAlign = 'center'
            ctx.textBaseline = 'top'
            ctx.font = '50px geo'
            ctx.fillText('LOADING', WIDTH/2, 100)
            ctx.font = '16px geo'
            ctx.fillText("#{loader.pending} resources left", WIDTH/2, 140)
 
            setTimeout(check, 100)
        else
            start_game(canvas)
    check()


start_game = (canvas) ->
    window['game'] = game = new Game(canvas)
    t0 = new Date()
    callback = ->
        t1 = new Date()
        td = t1-t0
        t0 = t1
        game.tick(td*0.001)
    if requestAnimFrame
        f = ->
            callback()
            requestAnimFrame(f, canvas)
        requestAnimFrame(f, canvas)
    else
        setInterval(callback, 1000/60)
    game.render()

window.requestAnimFrame = window['requestAnimationFrame'] || window['webkitRequestAnimationFrame'] || window['mozRequestAnimationFrame']

main()
