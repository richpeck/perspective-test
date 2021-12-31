## HUD ##
## Shows various pieces of data ##

class HUD

  # Attrs 
  attr_accessor :projectiles
    
  # Init
  def initialize projectiles = nil
    @projectiles = projectiles || []
    @message = Text.new("Projectiles: #{@projectiles.size}", x: 20, y: 20)
  end

  # Update
  def update projectiles: []
    @projectiles = projectiles
    #@message.text = "Projectiles: #{@projectiles.filter { |p| p.state == true }.size} (#{@projectiles.size})"
  end
    
end