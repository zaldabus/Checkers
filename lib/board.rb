require_relative 'piece'
require 'debugger'

class Board
  def self.generate_board
    Array.new(8) { Array.new(8) }
  end

  def initialize(board = self.class.generate_board)
    # debugger
    @board = board
    populate_board
  end

  def [](pos)
    x, y = pos
    @board[x][y]
  end

  def []=(pos, piece)
    x, y = pos
    @board[x][y] = piece
  end

  def populate_board
    (0..7).each do |row|
      (0..7).each do |col|
        case row
        when 0, 2
          self[[row, col]] = Piece.new(self, [row, col], :white) if col.odd?
        when 1
          self[[row, col]] = Piece.new(self, [row, col], :white) if col.even?
        when 5, 7
          self[[row, col]] = Piece.new(self, [row, col], :red) if col.even?
        when 6
          self[[row, col]] = Piece.new(self, [row, col], :red) if col.odd?
        end
      end
    end
  end

  def render
    @board.each {|row| p row}
  end

  def perform_jump

  end
end