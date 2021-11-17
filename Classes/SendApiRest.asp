
<!--#include file="./../connect.asp"-->
<%
Function webhook(EventId, Async, replaceFrom, replaceTo)

'VERIFICA SE O EVENTOID É NÚMERO PARA CONSULTAR NO CLINICCENTRAL O EVENTO WEBHOOK CADASTRADO
if isnumeric(EventID) then

  checkEndPointSQL =  " SELECT webEnd.id, webEnd.URL, webEve.Metodo, webEve.id evento_id, webEve.ModeloJSON FROM `cliniccentral`.`webhook_eventos` webEve "&chr(13)&_
                      " LEFT JOIN `cliniccentral`.`webhook_endpoints` webEnd ON webEnd.EventoID = webEve.id                                               "&chr(13)&_
                      " WHERE webEnd.LicencaID="&replace(session("Banco"),"clinic","")&" AND webEve.id="&EventId&"  AND webEve.Ativo='S'"
    
  SET  checkEndPoint = db.execute(checkEndPointSQL)
  if not checkEndPoint.eof then

    webhook_eventID  = checkEndPoint("evento_id")
    webhook_method   = checkEndPoint("Metodo")
    webhook_endpoint = checkEndPoint("URL")
    webhook_body     = checkEndPoint("ModeloJSON")
    webhook_header   = checkEndPoint("id") 'HEADER CUSTOMIZADO

    'TRATAMENTO DAS TAGS QUE SÃO PADRÃO DO SISTEMA ARMAZENADOS NA SESSÃO OU GERADO PELO SISTEMA
    if instr(webhook_body, "[Sistema.") > 0 then
      webhook_body = replace(webhook_body, "[Sistema.Licenca]", replace(session("Banco"),"clinic","") )
      webhook_body = replace(webhook_body, "[Sistema.Extenso]", formatdatetime(date(),1) )
      webhook_body = replace(webhook_body, "[Data.DDMMAAAA]", "[Sistema.Data]" )
      webhook_body = replace(webhook_body, "[Sistema.Data]",date())
      webhook_body = replace(webhook_body, "[Sistema.Hora]", time())
    end if

    'VERIFICA SE O REPLACEFROM É MÚLTIPLO E FAZ O TRATAMENTO ADEQUADO
    if instr(replaceFrom, "|,") > 0 then
      
      replaceFromArray = split(replaceFrom, "|,")
      replaceToArray   = split(replaceTo, "|,")

      'VALIDA A QNT DE REGISTROS DE VERIFICA DE replaceFrom E replaceTo
      if UBound(replaceFromArray) = UBound(replaceToArray) then
        itemID_atual = -1
        for each replaceFromValor in replaceFromArray

          itemNome = replace(replaceFromValor, "|", "")

          itemID_atual = itemID_atual+1        
          itemID       = replace(replaceToArray(itemID_atual),"|","")

          'PREPARA QUERYS E INFORMA O NOME DE CADA MÓDULO QUE FOI PASSADO  ATRAVÉS DO "replaceFrom"
          select case itemNome

            case "PacienteID"
              ModuleName = "Paciente" 
              ModuleSQL = "SELECT                                                                                          "&chr(13)&_
                    "p.NomePaciente as Nome,COALESCE(p.Cel1,p.Cel2,0) AS Celular, COALESCE(p.Email1,p.Email2,0) AS Email,  "&chr(13)&_
                    "c1.NomeConvenio AS 'Convenio1', c2.NomeConvenio AS 'Convenio2',c3.NomeConvenio AS 'Convenio3',        "&chr(13)&_
                    "pla1.NomePlano AS 'Plano1', pla2.NomePlano AS 'Plano2',pla3.NomePlano AS 'Plano3',                    "&chr(13)&_
                    "ec.EstadoCivil, s.NomeSexo AS Sexo, g.GrauInstrucao, o.Origem, corPel.NomeCorPele,                    "&chr(13)&_
                    "pacrel.CPFParente AS ResponsavelCPF, pacrel.Nome AS ResponsavelNome                                   "&chr(13)&_
                    "FROM pacientes AS p                                                                                   "&chr(13)&_
                    "LEFT JOIN estadocivil AS ec ON ec.id=p.EstadoCivil                                                    "&chr(13)&_
                    "LEFT JOIN sexo AS s ON s.id=p.Sexo                                                                    "&chr(13)&_
                    "LEFT JOIN grauinstrucao AS g ON g.id=p.GrauInstrucao                                                  "&chr(13)&_
                    "LEFT JOIN origens AS o ON o.id=p.Origem                                                               "&chr(13)&_
                    "LEFT JOIN convenios c1 ON c1.id=p.ConvenioID1                                                         "&chr(13)&_
                    "LEFT JOIN convenios c2 ON c2.id=p.ConvenioID2                                                         "&chr(13)&_
                    "LEFT JOIN convenios c3 ON c3.id=p.ConvenioID3                                                         "&chr(13)&_
                    "LEFT JOIN conveniosplanos pla1 ON pla1.id=p.PlanoID1                                                  "&chr(13)&_
                    "LEFT JOIN conveniosplanos pla2 ON pla2.id=p.PlanoID2                                                  "&chr(13)&_
                    "LEFT JOIN conveniosplanos pla3 ON pla3.id=p.PlanoID3                                                  "&chr(13)&_
                    "LEFT JOIN corpele corPel ON corPel.id=p.`CorPele`                                                     "&chr(13)&_
                    "LEFT JOIN pacientesrelativos AS pacrel ON pacrel.PacienteID=p.id AND pacrel.Dependente='S'            "&chr(13)&_
                    "where p.id="&treatvalzero(itemID)                                                                      &chr(13)&_
                    "GROUP BY p.id"
              
            case "EventoID"
              ModuleName = "Evento"
              ModuleSQL = "SELECT eve.id, IF(eve.AntesDepois='A','subtract','add') AS AntesDepois, eve.IntervaloHoras, "&chr(13)&_
                          "eveW.Nome AS WhatsAppModelo, sysSmsEma.TextoEmail AS EmailModelo,                           "&chr(13)&_
                          "sysSmsEma.TituloEmail AS EmailAssunto, sysSmsEma.TextoSMS AS SmsModelo                      "&chr(13)&_
                          "FROM eventos_emailsms eve                                                                   "&chr(13)&_
                          "LEFT JOIN sys_smsemail sysSmsEma ON sysSmsEma.id = eve.ModeloID                             "&chr(13)&_
                          "LEFT JOIN cliniccentral.eventos_whatsapp eveW ON eveW.id = sysSmsEma.EventosWhatsappID      "&chr(13)&_
                          "where eve.id="&treatvalzero(itemID)

            case "AgendamentoID"
              ModuleName = "Agendamento"
              ModuleSQL  = "SELECT "&chr(13)&_
                           "DATE_FORMAT(a.Data, '%Y')*1 Ano, DATE_FORMAT(a.Data, '%m')*1 Mes, DATE_FORMAT(a.Data, '%d')*1 Dia, TIME_FORMAT(a.Hora, '%H')*1 AS Hora, TIME_FORMAT(a.Hora, '%m')*1 AS Minuto, "&chr(13)&_
                           "a.id, a.Data, a.TipoCompromissoID,  a.StaID,  a.ValorPlano,  a.rdValorPlano,  a.Notas,  a.Falado,  a.FormaPagto,  a.LocalID,  a.Tempo,  a.HoraFinal,  a.SubtipoProcedimentoID,  a.HoraSta,  a.ConfEmail,  a.ConfSMS,  a.Encaixe,  a.EquipamentoID,  a.NomePaciente,  a.Tel1,  a.Cel1,  a.Email1, a.Procedimentos,  a.EspecialidadeID,  a.IndicadoPor,  a.TabelaParticularID,  a.CanalID,  a.Retorno,  a.RetornoID,  a.Primeira,  a.PlanoID, a.PermiteRetorno, esp.Especialidade "&chr(13)&_
                           "FROM agendamentos a "&chr(13)&_
                           "LEFT JOIN especialidades esp ON esp.id = a.EspecialidadeID "&chr(13)&_
                           "WHERE a.id="&treatvalzero(itemID)  

            case "ProfissionalID"
              ModuleName =  "Profissional"
              ModuleSQL  =  "SELECT f.id FornecedorID, prof.RQE, prof.Conselho, prof.NomeProfissional, prof.NomeProfissional as Nome, t.Tratamento, cp.descricao, COALESCE(f.NomeFornecedor, prof.NomeProfissional) RazaoSocial, f.CPF CPFCNPJ , CONCAT(IF(t.Tratamento is null,'',concat(t.Tratamento,' ')),IF(prof.NomeSocial is null or prof.NomeSocial ='', SUBSTRING_INDEX(prof.NomeProfissional,' ', 1), prof.NomeSocial)) PrimeiroNome, "&chr(13)&_
                            "CONCAT(cp.descricao, ' ', prof.DocumentoConselho, ' ', prof.UFConselho) Documento, prof.Assinatura, prof.DocumentoConselho, prof.CPF, prof.NomeSocial, esp.especialidade Especialidade "&chr(13)&_
                            "FROM profissionais prof "&chr(13)&_
                            "LEFT JOIN conselhosprofissionais cp ON cp.id=prof.Conselho "&chr(13)&_
                            "LEFT JOIN especialidades esp ON esp.id=prof.EspecialidadeID "&chr(13)&_
                            "LEFT JOIN fornecedores f ON f.id=prof.FornecedorID "&chr(13)&_
                            "LEFT JOIN tratamento t ON t.id=prof.TratamentoID "&chr(13)&_
                            "WHERE prof.id="&treatvalzero(itemID)

            case "ProcedimentoID"
              ModuleName = "Procedimento"
              ModuleSQL = "SELECT p.NomeProcedimento as Nome, p.DiasLaudo, p.TextoPreparo, t.TipoProcedimento "&chr(13)&_
                          "FROM procedimentos p "&chr(13)&_
                          "LEFT JOIN tiposprocedimentos t ON t.id=p.TipoProcedimentoID "&chr(13)&_
                          "WHERE p.id="&treatvalzero(itemID)

            case "UnidadeID"
              ModuleName = "Unidade"
              ModuleSQL =  "SELECT "&chr(13)&_
                           "CONCAT( "&chr(13)&_
                           "uni.Endereco, "&chr(13)&_
                           "COALESCE(CONCAT(', ',uni.Numero),''), "&chr(13)&_
                           "COALESCE(CONCAT(' ',uni.Complemento),''), "&chr(13)&_
                           "COALESCE(CONCAT(' - ',uni.Bairro),''), "&chr(13)&_
                           "COALESCE(CONCAT(', ',uni.Cidade),''), "&chr(13)&_
                           "COALESCE(CONCAT(' (',uni.Estado,')'),'') "&chr(13)&_
                           ") AS EnderecoCompleto, "&chr(13)&_
                           "COALESCE(uni.NomeFantasia,uni.NomeEmpresa,'Indefinido') AS Nome, COALESCE(uni.Tel1, uni.Tel2, 0) AS Telefone, "&chr(13)&_
                           "uni.* "&chr(13)&_
                           "FROM vw_unidades AS uni "&chr(13)&_
                           "WHERE uni.id="&treatvalzero(itemID)  

          end select
          
          SET moduleValue = db.execute(ModuleSQL)

          'CONSULTA O NOME DAS COLUNAS ATRAVÉS DA TABELA "cliniccentral.tags"
          tagsValidateSQL = "SELECT * FROM cliniccentral.tags tag "&chr(13)&_
                            "LEFT JOIN cliniccentral.tags_categorias cat ON cat.id=tag.tags_categorias_id "&chr(13)&_
                            "WHERE cat.categoria='"&ModuleName&"'"

          set tagsValidate = db.execute(tagsValidateSQL)

          if not tagsValidate.eof then

            while not tagsValidate.eof

              tagName = tagsValidate("tagNome")
              columnName = replace(tagsValidate("tagNome"),ModuleName&".","")

              'SE HOUVER ["tagName"] NO "webhook_body" ACIONA O REPLACE DE FORMA DINÂMICA
              if instr(webhook_body, tagName) > 0 then
                'IGNORA ERROS PARA EVITAR INTERRUPÇÕES NO SISTEMA 
                On error Resume Next
                webhook_body = replace(webhook_body, "["&tagName&"]", moduleValue(columnName))

                If Err.number <> 0 then
                  'CASO ALGUM VALOR NÃO SEJA CONVERTIDO, ALTERE O VALOR DE "ativaDebug" PARA true
                  '*** NÃO SUBIR  ativaDebug = true PARA PRODUÇÃO ***
                  ativaDebug = false
                  if ativaDebug = true then
                    response.write("<hr>")
                    response.write("<strong>ASPDescription: </strong>" & Err.description & "<br>" )

                    response.write("<strong>TagName: </strong> [" & tagName & "]<br>" )
                    response.write("<strong>ColumnName: </strong> " & columnName & "<br>" )
                  end if
                End If
              end if

              Err.Clear

            tagsValidate.moveNext
            wend
          end if
          tagsValidate.close
          set tagsValidate = nothing

          moduleValue.close
          set moduleValue = nothing
          
        next

      end if

    else
      'WEBHOOK ANTIGO replaceFrom / replaceTo 1 PARA 1
      webhook_body     = replace(webhook_body, replaceFrom,replaceTo)

    end if

    CALL sendWebAPI(webhook_endpoint, webhook_body, webhook_method, True, Token, webhook_header)

  end if
  checkEndPoint.close
  set checkEndPoint = nothing
end if

End Function

'***
'ENVIO API REST VIA ASP
'
Function sendWebAPI(EndPoint, Content, Method, Async, Token, EndPointHeader) 

  if Async= false then
    Set xmlhttp = CreateObject("MSXML2.serverXMLHTTP") 'NÃO FUNCIONANDO ASYNC
  else
    Set xmlhttp = CreateObject("Microsoft.XMLHTTP") 'NÃO FUNCIONANDO SYNC
  end if  
  xmlhttp.Open Method, EndPoint, Async

  if isnumeric(EndPointHeader) then
  set webHookHeader = db.execute("SELECT * FROM cliniccentral.webhook_header where endPointID="&EndPointHeader)
  if not webHookHeader.eof then
    while not webHookHeader.eof
      xmlhttp.setRequestHeader webHookHeader("header"), webHookHeader("value")
    webHookHeader.movenext
    wend
  end if
    webHookHeader.close
    set webHookHeader = nothing
  end if  

  xmlhttp.Send Content

  if Async= false then 
    If xmlhttp.Status = 200 Then
      message = xmlhttp.responseText
    Else
      message = xmlhttp.Status & ": " & xmlhttp.statusText
    End If

    response.write(message)
  end if  

  Set xmlhttp = Nothing

End Function
%>