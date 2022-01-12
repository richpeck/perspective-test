## Camera ##
## Shows a projection of the world from the 2D map ##

module Game # Game::Camera

  ## Bounding Boxes ##
  ## These should pull from the main file but hvae not figured out an appropriate scope yet
  BOUNDING_X = 500 # this should be Window.width but since we're creating a split screen demo, make this half the width of the window  
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
    Z      = 0

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
        color: background,
        z: Z
      )

      ## Floor ##
      ## This was taken from the Raycasting example I found online. I wanted to get it working so added the floor as a means to do it ##
      @floor = Quad.new(
        x1: BOUNDING_X, y1: (BOUNDING_Y / 2),
        x2: Window.width, y2: (BOUNDING_Y / 2),
        x3: Window.width, y3: BOUNDING_Y,
        x4: BOUNDING_X, y4: BOUNDING_Y,
        color: [background, background, floor, floor],
        z: Z + 1
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
          color: 'teal',
          z: 1
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
        projection_matrix = Matrix.projection(@player.angle, BOUNDING_X/BOUNDING_Y, 10, 100)

        ## Walls ##
        @walls.each_with_index do |wall, i|
          next unless i == 0 #debug mode
          (1..2).each { |p| visible_walls << i if @player.fov.contains?(wall.send("x#{p}"), wall.send("y#{p}")) } # using the 2D line so only need 1..2
        end

        ## Visisble Walls ##
        ## This exposes the list of "walls" within line of sight - we need to paint these onto the camera pane/canvas ##
        @projected_walls.each_with_index do |wall, i|
          if visible_walls.include?(i) 

            ## View Space ##
            ## We need to calculate each point as it appears RELATIVE to the camera ##
            ## The camera should be [0,5,0] and each point from the world should be drawn relative to it ##
            (1..2).each do |p| # each vector (only need to work with 2D space -- heights are constant so they can just inherit from the 2D)

              ## Calculate distance between the point and camera ##
              ## x1,y1 = origin ##
              ## x2,y2 = point ##
              d = distance(@player.x, @player.y, @walls[i].send("x#{p}"), @walls[i].send("y#{p}"))

              ## Calculate angle between camera normal (line) and the point ##
              ## normal = @player.line.x2, @player.line.y2 ##
              ## origin = @player.x, @player.y ##
              ## point  = wall.send("x#{p + 1}"), wall.send("y#{p + 1}") ##
              normal = Vector.new(x: @player.line.x2, y: @player.line.y2)
              origin = Vector.new(x: @player.x, y: @player.y)
              point  = Vector.new(x: @walls[i].send("x#{p}"), y: @walls[i].send("y#{p}"))

              ## Angle ##
              ## We need to translate this into the angle through which we'll see the point in our camera view (IE normalized against the camera) ##
              a = angle(normal, origin, point) # Gives us the angle away from the camera normal
              b = angle_to_screen(a) # Gives us the screen X co-ordinate from said angle (we get Y co-ordinate from the scaling factor from the distance)

              ## Height ##
              ## Now we need to figure out the height of the point on the screen


              
              if p == 1 
                wall.send("x#{p}=", b)
                wall.x2 = b
              elsif p == 2
                wall.x3 = b
                wall.x4 = b
              end

            end
            
            ## Add back into the DOM ##
            wall.add

          else

            ## No longer in field of view ##
            wall.remove 

          end
        end
        
      end

    end 

    private 

    ## Distance ##
    ## Get 2D distance between camera and point (all distances done in 2D because we just want to spoof them for 3D) ##
    def distance x1, y1, x2, y2 
      Math.sqrt(((x2 - x1) ** 2) + ((y2 - y1) ** 2) * 1.0)
    end

    ## Angle ##
    ## https://riptutorial.com/math/example/25158/calculate-angle-from-three-points ##
    def angle normal, origin, point

      numerator = origin.y * (normal.x - point.x) + normal.y * (point.x - origin.x) + point.y * (origin.x - normal.x)
      denominator = (origin.x - normal.x) * (normal.x - point.x) + (origin.y - normal.y) * (normal.y - point.y)

      ratio = numerator/denominator

      angleRad = Math.atan(ratio)
      angleDeg = (angleRad * 180)/Math::PI

      return angleDeg

    end

    ## Angle → Screen ##
    ## This takes the angle FROM the camera and translates it into a position on the screen ##
    ## Works similarly to the racasting technique (IE angle at which point appears is translated into screen X co-ordinate) ##
    def angle_to_screen angle 

      ## Screen Size ##
      ## This determines the number of vertical columns for our screen width vs the FOV angle ##
      column_width = BOUNDING_X / @player.fov_angle # Splits up the screen width into chunks based on FOV (for example, if I have 60 degree FOV and the screen width is 500, each vertical column is worth about 8.3 pixels)
      
      ## Position ##
      ## Take the provided angle and ensure that we are able to allocate it to the correct column (our "x" co-ordinate)
      column = angle + (@player.fov_angle / 2) ## (this normalizes the screen columns from being (-(fov_angle/2) - 0 - (fov_angle)) to (0 - fov_angle)). the reason for this is to simplify the maths

      ## Co-Ordinate ##
      ## The "X" co-ordinate for the point should then be the column width multiplied by the column number (EG 8.33 * 15) ##
      return (column_width * column) + BOUNDING_X ## BOUNDING_X added to provide to offset worldview

    end

    ## Distance → Height ##
    ## Takes the distance of the point from the camera and uses a scaling function to provide height that can be used to determine the Y co-ordinate ##
    def distance_to_height distance 



    end

  end

end