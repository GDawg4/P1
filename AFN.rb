require_relative 'State'

class AFN
  attr_accessor :states, :starting_states, :final_states, :transition_function

  def initialize(states, starting_states, final_states, transition_function)
    @states = states
    @starting_states = starting_states
    @final_states = final_states
    @transition_function = transition_function
  end
  
  def simulate(message)
    old_states = []
    new_states = []
    already_on = []

  end

  def eclosure(states)
    stack = []
    states.each do |state|
      stack << state
    end
    closure = states
    while stack.any?
      t = stack.pop
      new_states = @transition_function[[t, 'e']]
      unless new_states.nil? 
        @transition_function[[t, 'e']].each do |edge|
          unless stack.include?(edge)
            closure << edge
            stack << edge
          end
        end
      end
    end
    closure
  end

  def move(states, symbol)
    resulting_states = []
    states.each do |state|
      new_states = @transition_function[[state, symbol]]
      unless new_states.nil?
        resulting_states = resulting_states + new_states
      end
    end
    resulting_states.uniq
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
