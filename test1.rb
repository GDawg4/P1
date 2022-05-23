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
  line
end
string_to_check = ''
File.readlines("p31.atg").each { |x| string_to_check << process_line(x) }
# \n
# reg_ex = RegularExpression.new('ßCOMPILER#Ô%ßCHARACTERS#Ô%ßKEYWORDS#Ô%ßTOKENS#Ô%ßPRODUCTIONS#Ô%ßEND#Ô%ßEXCEPT#Ô%ßIGNORE#Ô%ßalt_char#Ô%ßident#Ô%ßnumber#Ô%ß.#Ô%ß=#Ô%ßchar#Ô%ßßemptyÔ#Ô%ßstring#Ô%ß+#Ô%ß{#Ô%ß}#Ô%ß-#Ô%ß[#Ô%ß]#Ô%ß|#Ô%ßßß(.Ôßßletter%symbol%digit%emptyÔ:Ôß.)ÔÔ#Ô%ß..#Ô%<#%>#')
reg_ex = RegularExpression.new('ßCOMPILER#Ô%ßCHARACTERS#Ô%ßKEYWORDS#Ô%ßTOKENS#Ô%ßPRODUCTIONS#Ô%ßEND#Ô%ßEXCEPT#Ô%ßIGNORE#Ô%ßalt_char#Ô%ßident#Ô%ßnumber#Ô%ß.#Ô%ß=#Ô%ßchar#Ô%ßßemptyÔ#Ô%ßstring#Ô%ß+#Ô%ß{#Ô%ß}#Ô%ß-#Ô%ß[#Ô%ß]#Ô%ß|#Ô%ßßß(.Ôßßletter%symbol%digit% Ô:Ôß.)ÔÔ#Ô%ß..#Ô%ß<Ôßßletter%symbol%digit% Ô:Ôß>#Ô%ß<#Ô%ß>#Ô%ß(#Ô%ß)#Ô')
# reg_ex = RegularExpression.new('ßßabcaÔ#Ô%ßßabÔ#Ô%ßßbÔ#Ô%ßßcÔ#Ô%ßempty#Ô')
reg_ex.create_direct
checked = reg_ex.check_string_direct(string_to_check)
puts "Result: #{checked}"
file = File.open('tokens.txt', 'w') { |f| f.write(checked.map { |token| token.join('☺') }.join('☻')) }
graph, names = reg_ex.graph_direct
create_graph(graph, names, 'graph_direct')
# puts time_direct