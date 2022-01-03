## Map ##
## Allows us to create a map which the player can traverse ##

class Map

  # Attributes
  attr_accessor :walls, :door
    
  def initialize

    # Objects
    # Array of vector co-ordinates which allow us to create a series of walls
    @walls = []
    @doors = []

    # Initial Walls 
    # This is just a test to see if we can do collision code
    @walls.push Line.new(
      x1: 125, y1: 100,
      x2: 125, y2: 400,
      width: 2,
      color: 'yellow',
      z: 20
    )

    # 1
    @walls.push Line.new(
      x1: 125, y1: 100,
      x2: 350, y2: 400,
      width: 2,
      color: 'yellow',
      z: 20
    )

    #2 
    @walls.push Line.new(
      x1: 125, y1: 400,
      x2: 150, y2: 400,
      width: 2,
      color: 'yellow',
      z: 20
    )

    #3 
    @walls.push Line.new(
      x1: 350, y1: 400,
      x2: 200, y2: 400,
      width: 2,
      color: 'yellow',
      z: 20
    )

    # Door 
    @doors.push Line.new(
      x1: 150, y1: 400,
      x2: 200, y2: 400,
      width: 2,
      color: 'lime',
      z: 19
    )

  end

  # Collision
  # https://stackoverflow.com/a/565282/1143732
  def contains? c1, c2 # c1 = co-ords1 (array of [x,y]), c2 = co-ords2 (array of [x,y])

    # Player line
    # This is a line from where the player is and where they want to go
    line = Line.new(
      x1: c1[0], y1: c1[1],
      x2: c2[0], y2: c2[1],
      opacity: 0
    )
    
    # Walls 
    # Cycle through the various walls to check if any collisions will occur
    @walls.each do |wall| 

      # Intersect
      return true if intersects? line, wall 

    end

    return false
  end

  private 

  # Direction
  # Determine the direction of the vectors
  # https://www.tutorialspoint.com/Check-if-two-line-segments-intersect
  def direction a, b, c
    val = (b[:y] - a[:y]) * (c[:x] - b[:x]) - (b[:x] - a[:x]) * (c[:y] - b[:y])
    response = 1 # clockwise 
     
    if val == 0
      response = 0 # colinear
    elsif val < 0
      response = 2 # anti-clockwise 
    end
    
    return response 
  end

  # onLine ([x,y], { x: [x1, y1], y: [x2,y2] })
  # Determines if the points intersect
  def onLine(l1, p)
    if(p[:x] <= max(l1.x1, l1.x2) && p[:x] <= min(l1.x1, l1.x2) && (p[:y] <= max(l1.y1, l1.y2) && p[:y] <= min(l1.y1, l1.y2)))
      return true 
    else 
      return false
    end
   end 

  # Intersection 
  # Allows us to identify whether the lines are going to intersect (and hopefully then show the points afterwards)
  # https://www.tutorialspoint.com/Check-if-two-line-segments-intersect
  def intersects? l1, l2 #each l is a struct which contains 4 co-ordinates (x1, y1, x2, y2)
    
    # Directions 
    dir1 = direction({ x: l1.x1, y: l1.y1 }, { x: l1.x2, y: l1.y2 }, { x: l2.x1, y: l2.y1 })
    dir2 = direction({ x: l1.x1, y: l1.y1 }, { x: l1.x2, y: l1.y2 }, { x: l2.x2, y: l2.y2 })
    dir3 = direction({ x: l2.x1, y: l2.y1 }, { x: l2.x2, y: l2.y2 }, { x: l1.x1, y: l1.y1 })
    dir4 = direction({ x: l2.x1, y: l2.y1 }, { x: l2.x2, y: l2.y2 }, { x: l1.x2, y: l1.y2 })

    return true if(dir1 != dir2 && dir3 != dir4) # Intersecting

    return true if(dir1==0 && onLine(l1, { x: l2.x1, y: l2.y1 } )) #when p2 of line2 are on the line1

    return true if(dir2==0 && onLine(l1, { x: l2.x2, y: l2.x2 } )) #when p1 of line2 are on the line1
      
    return true if(dir3==0 && onLine(l2, { x: l1.x1, y: l1.y1 } )) #when p2 of line1 are on the line2

    return true if(dir4==0 && onLine(l2, { x: l1.x2, y: l1.x2 } )) #when p1 of line1 are on the line2

  end
    
end