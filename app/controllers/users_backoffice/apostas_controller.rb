class UsersBackoffice::ApostasController < UsersBackofficeController
    before_action :rodadas  
    before_action :set_user
    before_action :set_equipe 
    before_action :set_mercado, only: [:rodada_atual]

        
    def minhas_apostas        
        
        @pagamento = StatusPagamento.all.includes(:equipe).all.where(equipe_id: set_equipe).page(params[:page]).per(8)
         
    end

    def rodada_atual
         # SDK de Mercado Pago
         require 'mercadopago.rb'

         # Configura credenciais
         $mp = MercadoPago.new('TEST-4686041618151195-042516-bf590b3cbc27e7b61ed4802c2402e3f4-198441614')

        unless @mercado == 1
            redirect_to users_backoffice_welcome_index_path #redirect para tela de resultados dessa aposta
        end  
                

        @rodada = @rodada_prox0 
        status_pagamento = params["collection_status"]
        id_pagamento = params["collection_id"] 

        unless status_pagamento.blank?
            unless status_pagamento == "null"
                if status_pagamento == "approved"
                    equipe_verificar_salvar = Equipe.all.where(id: params["external_reference"])
                    equipe_nome_salvar = equipe_verificar_salvar[0]["nome_time"]
                    equipe_salvar = Hash["equipe_id"=> params["external_reference"], "rodada"=> @rodada, "equipe_nome"=> equipe_nome_salvar]
                        unless Apostum.exists?(equipe_id: params["external_reference"], rodada: @rodada)
                            @aposta = Apostum.new(equipe_salvar)
                                if @aposta.save
                                    equipe_pagamento_aprovado = Hash["equipe_id"=> params["external_reference"], "rodada"=> @rodada, "status"=> "Aprovado"]
                                    pagamento_aprovado = StatusPagamento.new(equipe_pagamento_aprovado)
                                    pagamento_aprovado.save
                                    set_total_rodada(@rodada)
                                    flash[:success] = "Parabéns! Você está participando dessa aposta."
                                    redirect_to "/users_backoffice/rodada_atual"
                                else
                                    redirect_to "/users_backoffice/rodada_atual"
                                end 
                        else
                            flash[:success] = "Parabéns! Você já está participando dessa aposta."
                            redirect_to "/users_backoffice/rodada_atual"
                        end
                end

                if status_pagamento == "pending" || status_pagamento == "in_process"
                    preapproval = $mp.cancel_payment(id_pagamento)                    
                    flash[:danger] = "Seu pagamento pendente foi cancelado automaticamente, favor tentar novamente."
                    redirect_to "/users_backoffice/rodada_atual"
                end

                if status_pagamento == "rejected"
                    equipe_pagamento_recusado = Hash["equipe_id"=> params["external_reference"], "rodada"=> @rodada, "status"=> "Recusado"]
                    pagamento_recusado = StatusPagamento.new(equipe_pagamento_recusado)
                    
                    pagamento_recusado.save
                    flash[:danger] = "Seu pagamento foi recusado, favor tentar novamente."
                    redirect_to "/users_backoffice/rodada_atual"
                end
            end
        end
        

        @apostas = Apostum.includes(:equipe).all.where(rodada: @rodada).page(params[:page]).per(20)

        #define a numeração das posições        
        @ppp = params["page"].to_i 
        if @ppp == 0
            @contador = 1
        else
            @contador = (params["page"].to_i * 20) - 19
        end
        
        # descobre quais equipes do usuario já está na aposta
        @equipes_total = Equipe.all.where(user_id: @user)

        y = 0  
        @equipes_nome = Array.new
        while y < @equipes_total.length 
            @equipes_nome[y] = @equipes_total[y]["nome_time"]
            y = y + 1
        end
                        
        @apostador = Apostum.includes(:equipe).all.where(rodada: @rodada, equipe_nome: @equipes_nome)
      
        x = 0  
        @equipes_aposta = Array.new
        while x < @apostador.length 
            @equipes_aposta[x] = @apostador[x]["equipe_nome"]
            x = x + 1
        end

        @equipe_resultado = Equipe.all.where(nome_time: @equipes_aposta)

        @equipes_final = @equipes_total - @equipe_resultado

        
        #verificação para a tela JS
        @equipe_verificar = params[:equipe_id]

        #verifica na api o fechamento do mercado para poder bloquear pagamento após esse horário
        dia = 31
        mes = 12
        ano = 2020
        hora = 14 
        hora_final= hora - 1
        minuto = 0
       if dia <= 9
        @hora = "#{ano}-#{mes}-0#{dia}T#{hora_final}:#{minuto}0:00.000-04:00"
        else
        @hora = "#{ano}-#{mes}-#{dia}T#{hora_final}:#{minuto}0:00.000-04:00"   
        end

        #criar a preferencia, que gera o pagamento do mercadopago
       
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
                "success": "http://localhost:3000/users_backoffice/rodada_atual",
                "failure": "http://localhost:3000/users_backoffice/rodada_atual",
                "pending": "http://localhost:3000/users_backoffice/rodada_atual"
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
            
            "external_reference": "#{params[:equipe_id]}",
            "expires": true,
            "expiration_date_from": "2020-05-20T12:00:00.000-04:00",
            "expiration_date_to": "#{@hora}"  # Após descobrir o horario que o mercado vai fechar

            
            
        }
       
        @preference = $mp.create_preference(preference_data)
        #link para poder passar para o botão após escolher o time
        @preference_link = @preference["response"]["sandbox_init_point"] 
    end


    def rodada_prox
        # SDK de Mercado Pago
        require 'mercadopago.rb'

        # Configura credenciais
        $mp = MercadoPago.new('TEST-4686041618151195-042516-bf590b3cbc27e7b61ed4802c2402e3f4-198441614')

        @rodada = @rodada_prox1
        status_pagamento = params["collection_status"]
        id_pagamento = params["collection_id"] 

        unless status_pagamento.blank?
            unless status_pagamento == "null"
                if status_pagamento == "approved"
                    equipe_verificar_salvar = Equipe.all.where(id: params["external_reference"])
                    equipe_nome_salvar = equipe_verificar_salvar[0]["nome_time"]
                    equipe_salvar = Hash["equipe_id"=> params["external_reference"], "rodada"=> @rodada, "equipe_nome"=> equipe_nome_salvar]
                        unless Apostum.exists?(equipe_id: params["external_reference"], rodada: @rodada)
                            @aposta = Apostum.new(equipe_salvar)
                                if @aposta.save
                                    equipe_pagamento_aprovado = Hash["equipe_id"=> params["external_reference"], "rodada"=> @rodada, "status"=> "Aprovado"]
                                    pagamento_aprovado = StatusPagamento.new(equipe_pagamento_aprovado)
                                    pagamento_aprovado.save
                                    set_total_rodada(@rodada)
                                    flash[:success] = "Parabéns! Você está participando dessa aposta."
                                    redirect_to "/users_backoffice/rodada_prox"
                                else
                                    redirect_to "/users_backoffice/rodada_prox"
                                end 
                        else
                            flash[:success] = "Parabéns! Você já está participando dessa aposta."
                            redirect_to "/users_backoffice/rodada_prox"
                        end
                end

                if status_pagamento == "pending" || status_pagamento == "in_process"
                    preapproval = $mp.cancel_payment(id_pagamento)                    
                    flash[:danger] = "Seu pagamento pendente foi cancelado automaticamente, favor tentar novamente."
                    redirect_to "/users_backoffice/rodada_prox"
                end

                if status_pagamento == "rejected"
                    equipe_pagamento_recusado = Hash["equipe_id"=> params["external_reference"], "rodada"=> @rodada, "status"=> "Recusado"]
                    pagamento_recusado = StatusPagamento.new(equipe_pagamento_recusado)
                    
                    pagamento_recusado.save
                    flash[:danger] = "Seu pagamento foi recusado, favor tentar novamente."
                    redirect_to "/users_backoffice/rodada_prox"
                end
            end
        end
                
        
        @apostas = Apostum.includes(:equipe).all.where(rodada: @rodada).page(params[:page]).per(20)

        #define a numeração das posições        
        @ppp = params["page"].to_i 
        if @ppp == 0
            @contador = 1
        else
            @contador = (params["page"].to_i * 20) - 19
        end
        
        # descobre quais equipes do usuario já está na aposta
        @equipes_total = Equipe.all.where(user_id: @user)

        y = 0  
        @equipes_nome = Array.new
        while y < @equipes_total.length 
            @equipes_nome[y] = @equipes_total[y]["nome_time"]
            y = y + 1
        end
                        
        @apostador = Apostum.includes(:equipe).all.where(rodada: @rodada, equipe_nome: @equipes_nome)
      
        x = 0  
        @equipes_aposta = Array.new
        while x < @apostador.length 
            @equipes_aposta[x] = @apostador[x]["equipe_nome"]
            x = x + 1
        end

        @equipe_resultado = Equipe.all.where(nome_time: @equipes_aposta)

        @equipes_final = @equipes_total - @equipe_resultado

        
        #verificação para a tela JS
        @equipe_verificar = params[:equipe_id]

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
                "success": "http://localhost:3000/users_backoffice/rodada_prox",
                "failure": "http://localhost:3000/users_backoffice/rodada_prox",
                "pending": "http://localhost:3000/users_backoffice/rodada_prox"
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
            
            "external_reference": "#{params[:equipe_id]}",
            
            
        }
        @preference = $mp.create_preference(preference_data)
        
        @preference_link = @preference["response"]["sandbox_init_point"] 
        
    end


    def rodada_dprox
        # SDK de Mercado Pago
        require 'mercadopago.rb'

        # Configura credenciais
        $mp = MercadoPago.new('TEST-4686041618151195-042516-bf590b3cbc27e7b61ed4802c2402e3f4-198441614')

        @rodada = @rodada_prox2
        status_pagamento = params["collection_status"]
        id_pagamento = params["collection_id"] 

        unless status_pagamento.blank?
            unless status_pagamento == "null"
                if status_pagamento == "approved"
                    equipe_verificar_salvar = Equipe.all.where(id: params["external_reference"])
                    equipe_nome_salvar = equipe_verificar_salvar[0]["nome_time"]
                    equipe_salvar = Hash["equipe_id"=> params["external_reference"], "rodada"=> @rodada, "equipe_nome"=> equipe_nome_salvar]
                        unless Apostum.exists?(equipe_id: params["external_reference"], rodada: @rodada)
                            @aposta = Apostum.new(equipe_salvar)
                                if @aposta.save
                                    equipe_pagamento_aprovado = Hash["equipe_id"=> params["external_reference"], "rodada"=> @rodada, "status"=> "Aprovado"]
                                    pagamento_aprovado = StatusPagamento.new(equipe_pagamento_aprovado)
                                    pagamento_aprovado.save
                                    set_total_rodada(@rodada)
                                    flash[:success] = "Parabéns! Você está participando dessa aposta."
                                    redirect_to "/users_backoffice/rodada_dprox"
                                else
                                    redirect_to "/users_backoffice/rodada_dprox"
                                end 
                        else
                            flash[:success] = "Parabéns! Você já está participando dessa aposta."
                            redirect_to "/users_backoffice/rodada_dprox"
                        end
                end

                if status_pagamento == "pending" || status_pagamento == "in_process"
                    preapproval = $mp.cancel_payment(id_pagamento)
                    flash[:danger] = "Seu pagamento pendente foi cancelado automaticamente, favor tentar novamente."
                    redirect_to "/users_backoffice/rodada_dprox"
                end

                if status_pagamento == "rejected"
                    equipe_pagamento_recusado = Hash["equipe_id"=> params["external_reference"], "rodada"=> @rodada, "status"=> "Recusado"]
                    pagamento_recusado = StatusPagamento.new(equipe_pagamento_recusado)
                    
                    pagamento_recusado.save
                    flash[:danger] = "Seu pagamento foi recusado, favor tentar novamente."
                    redirect_to "/users_backoffice/rodada_dprox"
                end
            end
        end
        
        @apostas = Apostum.includes(:equipe).all.where(rodada: @rodada).page(params[:page]).per(20)

        #define a numeração das posições        
        @ppp = params["page"].to_i 
        if @ppp == 0
            @contador = 1
        else
            @contador = (params["page"].to_i * 20) - 19
        end
        
        # descobre quais equipes do usuario já está na aposta
        @equipes_total = Equipe.all.where(user_id: @user)

        y = 0  
        @equipes_nome = Array.new
        while y < @equipes_total.length 
            @equipes_nome[y] = @equipes_total[y]["nome_time"]
            y = y + 1
        end
                        
        @apostador = Apostum.includes(:equipe).all.where(rodada: @rodada, equipe_nome: @equipes_nome)
      
        x = 0  
        @equipes_aposta = Array.new
        while x < @apostador.length 
            @equipes_aposta[x] = @apostador[x]["equipe_nome"]
            x = x + 1
        end

        @equipe_resultado = Equipe.all.where(nome_time: @equipes_aposta)

        @equipes_final = @equipes_total - @equipe_resultado

        
        #verificação para a tela JS
        @equipe_verificar = params[:equipe_id]

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
                "success": "http://localhost:3000/users_backoffice/rodada_dprox",
                "failure": "http://localhost:3000/users_backoffice/rodada_dprox",
                "pending": "http://localhost:3000/users_backoffice/rodada_dprox"
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
            
            "external_reference": "#{params[:equipe_id]}",
            
            
        }
        @preference = $mp.create_preference(preference_data)
        
        @preference_link = @preference["response"]["sandbox_init_point"] 
    end
    



    def rodada_ddprox
        # SDK de Mercado Pago
        require 'mercadopago.rb'

        # Configura credenciais
        $mp = MercadoPago.new('TEST-4686041618151195-042516-bf590b3cbc27e7b61ed4802c2402e3f4-198441614')

         @rodada = @rodada_prox3 
         
         status_pagamento = params["collection_status"]
         status_pagamento = params["collection_status"]
        id_pagamento = params["collection_id"] 

        unless status_pagamento.blank?
            unless status_pagamento == "null"
                if status_pagamento == "approved"
                    equipe_verificar_salvar = Equipe.all.where(id: params["external_reference"])
                    equipe_nome_salvar = equipe_verificar_salvar[0]["nome_time"]
                    equipe_salvar = Hash["equipe_id"=> params["external_reference"], "rodada"=> @rodada, "equipe_nome"=> equipe_nome_salvar]
                        unless Apostum.exists?(equipe_id: params["external_reference"], rodada: @rodada)
                            @aposta = Apostum.new(equipe_salvar)
                                 if @aposta.save
                                     equipe_pagamento_aprovado = Hash["equipe_id"=> params["external_reference"], "rodada"=> @rodada, "status"=> "Aprovado"]
                                     pagamento_aprovado = StatusPagamento.new(equipe_pagamento_aprovado)
                                     pagamento_aprovado.save
                                     set_total_rodada(@rodada)
                                     flash[:success] = "Parabéns! Você está participando dessa aposta."
                                     redirect_to "/users_backoffice/rodada_ddprox"
                                 else
                                     redirect_to "/users_backoffice/rodada_ddprox"
                                 end 
                         else
                             flash[:success] = "Parabéns! Você já está participando dessa aposta."
                             redirect_to "/users_backoffice/rodada_ddprox"
                         end
                 end
 
                 if status_pagamento == "pending" || status_pagamento == "in_process"
                     preapproval = $mp.cancel_payment(id_pagamento)
                     flash[:danger] = "Seu pagamento pendente foi cancelado automaticamente, favor tentar novamente."
                     redirect_to "/users_backoffice/rodada_ddprox"
                 end
 
                 if status_pagamento == "rejected"
                     equipe_pagamento_recusado = Hash["equipe_id"=> params["external_reference"], "rodada"=> @rodada, "status"=> "Recusado"]
                     pagamento_recusado = StatusPagamento.new(equipe_pagamento_recusado)
                     
                     pagamento_recusado.save
                     flash[:danger] = "Seu pagamento foi recusado, favor tentar novamente."
                     redirect_to "/users_backoffice/rodada_ddprox"
                 end
             end
         end
        
       
         @apostas = Apostum.includes(:equipe).all.where(rodada: @rodada).page(params[:page]).per(20)

        #define a numeração das posições        
        @ppp = params["page"].to_i 
        if @ppp == 0
            @contador = 1
        else
            @contador = (params["page"].to_i * 20) - 19
        end
        
        # descobre quais equipes do usuario já está na aposta
        @equipes_total = Equipe.all.where(user_id: @user)

        y = 0  
        @equipes_nome = Array.new
        while y < @equipes_total.length 
            @equipes_nome[y] = @equipes_total[y]["nome_time"]
            y = y + 1
        end
                        
        @apostador = Apostum.includes(:equipe).all.where(rodada: @rodada, equipe_nome: @equipes_nome)
      
        x = 0  
        @equipes_aposta = Array.new
        while x < @apostador.length 
            @equipes_aposta[x] = @apostador[x]["equipe_nome"]
            x = x + 1
        end

        @equipe_resultado = Equipe.all.where(nome_time: @equipes_aposta)

        @equipes_final = @equipes_total - @equipe_resultado

        
        #verificação para a tela JS
        @equipe_verificar = params[:equipe_id]
        
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
                "success": "http://localhost:3000/users_backoffice/rodada_ddprox",
                "failure": "http://localhost:3000/users_backoffice/rodada_ddprox",
                "pending": "http://localhost:3000/users_backoffice/rodada_ddprox"
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
            
            "external_reference": "#{params[:equipe_id]}",
            
            
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