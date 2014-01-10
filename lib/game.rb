# -*- coding: utf-8 -*-
require_relative 'board'
require_relative 'humanplayer'

class Game
  attr_reader :board

  def initialize(player1, player2)
    @board = Board.new
    @players = {:red => player1, :white => player2}
    @turn = :red
  end

  def move(start_move, end_moves)
    begin

    rescue
  end

  def play
    loop do
      @board.render
      begin
        start_move, *end_moves = @players[@turn].move_input
      raise InvalidMoveError if @board.empty?(start_move)
        retry
      end
      @board[start_move].perform_moves(end_moves)
      break if winner?
      @turn = (@turn == :red ? :white : :red)
    end
    puts "#{@players[@turn].name} wins!"
  end

  def winner?
    no_pieces?(:red) || no_pieces?(:white)
  end

  def no_pieces?(color_type)
    board.pieces.none? { |piece| piece.color == color_type }
  end
end

class InvalidMoveError < StandardError
end