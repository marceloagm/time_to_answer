class Site::VisualizarTimeController < SiteController
    include ActionView::Helpers::NumberHelper
    require 'rest-client'
    require 'json'
    before_action :set_mercado_rodada
    


    def time 
        @contador = 0
        
            
        @rodada = params["rodada"].to_i
        

        if @rodada > @rodada_atual ||  @rodada < 4
            redirect_to users_backoffice_resultados_index_path
        else 


            if @mercado == "1" && @rodada == @rodada_atual
                #busca time no banco de dados
                time = params["time"]
                @times = Equipe.all.where(id: time)   
                    if @times.blank?
                        redirect_to users_backoffice_resultados_index_path
                    end
            end
           
               
            if @mercado == "1" && @rodada != @rodada_atual
                @contador = 0
                nome_jogador_slug = Array.new
                pontuacaoAtletaFinal = Array.new
                atletas_posicao_final = Array.new
                posicaoAtletaFinal = Array.new
                textCapitaoAtleta = Array.new
                @atleta = Array.new
                
                    atletas_encontrados = SalvarAtletumAnterior.all.where(rodada: @rodada, slug: params["slug"])
                    @atletas_verificar = atletas_encontrados[0]["mensagem"]

                    if @atletas_verificar == "1"
                    
                        
                    
                        result_atleta_nome = atletas_encontrados[0]["nome_atleta"].gsub('\"', '"')         
                        atletas_nome_final =  eval(result_atleta_nome)

                        result_id_nome = atletas_encontrados[0]["atletas"].gsub('\"', '"')         
                        atletas_id_final =  eval(result_id_nome)

                        result_posicao_nome = atletas_encontrados[0]["posicao_atleta"].gsub('\"', '"')         
                        atletas_posicao_final =  eval(result_posicao_nome)

                        result_atleta_pontos = atletas_encontrados[0]["pontos_atleta"].gsub('\"', '"')         
                        atletas_pontos_final =  eval(result_atleta_pontos)
                        
                        result_foto_pontos = atletas_encontrados[0]["foto_final"].gsub('\"', '"')         
                        atletas_foto_final =  eval(result_foto_pontos)

                        capitao = atletas_encontrados[0]["capitao"]
                        @nome_escudo_slug = atletas_encontrados[0]["escudo"]
                        @nome_cartoleiro_slug = atletas_encontrados[0]["cartoleiro"]
                        pontos_inter = atletas_encontrados[0]["pontos"]
                        @pontos = number_with_precision(pontos_inter, precision: 2, separator: '.')

                        @equipe = atletas_encontrados[0]["equipe_nome"]

                    
                     
                        a = 0
                        while a < 12
                            nome_jogador_slug[a] = atletas_nome_final[a]
                            

                            if atletas_posicao_final[a] == 1
                                posicaoAtletaFinal[a] = "Goleiro:"
                            end
                            if atletas_posicao_final[a] == 2
                                posicaoAtletaFinal[a] = "Lateral:"
                            end
                            if atletas_posicao_final[a] == 3
                                posicaoAtletaFinal[a] = "Zagueiro:"
                            end
                            if atletas_posicao_final[a] == 4
                                posicaoAtletaFinal[a] = "Meia:"
                            end
                            if atletas_posicao_final[a] == 5
                                posicaoAtletaFinal[a] = "Atacante:"
                            end
                            if atletas_posicao_final[a] == 6
                                posicaoAtletaFinal[a] = "Técnico:"
                            end


                                if atletas_id_final[a].to_i == capitao.to_i
                                    textCapitaoAtleta[a] = "orangered"
                                    pontuacaoAtletaFinal[a] = atletas_pontos_final[a]
                                else
                                    pontuacaoAtletaFinal[a] = atletas_pontos_final[a]
                                    textCapitaoAtleta[a] = ""
                                end
                                
                        @atleta[a] = [nome_jogador_slug[a],atletas_posicao_final[a],posicaoAtletaFinal[a],number_with_precision(pontuacaoAtletaFinal[a], precision: 2, separator: '.'),textCapitaoAtleta[a],atletas_foto_final[a]]
                        @atleta_final = Kaminari.paginate_array(@atleta.sort_by {|h| h[1]})
                        a = a + 1
                        end
                    else
                        @mensagem = atletas_encontrados[0]["mensagem"]
                        encontrar_escudo = Equipe.all.where(slug: params["slug"])
                        @nome_escudo_slug = encontrar_escudo[0]["escudo"]
                        @nome_cartoleiro_slug = encontrar_escudo[0]["cartoleiro"]
                        @pontos = "0.00"
                    end
                        
                  

               
               end

               if @mercado == "2" && @rodada != @rodada_atual || @mercado == "4" && @rodada != @rodada_atual
                
                @contador = 0
                nome_jogador_slug = Array.new
                pontuacaoAtletaFinal = Array.new
                atletas_posicao_final = Array.new
                posicaoAtletaFinal = Array.new
                textCapitaoAtleta = Array.new
                @atleta = Array.new
                
                    atletas_encontrados = SalvarAtletumAnterior.all.where(rodada: @rodada, slug: params["slug"])
                    @atletas_verificar = atletas_encontrados[0]["mensagem"]

                    if @atletas_verificar == "1"
                        
                    
                        result_atleta_nome = atletas_encontrados[0]["nome_atleta"].gsub('\"', '"')         
                        atletas_nome_final =  eval(result_atleta_nome)

                        result_id_nome = atletas_encontrados[0]["atletas"].gsub('\"', '"')         
                        atletas_id_final =  eval(result_id_nome)

                        result_posicao_nome = atletas_encontrados[0]["posicao_atleta"].gsub('\"', '"')         
                        atletas_posicao_final =  eval(result_posicao_nome)

                        result_atleta_pontos = atletas_encontrados[0]["pontos_atleta"].gsub('\"', '"')         
                        atletas_pontos_final =  eval(result_atleta_pontos)
                        
                        result_foto_pontos = atletas_encontrados[0]["foto_final"].gsub('\"', '"')         
                        atletas_foto_final =  eval(result_foto_pontos)

                        capitao = atletas_encontrados[0]["capitao"]
                        @nome_escudo_slug = atletas_encontrados[0]["escudo"]
                        @nome_cartoleiro_slug = atletas_encontrados[0]["cartoleiro"]
                        pontos_inter = atletas_encontrados[0]["pontos"]
                        @pontos = number_with_precision(pontos_inter, precision: 2, separator: '.')

                        @equipe = atletas_encontrados[0]["equipe_nome"]

                    
                     
                        a = 0
                        while a < 12
                            nome_jogador_slug[a] = atletas_nome_final[a]
                            

                            if atletas_posicao_final[a] == 1
                                posicaoAtletaFinal[a] = "Goleiro:"
                            end
                            if atletas_posicao_final[a] == 2
                                posicaoAtletaFinal[a] = "Lateral:"
                            end
                            if atletas_posicao_final[a] == 3
                                posicaoAtletaFinal[a] = "Zagueiro:"
                            end
                            if atletas_posicao_final[a] == 4
                                posicaoAtletaFinal[a] = "Meia:"
                            end
                            if atletas_posicao_final[a] == 5
                                posicaoAtletaFinal[a] = "Atacante:"
                            end
                            if atletas_posicao_final[a] == 6
                                posicaoAtletaFinal[a] = "Técnico:"
                            end


                                if atletas_id_final[a].to_i == capitao.to_i
                                    textCapitaoAtleta[a] = "orangered"
                                    pontuacaoAtletaFinal[a] = atletas_pontos_final[a]
                                else
                                    pontuacaoAtletaFinal[a] = atletas_pontos_final[a]
                                    textCapitaoAtleta[a] = ""
                                end
                                
                        @atleta[a] = [nome_jogador_slug[a],atletas_posicao_final[a],posicaoAtletaFinal[a],number_with_precision(pontuacaoAtletaFinal[a], precision: 2, separator: '.'),textCapitaoAtleta[a],atletas_foto_final[a]]
                        @atleta_final = Kaminari.paginate_array(@atleta.sort_by {|h| h[1]})
                        a = a + 1
                        end
                    else
                        @mensagem = atletas_encontrados[0]["mensagem"]
                        encontrar_escudo = Equipe.all.where(slug: params["slug"])
                        @nome_escudo_slug = encontrar_escudo[0]["escudo"]
                        @nome_cartoleiro_slug = encontrar_escudo[0]["cartoleiro"]
                        @pontos = "0.00"
                    end
               
               end


               if @mercado == "2" && @rodada == @rodada_atual || @mercado == "4" && @rodada == @rodada_atual

                @contador = 0
                nome_jogador_slug = Array.new
                pontuacaoAtletaFinal = Array.new
                atletas_posicao_final = Array.new
                posicaoAtletaFinal = Array.new
                textCapitaoAtleta = Array.new
                @atleta = Array.new
                
                    atletas_encontrados = Parcial.all.where(rodada: @rodada, slug: params["slug"])
                    @atletas_verificar = atletas_encontrados[0]["mensagem"]

                    if @atletas_verificar == "1"
                        
                    
                        result_atleta_nome = atletas_encontrados[0]["nome_atleta"].gsub('\"', '"')         
                        atletas_nome_final =  eval(result_atleta_nome)

                        result_id_nome = atletas_encontrados[0]["atletas"].gsub('\"', '"')         
                        atletas_id_final =  eval(result_id_nome)

                        result_posicao_nome = atletas_encontrados[0]["posicao_atleta"].gsub('\"', '"')         
                        atletas_posicao_final =  eval(result_posicao_nome)

                        result_atleta_pontos = atletas_encontrados[0]["pontos_atleta"].gsub('\"', '"')         
                        atletas_pontos_final =  eval(result_atleta_pontos)
                        
                        result_foto_pontos = atletas_encontrados[0]["foto_final"].gsub('\"', '"')         
                        atletas_foto_final =  eval(result_foto_pontos)

                        capitao = atletas_encontrados[0]["capitao"]
                        @nome_escudo_slug = atletas_encontrados[0]["escudo"]
                        @nome_cartoleiro_slug = atletas_encontrados[0]["cartoleiro"]
                        pontos_inter = atletas_encontrados[0]["pontos"]
                        @pontos = number_with_precision(pontos_inter, precision: 2, separator: '.')

                        @equipe = atletas_encontrados[0]["equipe_nome"]

                    
                     
                        a = 0
                        while a < 12
                            nome_jogador_slug[a] = atletas_nome_final[a]
                            

                            if atletas_posicao_final[a] == 1
                                posicaoAtletaFinal[a] = "Goleiro:"
                            end
                            if atletas_posicao_final[a] == 2
                                posicaoAtletaFinal[a] = "Lateral:"
                            end
                            if atletas_posicao_final[a] == 3
                                posicaoAtletaFinal[a] = "Zagueiro:"
                            end
                            if atletas_posicao_final[a] == 4
                                posicaoAtletaFinal[a] = "Meia:"
                            end
                            if atletas_posicao_final[a] == 5
                                posicaoAtletaFinal[a] = "Atacante:"
                            end
                            if atletas_posicao_final[a] == 6
                                posicaoAtletaFinal[a] = "Técnico:"
                            end


                                if atletas_id_final[a].to_i == capitao.to_i
                                    textCapitaoAtleta[a] = "orangered"
                                    pontuacaoAtletaFinal[a] = atletas_pontos_final[a]
                                else
                                    pontuacaoAtletaFinal[a] = atletas_pontos_final[a]
                                    textCapitaoAtleta[a] = ""
                                end
                                
                        @atleta[a] = [nome_jogador_slug[a],atletas_posicao_final[a],posicaoAtletaFinal[a],number_with_precision(pontuacaoAtletaFinal[a], precision: 2, separator: '.'),textCapitaoAtleta[a],atletas_foto_final[a]]
                        @atleta_final = Kaminari.paginate_array(@atleta.sort_by {|h| h[1]})
                        a = a + 1

                        end
                    else
                        @mensagem = atletas_encontrados[0]["mensagem"]
                        encontrar_escudo = Equipe.all.where(slug: params["slug"])
                        @nome_escudo_slug = encontrar_escudo[0]["escudo"]
                        @nome_cartoleiro_slug = encontrar_escudo[0]["cartoleiro"]
                        @pontos = "0.00"
                    end
            
            
            
                end

            end
        end

        

    

    private

    def set_mercado_rodada

        buscar_mercado_rodada = SalvarRodadaMercado.all
        @rodada_atual = buscar_mercado_rodada[0]["rodada_atual"].to_i
        @mercado = buscar_mercado_rodada[0]["mercado"]

    end
end
