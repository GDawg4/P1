require_relative 'ParseState'
require_relative "RegularExpression"
require_relative "SemanticNode"
class Parser
  attr_accessor :root

  ['COMPILER', 'CHARACTERS', 'KEYWORDS', 'TOKENS', 'PRODUCTIONS', 'END', 'EXCEPT', 'IGNORE', 'alt_char', 'ident', 'number', 'colon', 'equal', 'char',  'empty', 'string',
   'greater', 'c_bracket1',  'c_bracket2', 'smaller', 's_bracket1', 's_bracket2', 'or', 'comment', 'char_range', 'attribute', 'p_bracket1', 'p_bracket2', 'n_bracket1', 'n_bracket2'].each_with_index do |token, i|
    define_method("is_#{token}") do |name|
      name == i
    end
  end

  def initialize
    file = File.open('tokens.txt')
    @tokens = file.read.split('☻').map do |token|
                token.split('☺').map.with_index do |s, i|
                  i.zero? ? s : s.to_i
                end
              end.reject! { |j| [14, nil].include?(j[1]) }
    file.close
    @current = 0
    @tokens_key = {}
    list = ['COMPILER', 'CHARACTERS', 'KEYWORDS', 'TOKENS', 'EXCEPT', 'ident', 'number', '.', '=', 'char', 'empty', 'string',
            'Ô']
    list.each_with_index do |token, index|
      @tokens_key[token] = index
    end
    # puts @tokens.to_s
  end

  def peek_first
    @tokens[@current][1]
  end

  def first_lex
    @tokens[@current][0]
  end

  def cocol
    @root = ParseState.new('@root')
    @root.add_child(compiler)
    @root.add_child(ident)
    @root.add_child(scanner)
  end

  def compiler
    if is_COMPILER(peek_first)
      advance
      ParseState.new('COMPILER')
    end
  end

  def scanner
    scanner_node = ParseState.new('ScannerSpecification')
    if is_CHARACTERS(peek_first)
      scanner_node.add_child(ParseState.new('CHARACTERS'))
      advance
      scanner_node.add_child(sets)
    end
    if is_KEYWORDS(peek_first)
      scanner_node.add_child(ParseState.new('KEYWORDS'))
      advance
      scanner_node.add_child(keywords)
    end
    if is_TOKENS(peek_first)
      scanner_node.add_child(ParseState.new('TOKENS'))
      advance
      scanner_node.add_child(tokens)
    end
    if is_PRODUCTIONS(peek_first)
      scanner_node.add_child(ParseState.new('PRODUCTIONS'))
      advance
      scanner_node.add_child(productions)
    end
    if is_END(peek_first)
      scanner_node.add_child(endd)
      scanner_node.add_child(ident)
    end
    if is_IGNORE(peek_first)
      scanner_node.add_child(ignore)
      scanner_node.add_child(ident)
    end
    scanner_node
  end

  def sets
    sets_node = ParseState.new('Sets')
    while is_ident(peek_first)
      inner_set = ParseState.new('SetDecl')
      inner_set.add_child(ident)
      inner_set.add_child(ParseState.new('='))
      advance
      inner_set.add_child(set)
      inner_set.add_child(ParseState.new('.'))
      advance
      sets_node.add_child(inner_set)
    end
    sets_node
  end

  def set
    set_node = ParseState.new('Set')
    set_node.add_child(basic_set)
    while is_greater(peek_first) || is_smaller(peek_first)
      is_greater(peek_first) ? set_node.add_child(greater_symbol) : set_node.add_child(smaller_symbol)
      set_node.add_child(basic_set)
    end
    set_node
  end

  def greater_symbol
    advance
    ParseState.new('+')
  end

  def smaller_symbol
    advance
    ParseState.new('-')
  end

  def basic_set
    basic_set_node = ParseState.new('Basic set')
    basic_set_node.add_child(ident) if is_ident(peek_first)
    basic_set_node.add_child(stringn) if is_string(peek_first)
    basic_set_node.add_child(alt_char) if is_alt_char(peek_first)
    basic_set_node.add_child(char) if is_char(peek_first)
    basic_set_node
  end

  def keywords
    keywords_node = ParseState.new('Keywords')
    while is_ident(peek_first)
      inner_key = ParseState.new('KeywordsDecl')
      inner_key.add_child(ident)
      inner_key.add_child(ParseState.new('='))
      advance
      inner_key.add_child(stringn)
      inner_key.add_child(ParseState.new('.'))
      advance
      keywords_node.add_child(inner_key)
    end
    keywords_node
  end

  def tokens
    tokens_node = ParseState.new('Tokens')
    while is_ident(peek_first)
      inner_token = ParseState.new('TokenDecl')
      inner_token.add_child(ident)
      if is_equal(peek_first)
        inner_token.add_child(ParseState.new('='))
        advance
        inner_token.add_child(token_expr)
      end
      if is_EXCEPT(peek_first)
        inner_token.add_child(ParseState.new(first_lex))
        advance
        inner_token.add_child(ParseState.new(first_lex))
        advance
      end
      inner_token.add_child(ParseState.new('.'))
      advance
      tokens_node.add_child(inner_token)
    end
    tokens_node
  end

  def token_expr
    token_expr_node = ParseState.new('TokenExpr')
    token_expr_node.add_child(token_term)
    while is_or(peek_first)
      token_expr_node.add_child(ParseState.new('%'))
      advance
      token_expr_node.add_child(token_term)
    end
    token_expr_node
  end

  def token_term
    token_term_node = ParseState.new('TokenTerm')
    token_term_node.add_child(token_factor)
    while is_ident(peek_first) || is_string(peek_first) || first_lex == '(' || first_lex == '[' || first_lex == '{'
      token_term_node.add_child(token_factor)
    end
    token_term_node
  end

  def token_factor
    token_factor_node = ParseState.new('TokenFactor')
    if ['(', '[', '{'].include? first_lex
      token_factor_node.add_child(ParseState.new('ß'))
      token_factor_node.add_child(ParseState.new('ß'))
      advance
      token_factor_node.add_child(token_expr)
      item_to_add = case first_lex
                    when ']'
                      'Ô?Ô'
                    when '}'
                      'Ô:Ô'
                    else
                      'ÔÔ'
                    end
      token_factor_node.add_child(ParseState.new(item_to_add))
      advance
    else
      token_factor_node.add_child(symbol)
    end
    token_factor_node
  end

  def symbol
    symbol_node = ParseState.new('Symbol')
    if is_ident(peek_first)
      symbol_node.add_child(ident)
    elsif is_string(peek_first)
      symbol_node.add_child(stringn)
    end
    symbol_node
  end

  def productions
    production_node = ParseState.new('Productions')
    while is_ident(peek_first)
      inner_token = ParseState.new('Production')
      inner_token.add_child(ident)
      # puts "Next is1 #{first_lex}"
      if is_attribute(peek_first)
        inner_token.add_child(attributes)
      end
      # puts "Next is2 #{first_lex}"
      if is_comment(peek_first)
        inner_token.add_child(sem_action)
      end
      # puts "Next is3 #{first_lex}"
      inner_token.add_child(ParseState.new('='))
      advance
      inner_token.add_child(production_expression)
      inner_token.add_child(ParseState.new('.'))
      advance
      production_node.add_child(inner_token)
    end
    production_node
  end

  def attributes
    inner_token = ParseState.new('Attributes')
    if is_attribute(peek_first)
      inner_token.add_child(ParseState.new(first_lex))
      advance
    else
      inner_token.add_child(ParseState.new('<>'))
    end
    inner_token
  end

  def sem_action
    ident = ParseState.new('SemAction')
    leaf = ParseState.new(first_lex)
    ident.add_child(leaf)
    advance
    ident
  end

  def production_expression
    inner_token = ParseState.new('ProductionExpression')
    inner_token.add_child(production_term)
    while is_or(peek_first)
      inner_token.add_child(ParseState.new('|'))
      advance
      inner_token.add_child(production_term)
    end
    inner_token
  end

  def production_term
    inner_token = ParseState.new('ProductionTerm')
    inner_token.add_child(production_factor)
    while is_ident(peek_first) || is_string(peek_first) || first_lex == '(' || first_lex == '[' || first_lex == '{' || is_comment(peek_first)
      inner_token.add_child(production_factor)
    end
    inner_token
  end

  def production_factor
    inner_token = ParseState.new('ProductionFactor')
    if is_comment(peek_first)
      inner_token.add_child(sem_action)
    elsif ['(', '[', '{'].include? first_lex
      inner_token.add_child(ParseState.new(first_lex))
      advance
      inner_token.add_child(production_expression)
      inner_token.add_child(ParseState.new(first_lex))
      advance
    else
      inner_token.add_child(symbol)
      inner_token.add_child(attributes) if is_attribute(peek_first)
    end
    inner_token
  end

  def ignore
    advance
    ParseState.new('IGNORE')
  end

  def endd
    advance
    ParseState.new('END')
  end

  def ident
    if is_ident(peek_first)
      ident = ParseState.new('ident')
      leaf = ParseState.new(first_lex)
      ident.add_child(leaf)
      advance
      ident
    end
  end

  def stringn
    stringn = ParseState.new('string')
    leaf = ParseState.new(first_lex)
    stringn.add_child(leaf)
    advance
    stringn
  end

  def alt_char
    character = ParseState.new('alt_char')
    char_to_add = (first_lex.split('(')[1]).split(')')[0].to_i.chr
    leaf = ParseState.new(char_to_add)
    character.add_child(leaf)
    advance
    character
  end

  def char
    char_node = ParseState.new('char')
    char_to_add = first_lex.gsub("'", '"')
    advance
    if is_char_range(peek_first)
      advance
      range = (char_to_add..first_lex).to_a.join('').tr('"', '')
      leaf = ParseState.new(range)
      char_node.add_child(leaf)
      advance
    else
      leaf = ParseState.new(char_to_add)
      char_node.add_child(leaf)
    end
    char_node
  end

  def advance
    @current = [@current += 1, @tokens.length-1].min
  end

  def clean_empty
    @tokens.shift while is_empty(peek_first)
  end
