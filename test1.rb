require_relative "AFD"
require_relative "Symbol"
require_relative "RegularExpression"
require_relative "ExTree"

string_to_check = 'abb'
reg_ex = RegularExpression.new("(a|b)*abb")
reg_ex.create_thompson
reg_ex.check_string(string_to_check)
reg_ex.create_subset
reg_ex.check_string_afd(string_to_check)
# reg_ex.create_direct
# reg_ex.check_string_direct(string_to_check)

# my_stack = []

# my_stack.push(1)
# my_stack.push(2)
# my_stack.push(3)

# puts "#{my_stack}"
# puts my_stack.pop
# puts my_stack.pop
# puts my_stack.pop