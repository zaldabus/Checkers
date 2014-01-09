class HumanPlayer
  attr_reader :name

  def initialize(name)
    @name = name
  end

  def move_input
    puts "#{@name}, what move would you like to make?"
    puts "Example: A3, B4"
    user_input = gets.chomp
    format_move(user_input)
  end

  private
  def format_move(user_input)
    horizontal_directional = ("A".."H").to_a

    start_move, end_move = players_input.split(", ")

    start_move = [(8 - start_move[1].to_i), horizontal_directional.index(start_move[0].upcase)]
    end_move = [(8 - end_move[1].to_i), horizontal_directional.index(end_move[0].upcase)]

    [start_move, end_move]
  end
end