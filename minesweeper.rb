class Tile

  attr_accessor :is_bomb, :neighbors, :revealed, :is_flagged, :neighbor_bomb_count

  def initalize(is_bomb= false)
    @is_bomb = is_bomb
    @neighbors = nil
    @revealed = false
    @is_flagged = false
    @neighbor_bomb_count = 0
  end

  def is_bomb?
    self.is_bomb
  end

  def neighbors
  end

  def print_tile
    # return a string depending on the state
    return 'F' if @is_flagged
    if @revealed
      @neighbor_bomb_count == 0 ? '_' : @neighbor_bomb_count
    else
      '*'
    end
  end

end

class Board

  attr_reader :rows

  def initialize(rows = self.class.blank_grid)
    @rows = rows
  end

  def self.blank_grid
    Array.new(9) { Array.new(9) { Tile.new } }
  end

  def [](pos)
    x, y = pos[0], pos[1]
    @rows[x][y]
  end

  def display
    @rows.each do |row|
      row.each do |tile|
        tile.print_tile + ' '
      end
      puts
    end
  end

end

