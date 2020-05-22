class AdminsBackoffice::WelcomeController < AdminsBackofficeController
    
  def index
    @total_equipes = AdminStatistic.find_by_event(AdminStatistic::EVENTS[:total_equipes]).value
    @total_users = AdminStatistic.find_by_event(AdminStatistic::EVENTS[:total_users]).value
    end
   
end
