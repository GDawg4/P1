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
File.open("p33.atg").each_char { |x| string_to_check << x }
reg_ex = RegularExpression.new("ßempty#Ô%ßßß\"Ôß0%1%2%3%4%5%6%7%8%9%A%B%C%D%E%F%G%H%I%J%K%L%M%N%O%P%Q%R%S%T%U%V%W%X%Y%Z%Ñ%,% %ñ%a%b%c%d%e%f%g%h%i%j%k%l%m%n%o%p%q%r%s%t%u%v%w%x%y%z%!%$%.%&%'%(%)%*%+%-%/%;%=%[%]%|%{%}%╝%<%>Ôßßß0%1%2%3%4%5%6%7%8%9%A%B%C%D%E%F%G%H%I%J%K%L%M%N%O%P%Q%R%S%T%U%V%W%X%Y%Z%Ñ%,% %ñ%a%b%c%d%e%f%g%h%i%j%k%l%m%n%o%p%q%r%s%t%u%v%w%x%y%z%!%$%.%&%'%(%)%*%+%-%/%;%=%[%]%|%{%}%╝%<%>ÔÔ:Ôß\"ÔÔ#Ô%ßßß'Ôßßß/ÔÔ?ÔßA%B%C%D%E%F%G%H%I%J%K%L%M%N%O%P%Q%R%S%T%U%V%W%X%Y%Z%a%b%c%d%e%f%g%h%i%j%k%l%m%n%o%p%q%r%s%t%u%v%w%x%y%zÔß'ÔÔ#Ô%ßßßCHR(Ôß0%1%2%3%4%5%6%7%8%9Ôßßß0%1%2%3%4%5%6%7%8%9ÔÔ:Ôß)ÔÔ#Ô%ßßßCHR(Ôß0%1%2%3%4%5%6%7%8%9Ôßßß0%1%2%3%4%5%6%7%8%9ÔÔ:Ôß)Ôß..ÔßCHR(Ôß0%1%2%3%4%5%6%7%8%9Ôßßß0%1%2%3%4%5%6%7%8%9ÔÔ:Ôß)ÔÔ#Ô%ßßß0%1%2%3%4%5%6%7%8%9%A%B%C%D%E%F%G%H%I%J%K%L%M%N%O%P%Q%R%S%T%U%V%W%X%Y%Z%Ñ%,% %ñ%a%b%c%d%e%f%g%h%i%j%k%l%m%n%o%p%q%r%s%t%u%v%w%x%y%z%!%$%&%'%*%/%;%╝ÔÔ#Ô%ßßß(.ÔÔ#Ô%ßßß.)ÔÔ#Ô%ßCHARACTERS#Ô%ßKEYWORDS#Ô%ßTOKENS#Ô%ßPRODUCTIONS#Ô%ßCOMPILER#Ô%ßEXCEPT#Ô%ßEND#Ô%ßßßA%B%C%D%E%F%G%H%I%J%K%L%M%N%O%P%Q%R%S%T%U%V%W%X%Y%Z%a%b%c%d%e%f%g%h%i%j%k%l%m%n%o%p%q%r%s%t%u%v%w%x%y%zÔßßßA%B%C%D%E%F%G%H%I%J%K%L%M%N%O%P%Q%R%S%T%U%V%W%X%Y%Z%a%b%c%d%e%f%g%h%i%j%k%l%m%n%o%p%q%r%s%t%u%v%w%x%y%zÔ%ß0%1%2%3%4%5%6%7%8%9ÔÔ:ÔÔ#Ô")
reg_ex.create_direct
checked = reg_ex.check_string_direct(string_to_check)
graph, names = reg_ex.graph_direct
create_graph(graph, names, 'graph_direct_other')
checked.each{|token| puts "#{token}"}
File.open('parser_tokens.txt', 'w') { |f| f.write(checked.map { |token| token.join('☺') }.join('☻')) }
