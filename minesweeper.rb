class Tile

  attr_accessor :is_bomb, :neighbors, :revealed

  def initalize(is_bomb= false)
    @is_bomb = is_bomb
    @neighbors = nil
    @revealed = false
  end

  def is_bomb?
    self.is_bomb
  end

  def neighbors
  end
end

class Board
  def initialize

  end

  def self.blank_grid
    Array.new(9) { Array.new(9, Tile.new) }
end

