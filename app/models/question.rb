class Question < ApplicationRecord
  belongs_to :subject  # uma questão tem apenas uma subject
  has_many :answers # uma questão possui muitas respostas
  accepts_nested_attributes_for :answers #aceitem atributos de outra tabela, podendo criar uma pergunta já com resposta
end
