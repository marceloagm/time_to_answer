class UsersBackoffice::ApostasController < UsersBackofficeController
    before_action :rodadas  
    before_action :set_user
    before_action :set_equipe 
    before_action :set_equipe_rodada_atual, only: [:create]
    before_action :set_action, only: [:create, :index]
    before_action :set_mercado, only: [:rodada_atual]


    
    def index
        
    end

    def create
        
        
        @aposta = Apostum.new(set_equipe_rodada_atual)
            if @aposta.save
                set_total_rodada(set_equipe_rodada_atual[:rodada])
                flash[:success] = "Você está participando dessa aposta."
                redirect_to "/users_backoffice/#{set_action[:action]}"
            else
                
                redirect_to redirect_to "/users_backoffice/#{set_action[:action]}"
            end 
     
       
    end

    def minhas_apostas        
        
        @apostas = Apostum.includes(:equipe).all.where(equipe_id: set_equipe)
          
    end

    def rodada_atual
        @user_pag = @user["id"]
        @rodada = @rodada_prox0 

        # SDK de Mercado Pago
        require 'mercadopago.rb'

        # Configura credenciais
        $mp = MercadoPago.new('TEST-4686041618151195-042516-bf590b3cbc27e7b61ed4802c2402e3f4-198441614')

        preference_data = {
            "items": [
                {   
                    "id": "1",
                    "title": "Aposta #{@rodada}",
                    "quantity": 1,
                    "unit_price": 10.5,
                    "currency_id": "BRL"
                }
            ],
            "back_urls": {
                "success": "https://www.success.com",
                "failure": "http://www.failure.com",
                "pending": "http://www.pending.com"
            },
            "auto_return": "approved",
            "payment_methods": {
               "excluded_payment_types": [
                    {
                        "id": "ticket"
                    }
                ],
                "installments": 1
            },
            "notification_url": "https://www.your-site.com/ipn",
            "external_reference": "2",

        }

        @preference = $mp.create_preference(preference_data)
        
        # Este valor substituirá a string "<%= @preference_id %>" no seu HTML
        @preference_id = @preference["response"]["id"]

        # buscar pagamento
        #@filters = Hash["external_reference"=> "reference_1234"]
        filters = {
            external_reference: "1",
           # description: "testCreat",
           status:"approved"
          }

        @searchResult = $mp.search_payment(filters,0,1000)

        @total_pag = @searchResult["response"]["paging"]["total"]


        unless @mercado == 1
            redirect_to users_backoffice_welcome_index_path #redirect para tela de resultados dessa aposta
        end  

        @rodada = @rodada_prox0 
        @apostas = Apostum.includes(:equipe).all.where(rodada: @rodada)
        @total_aposta = ApostaStatistic.all.where(rodada: @rodada_prox0)
         
        @equipes_total = Equipe.all.where(user_id: @user)
                
        @apostador = Apostum.includes(:equipe).all.where(rodada: @rodada, equipe_id: @equipes_total)
        @total_time_aposta = @apostador.length
        # descobre quais equipes do usuario já está na aposta
        x = 0  
        @equipes_aposta = Array.new
        while x < @apostador.length 
            @equipes_aposta[x] = @apostador[x]["equipe_id"]
            x = x + 1
        end

        @equipe_resultado = Equipe.all.where(id: @equipes_aposta)

        @equipes_final = @equipes_total - @equipe_resultado
        
        #Quando o pagamento for aprovado ele vai salvar o TIME
        if @total_pag > @total_time_aposta
        
        end
        
    end

    def rodada_prox
        
        @rodada = @rodada_prox1 
        @apostas = Apostum.includes(:equipe).all.where(rodada: @rodada)

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
        
        @rodada = @rodada_prox2
        @apostas = Apostum.includes(:equipe).all.where(rodada: @rodada)

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
       
        @rodada = @rodada_prox3 
        @apostas = Apostum.includes(:equipe).all.where(rodada: @rodada)
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
        @apostador = Apostum.includes(:equipe).all.where(rodada: @rodada)
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

    def set_equipe_rodada_atual
        params.require(:aposta).permit(:equipe_id, :rodada)
    end

    def set_action
    params.require(:aposta).permit(:action)
    
    end
    def set_total_rodada(rodada)
        aposta_statistic = ApostaStatistic.find_or_create_by(rodada: rodada)
        aposta_statistic.total += 1
        aposta_statistic.save
    end

end
