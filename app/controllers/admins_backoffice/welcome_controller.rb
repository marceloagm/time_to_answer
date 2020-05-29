class AdminsBackoffice::WelcomeController < AdminsBackofficeController
  include ActionView::Helpers::NumberHelper
  def index
    @total_equipes = AdminStatistic.find_by_event(AdminStatistic::EVENTS[:total_equipes]).value
    @total_users = AdminStatistic.find_by_event(AdminStatistic::EVENTS[:total_users]).value


    @total_aposta = ApostaStatistic.all

    @total_valores = Array.new


    @contador = 0
    x = 0
    while x <=37
      @total_valores[x] = number_to_currency((15*(@total_aposta[x]["total"]*10).to_f)/100)
      x = x + 1
    end

    end
   

end
