require_relative 'State'
require_relative 'AFN'
class TreeNode
  attr_accessor :name, :children, :value, :afn

  def initialize(value)
    @name = value
    @value = value
    @children = []
    @@node_count = 0
  end

  def set_symbols(symbols)
    @@symbols = symbols
  end

  def add_child(node)
    @children << node
  end

  def print_children
    if @children.any?
      "#{@value} \n #{@children.map(&:print_children)}"
    else
      @name.to_s
    end
  end

  def set_afn_symbols(symbols)
    new_afn = AFN.new([], [], [], {})
    new_afn.set_symbols(symbols)
  end

  def create_state
    puts "Checking #{@name} #{@children.length}"
    if @children.empty?
      puts "Symbol, probably"
      new_initial = State.new(@@node_count, true, false)
      @@node_count += 1
      new_final = State.new(@@node_count, false, true)
      @@node_count += 1
      @afn = AFN.new([new_initial, new_final], [new_initial], [new_final],
                     { [new_initial.id, @value] => [new_final.id] })
      # puts @afn.to_s
      @afn
    elsif @children.length == 1
      # puts "just one #{@children[0].create_state.to_s}"
      @children[0].create_state
    elsif @name.to_s.eql?('|')
      new_initial = State.new(@@node_count, true, false)
      @@node_count += 1
      afn_1 = @children[0].create_state
      afn_2 = @children[1].create_state
      afn_1.no_initial
      afn_2.no_initial
      afn_1.no_final
      afn_2.no_final
      new_final = State.new(@@node_count, false, true)
      @@node_count += 1
      @afn = AFN.new([new_initial, *afn_1.states, *afn_2.states, new_final], [new_initial], [new_final],
                     { [new_initial.id, 'e'] => [afn_1.states[0].id, afn_2.states[0].id],
                       [afn_1.states[-1].id, 'e'] => [new_final.id],
                       [afn_2.states[-1].id,
                        'e'] => new_final.id }.merge(afn_1.transition_function).merge(afn_2.transition_function))
      @afn
    elsif @name.to_s.eql?('.')
      afn_1 = @children[0].create_state
      afn_2 = @children[1].create_state
      afn_2.no_initial
      afn_1.no_final
      @afn = AFN.new([*afn_1.states, *afn_2.states], [afn_1.states[-1]], [afn_2.states[0]],
                     { [afn_1.states[-1].id, 'e'] => [afn_2.states[0].id] }.merge(afn_1.transition_function).merge(afn_2.transition_function))
      @afn
    elsif @name.to_s.eql?('*')
      new_initial = State.new(@@node_count, true, false)
      @@node_count += 1
      afn_1 = @children[0].create_state
      afn_1.no_initial
      afn_1.no_final
      new_final = State.new(@@node_count, false, true)
      @@node_count += 1
      @afn = AFN.new([new_initial, *afn_1.states, new_final], [new_initial], [new_final],
                     { [new_initial.id, 'e'] => [afn_1.states[0].id],
                       [afn_1.states[-1].id,
                        'e'] => [new_final.id, afn_1.states[0].id] }.merge(afn_1.transition_function))
      @afn
    else
      puts @name
    end
  end

  def to_s
    @value
  end
end
