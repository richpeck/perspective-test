## Player ##
## Used to provide context to player ##

module Game # Game::Player

  class Player

    ## Attr Accessors ##
    ## Allows us to call @player.x ##
    attr_accessor :angle, :velocity, :angle_velocity, :x, :y

    ## Attr Readers ##
    ## Defines readable vars ##
    attr_reader :fov_angle, :fov_length
      
    def initialize

      # Vars 
      @angle          = 0 # direction (defaults to 0 and is maintained with the line)
      @angle_velocity = 0 # increments at which angle will change (IE += 0.1)
      @velocity       = 0 # speed (forward/backwards)
      @fov_angle      = 25 # degrees of fov_angle
      @fov_length     = 500 # length of fov

      # Dot (object)
      @dot = Square.new(
        size: 5,
        color: 'red',
        z: 1
      )
      @dot.x = (BOUNDING_X - @dot.size) / 2
      @dot.y = (BOUNDING_Y - @dot.size) - 10

      # Line (direction)
      @line = Line.new(
        x1: @dot.x + 3, y1: @dot.y,
        x2: @dot.x + 3, y2: @dot.y - 35,
        width: @dot.size,
        color: 'silver',
        z: 0,
        opacity: 0.2
      )

      # FoV 
      point_3 = update_radians({ x: @dot.x, y: @dot.y - fov_length }, { x: @dot.x, y: @dot.y }, (0 - (@fov_angle/2)) % 360)
      point_4 = update_radians({ x: @dot.x, y: @dot.y - fov_length }, { x: @dot.x, y: @dot.y }, (0 + (@fov_angle/2)) % 360)

      @fov = Quad.new(
        x1: @dot.x, y1: @dot.y,
        x2: @dot.x, y2: @dot.y,
        x3: point_3[:x], y3: point_3[:y],
        x4: point_4[:x], y4: point_4[:y],
        color: 'aqua',
        z: 10,
        opacity: 0.025
      )

      # x,y
      @x = @dot.x # x 
      @y = @dot.y # y

    end

    # Update Angle 
    def update_angle 
      @angle = (@angle + @angle_velocity) % 360

      radians = update_radians({ x: @line.x2, y: @line.y2 }, { x: @line.x1, y: @line.y1 })

      @line.x2 = radians[:x]
      @line.y2 = radians[:y]

      update_fov # update the field of view to match
    end

    # Update FoV
    def update_fov 
      radians = @angle * (Math::PI / 180)

      # Angles 
      [3,4].each do |i|
        angles = update_radians({ x: @fov.send("x#{i}"), y: @fov.send("y#{i}") }, { x: @fov.x1, y: @fov.y1 })

        @fov.send("x#{i}=", angles[:x])
        @fov.send("y#{i}=", angles[:y])
      end
    end

    # Update Velocity
    def update_velocity walls
      radians = @angle * (Math::PI / 180)

      x = Math.sin(radians) * @velocity
      y = Math.cos(radians) * @velocity

      unless (@dot.x + x) <= 0 || (@dot.x + x) >= BOUNDING_X
        unless walls.contains? [@dot.x, @dot.y], [(@dot.x + x), (@dot.y - y)]
          @dot.x += x
          @line.x1 += x
          @line.x2 += x

          @fov.x1 += x 
          @fov.x2 += x 
          @fov.x3 += x 
          @fov.x4 += x
        end
      end 

      unless (@dot.y - y) <= 0 || (@dot.y - y) >= BOUNDING_Y
        unless walls.contains? [@dot.x, @dot.y], [(@dot.x + x), (@dot.y - y)]
          @dot.y -= y
          @line.y1 -= y   
          @line.y2 -= y

          @fov.y1 -= y 
          @fov.y2 -= y 
          @fov.y3 -= y 
          @fov.y4 -= y
        end
      end 

      # Position
      # Update global position value for player (used in other classes)
      @x = @dot.x 
      @y = @dot.y
    end

    private 

    # Radians 
    # Functionality to update SINGLE set of points (p1[:x],p1[:y]) against static point (p2[:x],p2[:y])
    def update_radians p1, p2, angle_velocity = @angle_velocity
      radians  = angle_velocity * (Math::PI / 180)
      response = {}

      x2 = p1[:x] - p2[:x]
      y2 = p1[:y] - p2[:y]
      cos = Math.cos(radians)
      sin = Math.sin(radians)
      
      response[:x] = ((x2 * cos) - (y2 * sin)) + p2[:x]
      response[:y] = ((x2 * sin) + (y2 * cos)) + p2[:y]

      return response
    end
    
  end
end