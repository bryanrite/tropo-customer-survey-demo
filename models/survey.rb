class Survey < Sequel::Model
  plugin :validation_helpers
  self.raise_on_typecast_failure = false

  one_to_many :questions

  def validate
    super
    validates_presence [:phone_number]
    validates_numeric [:phone_number]
  end

  def to_json
    { id: id, phone_number: phone_number, questions: questions_to_json }
  end

  def questions_to_json
    array = []
    questions.each { |q| array << q.to_json }
    array
  end

end
