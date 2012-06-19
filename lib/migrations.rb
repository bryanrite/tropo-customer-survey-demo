migration "create the survey table" do
  database.create_table :surveys do
    primary_key :id
    String      :phone_number
  end
end

migration "create the questions table" do
  database.create_table :questions do
    primary_key :id
    String      :value
    foreign_key :survey_id, :surveys, null: false
  end
end

migration "create the responses table" do
  database.create_table :responses do
    primary_key :id
    String      :response_url
    foreign_key :question_id, :questions, null: false
  end
end