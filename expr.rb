require_relative "RegularExpression"
require "rgl/dot"
require "rgl/adjacency"
string_to_check = ''
File.open("text.txt").each_char { |x| string_to_check << x }
reg_ex = RegularExpression.new('<<<0%1%2%3%4%5%6%7%8%9><<0%1%2%3%4%5%6%7%8%9>>:>#>%<<<<+%->>?<0%1%2%3%4%5%6%7%8%9><<0%1%2%3%4%5%6%7%8%9>>:>#>%<<<%
%	% ><<%
%	% >>:>#>%<while#>%<if#>%<<<a%b%c%d%e%f%g%h%i%j%k%l%m%n%o%p%q%r%s%t%u%v%w%x%y%z%A%B%C%D%E%F%G%H%I%J%K%L%M%N%O%P%Q%R%S%T%U%V%W%X%Y%Z><<a%b%c%d%e%f%g%h%i%j%k%l%m%n%o%p%q%r%s%t%u%v%w%x%y%z%A%B%C%D%E%F%G%H%I%J%K%L%M%N%O%P%Q%R%S%T%U%V%W%X%Y%Z>%<0%1%2%3%4%5%6%7%8%9>>:>#>%<<<0%1%2%3%4%5%6%7%8%9%A%B%C%D%E%F><<0%1%2%3%4%5%6%7%8%9%A%B%C%D%E%F>>:<H>>#>')
reg_ex.create_direct
checked = reg_ex.check_string_direct(string_to_check)
puts "Result: #{checked}"
graph, names = reg_ex.graph_direct
create_graph(graph, names, "graph_direct2")
