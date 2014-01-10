require 'debugger'

class HumanPlayer
  attr_reader :name

  def initialize(name)
    @name = name
  end

  def move_input
    # debugger
    positions = []

    puts "#{@name}, what piece would you like to move?"
    puts "Example: #{random_example_generator}"
    user_input = gets.chomp.split

    positions << format_move(user_input)

    puts "Where would you like to move?"
    user_input = gets.chomp.split(",")
    positions << format_move(user_input)
  end
  
  def random_example_generator
    horizontal_directional = ("A".."H").to_a
    [horizontal_directional[rand(8)], rand(8) + 1].join
  end

  private
  def format_move(user_input)
    moves = []
    horizontal_directional = ("A".."H").to_a

    user_input.each do |move|
      moves << [(8 - move[1].to_i), horizontal_directional.index(move[0].upcase)]
    end

    if moves.length == 1
      moves.flatten
    else
      moves
    end
  end
end