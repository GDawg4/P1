require_relative "AFD"
require_relative "Symbol"
require_relative "RegularExpression"
require_relative "ExTree"

string_to_check = 'a'
reg_ex = RegularExpression.new("aa?b?")
reg_ex.create_thompson
reg_ex.check_string(string_to_check)
reg_ex.create_subset
reg_ex.check_string_afd(string_to_check)
reg_ex.create_direct
reg_ex.check_string_direct(string_to_check)