end

parser = Parser.new
parser.cocol
# parser.root.create_first
# parser.root.print_children(0)
sets = parser.root.sets
keywords = parser.root.keywords
tokens = parser.root.tokens_test
productions = parser.root.productions

# puts "SETS #{sets}"
# puts "#{keywords}"
# puts "TOKENS #{tokens}"
# puts "PRODUCTIONS #{productions}"

sets_f = {}
sets_f["ANY"] = ((0..9).to_a + ('A'..'Z').to_a + ['Ñ, ñ']+ ('a'..'z').to_a + ('!'..'?').to_a + ['=', '[', ']', '|', '{', '}']).join('').gsub('%', '.').gsub('ß', '').gsub('Ô', '').gsub('µ', '').gsub(':', '').gsub('@', '').gsub('#', '').gsub('?', '')
sets.each do |set|
  if set.length == 4
    sets_f[set[0]] = set[2] == '"' ? "\"": set[2].tr('"', '')
  else
    i = 2
    current_set = ''
    while i < set.length
      if set[i] == '.'
        i += 1
        next
      end
      current_value = (set[i][0] == '"' || set[i].length == 1) ? set[i] : sets_f[set[i]]
      if i == 2
        current_set << current_value.tr('"', '')
        i += 2
        next
      else
        if set[i-1] == '+'
          current_set = (current_set + current_value).chars.uniq.join('').tr('"', '')
        elsif set[i-1] == '-'
          current_set = (current_set.split('') - current_value.split('')).uniq.join('').tr('"', '')
        end
      end
      i += 2
    end
    sets_f[set[0]] = current_set.tr('"', '')
  end
