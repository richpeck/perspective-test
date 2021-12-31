## Player ##
## Used to provide context to player ##

class Player

  ## Attr Accessors ##
  ## Allows us to call @player.x ##
  attr_accessor :angle, :velocity, :angle_velocity, :x, :y
    
  def initialize

    # Dot (object)
    @dot = Square.new(
      size: 5,
      color: 'red',
      z: 1
    )
    @dot.x = (Window.width - @dot.size) / 2
    @dot.y = (Window.height - @dot.size) / 2

    # Line (direction)
    @line = Line.new(
      x1: @dot.x + 3, y1: @dot.y,
      x2: @dot.x + 3, y2: @dot.y - 35,
      width: @dot.size,
      color: 'silver',
      z: 0,
      opacity: 0.2
    )

    # Vars 
    @angle = 0 # direction (defaults to 0 and is maintained with the line)
    @angle_velocity = 0 # increments at which angle will change (IE += 0.1)
    @velocity = 0 # speed (forward/backwards)

  end

  # Update Angle 
  def update_angle 
    @angle = (@angle + @angle_velocity) % 360
    radians = @angle_velocity * (Math::PI / 180)
    
    x2 = @line.x2 - @line.x1
    y2 = @line.y2 - @line.y1
    cos = Math.cos(radians)
    sin = Math.sin(radians)
    
    @line.x2 = ((x2 * cos) - (y2 * sin)) + @line.x1
    @line.y2 = ((x2 * sin) + (y2 * cos)) + @line.y1 
  end

  # Update Velocity
  def update_velocity
    radians = @angle * (Math::PI / 180)

    x = Math.sin(radians) * @velocity
    y = Math.cos(radians) * @velocity

    unless (@dot.x + x) < 0 || (@dot.x + x) >= Window.width
      @dot.x += x
      @line.x1 += x
      @line.x2 += x
    end 

    unless (@dot.y - y) < 0 || (@dot.y - y) >= Window.height
      @dot.y -= y
      @line.y1 -= y   
      @line.y2 -= y
    end 

    # Position
    # Update global position value for player (used in other classes)
    @x = @dot.x 
    @y = @dot.y
  end
  
end