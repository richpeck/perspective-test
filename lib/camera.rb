## Camera ##
## Shows a projection of the world from the 2D map ##

module Game # Game::Camera

  ## Bounding Boxes ##
  ## These should pull from the main file but hvae not figured out an appropriate scope yet
  BOUNDING_X = 1000 / 2 # this should be Window.width but since we're creating a split screen demo, make this half the width of the window  
  BOUNDING_Y = 550 

  class Camera

    ## Other Constants ##
    ## Used for things such as ceiling height ##
    HEIGHT = 10 # height of the walls from the floor (considering the floor is 0)

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
      @walls = [] # populated later

      ## Bounding Box ##
      ## This is the area into-which we'll render everything ##
      @box = Quad.new(
        x1: BOUNDING_X, y1: 0,
        x2: Window.width, y2: 0,
        x3: Window.width, y3: BOUNDING_Y,
        x4: BOUNDING_X, y4: BOUNDING_Y,
        color: 'red'
      )

      ## Walls ##
      ## Check if any walls exist, invoke them into the 3D worldview and then hide the ones that are not showing. Expensive AF but can be optimized another time ##
      if @map.walls.any?
        @map.walls.each do |wall|

          @walls << Quad.new(
            x1: BOUNDING_X + wall.x1, y1: wall.y1 + HEIGHT,
            x2: BOUNDING_X + wall.x1, y2: wall.y1,
            x3: BOUNDING_X + wall.x2, y3: wall.y2,
            x4: BOUNDING_X + wall.x2, y4: wall.y2 + HEIGHT,
            color: 'white',
            z: 20
          )

        end
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

          ## p1 = Circle.new(radius: 20, color: 'white')
          ## p1.x = Window.width - ((BOUNDING_X - p1.radius) / 2)
          ## p1.y = (BOUNDING_Y - p1.radius) / 2
          ## p1.radius = p1.radius / distance
        end

      end

      ## Walls ##
      ## Check if any walls exist, invoke them into the 3D worldview and then hide the ones that are not showing. Expensive AF but can be optimized another time ##
      if @walls.any?
        @walls.each do |wall|

          ## Distance ##
          ## This allows us to determine the distance from the user (at that time) ##
          wall

          ## Translate 2D points into upright quads (using distance (z) as a means to change the spacing and positioning between points) ##
          ## Because we have a constant height (HEIGHT), we can change extrapolate the points based upon in
          

          ## First step is to get a list of all the points from the present geometry and convert them to 3D points 
          ## Because we can't paint 3D points, we have to spoof it with depth/perspective
          

        end
      end

    end 
      
  end

end