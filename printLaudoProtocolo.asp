<!--#include file="connect.asp"-->
<!--#include file="./Classes/TagsConverte.asp"-->
<%
LaudoID = req("L")
AgendamentoID = req("AgendamentoID")
qLaudoSQL = "select l.*, p.NomePaciente, p.id PacienteProntuario, p.Nascimento from laudos l LEFT JOIN pacientes p ON p.id=l.PacienteID WHERE l.id="& LaudoID
'response.write("<pre>"&qLaudoSQL&"</pre>")
set l = db.execute(qLaudoSQL)
if l.eof then
    ProtocoloConteudo = "Não foi possível imprimir o protocolo."
else
    'TRATA ERRO DE QUANDO NÃO EXISTE PROCEDIMENTOS VINCULADOS, GERALMENTE EXAMES LABORATORIAIS.
    ProcedimentoID = l("ProcedimentoID")&""
    if ProcedimentoID<>"" then
        qProcedimentoSQL = "SELECT proc.NomeProcedimento, proc.DiasLaudo FROM procedimentos proc WHERE proc.id="&l("ProcedimentoID")
        set ProcedimentoSQL = db.execute(qProcedimentoSQL)
        if not ProcedimentoSQL.eof then
            Procedimento = ProcedimentoSQL("NomeProcedimento")
            DiasLaudo = ProcedimentoSQL("DiasLaudo")
        end if
    end if

    NomePaciente = l("NomePaciente")
    PacienteProntuario = l("PacienteProntuario")
    PacienteNascimento = l("Nascimento")
    Id = l("id")
    Tabela = l("Tabela")
    IDTabela = l("IDTabela")
    NomeUsuario = session("NameUser")&""

    if Tabela="itensinvoice" then
        set getConta = db.execute("select DataExecucao from itensinvoice where id="&IDTabela)
            if not getConta.eof then
                DataExecucao = getConta("DataExecucao")
                Solicitante = ""
            end if
    elseif Tabela="tissguiasadt" then
        set getConta = db.execute("select DataSolicitacao, ProfissionalSolicitanteID, tipoProfissionalSolicitante from tissguiasadt where id="&IDTabela)
            if not getConta.eof then
                DataExecucao = getConta("DataSolicitacao")
                Solicitante = getConta("ProfissionalSolicitanteID")
                TipoSolicitante = getConta("tipoProfissionalSolicitante")
            end if
    elseif Tabela="tissprocedimentossadt" then
        set getConta = db.execute("select tgs.DataSolicitacao, tgs.ProfissionalSolicitanteID, tgs.tipoProfissionalSolicitante from tissguiasadt tgs INNER JOIN tissprocedimentossadt tps ON tps.GuiaID=tgs.id where tps.id="&IDTabela)
            if not getConta.eof then
                DataExecucao = getConta("DataSolicitacao")
                Solicitante = getConta("ProfissionalSolicitanteID")
                TipoSolicitante = getConta("tipoProfissionalSolicitante")
            end if
    end if
    ProfissionalSolicitante = ""
    if Solicitante<>"" then
        if TipoSolicitante="I" then
            set getProf = db.execute("SELECT NomeProfissional FROM profissionais WHERE id="&Solicitante)
            if not getProf.eof then
                ProfissionalSolicitante = getProf("NomeProfissional")
            end if
        elseif TipoSolicitante="E" then
            set getProf = db.execute("SELECT NomeProfissional FROM profissionalexterno WHERE id="&Solicitante)
            if not getProf.eof then
                ProfissionalSolicitante = getProf("NomeProfissional")
            end if
        end if
    end if

    set prot = db.execute("SELECT LaudosProtocolo FROM impressos")

    if not Prot.eof then
        ProtocoloConteudo = unscapeOutput(prot("LaudosProtocolo"))&""
        
        if ProtocoloConteudo<>"" then
            
            ProtocoloConteudo = (tagsConverte(ProtocoloConteudo,"PacienteID_"&PacienteProntuario&"|UnidadeID_"&session("UnidadeID")&"|ProcedimentoID_"&ProcedimentoID,""))
            
            if AgendamentoID <> "" then 
                ProtocoloConteudo = (tagsConverte(ProtocoloConteudo,"AgendamentoID_"&AgendamentoID,""))
            else 
                ProtocoloConteudo = replace(ProtocoloConteudo, "[Agendamento.id]", "")
            end if

            ProtocoloConteudo = replace(ProtocoloConteudo, "[Protocolo.ID]", right("0000000"&Id,7))
            ProtocoloConteudo = replace(ProtocoloConteudo, "[Exame.Data]", DataExecucao)
            ProtocoloConteudo = replace(ProtocoloConteudo, "[ProfissionalSolicitante.Nome]", ProfissionalSolicitante)
        else
            ProtocoloConteudo = ""
        end if
    else
        ProtocoloConteudo = ""
    end if

%>
    

<%
end if
%>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Feegow Clinic - Impressãod e Protocolo</title>
    </head>
    <body>
        <div class="modal-body" id="areaImpressao" >
            <%=ProtocoloConteudo%>
        </div>
        <script type="text/javascript">
        print();
        </script>
    </body>
</html>
