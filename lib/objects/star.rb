## Star ##
## Used for background animation ##

class Star < Circle
    
  def initialize
      @y_velocity = random_int(-3, 0.1)
      super(
          x: rand(Window.width),
          y: rand(Window.height),
          radius: random_int(0.1, 0.5),
          color: 'random',
          z: -2,
          opacity: random_int(0.2, 0.8)
      )
  end

  def move
      self.y = (self.y + @y_velocity) % Window.height
  end
    
end