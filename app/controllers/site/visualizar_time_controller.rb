class Site::VisualizarTimeController < SiteController
    include ActionView::Helpers::NumberHelper
    require 'rest-client'
    require 'json'
    before_action :set_api
    before_action :set_rodada
    before_action :set_mercado


    def time 
        @contador = 0
        
            
        @rodada = params["rodada"].to_i
        

        if @rodada > @rodada_atual ||  @rodada < 1
            redirect_to users_backoffice_resultados_index_path
        else 


            if @mercado == 1 && @rodada == @rodada_atual
                #busca time no banco de dados
                time = params["time"]
                @times = Equipe.all.where(id: time)   
                    if @times.blank?
                        redirect_to users_backoffice_resultados_index_path
                    end

            else 
               
                if @mercado != 1
                        uri3 = URI.parse("https://api.cartolafc.globo.com/atletas/pontuados")
                        request = Net::HTTP::Get.new(uri3)
                        
                        req_options = {
                        use_ssl: uri3.scheme == "https",
                        }

                        @response3 = Net::HTTP.start(uri3.hostname, uri3.port, req_options) do |http|
                        http.request(request)
                        end

                    @atletas_pontos = JSON.parse(@response3.body)["atletas"]
                end


                #busca time no cartola
                slug = params["slug"]
                url2 = 'https://api.cartolafc.globo.com/time/id/'
                resp = RestClient.get ("#{url2}#{slug}/#{@rodada}")
                @nome_time_slug = JSON.parse(resp.body)["time"]["nome"]
                @nome_cartoleiro_slug = JSON.parse(resp.body)["time"]["nome_cartola"]

                encontrar_slug = Equipe.all.where(slug: slug)  
                @nome_escudo_slug = encontrar_slug[0]["escudo"]


                capitao = JSON.parse(resp.body)["capitao_id"]
               
                idAtleta1 = JSON.parse(resp.body)["atletas"][0]["atleta_id"]
                fotoAtleta1 = JSON.parse(resp.body)["atletas"][0]["foto"]
                foto_format1 = fotoAtleta1.slice! "FORMATO.png"
                foto_final1 = "#{fotoAtleta1}140x140.png"
                nomeAtleta1 = JSON.parse(resp.body)["atletas"][0]["apelido"]
                posicaoAtleta1 = JSON.parse(resp.body)["atletas"][0]["posicao_id"]
                if posicaoAtleta1 == 1
                    posicaoAtletaFinal1 = "Goleiro:"
                end
                if posicaoAtleta1 == 2
                    posicaoAtletaFinal1 = "Lateral:"
                end
                if posicaoAtleta1 == 3
                    posicaoAtletaFinal1 = "Zagueiro:"
                end
                if posicaoAtleta1 == 4
                    posicaoAtletaFinal1 = "Meia:"
                end
                if posicaoAtleta1 == 5
                    posicaoAtletaFinal1 = "Atacante:"
                end
                if posicaoAtleta1 == 6
                    posicaoAtletaFinal1 = "Técnico:"
                end

                if @mercado == 1 && @rodada_atual != @rodada
                    pontuacaoAtleta1 = JSON.parse(resp.body)["atletas"][0]["pontos_num"]
                    
                end
                if @mercado != 1 && @rodada_atual != @rodada
                    pontuacaoAtleta1 = JSON.parse(resp.body)["atletas"][0]["pontos_num"]
                end

                if @mercado != 1 && @rodada_atual == @rodada
                    unless @atletas_pontos["#{idAtleta1}"].blank?
                        pontuacaoAtleta1 = @atletas_pontos["#{idAtleta1}"]["pontuacao"]
                    else
                        pontuacaoAtleta1 = 0
                    end
                end

                if idAtleta1 == capitao
                    textCapitaoAtleta1 = "(Capitão)"
                    pontuacaoAtletaFinal1 = 2*pontuacaoAtleta1
                else
                    pontuacaoAtletaFinal1 = pontuacaoAtleta1
                    textCapitaoAtleta1 = ""
                end



                @atleta1 = [nomeAtleta1,posicaoAtleta1,posicaoAtletaFinal1,number_with_precision(pontuacaoAtletaFinal1, precision: 2, separator: '.'),textCapitaoAtleta1,foto_final1]




                idAtleta2 = JSON.parse(resp.body)["atletas"][1]["atleta_id"]
                fotoAtleta2 = JSON.parse(resp.body)["atletas"][1]["foto"]
                foto_format2 = fotoAtleta2.slice! "FORMATO.png"
                foto_final2 = "#{fotoAtleta2}140x140.png"
                nomeAtleta2 = JSON.parse(resp.body)["atletas"][1]["apelido"]
                posicaoAtleta2 = JSON.parse(resp.body)["atletas"][1]["posicao_id"]
                if posicaoAtleta2 == 1
                    posicaoAtletaFinal2 = "Goleiro:"
                end
                if posicaoAtleta2 == 2
                    posicaoAtletaFinal2 = "Lateral:"
                end
                if posicaoAtleta2 == 3
                    posicaoAtletaFinal2 = "Zagueiro:"
                end
                if posicaoAtleta2 == 4
                    posicaoAtletaFinal2 = "Meia:"
                end
                if posicaoAtleta2 == 5
                    posicaoAtletaFinal2 = "Atacante:"
                end
                if posicaoAtleta2 == 6
                    posicaoAtletaFinal2 = "Técnico:"
                end

                            
                if @mercado == 1 && @rodada_atual != @rodada
                    pontuacaoAtleta2 = JSON.parse(resp.body)["atletas"][1]["pontos_num"]
                    
                end
                if @mercado != 1 && @rodada_atual != @rodada
                    pontuacaoAtleta2 = JSON.parse(resp.body)["atletas"][1]["pontos_num"]
                end

                if @mercado != 1 && @rodada_atual == @rodada
                    unless @atletas_pontos["#{idAtleta2}"].blank?
                        pontuacaoAtleta2 = @atletas_pontos["#{idAtleta2}"]["pontuacao"]
                    else
                        pontuacaoAtleta2 = 0
                    end
                end

                if idAtleta2 == capitao
                    textCapitaoAtleta2 = "(Capitão)"
                    pontuacaoAtletaFinal2 = 2*pontuacaoAtleta2
                else
                    pontuacaoAtletaFinal2 = pontuacaoAtleta2
                    textCapitaoAtleta2 = ""
                end

                @atleta2 = [nomeAtleta2,posicaoAtleta2,posicaoAtletaFinal2,number_with_precision(pontuacaoAtletaFinal2, precision: 2, separator: '.'),textCapitaoAtleta2,foto_final2]





                idAtleta3 = JSON.parse(resp.body)["atletas"][2]["atleta_id"]
                fotoAtleta3 = JSON.parse(resp.body)["atletas"][2]["foto"]
                foto_format3 = fotoAtleta3.slice! "FORMATO.png"
                foto_final3 = "#{fotoAtleta3}140x140.png"
                nomeAtleta3 = JSON.parse(resp.body)["atletas"][2]["apelido"]
                posicaoAtleta3 = JSON.parse(resp.body)["atletas"][2]["posicao_id"]
                if posicaoAtleta3 == 1
                    posicaoAtletaFinal3 = "Goleiro:"
                end
                if posicaoAtleta3 == 2
                    posicaoAtletaFinal3 = "Lateral:"
                end
                if posicaoAtleta3 == 3
                    posicaoAtletaFinal3 = "Zagueiro:"
                end
                if posicaoAtleta3 == 4
                    posicaoAtletaFinal3 = "Meia:"
                end
                if posicaoAtleta3 == 5
                    posicaoAtletaFinal3 = "Atacante:"
                end
                if posicaoAtleta3 == 6
                    posicaoAtletaFinal3 = "Técnico:"
                end
             

                if @mercado == 1 && @rodada_atual != @rodada
                    pontuacaoAtleta3 = JSON.parse(resp.body)["atletas"][2]["pontos_num"]
                    
                end
                if @mercado != 1 && @rodada_atual != @rodada
                    pontuacaoAtleta3 = JSON.parse(resp.body)["atletas"][2]["pontos_num"]
                end

                if @mercado != 1 && @rodada_atual == @rodada
                    unless @atletas_pontos["#{idAtleta3}"].blank?
                        pontuacaoAtleta3 = @atletas_pontos["#{idAtleta3}"]["pontuacao"]
                    else
                        pontuacaoAtleta3 = 0
                    end
                end

                if idAtleta3 == capitao
                    textCapitaoAtleta3 = "(Capitão)"
                    pontuacaoAtletaFinal3 = 2*pontuacaoAtleta3
                else
                    pontuacaoAtletaFinal3 = pontuacaoAtleta3
                    textCapitaoAtleta3 = ""
                end

                @atleta3 = [nomeAtleta3,posicaoAtleta3,posicaoAtletaFinal3,number_with_precision(pontuacaoAtletaFinal3, precision: 2, separator: '.'),textCapitaoAtleta3,foto_final3]



                idAtleta4 = JSON.parse(resp.body)["atletas"][3]["atleta_id"]
                fotoAtleta4 = JSON.parse(resp.body)["atletas"][3]["foto"]
                foto_format4 = fotoAtleta4.slice! "FORMATO.png"
                foto_final4 = "#{fotoAtleta4}140x140.png"
                nomeAtleta4 = JSON.parse(resp.body)["atletas"][3]["apelido"]
                posicaoAtleta4 = JSON.parse(resp.body)["atletas"][3]["posicao_id"]
                if posicaoAtleta4 == 1
                    posicaoAtletaFinal4 = "Goleiro:"
                end
                if posicaoAtleta4 == 2
                    posicaoAtletaFinal4 = "Lateral:"
                end
                if posicaoAtleta4 == 3
                    posicaoAtletaFinal4 = "Zagueiro:"
                end
                if posicaoAtleta4 == 4
                    posicaoAtletaFinal4 = "Meia:"
                end
                if posicaoAtleta4 == 5
                    posicaoAtletaFinal4 = "Atacante:"
                end
                if posicaoAtleta4 == 6
                    posicaoAtletaFinal4 = "Técnico:"
                end
           

                if @mercado == 1 && @rodada_atual != @rodada
                    pontuacaoAtleta4 = JSON.parse(resp.body)["atletas"][3]["pontos_num"]
                    
                end
                if @mercado != 1 && @rodada_atual != @rodada
                    pontuacaoAtleta4 = JSON.parse(resp.body)["atletas"][3]["pontos_num"]
                end

                if @mercado != 1 && @rodada_atual == @rodada
                    unless @atletas_pontos["#{idAtleta4}"].blank?
                        pontuacaoAtleta4 = @atletas_pontos["#{idAtleta4}"]["pontuacao"]
                    else
                        pontuacaoAtleta4 = 0
                    end
                end

                if idAtleta4 == capitao
                    textCapitaoAtleta4 = "(Capitão)"
                    pontuacaoAtletaFinal4 = 2*pontuacaoAtleta4
                else
                    pontuacaoAtletaFinal4 = pontuacaoAtleta4
                    textCapitaoAtleta4 = ""
                end

                @atleta4 = [nomeAtleta4,posicaoAtleta4,posicaoAtletaFinal4,number_with_precision(pontuacaoAtletaFinal4, precision: 2, separator: '.'),textCapitaoAtleta4,foto_final4]




                idAtleta5 = JSON.parse(resp.body)["atletas"][4]["atleta_id"]
                fotoAtleta5 = JSON.parse(resp.body)["atletas"][4]["foto"]
                foto_format5 = fotoAtleta5.slice! "FORMATO.png"
                foto_final5 = "#{fotoAtleta5}140x140.png"
                nomeAtleta5 = JSON.parse(resp.body)["atletas"][4]["apelido"]
                posicaoAtleta5 = JSON.parse(resp.body)["atletas"][4]["posicao_id"]
                if posicaoAtleta5 == 1
                    posicaoAtletaFinal5 = "Goleiro:"
                end
                if posicaoAtleta5 == 2
                    posicaoAtletaFinal5 = "Lateral:"
                end
                if posicaoAtleta5 == 3
                    posicaoAtletaFinal5 = "Zagueiro:"
                end
                if posicaoAtleta5 == 4
                    posicaoAtletaFinal5 = "Meia:"
                end
                if posicaoAtleta5 == 5
                    posicaoAtletaFinal5 = "Atacante:"
                end
                if posicaoAtleta5 == 6
                    posicaoAtletaFinal5 = "Técnico:"
                end
            
                if @mercado == 1 && @rodada_atual != @rodada
                    pontuacaoAtleta5 = JSON.parse(resp.body)["atletas"][4]["pontos_num"]
                    
                end
                if @mercado != 1 && @rodada_atual != @rodada
                    pontuacaoAtleta5 = JSON.parse(resp.body)["atletas"][4]["pontos_num"]
                end

                if @mercado != 1 && @rodada_atual == @rodada
                    unless @atletas_pontos["#{idAtleta5}"].blank?
                        pontuacaoAtleta5 = @atletas_pontos["#{idAtleta5}"]["pontuacao"]
                    else
                        pontuacaoAtleta5 = 0
                    end
                end

                if idAtleta5 == capitao
                    textCapitaoAtleta5 = "(Capitão)"
                    pontuacaoAtletaFinal5 = 2*pontuacaoAtleta5
                else
                    pontuacaoAtletaFinal5 = pontuacaoAtleta5
                    textCapitaoAtleta5 = ""
                end

                @atleta5 = [nomeAtleta5,posicaoAtleta5,posicaoAtletaFinal5,number_with_precision(pontuacaoAtletaFinal5, precision: 2, separator: '.'),textCapitaoAtleta5,foto_final5]


                idAtleta6 = JSON.parse(resp.body)["atletas"][5]["atleta_id"]
                fotoAtleta6 = JSON.parse(resp.body)["atletas"][5]["foto"]
                foto_format6 = fotoAtleta6.slice! "FORMATO.png"
                foto_final6 = "#{fotoAtleta6}140x140.png"
                nomeAtleta6 = JSON.parse(resp.body)["atletas"][5]["apelido"]
                posicaoAtleta6 = JSON.parse(resp.body)["atletas"][5]["posicao_id"]
                if posicaoAtleta6 == 1
                    posicaoAtletaFinal6 = "Goleiro:"
                end
                if posicaoAtleta6 == 2
                    posicaoAtletaFinal6 = "Lateral:"
                end
                if posicaoAtleta6 == 3
                    posicaoAtletaFinal6 = "Zagueiro:"
                end
                if posicaoAtleta6 == 4
                    posicaoAtletaFinal6 = "Meia:"
                end
                if posicaoAtleta6 == 5
                    posicaoAtletaFinal6 = "Atacante:"
                end
                if posicaoAtleta6 == 6
                    posicaoAtletaFinal6 = "Técnico:"
                end
           
                if @mercado == 1 && @rodada_atual != @rodada
                    pontuacaoAtleta6 = JSON.parse(resp.body)["atletas"][5]["pontos_num"]
                    
                end
                if @mercado != 1 && @rodada_atual != @rodada
                    pontuacaoAtleta6 = JSON.parse(resp.body)["atletas"][5]["pontos_num"]
                end

                if @mercado != 1 && @rodada_atual == @rodada
                    unless @atletas_pontos["#{idAtleta6}"].blank?
                        pontuacaoAtleta6 = @atletas_pontos["#{idAtleta6}"]["pontuacao"]
                    else
                        pontuacaoAtleta6 = 0
                    end
                end

                if idAtleta6 == capitao
                    textCapitaoAtleta6 = "(Capitão)"
                    pontuacaoAtletaFinal6 = 2*pontuacaoAtleta6
                else
                    pontuacaoAtletaFinal6 = pontuacaoAtleta6
                    textCapitaoAtleta6 = ""
                end
                @atleta6 = [nomeAtleta6,posicaoAtleta6,posicaoAtletaFinal6,number_with_precision(pontuacaoAtletaFinal6, precision: 2, separator: '.'),textCapitaoAtleta6,foto_final6]


                idAtleta7 = JSON.parse(resp.body)["atletas"][6]["atleta_id"]
                fotoAtleta7 = JSON.parse(resp.body)["atletas"][6]["foto"]
                foto_format7 = fotoAtleta7.slice! "FORMATO.png"
                foto_final7 = "#{fotoAtleta7}140x140.png"
                nomeAtleta7 = JSON.parse(resp.body)["atletas"][6]["apelido"]
                posicaoAtleta7 = JSON.parse(resp.body)["atletas"][6]["posicao_id"]
                if posicaoAtleta7 == 1
                    posicaoAtletaFinal7 = "Goleiro:"
                end
                if posicaoAtleta7 == 2
                    posicaoAtletaFinal7 = "Lateral:"
                end
                if posicaoAtleta7 == 3
                    posicaoAtletaFinal7= "Zagueiro:"
                end
                if posicaoAtleta7 == 4
                    posicaoAtletaFinal7 = "Meia:"
                end
                if posicaoAtleta7 == 5
                    posicaoAtletaFinal7 = "Atacante:"
                end
                if posicaoAtleta7 == 6
                    posicaoAtletaFinal7 = "Técnico:"
                end
             
                if @mercado == 1 && @rodada_atual != @rodada
                    pontuacaoAtleta7 = JSON.parse(resp.body)["atletas"][6]["pontos_num"]
                    
                end
                if @mercado != 1 && @rodada_atual != @rodada
                    pontuacaoAtleta7 = JSON.parse(resp.body)["atletas"][6]["pontos_num"]
                end

                if @mercado != 1 && @rodada_atual == @rodada
                    unless @atletas_pontos["#{idAtleta7}"].blank?
                        pontuacaoAtleta7 = @atletas_pontos["#{idAtleta7}"]["pontuacao"]
                    else
                        pontuacaoAtleta7 = 0
                    end
                end

                if idAtleta7 == capitao
                    textCapitaoAtleta7 = "(Capitão)"
                    pontuacaoAtletaFinal7 = 2*pontuacaoAtleta7
                else
                    pontuacaoAtletaFinal7 = pontuacaoAtleta7
                    textCapitaoAtleta7 = ""
                end
                @atleta7 = [nomeAtleta7,posicaoAtleta7,posicaoAtletaFinal7,number_with_precision(pontuacaoAtletaFinal7, precision: 2, separator: '.'),textCapitaoAtleta7,foto_final7]




                idAtleta8 = JSON.parse(resp.body)["atletas"][7]["atleta_id"]
                fotoAtleta8 = JSON.parse(resp.body)["atletas"][7]["foto"]
                foto_format8 = fotoAtleta8.slice! "FORMATO.png"
                foto_final8 = "#{fotoAtleta8}140x140.png"
                nomeAtleta8 = JSON.parse(resp.body)["atletas"][7]["apelido"]
                posicaoAtleta8 = JSON.parse(resp.body)["atletas"][7]["posicao_id"]
                if posicaoAtleta8 == 1
                    posicaoAtletaFinal8 = "Goleiro:"
                end
                if posicaoAtleta8 == 2
                    posicaoAtletaFinal8 = "Lateral:"
                end
                if posicaoAtleta8 == 3
                    posicaoAtletaFinal8 = "Zagueiro:"
                end
                if posicaoAtleta8 == 4
                    posicaoAtletaFinal8 = "Meia:"
                end
                if posicaoAtleta8 == 5
                    posicaoAtletaFinal8 = "Atacante:"
                end
                if posicaoAtleta8 == 6
                    posicaoAtletaFinal8 = "Técnico:"
                end
              

                if @mercado == 1 && @rodada_atual != @rodada
                    pontuacaoAtleta8 = JSON.parse(resp.body)["atletas"][7]["pontos_num"]
                    
                end
                if @mercado != 1 && @rodada_atual != @rodada
                    pontuacaoAtleta8 = JSON.parse(resp.body)["atletas"][7]["pontos_num"]
                end

                if @mercado != 1 && @rodada_atual == @rodada
                    unless @atletas_pontos["#{idAtleta8}"].blank?
                        pontuacaoAtleta8 = @atletas_pontos["#{idAtleta8}"]["pontuacao"]
                    else
                        pontuacaoAtleta8 = 0
                    end
                end

                if idAtleta8 == capitao
                    textCapitaoAtleta8 = "(Capitão)"
                    pontuacaoAtletaFinal8 = 2*pontuacaoAtleta8
                else
                    pontuacaoAtletaFinal8 = pontuacaoAtleta8
                    textCapitaoAtleta8 = ""
                end

                @atleta8 = [nomeAtleta8,posicaoAtleta8,posicaoAtletaFinal8,number_with_precision(pontuacaoAtletaFinal8, precision: 2, separator: '.'),textCapitaoAtleta8,foto_final8]


                idAtleta9 = JSON.parse(resp.body)["atletas"][8]["atleta_id"]
                fotoAtleta9 = JSON.parse(resp.body)["atletas"][8]["foto"]
                foto_format9 = fotoAtleta9.slice! "FORMATO.png"
                foto_final9 = "#{fotoAtleta9}140x140.png"
                nomeAtleta9 = JSON.parse(resp.body)["atletas"][8]["apelido"]
                posicaoAtleta9 = JSON.parse(resp.body)["atletas"][8]["posicao_id"]
                if posicaoAtleta9 == 1
                    posicaoAtletaFinal9 = "Goleiro:"
                end
                if posicaoAtleta9 == 2
                    posicaoAtletaFinal9 = "Lateral:"
                end
                if posicaoAtleta9 == 3
                    posicaoAtletaFinal9 = "Zagueiro:"
                end
                if posicaoAtleta9 == 4
                    posicaoAtletaFinal9 = "Meia:"
                end
                if posicaoAtleta9 == 5
                    posicaoAtletaFinal9 = "Atacante:"
                end
                if posicaoAtleta9 == 6
                    posicaoAtletaFinal9 = "Técnico:"
                end
             
                if @mercado == 1 && @rodada_atual != @rodada
                    pontuacaoAtleta9 = JSON.parse(resp.body)["atletas"][8]["pontos_num"]
                    
                end
                if @mercado != 1 && @rodada_atual != @rodada
                    pontuacaoAtleta9 = JSON.parse(resp.body)["atletas"][8]["pontos_num"]
                end

                if @mercado != 1 && @rodada_atual == @rodada
                    unless @atletas_pontos["#{idAtleta9}"].blank?
                        pontuacaoAtleta9 = @atletas_pontos["#{idAtleta9}"]["pontuacao"]
                    else
                        pontuacaoAtleta9 = 0
                    end
                end

                if idAtleta9 == capitao
                    textCapitaoAtleta9 = "(Capitão)"
                    pontuacaoAtletaFinal9 = 2*pontuacaoAtleta9
                else
                    pontuacaoAtletaFinal9 = pontuacaoAtleta9
                    textCapitaoAtleta9 = ""
                end

                @atleta9 = [nomeAtleta9,posicaoAtleta9,posicaoAtletaFinal9,number_with_precision(pontuacaoAtletaFinal9, precision: 2, separator: '.'),textCapitaoAtleta9,foto_final9]


                idAtleta10 = JSON.parse(resp.body)["atletas"][9]["atleta_id"]
                fotoAtleta10 = JSON.parse(resp.body)["atletas"][9]["foto"]
                foto_format10 = fotoAtleta10.slice! "FORMATO.png"
                foto_final10 = "#{fotoAtleta10}140x140.png"
                nomeAtleta10 = JSON.parse(resp.body)["atletas"][9]["apelido"]
                posicaoAtleta10 = JSON.parse(resp.body)["atletas"][9]["posicao_id"]
                if posicaoAtleta10 == 1
                    posicaoAtletaFinal10 = "Goleiro:"
                end
                if posicaoAtleta10 == 2
                    posicaoAtletaFinal10 = "Lateral:"
                end
                if posicaoAtleta10 == 3
                    posicaoAtletaFinal10 = "Zagueiro:"
                end
                if posicaoAtleta10 == 4
                    posicaoAtletaFinal10 = "Meia:"
                end
                if posicaoAtleta10 == 5
                    posicaoAtletaFinal10 = "Atacante:"
                end
                if posicaoAtleta10 == 6
                    posicaoAtletaFinal10 = "Técnico:"
                end
              
                if @mercado == 1 && @rodada_atual != @rodada
                    pontuacaoAtleta10 = JSON.parse(resp.body)["atletas"][9]["pontos_num"]
                    
                end
                if @mercado != 1 && @rodada_atual != @rodada
                    pontuacaoAtleta10 = JSON.parse(resp.body)["atletas"][9]["pontos_num"]
                end

                if @mercado != 1 && @rodada_atual == @rodada
                    unless @atletas_pontos["#{idAtleta10}"].blank?
                        pontuacaoAtleta10 = @atletas_pontos["#{idAtleta10}"]["pontuacao"]
                    else
                        pontuacaoAtleta10 = 0
                    end
                end

                if idAtleta10 == capitao
                    textCapitaoAtleta10 = "(Capitão)"
                    pontuacaoAtletaFinal10 = 2*pontuacaoAtleta10
                else
                    pontuacaoAtletaFinal10 = pontuacaoAtleta10
                    textCapitaoAtleta10 = ""
                end
                @atleta10 = [nomeAtleta10,posicaoAtleta10,posicaoAtletaFinal10,number_with_precision(pontuacaoAtletaFinal10, precision: 2, separator: '.'),textCapitaoAtleta10,foto_final10]


                idAtleta11 = JSON.parse(resp.body)["atletas"][10]["atleta_id"]
                fotoAtleta11 = JSON.parse(resp.body)["atletas"][10]["foto"]
                foto_format11 = fotoAtleta11.slice! "FORMATO.png"
                foto_final11 = "#{fotoAtleta11}140x140.png"
                nomeAtleta11 = JSON.parse(resp.body)["atletas"][10]["apelido"]
                posicaoAtleta11 = JSON.parse(resp.body)["atletas"][10]["posicao_id"]
                if posicaoAtleta11 == 1
                    posicaoAtletaFinal11 = "Goleiro:"
                end
                if posicaoAtleta11 == 2
                    posicaoAtletaFinal11 = "Lateral:"
                end
                if posicaoAtleta11 == 3
                    posicaoAtletaFinal11 = "Zagueiro:"
                end
                if posicaoAtleta11 == 4
                    posicaoAtletaFinal11 = "Meia:"
                end
                if posicaoAtleta11 == 5
                    posicaoAtletaFinal11 = "Atacante:"
                end
                if posicaoAtleta11 == 6
                    posicaoAtletaFinal11 = "Técnico:"
                end
            
                if @mercado == 1 && @rodada_atual != @rodada
                    pontuacaoAtleta11 = JSON.parse(resp.body)["atletas"][10]["pontos_num"]
                    
                end
                if @mercado != 1 && @rodada_atual != @rodada
                    pontuacaoAtleta11 = JSON.parse(resp.body)["atletas"][10]["pontos_num"]
                end

                if @mercado != 1 && @rodada_atual == @rodada
                    unless @atletas_pontos["#{idAtleta11}"].blank?
                        pontuacaoAtleta11 = @atletas_pontos["#{idAtleta11}"]["pontuacao"]
                    else
                        pontuacaoAtleta11 = 0
                    end
                end

                if idAtleta11 == capitao
                    textCapitaoAtleta11 = "(Capitão)"
                    pontuacaoAtletaFinal11 = 2*pontuacaoAtleta11
                else
                    pontuacaoAtletaFinal11 = pontuacaoAtleta11
                    textCapitaoAtleta11 = ""
                end

                @atleta11 = [nomeAtleta11,posicaoAtleta11,posicaoAtletaFinal11,number_with_precision(pontuacaoAtletaFinal11, precision: 2, separator: '.'),textCapitaoAtleta11,foto_final11]





                idAtleta12 = JSON.parse(resp.body)["atletas"][11]["atleta_id"]
                fotoAtleta12 = JSON.parse(resp.body)["atletas"][11]["foto"]
                foto_format12 = fotoAtleta12.slice! "FORMATO.png"
                foto_final12 = "#{fotoAtleta12}140x140.png"
                nomeAtleta12 = JSON.parse(resp.body)["atletas"][11]["apelido"]
                posicaoAtleta12 = JSON.parse(resp.body)["atletas"][11]["posicao_id"]
                if posicaoAtleta12 == 1
                    posicaoAtletaFinal12 = "Goleiro:"
                end
                if posicaoAtleta12 == 2
                    posicaoAtletaFinal12 = "Lateral:"
                end
                if posicaoAtleta12 == 3
                    posicaoAtletaFinal12 = "Zagueiro:"
                end
                if posicaoAtleta12 == 4
                    posicaoAtletaFinal12 = "Meia:"
                end
                if posicaoAtleta12 == 5
                    posicaoAtletaFinal12 = "Atacante:"
                end
                if posicaoAtleta12 == 6
                    posicaoAtletaFinal12 = "Técnico:"
                end
             
                if @mercado == 1 && @rodada_atual != @rodada
                    pontuacaoAtleta12 = JSON.parse(resp.body)["atletas"][11]["pontos_num"]
                    
                end
                if @mercado != 1 && @rodada_atual != @rodada
                    pontuacaoAtleta12 = JSON.parse(resp.body)["atletas"][11]["pontos_num"]
                end

                if @mercado != 1 && @rodada_atual == @rodada
                    unless @atletas_pontos["#{idAtleta12}"].blank?
                        pontuacaoAtleta12 = @atletas_pontos["#{idAtleta12}"]["pontuacao"]
                    else
                        pontuacaoAtleta12 = 0
                    end
                end

                if idAtleta12 == capitao
                    textCapitaoAtleta12 = "(Capitão)"
                    pontuacaoAtletaFinal12 = 2*pontuacaoAtleta12
                else
                    pontuacaoAtletaFinal12 = pontuacaoAtleta12
                    textCapitaoAtleta12 = ""
                end
                @atleta12 = [nomeAtleta12,posicaoAtleta12,posicaoAtletaFinal12,number_with_precision(pontuacaoAtletaFinal12, precision: 2, separator: '.'),textCapitaoAtleta12,foto_final12]


                @atletas_escolhidos = Array[@atleta1,@atleta2,@atleta3,@atleta4,@atleta5,@atleta6,@atleta7,@atleta8,@atleta9,@atleta10,@atleta11,@atleta12]

                @atletas = @atletas_escolhidos.sort_by {|h| h[1]}

                @pontos_time_slug = number_with_precision((pontuacaoAtletaFinal1 +  pontuacaoAtletaFinal2 + pontuacaoAtletaFinal3 + pontuacaoAtletaFinal4 + pontuacaoAtletaFinal5 + pontuacaoAtletaFinal6 + pontuacaoAtletaFinal7 + pontuacaoAtletaFinal8 + pontuacaoAtletaFinal9 + pontuacaoAtletaFinal10 + pontuacaoAtletaFinal11 + pontuacaoAtletaFinal12), precision: 2, separator: '.')
                 
                end
            end
        end

    

    private

    def set_api

        url = 'https://api.cartolafc.globo.com/mercado/status'
        @resp = RestClient.get "#{url}"   

    end


    def set_mercado
        @mercado = JSON.parse(@resp.body)["status_mercado"]

    end

    def set_rodada
           
        @rodada_atual = JSON.parse(@resp.body)["rodada_atual"]

    end
end
