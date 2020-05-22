class Equipe < ApplicationRecord
  belongs_to :user
  
  accepts_nested_attributes_for :user
  after_create :set_statistic

  private
    def set_statistic
      AdminStatistic.set_event(AdminStatistic::EVENTS[:total_equipes])
    end

end
