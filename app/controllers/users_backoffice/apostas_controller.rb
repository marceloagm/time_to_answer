class UsersBackoffice::ApostasController < UsersBackofficeController
    before_action :rodadas  
    before_action :set_user
    before_action :set_equipe 
    before_action :set_preference, only: [:rodada_atual, :rodada_prox, :rodada_dprox, :rodada_ddprox] 
    before_action :set_mercado, only: [:rodada_atual]

    
    def create
        action_salvar = params["pagina"]
        status_pagamento = params["payment_status"]
        equipe_salvar = Hash["equipe_id"=> params["equipe_id"], "rodada"=> params["rodada"]]
        rodada_salvar = params["rodada"]

        
        if status_pagamento == "approved"
            equipe_pagamento_aprovado = Hash["equipe_id"=> params["equipe_id"], "rodada"=> params["rodada"], "status"=> "Aprovado"]
            pagamento_aprovado = StatusPagamento.new(equipe_pagamento_aprovado)
            pagamento_aprovado.save
            
            @aposta = Apostum.new(equipe_salvar)
                if @aposta.save
                    set_total_rodada(rodada_salvar)
                    flash[:success] = "Você está participando dessa aposta."
                    redirect_to "/users_backoffice/#{action_salvar}"
                else
                    redirect_to "/users_backoffice/#{action_salvar}"
                end 
        else
            equipe_pagamento_recusado = Hash["equipe_id"=> params["equipe_id"], "rodada"=> params["rodada"], "status"=> "Recusado"]
            pagamento_recusado = StatusPagamento.new(equipe_pagamento_recusado)
            
            pagamento_recusado.save
            flash[:danger] = "Seu pagamento foi recusado, favor tentar novamente."
            redirect_to "/users_backoffice/#{action_salvar}"
        end
       
    end

    def minhas_apostas        
        
        @pagamento = StatusPagamento.all.includes(:equipe).all.where(equipe_id: set_equipe).page(params[:page]).per(8)
         
    end

    def rodada_atual
                
        unless @mercado == 1
            redirect_to users_backoffice_welcome_index_path #redirect para tela de resultados dessa aposta
        end  
        
        #Criar a preferencia que é os dados da aposta
        @preference = $mp.create_preference(set_preference)
        
        # Este valor substituirá a string "<%= @preference_id %>" no seu HTML
        @preference_id = @preference["response"]["id"]


        @rodada = @rodada_prox0 
        @apostas = Apostum.includes(:equipe).all.where(rodada: @rodada).page(params[:page]).per(20)

                
        @ppp = params["page"].to_i 
        if @ppp == 0
            @contador = 1
        else
            @contador = (params["page"].to_i * 20) - 19
        end
        
        @equipes_total = Equipe.all.where(user_id: @user)
                
        @apostador = Apostum.includes(:equipe).all.where(rodada: @rodada, equipe_id: @equipes_total)
        # descobre quais equipes do usuario já está na aposta
        x = 0  
        @equipes_aposta = Array.new
        while x < @apostador.length 
            @equipes_aposta[x] = @apostador[x]["equipe_id"]
            x = x + 1
        end

        @equipe_resultado = Equipe.all.where(id: @equipes_aposta)

        @equipes_final = @equipes_total - @equipe_resultado
                        
    end


    def rodada_prox
        @preference = $mp.create_preference(set_preference)
        
        # Este valor substituirá a string "<%= @preference_id %>" no seu HTML
        @preference_id = @preference["response"]["id"]
        
        @rodada = @rodada_prox1 
        @apostas = Apostum.includes(:equipe).all.where(rodada: @rodada).page(params[:page]).per(20)

                
        @ppp = params["page"].to_i 
        if @ppp == 0
            @contador = 1
        else
            @contador = (params["page"].to_i * 20) - 19
        end

        @equipes_total = Equipe.all.where(user_id: @user)
                
        @apostador = Apostum.includes(:equipe).all.where(rodada: @rodada, equipe_id: @equipes_total)

        # descobre quais equipes do usuario já está na aposta
        x = 0  
        @equipes_aposta = Array.new
        while x < @apostador.length 
            @equipes_aposta[x] = @apostador[x]["equipe_id"]
            x = x + 1
        end

        @equipe_resultado = Equipe.all.where(id: @equipes_aposta)

        @equipes_final = @equipes_total - @equipe_resultado
        
    end


    def rodada_dprox
        @preference = $mp.create_preference(set_preference)
        
        # Este valor substituirá a string "<%= @preference_id %>" no seu HTML
        @preference_id = @preference["response"]["id"]

        @rodada = @rodada_prox2
        @apostas = Apostum.includes(:equipe).all.where(rodada: @rodada).page(params[:page]).per(20)

                
        @ppp = params["page"].to_i 
        if @ppp == 0
            @contador = 1
        else
            @contador = (params["page"].to_i * 20) - 19
        end

        @equipes_total = Equipe.all.where(user_id: @user)
                
        @apostador = Apostum.includes(:equipe).all.where(rodada: @rodada, equipe_id: @equipes_total)

        # descobre quais equipes do usuario já está na aposta
        x = 0  
        @equipes_aposta = Array.new
        while x < @apostador.length 
            @equipes_aposta[x] = @apostador[x]["equipe_id"]
            x = x + 1
        end

        @equipe_resultado = Equipe.all.where(id: @equipes_aposta)

        @equipes_final = @equipes_total - @equipe_resultado
    end
    

    def rodada_ddprox
       @preference = $mp.create_preference(set_preference)
        
        # Este valor substituirá a string "<%= @preference_id %>" no seu HTML
        @preference_id = @preference["response"]["id"]
        
        @rodada = @rodada_prox3 

        @apostas = Apostum.includes(:equipe).all.where(rodada: @rodada).page(params[:page]).per(20)

                
        @ppp = params["page"].to_i 
        if @ppp == 0
            @contador = 1
        else
            @contador = (params["page"].to_i * 20) - 19
        end
        @equipes_total = Equipe.all.where(user_id: @user)
                
        @apostador = Apostum.includes(:equipe).all.where(rodada: @rodada, equipe_id: @equipes_total)

        # descobre quais equipes do usuario já está na aposta
        x = 0  
        @equipes_aposta = Array.new
        while x < @apostador.length 
            @equipes_aposta[x] = @apostador[x]["equipe_id"]
            x = x + 1
        end

        @equipe_resultado = Equipe.all.where(id: @equipes_aposta)

        @equipes_final = @equipes_total - @equipe_resultado
    end
    

    private
    def set_mercado
        @mercado = 1
    end
    def set_equipe
        @equipes = Equipe.all.where(user_id: @user)
    end

     def set_preference
        # SDK de Mercado Pago
        require 'mercadopago.rb'

        # Configura credenciais
        $mp = MercadoPago.new('APP_USR-4686041618151195-042516-3596122e2cbb25dc4d3c0c5d3c5cbbc6-198441614')

        preference_data = {
            "items": [
                {   
                    "id": "1",
                    "title": "Pagamento de Aposta",
                    "description": "TESTE",
                    "quantity": 1,
                    "unit_price": 10.5,
                    "currency_id": "BRL"
                }
            ],
            "back_urls": {
                "success": "https://localhost:3000/",
                "failure": "http://www.failure.com",
                "pending": "http://www.pending.com"
            },
            "auto_return": "all",
            "payment_methods": {
                "excluded_payment_methods": [
                    {
                        "id": "bolbradesco"
                    }
                ],
                
               "excluded_payment_types": [
                    {
                        "id": "ticket"
                    }
                ],
                "installments": 1
            },
            
            "external_reference": "2",

        }
    end
    def set_user
        @user = User.find(current_user.id)
        
    end

    def rodadas
        @rodada_atual = 1  #será uma consulta a API em qual rodada está
    
        @rodada_prox0 = @rodada_atual 
        @rodada_prox1 = @rodada_atual + 1
        @rodada_prox2 = @rodada_atual + 2
        @rodada_prox3 = @rodada_atual + 3
    end

    def set_total_rodada(rodada)
        aposta_statistic = ApostaStatistic.find_or_create_by(rodada: rodada)
        aposta_statistic.total += 1
        aposta_statistic.save
    end

end