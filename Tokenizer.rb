require_relative 'RegularExpression'
require 'rgl/adjacency'
require 'rgl/dot'

class Tokenizer
  def initialize(regexs, string_to_check)
    @regexs = regexs
    @string_to_check = string_to_check
    @checkers = @regexs.map do |regex|
      reg_ex = RegularExpression.new(regex)
      reg_ex.create_direct
      reg_ex
    end
  end

  # reg_ex = RegularExpression.new(expression)
  # reg_ex.create_direct
  # graph, names = reg_ex.graph_direct

  def check_single_dfa
    puts "Checked #{@regexs.map{|regex| '(('<<regex<<')#)'}.join('|')}"
  end

  def check_string
    current_string = ''
    current_token = nil
    tokens = []
    @string_to_check.each_char do |char|
      current_string << char
      current_string = current_string[1..-1] if current_string[0] == ' '
      last_match = nil
      @checkers.each_with_index do |checker, i|
        puts "Checking #{current_string}"
        if checker.check_string_direct(current_string)
          last_match = [current_string.dup, i]
          break
        end
      end
      if last_match
        current_token = last_match
      else
        unless current_token.nil?
          tokens << current_token
          current_string = char
        end
        current_token = nil
      end
      last_match = nil
    end
    tokens << current_token
    puts "Tokens: #{tokens}"
    tokens
  end
end
