require_relative 'State'

class AFN
  attr_accessor :states, :starting_states, :final_states, :transition_function

  def initialize(states, starting_states, final_states, transition_function)
    @states = states
    @starting_states = starting_states
    @final_states = final_states
    @transition_function = transition_function
  end

  def set_symbols(symbols)
    @@symbols = symbols
  end

  def no_initial
    @states.each do |item|
      item.is_initial = false
    end
  end

  def no_final
    @states.each do |item|
      item.is_final = false
    end
  end

  # #{@transition_function[state[0].to_s, state[1]]}
  def to_s
    @states.product(@@symbols).map do |state|
      "#{state[0]}, #{state[1]} => #{@transition_function[[state[0].id, state[1].to_s]]}"
    end
  end
end
