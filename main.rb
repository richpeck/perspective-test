# Libraries
require 'ruby2d'

# Objects
if RUBY_ENGINE != 'mruby'
    %w(player map projectile hud).each do |file|
        require_relative "lib/objects/#{file}"
    end
else
    require File.expand_path("../lib/objects/player", __FILE__) # require_relative not supported by mruby
    require File.expand_path("../lib/objects/map", __FILE__) # require_relative not supported by mruby
    require File.expand_path("../lib/objects/projectile", __FILE__) # require_relative not supported by mruby
end

# Window
# Set title, dimensions etc
set title: "Perspective Test", background: 'black', width: 850, height: 550

# Objects 
# Loaded at start so they provide the engine with the means to calculate the entire experience
@player      = Player.new # player animation in the center of the screen
@map         = Map.new    # Map interface (creates walls/vertices which can then be traversed with the game code below)
@hud         = HUD.new    # Display information and options to the user
@projectiles = []         # Projectiles array (used to define which projectiles the user has fired)

# Constants
# Static values 
VELOCITY = 10
ANGLE    = 5

# Inputs 
# Take the user's inputted keystrokes and updates worldview
on :key_held do |event|
    case event.key 
        when "left"
            @player.angle_velocity = -(ANGLE)
        when "right"
            @player.angle_velocity = ANGLE
        when 'up'
            @player.velocity = VELOCITY
        when 'down'
            @player.velocity = -(VELOCITY)
    end
end

# Keys 
# Single button clicks (no need to hold as above)
on :key_down do |event|
    case event.key 
        when "space"
            @projectiles.push Projectile.new(@player.angle, @player.x, @player.y)
    end
end

# Stop 
# When key input ceases, stop updating the x,y of the user 
on :key_up do |event|
    case event.key 
        when 'left', 'right'
            @player.angle_velocity = 0
        when 'up', 'down'
            @player.velocity = 0
    end
end

# Game Loop
# This is the game loop which runs infinitely
update do 

    # HUD
    @hud.update projectiles: @projectiles

    # Player
    @player.update_angle if @player.angle_velocity != 0
    @player.update_velocity if @player.velocity != 0

    # Projectiles
    @projectiles.each { |projectile| projectile.move(VELOCITY) unless !projectile.state } if @projectiles.any? 
    
end

# Show Window
show