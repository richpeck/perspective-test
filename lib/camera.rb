## Camera ##
## Shows a projection of the world from the 2D map ##

module Game # Game::Camera

  ## Bounding Boxes ##
  ## These should pull from the main file but hvae not figured out an appropriate scope yet
  BOUNDING_X = 1000 / 2 # this should be Window.width but since we're creating a split screen demo, make this half the width of the window  
  BOUNDING_Y = 550 

  ## Points ##
  ## Used to give us a way to call Point.x when defining new items ##
  Vector = Struct.new(:x,:y,:z,:w) do # https://stackoverflow.com/a/57148456/1143732
    def initialize(*args) # https://stackoverflow.com/a/17061970 (MRUBY - error when compiling "keyword_init")
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

    ################################
    ################################

    ## Constants ##
    ## Values to use inside the Camera class ##
    HEIGHT = 15
    PLAYER = 5

    ################################
    ################################

    ## Init ##
    ## Requires player, map & projectiles objects ##
    def initialize player, map, projectiles

      ## Vars ##
      ## These are used to define the various pieces of data for use in the class
      @player = player 
      @map = map 
      @projectiles = projectiles
      @walls = [] # populated later
      @projected_walls = [] # populated later

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
      ## Check if any walls exist, invoke them into 3D ##
      if @map.walls.any?

        ## Test Line ##
        ## This is the white line on the left of the screen - we are trying to render it as a wall in 3D space on the right ##
        @walls << Line.new(
          x1: (BOUNDING_X / 2) - 100, y1: (300 + 125),
          x2: (BOUNDING_X / 2), y2: (300 + 125),
          color: 'white',
          z: 10
        )
      
        # These are the new co-ordinates for the projected "3D" shapes
        # We'll use these points to create a new Quad with the projected co-ordinates in the "update" method below
        w =[]
        w[0] = Vector.new(x: @walls[0].x1, y: 0, z: @walls[0].y1)
        w[1] = Vector.new(x: @walls[0].x1, y: 0 + HEIGHT, z: @walls[0].y1)
        w[2] = Vector.new(x: @walls[0].x2, y: 0 + HEIGHT, z: @walls[0].y2)
        w[3] = Vector.new(x: @walls[0].x2, y: 0, z: @walls[0].y2)

        @projected_walls << @quad = Quad.new(
          x1: w[0].x, y1: w[0].z + w[0].y,
          x2: w[1].x, y2: w[1].z + w[1].y,
          x3: w[2].x, y3: w[2].z + w[2].y,
          x4: w[3].x, y4: w[3].z + w[3].y,
          color: 'teal'
        )
        @quad.remove

      end

    end

    ## Update ##
    ## Redraw the worldspace each time the player moves ##
    def update 

      ## Walls ##
      ## Check if any walls exist, invoke them into the 3D worldview and then hide the ones that are not showing. Expensive AF but can be optimized another time ##
      if @walls.any?

        ## Vars ##
        visible_walls = []

        ## Walls ##
        @walls.each_with_index do |wall, i|
          next unless i == 0 #debug mode
          (1..2).each { |p| visible_walls << i if @player.fov.contains?(wall.send("x#{p}"), wall.send("y#{p}")) } # using the 2D line so only need 1..2
        end

        ## Visisble Walls ##
        ## This exposes the list of "walls" within line of sight ##
        @projected_walls.each_with_index do |wall, i|
          if visible_walls.include?(i) 

            ## Wall is Visible ##
            ## Now we need to determine A) where the wall's POINTS will display inside our camera pane + B) where to display them ##
            camera = [@player.x, PLAYER, @player.y] # Y is constant (IE player is 5 high), Z = Y in 3D 
            angle  = @player.angle

            ## Normalization ##
            ## For each point, we need to get its 1) 3D Co-Ordinates, b) Angle, c) Distance RELATIVE to the camera ##
            ## Remember, the camera is independent of the worldview. It does not matter what else is in the world as long as it's visible to the camera ##
            puts wall.inspect

            ## With the above, we need to translate them into 


            ## Add back into the DOM ##
            wall.add

          else
            wall.remove 
          end
        end
        
      end

    end 

  end

end