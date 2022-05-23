class Descender
  def initialize
    @tokens = [['1', 1], ['+', nil], ['2', 1], ['+', nil], ['3', 1], [';', nil], ['.', nil], ['', 0]]
    @tokens_key = [
      'ident',
      'number'
    ]
    @tokens = @tokens.map {|token| token[1].nil? ? token : [token[0], @tokens_key[token[1]]]}
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

  def Expr
    while ['"-"', 'number', '"("'].include? lookAhead
      Stat()
      consume(';')
    end

    consume('.')
  end

  def Stat
    value = 0
    value = Expression(value)

    puts value
  end

  def Expression(result)
    result1 = result2 = 0
    result1 = Term(result1)
    while ['"+"', '"-"'].include? lookAhead
      case lookAhead
      when '+'

        consume('+')
        result2 = Term(result2)

        result1 += result2

      when '-'

        consume('-')
        result2 = Term(result2)

        result1 -= result2

      end
    end

    result = result1

    result1
  end

  def Term(_result)
    result1 = result2 = 0
    result1 = Factor(result1)
    while ['"*"', '"/"'].include? lookAhead
      case lookAhead
      when '*'

        consume('*')
        result2 = Factor(result2)

        result1 *= result2

      when '/'

        consume('/')
        result2 = Factor(result2)

        result1 /= result2

      end
    end

    result1
  end

  def Factor(result)
    signo = 1

    consume('-')

    signo = -1
    case lookAhead
    when 'number'
      result = Number(result)

    when '('

      consume('(')
      result = Expression(result)

      consume(')')

    end

    result *= signo

    result
  end

  def Number(_result)
    consume('number')
  end
end

desc = Descender.new
desc.Expr()
