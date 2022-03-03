require_relative 'State'

class AFD
  def initialize(states, symbols, final_states, starting_state, transition_function)
    @states = states
    @symbols = symbols
    @final_states = final_states
    @starting_state = starting_state
    @transition_function = transition_function
  end

  def to_s
    'Buenas'
  end
end
