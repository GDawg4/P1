class SemanticNode
  attr_accessor :name, :children, :first

  def initialize(name)
    @name = name
    @children = []
    @first = []
  end

  def add_children(children)
    @children += children
  end

end