## Map ##
## Allows us to create a map which the player can traverse ##

class Map

  # Attributes
  attr_accessor :walls
    
  def initialize

    # Walls
    # Array of vector co-ordinates which allow us to create a series of walls
    @walls = []

  end
    
end