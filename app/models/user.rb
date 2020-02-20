class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable


  has_one :user_profile

  accepts_nested_attributes_for :user_profile, reject_if: :all_blank

  #Validações
  validates :first_name, presence: true, length: { minimum: 3 }, on: :update # quando for gravar no banco valide o primeiro nome, se ele existe


  def full_name
    [self.first_name, self.last_name].join(' ') #junta os nomes e coloca um espaço no meio com o join
  end
end
