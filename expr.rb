require_relative "RegularExpression"
require "rgl/dot"
require "rgl/adjacency"
string_to_check = ""
File.open("test.atg").each_char { |x| string_to_check << x }
reg_ex = RegularExpression.new("<empty#>%<<<\"><0%1%2%3%4%5%6%7%8%9%A%B%C%D%E%F%G%H%I%J%K%L%M%N%O%P%Q%R%S%T%U%V%W%X%Y%Z%a%b%c%d%e%f%g%h%i%j%k%l%m%n%o%p%q%r%s%t%u%v%w%x%y%z%!%$%.%&%'%(%)%*%+%,%-%/%=%[%]%|%{%}><<<0%1%2%3%4%5%6%7%8%9%A%B%C%D%E%F%G%H%I%J%K%L%M%N%O%P%Q%R%S%T%U%V%W%X%Y%Z%a%b%c%d%e%f%g%h%i%j%k%l%m%n%o%p%q%r%s%t%u%v%w%x%y%z%!%$%.%&%'%(%)%*%+%,%-%/%=%[%]%|%{%}>>:><\">>#>%<<'<</>?><A%B%C%D%E%F%G%H%I%J%K%L%M%N%Ñ%O%P%Q%R%S%T%U%V%W%X%Y%Z%a%b%c%d%e%f%g%h%i%j%k%l%m%n%ñ%o%p%q%r%s%t%u%v%w%x%y%z>'>#>%<<CHR(<0%1%2%3%4%5%6%7%8%9><<<0%1%2%3%4%5%6%7%8%9>>:>)>#>%<<CHR(<0%1%2%3%4%5%6%7%8%9><<<0%1%2%3%4%5%6%7%8%9>>:>)..CHR(<0%1%2%3%4%5%6%7%8%9><<<0%1%2%3%4%5%6%7%8%9>>:>)>#>%<<<0%1%2%3%4%5%6%7%8%9%A%B%C%D%E%F%G%H%I%J%K%L%M%N%O%P%Q%R%S%T%U%V%W%X%Y%Z%a%b%c%d%e%f%g%h%i%j%k%l%m%n%o%p%q%r%s%t%u%v%w%x%y%z%!%$%&%'%*%,%/>>#>%<<(.>#>%<<.)>#>%<<<A%B%C%D%E%F%G%H%I%J%K%L%M%N%Ñ%O%P%Q%R%S%T%U%V%W%X%Y%Z%a%b%c%d%e%f%g%h%i%j%k%l%m%n%ñ%o%p%q%r%s%t%u%v%w%x%y%z><<<A%B%C%D%E%F%G%H%I%J%K%L%M%N%Ñ%O%P%Q%R%S%T%U%V%W%X%Y%Z%a%b%c%d%e%f%g%h%i%j%k%l%m%n%ñ%o%p%q%r%s%t%u%v%w%x%y%z>%<0%1%2%3%4%5%6%7%8%9>>:>>#>")
reg_ex.create_direct
checked = reg_ex.check_string_direct(string_to_check)
puts "Result: #{checked}"
