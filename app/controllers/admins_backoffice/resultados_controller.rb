class AdminsBackoffice::ResultadosController < AdminsBackofficeController
    before_action :set_rodada
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
        
        @contador = 0
        @rodada = params[:rodada].to_i

        @apostas = Apostum.includes(:equipe).all.where(rodada: @rodada)
        
        a = 0  
        @equipe_cartola = Array.new
        @equipe_salvar_cartola = Array.new
        @equipe_criado_cartola = Array.new
        while a < @apostas.length 
            @equipe_cartola[a] = @apostas[a]["slug"]
            @equipe_salvar_cartola[a] = @apostas[a]["equipe_id"]
            @equipe_criado_cartola[a] = @apostas[a]["created_at"]
            a = a + 1
        end
            
        
        b = 0
    
        @time_final = Array.new

        while b < @apostas.length 

            url2 = 'https://api.cartolafc.globo.com/time/id/'
            @times_slug = RestClient.get ("#{url2}#{@equipe_cartola[b]}/#{@rodada}")
            @nome_time_slug = JSON.parse(@times_slug.body)["time"]["nome"]
            @pontos_time_slug = JSON.parse(@times_slug.body)["time"]["tipo_estampa_camisa"] # aqui será pontuação, só mudar para pontos
            @time_final[b] = [@equipe_salvar_cartola[b], @nome_time_slug, @equipe_criado_cartola[b] , @pontos_time_slug]
            
            b = b + 1
        end
        
        @time_teste = Kaminari.paginate_array(@time_final.sort_by {|h| -h[3]}).page(params[:page]).per(20)
           
                        

         
    end

    private
    def set_rodada
        @rodada_atual = 38
    end

    def set_aposta        
        @aposta = Apostum.find(params[:id])
    end

    def params_aposta
        params.require(:apostum).permit(:id, :rodada, :nome_time)
     end
     
end
