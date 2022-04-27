require_relative "RegularExpression"
require_relative "Tokenizer"
require 'benchmark'

def create_graph(graph, names, file_name)
  dg = RGL::DirectedAdjacencyGraph[*graph]
  edge_label_setting = proc{|b, e| names["#{b}-#{e}"]}
  edge_settings = { 'label' => edge_label_setting, 'fontsize' => 15 }
  dot_options = { 'edge' => edge_settings }
  dg.write_to_graphic_file('jpg', file_name, dot_options)
end

def process_line(line)
  # line = line.gsub('+', '>').gsub('-', '<').gsub('|', '%').gsub('..', ':').gsub('(.', '$').gsub('.)', '$').gsub('/*', '').gsub('*/', '').gsub('(', '@').gsub(')', '@')
  # line[-2] = ';' if line[-2] == '.'
  # line.gsub('.', '!')
  line
end
string_to_check = ''
File.readlines("test.atg").each { |x| string_to_check << process_line(x) }
puts string_to_check
expressions = ['a(bc)*', 'a(cb)*']
# ε
# \n
reg_ex = RegularExpression.new('<COMPILER#>%<CHARACTERS#>%<KEYWORDS#>%<TOKENS#>%<PRODUCTIONS#>%<END#>%<EXCEPT#>%<alt_char#>%<ident#>%<number#>%<.#>%<=#>%<char#>%<<empty>#>%<string#>%<+#>%<{#>%<}#>%<-#>%<[#>%<]#>%<|#>%<<$any$>#>%<..#>')
# reg_ex = RegularExpression.new('<char#>%<.#>')
# reg_ex = RegularExpression.new('(.#)')
reg_ex.create_direct
checked = reg_ex.check_string_direct(string_to_check)
puts "Result: #{checked}"
file = File.open('tokens.txt', 'w') { |f| f.write(checked.map { |token| token.join('*') }.join('&')) }
graph, names = reg_ex.graph_direct
create_graph(graph, names, 'graph_direct')
# puts time_direct