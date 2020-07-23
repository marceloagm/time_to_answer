class UsersBackoffice::ResultadosController < UsersBackofficeController
    include ActionView::Helpers::NumberHelper
    require 'rest-client'
    require 'json'
    before_action :set_api
    before_action :set_rodada
    before_action :set_mercado

    def index 
            
    end
    def visualizar_resultados
        
        @rodada = params[:rodada].to_i

       # @apostas = Apostum.includes(:equipe).all.where(rodada: rodada).page(params[:page]).per(20)

        @ppp = params["page"].to_i 
        if @ppp == 0
            @contador = 1
        else
            @contador = (params["page"].to_i * 20) - 19
        end

        if @ppp == 0
            @contador2 = 1
        else
            @contador2 = (params["page"].to_i * 20) - 19
        end

        
       

        @total_aposta0 = ApostaStatistic.all.where(rodada: @rodada).first.attributes["total"]
        @valor_total01 = (@total_aposta0*10).to_f
        @valor_total02 = ((@valor_total01*15)/100).to_f
        @valor_total_aposta0 = @valor_total01 - @valor_total02
          

        if @total_aposta0 >= 2 && @total_aposta0 <= 10
            x = 1
            @valor_aposta = Array.new
            @valor_aposta[x] = number_to_currency(@valor_total_aposta0)
        end
        

         #time
          
        if @rodada > @rodada_atual ||  @rodada < 1
            redirect_to users_backoffice_resultados_index_path
        else
            if @mercado == 1 && @rodada == @rodada_atual
                @apostas = Apostum.includes(:equipe).all.where(rodada: @rodada).page(params[:page]).per(20)

            else

                @contador3 = 0
                @contador4 = 0
        
                @apostas = Apostum.includes(:equipe).all.where(rodada: @rodada)
        
                a = 0  
                @equipe_cartola = Array.new
                while a < @apostas.length 
                    @equipe_cartola[a] = @apostas[a]["slug"]
                    a = a + 1
                end
                    
                
                b = 0
            
                @time_final = Array.new
        
                while b < @apostas.length 

                    url2 = 'https://api.cartolafc.globo.com/time/id/'
                    @times_slug = RestClient.get ("#{url2}#{@equipe_cartola[b]}/#{@rodada}")
                    @nome_time_slug = JSON.parse(@times_slug.body)["time"]["nome"]
                    @pontos_time_slug = JSON.parse(@times_slug.body)["time"]["tipo_estampa_camisa"] # aqui será pontuação, só mudar para pontos
                    @time_final[b] = [@nome_time_slug, @pontos_time_slug, @equipe_cartola[b]]
                    
                    b = b + 1
                end
                
                @time_teste = Kaminari.paginate_array(@time_final.sort_by {|h| -h[1]}).page(params[:page]).per(20)
                                
            end
        end


        if @total_aposta0 >= 11 && @total_aposta0 <= 50
                x = 1
                @valor_aposta = Array.new
                while x <= 3

                    if x == 1
                    @valor_aposta[x] = number_to_currency(@valor_total_aposta0 / 2)
                    x= x + 1
                    end

                    if x == 2
                        @valor_aposta[x] = number_to_currency((@valor_total_aposta0*35/100))
                        x= x + 1
                    end

                    if x == 3
                        @valor_aposta[x] = number_to_currency((@valor_total_aposta0*15/100))
                        x= x + 1
                    end                  

                end
        end

        
        if @total_aposta0 >= 51 && @total_aposta0 <= 100
            x = 1
            @valor_aposta = Array.new
            while x <= 9

                if x == 1
                @valor_aposta[x] = number_to_currency(@valor_total_aposta0 / 2)
                x= x + 1
                end

                if x == 2
                    @valor_aposta[x] = number_to_currency((@valor_total_aposta0*25/100))
                    x= x + 1
                end

                if x == 3
                    @valor_aposta[x] = number_to_currency((@valor_total_aposta0*10/100))
                    x= x + 1
                end     

                if x >= 4 && x <=9
                    @valor_aposta[x] = number_to_currency((@valor_total_aposta0*2.5/100))
                    x= x + 1
                end                 

            end
        end

        if @total_aposta0 >= 101 && @total_aposta0 <= 150
            x = 1
            @valor_aposta = Array.new
            while x <= 15

                if x == 1
                @valor_aposta[x] = number_to_currency(@valor_total_aposta0 / 2)
                x= x + 1
                end

                if x == 2
                    @valor_aposta[x] = number_to_currency((@valor_total_aposta0*20/100))
                    x= x + 1
                end

                if x == 3
                    @valor_aposta[x] = number_to_currency((@valor_total_aposta0*7.8/100))
                    x= x + 1
                end     

                if x >= 4 && x <=9
                    @valor_aposta[x] = number_to_currency((@valor_total_aposta0*2.4/100))
                    x= x + 1
                end       

                if x >= 10 && x <= 15
                    @valor_aposta[x] = number_to_currency((@valor_total_aposta0*1.3/100))
                    x= x + 1
                end          

            end
        end


        if @total_aposta0 >= 151
            x = 1
            @valor_aposta = Array.new
            while x <= 20

                if x == 1
                @valor_aposta[x] = number_to_currency(@valor_total_aposta0 / 2)
                x= x + 1
                end

                if x == 2
                    @valor_aposta[x] = number_to_currency((@valor_total_aposta0*16.5/100))
                    x= x + 1
                end

                if x == 3
                    @valor_aposta[x] = number_to_currency((@valor_total_aposta0*7.65/100))
                    x= x + 1
                end     

                if x >= 4 && x <=9
                    @valor_aposta[x] = number_to_currency((@valor_total_aposta0*2.4/100)) 
                    x= x + 1
                end       

                if x >= 10 && x <= 15
                    @valor_aposta[x] = number_to_currency((@valor_total_aposta0*1.2/100))
                    x= x + 1
                end    
                if x >= 16 && x <= 20
                    @valor_aposta[x] = number_to_currency((@valor_total_aposta0*0.85/100))
                    x= x + 1
                end          

            end
        end

        
    end

    private

    def set_api

        url = 'https://api.cartolafc.globo.com/mercado/status'
        @resp = RestClient.get "#{url}"   

    end


    def set_mercado
        @mercado = JSON.parse(@resp.body)["status_mercado"]

    end

    def set_rodada
           
    @rodada_atual = JSON.parse(@resp.body)["rodada_atual"]

    end
end
