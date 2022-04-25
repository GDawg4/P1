class State
  attr_accessor :is_initial, :is_final, :id

  def initialize(id, is_initial, is_final, token)
    @id = id
    @is_initial = is_initial
    @is_final = is_final
    @token = token
    #token_id = 5
  end

  def to_s
    "#{@is_initial ? 'I' : nil} #{@id} #{@is_final ? token : nil}"
  end
end
