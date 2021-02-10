<!--#include file="./../connect.asp"-->
<!--#include file="./../md5.asp"-->
<!--#include file="./StringFormat.asp"-->
<%
'VERIFICA SE LOGS ESTÁ CONFIGURADO NA VARIÁVEL DE AMBIENTE
logsJsonActive = false
set shellExec = createobject("WScript.Shell")
Set objSystemVariables = shellExec.Environment("SYSTEM")
  if UCASE(objSystemVariables("LOG_FORMAT"))="JSON" then
    logsJsonActive = true
  end if
set shellExec = nothing
Set objSystemVariables=nothing

function hashRand()
  'BIBLIOTECA DESATIVADA DEVIDO FALTA DE DLL NO SERVER DE PRODUÇÃO
  'set hashRandom = Server.CreateObject("Chilkat_9_5_0.Prng")
  '  hashRand = md5(now()&Server.HTMLEncode( hashRandom.RandomInt(12,24)))
  'set hashRandom = nothing
  hashRand = md5(session("Banco")&session("user")& now())
end function

function executeSQL(query,actionError,Description,Hash)
  QueryFiltraAcao = trim(split(query, "(")(0))
  QueryFiltraAcao = replace(QueryFiltraAcao,"  ", " ")
  QueryFiltraAcao = lcase(split(QueryFiltraAcao, " ")(0))
  select case actionError
    case 0 'NÃO EXECUTA QUERY
      msgErro = "NÃO EXECUTA QUERY"
    case 1 'PROSSEGUE MESMO COM ERRO
      msgErro = "PROSSEGUE MESMO COM ERRO"
    case 2 'INTERROMPE PROCESSO
      msgErro = "INTERROMPE PROCESSO"
    case 3 'INTERROMPE PROCESSO E SOLICITA AO USUÁRIO ATUALIZAÇÃO DA PÁGINA
      msgErro = "INTERROMPE PROCESSO E SOLICITA AO USUÁRIO ATUALIZAÇÃO DA PÁGINA"
  end select

  On error Resume Next
  db.execute(Query)

  if Err<>0 then

    error_hash = Hash
    erroExecucao_descricao  = Err.Description
    ASPCode                 = Err.ASPCode
    ASPDescription          = Err.ASPDescription
    erroExecucao_linha      = Err.Line
    cliente_id              = replace(session("Banco"),"clinic","")
    p(10)
    erroExecucao_numero     = Err.Number
    erroExecucao_data       = now()

    erroExecucao_Devs = "{"&_
      """asp_code"":"""&ASPCode&""","&_
      """asp_description"":"""&ASPDescription&""","&_
      """result_expected"":"""&Description&""","&_
      """error_number"":"""&erroExecucao_numero&""","&_
      """error_line"":"""&erroExecucao_linha&""","&_
      """error_description"":"""&erroExecucao_descricao&""","&_
      """reference"":"""&request.servervariables("URL")&""","&_
      """query"":"""&Query&""","&_
      """data"":"""&erroExecucao_data&""","&_
      """client_id"":"""&cliente_id&""","&_
      """hash"":"""&error_hash&""""&_
    "}"

    'NOTIFICAÇÃO PARA O CLIENTE INICIO
    erroExecucao_Clients = "<script>"&_
    "new PNotify({"&_
      "title: 'Erro na execução!',"&_
      "text: 'Código: "&error_hash&"',"&_
      "type: 'alert',"&_
      "delay: 5000"&_
    "});"&_
    "</script>"
    'response.write(erroExecucao_Clients)
    'NOTIFICAÇÃO PARA O CLIENTE FIM
    
    '## ENVIA ERRO PARA LAMBDA > CLOUDWATCH (ASYNC)
    endPoint  = "https:'functions.feegow.com/log"
    content   = "{"&_
      """json"":"&erroExecucao_Devs&","&_
      """tags"":["&cliente_id&"]"&_
    "}"          
    'response.write(content)
    
    Set http = Server.CreateObject("WinHttp.WinHttpRequest.5.1")
    url = endPoint
    data = content
    With http
      Call .Open("POST", url, true) 'ASYNC = true
      Call .SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
      Call .SetRequestHeader("X-Api-Key", "[X-Api-Key]")
      Call .SetRequestHeader("X-Auth-Token", "[X-Auth-Token]")
      Call .Send(data)
    End With
    'If http.Status = 201 Then
      'Call Response.Write("succeeded: " & http.Status & " " & http.StatusText)
    'Else
      'Call Response.Write("Server returned: " & http.Status & " " & http.StatusText)
    'End If
    
    Err.Clear

  else

    if instr(QueryFiltraAcao, "select")>0 then
      '############APENAS SELECT SEM WHILE PARA OS LOGS
        Set rs = db.Execute(query)
        sql_logsJson = replace(rs("logsJson")&"","EX_FW","")
        'response.write(sql_logsJson)
        executeSQL = sql_logsJson
        
        rs.close
        set rs = nothing
    elseif instr(QueryFiltraAcao, "insert")>0 or instr(QueryFiltraAcao, "update")>0 then
      db.execute(Query)
    elseif instr(QueryFiltraAcao, "delete")>0 then
      response.write("Função não preparada para DELETE!")
      response.end()
    end if

  end if


end function
function logsJson(Module, Query, Action, QueryWhere)
'***
'Module = Módulo em que o log foi gerado;
'Query  = Query que foi executada (somente query de ações simples "insert into", update e delete);
'Action = Tipo a ação executada no módulo
'OBS.: É possível que durante a edição de um módulo sejam executados updates e deletes.
'***'
    'VERIFICA O TIPO DE AÇÃO EXECUTADA NA QUERY
    QueryFiltraAcao = trim(split(Query, "(")(0))
    QueryFiltraAcao = replace(QueryFiltraAcao,"  ", " ")
    
    if instr(lcase(split(QueryFiltraAcao, " ")(0)),"insert")>0 then
        queryAcao   = "insert"
        queryTabela = split(QueryFiltraAcao, " ")(2)
        queryColunas = split(Query, "(")(1)
        queryColunas = split(queryColunas, ")")(0)
        queryValores = trim(split(Query, "VALUES")(1))
        queryWhere = "AND LAST_INSERT_ID(id)=(SELECT max(id) FROM profissionais WHERE sysUser="&session("user")&")"
        executaAcaoInicio=false
        executaAcaoFim =true

        logsDescricao = "Novo registro no módulo "&Module
        
    elseif instr(lcase(split(QueryFiltraAcao, " ")(0)),"update")>0 then
        queryAcao    = "update"
        queryTabela  = split(QueryFiltraAcao, " ")(1)
        
        query_colunasConteudo = trim(split(QueryFiltraAcao, queryTabela)(1))
        query_colunasConteudo = mid(query_colunasConteudo, 4, len(query_colunasConteudo))
        query_colunasConteudo = RemoveCaracters(query_colunasConteudo,"` ")
        qColunasCheck = "SELECT GROUP_CONCAT(CONCAT('`',c.COLUMN_NAME,'`')) 'COLUMN_NAME' FROM INFORMATION_SCHEMA.COLUMNS AS c "&_
                         "WHERE TABLE_NAME = '"&queryTabela&"' AND TABLE_SCHEMA = '"&session("Banco")&"'"
        set ColunasCheck = db.execute(qColunasCheck)
          colunn_name = ColunasCheck("COLUMN_NAME")
        ColunasCheck.close
        set ColunasCheck = nothing
        'SEPARA A COLUNA DO CONTEÚDO
        query_colunasConteudoArray = split(query_colunasConteudo,",")
        colunnName_array = split(colunn_name,",")
        For query_colunasConteudoID = 0 to Ubound(query_colunasConteudoArray)
          coluna_conteudo = query_colunasConteudoArray(query_colunasConteudoID)
          query__Coluna = "`"&split(coluna_conteudo, "=")(0)&"`"
          
          'VALIDA AS COLUNAS DE ACORDO COM O SCHEMA DA TABELA
          For i_ColunnName = 0 to Ubound(colunnName_array)
            if query__Coluna=colunnName_array(i_ColunnName) then
              if queryColunas = "" then
                queryColunas = query__Coluna
              else
                queryColunas = queryColunas&", "&query__Coluna
              end if
            end if
          next
        next
        executaAcaoInicio=true
        executaAcaoFim=true

        logsDescricao = "Alteração no módulo "&Module
        
    elseif instr(lcase(split(QueryFiltraAcao, " ")(0)),"delete")>0 then
        queryAcao   = "delete"
        queryTabela = split(QueryFiltraAcao, " ")(2)

        logsDescricao = "Registro removido no módulo "&Module
    end if
    'GERA CONSULTA FORMATO JSON
    queryColunas_array = Split(replace(queryColunas,"`",""),",")
    For Coluna = 0 to Ubound(queryColunas_array)
      colunaJsonModelo = "'"&trim(queryColunas_array(Coluna))&"',`"&trim(queryColunas_array(Coluna))&"`"
      if colunaJson="" then
        colunaJson = "'id',`id`,"&colunaJsonModelo
      else
        colunaJson = colunaJson&","&colunaJsonModelo
      end if
    Next
    trataErroAspJson = "EX_FW"
    qSelectJson = "SELECT CONCAT('"&trataErroAspJson&"',JSON_OBJECT("&_
                  colunaJson&_
                ")) AS 'logsJson' "&_
                "from "&queryTabela&" "&_
                "WHERE "&queryWhere '################# WHERE:: UPDATE OK >> INSERT LAST INTO >> DELETE OK
    
    'response.write(qSelectJson&"<br>")
    logsHash       = hashRand()
    logsReferencia = "{""Module"":"&Module&", ""ModuleAction"":"&Action&", ""query"":"&queryAcao&"}"    

    '######## EXECUTA QUERYS INSERT/UPDATE/DELETE 
    if executaAcaoInicio=true then
      'response.write("<strong>Valor OLD: </strong>"&qSelectJson)
      gravaLogValorOLD = executeSQL(qSelectJson,0,"Verificar dados e gravar logs OLD",logsHash)
      'response.write("<hr>"&gravaLogValorOLD&"<hr>")
    end if

      'response.write("<br><strong>Query a executar: </strong><pre>"&Query&"</pre><hr>")
      acaoSQL = executeSQL(Query,1,"Alterar dados do profissional",logsHash)
      
    if executaAcaoFim=true then
      'response.write("<br><strong>Valor NEW: </strong>"&qSelectJson)
      gravaLogValorNovo = executeSQL(qSelectJson,0,"Verificar dados e gravar logs NEW",logsHash)
      'response.write("<br><strong>Valor NEW: </strong>"&gravaLogValorNovo)
      
    end if

    'GRAVA OS LOGS NO BANCO MYSQ PROVISORIAMENTE #####
    'ALTERAR DB.EXECUTE PARA FUNÇÃO SQL
    
    if gravaLogValorOLD<>gravaLogValorNovo then
      
      insertLogPROVISORIO = "insert into log(valorAnterior,valorAtual,Obs,Hash,Referencia,sysUser) "&_
      "VALUES('"&gravaLogValorOLD&"','"&gravaLogValorNovo&"','"&logsDescricao&"','"&logsHash&"','"&logsReferencia&"',"&session("User")&")"
      'response.write("<hr><B>TESTE SALVA LOGS</b><BR>"&insertLogPROVISORIO&"<hr>")
      db.execute(insertLogPROVISORIO)
    end if
    
end function
'querys
'querySQL = " INSERT  INTO `Profissionais` (`NomeProfissional`, `EspecialidadeID`, `CPF`) VALUES ('TESTE',0,'112-204-xxxx/0000');"
'querySQL = "UPDATE profissionais SET `id`=216, `NomeProfissional`='Airton Baptista', `DocumentoConselho`='X"&now()&"' WHERE `id`=216;"
'querySQL = "DELETE FROM `Profissionais` WHERE  `id`=1;"
'call logsJson("Profissional",querySQL,"Update","`id`=216")
%> 
