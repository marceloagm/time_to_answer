class ParciaisController < ApplicationController
    include ActionView::Helpers::NumberHelper
      
    require 'net/http'
    require 'uri'
    require 'json'
    require 'rest-client'

      
    
      def rodada_atual
    
            resp = RestClient::Request.execute( method: :get, url: "https://api.cartolafc.globo.com/mercado/status", verify_ssl: false)   
            mercado_verificar = JSON.parse(resp.body)["status_mercado"]
            if mercado_verificar == 4
                mercado = 2
            else
                mercado = mercado_verificar
            end

            rodada_atual = JSON.parse(resp.body)["rodada_atual"]

            dia = JSON.parse(resp.body)["fechamento"]["dia"]
            mes = JSON.parse(resp.body)["fechamento"]["mes"]
            ano = JSON.parse(resp.body)["fechamento"]["ano"]
            hora = JSON.parse(resp.body)["fechamento"]["hora"]
            minuto = JSON.parse(resp.body)["fechamento"]["minuto"]
  
            parcial_rodada = SalvarRodadaMercado.find_or_create_by(id: 1)
            parcial_rodada.rodada_atual = rodada_atual
            parcial_rodada.rodada_anterior = rodada_atual - 1
            parcial_rodada.mercado = mercado
            parcial_rodada.dia = dia
            parcial_rodada.mes = mes
            parcial_rodada.hora = hora
            parcial_rodada.minuto = minuto
            parcial_rodada.ano = ano
            parcial_rodada.save
  
    end
  
  
    def salvar_equipe

        buscar_mercado_rodada = SalvarRodadaMercado.all
        rodada_atual = buscar_mercado_rodada[0]["rodada_atual"]
        mercado = buscar_mercado_rodada[0]["mercado"]
        rodada_anterior = buscar_mercado_rodada[0]["rodada_anterior"]
    
        apostas = Apostum.includes(:equipe).all.where(rodada: rodada_atual)
        verificar_equipes = SalvarAtletum.all.where(rodada: rodada_atual)
    
    
        if mercado == "2"
    
            if verificar_equipes.length != apostas.length
                            
                
                b = 0
                atletas = Array.new
                nome_atleta = Array.new
                posicao_atleta = Array.new
                foto_atleta = Array.new
                foto_format = Array.new
                foto_final = Array.new
                foto_atleta_format = Array.new
    
    
                while b < apostas.length
                
                
                times_slug = RestClient::Request.execute( method: :get, url:"https://api.cartolafc.globo.com/time/id/#{apostas[b]["slug"]}/#{rodada_atual}" , verify_ssl: false) 
                equipe_nome = JSON.parse(times_slug.body)["time"]["nome"]
                atleta_verificar = JSON.parse(times_slug.body)["atletas"]  
                a = 0
                
                unless atleta_verificar.blank?
                    mensagem = "1"
                    capitao = JSON.parse(times_slug.body)["capitao_id"]            
                    escudo = JSON.parse(times_slug.body)["time"]["url_escudo_png"]
                    cartoleiro = JSON.parse(times_slug.body)["time"]["nome_cartola"]
                    
                        while a < 12
                        atletas[a] = JSON.parse(times_slug.body)["atletas"][a]["atleta_id"]
                        nome_atleta[a] = JSON.parse(times_slug.body)["atletas"][a]["apelido"]
                        posicao_atleta[a] = JSON.parse(times_slug.body)["atletas"][a]["posicao_id"]
                        
                        foto_atleta[a] = JSON.parse(times_slug.body)["atletas"][a]["foto"]
                        foto_atleta_format[a] = foto_atleta[a].slice! ".png"

                        unless foto_atleta_format[a].blank?
                            foto_format[a] = foto_atleta[a].slice! "FORMATO.png"
                            foto_final[a] = "#{foto_atleta[a]}140x140.png"
                        else
                            foto_format[a] = foto_atleta[a].slice! "FORMATO.jpeg"
                            foto_final[a] = "#{foto_atleta[a]}140x140.jpeg"
                        end
                        
                        a = a + 1
                        end
                else
                        mensagem = "Ops! Esse time não foi escalado para essa rodada."
                        atletas = []
                        nome_atleta = []
                        posicao_atleta = []
                        foto_final = []
                        capitao = []
                        cartoleiro = []
                        escudo = []
                       
                end
    
                    atletas_salvar = SalvarAtletum.find_or_create_by(slug: apostas[b]["slug"], rodada: rodada_atual)
                    atletas_salvar.slug = apostas[b]["slug"]
                    atletas_salvar.rodada = rodada_atual
                    atletas_salvar.atletas = atletas
                    atletas_salvar.capitao = capitao
                    atletas_salvar.nome_atleta = nome_atleta
                    atletas_salvar.posicao_atleta = posicao_atleta
                    atletas_salvar.foto_final = foto_final
                    atletas_salvar.equipe_nome = equipe_nome
                    atletas_salvar.mensagem = mensagem  
                    atletas_salvar.escudo = escudo 
                    atletas_salvar.cartoleiro = cartoleiro  
                    atletas_salvar.save
    
                    atletas.clear
                    nome_atleta.clear
                    posicao_atleta.clear
                    foto_atleta.clear
                    foto_format.clear
                    foto_final.clear
                    foto_atleta_format.clear
                    
                
                b = b + 1
                end
            end
        end 
    
        if mercado == "1"
            
            apostas_anterior = Apostum.includes(:equipe).all.where(rodada: rodada_anterior) 
            atletas_anterior = SalvarAtletumAnterior.all.where(rodada: rodada_anterior)
    
            if apostas_anterior.length != atletas_anterior.length
                
                b = 0
                atletas = Array.new
                nome_atleta = Array.new
                posicao_atleta = Array.new
                foto_atleta = Array.new
                foto_format = Array.new
                foto_final = Array.new
                pontos_atleta = Array.new
                pontos_inter = Array.new
                foto_atleta_format = Array.new
    
        
    
                while b < apostas_anterior.length
                pontos_final = 0
                pontos_time_slug = 0
                
                times_slug = RestClient::Request.execute( method: :get, url:"https://api.cartolafc.globo.com/time/id/#{apostas_anterior[b]["slug"]}/#{rodada_anterior}" , verify_ssl: false)   
                atleta_verificar = JSON.parse(times_slug.body)["atletas"]  
                equipe_nome = JSON.parse(times_slug.body)["time"]["nome"]
                a = 0
                unless atleta_verificar.blank?         
                    mensagem = "1"
                    capitao = JSON.parse(times_slug.body)["capitao_id"]
                    escudo = JSON.parse(times_slug.body)["time"]["url_escudo_png"]
                    cartoleiro = JSON.parse(times_slug.body)["time"]["nome_cartola"]
               
                    while a < 12
                    atletas[a] = JSON.parse(times_slug.body)["atletas"][a]["atleta_id"]
                    nome_atleta[a] = JSON.parse(times_slug.body)["atletas"][a]["apelido"]
                    posicao_atleta[a] = JSON.parse(times_slug.body)["atletas"][a]["posicao_id"]
                    pontos_atleta[a] = JSON.parse(times_slug.body)["atletas"][a]["pontos_num"]   
         
                    if atletas[a] == capitao
                                
                        pontos_inter[a] = 2*pontos_atleta[a]
                      else
                        pontos_inter[a] = pontos_atleta[a]
                      end
                      foto_atleta[a] = JSON.parse(times_slug.body)["atletas"][a]["foto"]
                      foto_atleta_format[a] = foto_atleta[a].slice! ".png"

                      unless foto_atleta_format[a].blank?
                          foto_format[a] = foto_atleta[a].slice! "FORMATO.png"
                          foto_final[a] = "#{foto_atleta[a]}140x140.png"
                      else
                          foto_format[a] = foto_atleta[a].slice! "FORMATO.jpeg"
                          foto_final[a] = "#{foto_atleta[a]}140x140.jpeg"
                      end
    
                    a = a + 1
                    end
                    
                    pontos_final =  pontos_inter.inject(:+)
                   # pontos_time_slug = number_with_precision(pontos_final, precision: 2, separator: '.')
                else
                    mensagem = "Ops! Esse time não foi escalado para essa rodada."
                    atletas = []
                    nome_atleta = []
                    posicao_atleta = []
                    foto_final = []
                    capitao = []
                    cartoleiro = []
                    escudo = []
                    pontos_final = 0
                    pontos_inter = []
                end
    
                    atletas_salvar = SalvarAtletumAnterior.find_or_create_by(slug: apostas_anterior[b]["slug"], rodada: rodada_anterior)
                    atletas_salvar.slug = apostas_anterior[b]["slug"]
                    atletas_salvar.rodada = rodada_anterior
                    atletas_salvar.pontos = pontos_final
                    atletas_salvar.pontos_atleta = pontos_inter
                    atletas_salvar.atletas = atletas
                    atletas_salvar.capitao = capitao
                    atletas_salvar.nome_atleta = nome_atleta
                    atletas_salvar.posicao_atleta = posicao_atleta
                    atletas_salvar.foto_final = foto_final
                    atletas_salvar.equipe_nome = equipe_nome
                    atletas_salvar.mensagem = mensagem
                    atletas_salvar.escudo = escudo
                    atletas_salvar.cartoleiro = cartoleiro
                    atletas_salvar.save
    
                    atletas.clear
                    nome_atleta.clear
                    posicao_atleta.clear
                    pontos_atleta.clear
                    pontos_inter.clear
                    foto_atleta.clear
                    foto_format.clear
                    foto_final.clear
                    foto_atleta_format.clear
                    
                
                b = b + 1
                end
            
            
            end
            
        end
    
    end
    
    
    
    
    def salvar_atletas_pontuados
    
        buscar_mercado_rodada = SalvarRodadaMercado.all
        rodada_atual = buscar_mercado_rodada[0]["rodada_atual"]
        mercado = buscar_mercado_rodada[0]["mercado"]
    
        if mercado == "2" 
    
            response3 = RestClient::Request.execute( method: :get, url: 'https://api.cartolafc.globo.com/atletas/pontuados', verify_ssl: false)   
            atletas = JSON.parse(response3.body)["atletas"]
            
    
            atletas_parcial = AtletaPontuado.find_or_create_by(rodada: rodada_atual)
            atletas_parcial.rodada = rodada_atual
            atletas_parcial.atletas = atletas
            atletas_parcial.save
        else
            atletas_verificar = AtletaPontuado.all
            
            if atletas_verificar != []
                ActiveRecord::Base.connection.execute("TRUNCATE atleta_pontuados")
            end
        end
    end
    
    
    
    def parciais
          
        buscar_mercado_rodada = SalvarRodadaMercado.all
        rodada_atual = buscar_mercado_rodada[0]["rodada_atual"]
        mercado = buscar_mercado_rodada[0]["mercado"]
            
        apostas = Apostum.includes(:equipe).all.where(rodada: rodada_atual)
       
        
        if mercado == "2" 
           
            b = 0  
            atletas = Array.new
            nome_atleta = Array.new
            posicao_atleta = Array.new
            foto_atleta = Array.new
            foto_format = Array.new
            foto_final = Array.new
            pontos_atleta = Array.new
            pontos_inter = Array.new
            atletas_equipes = Array.new
            atletas_encontrados = Array.new
            result_atleta_nome = Array.new        
            atletas_nome_final = Array.new
            result_id_nome = Array.new        
            atletas_id_final = Array.new
            result_posicao_nome = Array.new         
            atletas_posicao_final =  Array.new
            result_foto_pontos = Array.new       
            atletas_foto_final =  Array.new
            pontuacaoAtleta = Array.new
            pontuacaoAtletaFinal = Array.new
            atleta_verificar = Array.new
            
            atletas_buscar = AtletaPontuado.all.where(rodada: rodada_atual)
            result_atleta = atletas_buscar[0]["atletas"].gsub('\"', '"')        
            atletas_pontos =  eval(result_atleta)
    
            
            while b < apostas.length 
    
                a = 0                    
                pontos_time_slug = 0
                pontos_final = 0
                
                atletas_encontrados[b] = SalvarAtletum.all.where(rodada: rodada_atual, slug: apostas[b]["slug"])
                atleta_verificar[b] = atletas_encontrados[b][0]["mensagem"]
                equipe_nome = atletas_encontrados[b][0]["equipe_nome"]
                escudo = atletas_encontrados[b][0]["escudo"]
                cartoleiro = atletas_encontrados[b][0]["cartoleiro"]
    
                if atleta_verificar[b] == "1"
                    mensagem = "1"
                    result_atleta_nome[b] = atletas_encontrados[b][0]["nome_atleta"].gsub('\"', '"')         
                    atletas_nome_final[b] =  eval(result_atleta_nome[b])
    
                    result_id_nome[b] = atletas_encontrados[b][0]["atletas"].gsub('\"', '"')         
                    atletas_id_final[b] =  eval(result_id_nome[b])
    
                    result_posicao_nome[b] = atletas_encontrados[b][0]["posicao_atleta"].gsub('\"', '"')         
                    atletas_posicao_final[b] =  eval(result_posicao_nome[b])
    
                                    
                    result_foto_pontos[b] = atletas_encontrados[b][0]["foto_final"].gsub('\"', '"')         
                    atletas_foto_final[b] =  eval(result_foto_pontos[b])
    
                    capitao = atletas_encontrados[b][0]["capitao"]
                    
                    
                    
                        
                        while a < 12
                                nome_atleta[a] = atletas_nome_final[b][a]
                                posicao_atleta[a] = atletas_posicao_final[b][a]
                                foto_final[a] = atletas_foto_final[b][a]
                                atletas[a] = atletas_id_final[b][a]
                                                                    
                
                                unless atletas_pontos["#{atletas_id_final[b][a]}"].blank?
                                pontuacaoAtleta[a] = atletas_pontos["#{atletas_id_final[b][a]}"]["pontuacao"]
                                else
                                pontuacaoAtleta[a] = 0
                                end
                    
                                if atletas[a].to_i == capitao.to_i
                                            
                                    pontuacaoAtletaFinal[a] = 2*pontuacaoAtleta[a]
                                else
                                    pontuacaoAtletaFinal[a] = pontuacaoAtleta[a]
                                end
                                
                                pontos_inter[a] = pontuacaoAtletaFinal[a].to_f                    
                            a = a + 1
                        end
    
                        pontos_final =  pontos_inter.inject(:+)
    
                    else
                        mensagem = "Ops! Esse time não foi escalado para essa rodada."
                        pontos_final = 0
                        pontos_inter = []
                        atletas = []
                        capitao = []
                        escudo = []
                        cartoleiro = []
                        nome_atleta = []
                        posicao_atleta = []
                        posicao_atleta = []
                        foto_final = []
    
                    end                                    
    
    
                    parcial_pontos = Parcial.find_or_create_by(slug: apostas[b]["slug"], rodada: rodada_atual)                                       
                    parcial_pontos.slug = apostas[b]["slug"]
                    parcial_pontos.rodada = rodada_atual
                    parcial_pontos.pontos = pontos_final
                    parcial_pontos.pontos_atleta = pontos_inter
                    parcial_pontos.atletas = atletas
                    parcial_pontos.capitao = capitao
                    parcial_pontos.nome_atleta = nome_atleta
                    parcial_pontos.posicao_atleta = posicao_atleta
                    parcial_pontos.foto_final = foto_final
                    parcial_pontos.equipe_nome = equipe_nome
                    parcial_pontos.mensagem = mensagem
                    parcial_pontos.escudo = escudo
                    parcial_pontos.cartoleiro = cartoleiro
                    parcial_pontos.save
    
    
                    atletas.clear
                    nome_atleta.clear
                    posicao_atleta.clear
                    pontos_atleta.clear
                    pontos_inter.clear
                    foto_atleta.clear
                    foto_format.clear
                    foto_final.clear
                    
                    
    
                    b = b + 1                             
            end
    
            
    
        else
            parcial_verificar = Parcial.all
            
            if parcial_verificar != []
                ActiveRecord::Base.connection.execute("TRUNCATE parcials")
            end
        end
      
    
    end
end

