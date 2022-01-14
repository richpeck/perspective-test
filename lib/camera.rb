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
    HEIGHT = 30
    PLAYER = 5
    COLOUR = '#2b1cff'
    BACKGROUND = 'red'
    FLOOR_FORE = '#383838'
    FLOOR_BACK = 'black'
    Z = 0 #-> z-index used for camera overlap/clipping

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
        color: BACKGROUND,
        z: Z
      )

      ## Floor ##
      ## This was taken from the Raycasting example I found online. I wanted to get it working so added the floor as a means to do it ##
      @floor = Quad.new(
        x1: BOUNDING_X, y1: (BOUNDING_Y / 2),
        x2: Window.width, y2: (BOUNDING_Y / 2),
        x3: Window.width, y3: BOUNDING_Y,
        x4: BOUNDING_X, y4: BOUNDING_Y,
        color: [FLOOR_BACK, FLOOR_BACK, FLOOR_FORE, FLOOR_FORE],
        z: Z + 1
      )

      ## Walls ##
      ## Check if any walls exist, invoke them into 3D ##
      if @map.walls.any?

        ## Walls ##
        ## This is the white line on the left of the screen - we are trying to render it as a wall in 3D space on the right ##
        @map.walls.each do |wall|
          line = Line.new(
            x1: BOUNDING_X + wall.x1, y1: BOUNDING_X + wall.y1,
            x2: wall.x2, y2: wall.y2,
            z: 10
          )
          line.remove
          @walls << line
        end

        # These are the new co-ordinates for the projected "3D" shapes
        # We'll use these points to create a new Quad with the projected co-ordinates in the "update" method below
        @walls.each do |wall|

          w = []
          w[0] = Vector.new(x: wall.x1, y: 0, z: wall.y1)
          w[1] = Vector.new(x: wall.x1, y: 0 + HEIGHT, z: wall.y1)
          w[2] = Vector.new(x: wall.x2, y: 0 + HEIGHT, z: wall.y2)
          w[3] = Vector.new(x: wall.x2, y: 0, z: wall.y2)

          @projected_walls << @quad = Quad.new(
            x1: w[0].x, y1: w[0].z + w[0].y,
            x2: w[1].x, y2: w[1].z + w[1].y,
            x3: w[2].x, y3: w[2].z + w[2].y,
            x4: w[3].x, y4: w[3].z + w[3].y,
            z: 1
          )
          @quad.remove

        end

      end

    end

    ## Update ##
    ## Redraw the worldspace each time the player moves ##
    def update 

      ## Walls ##
      ## Check if any walls exist, invoke them into the 3D worldview and then hide the ones that are not showing. Expensive AF but can be optimized another time ##
      if @walls.any?

        ## Vars ##
        visible_walls, points, colours = [],[],[]

        points[0] = Vector.new(x: @player.fov.x1, y: @player.fov.y1)
        points[1] = Vector.new(x: @player.fov.x2, y: @player.fov.y2)
        points[2] = Vector.new(x: @player.fov.x3, y: @player.fov.y3)

        ## Walls ##
        @walls.each_with_index do |wall, i|
          (1..2).each do |p|
            points[3] = Vector.new(wall.send("x#{p}"), wall.send("y#{p}"))
            visible_walls << i if inside?(points[3], points[0], points[1], points[2]) # using the 2D line so only need 1..2
          end
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
              a = -(angle(normal, origin, point)) # Gives us the angle away from the camera normal
              x = angle_to_screen(a) # Gives us the screen X co-ordinate from said angle (we get Y co-ordinate from the scaling factor from the distance)

              ## Height ##
              ## Now we need to figure out the height of the point on the screen (relative to the total screen height)
              y = distance_to_height(d) ## returns height values tp be used for top; bottom will deduct this value

              ## Colour ##
              ## This allows us to change the colour depending on the distance ##
              distance_percentage = (BOUNDING_Y - d)/BOUNDING_Y

              ## Darkened ##
              ## Gives us the ability to darken a particular part of the wall's colour ##
              colour = darken_color(COLOUR, distance_percentage)

              ## Populate the x/y values for the wall ##
              case p 
                when 1 
                  wall.x1 = x
                  wall.x2 = x

                  wall.y2 = BOUNDING_Y - y
                  wall.y1 = y

                  colour = Color.new(colour)
                  colours[0] = colour
                  colours[1] = colour 
                when 2
                  wall.x3 = x
                  wall.y3 = BOUNDING_Y - y 

                  wall.x4 = x
                  wall.y4 = y

                  colour = Color.new(colour)
                  colours[2] = colour 
                  colours[3] = colour
              end

              ## Z Buffer ##
              wall.z = 15 + (-(d) / 100).truncate if p == 2

            end

            ## Add Colours ##
            wall.color = colours if colours.size == 4
            
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

    ## Inside? ##
    ## Is the point inside the FOV triangle? ##
    ## http://jsfiddle.net/PerroAZUL/zdaY8/1/ & https://stackoverflow.com/a/20861130/1143732 ##
    def inside? p, p0, p1, p2

      s = (p0.x - p2.x) * (p.y - p2.y) - (p0.y - p2.y) * (p.x - p2.x)
      t = (p1.x - p0.x) * (p.y - p0.y) - (p1.y - p0.y) * (p.x - p0.x)
  
      return false if ((s < 0) != (t < 0) && s != 0 && t != 0)
  
      d = (p2.x - p1.x) * (p.y - p1.y) - (p2.y - p1.y) * (p.x - p1.x)
      return d == 0 || (d < 0) == (s + t <= 0)
      
    end

    ## Distance ##
    ## Get 2D distance between camera and point (all distances done in 2D because we just want to spoof them for 3D) ##
    def distance x1, y1, x2, y2 
      Math.sqrt(((x2 - x1) ** 2) + ((y2 - y1) ** 2) * 1.0)
    end

    ## Distance → Height ##
    ## Takes the distance of the point from the camera and uses a scaling function to provide height that can be used to determine the Y co-ordinate ##
    def distance_to_height distance 

      ## We need to convert the distance to the point into an equivalent height (porportional to the screen (EG 90%)) ##
      ## To do this, we take the raw distance to the point and convert it into decimal format ##
      ## https://youtu.be/xW8skO7MFYw?t=833 ##
      (BOUNDING_Y / 2.0) - ((BOUNDING_Y / distance) + HEIGHT)


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

    ## Colour Manipulation (Darken) ##
    ## Amount should be a decimal between 0 and 1. Lower means darker
    ## https://www.redguava.com.au/2011/10/lighten-or-darken-a-hexadecimal-color-in-ruby-on-rails/
    def darken_color(hex_color, amount=0.4)
      hex_color = hex_color.gsub('#','')
      rgb =[]
      rgb[0] = (hex_color[0..1].hex.to_i * amount.abs).round
      rgb[1] = (hex_color[2..3].hex.to_i * amount.abs).round
      rgb[2] = (hex_color[4..5].hex.to_i * amount.abs).round
      "#%02x%02x%02x" % rgb
    end

  end

end