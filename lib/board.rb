# -*- coding: utf-8 -*-
require 'debugger'
require_relative 'piece'

class Board

  def initialize(fill_board = true)
    @board = Array.new(8) { Array.new(8) }
    fill_spaces if fill_board
  end

  def [](pos)
    x, y = pos
    @board[x][y]
  end

  def []=(pos, piece)
    x, y = pos
    @board[x][y] = piece
  end

  def fill_spaces
     (0...3).each { |row| fill_row(row, :white) }
     (5...8).each { |row| fill_row(row, :red) }
  end

  def fill_row(row, color)
    8.times do |col|
      self[[row, col]] = Piece.new(self, [row, col], color) if ((row % 2) == (col % 2))
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