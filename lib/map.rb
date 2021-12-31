## Map ##
## Allows us to create a map which the player can traverse ##

class Map

  # Attributes
  attr_accessor :walls
    
  def initialize

    # Walls
    # Array of vector co-ordinates which allow us to create a series of walls
    #@walls = []

    # Initial Walls 
    # This is just a test to see if we can do collision code
    @walls = Line.new(
      x1: 125, y1: 100,
      x2: 350, y2: 400,
      width: 2,
      color: 'yellow',
      z: 20
    )

  end
    
end