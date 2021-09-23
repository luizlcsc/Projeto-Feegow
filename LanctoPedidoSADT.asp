<!--#include file="connect.asp"-->
<!--#include file="Classes/Json.asp"-->
<!--#include file="tissFuncs.asp"-->

<%

call jsonHeader(1)

PacienteID = ref("PacienteID")
ConvenioID = ref("ConvenioIDPedidoSADT")
IndicacaoClinica =  ref("IndicacaoClinicaPedidoSADT")
Observacoes = ref("ObservacoesPedidoSADT")
ProfissionalExecutante = ref("ProfissionalExecutanteIDPedidoSADT")
PedidoID = ref("PedidoSADTID")
DataSolicitacao = ref("DataSolicitacao")
TotalProcedimentos = 0

GuiaID=1
set guia = db.execute("select id from tissguiasadt order by id desc LIMIT 1")
if not guia.eof then
    GuiaID = guia("id") + 1
end if

set pac = db.execute("select CNS, Matricula1, Validade1 from pacientes where id="&PacienteID)
if not pac.eof then
    CNS = pac("CNS")
    Matricula = pac("Matricula1")
    Validade = pac("Validade1")
end if

set emp = db.execute("select CNES from empresa")
if not emp.eof then
    CodigoCNES = emp("CNES")
end if

set contrato = db.execute("select * from contratosconvenio where  sysActive=1 and Contratado = "&session("idInTable")&" and ConvenioID="&ConvenioID)
if not contrato.eof then
    CodigoNaOperadora = contrato("CodigoNaOperadora")
    Contratado = contrato("Contratado")
    ContratadoSolicitanteID = contrato("Contratado")
    ContratadoSolicitanteCodigoNaOperadora = contrato("CodigoNaOperadora")
    CodigoCNES="9999999"
else
    CodigoNaOperadora = ""
    Contratado = 0
    ContratadoSolicitanteID = 0
    ContratadoSolicitanteCodigoNaOperadora = ""
    CodigoCNES="9999999"
end if

set conv = db.execute("select RegistroANS from convenios where id="&ConvenioID)
if not conv.eof then
    RegistroANS = conv("RegistroANS")
else
    RegistroANS =""
end if

NGuiaPrestador = numeroDisponivel(ConvenioID)


set prof = db.execute("select Conselho, DocumentoConselho, EspecialidadeID, UFConselho from profissionais where id="&session("idInTable"))
if not prof.eof then
    set esp = db.execute("select * from especialidades where id = '"&prof("EspecialidadeID")&"'")
    if not esp.eof then
        CodigoTISS = esp("CodigoTISS")
    end if
    ConselhoProfissionalSolicitanteID = prof("Conselho")
    NumeroNoConselhoSolicitante = prof("DocumentoConselho")&""
    UFConselhoSolicitante = prof("UFConselho")&""
    CodigoCBOSolicitante =  CodigoTISS&""

end if


db_execute("update pedidossadt set ConvenioID="&treatvalzero(ConvenioID)&", ProfissionalID="&treatvalzero(session("idInTable"))&", Data="&mydatenull(DataSolicitacao)&", IndicacaoClinica='"&IndicacaoClinica&"', Observacoes='"&Observacoes&"', ProfissionalExecutante='"&ProfissionalExecutante&"', GuiaID="&GuiaID&" where id="&PedidoID)

set ExamesValidarSQL = db.execute("select psp.*, proc.SolIC from pedidossadtprocedimentos psp "&_
                                  "LEFT JOIN procedimentos proc ON proc.Codigo=psp.CodigoProcedimento "&_
                                  "where psp.PedidoID="&PedidoID)

ObrigaIndicacaoClinica = False
while not ExamesValidarSQL.eof
    if ExamesValidarSQL("SolIC")="S" then
        ObrigaIndicacaoClinica = True
    end if
ExamesValidarSQL.movenext
wend
ExamesValidarSQL.close
set ExamesValidarSQL=nothing

if ObrigaIndicacaoClinica and ref("IndicacaoClinicaPedidoSADT")="" then
    erro="Preencha a indicação clínica."
end if

if erro<>"" then
    %>{
      "success": false,
      "message": "<%=erro%>"
}<%
    Response.End
end if

