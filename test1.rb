require_relative "AFD"
require_relative "Symbol"
require_relative "RegularExpression"
require_relative "ExTree"

reg_ex = RegularExpression.new("(a|b)*abb")
reg_ex.create_thompson

# my_stack = []

# my_stack.push(1)
# my_stack.push(2)
# my_stack.push(3)

# puts "#{my_stack}"
# puts my_stack.pop
# puts my_stack.pop
# puts my_stack.pop