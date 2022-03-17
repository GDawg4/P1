require_relative "RegularExpression"
require 'rgl/adjacency'
require 'rgl/dot'
require 'benchmark'

def create_graph(graph, names, file_name)
  dg = RGL::DirectedAdjacencyGraph[*graph]
  edge_label_setting = proc{|b, e| names["#{b}-#{e}"]}
  edge_settings = { 'label' => edge_label_setting, 'fontsize' => 15 }
  dot_options = { 'edge' => edge_settings }
  dg.write_to_graphic_file('jpg', file_name, dot_options)
end

string_to_check = 'ab'
reg_ex = RegularExpression.new("(a|b)*abb")

time_afn = Benchmark.realtime {
  reg_ex.create_thompson
  reg_ex.check_string(string_to_check)
}
# puts time_afn
graph, names = reg_ex.graph_afn
create_graph(graph, names, 'graph')

time_subset = Benchmark.realtime {
  reg_ex.create_subset
  reg_ex.check_string_afd(string_to_check)
}
puts time_subset
graph, names = reg_ex.graph_subset
create_graph(graph, names, 'graph_subset')

time_direct = Benchmark.realtime {
  reg_ex.create_direct
  reg_ex.check_string_direct(string_to_check)
}
puts time_direct
graph, names = reg_ex.graph_direct
create_graph(graph, names, 'graph_direct')
