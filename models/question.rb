class Question < Sequel::Model
  plugin :validation_helpers
  self.raise_on_typecast_failure = false

  many_to_one :survey

  def to_json
    { value.to_sym => response.nil? ? '' : response }
  end
end