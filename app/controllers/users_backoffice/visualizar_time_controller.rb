class UsersBackoffice::VisualizarTimeController < UsersBackofficeController
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
                #busca time no cartola
                slug = params["slug"]
                url2 = 'https://api.cartolafc.globo.com/time/id/'
                resp = RestClient.get ("#{url2}#{slug}/#{@rodada}")
                @nome_time_slug = JSON.parse(resp.body)["time"]["nome"]
                @nome_cartoleiro_slug = JSON.parse(resp.body)["time"]["nome_cartola"]
                @pontos_time_slug = JSON.parse(resp.body)["time"]["tipo_estampa_camisa"] # aqui será pontuação, só mudar para pontos

                encontrar_slug = Equipe.all.where(slug: slug)  
                @nome_escudo_slug = encontrar_slug[0]["escudo"]


                capitao = JSON.parse(resp.body)["capitao_id"]

                idAtleta1 = JSON.parse(resp.body)["atletas"][0]["id"]
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
                pontuacaoAtleta1 = JSON.parse(resp.body)["atletas"][0]["pontos_num"]
                if idAtleta1 == capitao
                    pontuacaoAtletaFinal1 = 2*pontuacaoAtleta1
                    textCapitaoAtleta1 = "(Capitão)"
                else
                    pontuacaoAtletaFinal1 = pontuacaoAtleta1
                    textCapitaoAtleta1 = ""
                end

                @atleta1 = [nomeAtleta1,posicaoAtleta1,posicaoAtletaFinal1,pontuacaoAtletaFinal1,textCapitaoAtleta1]




                idAtleta2 = JSON.parse(resp.body)["atletas"][1]["id"]
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
                pontuacaoAtleta2 = JSON.parse(resp.body)["atletas"][1]["pontos_num"]
                if idAtleta2 == capitao
                    pontuacaoAtletaFinal2 = 2*pontuacaoAtleta2
                    textCapitaoAtleta2 = "(Capitão)"
                else
                    pontuacaoAtletaFinal2 = pontuacaoAtleta2
                    textCapitaoAtleta2 = ""
                end

                @atleta2 = [nomeAtleta2,posicaoAtleta2,posicaoAtletaFinal2,pontuacaoAtletaFinal2,textCapitaoAtleta2]





                idAtleta3 = JSON.parse(resp.body)["atletas"][2]["id"]
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
                pontuacaoAtleta3 = JSON.parse(resp.body)["atletas"][2]["pontos_num"]
                if idAtleta3 == capitao
                    pontuacaoAtletaFinal3 = 2*pontuacaoAtleta3
                    textCapitaoAtleta3 = "(Capitão)"
                else
                    pontuacaoAtletaFinal3 = pontuacaoAtleta3
                    textCapitaoAtleta3 = ""
                end

                @atleta3 = [nomeAtleta3,posicaoAtleta3,posicaoAtletaFinal3,pontuacaoAtletaFinal3,textCapitaoAtleta3]



                idAtleta4 = JSON.parse(resp.body)["atletas"][3]["id"]
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
                pontuacaoAtleta4 = JSON.parse(resp.body)["atletas"][3]["pontos_num"]
                if idAtleta4 == capitao
                    pontuacaoAtletaFinal4 = 2*pontuacaoAtleta4
                    textCapitaoAtleta4 = "(Capitão)"
                else
                    pontuacaoAtletaFinal4 = pontuacaoAtleta4
                    textCapitaoAtleta4 = ""
                end

                @atleta4 = [nomeAtleta4,posicaoAtleta4,posicaoAtletaFinal4,pontuacaoAtletaFinal4,textCapitaoAtleta4]




                idAtleta5 = JSON.parse(resp.body)["atletas"][4]["id"]
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
                pontuacaoAtleta5 = JSON.parse(resp.body)["atletas"][4]["pontos_num"]
                if idAtleta5 == capitao
                    pontuacaoAtletaFinal5 = 2*pontuacaoAtleta5
                    textCapitaoAtleta5 = "(Capitão)"
                else
                    pontuacaoAtletaFinal5 = pontuacaoAtleta5
                    textCapitaoAtleta5 = ""
                end

                @atleta5 = [nomeAtleta5,posicaoAtleta5,posicaoAtletaFinal5,pontuacaoAtletaFinal5,textCapitaoAtleta5]


                idAtleta6 = JSON.parse(resp.body)["atletas"][5]["id"]
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
                pontuacaoAtleta6 = JSON.parse(resp.body)["atletas"][5]["pontos_num"]
                if idAtleta6 == capitao
                    pontuacaoAtletaFinal6 = 2*pontuacaoAtleta6
                    textCapitaoAtleta6 = "(Capitão)"
                else
                    pontuacaoAtletaFinal6 = pontuacaoAtleta6
                    textCapitaoAtleta6 = ""
                end

                @atleta6 = [nomeAtleta6,posicaoAtleta6,posicaoAtletaFinal6,pontuacaoAtletaFinal6,textCapitaoAtleta6]


                idAtleta7 = JSON.parse(resp.body)["atletas"][6]["id"]
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
                pontuacaoAtleta7 = JSON.parse(resp.body)["atletas"][6]["pontos_num"]
                if idAtleta7 == capitao
                    pontuacaoAtletaFinal7 = 2*pontuacaoAtleta7
                    textCapitaoAtleta7 = "(Capitão)"
                else
                    pontuacaoAtletaFinal7 = pontuacaoAtleta7
                    textCapitaoAtleta7 = ""
                end

                @atleta7 = [nomeAtleta7,posicaoAtleta7,posicaoAtletaFinal7,pontuacaoAtletaFinal7,textCapitaoAtleta7]




                idAtleta8 = JSON.parse(resp.body)["atletas"][7]["id"]
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
                pontuacaoAtleta8 = JSON.parse(resp.body)["atletas"][7]["pontos_num"]
                if idAtleta8 == capitao
                    pontuacaoAtletaFinal8 = 2*pontuacaoAtleta8
                    textCapitaoAtleta8 = "(Capitão)"
                else
                    pontuacaoAtletaFinal8 = pontuacaoAtleta8
                    textCapitaoAtleta8 = ""
                end

                @atleta8 = [nomeAtleta8,posicaoAtleta8,posicaoAtletaFinal8,pontuacaoAtletaFinal8,textCapitaoAtleta8]


                idAtleta9 = JSON.parse(resp.body)["atletas"][8]["id"]
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
                pontuacaoAtleta9 = JSON.parse(resp.body)["atletas"][8]["pontos_num"]
                if idAtleta9 == capitao
                    pontuacaoAtletaFinal9 = 2*pontuacaoAtleta9
                    textCapitaoAtleta9 = "(Capitão)"
                else
                    pontuacaoAtletaFinal9 = pontuacaoAtleta9
                    textCapitaoAtleta9 = ""
                end

                @atleta9 = [nomeAtleta9,posicaoAtleta9,posicaoAtletaFinal9,pontuacaoAtletaFinal9,textCapitaoAtleta9]


                idAtleta10 = JSON.parse(resp.body)["atletas"][9]["id"]
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
                pontuacaoAtleta10 = JSON.parse(resp.body)["atletas"][9]["pontos_num"]
                if idAtleta10 == capitao
                    pontuacaoAtletaFinal10 = 2*pontuacaoAtleta10
                    textCapitaoAtleta10 = "(Capitão)"
                else
                    pontuacaoAtletaFinal10 = pontuacaoAtleta10
                    textCapitaoAtleta10 = ""
                end

                @atleta10 = [nomeAtleta10,posicaoAtleta10,posicaoAtletaFinal10,pontuacaoAtletaFinal10,textCapitaoAtleta10]


                idAtleta11 = JSON.parse(resp.body)["atletas"][10]["id"]
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
                pontuacaoAtleta11 = JSON.parse(resp.body)["atletas"][10]["pontos_num"]
                if idAtleta11 == capitao
                    pontuacaoAtletaFinal11 = 2*pontuacaoAtleta11
                    textCapitaoAtleta11 = "(Capitão)"
                else
                    pontuacaoAtletaFinal11 = pontuacaoAtleta11
                    textCapitaoAtleta11 = ""
                end

                @atleta11 = [nomeAtleta11,posicaoAtleta11,posicaoAtletaFinal11,pontuacaoAtletaFinal11,textCapitaoAtleta11]





                idAtleta12 = JSON.parse(resp.body)["atletas"][11]["id"]
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
                pontuacaoAtleta12 = JSON.parse(resp.body)["atletas"][11]["pontos_num"]
                if idAtleta12 == capitao
                    pontuacaoAtletaFinal12 = 2*pontuacaoAtleta12
                    textCapitaoAtleta12 = "(Capitão)"
                else
                    pontuacaoAtletaFinal12 = pontuacaoAtleta12
                    textCapitaoAtleta12 = ""
                end

                @atleta12 = [nomeAtleta12,posicaoAtleta12,posicaoAtletaFinal12,pontuacaoAtletaFinal12,textCapitaoAtleta12]


                @atletas_escolhidos = Array[@atleta1,@atleta2,@atleta3,@atleta4,@atleta5,@atleta6,@atleta7,@atleta8,@atleta9,@atleta10,@atleta11,@atleta12]

                @atletas = @atletas_escolhidos.sort_by {|h| -h[1]}



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
