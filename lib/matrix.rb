## Matrix ##
## Various functions/methods used to help us work with matrices ##

class Matrix 

  ## Multiply Matrix ##
  ## Accepts m1, m2 and multiplies them together ##
  def self.multiply m1, m2 ## m1 is the "result" context (number of columns) and m2 is the "matrix" (number of rows)
    result = Array.new( m1.length ) { Array.new( m2[0].length ) {0} }

    for i in 0..result.length - 1
        for j in 0..result[0].length - 1
            for k in 0..m1[0].length - 1
                result[i][j] += m1[i][k] * m2[k][j]
            end
        end
    end

    return result
  end

  ## Rotation Matrix
  ## Method to return the rotation matrix (means we don't have to keep defining it each time)
  def self.rotation radians
    [
      [Math.cos(radians), -(Math.sin(radians))],
      [Math.sin(radians), Math.cos(radians)]
    ]
  end

end