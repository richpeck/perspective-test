## HUD ##
## Shows various pieces of data ##

class HUD

  # Attrs 
  attr_accessor :projectiles
    
  # Init
  def initialize projectiles = nil, angle = nil
    @projectiles = projectiles || []
    @projectiles_message = Text.new("Projectiles: #{@projectiles.size}", x: 20, y: 20)
    @angle_message       = Text.new("Angle: #{angle}", x: 20, y: 40)
  end

  # Update
  def update projectiles: [], angle: 0
    @projectiles = projectiles

    @projectiles_message.text = "Projectiles: #{@projectiles.filter { |p| p.state == true }.size} (#{@projectiles.size})"
    @angle_message.text = "Angle: #{angle.to_s}"
  end
    
end