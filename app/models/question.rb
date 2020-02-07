class Question < ApplicationRecord
  belongs_to :subject, inverse_of: :questions  # uma questão tem apenas uma subject
  has_many :answers # uma questão possui muitas respostas
  accepts_nested_attributes_for :answers, reject_if: :all_blank, allow_destroy: true #aceitem atributos de outra tabela, podendo criar uma pergunta já com resposta

  # Kaminari
  paginates_per 5
end
