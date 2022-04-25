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

string_to_check = ''
File.open("test.atg").each_char { |x| string_to_check << x }
# puts string_to_check
expressions = ['a(bc)*', 'a(cb)*']
# ε
# \n
# ((a(bc)*)#)|((a(cb)*)#)
# reg_ex = RegularExpression.new('CharsDecl#|KeyDecl#|TokenDecl#')
reg_ex = RegularExpression.new('(COMPILER#)|(CHARACTERS#)|(KEYWORDS#)|(TOKENS#)|(PRODUCTIONS#)|(END#)|(EXCEPT#)|(ident#)|(number#)|(;#)|(=#)|(char#)|((empty)#)|(string#)|(>#)|({#)|(}#)|(<#)')
reg_ex.create_direct
checked = reg_ex.check_string_direct(string_to_check)
puts "Result: #{checked}"
file = File.open('tokens.txt', 'w') { |f| f.write(checked.map { |token| token.join('*') }.join('&')) }
graph, names = reg_ex.graph_direct
create_graph(graph, names, 'graph_direct')
# puts time_direct