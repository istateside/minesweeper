require 'yaml'
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
    @neighbors = []
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
    return 'F' if @is_flagged
    if @revealed
      return 'B' if @is_bomb
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
      return
    elsif @neighbor_bomb_count == 0
      unrevealed_neighbors = @neighbors.reject do |neighbor|
        neighbor.revealed
      end
      unrevealed_neighbors.each { |neighbor| neighbor.reveal_tile }
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
    @rows.flatten.sample(10).each { |tile| tile.is_bomb = true }
  end

  def get_all_neighbor_bomb_counts
    @rows.flatten.each { |tile| tile.get_neighbor_bomb_count }
    nil
  end

  def blank_grid
    grid = Array.new(SIZE) { Array.new(SIZE) }

    # grid = Array.new(SIZE) do |row_index|
#       Array.new(SIZE) { |col_index| Tile.new }
#     end

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
      row.each { |tile| line << tile.print_tile }
      puts line.join (' ')
    end
    nil
  end

  def flag_spot(pos)
    if self[pos].nil? || self[pos].is_flagged
      return false
    else
      self[pos].flag_tile
    end
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

  def reveal_all_bombs
    @rows.each do |row|
      row.each do |tile|
        if tile.is_bomb
          tile.revealed = true
          tile.is_flagged = false
        end
      end
    end
  end

  def loss?
    @rows.each do |row|
      #row.any? { |tile| tile.is_bomb && tile.revealed }
      row.each do |tile|
        if tile.is_bomb && tile.revealed
          return true
        end
      end
    end
    false
  end

  def won?
    @rows.all? do |row|
      row.all? { |tile| tile.is_bomb ? next : tile.revealed }
    end
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
    input = gets.chomp

    if input.downcase == 'save'
      save_game
      return
    else
      pos = input.split(',').map { |num| num.to_i }.reverse
    end

    # begin
#       pos = Integer(num)
#     rescue ArgumentError
#       puts "Please put in valid move!!"
#       retry
#     end

    if @board[pos].nil? || @board[pos].revealed
      puts "Please enter valid coordinates."
      return
    end

    puts "Flag (f) or reveal (r)?"
    command = gets.chomp.downcase

    if !['f','r', 'flag', 'reveal'].include?(command)
      puts "Invalid move specified."
      return
    end

    if ['r', 'reveal'].include?(command)
      @board.reveal_spot(pos)
    else
      @board.flag_spot(pos)
    end
  end

  def play
    start_time = Time.now
    loop do
      @board.display

      get_player_choice

      break if @board.loss? || @board.won?
    end
    if @board.loss?
      @board.display
      puts "YOU LOSE."
      puts "Time elapsed: #{Time.now - start_time}"
    elsif @board.won?
      @board.display
      puts "You win!"
      puts "Time elapsed: #{Time.now - start_time}"
    end
  end

  def save_game
    File.open("minesweeper_save.yaml", "w") do |file|
      file.puts self.to_yaml
    end
  end

  def self.load_game
    loaded_game = YAML.load_file("minesweeper_save.yaml")
  end
end


if __FILE__ == $PROGRAM_NAME
  puts "Welcome to MINESWEEPER"
  puts "NEW game or LOAD existing game (N or L)?"
  user_input = gets.chomp.downcase
  if user_input == 'n'
    Game.new.play
  else
    Game.load_game.play
  end
end

