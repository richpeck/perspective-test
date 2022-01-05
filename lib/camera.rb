## Camera ##
## Shows a projection of the world from the 2D map ##

module Game # Game::Camera

  ## Bounding Boxes ##
  ## These should pull from the main file but hvae not figured out an appropriate scope yet
  BOUNDING_X = 1000 / 2 # this should be Window.width but since we're creating a split screen demo, make this half the width of the window  
  BOUNDING_Y = 550 

  class Camera

    ## Init ##
    ## Requires player, map & projectiles objects ##
    def initialize player, map, projectiles

      ## Vars ##
      ## These are used to define the various pieces of data for use in the class
      @player = player 
      @map = map 
      @projectiles = projectiles

      ## Box ##
      ## This is the area into-which we'll render everything ##
      @box = Quad.new(
        x1: BOUNDING_X, y1: 0,
        x2: Window.width, y2: 0,
        x3: Window.width, y3: BOUNDING_Y,
        x4: BOUNDING_X, y4: BOUNDING_Y,
        color: 'red'
      )

    end

    ## Update ##
    ## Redraw the worldspace each time the player moves ##
    def update 

      ## The view is infinite, meaning that we can "see" everything in the bounding box
      ## We need to take this infinite view and make objects appear relative to the user
      
      ## I think we need to work backwards from the user (IE what they will first see)
      ## We can make this work by extending outwards from the user's X,Y co-ordinates
      x = @player.x 
      y = @player.y 

      ## Initially start with projectiles
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

    end 
      
  end

end