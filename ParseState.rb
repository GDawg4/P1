class ParseState
  attr_accessor :name, :children, :first, :function, :firsts_flat

  def initialize(name)
    @name = name
    @children = []
    @first = []
    @action = ''
    @function = ''
  end

  def add_child(child)
    @children << child
  end

  def add_action(action)
    @action = action
  end

  def set_firsts_flat(firsts_flat)
    @@firsts_flat = firsts_flat
  end

  def firsts_flat
    @@firsts_flat
  end

  def add_children(children)
    @children += children
  end

  def print_children(space)
    if @children.empty?
      puts " "*space + "#{@name}\n"
    else
      puts " "*space + "#{@name} #{@first} \n"
      if @children.any?
        @children.each do |child|
          child.print_children(space + 2)
        end
      end
    end
  end

  def child_by_name(name)
    @children.select { |child| child.name == name}
  end

  def drill_down
    if @children.empty?
      @name
    else
      @children.map(&:drill_down)
    end
  end

  def flat_contents
    drill_down.flatten
  end

  def sets
    child_by_name('ScannerSpecification')[0].child_by_name('Sets').map(&:children)[0].map(&:flat_contents)
  end
  
  def keywords
    if child_by_name('ScannerSpecification')[0].child_by_name('Keywords').empty?
      []
    else
      child_by_name('ScannerSpecification')[0].child_by_name('Keywords').map(&:children)[0].map(&:flat_contents)
    end
  end

  def tokens_test
    child_by_name('ScannerSpecification')[0].child_by_name('Tokens').map(&:children)[0].map(&:flat_contents)
  end

  def productions
    child_by_name('ScannerSpecification')[0].child_by_name('Productions').map(&:children)[0]
    # child_by_name('ScannerSpecification')[0].child_by_name('Productions')[0].child_by_name('Production').map{|child| child.child_by_name('ProductionExpression')}
  end

  def create_first
    @children.each(&:create_first)
    if @children.empty?
      @first = [@name]
      @first
    elsif ['Symbol', 'ident', 'string', 'char'].include? @name
      @first = ['Symbol', 'ident'].include?(@name) ? @children[0].first : [@children[0].first[0][1..-2]]
      @first
    elsif @name == 'ProductionFactor'
      if @children.length < 3
        @first = @children[0].first
      elsif @children.length == 3
        @first = @children[1].first
      end
      @first
    elsif @name == 'ProductionTerm'
      i = 0
      final_first = []
      while @children[i].first == [] || (@children[i].children.length == 3 && @children[i].children[0].name == '[')
        if @children[i].children.length == 3 && @children[i].children[0].name == '['
          final_first += @children[i].children[1].first
        end
        i += 1
      end
      final_first += @children[i].first
      @first = final_first
      @first
    elsif @name == 'ProductionExpression'
      i = 2
      list = @children[0].first
      while i < @children.length
        list += @children[i].first
        i += 2
      end
      @first = list
      @first
    end
  end

  def create_function
    @children.each(&:create_function)
    if @children.empty?
      @function = @name
      @function
    elsif @children.length == 1 && @name != "ProductionFactor"
      if @name == "ident"
        @function += /[[:upper:]]/.match(@children[0].function[0]) ? @children[0].function : "consume('#{@children[0].function}')"
      elsif @name == "string"
        @function += "\nconsume(#{@children[0].function})\n"
      elsif @name == "SemAction"
        @function += "\n#{@children[0].function[2..-3].split('╝').join("\n")}\n"
      else
        @function = "#{@children[0].function}"
      end
      @function
    elsif @name == "ProductionFactor"
      if @children.length == 1
        if @children[0].name == 'Symbol' && @children[0].children[0].name == 'ident' && /[[:upper:]]/.match(@children[0].children[0].children[0].name[0])
          @function += "#{@children[0].function}()\n"
        else
          @function += "#{@children[0].function}\n"
        end
        @function
      elsif @children.length == 2
        base = @children[1].function[1..-2]
        split = base.length > 0 ? base.split(',') : []
        if split.length > 0 && split[0].include?('*')
          @function += "#{split[0][1..-1]}="
          split.slice!(0)
        end
        @function += @children[0].function
        @function += "(#{split.join(',')})\n"
        @function
      elsif @children.length == 3
        if @children[0].name == '{'
          @function << "while #{@children[1].first.map{|first| first[0] == '"' ? first : firsts_flat[first] ? firsts_flat[first].flatten : first }.flatten}.include? lookAhead\n"
        end
        if @children[0].name == '['
          @function << "if #{@children[1].first.map{|first| first[0] == '"' ? first : firsts_flat[first] ? firsts_flat[first].flatten : first }.flatten}.include? lookAhead\n"
        end
        @function += @children[1].function
        if ['}', ']'].include? @children[2].name
          @function << "end\n"
        end
        @function
      end
    elsif @name == "ProductionTerm"
      @children.each{|child| @function += child.function}
      @function
    elsif @name == "ProductionExpression"
      i = 0
      if @children.length > 1
        @function += "case lookAhead\n"
        while i < @children.length
          @function += "when '#{@children[i].first.map{|first| first[0] == '"' ? first : firsts_flat[first] ? firsts_flat[first].flatten : first }.flatten.join(',').gsub(',', "','")}'\n"
          @function += "#{@children[i].function}\n"
          i += 2
        end 
        @function += "end\n"
      end
    elsif @name == "Attributes"
      @function += "(#{@children[0].function})fdsa\n"
      @function
    end
  end

  def get_function(name, parameters, return_value)
    "def #{name}(#{parameters})\n#{@function}\n#{return_value}\nend\n\n"
  end

  def to_s
  end

end
