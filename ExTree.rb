require_relative 'TreeNode'
class ExTree
  attr_accessor :root, :size

  def initialize()
    @root = nil
    @size = 0
  end

  def print_tree
    puts @root.to_s
  end
end
