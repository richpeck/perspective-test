## Camera ##
## Shows a projection of the world from the 2D map ##

module Game # Game::Camera

  ## Bounding Boxes ##
  ## These should pull from the main file but hvae not figured out an appropriate scope yet
  BOUNDING_X = 1000 / 2 # this should be Window.width but since we're creating a split screen demo, make this half the width of the window  
  BOUNDING_Y = 550 

  ## Points ##
  ## Used to give us a way to call Point.x when defining new items ##
  Point = Struct.new(:x,:y) do # https://stackoverflow.com/a/57148456/1143732
    def initialize(*args) # https://stackoverflow.com/a/17061970 (MRUBY - error when compiling for "keyword_init")
      opts = args.last.is_a?(Hash) ? args.pop : Hash.new
      super(*args)
      opts.each_pair do |k, v|
        self.send "#{k}=", v
      end
    end
  end

  ## Camera ##
  ## This is the main camera object which renders our canvas ##
  class Camera

    ## Other Constants ##
    ## Used for things such as ceiling height ##
    HEIGHT = 150 # height of the walls from the floor (considering the floor is 0)
    FOV    = 350 # render distance

    ## Attr Accessor ##
    ## Editable from outside - allows us to make public methods that can be used by other parts of app ##
    attr_accessor :walls

    ## Init ##
    ## Requires player, map & projectiles objects ##
    def initialize player, map, projectiles

      ## Vars ##
      ## These are used to define the various pieces of data for use in the class
      @player = player 
      @map = map 
      @projectiles = projectiles
      @original_walls = [] # populated later
      @walls = [] # populated later
      @distance = 0 # populated later

      ## Locals ##
      ## Used for colours and other things ##
      background = 'red'
      floor = 'black'

      ## Bounding Box ##
      ## This is the area into-which we'll render everything ##
      @box = Quad.new(
        x1: BOUNDING_X, y1: 0,
        x2: Window.width, y2: 0,
        x3: Window.width, y3: BOUNDING_Y,
        x4: BOUNDING_X, y4: BOUNDING_Y,
        color: background
      )

      ## Floor ##
      ## This was taken from the Raycasting example I found online. I wanted to get it working so added the floor as a means to do it ##
      @floor = Quad.new(
        x1: BOUNDING_X, y1: (BOUNDING_Y / 2),
        x2: Window.width, y2: (BOUNDING_Y / 2),
        x3: Window.width, y3: BOUNDING_Y,
        x4: BOUNDING_X, y4: BOUNDING_Y,
        color: [background, background, floor, floor]
      )

      ## Walls ##
      ## Check if any walls exist, invoke them into the 3D worldview ##
      if @map.walls.any?

        line = Line.new(
          x1: 100, y1: (200 + 125),
          x2: (100 + 125), y2: (200 + 125),
          size: 125,
          color: 'white',
          z: 10
        )
      
        wall = []
        wall[0] = Point.new(x: line.x1 + BOUNDING_X, y: line.y1)
        wall[1] = Point.new(x: line.x2 + BOUNDING_X, y: line.y2)
        wall[2] = Point.new(x: line.x1 + BOUNDING_X, y: line.y1 - HEIGHT)
        wall[3] = Point.new(x: line.x2 + BOUNDING_X, y: line.y2 - HEIGHT)

        @walls << Quad.new(
          x1: wall[0].x, y1: wall[0].y, # white
          x2: wall[2].x, y2: wall[2].y, # yellow
          x3: wall[3].x, y3: wall[3].y, # green
          x4: wall[1].x, y4: wall[1].y, # blue
          color: ['blue', 'yellow' ,'green', 'white']
        )

        # Used to store the original wall points 
        @original_walls << wall

      end

    end

    ## Update ##
    ## Redraw the worldspace each time the player moves ##
    def update 

      ## I think we need to work backwards from the user (IE what they will first see)
      ## We can make this work by extending outwards from the user's X,Y co-ordinates
      x = @player.x 
      y = @player.y 

      ## Projectiles ##
      ## These have a definite set of dimensions etc so we can see how they look on screen
      if @projectiles.any?

        ## Determine distance from player
        ## https://www.geeksforgeeks.org/program-calculate-distance-two-points/
        @projectiles.select { |p|  p.x <= BOUNDING_X && p.y <= BOUNDING_Y }.each do |projectile|
          a = (projectile.x - @player.x) ** 2
          b = (projectile.y - @player.y) ** 2

          distance = Math.sqrt((a + b) * 1.0)
        end

      end

      ## Walls ##
      ## Check if any walls exist, invoke them into the 3D worldview and then hide the ones that are not showing. Expensive AF but can be optimized another time ##
      if @walls.any?

        ## Wall is a set of points which we have created from the lines drawn for the map ##
        @walls.each_with_index do |wall,i|

          ## Central ##
          central = Point.new(x: (@original_walls[i][0].x + @original_walls[i][1].x) / 2, y: (@original_walls[i][0].y + @original_walls[i][2].y) / 2)

                        ## Scale ##
                        scale = ((@original_walls[i][0].y - @player.y)/@original_walls[i][0].y) / 0.1 # percentage of how far the user is in proportion to the object

          ## Prevent inversion ##
          if scale.positive?

            ## Hide from worldview (behind us)
            wall.remove

          else

            ## Show in worldview ##
            wall.add 

            ## Points ##
            [1,2,3,4].each do |p|

              ## Distance ##
              ## Get the distance from the player to that point specifically ##
              a = (wall.send("x#{p}") - @player.x) ** 2
              b = (wall.send("y#{p}") - @player.y) ** 2
    
              ## Actual Distance ##
              ## This allows us to now use this figure to calculate scale ##
              distance = Math.sqrt((a + b) * 1.0)

              ## Scale ##
              #scale = ((@original_walls[i][0].y - @player.y)/@original_walls[i][0].y) / 0.1 # percentage of how far the user is in proportion to the object

            end

            ## Points ##
            wall.x4 = central.x - (@original_walls[i][1].x / scale) #top left // white
            wall.y4 = central.y + (@original_walls[i][1].y / scale)

            wall.x1 = central.x + (@original_walls[i][0].x / scale) #top right // blue
            wall.y1 = central.y + (@original_walls[i][0].y / scale)

            wall.x3 = central.x - (@original_walls[i][3].x / scale) #bottom left // green
            wall.y3 = central.y - (@original_walls[i][3].y / scale)

            wall.x2 = central.x + (@original_walls[i][2].x / scale) #bottom right // yellow
            wall.y2 = central.y - (@original_walls[i][2].y / scale)

          end

        end
        
      end

    end 
      
  end

end