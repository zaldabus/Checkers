# -*- coding: utf-8 -*-
require 'debugger'
require_relative 'piece'

class Board

  def initialize(fill_board = true)
    generate_board(fill_board)
  end

  def generate_board(fill_board)
    @board = Array.new(8) { Array.new(8) }
    populate_board if fill_board
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
        #refactor this 30, 32, 34, 36 are all pretty similar
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
    @board.each { |row| p row }
  end

  def dup
    test_board = Board.new(false)

    pieces.each do |piece|
      piece.class.new(test_board, piece.pos, piece.color)
    end

    test_board
  end

  def pieces
    @board.flatten.compact
  end

end