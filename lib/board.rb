require_relative 'piece'
require 'debugger'

class Board
  def self.generate_board
    Array.new(8) { Array.new(8) }
  end

  def initialize(board = self.class.generate_board)
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

  def valid_pos?(pos)
    pos.all? {|coord| coord.between?(0, 7) }
  end

  def empty?(pos)
    self[pos].nil?
  end

  def perform_jump(start_pos, end_pos)
    raise "Invalid Jump!" unless self[start_pos].diagonal_attacks.include?(end_pos)
    self[end_pos] = self[start_pos]
    self[end_pos].pos = end_pos
    self[start_pos] = nil
    self[move_diffs(start_pos, end_pos)] = nil
    self[end_pos].king_me if opposite_row?(end_pos)
  end

  def move_diffs(start_pos, end_pos)
    start_x, start_y = start_pos
    end_x, end_y = end_pos
    [(start_x + end_x)/2, (start_y + end_y)/2]
  end

  def perform_slide(start_pos, end_pos)
    # debugger
    raise "Invalid Slide!" unless self[start_pos].diagonal_steps.include?(end_pos)
    self[end_pos] = self[start_pos]
    self[end_pos].pos = end_pos
    self[start_pos] = nil
    self[end_pos].king_me if opposite_row?(end_pos)
  end

  def opposite_row?(pos)
    i, j = pos
    opposite_row = (self[pos].color == :white ? 7 : 0)
    i == opposite_row
  end
end