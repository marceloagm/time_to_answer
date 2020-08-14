class AdminsBackoffice::ResultadosController < AdminsBackofficeController
    before_action :set_mercado_rodada
    before_action :set_aposta, only: [:edit]
    def edit
       
    end

    def update
        rodada_antiga = params["apostum"]["rodada_antiga"]
        @aposta = Apostum.find(params_aposta[:id])
        if @aposta.update(params_aposta)
            flash[:success] = "Aposta atualizada com sucesso."
            aposta_statistic = ApostaStatistic.find_or_create_by(rodada: params_aposta[:rodada])
            aposta_statistic.total += 1
            aposta_statistic.save

            aposta_statistic2 = ApostaStatistic.find_or_create_by(rodada: rodada_antiga)
            aposta_statistic2.total -= 1
            aposta_statistic2.save

            redirect_to admins_backoffice_resultados_visualizar_resultados_path(:rodada => rodada_antiga)
          else
            render :edit
          end 
    end

    def visualizar_resultados
        @rodada = params[:rodada].to_i

       # @apostas = Apostum.includes(:equipe).all.where(rodada: rodada).page(params[:page]).per(20)
        @contador = 0
        
        if @mercado == "1" && @rodada == @rodada_atual
            @contador1 = 0
            @apostas = Apostum.includes(:equipe).all.where(rodada: @rodada).page(params[:page]).per(20)
        end


        if @mercado == "1" && @rodada != @rodada_atual
            @contador3 = 0
            @contador4 = 0
            @apostas = Apostum.all.where(rodada: @rodada)
            @equipes_encontrar = SalvarAtletumAnterior.all.where(rodada: @rodada)
            b = 0

            @nome_time_slug = Array.new
            @pontos_time_slug = Array.new
            @time_slug = Array.new
            @time_final = Array.new
            @equipe_id = Array.new
            @aposta_participar = Array.new
            
            
            while b < @apostas.length 

                
                @aposta_participar[b] = @apostas[b]["created_at"]
                @nome_time_slug[b] = @equipes_encontrar[b]["equipe_nome"]
                @pontos_time_slug[b] = @equipes_encontrar[b]["pontos"]
                @time_slug[b] = @equipes_encontrar[b]["slug"]
                @equipe_id[b] = @apostas[b]["equipe_id"]

                @time_final[b] = [@equipe_id[b], @nome_time_slug[b], @aposta_participar[b], @pontos_time_slug[b].to_f ]
                
                b = b + 1
            end
            
            @time_teste = Kaminari.paginate_array(@time_final.sort_by {|h| -h[3]}).page(params[:page]).per(20)
        end


        if @mercado == "2" && @rodada != @rodada_atual
            @contador3 = 0
            @contador4 = 0
            @apostas = Apostum.all.where(rodada: @rodada)
            @equipes_encontrar = SalvarAtletumAnterior.all.where(rodada: @rodada)
            b = 0
            @nome_time_slug = Array.new
            @pontos_time_slug = Array.new
            @time_slug = Array.new
            @time_final = Array.new
            while b < @apostas.length 

                
                @nome_time_slug[b] = @equipes_encontrar[b]["equipe_nome"]
                @pontos_time_slug[b] = @equipes_encontrar[b]["pontos"]
                @time_slug[b] = @equipes_encontrar[b]["slug"]

                @time_final[b] = [@nome_time_slug[b], @pontos_time_slug[b].to_f, @time_slug[b]]
                
                b = b + 1
            end
            
            @time_teste = Kaminari.paginate_array(@time_final.sort_by {|h| -h[1]}).page(params[:page]).per(20)
        
        end


        if @mercado == "2" && @rodada == @rodada_atual

            @contador3 = 0
            @contador4 = 0
    
            @apostas = Apostum.all.where(rodada: @rodada)
    
                          
            b = 0
        
            @time_final = Array.new
            @nome_time_slug = Array.new
            @pontos_time_slug = Array.new
            @time_slug = Array.new

           
            @equipes_encontrar = Parcial.all.where(rodada: @rodada)

            while b < @apostas.length 

                
                @nome_time_slug[b] = @equipes_encontrar[b]["equipe_nome"]
                @pontos_time_slug[b] = @equipes_encontrar[b]["pontos"]
                @time_slug[b] = @equipes_encontrar[b]["slug"]

                @time_final[b] = [@nome_time_slug[b], @pontos_time_slug[b].to_f, @time_slug[b]]
                
                b = b + 1
            end
            
            @time_teste = Kaminari.paginate_array(@time_final.sort_by {|h| -h[1]}).page(params[:page]).per(20)

           
        end
           
                        

         
    end

    private
    def set_mercado_rodada

        buscar_mercado_rodada = SalvarRodadaMercado.all
        @rodada_atual = buscar_mercado_rodada[0]["rodada_atual"].to_i
        @mercado = buscar_mercado_rodada[0]["mercado"]
    
    end
     
end
