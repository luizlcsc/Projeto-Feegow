<!--#include file="connect.asp"-->
<!--#include file="tissFuncs.asp"-->

<%
PacienteID = req("PacienteID")
ConvenioID = req("ConvenioIDPedidoSADT")
IndicacaoClinica =  req("IndicacaoClinicaPedidoSADT")
Observacoes = req("ObservacoesPedidoSADT")
ProfissionalExecutante = req("ProfissionalExecutanteIDPedidoSADT")
PedidoID = req("PedidoSADTID")
DataSolicitacao = req("DataSolicitacao")
TotalProcedimentos = 0

GuiaID=1
set guia = db.execute("select id from tissguiasadt order by id desc")
if not guia.eof then
    GuiaID = guia("id") + 1
end if

set pac = db.execute("select * from pacientes where id="&PacienteID)
if not pac.eof then
    CNS = pac("CNS")
    Matricula = pac("Matricula1")
    Validade = pac("Validade1")
end if

set emp = db.execute("select * from empresa")
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


set prof = db.execute("select * from profissionais where id="&session("idInTable"))
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
        set espexe = db.execute("select * from especialidades where id = '"&profexe("EspecialidadeID")&"'")
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
%>
var url =".?P=tissguiasadt&I=<%=GuiaID%>&Pers=1&close=1"
var GuiaID=<%=GuiaID%>