end

sets_f.transform_values! { |value| "ß#{value.each_char.map(&:to_s).join('%')}Ô"}
# puts "Sets f #{sets_f}"

keywords_f = {}
keywords.each { |keyword| keywords_f[keyword[0]] = keyword[2] }

tokens_list = []
tokens_f = {}
has_except = {}
tokens.each_with_index do |token, i|
  has_except[token[0]] = !token.index('EXCEPT').nil?
  decl_range = [token.index('.'), token.index('EXCEPT') || +1.0/0.0 ].min
  changed =  (token[2..decl_range-1].map do |element|
    ['"'].include?(element[0]) ? "ß#{element.tr('"', '')}Ô" : ['ß', 'Ô', '{', '}', '[', ']', '%'].include?(element[0]) ? element.tr('"', '') : sets_f[element]
  end)
  tokens_list << token[0]
  tokens_f[token[0]] = changed.join('')
end

final_string = ''
tokens_f.each do |key, value|
  next if has_except[key]
  final_string << "ßß#{value}Ô#Ô%"
end
keywords_f.each do |_, value|
  final_string << "ß#{value.tr('"','')}#Ô%"
end
tokens_f.each do |key, value|
  next unless has_except[key]
  final_string << "ßß#{value}Ô#Ô%"
end
# puts "Final #{final_string}"

