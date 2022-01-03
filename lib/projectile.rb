## Projectile ##
## Projectiles fired by the user (takes angle as argument) ##

class Projectile < Circle

    # Attributes
    attr_accessor :angle, :state, :velocity
      
    def initialize(angle, x = 0, y = 0)
        super(
            color: 'white',
            z: 10
        )

        # Required for MRuby
        self.radius = 2
        self.x = x
        self.y = y

        # Vars
        @state = true # true/false
        @angle = angle # passed from constructor
        @velocity = 0 # speed/movement

    end

    # Move 
    def move velocity, map
        @velocity = velocity 

        radians = @angle * (Math::PI / 180)

        x = Math.sin(radians) * @velocity
        y = Math.cos(radians) * @velocity

        self.x += x
        self.y -= y

        # Out of bounds
        set_state(false) if self.x < 0 || self.x > Window.width || self.y < 0 || self.y > Window.height

        # Walls 
        set_state(false) if map.contains?(self.x, self.y)
    end

    # Status
    def set_state toggle = true
        @state = toggle
        self.remove if toggle == false
    end
      
  end