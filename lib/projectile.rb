## Projectile ##
## Projectiles fired by the user (takes angle as argument) ##

module Game # Game::Projectile

  class Projectile < Circle

    # Attributes
    attr_accessor :angle, :state, :velocity, :x, :y, :radius, :color

    def initialize(angle, x = 0, y = 0)
      super(z: 10)

      # Required for MRuby
      self.color  = Color.new('white')
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

      old_x = self.x
      old_y = self.y

      self.x += x
      self.y -= y

      # Out of bounds
      set_state(false) if self.x < 0 || self.x > BOUNDING_X || self.y < 0 || self.y > BOUNDING_Y

      # Walls
      set_state(false) if map.contains? [old_x, old_y], [(old_x + x), (old_y - y)]
    end

    # Status
    def set_state toggle = true
      @state = toggle
      self.remove if toggle == false
    end

  end

end