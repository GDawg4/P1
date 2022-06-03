class Descender
  def initialize
    file = File.open('parser_tokens.txt')
    @tokens = file.read.split('☻').map do |token|
      token.split('☺').map.with_index do |s, i|
        if s == 'nil'
          nil
        else
          i.zero? ? s : s.to_i
        end
      end
    end.reject! { |j| [0].include?(j[1]) }
    file.close
    file = File.open('tokens_list.txt')
    @tokens_key = file.read.split('☺')
    file.close
    @tokens = @tokens.map { |token| token[1].nil? ? token : [token[0], @tokens_key[token[1] - 1]] }
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

  def MyCOCOR
    compilerName = endName = 0

    consume('COMPILER')

    compilerName = Ident()

    puts compilerName

    Codigo() if ['startcode'].include? lookAhead
    Body()

    consume('END')

    endName = Ident()

    puts endName
  end

  def Body
    Characters()
    Keywords() if ['KEYWORDS'].include? lookAhead
    Tokens()
    Productions()
  end

  def Characters
    charName = 0
    counter = 0

    consume('CHARACTERS')

    puts 'Leyendo Characters'

    while ['ident'].include? lookAhead
      charName = Ident()

      counter += 1
      puts counter
      puts charName

      consume('=')

      CharSet()
      while ['+', '-'].include? lookAhead
        case lookAhead
        when '+'

          consume('+')

          CharSet()

        when '-'

          consume('-')

          CharSet()

        else
          puts " Error at symbol #{firstToken} "
          return 0
        end
      end

      consume('.')

    end
  end

  def Keywords
    keyName = stringValue = 0
    counter = 0

    consume('KEYWORDS')

    puts 'Leyendo Keywords'

    while ['ident'].include? lookAhead
      keyName = Ident()

      counter += 1
      puts counter
      puts keyName

      consume('=')

      stringValue = String()

      consume('.')

    end
  end

  def Tokens
    tokenName = 0
    counter = 0

    consume('TOKENS')

    puts 'Leyendo Tokens'

    while ['ident'].include? lookAhead
      tokenName = Ident()

      counter += 1
      puts counter
      puts tokenName

      consume('=')

      TokenExpr()
      ExceptKeyword() if ['EXCEPT'].include? lookAhead

      consume('.')

    end
  end

  def Productions
    counter = 0

    consume('PRODUCTIONS')

    prodName = 0
    puts 'Leyendo Productions'

    while ['ident'].include? lookAhead
      prodName = Ident()

      counter += 1
      puts counter
      puts prodName

      Atributos() if ['<'].include? lookAhead

      consume('=')

      Codigo() if ['startcode'].include? lookAhead
      ProductionExpr()

      consume('.')

    end
  end

  def ExceptKeyword
    consume('EXCEPT')

    consume('KEYWORDS')
  end

  def ProductionExpr
    ProdTerm()
    while ['|'].include? lookAhead

      consume('|')

      ProdTerm()
    end
  end

  def ProdTerm
    ProdFactor()
    ProdFactor() while ['string', 'char', 'ident', '(', '[', '{'].include? lookAhead
  end

  def ProdFactor
    case lookAhead
    when 'string', 'char', 'ident'
      SymbolProd()

    when '('

      consume('(')

      ProductionExpr()

      consume(')')

    when '['

      consume('[')

      ProductionExpr()

      consume(']')

    when '{'

      consume('{')

      ProductionExpr()

      consume('}')

    else
      puts " Error at symbol #{firstToken} "
      return 0
    end
    Codigo() if ['startcode'].include? lookAhead
  end

  def SymbolProd
    sv = ind = 0

    case lookAhead
    when 'string'
      sv = String()

    when 'char'
      consume('char')

    when 'ident'
      ind = Ident()
      Atributos() if ['<'].include? lookAhead

    else
      puts " Error at symbol #{firstToken} "
      0
    end
  end

  def Codigo
    consume('startcode')
    ANY() while ['ident', 'string', '=', '*', 'nontoken', '+'].include? lookAhead
    consume('endcode')
  end

  def Atributos
    consume('<')

    ANY() while ['ident', 'string', '=', '*', 'nontoken', '+'].include? lookAhead

    consume('>')
  end

  def TokenExpr
    TokenTerm()
    while ['|'].include? lookAhead

      consume('|')

      TokenTerm()
    end
  end

  def TokenTerm
    TokenFactor()
    TokenFactor() while ['string', 'char', 'ident', '(', '[', '{'].include? lookAhead
  end

  def TokenFactor
    case lookAhead
    when 'string', 'char', 'ident'
      SimbolToken()

    when '('

      consume('(')

      TokenExpr()

      consume(')')

    when '['

      consume('[')

      TokenExpr()

      consume(']')

    when '{'

      consume('{')

      TokenExpr()

      consume('}')

    else
      puts " Error at symbol #{firstToken} "
      0
    end
  end

  def SimbolToken
    identName = stringValue = 0

    case lookAhead
    when 'string'
      stringValue = String()

    when 'char'
      consume('char')

    when 'ident'
      identName = Ident()

    else
      puts " Error at symbol #{firstToken} "
      0
    end
  end

  def CharSet
    identName = stringValue = 0

    case lookAhead
    when 'string'
      stringValue = String()

    when 'char', 'charnumber', 'charinterval'
      Char()

    when 'ident', 'string', '=', '*', 'nontoken', '+'

      consume('ANY')

    when 'ident'
      identName = Ident()

    else
      puts " Error at symbol #{firstToken} "
      0
    end
  end

  def Char
    case lookAhead
    when 'char'
      consume('char')

    when 'charnumber'
      consume('charnumber')

    when 'charinterval'
      consume('charinterval')

    else
      puts " Error at symbol #{firstToken} "
      0
    end
  end

  def ANY
    while ['ident', 'string', '=', '*', 'nontoken', '+'].include? lookAhead
      case lookAhead
      when 'ident'
        consume('ident')

      when 'string'
        consume('string')

      when '='

        consume('=')

      when '*'

        consume('*')

      when 'nontoken'
        consume('nontoken')

      when '+'

        consume('+')

      else
        puts " Error at symbol #{firstToken} "
        return 0
      end
    end
  end

  def String
    s = firstToken

    consume('string')

    s
  end

  def Ident
    s = firstToken

    consume('ident')

    s
  end
end
desc = Descender.new
desc.MyCOCOR()
