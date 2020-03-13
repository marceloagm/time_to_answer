require "net/http"


class TIME_CARTOLA

    attr_reader :logradouro, :bairro, :localidade, :uf
    END_POINT = "https://viacep.com.br/ws/"
    FORMAT = "json"
    
    def initialize(time)
        
        @time_encontrado = encontrar(time) #hash
        preencher_dados(@time_encontrado)
        
    end

    def endereco
        "#{@logradouro} / #{@bairro} / #{@localidade} / #{@uf}"
    
    end
    

    private

    def preencher_dados(time_encontrado)
        
        @logradouro = time_encontrado["logradouro"]
        @bairro = time_encontrado["bairro"]
        @localidade = time_encontrado["localidade"]
        @uf = time_encontrado["uf"]
        
    end



    def encontrar(time)
        ActiveSupport::JSON.decode(
            Net::HTTP.get(
                URI("#{END_POINT}#{time}/#{FORMAT}/")
            )
        )
    end
    
end
