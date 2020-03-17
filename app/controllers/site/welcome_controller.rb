class Site::WelcomeController < SiteController
  
  def index
    @rodada_atual = 6 #será uma consulta a API

    @rodada_prox0 = @rodada_atual 
    @rodada_prox1 = @rodada_atual + 1
    @rodada_prox2 = @rodada_atual + 2
    @rodada_prox3 = @rodada_atual + 3
end

end
