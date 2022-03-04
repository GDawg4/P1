require_relative 'Symbol'
require_relative 'Operator'
require_relative 'ExTree'
require_relative 'TreeNode'

class RegularExpression
  def initialize(string_representation)
    @string_representation = string_representation
    @operators = [Operator.new('*', 2), Operator.new('|', 0), Operator.new('.', 1)]
    @symbols = ((string_representation.split('').uniq - ['(', ')']) - @operators.map(&:to_s)).map do |symbol|
      SymbolNew.new(symbol)
    end
    @tree_representation = nil
  end

  def symbol?(value)
    @symbols.map(&:to_s).include?(value)
  end

  def operator?(value)
    @operators.map(&:to_s).include? value
  end

  def get_precedence(operator)
    case operator
    when '*'
      2
    when '.'
      2
    when '|'
      1
    else
      0
    end
  end

  def create_thompson
    values = []
    operators = []
    i = 0
    while i < @string_representation.length
      if symbol? @string_representation[i]
        # puts @string_representation[i]
        new_node = TreeNode.new(@string_representation[i])
        values.push(new_node)
        if symbol?(@string_representation[i + 1]) || (i.positive? && @string_representation[i - 1] == '*')
          operators.push(TreeNode.new('.'))
        end
        i += 1
      elsif @string_representation[i] == '('
        new_node = TreeNode.new(@string_representation[i])
        operators.push(new_node)
        i += 1
      elsif @string_representation[i] == ')'
        while operators.last.to_s != '('
          op = operators.pop
          case op.to_s
          when '*'
            new_root = TreeNode.new(operand.to_s)
            new_value = values.pop
            new_root.add_child(new_value)
            new_root.add_child(op)
            values.push(new_root)
          when '|'
            new_root = TreeNode.new(op)
            first_value = values.pop
            second_value = values.pop
            new_root.add_child(second_value)
            new_root.add_child(first_value)
            values.push(new_root)
          when '.'
            new_root = TreeNode.new(op)
            first_value = values.pop
            second_value = values.pop
            new_root.add_child(second_value)
            new_root.add_child(first_value)
            values.push(new_root)
          else
            puts 'Ninguno'
          end
        end
        left = operators.pop
        new_root = TreeNode.new('root')
        new_value = values.pop
        new_root.add_child(new_value)
        values.push(new_root)
        i += 1
      # end
      elsif operator?(@string_representation[i]) || (symbol?(@string_representation[i]) && symbol?(@string_representation[i + 1]))
        current = symbol?(@string_representation[i]) && symbol?(@string_representation[i + 1]) ? '.' : @string_representation[i]
        if @string_representation[i] == '*'
          first_value = values.pop
          new_root = TreeNode.new('*')
          new_op = TreeNode.new('*')
          new_root.add_child(first_value)
          new_root.add_child(new_op)
          values.push(new_root)
        else
          while operators.any? && get_precedence(operators.last.to_s) >= get_precedence(current)
            operator = operators.pop
            case operator.to_s
            when '|'
              first_value = values.pop
              second_value = values.pop
              new_op = TreeNode.new('|')
              new_op.add_child(second_value)
              new_op.add_child(first_value)
              values.push(new_op)
            when '.'
              first_value = values.pop
              second_value = values.pop
              new_op = TreeNode.new('.')
              new_op.add_child(second_value)
              new_op.add_child(first_value)
              values.push(new_op)
            end
            new_node = TreeNode.new(@string_representation[i])
          end
          operators.push(TreeNode.new(@string_representation[i]))
        end
        i += 1
      else
        puts 'Nada'
      end
    end
    while operators.any?
      operand = operators.pop
      case operand.to_s
      when '*'
        first_value = values.pop
        new_root = TreeNode.new(operand.to_s)
        new_operand = TreeNode.new(operand)
        new_root.add_child(first_value)
        new_root.add_child(new_operand)
        values.push(new_root)
      when '|'
        first_value = values.pop
        second_value = values.pop
        new_root = TreeNode.new(operand.to_s)
        new_root.add_child(second_value)
        new_root.add_child(first_value)
        values.push(new_root)
      when '.'
        first_value = values.pop
        second_value = values.pop
        new_root = TreeNode.new(operand)
        new_root.add_child(second_value)
        new_root.add_child(first_value)
        values.push(new_root)
      end
    end
    values = values.reverse
    while values.length > 1
      second_value = values.pop
      first_value = values.pop
      new_root = TreeNode.new('.')
      new_root.add_child(second_value)
      new_root.add_child(first_value)
      values.push(new_root)
    end
    @tree = values[0]
    # puts @tree.print_children
    create_afn
  end

  def create_afn
    @tree.set_symbols(@symbols)
    @tree.set_afn_symbols([*@symbols, 'e'])
    @afn = @tree.create_state
  end

  def check_string(message)
    states = @afn.eclosure(@afn.starting_states.map(&:id))
    message.each_char do |charachter|
      states = @afn.move(@afn.eclosure(states), charachter)
    end
    puts "Revisando si la cadena '#{message}' pertenece a la expresión regular'#{@string_representation}'"
    puts 'El oráculo ha pensado, y habiendo pensado ofrece una respuesta:'
    puts '----------------------------------------------------'
    puts states.intersection(@afn.final_states.map(&:id)).any?
    puts '----------------------------------------------------'
    puts 'Gracias por visitar el oráculo'
  end

  

  def create_subset
    states = @afn.eclosure(@afn.starting_states.map(&:id)).sort
    possible_names = ("A".."Z").to_a
    afd_states = [states]
    are_marked = [false]
    names = ["A"]
    transition = {}
    until are_marked.find_index{ |state| state == false }.nil?
      state_to_check = are_marked.find_index{ |state| state == false }
      are_marked[state_to_check] = true
      @symbols.each do |symbol|
        c_states = @afn.eclosure(@afn.move(afd_states[state_to_check], symbol.to_s)).sort
        unless afd_states.include?(c_states)
          names << possible_names[afd_states.length]
          afd_states << c_states
          are_marked << false
        end
        name = afd_states.find_index{ |state| state == c_states }
        transition[[names[state_to_check], symbol.to_s]] = names[name]
      end
    end
    puts "#{afd_states}"
    puts "#{transition.to_s}"
    puts "#{names.to_s}"
  end

  def to_s
    @root.to_s
  end
end
