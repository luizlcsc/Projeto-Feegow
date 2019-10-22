<!--#include file="connect.asp"-->

<%
LaudoID = req("L")
set l = db.execute("select l.*, p.NomePaciente, p.id PacienteProntuario, p.Nascimento from laudos l LEFT JOIN pacientes p ON p.id=l.PacienteID WHERE l.id="& LaudoID)
if not l.eof then
    set ProcedimentoSQL = db.execute("SELECT proc.NomeProcedimento, proc.DiasLaudo FROM procedimentos proc WHERE proc.id="&l("ProcedimentoID"))
    if not ProcedimentoSQL.eof then
        Procedimento = ProcedimentoSQL("NomeProcedimento")
        DiasLaudo = ProcedimentoSQL("DiasLaudo")
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

    if session("UnidadeID")=0 then
        set getUnit = db.execute("select NomeFantasia, Tel1 from empresa")
        if not getUnit.eof then
          NomeEmpresa = getUnit("NomeFantasia")
          Telefone = getUnit("Tel1")
        end if
    else
        set getUnit = db.execute("select NomeFantasia,Tel1 from sys_financialcompanyunits where id="&session("UnidadeID"))
        if not getUnit.eof then
            NomeEmpresa = getUnit("NomeFantasia")
            Telefone = getUnit("Tel1")
        end if
    end if

    set prot = db.execute("SELECT LaudosProtocolo FROM impressos")
    if not Prot.eof then
        ProtocoloConteudo = prot("LaudosProtocolo")&""
        if ProtocoloConteudo<>"" then
            ProtocoloConteudo = replace(ProtocoloConteudo, "[Usuario.Nome]", NomeUsuario)
            ProtocoloConteudo = replace(ProtocoloConteudo, "[Sistema.Hora]", now())
            ProtocoloConteudo = replace(ProtocoloConteudo, "[Protocolo.ID]", right("0000000"&Id,7))
            ProtocoloConteudo = replace(ProtocoloConteudo, "[Paciente.Nome]", NomePaciente)
            ProtocoloConteudo = replace(ProtocoloConteudo, "[Paciente.Nascimento]", PacienteNascimento)
            ProtocoloConteudo = replace(ProtocoloConteudo, "[Paciente.Prontuario]", PacienteProntuario)
            ProtocoloConteudo = replace(ProtocoloConteudo, "[Exame.Data]", DataExecucao)
            ProtocoloConteudo = replace(ProtocoloConteudo, "[Procedimento.Nome]", Procedimento)
            ProtocoloConteudo = replace(ProtocoloConteudo, "[Procedimento.DiasLaudo]", DiasLaudo&"")
            ProtocoloConteudo = replace(ProtocoloConteudo, "[ProfissionalSolicitante.Nome]", ProfissionalSolicitante)
            ProtocoloConteudo = replace(ProtocoloConteudo, "[Unidade.Nome]", NomeEmpresa&"")
            ProtocoloConteudo = replace(ProtocoloConteudo, "[Unidade.Telefone]", Telefone&"")
        else
            ProtocoloConteudo = ""
        end if
    else
        ProtocoloConteudo = ""
    end if

%>
    <body>

        <div class="modal-body" id="areaImpressao" >
            <%=ProtocoloConteudo%>
        </div>

    </body>

<%
end if
%>



<script type="text/javascript">
print();
</script>