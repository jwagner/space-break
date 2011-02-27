WIDTH = 640
HEIGHT = 480
RESOURCES =
    background: 'gfx/background0.jpg'

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


class Brick
    constructor: (@position) ->
        @shape = new Rect(@position, Brick.width, Brick.height)
        @destroyed = false


class Paddle
    constructor: (@position) ->
        @shape = new Rect(@position, 100, 20)
        @velocity = 0
        @acceleration = 0
        @target = @position.x

Brick.width = 80
Brick.height = 30

class Game
    constructor: (@canvas, @resources) ->
        @ctx = @canvas.getContext '2d'
        @scene =
            score: 0
            balls: 4
            bricks: []
            ball: new Ball(v2(0, 0), v2(0, 0))
            paddle: new Paddle(v2(WIDTH/2, HEIGHT-50))
        for row in [0...4]
            for col in [0...6]
                x = col*(Brick.width+10)+Brick.width+(row&1)*20
                y = row*(Brick.height+10)+Brick.height+50
                @scene.bricks.push(new Brick(v2(x, y), 10))
        @newBall()
        @canvas.onmousemove = (e) =>
            @scene.paddle.target = e.clientX

    newBall: ->
        ball = @scene.ball
        ball.shape.center.set(WIDTH/2, HEIGHT/2)
        if @scene.balls--
            ball.velocity = v2(Math.random()-0.5, Math.random()).normalize().muls(200)
        else
            # game over
            ball.velocity.set(0, 0)

    tick: (t) ->
        @physics(t)
        @render()

    physics: (t) ->

        @scene.paddle.acceleration = (@scene.paddle.target - @scene.paddle.shape.center.x)*0.1
        @scene.paddle.velocity += @scene.paddle.acceleration
        @scene.paddle.velocity *= 0.7
        @scene.paddle.shape.center.x += @scene.paddle.velocity
        @scene.paddle.shape.recalc()

        ball = @scene.ball
        shape = ball.shape
        new_position = ball.position.add(ball.velocity.muls(t))
        if not (shape.radius < shape.center.x < WIDTH-shape.radius)
            axis = 'x'
        if not (shape.radius < shape.center.y < HEIGHT-shape.radius)
            if HEIGHT-shape.radius < new_position.y
                @newBall()
                return
            if axis is 'x'
                axis = 'xy'
            else
                axis = 'y'
        if not axis and not ((axis = rect_circle_collision(@scene.paddle.shape, ball.shape, new_position)) and paddle = true)
            for brick in @scene.bricks
                if not brick.destroyed and axis = rect_circle_collision(brick.shape, ball.shape, new_position)
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
        ball.position.iadd(ball.velocity.muls(t))


    render: ->
        @ctx.drawImage(@resources['background'], 0, 0)
        @ctx.fillStyle = 'rgba(255, 255, 255, 0.6)'
        this.renderCircle @scene.ball.shape
        for brick in @scene.bricks
            if not brick.destroyed
                this.renderRect(brick.shape)
        this.renderRect(@scene.paddle.shape)

        @ctx.textAlign = 'center'
        @ctx.textBaseline = 'top'
        @ctx.font = '50px geo'
        @ctx.fillText(@scene.score, WIDTH/2, -5)
        @ctx.font = '16px geo'
        if @scene.balls >= 0
            @ctx.fillText("#{@scene.balls} balls left", WIDTH/2, 40)
        else
            @ctx.fillText("GAME OVER", WIDTH/2, 40)
        return

    renderCircle: (circle) ->
        @ctx.beginPath()
        @ctx.arc(circle.center.x, circle.center.y, circle.radius, 0, Math.PI*2, true)
        @ctx.closePath()
        @ctx.fill()

    renderRect: (rect) ->
        @ctx.fillRect(rect.left, rect.top, rect.width, rect.height)

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
            if /|.(jpe?g|gif|png)/.test src
                @loadImage(name, src)
            else if src.test /\.(og(g|a)|mp3)$/
                @loadAudio(name, src)
            else
                throw 'unknow resource type ' + src
            @pending++

    loadImage: (name, src) ->
        img = new Image()
        img.onload = => @_success(name, img)
        img.onerror = (e) => @_error(name, e)
        img.src = src

    loadAudio: (name, src) ->
        audio = document.createElement('audio')
        audio.preload = 'auto'
        audio.oncanplaythough = =>
            audio.currentTime = 0.0
            audio.pause()
            audio.volume = 1.0
            @_success(name, audio)
        audio.onerror = (e) =>
            @_error(name, e)
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
            start_game(canvas, loader.resources)
    check()


start_game = (canvas, resources) ->
    window['game'] = game = new Game(canvas, resources)
    t0 = new Date()
    i = requestAnimFrame(f =->
        t1 = new Date()
        td = t1-t0
        t0 = t1
        game.tick(td*0.001)
        requestAnimFrame(f, canvas)
    , canvas)
    game.render()

`window['requestAnimFrame'] = (function(){
return  window['requestAnimationFrame'] || 
window['webkitRequestAnimationFrame'] || 
window['mozRequestAnimationFrame'] || 
window['oRequestAnimationFrame']
|| 
window['msRequestAnimationFrame']
|| 
function(/*
function
*/
callback,
/*
DOMElement
*/
element){
window.setTimeout(callback,
1000
/
60);
};
})();`

main()
