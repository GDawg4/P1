def create_graph(graph, names, file_name)
 dg = RGL::DirectedAdjacencyGraph[*graph]
edge_label_setting = proc{|b, e| names["#{b}-#{e}"]}
edge_settings = { 'label' => edge_label_setting, 'fontsize' => 15 }
dot_options = { 'edge' => edge_settings }
dg.write_to_graphic_file('jpg', file_name, dot_options)
end
require_relative "RegularExpression"
require "rgl/dot"
require "rgl/adjacency"
string_to_check = ""
File.open("text.txt").each_char { |x| string_to_check << x }
reg_ex = RegularExpression.new("ßempty#Ô%ßßß0%1%2%3%4%5%6%7%8%9Ôßßß0%1%2%3%4%5%6%7%8%9ÔÔ:ÔÔ#Ô%ßßß0%1%2%3%4%5%6%7%8%9Ôßßß0%1%2%3%4%5%6%7%8%9ÔÔ:Ôß.Ôß0%1%2%3%4%5%6%7%8%9Ôßßß0%1%2%3%4%5%6%7%8%9ÔÔ:ÔÔ#Ô%ßßß
%
%	Ôßßß
%
%	ÔÔ:ÔÔ#Ô")
reg_ex.create_direct
checked = reg_ex.check_string_direct(string_to_check)
graph, names = reg_ex.graph_direct
create_graph(graph, names, 'graph_direct_other')
puts "Result: #{checked}"
File.open('parser_tokens.txt', 'w') { |f| f.write(checked.map { |token| token.join('☺') }.join('☻')) }
