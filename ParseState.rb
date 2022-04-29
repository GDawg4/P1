class ParseState
  attr_accessor :name, :children

  def initialize(name)
    @name = name
    @children = []
  end

  def add_child(child)
    @children << child
  end

  def add_children(children)
    @children += children
  end

  def print_children(space)
    if @children.empty?
      puts " "*space + "#{@name} \n"
    else
      # puts " "*space + "#{@name} \n"
      @children.each do |child|
        child.print_children(space + 2)
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

  def tokens
    
  end

  def to_s
    "Name: #{@name} children: #{@children.map(&:name)}"
  end

end
