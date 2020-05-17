class UsersBackoffice::ApostasController < UsersBackofficeController
    before_action :rodadas  
    before_action :set_user
    before_action :set_equipe 
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
    def pagamento
    
        
    end
    def escolher_time
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
    
    def minhas_apostas        
        
        @pagamento = StatusPagamento.all.includes(:equipe).all.where(equipe_id: set_equipe).page(params[:page]).per(8)
         
    end

    def rodada_atual
                
        unless @mercado == 1
            redirect_to users_backoffice_welcome_index_path #redirect para tela de resultados dessa aposta
        end  
        


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

        @equipe_verificar = params[:equipe_id]

        dia = 31
        mes = 12
        ano = 2020
        hora = 14 
        hora_final= hora - 1
        minuto = 0
       # "2016-02-28T12:00:00.000-04:00"
        if dia <= 9
        @hora = "#{ano}-#{mes}-0#{dia}T#{hora_final}:#{minuto}0:00.000-04:00"
        else
        @hora = "#{ano}-#{mes}-#{dia}T#{hora_final}:#{minuto}0:00.000-04:00"   
        end
        # SDK de Mercado Pago
        require 'mercadopago.rb'

        # Configura credenciais
        $mp = MercadoPago.new('TEST-4686041618151195-042516-bf590b3cbc27e7b61ed4802c2402e3f4-198441614')

        preference_data = {
            "items": [
                {   
                    "id": "1",
                    "title": "PPP #{params[:equipe_id]}",
                    "description": "TESTE",
                    "quantity": 1,
                    "unit_price": 10.5,
                    "currency_id": "BRL"
                }
            ],
            "back_urls": {
                "success": "http://localhost:3000/users_backoffice/apostas",
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
            
            "external_reference": "#{params[:equipe_id]}#{@rodada}",
            "expires": true,
            "expiration_date_from": "2016-02-01T12:00:00.000-04:00",
            "expiration_date_to": "#{@hora}"  # Após descobrir o horario que o mercado vai fechar

            
            
        }
        @preference = $mp.create_preference(preference_data)
        
        @preference_link = @preference["response"]["sandbox_init_point"] 
    end


    def rodada_prox
        
                
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



        require 'mercadopago.rb'

        # Configura credenciais
        $mp = MercadoPago.new('TEST-4686041618151195-042516-bf590b3cbc27e7b61ed4802c2402e3f4-198441614')

        preference_data = {
            "items": [
                {   
                    "id": "1",
                    "title": "PPP #{params[:equipe_id]}",
                    "description": "TESTE",
                    "quantity": 1,
                    "unit_price": 10.5,
                    "currency_id": "BRL"
                }
            ],
            "back_urls": {
                "success": "http://localhost:3000/users_backoffice/apostas",
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
            
            "external_reference": "#{params[:equipe_id]}#{@rodada}",
            
            
        }
        @preference = $mp.create_preference(preference_data)
        
        @preference_link = @preference["response"]["sandbox_init_point"] 
        @equipe_verificar = params[:equipe_id]
    end


    def rodada_dprox
        

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

        @equipe_verificar = params[:equipe_id]
        require 'mercadopago.rb'

        # Configura credenciais
        $mp = MercadoPago.new('TEST-4686041618151195-042516-bf590b3cbc27e7b61ed4802c2402e3f4-198441614')

        preference_data = {
            "items": [
                {   
                    "id": "1",
                    "title": "PPP #{params[:equipe_id]}",
                    "description": "TESTE",
                    "quantity": 1,
                    "unit_price": 10.5,
                    "currency_id": "BRL"
                }
            ],
            "back_urls": {
                "success": "http://localhost:3000/users_backoffice/apostas",
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
            
            "external_reference": "#{params[:equipe_id]}#{@rodada}",
            
            
        }
        @preference = $mp.create_preference(preference_data)
        
        @preference_link = @preference["response"]["sandbox_init_point"] 
    end
    



    def rodada_ddprox
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

        @equipe_verificar = params[:equipe_id]
        require 'mercadopago.rb'

        # Configura credenciais
        $mp = MercadoPago.new('TEST-4686041618151195-042516-bf590b3cbc27e7b61ed4802c2402e3f4-198441614')

        preference_data = {
            "items": [
                {   
                    "id": "1",
                    "title": "PPP #{params[:equipe_id]}",
                    "description": "TESTE",
                    "quantity": 1,
                    "unit_price": 10.5,
                    "currency_id": "BRL"
                }
            ],
            "back_urls": {
                "success": "http://localhost:3000/users_backoffice/apostas",
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
            
            "external_reference": "#{params[:equipe_id]}#{@rodada}",
            
            
        }
        @preference = $mp.create_preference(preference_data)
        
        @preference_link = @preference["response"]["sandbox_init_point"] 
    end
    


    private
    def set_mercado
        @mercado = 1
    end
   
    def set_equipe
        @equipes = Equipe.all.where(user_id: @user)
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