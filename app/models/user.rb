class User < ApplicationRecord
  
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  def full_name
    [self.nome, self.sobrenome].join(' ')
  end

  after_create :set_statistic

private

 def set_statistic
    AdminStatistic.set_event(AdminStatistic::EVENTS[:total_users])
 end


end