instructions_to_write = [
  'def create_graph(graph, names, file_name)',
   ' dg = RGL::DirectedAdjacencyGraph[*graph]',
    'edge_label_setting = proc{|b, e| names["#{b}-#{e}"]}',
    "edge_settings = { 'label' => edge_label_setting, 'fontsize' => 15 }",
    "dot_options = { 'edge' => edge_settings }",
    "dg.write_to_graphic_file('jpg', file_name, dot_options)",
  'end',
  'require_relative "RegularExpression"',
  'require "rgl/dot"',
  'require "rgl/adjacency"',
  "string_to_check = \"\"",
  'File.open("text.txt").each_char { |x| string_to_check << x }',
  "reg_ex = RegularExpression.new(\"ßempty#Ô%#{final_string.chop.gsub('"', '\"')}\")",
  'reg_ex.create_direct',
  'checked = reg_ex.check_string_direct(string_to_check)',
  'graph, names = reg_ex.graph_direct',
  "create_graph(graph, names, 'graph_direct_other')",
  'puts "Result: #{checked}"',
  "File.open('parser_tokens.txt', 'w') { |f| f.write(checked.map { |token| token.join('☺') }.join('☻')) }"

]
File.open('expr.rb', 'w') do |f|
  f.puts(instructions_to_write)
end

start = []
names = []
productions.map(&:flat_contents).each do |production|
  start << production.find_index('=')
  names << production[0]
end

starts = {}
descent_to_write = [
  "class Descender",
  "\n",
  "\tdef initialize",
  "\t\tfile = File.open('parser_tokens.txt')",
  "\t\t@tokens = file.read.split('☻').map do |token|",
  "\t\ttoken.split('☺').map.with_index do |s, i|",
  "\t\t\ts == 'nil' ? nil : i.zero? ? s : s.to_i",
  "\t\t\tend",
  "\t\tend.reject! { |j| [0].include?(j[1]) }",
  "\t\tfile.close",
  "\t\tfile = File.open('tokens_list.txt')",
  "\t\t@tokens_key = file.read.split('☺')",
  "\t\tfile.close",
  "\t\t@tokens = @tokens.map {|token| token[1].nil? ? token : [token[0], @tokens_key[token[1]]]}",
  "\t\tputs \"Tokens \#{@tokens}\"",
  "\tend",
  "\n",
  "\tdef consume(token)",
  "\t\treturn_value = lookAhead == token ? @tokens[0][0] : 0",
  "\t\t@tokens.shift",
  "\t\treturn_value",
  "\tend",
  "\tdef lookAhead",
  "\t\t@tokens[0][1].nil? ? @tokens[0][0] : @tokens[0][1]",
  "\tend",
  "\tdef firstToken",
  "\t\t@tokens[0][0]",
	"\tend",
  "\n",
]
productions.reverse.each.with_index do |production, i|
  real_start = [start.reverse[i], 2].min+1
  production.children[real_start].create_first
  starts[names.reverse[i]] = production.children[real_start].first.map{
    |first| first[0] == '"' ? first : starts[first] ? starts[first].flatten : first
  }.flatten
  production.set_firsts_flat(starts)
end
productions.each.with_index do |production, i|
  real_start = [start[i], 2].min+1
  parameters = production.children[real_start-2].name == 'Attributes' ? production.children[real_start-2].drill_down[0][1..-2].split(','): []
  return_value = ''
  if parameters.any? && parameters[0].include?('*')
    return_value = "return #{parameters[0][1..-1]}"
    parameters.slice!(0)
  end
  production.children[real_start].create_function
  descent_to_write << "\t#{production.children[real_start].get_function(names[i], parameters.join(','), return_value)}"
end
# parser.root.print_children(0)
# puts "#{starts}"
descent_to_write << "end"
descent_to_write << "desc = Descender.new"
descent_to_write << "desc.Expr()"
File.open('descent.rb', 'w') do |f|
  f.puts(descent_to_write)
end

File.open('tokens_list.txt', 'w') {|f| f.write(tokens_list.join('☺'))}