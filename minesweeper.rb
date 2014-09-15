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

      if new_pos.all? { |coord| coord.between?(0,8) }
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
    if @revealed
      @neighbor_bomb_count == 0 ? '_' : @neighbor_bomb_count
    else
      '*'
    end
  end

  def flag_tile
    @is_flagged = true
  end

  def reveal_tile
    @revealed = true

    if @is_bomb
      reveal_all_bombs
      return
    elsif @neighbor_bomb_count == 0
      @neighbors.each { |neighbor| neighbor.reveal_tile }
    end
    nil
  end

end


class Board
  SIZE = 9

  attr_reader :rows

  def initialize
    @rows = nil
  end

  def prepare_board
    @rows = blank_grid
    place_bombs
    get_all_neighbor_bomb_counts
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

  def blank_grid
    grid = Array.new(SIZE) { Array.new(SIZE) }
    grid.each_with_index do |row, row_index|
      col_index = 0
      while col_index < row.length
        row[col_index] = Tile.new(self, row_index, col_index)
        col_index += 1
      end
    end
    return grid
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

  def reveal_spot(pos)
    if self[pos].nil? || self[pos].revealed
      return false
    else
      self[pos].reveal_tile
    end

    if self[pos].is_bomb
      reveal_all_bombs
    end

    true
  end

  def flag_spot(pos)
    if self[pos].nil? || self[pos].is_flagged
      return false
    else
      self[pos].flag_tile
    end
  end

  def loss?
    @rows.each do |row|
       row.any? { |tile| tile.is_bomb && tile.revealed }
    end
  end

  def won?
    @rows.all? do |row|
      row.all? do |tile|
        tile.is_bomb ? next : tile.revealed
      end
    end
  end

  def reveal_all_bombs
    # build out
  end

end

class Game
  def initialize
    @board = Board.new
    @board.prepare_board
  end

  def get_player_choice

    # puts "Enter a command (f for flag, r for reveal) and a position (x,y)"
    puts "Select a position. x,y"
    pos = gets.chomp.split(',')

    puts "Flag (f) or reveal (r)?"
    command = gets.chomp.downcase

    until ['f','r'].include?(command)
      if command == 'r'
        until @board.reveal_spot(pos)
          puts "Please enter valid coordinates."
          pos = gets.chomp.split(',')
        end
      elsif command == 'f'
        until @board.flag_spot(pos)
          puts "Please enter valid coordinates."
        end
      else
        puts "Please enter valid command."
        command = gets.chomp.downcase
      end
    end
  end

  def play
    loop do
      # until the game is won
      # check if player lost - check if any bomb is revealed
      @board.display

      get_player_choice

      # check if (a) all non-bombs revealed and (b) all bombs flagged
      if @board.loss?
        puts "YOU LOSE."
        break
      elsif @board.won?
        puts "You win!"
        break
      end

    end
  end
    #
  # def over?
  # end

end
