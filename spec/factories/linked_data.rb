FactoryBot.define do
  factory :linked_datum do
    name "My Realtime Dataset"
    description "This is a description of our dataset!"
    keywords "data, realtime"
    dataset_url "http://portal.chordsrt.com"
    license "CC"
    doi "10.1234/5678/abc-def.123456"
  end
end
