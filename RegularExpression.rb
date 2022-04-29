require_relative 'Symbol'
require_relative 'Operator'
require_relative 'ExTree'
require_relative 'TreeNode'
require_relative 'AFD'
require_relative 'State'

class RegularExpression
  def initialize(string_representation)
    @string_representation = sub_sets(string_representation)
    @operators = [Operator.new(':', 2), Operator.new('@', 2), Operator.new('?', 2), Operator.new('%', 0), Operator.new(';', 1)]
    @symbols = ((@string_representation.split('').uniq - ['<', '>']) - @operators.map(&:to_s)).map do |symbol|
      SymbolNew.new(symbol)
    end
    @tree_representation = nil
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
    when ':', '@', '?'
      2
    when ';'
      2
    when '%'
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
    [':', '@', '?'].include?(symbol)
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
      # puts "Operators #{operators.length()} #{operators}"
      # puts "Values #{values.length()} #{values}"
      # puts "\nNext value #{regex_representation[i]}"
      if symbol? regex_representation[i]
        # puts regex_representation[i]
        new_node = TreeNode.new(regex_representation[i])
        values.push(new_node)
        if symbol?(regex_representation[i + 1]) || (i.positive? && unary?(regex_representation[i - 1])) || (i.positive? && regex_representation[i-1].to_s == '>')
          operators.push(TreeNode.new(';'))
        end
        i += 1
      elsif regex_representation[i] == '<'
        operators.push(TreeNode.new(';')) if regex_representation[[0, i - 1].max] == '>' || symbol?(regex_representation[[0, i - 1].max])
        new_node = TreeNode.new(regex_representation[i])
        operators.push(new_node)
        i += 1
      elsif regex_representation[i] == '>'
        while operators.last.to_s != '<'
          op = operators.pop
          case op.to_s
          when ':', '@', '?'
            new_value = values.pop
            values.push(create_node_two(op.to_s, new_value, op))
          when '%'
            first_value = values.pop
            second_value = values.pop
            values.push(create_node_two(op.to_s, second_value, first_value))
          when ';'
            first_value = values.pop
            second_value = values.pop
            values.push(create_node_two(op.to_s, second_value, first_value))
          # when '<'
          #   new_node = TreeNode.new('<')
          #   operators.push(new_node)
          #   i += 1
          else
            puts 'Ninguno'
          end
        end
        new_root = TreeNode.new('<>')
        new_value = values.pop
        new_root.add_child(new_value)
        values.push(new_root)
        operators.pop
        i += 1
      # end
      elsif operator?(regex_representation[i]) || (symbol?(regex_representation[i]) && symbol?(regex_representation[i + 1])) || regex_representation[i] == '#'
        current = symbol?(regex_representation[i]) && symbol?(regex_representation[i + 1]) ? ';' : regex_representation[i]
        if regex_representation[i] == ':'
          first_value = values.pop
          values.push(create_node_two(':', first_value, TreeNode.new(':')))
        elsif regex_representation[i] == '@'
          first_value = values.pop
          values.push(create_node_two('@', first_value, TreeNode.new('@')))
        elsif regex_representation[i] == '?'
          first_value = values.pop
          values.push(create_node_two('?', first_value, TreeNode.new('?')))
        else
          while operators.any? && get_precedence(operators.last.to_s) >= get_precedence(current)
            operator = operators.pop
            case operator.to_s
            when '%'
              first_value = values.pop
              second_value = values.pop
              values.push(create_node_two('%', second_value, first_value))
            when ';'
              first_value = values.pop
              second_value = values.pop
              values.push(create_node_two(';', second_value, first_value))
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
    # puts "\nOperators final #{operators.length()} #{operators}"
    # puts "Values final #{values.length()} #{values}"
    # values.each {|a| puts "#{a.children_s}"}
    values = values.reverse
    while operators.any?
      operand = operators.pop
      case operand.to_s
      when ':', '@', '?'
        first_value = values.pop
        values.push(create_node_two(operand.to_s, first_value, TreeNode.new(operand)))
      when '%'
        first_value = values.pop
        second_value = values.pop
        values.push(create_node_two('%', first_value, second_value))
      when ';'
        first_value = values.pop
        second_value = values.pop
        values.push(create_node_two(';', first_value, second_value))
      end
    end
    values = values.reverse
    while values.length > 1
      first_value = values.pop
      second_value = values.pop
      values.push(create_node_two(';', second_value, first_value))
    end
    # first_value = values.pop
    # values.push(create_node_two(';', first_value, TreeNode.new('#')))
    values[0]
  end

  def sub_sets(string_to_check)
    @sets = {
      'letter': 'a|b|c|d|e|f|g|h|i|j|k|l|m|n|o|p|q|r|s|t|u|v|w|x|y|z|A|B|C|D|E|F|G|H|I|J|K|L|M|N|O|P|Q|R|S|T|U|V|W|X|Y|Z',
      'digit': '0|1|2|3|4|5|6|7|8|9'
    }
    @basic_sets = {
      'ident': 'letter<letter%digit>:',
      'range': '<charachter<empty>..<empty>charachter>',
      'charachter': '<char%alt_char>',
      'alt_char': '<CHR(number)>',
      'number': 'digit<digit>:',
      'string': '"<letter%digit%symbol>:"',
      'char': '\'<letter%digit%+%-% >\'',
      'any': '<letter%digit%empty%symbol>:',
      'letter': 'a%b%c%d%e%f%g%h%i%j%k%l%m%n%ñ%o%p%q%r%s%t%u%v%w%x%y%z%A%B%C%D%E%F%G%H%I%J%K%L%M%N%Ñ%O%P%Q%R%S%T%U%V%W%X%Y%Z',
      'symbol': '(%)%{%}%+%-%=%[%]%|%/%\'%*%.%/',
      'digit': '0%1%2%3%4%5%6%7%8%9',
      'empty': "<\n%\t%\x16%#{32.chr}>:"
    }
    new_string = string_to_check
    @basic_sets.each do |key, value|
      new_string = new_string.gsub(key.to_s, "<#{value}>")
    end
    new_string
  end

  def create_direct
    # important_symbol = SymbolNew.new('#')
    # @symbols << important_symbol
    temp = sub_sets(@string_representation)
    # puts "Temp: #{temp}"
    @important_tree = create_tree(temp)
    # @symbols.delete_at(-1)
    # @important_tree.print_children(0)
    @important_tree.process_values
    @dict = @important_tree.get_dict
    @ref = @important_tree.get_refs
    @return_pos = {}
    found_return = 0
    @dict.each do |key, value|
      if value == '#'
        @return_pos[key] = found_return
        found_return += 1
      end
    end
    # puts @return_pos
    @follow_pos = @important_tree.get_follow_pos
    build_dfa
  end

  def share_elements(array1, array2)
    (array1 & array2).any?
  end

  def build_dfa
    states = @important_tree.firstpos.sort
    possible_names = ("AA".."ZZ").to_a
    names = ["A"]
    afd_states = [states]
    are_marked = [false]
    are_initial = [true]
    final_symbols = []
    @dict.each do |key, value|
      final_symbols << key if value == '#'
    end
    are_final = [(states & final_symbols).any?]
    return_states = [(states & final_symbols)[0]]
    transition = {}
    until are_marked.find_index{ |state| state == false }.nil?
      state_to_check = are_marked.find_index{ |state| state == false }
      are_marked[state_to_check] = true
      @symbols.each do |symbol|
        c_symbols = []
        afd_states[state_to_check].each do |state|
          c_symbols = (c_symbols + (@follow_pos[state] || [])) if @dict[state] == symbol.to_s
        end
        c_symbols = c_symbols.uniq.sort
        unless afd_states.include?(c_symbols) || c_symbols == []
          names << possible_names[afd_states.length]
          afd_states << c_symbols
          are_marked << false
          are_initial << false
          are_final << (c_symbols & final_symbols).any?
          return_states << (c_symbols & final_symbols)[0]
        end
        name = afd_states.find_index{ |state| state == c_symbols }
        transition[[names[state_to_check], symbol.to_s]] = names[name] if c_symbols != []
      end
    end
    # puts "Names #{names}"
    # puts "Are final #{are_final}"
    return_states = return_states.map do |state|
      state.nil? ? nil : @return_pos[state]
    end
    # puts "Final symbols #{return_states}"
    @direct_afd = create_afd(names, are_initial, are_final, transition, return_states)
    @graph_direct = create_graph(@direct_afd.transition_function)
    @direct_afd.set_symbols(@symbols)
  end

  def create_afd(states, starting_states, final_states, transition_function, return_tokens)
    afd_states = []
    afd_starting_states = []
    afd_final_states = []
    states.each_with_index do |name, i|
      new_state = State.new(name, starting_states[i], final_states[i], return_tokens[i])
      afd_states << new_state
      afd_starting_states << new_state if starting_states[i]
      afd_final_states << new_state if final_states[i]
    end
    @return_tokens = Hash[[states, return_tokens].transpose]
    AFD.new(afd_states, afd_starting_states, afd_final_states, transition_function, return_tokens)
  end

  def check_string_direct(message)
    state = @direct_afd.starting_states[0].id
    i = 0
    found_tokens = []
    last_found = 0
    while i < message.length
      string_to_check = message[i]
      new_state = @direct_afd.move(state, string_to_check)
      # puts "String: '#{string_to_check}' in state #{state} to #{new_state}"
      if new_state.nil?
        # puts "Last found: #{last_found} i:#{i}"
        if i - last_found == 1
          # puts "Stopped at token: '#{message[last_found]}' to number: #{@return_tokens[state]}"
          found_tokens.push([message[last_found], @return_tokens[state]])
        elsif i == last_found
          puts "Not recognized at #{last_found}"
          found_tokens.push([message[i], nil])
          i += 1
        else
          # puts "Stopped at token2: '#{message[last_found..i-1]}' to number: #{@return_tokens[state]}"
          found_tokens.push([message[last_found..i-1], @return_tokens[state]])
        end 
        state = @direct_afd.starting_states[0].id
        last_found = i
      else
        state = new_state
        i += 1
      end
    end
    found_tokens.push([message[last_found..-1], @return_tokens[state]])
    # puts "#{found_tokens}"
  end

  def to_s
    @root.to_s
  end
end
