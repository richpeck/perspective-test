## HUD ##
## Shows various pieces of data ##

module Game # Game::HUD

  class HUD

    # Constants 
    Z = 100 # stay on top

    # Attrs 
    attr_reader :projectiles, :player
      
    # Init
    def initialize projectiles = nil, player = nil
      @projectiles = projectiles || []
      @player      = player

      @projectiles_message = Text.new("Projectiles: #{@projectiles.size}", x: 20, y: 20, z: Z)
      @angle_message       = Text.new("Angle: #{@player.angle}", x: 20, y: 45, z: Z)
      @x_message           = Text.new("X: #{@player.x}", x: 20, y: 70, z: Z)
      @y_message           = Text.new("Y: #{@player.y}", x: 20, y: 95, z: Z)
    end

    # Update
    def update projectiles: [], player: nil
      @projectiles = projectiles

      @projectiles_message.text = "Projectiles: #{@projectiles.filter { |p| p.state == true }.size} (#{@projectiles.size})"
      @angle_message.text = "Angle: #{@player.angle.to_s}"
      @x_message.text = "X: #{@player.x.to_s}"
      @y_message.text = "Y: #{@player.y.to_s}"
    end
      
  end

end