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

  def play
    loop do
      ## REVIEW: I think this @board.render + "\n" was throwing me an error
      ## becaause @board.render returns and array and you can't and a string to
      ## an array. Instead you could just do:
      # @board.render
      # puts

      @board.render + "\n"
      moves = @players[@turn].move_input
      @board[start_move].perform_moves(moves)
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