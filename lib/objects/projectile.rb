## Projectile ##
## Projectiles fired by the user (takes angle as argument) ##

class Projectile < Circle

    # Attributes
    attr_accessor :angle, :state, :velocity
      
    def initialize(angle, x = 0, y = 0)
        super(
            x: x, y: y,
            radius: 2,
            sectors: 32,
            color: 'white',
            z: 10
        )

        # Vars
        @state = true # true/false
        @angle = angle # passed from constructor
        @velocity = 0 # speed/movement

    end

    # Move 
    def move(velocity)
        @velocity = velocity 

        radians = @angle * (Math::PI / 180)

        x = Math.sin(radians) * @velocity
        y = Math.cos(radians) * @velocity

        self.x += x
        self.y -= y
    end
      
  end