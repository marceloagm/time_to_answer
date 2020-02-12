class Question < ApplicationRecord
  belongs_to :subject, inverse_of: :questions  # uma questão tem apenas uma subject
  has_many :answers # uma questão possui muitas respostas
  accepts_nested_attributes_for :answers, reject_if: :all_blank, allow_destroy: true #aceitem atributos de outra tabela, podendo criar uma pergunta já com resposta

  # Kaminari
  paginates_per 5

  scope :_search_, ->(page, term){
      Question.includes(:answers)
            .where("lower(description) LIKE ?", "%#{term.downcase}%")
            .page(page) 
  }

  scope :last_questions, ->(page){
    Question.includes(:answers).order('created_at desc').page(page)
  }
end
