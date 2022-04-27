require_relative 'State'
require_relative 'AFN'
class TreeNode
  attr_accessor :name, :children, :value, :afn, :nullable, :firstpos, :followpos, :lastpos, :follow_pos, :name_dict

  @@state_id = 0
  @@name_dict = {}
  @@ref_dict = {}
  def initialize(value)
    @name = value
    @value = value
    @children = []
    @id = @@state_id
    @@state_id += 1
    @@node_count = 0
    @@follow_pos = {}
  end

  def get_dict
    @@name_dict
  end

  def get_refs
    @@ref_dict
  end

  def get_follow_pos
    @@follow_pos
  end

  def set_symbols(symbols)
    @@symbols = symbols
  end

  def add_child(node)
    @children << node
  end

  def print_children(space)
    if @children.any?
      puts " "*space+ "#{@name} \n"
      @children.reverse.each do |child|
        child.print_children(space + 2)
      end
    else
      puts " "*space + @name
    end
  end

  def print_nullable(space)
    if @children.any?
      puts " "*space + "#{values_s} \n"
      @children.reverse.each do |child|
        child.print_nullable(space + 2)
      end
    else
      puts " "*space + "#{values_s}"
    end
  end

  def print_followpos
    puts "#{@@follow_pos}"
  end

  def print_name_dict
    puts "#{@@name_dict}"
  end

  def set_afn_symbols(symbols)
    new_afn = AFN.new([], [], [], {})
    new_afn.set_symbols(symbols)
  end

  def create_state
    if @children.empty?
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
    elsif @name.to_s.eql?('%')
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
                     { [new_initial.id, 'ε'] => [afn_1.states[0].id, afn_2.states[0].id],
                       [afn_1.states[-1].id, 'ε'] => [new_final.id],
                       [afn_2.states[-1].id,
                        'ε'] => [new_final.id] }.merge(afn_1.transition_function).merge(afn_2.transition_function))
      @afn
    elsif @name.to_s.eql?(';')
      afn_1 = @children[0].create_state
      afn_2 = @children[1].create_state
      afn_2.no_initial
      afn_1.no_final
      @afn = AFN.new([*afn_1.states, *afn_2.states], [afn_1.states[0]], [afn_2.states[-1]],
                     { [afn_1.states[-1].id, 'ε'] => [afn_2.states[0].id] }.merge(afn_1.transition_function).merge(afn_2.transition_function))
      @afn
    elsif @name.to_s.eql?(':')
      new_initial = State.new(@@node_count, true, false)
      @@node_count += 1
      afn_1 = @children[0].create_state
      afn_1.no_initial
      afn_1.no_final
      new_final = State.new(@@node_count, false, true)
      @@node_count += 1
      @afn = AFN.new([new_initial, *afn_1.states, new_final], [new_initial], [new_final],
                     { [new_initial.id, 'ε'] => [afn_1.states[0].id, new_final.id],
                       [afn_1.states[-1].id,
                        'ε'] => [new_final.id, afn_1.states[0].id] }.merge(afn_1.transition_function))
      @afn
    elsif @name.to_s.eql?('@')
      new_initial = State.new(@@node_count, true, false)
      @@node_count += 1
      afn_1 = @children[0].create_state
      afn_1.no_initial
      afn_1.no_final
      new_final = State.new(@@node_count, false, true)
      @@node_count += 1
      @afn = AFN.new([new_initial, *afn_1.states, new_final], [new_initial], [new_final],
                     { [new_initial.id, 'ε'] => [afn_1.states[0].id],
                       [afn_1.states[-1].id,
                        'ε'] => [new_final.id, afn_1.states[0].id] }.merge(afn_1.transition_function))
      @afn    
    elsif @name.to_s.eql?('?')
      new_initial = State.new(@@node_count, true, false)
      @@node_count += 1
      afn_1 = @children[0].create_state
      afn_1.no_initial
      afn_1.no_final
      new_final = State.new(@@node_count, false, true)
      @@node_count += 1
      @afn = AFN.new([new_initial, *afn_1.states, new_final], [new_initial], [new_final],
                     { [new_initial.id, 'ε'] => [afn_1.states[0].id, new_final.id],
                       [afn_1.states[-1].id, 'ε'] => [new_final.id]}.merge(afn_1.transition_function))
      @afn
    else
      puts @name
    end
  end

  def process_values
    process_nullable
    process_firstpos
    process_lastpos
    process_followpos
    process_dict
    process_ref
  end

  def process_nullable
    if @children.empty?
      @nullable = (@value == 'ε')
      @nullable
    elsif @children.length == 1
      @nullable = @children[0].process_nullable
      @nullable
    else
      case @value.to_s
      when '%'
        @nullable = @children[0].process_nullable || @children[1].process_nullable
        @nullable
      when ';'
        child0 = @children[0].process_nullable
        child1 = @children[1].process_nullable
        @nullable = child0 && child1
        @nullable
      when ':'
        @children[0].process_nullable
        @nullable = true
        @nullable      
      when '@'
        @children[0].process_nullable
        @nullable = false
        @nullable
      when '<>'
        @children[0].process_nullable      
      when '?'
        @children[0].process_nullable
        @nullable = true
        @nullable
      else
        puts "No"
      end
    end
  end

  def process_firstpos
    if @children.empty?
      @firstpos = @value == 'ε' ? [] : [@id]
      @firstpos
    elsif @children.length == 1
      @firstpos = @children[0].process_firstpos
      @firstpos
    else
      @children.each(&:process_firstpos)
      case @value.to_s
      when '%'
        @firstpos = @children[0].firstpos + @children[1].firstpos
      when ';'
        @firstpos = @children[0].nullable ? @children[0].firstpos + @children[1].firstpos : @children[0].firstpos
      when ':', '@', '?'
        @firstpos = @children[0].firstpos
      when '<>'
        @firstpos = @children[0].firstpos
      else
        puts "No"
      end
    end
  end

  def process_lastpos
    if @children.empty?
      @lastpos = @value == 'ε' ? [] : [@id]
      @lastpos
    elsif @children.length == 1
      @lastpos = @children[0].process_lastpos
      @lastpos
    else
      @children.each(&:process_lastpos)
      case @value.to_s
      when '%'
        @lastpos = @children[0].lastpos + @children[1].lastpos
      when ';'
        @lastpos = @children[1].nullable ? @children[0].lastpos + @children[1].lastpos : @children[1].lastpos
      when ':', '@', '?'
        @lastpos = @children[0].lastpos
      when '<>'
        @lastpos = @children[0].lastpos
      else
        puts "No"
      end
    end
  end

  def process_followpos
    if @value.to_s == ';'
      @children[0].lastpos.each do |position|
        @@follow_pos[position] = (@@follow_pos[position] || []) + @children[1].firstpos
      end
    elsif (@value.to_s == ':' || @value.to_s == '@' || @value.to_s == '?') && @children.any?
      @children[0].lastpos.each do |position|
        @@follow_pos[position] = (@@follow_pos[position] || []) + @children[0].firstpos
      end
    end
    unless @children.empty?
      @children.each(&:process_followpos)
    end
  end

  def process_dict
    if @children.empty?
      @@name_dict[@id] = @value
    else
      @children.each(&:process_dict)
    end
  end

  def process_ref
    @@ref_dict[@id] = self
    if children.any?
      children.each(&:process_ref)
    end
  end

  def children_s
    "#{@value} #{@children.map(&:children_s)}"
  end

  def values_s
    "#{@value} #{@id} #{@nullable.to_s} #{@firstpos} #{@lastpos}"
  end

  def to_s
    @value
  end
end
