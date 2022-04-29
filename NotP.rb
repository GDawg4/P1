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
reg_ex = RegularExpression.new("<<<\"><<A>:><\">>#>%<<<<A>>:>#>")
#<<<\"><A><<A>>:<\">>#>%<<<A><<A>%<0>>:>#>
reg_ex.create_direct
checked = reg_ex.check_string_direct("AAA")
puts "Result: #{checked}"
graph, names = reg_ex.graph_direct
create_graph(graph, names, 'graph_direct')