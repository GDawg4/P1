require_relative 'State'

class AFD
  attr_accessor :states, :starting_states, :final_states, :transition_function

  def initialize(states, starting_states, final_states, transition_function, return_tokens)
    @states = states
    @starting_states = starting_states
    @final_states = final_states
    @transition_function = transition_function
    @return_tokens = return_tokens
  end

  def set_symbols(symbols)
    @@symbols = symbols
  end

  def move(state, symbol)
    @transition_function[[state, symbol]]
  end

  def to_s
    @states.product(@@symbols).map do |state|
      "#{state[0]}, #{state[1]} => #{@transition_function[[state[0].id, state[1].to_s]]}"
    end
  end
end
