class UsersBackoffice::ApostasController < UsersBackofficeController

    require 'net/http'
    require 'uri'
    require 'json'
    before_action :set_mercado_rodada
    before_action :rodadas  
    before_action :set_user
    before_action :set_equipe 
    before_action :headers, only: [:rodada_atual]

        
    def minhas_apostas        
        
        @pagamento = StatusPagamento.all.includes(:equipe).all.where(equipe_id: set_equipe).page(params[:page]).per(8)
         
    end

    def teste
        @teste = "OI"
    end
    def rodada_atual
        buscar_fechamento = SalvarRodadaMercado.all
      

        #verifica na api o fechamento do mercado para poder bloquear pagamento após esse horário
        dia = buscar_fechamento[0]["dia"].to_i
        mes = buscar_fechamento[0]["mes"].to_i
        ano = buscar_fechamento[0]["ano"].to_i
        hora = buscar_fechamento[0]["hora"].to_i
        minuto = buscar_fechamento[0]["minuto"].to_i

        if minuto >= 0 && minuto <= 9
            minuto_final = "0#{minuto}"
        else
            minuto_final = minuto
        end

        if hora >= 0 && hora <= 9
            hora_final = "0#{hora}"
        else
            hora_final = hora
        end

        if mes >= 1 && mes <= 9
            mes_final = "0#{mes}"
        else
            mes_final = mes
        end

       if dia>=1 && dia <= 9
            @hora = "#{ano}-#{mes}-0#{dia}T#{hora_final}:#{minuto_final}:00.000-03:00"
            @hora_picpay = "#{ano}-#{mes}-0#{dia}T#{hora_final}:#{minuto_final}:00-03:00"
            
        else
            @hora = "#{ano}-#{mes}-#{dia}T#{hora_final}:#{minuto_final}:00.000-03:00"   
            @hora_picpay = "#{ano}-#{mes}-#{dia}T#{hora_final}:#{minuto_final}:00-03:00"  
        end


        rodada_verificar = @rodada_prox0 

        
        @equipe_verificar_picpay  =  params[:equipe_id]


        #PAGAMENTO PICPAY
        unless @equipe_verificar_picpay.blank?
            
            @teste_equipe = rand(10 .. 99)
       
            @teste_verificando = "#{@teste_equipe}ep#{params[:equipe_id]}rda#{rodada_verificar}"

            uri = URI.parse("https://appws.picpay.com/ecommerce/public/payments")
            request = Net::HTTP::Post.new(uri)
            request.content_type = "application/json"
            request["X-Picpay-Token"] = "98de93cc-33f8-4ef3-9b81-36c5b6b78dec"
            request.body = JSON.dump({
            "referenceId" => "#{@teste_verificando}",
            "callbackUrl" => "http://localhost:3000/users_backoffice/rodada_atual",
            "returnUrl" => "http://localhost:3000/users_backoffice/rodada_atual",
            "value" => 1.0,
            "expiresAt" => "#{@hora_picpay}",
            "buyer" => {
                "firstName" => "#{@user.nome}",
                "lastName" => "#{@user.sobrenome}",
                "document" => "123.456.789-10",
                "email" => "#{@user.email}",
                "phone" => "+55 71 988888888"
            }
            })
            
            req_options = {
            use_ssl: uri.scheme == "https",
            }
            
            @response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
            http.request(request)
            end

            @link_pagamento = JSON.parse(@response.body)["paymentUrl"]

            reference_salvar = Hash["reference_picpay"=> @teste_verificando, "equipe_picpay"=> params[:equipe_id], "user_picpay"=> @user.id, "rodada"=> rodada_verificar]
            salvando_reference = VerificarPagamento.new(reference_salvar)
            salvando_reference.save
            
        end
        
        

        @verificar_pagamento_banco = VerificarPagamento.all.where(user_picpay: @user.id, rodada: rodada_verificar)
        
        if @verificar_pagamento_banco != [] && @equipe_verificar_picpay.blank?
            
            id_picpay = @verificar_pagamento_banco[0]["id"] 
            @reference_picpay = @verificar_pagamento_banco[0]["reference_picpay"]  
            equipe_picpay = @verificar_pagamento_banco[0]["equipe_picpay"] 
            user_picpay = @verificar_pagamento_banco[0]["user_picpay"]
            
            uri = URI.parse("https://appws.picpay.com/ecommerce/public/payments/#{@reference_picpay}/status")
            request = Net::HTTP::Get.new(uri)
            request.content_type = "application/json"
            request["X-Picpay-Token"] = "98de93cc-33f8-4ef3-9b81-36c5b6b78dec"

            req_options = {
            use_ssl: uri.scheme == "https",
            }

            @response2 = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
            http.request(request)
            end

            @status = JSON.parse(@response2.body)["status"]
                
                if @status == "completed" || @status == "paid" || @status == "analysis" || @status == "chargeback"
                        equipe_verificar_salvar = Equipe.all.where(id: equipe_picpay)
                        equipe_nome_salvar = equipe_verificar_salvar[0]["nome_time"]
                        equipe_slug_salvar = equipe_verificar_salvar[0]["slug"]
                        equipe_salvar = Hash["equipe_id"=> equipe_picpay, "rodada"=> rodada_verificar, "equipe_nome"=> equipe_nome_salvar, "slug"=> equipe_slug_salvar]
                        unless Apostum.exists?(equipe_id: equipe_picpay, rodada: rodada_verificar)
                                @aposta = Apostum.new(equipe_salvar)
                                    if @aposta.save
                                        equipe_pagamento_aprovado = Hash["equipe_id"=> equipe_picpay, "rodada"=> rodada_verificar, "status"=> "Aprovado"]
                                        pagamento_aprovado = StatusPagamento.new(equipe_pagamento_aprovado)
                                        pagamento_aprovado.save

                                        equipe_pontos = Hash["rodada"=> rodada_verificar, "equipe_nome"=> equipe_nome_salvar, "slug"=> equipe_slug_salvar, "pontos"=> "0"]
                                        equipe_pontos_pagamento = Parcial.new(equipe_pontos)
                                        equipe_pontos_pagamento.save

                                        set_total_rodada(rodada_verificar)
                                        flash[:success] = "Parabéns! Você está participando dessa aposta."
                                        redirect_to "/users_backoffice/rodada_atual"
                                    else
                                        redirect_to "/users_backoffice/rodada_atual"
                                    end 
                        else
                                flash[:success] = "Parabéns! Você já está participando dessa aposta."
                                redirect_to "/users_backoffice/rodada_atual"
                        end
                        
                        excluir_reference = VerificarPagamento.find(id_picpay)
                        excluir_reference.destroy
                end        
                
                if  @status == "expired" || @status == "refunded"
                        equipe_pagamento_recusado = Hash["equipe_id"=> equipe_picpay, "rodada"=> rodada_verificar, "status"=> "Recusado"]
                        pagamento_recusado = StatusPagamento.new(equipe_pagamento_recusado)
                        
                        pagamento_recusado.save
                        flash[:danger] = "Seu pagamento foi recusado ou cancelado, favor tentar novamente."
                        redirect_to "/users_backoffice/rodada_atual"

                        excluir_reference = VerificarPagamento.find(id_picpay)
                        excluir_reference.destroy
                end
                if  @status == "created"
                        excluir_reference = VerificarPagamento.find(id_picpay)
                        excluir_reference.destroy
                end
                if @response2.code == "422"
                     excluir_reference = VerificarPagamento.find(id_picpay)
                     excluir_reference.destroy
                end
               
        end



         # SDK de Mercado Pago
         require 'mercadopago.rb'

         # Configura credenciais
         $mp = MercadoPago.new('TEST-4686041618151195-042516-bf590b3cbc27e7b61ed4802c2402e3f4-198441614')

        #PAGAMENTO MERCADO PAGO
         @equipe_verificar_mp  =  params[:equipe_id]


         unless @equipe_verificar_mp.blank?
            @teste_equipe_mp = rand(10 .. 99)
       
            @teste_verificando_mp = "#{@teste_equipe}ep#{params[:equipe_id]}rda#{rodada_verificar}"

            preference_data = {
                "items": [
                    {   
                        "id": "1",
                        "title": "Pagamento da Liga Rodada #{rodada_verificar}",
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
                
                "external_reference": "#{@teste_verificando_mp}",
                "expires": true,
                "expiration_date_from": "2020-05-20T12:00:00.000-03:00",
                "expiration_date_to": "#{@hora}"  # Após descobrir o horario que o mercado vai fechar
    
                
                
            }
         
          @preference = $mp.create_preference(preference_data)
          #link para poder passar para o botão após escolher o time
          @preference_link = @preference["response"]["sandbox_init_point"] 

          reference_salvar_mp = Hash["reference_mp"=> @teste_verificando_mp, "equipe_mp"=> params[:equipe_id], "user_mp"=> @user.id, "rodada"=> rodada_verificar]
          salvando_reference_mp = VerificarPagamentoMp.new(reference_salvar_mp)
          salvando_reference_mp.save
  
        end


        unless @mercado == "1"
            redirect_to users_backoffice_welcome_index_path #redirect para tela de resultados dessa aposta
        end  
                


        @rodada = @rodada_prox0 
        status_pagamento = params["collection_status"]
        id_pagamento = params["collection_id"] 

        @verificar_pagamento_mp = VerificarPagamentoMp.all.where(user_mp: @user.id, rodada: rodada_verificar)


        if @verificar_pagamento_mp != [] && @equipe_verificar_mp.blank?

            id_mp = @verificar_pagamento_mp[0]["id"] 
            reference_mp = @verificar_pagamento_mp[0]["reference_mp"]  
            equipe_mp = @verificar_pagamento_mp[0]["equipe_mp"] 
            user_mp = @verificar_pagamento_mp[0]["user_mp"]

            if reference_mp == params["external_reference"]
                unless status_pagamento.blank?
                    unless status_pagamento == "null"
                        paymentInfo = $mp.get_payment(id_pagamento) 
                        status_pagamento_mp = paymentInfo["response"]["status"] 

                        if status_pagamento_mp == "approved"
                            equipe_verificar_salvar = Equipe.all.where(id: equipe_mp)
                            equipe_nome_salvar = equipe_verificar_salvar[0]["nome_time"]
                            equipe_slug_salvar = equipe_verificar_salvar[0]["slug"]
                            equipe_salvar = Hash["equipe_id"=> equipe_mp, "rodada"=> @rodada, "equipe_nome"=> equipe_nome_salvar, "slug"=> equipe_slug_salvar]
                            unless Apostum.exists?(equipe_id: equipe_mp, rodada: @rodada)
                                    @aposta = Apostum.new(equipe_salvar)
                                        if @aposta.save
                                            equipe_pagamento_aprovado = Hash["equipe_id"=> equipe_mp, "rodada"=> @rodada, "status"=> "Aprovado"]
                                            pagamento_aprovado = StatusPagamento.new(equipe_pagamento_aprovado)
                                            pagamento_aprovado.save

                                            equipe_pontos = Hash["rodada"=> rodada_verificar, "equipe_nome"=> equipe_nome_salvar, "slug"=> equipe_slug_salvar, "pontos"=> "0"]
                                            equipe_pontos_pagamento = Parcial.new(equipe_pontos)
                                            equipe_pontos_pagamento.save
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

                            excluir_reference_mp = VerificarPagamentoMp.find(id_mp)
                            excluir_reference_mp.destroy
                        end


                        if status_pagamento_mp == "pending" || status_pagamento == "in_process"
                            preapproval = $mp.cancel_payment(id_pagamento)                    
                            flash[:danger] = "Seu pagamento pendente foi cancelado automaticamente, favor tentar novamente."
                            redirect_to "/users_backoffice/rodada_atual"
                            excluir_reference_mp = VerificarPagamentoMp.find(id_mp)
                            excluir_reference_mp.destroy
                        end

                        if status_pagamento_mp == "rejected"
                            equipe_pagamento_recusado = Hash["equipe_id"=> equipe_mp, "rodada"=> @rodada, "status"=> "Recusado"]
                            pagamento_recusado = StatusPagamento.new(equipe_pagamento_recusado)
                            
                            pagamento_recusado.save
                            flash[:danger] = "Seu pagamento foi recusado, favor tentar novamente."
                            redirect_to "/users_backoffice/rodada_atual"
                            excluir_reference_mp = VerificarPagamentoMp.find(id_mp)
                            excluir_reference_mp.destroy
                        end
                    else
                        excluir_reference_mp = VerificarPagamentoMp.find(id_mp)
                        excluir_reference_mp.destroy
                        redirect_to "/users_backoffice/rodada_atual"
                    end
                end

            else
                excluir_reference_mp = VerificarPagamentoMp.find(id_mp)
                excluir_reference_mp.destroy
                redirect_to "/users_backoffice/rodada_atual"
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
        if @equipe_verificar.blank?
            @equipe_verificar_js = 1
        else
            @equipe_verificar_js = 2
        end
       
    end


    def rodada_prox

        rodada_verificar = @rodada_prox1 

        @equipe_verificar_picpay  =  params[:equipe_id]

        #PAGAMENTO PICPAY
        unless @equipe_verificar_picpay.blank?
            
            @teste_equipe = rand(1 .. 99)
       
            @teste_verificando = "#{@teste_equipe}ep#{params[:equipe_id]}rda#{rodada_verificar}"

            uri = URI.parse("https://appws.picpay.com/ecommerce/public/payments")
            request = Net::HTTP::Post.new(uri)
            request.content_type = "application/json"
            request["X-Picpay-Token"] = "98de93cc-33f8-4ef3-9b81-36c5b6b78dec"
            request.body = JSON.dump({
            "referenceId" => "#{@teste_verificando}",
            "callbackUrl" => "http://localhost:3000/users_backoffice/rodada_prox",
            "returnUrl" => "http://localhost:3000/users_backoffice/rodada_prox",
            "value" => 1.0,
            "expiresAt" => "2021-12-31T16:00:00-03:00",
            "buyer" => {
                "firstName" => "#{@user.nome}",
                "lastName" => "#{@user.sobrenome}",
                "document" => "123.456.789-10",
                "email" => "#{@user.email}",
                "phone" => "+55 71 988888888"
            }
            })
            
            req_options = {
            use_ssl: uri.scheme == "https",
            }
            
            @response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
            http.request(request)
            end

            @link_pagamento = JSON.parse(@response.body)["paymentUrl"]

            reference_salvar = Hash["reference_picpay"=> @teste_verificando, "equipe_picpay"=> params[:equipe_id], "user_picpay"=> @user.id, "rodada"=> rodada_verificar]
            salvando_reference = VerificarPagamento.new(reference_salvar)
            salvando_reference.save
            
        end
        
    
        @verificar_pagamento_banco = VerificarPagamento.all.where(user_picpay: @user.id, rodada: rodada_verificar)
        
        if @verificar_pagamento_banco != [] && @equipe_verificar_picpay.blank?
            
            id_picpay = @verificar_pagamento_banco[0]["id"] 
            @reference_picpay = @verificar_pagamento_banco[0]["reference_picpay"]  
            equipe_picpay = @verificar_pagamento_banco[0]["equipe_picpay"] 
            user_picpay = @verificar_pagamento_banco[0]["user_picpay"]
            
            uri = URI.parse("https://appws.picpay.com/ecommerce/public/payments/#{@reference_picpay}/status")
            request = Net::HTTP::Get.new(uri)
            request.content_type = "application/json"
            request["X-Picpay-Token"] = "98de93cc-33f8-4ef3-9b81-36c5b6b78dec"

            req_options = {
            use_ssl: uri.scheme == "https",
            }

            @response2 = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
            http.request(request)
            end

            @status = JSON.parse(@response2.body)["status"]
                
                if @status == "completed" || @status == "paid" || @status == "analysis" || @status == "chargeback"
                        equipe_verificar_salvar = Equipe.all.where(id: equipe_picpay)
                        equipe_nome_salvar = equipe_verificar_salvar[0]["nome_time"]
                        equipe_slug_salvar = equipe_verificar_salvar[0]["slug"]
                        equipe_salvar = Hash["equipe_id"=> equipe_picpay, "rodada"=> rodada_verificar, "equipe_nome"=> equipe_nome_salvar, "slug"=> equipe_slug_salvar]
                        unless Apostum.exists?(equipe_id: equipe_picpay, rodada: rodada_verificar)
                                @aposta = Apostum.new(equipe_salvar)
                                    if @aposta.save
                                        equipe_pagamento_aprovado = Hash["equipe_id"=> equipe_picpay, "rodada"=> rodada_verificar, "status"=> "Aprovado"]
                                        pagamento_aprovado = StatusPagamento.new(equipe_pagamento_aprovado)
                                        pagamento_aprovado.save

                                        equipe_pontos = Hash["rodada"=> rodada_verificar, "equipe_nome"=> equipe_nome_salvar, "slug"=> equipe_slug_salvar, "pontos"=> "0"]
                                        equipe_pontos_pagamento = Parcial.new(equipe_pontos)
                                        equipe_pontos_pagamento.save

                                        set_total_rodada(rodada_verificar)
                                        flash[:success] = "Parabéns! Você está participando dessa aposta."
                                        redirect_to "/users_backoffice/rodada_prox"
                                    else
                                        redirect_to "/users_backoffice/rodada_prox"
                                    end 
                        else
                                flash[:success] = "Parabéns! Você já está participando dessa aposta."
                                redirect_to "/users_backoffice/rodada_prox"
                        end
                        
                        excluir_reference = VerificarPagamento.find(id_picpay)
                        excluir_reference.destroy
                end        
                
                if  @status == "expired" || @status == "refunded"
                        equipe_pagamento_recusado = Hash["equipe_id"=> equipe_picpay, "rodada"=> rodada_verificar, "status"=> "Recusado"]
                        pagamento_recusado = StatusPagamento.new(equipe_pagamento_recusado)
                        
                        pagamento_recusado.save
                        flash[:danger] = "Seu pagamento foi recusado ou cancelado, favor tentar novamente."
                        redirect_to "/users_backoffice/rodada_prox"

                        excluir_reference = VerificarPagamento.find(id_picpay)
                        excluir_reference.destroy
                end

                if  @status == "created"
                        excluir_reference = VerificarPagamento.find(id_picpay)
                        excluir_reference.destroy
                end
                if @response2.code == "422"
                    excluir_reference = VerificarPagamento.find(id_picpay)
                    excluir_reference.destroy
               end
               
        end
               
        

        # SDK de Mercado Pago
        require 'mercadopago.rb'

        # Configura credenciais
        $mp = MercadoPago.new('TEST-4686041618151195-042516-bf590b3cbc27e7b61ed4802c2402e3f4-198441614')

        #PAGAMENTO MERCADO PAGO
        @equipe_verificar_mp  =  params[:equipe_id]

        unless @equipe_verificar_mp.blank?
            @teste_equipe_mp = rand(10 .. 99)
       
            @teste_verificando_mp = "#{@teste_equipe}ep#{params[:equipe_id]}rda#{rodada_verificar}"
       

        preference_data = {
            "items": [
                {   
                    "id": "1",
                    "title": "Pagamento da Liga Rodada #{rodada_verificar}",
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
            
            "external_reference": "#{@teste_verificando_mp}",
            
            
        }
        @preference = $mp.create_preference(preference_data)
        #link para poder passar para o botão após escolher o time
        @preference_link = @preference["response"]["sandbox_init_point"] 

        reference_salvar_mp = Hash["reference_mp"=> @teste_verificando_mp, "equipe_mp"=> params[:equipe_id], "user_mp"=> @user.id, "rodada"=> rodada_verificar]
        salvando_reference_mp = VerificarPagamentoMp.new(reference_salvar_mp)
        salvando_reference_mp.save

      end



        @rodada = @rodada_prox1
        status_pagamento = params["collection_status"]
        id_pagamento = params["collection_id"] 

        @verificar_pagamento_mp = VerificarPagamentoMp.all.where(user_mp: @user.id, rodada: rodada_verificar)

        if @verificar_pagamento_mp != [] && @equipe_verificar_mp.blank?

            id_mp = @verificar_pagamento_mp[0]["id"] 
            reference_mp = @verificar_pagamento_mp[0]["reference_mp"]  
            equipe_mp = @verificar_pagamento_mp[0]["equipe_mp"] 
            user_mp = @verificar_pagamento_mp[0]["user_mp"]

            if reference_mp == params["external_reference"]
                unless status_pagamento.blank?
                    unless status_pagamento == "null"
                    paymentInfo = $mp.get_payment(id_pagamento) 
                    status_pagamento_mp = paymentInfo["response"]["status"] 

                        if status_pagamento_mp == "approved"
                            equipe_verificar_salvar = Equipe.all.where(id: equipe_mp)
                            equipe_nome_salvar = equipe_verificar_salvar[0]["nome_time"]
                            equipe_slug_salvar = equipe_verificar_salvar[0]["slug"]
                            equipe_salvar = Hash["equipe_id"=> equipe_mp, "rodada"=> @rodada, "equipe_nome"=> equipe_nome_salvar, "slug"=> equipe_slug_salvar]
                                unless Apostum.exists?(equipe_id: equipe_mp, rodada: @rodada)
                                    @aposta = Apostum.new(equipe_salvar)
                                        if @aposta.save
                                            equipe_pagamento_aprovado = Hash["equipe_id"=> equipe_mp, "rodada"=> @rodada, "status"=> "Aprovado"]
                                            pagamento_aprovado = StatusPagamento.new(equipe_pagamento_aprovado)
                                            pagamento_aprovado.save

                                            equipe_pontos = Hash["rodada"=> rodada_verificar, "equipe_nome"=> equipe_nome_salvar, "slug"=> equipe_slug_salvar, "pontos"=> "0"]
                                            equipe_pontos_pagamento = Parcial.new(equipe_pontos)
                                            equipe_pontos_pagamento.save

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
                            excluir_reference_mp = VerificarPagamentoMp.find(id_mp)
                            excluir_reference_mp.destroy
                        end

                        if status_pagamento_mp == "pending" || status_pagamento == "in_process"
                            preapproval = $mp.cancel_payment(id_pagamento)                    
                            flash[:danger] = "Seu pagamento pendente foi cancelado automaticamente, favor tentar novamente."
                            redirect_to "/users_backoffice/rodada_prox"
                            excluir_reference_mp = VerificarPagamentoMp.find(id_mp)
                            excluir_reference_mp.destroy
                        end

                        if status_pagamento_mp == "rejected"
                            equipe_pagamento_recusado = Hash["equipe_id"=> equipe_mp, "rodada"=> @rodada, "status"=> "Recusado"]
                            pagamento_recusado = StatusPagamento.new(equipe_pagamento_recusado)
                            
                            pagamento_recusado.save
                            flash[:danger] = "Seu pagamento foi recusado, favor tentar novamente."
                            redirect_to "/users_backoffice/rodada_prox"
                            excluir_reference_mp = VerificarPagamentoMp.find(id_mp)
                            excluir_reference_mp.destroy
                        end
                    else
                        excluir_reference_mp = VerificarPagamentoMp.find(id_mp)
                        excluir_reference_mp.destroy
                        redirect_to "/users_backoffice/rodada_prox"
                    end
                end
            else
                excluir_reference_mp = VerificarPagamentoMp.find(id_mp)
                excluir_reference_mp.destroy
                redirect_to "/users_backoffice/rodada_prox"
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
        if @equipe_verificar.blank?
            @equipe_verificar_js = 1
        else
            @equipe_verificar_js = 2
        end
        
        
        
    end


    def rodada_dprox

        rodada_verificar = @rodada_prox2 

        @equipe_verificar_picpay  =  params[:equipe_id]

        #PAGAMENTO PICPAY
        unless @equipe_verificar_picpay.blank?
            
            @teste_equipe = rand(10 .. 99)
       
            @teste_verificando = "#{@teste_equipe}ep#{params[:equipe_id]}rda#{rodada_verificar}"

            uri = URI.parse("https://appws.picpay.com/ecommerce/public/payments")
            request = Net::HTTP::Post.new(uri)
            request.content_type = "application/json"
            request["X-Picpay-Token"] = "98de93cc-33f8-4ef3-9b81-36c5b6b78dec"
            request.body = JSON.dump({
            "referenceId" => "#{@teste_verificando}",
            "callbackUrl" => "http://localhost:3000/users_backoffice/rodada_dprox",
            "returnUrl" => "http://localhost:3000/users_backoffice/rodada_dprox",
            "value" => 1.0,
            "expiresAt" => "2021-12-31T16:00:00-03:00",
            "buyer" => {
                "firstName" => "#{@user.nome}",
                "lastName" => "#{@user.sobrenome}",
                "document" => "123.456.789-10",
                "email" => "#{@user.email}",
                "phone" => "+55 71 988888888"
            }
            })
            
            req_options = {
            use_ssl: uri.scheme == "https",
            }
            
            @response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
            http.request(request)
            end

            @link_pagamento = JSON.parse(@response.body)["paymentUrl"]

            reference_salvar = Hash["reference_picpay"=> @teste_verificando, "equipe_picpay"=> params[:equipe_id], "user_picpay"=> @user.id, "rodada"=> rodada_verificar]
            salvando_reference = VerificarPagamento.new(reference_salvar)
            salvando_reference.save
            
        end
        
        

        @verificar_pagamento_banco = VerificarPagamento.all.where(user_picpay: @user.id, rodada: rodada_verificar)
        
        if @verificar_pagamento_banco != [] && @equipe_verificar_picpay.blank?
            
            id_picpay = @verificar_pagamento_banco[0]["id"] 
            @reference_picpay = @verificar_pagamento_banco[0]["reference_picpay"]  
            equipe_picpay = @verificar_pagamento_banco[0]["equipe_picpay"] 
            user_picpay = @verificar_pagamento_banco[0]["user_picpay"]
            
            uri = URI.parse("https://appws.picpay.com/ecommerce/public/payments/#{@reference_picpay}/status")
            request = Net::HTTP::Get.new(uri)
            request.content_type = "application/json"
            request["X-Picpay-Token"] = "98de93cc-33f8-4ef3-9b81-36c5b6b78dec"

            req_options = {
            use_ssl: uri.scheme == "https",
            }

            @response2 = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
            http.request(request)
            end

            @status = JSON.parse(@response2.body)["status"]
                
                if @status == "completed" || @status == "paid" || @status == "analysis" || @status == "chargeback"
                        equipe_verificar_salvar = Equipe.all.where(id: equipe_picpay)
                        equipe_nome_salvar = equipe_verificar_salvar[0]["nome_time"]
                        equipe_slug_salvar = equipe_verificar_salvar[0]["slug"]
                        equipe_salvar = Hash["equipe_id"=> equipe_picpay, "rodada"=> rodada_verificar, "equipe_nome"=> equipe_nome_salvar, "slug"=> equipe_slug_salvar]
                        unless Apostum.exists?(equipe_id: equipe_picpay, rodada: rodada_verificar)
                                @aposta = Apostum.new(equipe_salvar)
                                    if @aposta.save
                                        equipe_pagamento_aprovado = Hash["equipe_id"=> equipe_picpay, "rodada"=> rodada_verificar, "status"=> "Aprovado"]
                                        pagamento_aprovado = StatusPagamento.new(equipe_pagamento_aprovado)
                                        pagamento_aprovado.save

                                        equipe_pontos = Hash["rodada"=> rodada_verificar, "equipe_nome"=> equipe_nome_salvar, "slug"=> equipe_slug_salvar, "pontos"=> "0"]
                                        equipe_pontos_pagamento = Parcial.new(equipe_pontos)
                                        equipe_pontos_pagamento.save

                                        set_total_rodada(rodada_verificar)
                                        flash[:success] = "Parabéns! Você está participando dessa aposta."
                                        redirect_to "/users_backoffice/rodada_dprox"
                                    else
                                        redirect_to "/users_backoffice/rodada_dprox"
                                    end 
                        else
                                flash[:success] = "Parabéns! Você já está participando dessa aposta."
                                redirect_to "/users_backoffice/rodada_dprox"
                        end
                        
                        excluir_reference = VerificarPagamento.find(id_picpay)
                        excluir_reference.destroy
                end        
                
                if  @status == "expired" || @status == "refunded"
                        equipe_pagamento_recusado = Hash["equipe_id"=> equipe_picpay, "rodada"=> rodada_verificar, "status"=> "Recusado"]
                        pagamento_recusado = StatusPagamento.new(equipe_pagamento_recusado)
                        
                        pagamento_recusado.save
                        flash[:danger] = "Seu pagamento foi recusado ou cancelado, favor tentar novamente."
                        redirect_to "/users_backoffice/rodada_dprox"

                        excluir_reference = VerificarPagamento.find(id_picpay)
                        excluir_reference.destroy
                end
                if  @status == "created"
                        excluir_reference = VerificarPagamento.find(id_picpay)
                        excluir_reference.destroy
                end
                if @response2.code == "422"
                    excluir_reference = VerificarPagamento.find(id_picpay)
                    excluir_reference.destroy
               end
               
        end
               
        




        # SDK de Mercado Pago
        require 'mercadopago.rb'

        # Configura credenciais
        $mp = MercadoPago.new('TEST-4686041618151195-042516-bf590b3cbc27e7b61ed4802c2402e3f4-198441614')

       
        
        #PAGAMENTO MERCADO PAGO
        @equipe_verificar_mp  =  params[:equipe_id]

        unless @equipe_verificar_mp.blank?
            @teste_equipe_mp = rand(10 .. 99)
       
            @teste_verificando_mp = "#{@teste_equipe}ep#{params[:equipe_id]}rda#{rodada_verificar}"
       

        preference_data = {
            "items": [
                {   
                    "id": "1",
                    "title": "Pagamento da Liga Rodada #{rodada_verificar}",
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
            
            "external_reference": "#{@teste_verificando_mp}",
            
            
        }
        @preference = $mp.create_preference(preference_data)
        #link para poder passar para o botão após escolher o time
        @preference_link = @preference["response"]["sandbox_init_point"] 

        reference_salvar_mp = Hash["reference_mp"=> @teste_verificando_mp, "equipe_mp"=> params[:equipe_id], "user_mp"=> @user.id, "rodada"=> rodada_verificar]
        salvando_reference_mp = VerificarPagamentoMp.new(reference_salvar_mp)
        salvando_reference_mp.save

      end



        @rodada = @rodada_prox2
        status_pagamento = params["collection_status"]
        id_pagamento = params["collection_id"] 

        @verificar_pagamento_mp = VerificarPagamentoMp.all.where(user_mp: @user.id, rodada: rodada_verificar)

        if @verificar_pagamento_mp != [] && @equipe_verificar_mp.blank?

            id_mp = @verificar_pagamento_mp[0]["id"] 
            reference_mp = @verificar_pagamento_mp[0]["reference_mp"]  
            equipe_mp = @verificar_pagamento_mp[0]["equipe_mp"] 
            user_mp = @verificar_pagamento_mp[0]["user_mp"]

            if reference_mp == params["external_reference"]
                unless status_pagamento.blank?
                    unless status_pagamento == "null"
                    paymentInfo = $mp.get_payment(id_pagamento) 
                    status_pagamento_mp = paymentInfo["response"]["status"] 

                        if status_pagamento_mp == "approved"
                            equipe_verificar_salvar = Equipe.all.where(id: equipe_mp)
                            equipe_nome_salvar = equipe_verificar_salvar[0]["nome_time"]
                            equipe_slug_salvar = equipe_verificar_salvar[0]["slug"]
                            equipe_salvar = Hash["equipe_id"=> equipe_mp, "rodada"=> @rodada, "equipe_nome"=> equipe_nome_salvar, "slug"=> equipe_slug_salvar]
                                unless Apostum.exists?(equipe_id: equipe_mp, rodada: @rodada)
                                    @aposta = Apostum.new(equipe_salvar)
                                        if @aposta.save
                                            equipe_pagamento_aprovado = Hash["equipe_id"=> equipe_mp, "rodada"=> @rodada, "status"=> "Aprovado"]
                                            pagamento_aprovado = StatusPagamento.new(equipe_pagamento_aprovado)
                                            pagamento_aprovado.save

                                            equipe_pontos = Hash["rodada"=> rodada_verificar, "equipe_nome"=> equipe_nome_salvar, "slug"=> equipe_slug_salvar, "pontos"=> "0"]
                                            equipe_pontos_pagamento = Parcial.new(equipe_pontos)
                                            equipe_pontos_pagamento.save

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
                            excluir_reference_mp = VerificarPagamentoMp.find(id_mp)
                            excluir_reference_mp.destroy
                        end

                        if status_pagamento_mp == "pending" || status_pagamento == "in_process"
                            preapproval = $mp.cancel_payment(id_pagamento)                    
                            flash[:danger] = "Seu pagamento pendente foi cancelado automaticamente, favor tentar novamente."
                            redirect_to "/users_backoffice/rodada_dprox"
                            excluir_reference_mp = VerificarPagamentoMp.find(id_mp)
                            excluir_reference_mp.destroy
                        end

                        if status_pagamento_mp == "rejected"
                            equipe_pagamento_recusado = Hash["equipe_id"=> equipe_mp, "rodada"=> @rodada, "status"=> "Recusado"]
                            pagamento_recusado = StatusPagamento.new(equipe_pagamento_recusado)
                            
                            pagamento_recusado.save
                            flash[:danger] = "Seu pagamento foi recusado, favor tentar novamente."
                            redirect_to "/users_backoffice/rodada_dprox"
                            excluir_reference_mp = VerificarPagamentoMp.find(id_mp)
                            excluir_reference_mp.destroy
                        end
                    else
                        excluir_reference_mp = VerificarPagamentoMp.find(id_mp)
                        excluir_reference_mp.destroy
                        redirect_to "/users_backoffice/rodada_dprox"
                    end
                end
            else
                excluir_reference_mp = VerificarPagamentoMp.find(id_mp)
                excluir_reference_mp.destroy
                redirect_to "/users_backoffice/rodada_dprox"
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
        if @equipe_verificar.blank?
            @equipe_verificar_js = 1
        else
            @equipe_verificar_js = 2
        end

        
    end
    



    def rodada_ddprox

        rodada_verificar = @rodada_prox3 

        @equipe_verificar_picpay  =  params[:equipe_id]

        #PAGAMENTO PICPAY
        unless @equipe_verificar_picpay.blank?
            
            @teste_equipe = rand(10 .. 99)
       
            @teste_verificando = "#{@teste_equipe}ep#{params[:equipe_id]}rda#{rodada_verificar}"

            uri = URI.parse("https://appws.picpay.com/ecommerce/public/payments")
            request = Net::HTTP::Post.new(uri)
            request.content_type = "application/json"
            request["X-Picpay-Token"] = "98de93cc-33f8-4ef3-9b81-36c5b6b78dec"
            request.body = JSON.dump({
            "referenceId" => "#{@teste_verificando}",
            "callbackUrl" => "http://localhost:3000/users_backoffice/rodada_ddprox",
            "returnUrl" => "http://localhost:3000/users_backoffice/rodada_ddprox",
            "value" => 1.0,
            "expiresAt" => "2021-12-31T16:00:00-03:00",
            "buyer" => {
                "firstName" => "#{@user.nome}",
                "lastName" => "#{@user.sobrenome}",
                "document" => "123.456.789-10",
                "email" => "#{@user.email}",
                "phone" => "+55 71 988888888"
            }
            })
            
            req_options = {
            use_ssl: uri.scheme == "https",
            }
            
            @response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
            http.request(request)
            end

            @link_pagamento = JSON.parse(@response.body)["paymentUrl"]

            reference_salvar = Hash["reference_picpay"=> @teste_verificando, "equipe_picpay"=> params[:equipe_id], "user_picpay"=> @user.id, "rodada"=> rodada_verificar]
            salvando_reference = VerificarPagamento.new(reference_salvar)
            salvando_reference.save
            
        end
        
        

        @verificar_pagamento_banco = VerificarPagamento.all.where(user_picpay: @user.id, rodada: rodada_verificar)
        
        if @verificar_pagamento_banco != [] && @equipe_verificar_picpay.blank?
            
            id_picpay = @verificar_pagamento_banco[0]["id"] 
            @reference_picpay = @verificar_pagamento_banco[0]["reference_picpay"]  
            equipe_picpay = @verificar_pagamento_banco[0]["equipe_picpay"] 
            user_picpay = @verificar_pagamento_banco[0]["user_picpay"]
            
            uri = URI.parse("https://appws.picpay.com/ecommerce/public/payments/#{@reference_picpay}/status")
            request = Net::HTTP::Get.new(uri)
            request.content_type = "application/json"
            request["X-Picpay-Token"] = "98de93cc-33f8-4ef3-9b81-36c5b6b78dec"

            req_options = {
            use_ssl: uri.scheme == "https",
            }

            @response2 = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
            http.request(request)
            end

            @status = JSON.parse(@response2.body)["status"]
                
                if @status == "completed" || @status == "paid" || @status == "analysis" || @status == "chargeback"
                        equipe_verificar_salvar = Equipe.all.where(id: equipe_picpay)
                        equipe_nome_salvar = equipe_verificar_salvar[0]["nome_time"]
                        equipe_slug_salvar = equipe_verificar_salvar[0]["slug"]
                        equipe_salvar = Hash["equipe_id"=> equipe_picpay, "rodada"=> rodada_verificar, "equipe_nome"=> equipe_nome_salvar, "slug"=> equipe_slug_salvar]
                        unless Apostum.exists?(equipe_id: equipe_picpay, rodada: rodada_verificar)
                                @aposta = Apostum.new(equipe_salvar)
                                    if @aposta.save
                                        equipe_pagamento_aprovado = Hash["equipe_id"=> equipe_picpay, "rodada"=> rodada_verificar, "status"=> "Aprovado"]
                                        pagamento_aprovado = StatusPagamento.new(equipe_pagamento_aprovado)
                                        pagamento_aprovado.save

                                        equipe_pontos = Hash["rodada"=> rodada_verificar, "equipe_nome"=> equipe_nome_salvar, "slug"=> equipe_slug_salvar, "pontos"=> "0"]
                                        equipe_pontos_pagamento = Parcial.new(equipe_pontos)
                                        equipe_pontos_pagamento.save
                                            
                                        set_total_rodada(rodada_verificar)
                                        flash[:success] = "Parabéns! Você está participando dessa aposta."
                                        redirect_to "/users_backoffice/rodada_ddprox"
                                    else
                                        redirect_to "/users_backoffice/rodada_ddprox"
                                    end 
                        else
                                flash[:success] = "Parabéns! Você já está participando dessa aposta."
                                redirect_to "/users_backoffice/rodada_ddprox"
                        end
                        
                        excluir_reference = VerificarPagamento.find(id_picpay)
                        excluir_reference.destroy
                end        
                
                if  @status == "expired" || @status == "refunded"
                        equipe_pagamento_recusado = Hash["equipe_id"=> equipe_picpay, "rodada"=> rodada_verificar, "status"=> "Recusado"]
                        pagamento_recusado = StatusPagamento.new(equipe_pagamento_recusado)
                        
                        pagamento_recusado.save
                        flash[:danger] = "Seu pagamento foi recusado ou cancelado, favor tentar novamente."
                        redirect_to "/users_backoffice/rodada_ddprox"

                        excluir_reference = VerificarPagamento.find(id_picpay)
                        excluir_reference.destroy
                end
                if  @status == "created"
                        excluir_reference = VerificarPagamento.find(id_picpay)
                        excluir_reference.destroy
                end
                if @response2.code == "422"
                    excluir_reference = VerificarPagamento.find(id_picpay)
                    excluir_reference.destroy
               end
               
        end
               


        # SDK de Mercado Pago
        require 'mercadopago.rb'

        # Configura credenciais
        $mp = MercadoPago.new('TEST-4686041618151195-042516-bf590b3cbc27e7b61ed4802c2402e3f4-198441614')

        
        #PAGAMENTO MERCADO PAGO
        @equipe_verificar_mp  =  params[:equipe_id]

        unless @equipe_verificar_mp.blank?
            @teste_equipe_mp = rand(10 .. 99)
       
            @teste_verificando_mp = "#{@teste_equipe}ep#{params[:equipe_id]}rda#{rodada_verificar}"
       

        preference_data = {
            "items": [
                {   
                    "id": "1",
                    "title": "Pagamento da Liga Rodada #{rodada_verificar}",
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
            
            "external_reference": "#{@teste_verificando_mp}",
            
            
        }
        @preference = $mp.create_preference(preference_data)
        #link para poder passar para o botão após escolher o time
        @preference_link = @preference["response"]["sandbox_init_point"] 

        reference_salvar_mp = Hash["reference_mp"=> @teste_verificando_mp, "equipe_mp"=> params[:equipe_id], "user_mp"=> @user.id, "rodada"=> rodada_verificar]
        salvando_reference_mp = VerificarPagamentoMp.new(reference_salvar_mp)
        salvando_reference_mp.save

      end



        @rodada = @rodada_prox3
        status_pagamento = params["collection_status"]
        id_pagamento = params["collection_id"] 

        @verificar_pagamento_mp = VerificarPagamentoMp.all.where(user_mp: @user.id, rodada: rodada_verificar)

        if @verificar_pagamento_mp != [] && @equipe_verificar_mp.blank?

            id_mp = @verificar_pagamento_mp[0]["id"] 
            reference_mp = @verificar_pagamento_mp[0]["reference_mp"]  
            equipe_mp = @verificar_pagamento_mp[0]["equipe_mp"] 
            user_mp = @verificar_pagamento_mp[0]["user_mp"]

            if reference_mp == params["external_reference"]
                unless status_pagamento.blank?
                    unless status_pagamento == "null"
                    paymentInfo = $mp.get_payment(id_pagamento) 
                    status_pagamento_mp = paymentInfo["response"]["status"] 

                        if status_pagamento_mp == "approved"
                            equipe_verificar_salvar = Equipe.all.where(id: equipe_mp)
                            equipe_nome_salvar = equipe_verificar_salvar[0]["nome_time"]
                            equipe_slug_salvar = equipe_verificar_salvar[0]["slug"]
                            equipe_salvar = Hash["equipe_id"=> equipe_mp, "rodada"=> @rodada, "equipe_nome"=> equipe_nome_salvar, "slug"=> equipe_slug_salvar]
                                unless Apostum.exists?(equipe_id: equipe_mp, rodada: @rodada)
                                    @aposta = Apostum.new(equipe_salvar)
                                        if @aposta.save
                                            equipe_pagamento_aprovado = Hash["equipe_id"=> equipe_mp, "rodada"=> @rodada, "status"=> "Aprovado"]
                                            pagamento_aprovado = StatusPagamento.new(equipe_pagamento_aprovado)
                                            pagamento_aprovado.save

                                            equipe_pontos = Hash["rodada"=> rodada_verificar, "equipe_nome"=> equipe_nome_salvar, "slug"=> equipe_slug_salvar, "pontos"=> "0"]
                                            equipe_pontos_pagamento = Parcial.new(equipe_pontos)
                                            equipe_pontos_pagamento.save
                                            
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
                            excluir_reference_mp = VerificarPagamentoMp.find(id_mp)
                            excluir_reference_mp.destroy
                        end

                        if status_pagamento_mp == "pending" || status_pagamento == "in_process"
                            preapproval = $mp.cancel_payment(id_pagamento)                    
                            flash[:danger] = "Seu pagamento pendente foi cancelado automaticamente, favor tentar novamente."
                            redirect_to "/users_backoffice/rodada_ddprox"
                            excluir_reference_mp = VerificarPagamentoMp.find(id_mp)
                            excluir_reference_mp.destroy
                        end

                        if status_pagamento_mp == "rejected"
                            equipe_pagamento_recusado = Hash["equipe_id"=> equipe_mp, "rodada"=> @rodada, "status"=> "Recusado"]
                            pagamento_recusado = StatusPagamento.new(equipe_pagamento_recusado)
                            
                            pagamento_recusado.save
                            flash[:danger] = "Seu pagamento foi recusado, favor tentar novamente."
                            redirect_to "/users_backoffice/rodada_ddprox"
                            excluir_reference_mp = VerificarPagamentoMp.find(id_mp)
                            excluir_reference_mp.destroy
                        end
                    else
                        excluir_reference_mp = VerificarPagamentoMp.find(id_mp)
                        excluir_reference_mp.destroy
                        redirect_to "/users_backoffice/rodada_ddprox"
                        
                    end
                end
            else
                excluir_reference_mp = VerificarPagamentoMp.find(id_mp)
                excluir_reference_mp.destroy
                redirect_to "/users_backoffice/rodada_ddprox"
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
         if @equipe_verificar.blank?
             @equipe_verificar_js = 1
         else
             @equipe_verificar_js = 2
         end
       
    end
    


    private

    def set_mercado_rodada

        buscar_mercado_rodada = SalvarRodadaMercado.all
        @mercado = buscar_mercado_rodada[0]["mercado"]

    end
   
    def set_equipe
        @equipes = Equipe.all.where(user_id: @user)
    end

    def set_user
        @user = User.find(current_user.id)
        
    end
    
    def rodadas
        buscar_mercado_rodada = SalvarRodadaMercado.all
        @rodada_atual = buscar_mercado_rodada[0]["rodada_atual"].to_i
    
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