set pedproc = db.execute("select * from pedidossadtprocedimentos where PedidoID="&PedidoID)
while not pedproc.eof
    TabelaID = pedproc("TabelaID")
    CodigoProcedimento = pedproc("CodigoProcedimento")
    Descricao = pedproc("Descricao")
    Quantidade = pedproc("Quantidade")
    db_execute("insert into tissprocedimentossadt (GuiaID, ProfissionalID, `Data`, TabelaID, ProcedimentoID, CodigoProcedimento, Descricao, Quantidade, ViaID, TecnicaID, Fator, ValorUnitario, ValorTotal, sysUser, Associacao) values ("&GuiaID&", "&session("idInTable")&", now(), "&TabelaID&", 0,  '"&CodigoProcedimento&"', '"&Descricao&"', '"&Quantidade&"', 1, 1, 1, 0, 0, "&session("User")&", 5 )")
pedproc.movenext
wend
pedproc.close
set pedproc=nothing

if ProfissionalExecutante&""<>"" then
    ProfissionalSplt = split(ProfissionalExecutante,"_")
    set profexe = db.execute("select * from profissionais where id="&ProfissionalSplt(1))
    if not profexe.eof then
        set espexe = db.execute("select CodigoTISS from especialidades where id = '"&profexe("EspecialidadeID")&"'")
        if not espexe.eof then
            CodigoTISS = espexe("CodigoTISS")
        end if
        ConselhoID = profexe("Conselho")
        DocumentoConselho = profexe("DocumentoConselho")&""
        UFConselho = profexe("UFConselho")&""
        CodigoNaOperadoraOuCPF = profexe("CPF")&""
        CodigoCBO =  CodigoTISS&""
        Sequencial=1
        GrauParticipacaoID=12
        ProfissionalID=ProfissionalSplt(1)

        db_execute("insert into tissprofissionaissadt (GuiaID, Sequencial, GrauParticipacaoID, ProfissionalID, CodigoNaOperadoraOuCPF, ConselhoID, DocumentoConselho, UFConselho, CodigoCBO, sysUser) values ("&GuiaID&", "&Sequencial&", "&GrauParticipacaoID&", "&ProfissionalID&", '"&CodigoNaOperadoraOuCPF&"', "&ConselhoID&", '"&DocumentoConselho&"', '"&UFConselho&"', '"&CodigoCBO&"', "&session("User")&")")
    end if
else
    Contratado=""
    CodigoNaOperadora=""
    CodigoCNES=""
end if

DataSolicitacao = date()

db_execute("insert into tissguiasadt (id, PacienteID, CNS, NumeroCarteira, ValidadeCarteira, AtendimentoRN, ConselhoProfissionalSolicitanteID, NumeroNoConselhoSolicitante, UFConselhoSolicitante, CodigoCBOSolicitante, Contratado, CodigoNaOperadora, ContratadoSolicitanteID, ContratadoSolicitanteCodigoNaOperadora, ConvenioID, RegistroANS, NGuiaPrestador, CodigoCNES, TipoAtendimentoID, IndicacaoAcidenteID, TipoConsultaID, CaraterAtendimentoID, ProfissionalSolicitanteID, DataSolicitacao, Observacoes, IndicacaoClinica, sysUser, sysActive, tipoContratadoSolicitante, tipoProfissionalSolicitante, UnidadeID) VALUES ("&GuiaID&", "&PacienteID&", '"&CNS&"', '"&Matricula&"', "&mydatenull(Validade)&", 'N', "&ConselhoProfissionalSolicitanteID&", '"&NumeroNoConselhoSolicitante&"', '"&UFConselhoSolicitante&"', '"&CodigoCBOSolicitante&"', "&treatvalnull(Contratado)&", '"&CodigoNaOperadora&"', "&ContratadoSolicitanteID&", '"&ContratadoSolicitanteCodigoNaOperadora&"', "&ConvenioID&", '"&RegistroANS&"', '"&NGuiaPrestador&"', '"&CodigoCNES&"', 5, 9, 1, 1, "&session("idInTable")&", "&mydatenull(DataSolicitacao)&", '"&Observacoes&"', '"&IndicacaoClinica&"', "&session("User")&", 1 , 'I', 'I', "&session("UnidadeID")&") ")


'response.Redirect(".?P=tissguiasadt&I="&GuiaID&"&Pers=1")

%>{
    "url_redirect": ".?P=tissguiasadt&I=<%=GuiaID%>&Pers=1&close=1",
    "guia_id": <%=GuiaID%>,
    "success": true
}