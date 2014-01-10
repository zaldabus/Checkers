# -*- coding: utf-8 -*-

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

  ## REVIEW: using an array as a hash key, which works, but I'm not sure
  ## how clear or stylistically good that is. But if you do it this  I think
  ## you'll have to change the keys here to [:white, true], [:white, false], etc
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

  ## REVIEW: This seems unnecessary, the @king variable is already a boolean so
  ## whereever you call kinged? you could have just called @king
  def kinged?
    @king
  end

  def perform_moves!(*move_sequence)

=begin
  REVIEW:
    When you perform_slide or perform_jump in this method, the piece actually
    moves there (ie, it's position changes to end_pos, and the board updates
    to reflect this). Therefore instead of adding each end_pos to a
    reference_moves array, you could each through the entire move sequence, and
    your perform_slide or perform_jump methods will either execute without error
    if the whole move_sequence is correct, or raise an error at the first
    invalid move. Also I think this is why they originaly advise us to return true
    or false in the perform_slide and perform_jump methods, because it helps with the
    logic if you implement perform_moves! as described above
=end
    reference_moves = []

    until move_sequence.empty?
      if move_sequence.length == 2 && reference_moves.empty?
        moves = move_sequence.shift(2)
        ## REVIEW: Could just use: start_pos, end_pos = moves
        start_pos, end_pos = moves.first, moves.last
        begin
          perform_slide(start_pos, end_pos)
        rescue InvalidMoveError
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

  def valid_move_seq?(*move_sequence)
    begin
      test_board = board.dup
      perform_moves!(*move_sequence)
    rescue InvalidMoveError
      puts "Invalid Move Sequence!"
      return false
    end
    true
  end

  def perform_moves(*move_sequence)
    if valid_move_seq?(*move_sequence)
      perform_moves!(*move_sequence)
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

  ## REVIEW: I think you want this to return true or false rather than raise an
  ## error
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

  ## REVIEW: I think you want this to return true or false rather than raise error
  ## Right now it's returning the last line evaluated, which is either
  ## the piece.king_me? or an error
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