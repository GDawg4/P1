class State
  attr_accessor :incoming, :outgoing, :is_initial, :is_final, :id

  def initialize(id, is_initial, is_final)
    @id = id
    @is_initial = is_initial
    @is_final = is_final
  end

  def to_s
    "#{@is_initial ? 'I' : nil} #{@id} #{@is_final ? 'F' : nil}"
  end
end
