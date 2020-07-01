<!--#include file="./../connect.asp"-->
<%
'Dim variavel
'Dim i
'For Each variavel in Session.Contents
'If IsArray(Session(variavel)) then
'For i = LBound(Session(variavel)) to UBound(Session(variavel))
'Response.Write variavel & "(" & i & ") – " & _
'Session(variavel)(i) & "<BR>"
'Next
'Else
'Response.Write variavel & " – " & Session.Contents(variavel) & "<BR>"
'End If
'Next

function tagsConverte(conteudo,itens,moduloExcecao)
  'EXEMPLO: DE USO DESTA FUNÇÃO
  'conteudo = "Atesto que o paciente [Paciente.Nome]<br>foi atendido as [Sistema.Hora]<br>pelo profissional [Profissional.Nome]"
  'response.write(tagsConverte(conteudo,Profissional_4754|Paciente_7854|Sistema_0,""))
  'moduloExcecao: São configurações específicas que um módulo pode ter, neste caso crie a exceção em um CASE/IF

  '**IMAGEM NAO EXISTE
  img404Base64      = "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"
  img404            ="onerror='this.src=`data:image/png;base64,"&img404Base64&"`"
  imgURLPathDefault = "https://clinic7.feegow.com.br/uploads/"&replace(Session("Banco"),"clinic","")&"/Imagens"
  'EXEMPLO DE USO
  'response.write("<img src='imagem-nao-existe.png'" & img404&">")

  'CONVERSAO DA CATEGORIA SISTEMA É PADRÃO
  itens = itens&"|Sistema_0"

  '### FILTRA OS ITENS SEPARADOS POR PIPE
  itensArray=Split(itens,"|")
  for each itensValor in itensArray

    '### <SEPARA OS ITENS SEPARADOS POR UNDERLINE>
    itemArray = split(itensValor, "_")
    item_nome = itemArray(0)&""
    item_id   = itemArray(1)&""

    select case item_nome
      case "PacienteID"
        PacienteID          = item_id
      case "ProfissionalID"
        ProfissionalID      = item_id
      case "ProfissionalSessao"
        ProfissionalSessao  = item_id
      case "UnidadeSessao"
        UnidadeSessao       = item_id


    end select

  next
  '### <FILTRA OS ITENS SEPARADOS POR PIPE/>

  SET tagsCategoriasSQL = db.execute("select categoria from cliniccentral.tags_categorias")
  while not tagsCategoriasSQL.eof

    tagsCategoria = tagsCategoriasSQL("categoria")

    'CHECA SE FOI INSERIDA A TAG PERTENCENTE A UMA CATEGORIA EXISTENTE 
    if instr(conteudo, "["&tagsCategoria&".")>0 then
      select case tagsCategoria
        case "Paciente"
          qPacientesSQL = "SELECT  "&_
          "c1.NomeConvenio AS 'Convenio1', c2.NomeConvenio AS 'Convenio2',c3.NomeConvenio AS 'Convenio3'  "&_
          ",pla1.NomePlano AS 'Plano1', pla2.NomePlano AS 'Plano2',pla3.NomePlano AS 'Plano3'  "&_
          ",p.*, ec.EstadoCivil, s.NomeSexo as Sexo, g.GrauInstrucao, o.Origem  "&_
          "from pacientes as p  "&_
          "left join estadocivil as ec on ec.id=p.EstadoCivil  "&_
          "left join sexo as s on s.id=p.Sexo  "&_
          "left join grauinstrucao as g on g.id=p.GrauInstrucao  "&_
          "left join origens as o on o.id=p.Origem  "&_
          "LEFT JOIN convenios c1 ON c1.id=p.ConvenioID1  "&_
          "LEFT JOIN convenios c2 ON c2.id=p.ConvenioID2  "&_
          "LEFT JOIN convenios c3 ON c3.id=p.ConvenioID3  "&_
          "LEFT JOIN conveniosplanos pla1 ON pla1.ConvenioID=c1.id  "&_
          "LEFT JOIN conveniosplanos pla2 ON pla2.ConvenioID=c2.id  "&_
          "LEFT JOIN conveniosplanos pla3 ON pla3.ConvenioID=c3.id  "&_
          "where p.id="&treatvalzero(PacienteID) 

          SET PacientesSQL = db.execute(qPacientesSQL)
            if not PacientesSQL.eof then
              conteudo = replace(conteudo,"[Paciente.Nome]",PacientesSQL("NomePaciente"))

              conteudo = replace(conteudo, "[Paciente.Idade]", idade(PacientesSQL("Nascimento")))
              conteudo = replace(conteudo, "[Paciente.Nascimento]", PacientesSQL("Nascimento")&"")
              conteudo = replace(conteudo, "[Paciente.Documento]", PacientesSQL("Documento")&"")
              conteudo = replace(conteudo, "[Paciente.Prontuario]", PacientesSQL("id"))

              'POSSIBILIDADE DE UTILIZAR PLANOS E CONVENIOS SECUNDÁRIOS
              conteudo = replace(conteudo, "[Paciente.Convenio1]", PacientesSQL("Convenio1")&"")
              conteudo = replace(conteudo, "[Paciente.Convenio2]", PacientesSQL("Convenio2")&"")
              conteudo = replace(conteudo, "[Paciente.Convenio3]", PacientesSQL("Convenio3")&"")
              conteudo = replace(conteudo, "[Paciente.Plano1]", PacientesSQL("Plano1")&"")
              conteudo = replace(conteudo, "[Paciente.Plano2]", PacientesSQL("Plano2")&"")
              conteudo = replace(conteudo, "[Paciente.Plano3]", PacientesSQL("Plano3")&"")
              'REDUNDANCIA NOS PLANOS E CONVENIOS 1 TAGs EXISTENTES
              conteudo = replace(conteudo, "[Paciente.Convenio]", trim(PacientesSQL("Convenio1")&" ") )
              conteudo = replace(conteudo, "[Paciente.Plano]", trim(PacientesSQL("Plano1")&" ") )

              conteudo = replace(conteudo, "[Paciente.Matricula]", trim(PacientesSQL("Matricula1")&" ") )
              conteudo = replace(conteudo, "[Paciente.Validade]", trim(PacientesSQL("Validade1")&" ") )
              conteudo = replace(conteudo, "[Paciente.Email]", trim(PacientesSQL("Email1")&" ") )
              conteudo = replace(conteudo, "[Paciente.Cpf]", trim(PacientesSQL("CPF")&" ") )
              conteudo = replace(conteudo, "[Paciente.Telefone]", trim(PacientesSQL("Cel1")&" ") )
            end if
          PacientesSQL.close
          set PacientesSQL = nothing

        case "Unidade"
          if UnidadeID=0 then
            qUnidadeSQL = "select *, NomeEmpresa Nome from empresa"
          else
            qUnidadeSQL = "select *, unitName Nome from sys_financialcompanyunits where id="&UnidadeID
          end if
          SET UnidadeSQL = db.execute(qUnidadeSQL)
          if not UnidadeSQL.eof then
            conteudo = replace(conteudo, "[Unidade.Nome]", trim(UnidadeSQL("NomeEmpresa")&" ") )

            
          end if

          'response.write("<pre>"&qUnidadeSQL&"</pre>")

        case "Profissional"

          'PROFISSIONAIS POR SESSAO
          if ProfissionalSessao>0 then
            if session("Table")=lcase("profissionais") then
              qProfissionaisSQL = "SELECT p.*,t.Tratamento FROM profissionais AS p "_
              &"LEFT JOIN tratamento AS t ON t.id=p.TratamentoID "_
              &"WHERE p.id="&session("idInTable")

            end if
          elseif Profissiona>0 then
            'QUERY PELO ID DO PROFISSIONAL
          end if

          

          SET ProfissionaisSQL = db.execute(qProfissionaisSQL)
          if not ProfissionaisSQL.eof then

            conteudo = replace(conteudo, "[Profissional.Nome]", trim(ProfissionaisSQL("NomeProfissional")&" ") )
            conteudo = replace(conteudo, "[Profissional.Documento]", trim(ProfissionaisSQL("DocumentoProfissional")&" ") )
            conteudo = replace(conteudo, "[Profissional.CPF]", trim(ProfissionaisSQL("CPF")&" ") )
            'conteudo = replace(conteudo, "[Profissional.Assinatura]", trim(ProfissionaisSQL("Assinatura")&" ") )
            conteudo = replace(conteudo, "[Profissional.Assinatura]", "<img src='"&imgURLPathDefault&"/"&trim(ProfissionaisSQL("Assinatura"))&" "&"' "&img404&"'>" )
            conteudo = replace(conteudo, "[Profissional.Tratamento]", trim(ProfissionaisSQL("Tratamento")&" ") )
            conteudo = replace(conteudo, "[ProfissionalSolicitante.Nome]", trim(ProfissionaisSQL("Cel1")&" ") )


          end if 

          

        case "Sistema"
          conteudo = replace(conteudo, "[Sistema.Extenso]", formatdatetime(date(),1) )
          conteudo = replace(replace(conteudo, "[Data.DDMMAAAA]", "[Sistema.Data]"),"[Sistema.Data]",date())
          
          conteudo = replace(conteudo, "[Sistema.Hora]", time())
        case "Financeiro"

        case "Agendamento"

        case "Procedimento"

        case "Devolucao"

        case "Proposta"

        case "Encaminhamento"
    
      end select
    end if

  tagsCategoriasSQL.movenext
  wend
  tagsCategoriasSQL.close
  SET tagsCategoriasSQL = nothing

  tagsConverte = conteudo
  

end function

'***** EXEMPLO DE USO DA FUNÇÃO ******
'conteudoParaConverter = "Atesto que o paciente [Paciente.Nome]<br>foi atendido as [Sistema.Hora]<br>pelo profissional [Profissional.Nome]"
'itens = "PacienteID_6365|UserID_478|UnidadeID_8741|Sistema_0"
'response.write(tagsConverte(conteudoParaConverter,itens,""))

'response.write(tagsConverte("[Sistema.Data] e [Data.DDMMAAAA]","Sistema_0",""))
%>


