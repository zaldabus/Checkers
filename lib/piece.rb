# -*- coding: utf-8 -*-
require 'debugger'
class Piece

  attr_accessor :pos, :color, :board

  def initialize(board, pos, color, king = false)
    @board, @pos, @color = board, pos, color
    @king = king
  end

  def to_s
    symbols[[color, kinged?]]
  end

  def render
    symbols[[color, kinged?]]
  end

  def symbols
    {
    [:white, kinged?] => "⚆",
    [:white, kinged?] => "⚇",
    [:red, kinged?] => "⚈",
    [:red, kinged?] => "⚉"
    }
  end

  def king_me
    @king = true
  end

  def kinged?
    @king
  end

  def perform_moves!(move_sequence)
    if move_sequence.length == 1
      pos = move_sequence.first
      unless perform_slide(pos) || perform_jump(pos)
        raise InvalidMoveError
      end
    else
      move_sequence.each do |move|
        raise InvalidMoveError unless perform_jump(move)
      end
    end
  end

  def valid_move_seq?(move_sequence)
    begin
      test_board = board.dup
      test_board[pos].perform_moves!(move_sequence)
    rescue InvalidMoveError
      false
    end
    true
  end

  def perform_moves(move_sequence)
    if valid_move_seq?(move_sequence)
      perform_moves!(move_sequence)
    else
      raise InvalidMoveError
    end
  end

  def forward_dir
    (self.color == :red) ? -1 : 1
  end

  def diagonal_steps
    i, j = pos
    possible_steps = [
      [i + forward_dir, j + forward_dir],
      [i + forward_dir, j - forward_dir]
    ]

    possible_steps.concat([
        [i - forward_dir, j + forward_dir],
        [i - forward_dir, j - forward_dir]
      ]) if kinged?

    add_diagonal_steps(possible_steps)
  end

  def add_diagonal_steps(possible_steps)
    steps = []

    possible_steps.each do |step|
      if valid_pos?(step) && empty?(step)
          steps << step
      end
    end

    steps || nil
  end

  def diagonal_attacks
    i, j = pos
    forward_attacks = [
      [i + (2 * forward_dir), j + (2 * forward_dir)],
      [i + (2 * forward_dir), j - (2 * forward_dir)]
    ]

    forward_attacks.concat([
      [i - (2 * forward_dir), j + (2 * forward_dir)],
      [i - (2 * forward_dir), j - (2 * forward_dir)]
      ]) if kinged?

    blocked_spaces = [
      [i + forward_dir, j + forward_dir],
      [i + forward_dir, j - forward_dir]
    ]

    blocked_spaces.concat([
      [i - forward_dir, j + forward_dir],
      [i - forward_dir, j - forward_dir]
      ]) if kinged?

    add_diagonal_attacks(forward_attacks, blocked_spaces)
  end

  def add_diagonal_attacks(forward_attacks, blocked_spaces)
    attacks = []

    forward_attacks.each_index do |location|
      next unless valid_pos?(forward_attacks[location])

      threatened_piece = board[blocked_spaces[location]]
      if threatened_piece && threatened_piece.color != self.color
        attacks << forward_attacks[location]
      end
    end

    attacks || nil
  end

  def valid_pos?(pos)
    pos.all? { |coord| coord.between?(0, 7) }
  end

  def empty?(pos)
    board[pos].nil?
  end

  def perform_jump(end_pos)
    return false unless self.diagonal_attacks.include?(end_pos)

    board[pos] = nil
    self.pos = end_pos
    board[end_pos] = self
    board[move_diffs(self, end_pos)] = nil

    piece.king_me if opposite_row?(end_pos)

    true
  end

  def move_diffs(start_pos, end_pos)
    start_x, start_y = start_pos
    end_x, end_y = end_pos
    [(start_x + end_x)/2, (start_y + end_y)/2]
  end

  def perform_slide(end_pos)
    return false unless self.diagonal_steps.include?(end_pos)

    board[pos] = nil
    self.pos = end_pos
    board[end_pos] = self

    self.king_me if opposite_row?(end_pos)

    true
  end

  def opposite_row?(pos)
    i, j = pos
    opposite_row = (board[pos].color == :white ? 7 : 0)
    i == opposite_row
  end

  def dup(test_board)
    Piece.new(test_board, pos, color, kinged?)
  end

end

class InvalidMoveError < StandardError
end