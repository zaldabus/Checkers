# -*- coding: utf-8 -*-

class Piece
  #remember to create a valid_pos?(pos) and empty(pos)
  #method in Board class

  def initialize(board, pos, color)
    @board, @pos, @color = board, pos, color
    @king = false
  end

  def to_s
    @color
  end

  def render
    symbols[[color, type]]
  end

  def symbols
    {
    [:white, :man] => ⚆,
    [:white, :king] => ⚇,
    [:red, :man] => ⚈,
    [:red, :king] => ⚉
    }
  end

  def king_me
    i, j = pos
    opposite_row = (self.color == :white ? 7 : 0)
    @king = true if j == opposite_row
  end

  def kinged?
    @king
  end

  def moves
    diagonal_steps + diagonal_attacks
  end

  def forward_dir
    (color == :red) ? -1 : 1
  end

  def diagonal_steps
    steps = []

    i, j = pos
    possible_steps = [
      [i + forward_dir, j + forward_dir],
      [i + forward_dir, j - forward_dir]
    ]

    possible_steps.each do |step|
      if board.valid_pos?(step) && board.empty?(step)
          steps << step
      end
    end

    kinged? ? steps << kings_diagonal_steps : steps
  end

  def kings_diagonal_steps
    backward_steps = []

    backward_possible_steps = [
      [i - forward_dir, j + forward_dir],
      [i - forward_dir, j - forward_dir]
    ]

    backward_possible_steps.each do |step|
      if board.valid_pos?(step) && board.empty?(step)
          backward_steps << step
      end
    end

    backward_steps
  end

  def diagonal_attacks
    attacks = []

    i, j = pos

    forward_attacks = [
      [i + (2 * forward_dir), j + (2 * forward_dir)],
      [i + (2 * forward_dir), j - (2 * forward_dir)]
    ]

    blocked_spaces = [
      [i + forward_dir, j + forward_dir],
      [i + forward_dir, j - forward_dir]
    ]

    forward_attacks.each_index do |location|
      next unless board.valid_pos?(forward_attacks[location])

      threatened_piece = board[blocked_spaces[location]]
      if threatened_piece && threatened_piece.color != self.color
        attacks << forward_attacks[location]
      end
    end

    kinged? ? attacks << kings_attacks : attacks
  end

  def kings_attacks
    kings_attacks = []

    i, j = pos

    backward_attacks = [
      [i - (2 * forward_dir), j + (2 * forward_dir)],
      [i - (2 * forward_dir), j - (2 * forward_dir)]
    ]

    blocked_spaces = [
      [i - forward_dir, j + forward_dir],
      [i - forward_dir, j - forward_dir]
    ]

    backward_attacks.each_index do |location|
      next unless board.valid_pos?(backward_attacks[location])

      threatened_piece = board[blocked_spaces[location]]
      if threatened_piece && threatened_piece.color != self.color
        kings_attacks << backward_attacks[location]
      end
    end
    kings_attacks
  end


end