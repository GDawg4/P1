class Descender

	def initialize
		file = File.open('parser_tokens.txt')
		@tokens = file.read.split('☻').map do |token|
		token.split('☺').map.with_index do |s, i|
			s == 'nil' ? nil : i.zero? ? s : s.to_i
			end
		end.reject! { |j| [0].include?(j[1]) }
		file.close
		file = File.open('tokens_list.txt')
		@tokens_key = file.read.split('☺')
		file.close
		@tokens = @tokens.map {|token| token[1].nil? ? token : [token[0], @tokens_key[token[1] - 1]]}
		puts "Tokens #{@tokens}"
	end

	def consume(token)
		return_value = lookAhead == token ? @tokens[0][0] : 0
		@tokens.shift
		return_value
	end
	def lookAhead
		@tokens[0][1].nil? ? @tokens[0][0] : @tokens[0][1]
	end
	def firstToken
		@tokens[0][0]
	end

	def Expr()
while ["-", "number", "decnumber", "("].include? lookAhead
Stat()

consume(";")

while ["white"].include? lookAhead
consume('white')
end
end
while ["white"].include? lookAhead
consume('white')
end

consume(".")



end

	def Stat()

value=0

value=Expression( value)

puts value



end

	def Expression( result)

result1=result2=0

result1=Term( result1)
while ["+", "-"].include? lookAhead
case lookAhead
when '+'

consume("+")

result2=Term( result2)

result1+=result2


when '-'

consume("-")

result2=Term( result2)

result1-=result2


end
end

result=result1


return result1
end

	def Term( result)

result1=result2=0

result1=Factor( result1)
while ["*", "/"].include? lookAhead
case lookAhead
when '*'

consume("*")

result2=Factor( result2)

result1*=result2


when '/'

consume("/")

result2=Factor( result2)

result1/=result2


end
end

result=result1


return result
end

	def Factor( result)

sign=1

if ["-"].include? lookAhead

consume("-")


sign = -1

end
case lookAhead
when 'number','decnumber'
result=Number( result)

when '('

consume("(")

result=Expression( result)

consume(")")


end

result*=sign


return result
end

	def Number( result)

result=firstToken.to_f

case lookAhead
when 'number'
consume('number')

when 'decnumber'
consume('decnumber')

end

return result
end

end
desc = Descender.new
desc.Expr()
