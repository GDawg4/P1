require_relative 'Symbol'
require_relative 'Operator'
require_relative 'ExTree'
require_relative 'TreeNode'
require_relative 'AFD'
require_relative 'State'

class RegularExpression
  def initialize(string_representation)
    @string_representation = string_representation
    @operators = [Operator.new('*', 2), Operator.new('+', 2), Operator.new('?', 2), Operator.new('|', 0), Operator.new('.', 1)]
    @symbols = ((string_representation.split('').uniq - ['(', ')']) - @operators.map(&:to_s)).map do |symbol|
      SymbolNew.new(symbol)
    end
    @tree_representation = nil
  end

  def graph_afn
    @graph_afn
  end

  def graph_subset
    @graph_subset
  end

  def graph_direct
    @graph_direct
  end

  def symbol?(value)
    @symbols.map(&:to_s).include?(value)
  end

  def operator?(value)
    @operators.map(&:to_s).include? value
  end

  def get_precedence(operator)
    case operator
    when '*', '+', '?'
      2
    when '.', '#'
      2
    when '|'
      1
    else
      0
    end
  end

  def create_node_two(name, left_child, right_child)
    new_root = TreeNode.new(name)
    new_root.add_child(left_child)
    new_root.add_child(right_child)
    new_root
  end

  def unary?(symbol)
    ['*', '+', '?'].include?(symbol)
  end

  def create_graph(transition_function)
    states_list = []
    edge_labels = {}
    # puts "#{transition_function.keys}"
    # puts "#{transition_function.values}"
    transition_function.keys.each_with_index do |transition, i|
      starting_state = transition[0]
      symbol = transition[1]
      end_states = transition_function.values[i]
      if end_states.is_a? Array
        end_states.each do |edge|
          states_list << starting_state
          states_list << edge
          edge_labels["#{starting_state}-#{edge}"] = symbol
        end
      else
        states_list << starting_state
        states_list << end_states
        edge_labels["#{starting_state}-#{end_states}"] = symbol
      end
    end
    [states_list, edge_labels]
  end

  def create_tree(regex_representation)
    values = []
    operators = []
    i = 0
    while i < regex_representation.length
      if symbol? regex_representation[i]
        # puts regex_representation[i]
        new_node = TreeNode.new(regex_representation[i])
        values.push(new_node)
        if symbol?(regex_representation[i + 1]) || (i.positive? && unary?(regex_representation[i - 1]))
          operators.push(TreeNode.new('.'))
        end
        i += 1
      elsif regex_representation[i] == '('
        new_node = TreeNode.new(regex_representation[i])
        operators.push(new_node)
        i += 1
      elsif regex_representation[i] == ')'
        while operators.last.to_s != '('
          op = operators.pop
          case op.to_s
          when '*', '+', '?'
            new_value = values.pop
            values.push(create_node_two(op.to_s, new_value, op))
          when '|'
            first_value = values.pop
            second_value = values.pop
            values.push(create_node_two(op.to_s, second_value, first_value))
          when '.'
            first_value = values.pop
            second_value = values.pop
            values.push(create_node_two(op.to_s, second_value, first_value))
          else
            puts 'Ninguno'
          end
        end
        new_root = TreeNode.new('()')
        new_value = values.pop
        new_root.add_child(new_value)
        values.push(new_root)
        i += 1
      # end
      elsif operator?(regex_representation[i]) || (symbol?(regex_representation[i]) && symbol?(regex_representation[i + 1]))
        current = symbol?(regex_representation[i]) && symbol?(regex_representation[i + 1]) ? '.' : regex_representation[i]
        if regex_representation[i] == '*'
          first_value = values.pop
          values.push(create_node_two('*', first_value, TreeNode.new('*')))
        elsif regex_representation[i] == '+'
          first_value = values.pop
          values.push(create_node_two('+', first_value, TreeNode.new('+')))
        elsif regex_representation[i] == '?'
          first_value = values.pop
          values.push(create_node_two('?', first_value, TreeNode.new('?')))
        else
          while operators.any? && get_precedence(operators.last.to_s) >= get_precedence(current)
            operator = operators.pop
            case operator.to_s
            when '|'
              first_value = values.pop
              second_value = values.pop
              values.push(create_node_two('|', second_value, first_value))
            when '.'
              first_value = values.pop
              second_value = values.pop
              values.push(create_node_two('+', second_value, first_value))
            end
            # new_node = TreeNode.new(regex_representation[i])
          end
          operators.push(TreeNode.new(regex_representation[i]))
        end
        i += 1
      else
        puts 'Nada'
      end
    end
    # puts "#{values}"
    # puts "#{operators}"
    values = values.reverse
    while operators.any?
      operand = operators.pop
      case operand.to_s
      when '*', '+', '?'
        first_value = values.pop
        values.push(create_node_two(operand.to_s, first_value, TreeNode.new(operand)))
      when '|'
        first_value = values.pop
        second_value = values.pop
        values.push(create_node_two('|', first_value, second_value))
      when '.'
        first_value = values.pop
        second_value = values.pop
        values.push(create_node_two('.', first_value, second_value))
      end
    end
    values = values.reverse
    while values.length > 1
      first_value = values.pop
      second_value = values.pop
      values.push(create_node_two('.', second_value, first_value))
    end
    values[0]
  end

  def create_thompson
    @tree = create_tree(@string_representation)
    # @tree.print_children(0)
    create_afn
  end

  def create_direct
    important_symbol = SymbolNew.new('#')
    @symbols << important_symbol
    @important_tree = create_tree(@string_representation << '#')
    @symbols.delete_at(-1)
    # @important_tree.print_children(0)
    @important_tree.process_values
    # @important_tree.print_nullable(0)
    @dict = @important_tree.get_dict
    @ref = @important_tree.get_refs
    @follow_pos = @important_tree.get_follow_pos
    # @important_tree.print_name_dict
    build_dfa
  end

  def create_afn
    @tree.set_symbols(@symbols)
    @tree.set_afn_symbols([*@symbols, 'e'])
    @afn = @tree.create_state
    @graph_afn = create_graph(@afn.transition_function)
  end

  def check_string(message)
    states = @afn.eclosure(@afn.starting_states.map(&:id))
    message.each_char do |charachter|
      states = @afn.eclosure(@afn.move(states, charachter))
    end
    puts "Revisando si la cadena '#{message}' pertenece a la expresión regular'#{@string_representation}'"
    puts 'El oráculo no determinista ha pensado, y habiendo pensado ofrece una respuesta:'
    puts '----------------------------------------------------'
    puts states.intersection(@afn.final_states.map(&:id)).any?
    puts '----------------------------------------------------'
    puts 'Gracias por visitar el oráculo \n'
  end

  def share_elements(array1, array2)
    (array1 & array2).any?
  end

  def create_subset
    states = @afn.eclosure(@afn.starting_states_id).sort.uniq
    possible_names = ("A".."Z").to_a
    names = ["A"]
    afd_states = [states]
    are_marked = [false]
    are_initial = [true]
    are_final = [share_elements(states, @afn.final_states_id)]
    transition = {}
    until are_marked.find_index { |state| state == false }.nil?
      state_to_check = are_marked.find_index{ |state| state == false }
      are_marked[state_to_check] = true
      @symbols.each do |symbol|
        c_states = @afn.eclosure(@afn.move(afd_states[state_to_check], symbol.to_s)).sort.uniq
        unless afd_states.include?(c_states) || c_states == []
          names << possible_names[afd_states.length]
          afd_states << c_states
          are_marked << false
          are_initial << share_elements(c_states, @afn.starting_states_id)
          are_final << share_elements(c_states, @afn.final_states_id)
        end
        name = afd_states.find_index{ |state| state == c_states }
        (transition[[names[state_to_check], symbol.to_s]] = names[name]) if c_states != []
      end
    end
    @afd = create_afd(names, are_initial, are_final, transition)
    # puts @afd.transition_function
    @graph_subset = create_graph(@afd.transition_function)
    @afd.set_symbols(@symbols)
  end

  def build_dfa
    states = @important_tree.firstpos.sort
    possible_names = ("A".."Z").to_a
    names = ["A"]
    afd_states = [states]
    are_marked = [false]
    are_initial = [true]
    are_final = [false]
    transition = {}
    until are_marked.find_index{ |state| state == false }.nil?
      state_to_check = are_marked.find_index{ |state| state == false }
      are_marked[state_to_check] = true
      @symbols.each do |symbol|
        c_symbols = []
        afd_states[state_to_check].each do |state|
          c_symbols = (c_symbols + @follow_pos[state]) if @dict[state] == symbol.to_s
        end
        c_symbols = c_symbols.uniq.sort
        unless afd_states.include?(c_symbols)
          names << possible_names[afd_states.length]
          afd_states << c_symbols
          are_marked << false
          are_initial << false
          are_final << c_symbols.include?(@dict.keys.max)
        end
        name = afd_states.find_index{ |state| state == c_symbols }
        transition[[names[state_to_check], symbol.to_s]] = names[name]
      end
    end
    @direct_afd = create_afd(names, are_initial, are_final, transition)
    @graph_direct = create_graph(@direct_afd.transition_function)
    @direct_afd.set_symbols(@symbols)
  end

  def create_afd(states, starting_states, final_states, transition_function)
    afd_states = []
    afd_starting_states = []
    afd_final_states = []
    states.each_with_index do |name, i|
      new_state = State.new(name, starting_states[i], final_states[i])
      afd_states << new_state
      afd_starting_states << new_state if starting_states[i]
      afd_final_states << new_state if final_states[i]
    end
    AFD.new(afd_states, afd_starting_states, afd_final_states, transition_function)
  end

  def check_string_afd(message)
    state = @afd.starting_states[0].id
    message.each_char do |charachter|
      state = @afd.move(state, charachter)
    end
    puts "Revisando si la cadena '#{message}' pertenece a la expresión regular'#{@string_representation}'"
    puts 'El oráculo creado con subconjuntos ha pensado, y habiendo pensado ofrece una respuesta:'
    puts '----------------------------------------------------'
    puts @afd.final_states.map(&:id).include?(state)
    puts '----------------------------------------------------'
    puts 'Gracias por visitar el oráculo \n'
  end

  def check_string_direct(message)
    state = @direct_afd.starting_states[0].id
    message.each_char do |charachter|
      state = @direct_afd.move(state, charachter)
    end
    puts "Revisando si la cadena '#{message}' pertenece a la expresión regular'#{@string_representation}'"
    puts 'El oráculo creado con método directo ha pensado, y habiendo pensado ofrece una respuesta:'
    puts '----------------------------------------------------'
    puts @direct_afd.final_states.map(&:id).include?(state)
    puts '----------------------------------------------------'
    puts 'Gracias por visitar el oráculo \n'
  end

  def to_s
    @root.to_s
  end
end
