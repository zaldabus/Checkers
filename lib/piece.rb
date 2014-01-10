# -*- coding: utf-8 -*-
require 'debugger'
class Piece

  attr_accessor :pos, :color, :board

  def initialize(board, pos, color)
    @board, @pos, @color = board, pos, color
    @king = false
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

  def perform_moves!(*move_sequence)
    debugger
    reference_moves = []

    until move_sequence.empty?
      if move_sequence.length == 2 && reference_moves.empty?
        start_pos, end_pos = move_sequence.first, move_sequence.last
        move_sequence = []
        begin
          perform_slide(start_pos, end_pos)
        rescue
          perform_jump(start_pos, end_pos)
        end

      elsif move_sequence.length > 1
        if reference_moves.empty?
          reference_moves = move_sequence.shift(2)
          start_pos, end_pos = reference_moves.first, reference_moves.last
          raise InvalidMoveError unless perform_jump(start_pos, end_pos)
          reference_moves << end_pos
        else
          start_pos, end_pos = reference_moves.shift, move_sequence.shift
          raise InvalidMoveError unless perform_jump(start_pos, end_pos)
          reference_moves << end_pos
        end

      elsif move_sequence.length == 1
        start_pos, end_pos = reference_moves.shift, move_sequence.shift
        raise InvalidMoveError unless perform_jump(start_pos, end_pos)
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

  def perform_jump(start_pos, end_pos)
    piece = board[start_pos]
    raise InvalidMoveError unless piece && piece.diagonal_attacks.include?(end_pos)
    board[end_pos] = piece
    piece.pos = end_pos

    board[start_pos] = nil
    board[move_diffs(start_pos, end_pos)] = nil

    piece.king_me if opposite_row?(end_pos)
  end

  def move_diffs(start_pos, end_pos)
    start_x, start_y = start_pos
    end_x, end_y = end_pos
    [(start_x + end_x)/2, (start_y + end_y)/2]
  end

  def perform_slide(start_pos, end_pos)
    piece = board[start_pos]
    raise InvalidMoveError unless piece && piece.diagonal_steps.include?(end_pos)
    board[end_pos] = piece
    piece.pos = end_pos

    board[start_pos] = nil

    piece.king_me if opposite_row?(end_pos)
  end

  def opposite_row?(pos)
    i, j = pos
    opposite_row = (board[pos].color == :white ? 7 : 0)
    i == opposite_row
  end

end

class InvalidMoveError < StandardError
end