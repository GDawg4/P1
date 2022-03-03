class Operator
  def initialize(string_representation, precedence = 0)
    @string_representation = string_representation
    @precedence = precedence
  end

  def to_s
    @string_representation.to_s
  end
end
