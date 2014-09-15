class Tile

  NEIGHBOR_POS = [
    [-1, -1],
    [-1, 0],
    [-1, 1],
    [0, -1],
    [0, 1],
    [1, -1],
    [1, 0],
    [1, 1]
  ]

  attr_accessor :is_bomb, :neighbors, :revealed, :is_flagged, :neighbor_bomb_count
  attr_reader :board, :pos

  def initialize(board, x, y)
    @is_bomb = false
    @neighbors = nil
    @revealed = false
    @is_flagged = false
    @neighbor_bomb_count = 0
    @board = board
    @pos = [x, y]
  end

  def is_bomb?
    self.is_bomb
  end

  def get_neighbors
    @neighbors = []
    NEIGHBOR_POS.each do |(dx, dy)|
      new_pos = [@pos[0] + dx, @pos[1] + dy]

      if new_pos.all? { |coord| coord.between?(0,7) }
        neighbors << @board[new_pos]
      end
    end
    nil
  end

  def get_neighbor_bomb_count
    get_neighbors
    @neighbors.each do |neighbor|
      @neighbor_bomb_count += 1 if neighbor.is_bomb?
    end
  end

  def print_tile
    # return a string depending on the state
    return 'B' if @is_bomb
    return 'F' if @is_flagged
    # if @revealed
      @neighbor_bomb_count == 0 ? '_' : @neighbor_bomb_count
    # else
    #   '*'
    # end
  end

end

class Board
  SIZE = 9

  attr_reader :rows

  def initialize(rows = self.class.blank_grid)
    @rows = rows
    place_bombs
    get_all_neighbor_bomb_count
  end

  def place_bombs
    all_tiles = []
    @rows.each do |row|
      row.each do |tile|
        all_tiles << tile
      end
    end
    all_tiles.sample(10).each do |tile|
      tile.is_bomb = true
    end
  end

  def get_all_neighbor_bomb_counts
    @rows.each do |row|
      row.each do |tile|
        tile.get_neighbor_bomb_count
      end
    end
    nil
  end

  def self.blank_grid
    grid = Array.new(SIZE) { Array.new(SIZE) }
    grid.each_with_index do |row, row_index|
      row.each_with_index do |space, col_index|
        space = Tile.new(self, row_index, col_index)
      end
    end
    grid
  end

  def [](pos)
    x, y = pos[0], pos[1]
    @rows[x][y]
  end

  def display
    @rows.each do |row|
      line = []
      row.map do |tile|
        line << tile.print_tile
      end
      puts line.join (' ')
    end
    nil
  end

end

b = Board.new
b.display
