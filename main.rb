# Libraries
require 'ruby2d'

#######################################
#######################################

## IMPORTANT ##

## Requires SDL2_TTF 2.0.15-1 to be installed
## You can download from the repo here: http://repo.msys2.org/mingw/mingw64/

## 1. Save this locally: http://repo.msys2.org/mingw/mingw64/mingw-w64-x86_64-SDL2_ttf-2.0.15-1-any.pkg.tar.xz
## 2. Load up MSYS2 and uninstall any version of SDL2_TTF that's later than 2.0.15
## 3. Type pacman -U c:/users/richard/downloads/mingw-w64-x86_64-SDL2_ttf-2.0.15-1-any.pkg.tar.xz to install the local file
## 4. It should load and all should be well

#######################################
#######################################

# Objects
if RUBY_ENGINE != 'mruby'
    %w(player map projectile hud camera matrix).each do |file|
        require_relative "lib/#{file}"
    end
else
    require File.expand_path("../lib/player", __FILE__) 
    require File.expand_path("../lib/map", __FILE__) 
    require File.expand_path("../lib/projectile", __FILE__) 
    require File.expand_path("../lib/hud", __FILE__) 
    require File.expand_path("../lib/camera", __FILE__)
    require File.expand_path("../lib/matrix", __FILE__)
end

# Constants
# Static values 
VELOCITY = 10
ANGLE    = 5
WIDTH    = 1000
HEIGHT   = 550

# Window
# Set title, dimensions etc
set title: "Perspective Test", background: 'black', width: WIDTH, height: HEIGHT

# Background
# This is used to give us a black background to hide the overflow from the camera. Yes, it's a hack but wanted to get it done quickly
Rectangle.new(
    x: 0, y: 0,
    width: WIDTH/2, height: HEIGHT,
    color: 'black',
    z: 5
)

# Objects 
# Loaded at start so they provide the engine with the means to calculate the entire experience
@player      = Game::Player.new      # player animation in the center of the screen
@map         = Game::Map.new         # Map interface (creates walls/vertices which can then be traversed with the game code below)
@projectiles = []                    # Projectiles array (used to define which projectiles the user has fired)
@hud         = Game::HUD.new @projectiles, @player # Display information and options to the user

# Camera
# Instantiate the camera 
@camera = Game::Camera.new @player, @map, @projectiles

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
            @projectiles.push Game::Projectile.new(@player.angle, @player.x, @player.y)
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
    @hud.update projectiles: @projectiles, player: @player

    # Player
    @player.update_angle if @player.angle_velocity != 0
    @player.update_velocity @map if @player.velocity != 0

    # Projectiles
    @projectiles.each { |projectile| projectile.move(VELOCITY, @map) unless !projectile.state } if @projectiles.any? 

    # Camera 
    @camera.update 
    
end

# Show Window
show