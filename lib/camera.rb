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

    ## RPECK 11/01/2022
    ## This is my attempt at creating a "camera" to visualize our worldview with perspective
    ## I will briefly explain how it works here

    ## 1. The world is defined with the various 2D elements in @map, @hud etc
    ## 2. The player represents the camera (IE the player's co-ordinates are where the camera is located)
    ## 3. When the player moves in worldspace, the camera needs to update its viewing plane, angle and height
    ## 4. Once this has been done, it is able to take objects from the world and express them on screen using the Model > View > Projection set of matrices

    ## First, we need to convert 2D lines into "walls" (3D objects defined by a series of points projected from the 2D)
    ## Second, we need to use the MVP set of matrices to "project" the walls into model and view space
    ## Third, we need to be able to turn these into projected planes

    ################################
    ################################

    ## Constants ##
    ## Values to use inside the Camera class ##
    HEIGHT = 15

    ################################
    ################################

    ## Attr Accessors ##
    ## Values changeable publicly (IE @camera.direction)
    #attr_accessor :direction

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
      @original_walls = [] # populated later

      ## Perspective stuff ##
      @fov_angle = @player.fov_angle
      @aspect_ratio = BOUNDING_Y / BOUNDING_X
      @zFar = @player.y - 150
      @zNear = @player.y

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
        line = Line.new(
          x1: (BOUNDING_X / 2) - 100, y1: (300 + 125),
          x2: (BOUNDING_X / 2), y2: (300 + 125),
          color: 'white',
          z: 10
        )

        #################
        ## Model Space ##
        #################

        ## The first step is to "normalize" the model -- which means taking a set of geometric values and usng them to create an object ##
        ## For example, if you wanted to make a 2D square, you would require 4 points at [(-1,-1), (-1,1), (1,-1), (1,1)] ##

        ## Because we have defined the line above, we can use the line's co-ordinates to create a geometric shape based on its model space ##
        ## model = [[-x,-y,z], [-x,y,z], [x,-y,z], [x,y,z]] -> ALL NEED TO BE NORMALIZED AGAINST THE SHAPE ITSELF (NOT THE WORLDVIEW) ##
        x_length = (line.x2 - line.x1) / 2.0
        y_length = (line.y2 - line.y1) / 2.0 # 2.0 creates float

        ## Model Matrix ##
        ## This outputs a model matrix which we can populate with the points computed above (normalized around 0,0 inside the model) ##
        model = Matrix.model(x_length, y_length, HEIGHT) # added "height" to help us compute the height of the object (considering the walls have the same height)

        ################
        ## View Space ##
        ################
      
        ## The second step is to "normalize" the model against the camera (world space) ##
        ## If the camera is at [0,0,0] and the model is positioned at [50,100,30], that means that we can apply the above model geometry to the view the camera creates ##
        #camera = 
      
        # These are the new co-ordinates for the projected "3D" shapes
        # We'll use these points to create a new Quad with the projected co-ordinates in the "update" method below
        @walls[0] = []
        @walls[0][0] = Vector.new(x: line.x1, y: 100, z: line.y1) # translate "y" from our 2D world to z and then reset the y co-ord to be 0 (ground) or HEIGHT (wall height)
        @walls[0][1] = Vector.new(x: line.x2, y: 100, z: line.y2)
        @walls[0][2] = Vector.new(x: line.x1, y: 100 + HEIGHT, z: line.y1)
        @walls[0][3] = Vector.new(x: line.x2, y: 100 + HEIGHT, z: line.y2)

      end

    end

    ## Update ##
    ## Redraw the worldspace each time the player moves ##
    def update 

      ## Walls ##
      ## Check if any walls exist, invoke them into the 3D worldview and then hide the ones that are not showing. Expensive AF but can be optimized another time ##
      if @walls.any?

        ## Vars ##
        new_wall = []

        ## Projection Matrix ##
        projection_matrix = Matrix.projection(@fov_angle, @aspect_ratio, @zNear, @zFar)

        ## New Walls ##
        @walls.each_with_index do |wall, i|
          next unless i == 0

          ## Vars ##
          new_wall[i] = []
          
          ## Create a new wall (this will be a quad which will populate the worldview) ##
          ## For now, we just need to get the new points by multiplying by the matrix below ##
          (0..3).each do |p|
            #new_wall[i][p] = Matrix.multiply [[wall[p].x, wall[p].y, wall[p].z, 1]], projection_matrix # will return x,y,z value (ignore z because we don't need it for 2d)
          end

          # Probably need to fix this - there is an extra level of depth which is not required
          #new_wall[i].flatten!(1)

        end
        
      end

    end 

  end

end