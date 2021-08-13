<!--#include file="connect.asp"-->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <link rel="stylesheet" type="text/css" media="all" href="assets/css/tiss.css" />
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>Guia de Solicitação de Quimioterapia</title>
    <style>
        body{
            width: 100%;
            border: 0;
        }
        h1{
            display: flex;
            justify-content: center;
            font-weight: bolder;
            margin-bottom: 5px;
            font-size: 15px;
        }
        div{
            display: flex;
            justify-content: flex-end;
            font-size: 8px;
            margin-right: 5mm;
            margin-bottom: 5px;
            padding-top: 4px;
        }
        span{
            font-size: 13px;
            margin-top: -4px;
        }
        th{
            font-size: 9px;
            text-align: left;
            border: none;
            padding-left: 5px;     
            background-color: darkgray;
            -webkit-print-color-adjust: exact;
        }
        td{
            font-size: 8px;
            text-align: left;
            vertical-align: text-top;
            border: solid black 1px;
            <%if req("I") <> 0 then%>
                padding-bottom: 10px;
            <%else%>
                padding-bottom: 30px;
            <%end if%>
            padding-left: 5px;  
        }
        table{
            border-spacing: 3px 3px;
            width: 100%;
        }
    </style>
</head>

<%
function CidGuia(CidID)
    CidGuia = 0
    if CidID&""<>"" then
        set CodigoCid =  db.execute("SELECT Codigo FROM cliniccentral.cid10 WHERE id="&CidID)
        if not CodigoCid.eof then
            CidGuia = CodigoCid("Codigo")
        end if
    end if
end function

NGuiaReferenciada = ""
CNS = ""
RegistroANS = ""
NGuiaPrestador = ""
Senha = ""
DataAutorizacao = ""
NGuiaOperadora = ""
NumeroCarteira = ""
DataValidadeSenha = ""
NumeroCarteira = ""
ValidadeCarteira = ""
PacienteID = ""
Peso = ""
Altura = ""
IdadePaciente = ""
SuperficieCorporal = ""
Sexo = ""
ConvenioID = ""
PlanoID = ""
ProfissionalSolicitanteID = ""
Telefone = ""
Email = ""
DataDiagnostico = ""
Cid1 = ""
Cid2 = ""
Cid3 = ""
Cid4 = ""
Estadiamento = ""
TipoQuimioterapia = ""
Finalidade = ""
ECOG = ""
TabelaID = ""
PlanoTerapeutico = ""
DiagnosticoCitoHistopatologico = ""
InfoRelevante = ""
Cirurgia = ""
DataRealizacao = ""
AreaIrradiada = ""
DataAplicacao = ""
Observacoes = ""
NumeroCicloPrevisto = ""
CicloAtual = ""
IntervaloEntreCiclos = ""
DataSolicitacao = ""
AssinaturaProfissionalSolicitante = ""
AssinaturaResponsavelAutorizacao = ""

if req("I") <> 0 then
    set reg = db.execute("select * from tissguiaquimioterapia where id="&req("I"))

    NGuiaReferenciada = reg("NGuiaReferenciada")
    CNS = reg("CNS")
    RegistroANS = reg("RegistroANS")
    NGuiaPrestador = reg("NGuiaPrestador")
    Senha = reg("Senha")
    DataAutorizacao = reg("DataAutorizacao")
    NGuiaOperadora = reg("NGuiaOperadora")
    NumeroCarteira = reg("NumeroCarteira")
    DataValidadeSenha = reg("DataValidadeSenha")
    NumeroCarteira = reg("NumeroCarteira")
    ValidadeCarteira = reg("ValidadeCarteira")
    PacienteID = reg("PacienteID")
    Peso = reg("Peso")
    Altura = reg("Altura")
    IdadePaciente = reg("Idade")
    if IdadePaciente = 0 then
        IdadePaciente = ""
    end if
    SuperficieCorporal = reg("SuperficieCorporal")
    Sexo = reg("Sexo")
    if Sexo = 1 then
        Sexo = "Masculino"
    elseif Sexo = 2 then
        Sexo = "Feminino"
    elseif Sexo = 3 then
        Sexo = "Indefinido"
    end if
    ConvenioID = reg("ConvenioID")
    PlanoID = reg("PlanoID")
    ProfissionalSolicitanteID = reg("ProfissionalSolicitanteID")
    Telefone = reg("Telefone")
    Email = reg("Email")
    DataDiagnostico = reg("DataDiagnostico")
    Cid1 = CidGuia(reg("Cid1"))
    Cid2 = CidGuia(reg("Cid2"))
    Cid3 = CidGuia(reg("Cid3"))
    Cid4 = CidGuia(reg("Cid4"))
    Estadiamento = reg("Estadiamento")
    TipoQuimioterapia = reg("TipoQuimioterapia")
    Finalidade = reg("Finalidade")
    ECOG = reg("ECOG")
    PlanoTerapeutico = reg("PlanoTerapeutico")
    DiagnosticoCitoHistopatologico = reg("DiagnosticoCitoHistopatologico")
    InfoRelevante = reg("InfoRelevante")
    Cirurgia = reg("Cirurgia")
    DataRealizacao = reg("DataRealizacao")
    AreaIrradiada = reg("AreaIrradiada")
    DataAplicacao = reg("DataAplicacao")
    Observacoes = reg("Observacoes")
    NumeroCicloPrevisto = reg("NumeroCicloPrevisto")
    CicloAtual = reg("CicloAtual")
    IntervaloEntreCiclos = reg("IntervaloEntreCiclos")
    DataSolicitacao = reg("DataSolicitacao")
    AssinaturaProfissionalSolicitante = reg("AssinaturaProfissionalSolicitante")
    if AssinaturaProfissionalSolicitante = 0 then
        AssinaturaProfissionalSolicitante = ""
    end if
    AssinaturaResponsavelAutorizacao = reg("AssinaturaResponsavelAutorizacao")
    if AssinaturaResponsavelAutorizacao = 0 then
        AssinaturaResponsavelAutorizacao = ""
    end if

    set pac = db.execute("select NomePaciente from pacientes where id="&PacienteID)
    NomePaciente = pac("NomePaciente")
    set prof = db.execute("select NomeProfissional from profissionais where id="&ProfissionalSolicitanteID)
    NomeProfissional = prof("NomeProfissional")
    NomeConvenio = ""
    if ConvenioID <> 0 then
        set conv = db.execute("select NomeConvenio from convenios where id="&ConvenioID)
        NomeConvenio = conv("NomeConvenio")
    end if
    NomePlano = ""
    if PlanoID <> 0 then
        set plano = db.execute("select NomePlano from conveniosplanos where id="&ConvenioID)
        NomePlano = plano("NomePlano")
    end if
    set medicamentosSQL = db.execute("select * from tissmedicamentosquimioterapia where GuiaID="&req("I"))
    DataAdministracao = ""
    TabelaID = ""
    CodigoMedicamento = ""
    Descricao = ""
    DosagemMedicamento = ""
    ViaADM = ""
    Frequencia = ""
    while not medicamentosSQL.eof
        DataAdministracao = DataAdministracao&"<p>"&medicamentosSQL("DataAdministracao")&"</p>"
        CodigoMedicamento = CodigoMedicamento&"<p>"&medicamentosSQL("CodigoMedicamento")&"</p>"
        Descricao = Descricao&"<p>"&medicamentosSQL("Descricao")&"</p>"
        DosagemMedicamento = DosagemMedicamento&"<p>"&medicamentosSQL("DosagemMedicamento")&"</p>"
        ViaADM = ViaADM&"<p>"&medicamentosSQL("ViaADM")&"</p>"
        Frequencia = Frequencia&"<p>"&medicamentosSQL("Frequencia")&"</p>"
        TabelaID = TabelaID&"<p>"&medicamentosSQL("TabelaID")&"</p>"
        medicamentosSQL.movenext
    wend
    medicamentosSQL.close
    set medicamentosSQL=nothing
end if
%>
    <body>
        <h1>ANEXO DE SOLICITAÇÃO DE QUIMIOTERAPIA</h1>
        <div>2 - N° da Guia Principal &nbsp&nbsp&nbsp&nbsp<span><%=NGuiaReferenciada%></span></div>
        <table>
                <tr>
                    <td>
                        <p>1 - Registro ANS</p>
                        <p><%=RegistroANS%></p>
                    </td>
                    <td>
                        <p>3 - Numero da Guia Referenciada</p>
                        <p><%=NGuiaReferenciada%></p>
                    </td>
                    <td>
                        <p>4 - Senha</p>
                        <p><%=Senha%></p>
                    </td>
                    <td>
                        <p>5 - Data da Autorização</p>
                        <p><%=DataAutorizacao%></p>
                    </td>
                    <td>
                        <p>6 -Número da Guia Atribuído pela Operadora</p>
                        <p><%=NGuiaOperadora%></p>
                    </td>
                </tr>
        </table>

        <table>
            <thead>
                <tr>
                    <th colspan="5">
                        Dados do Beneficiário
                    </th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td colspan="2">
                        <p>7 - Número da Carteira</p>
                        <p><%=NumeroCarteira%></p>
                    </td>
                    <td colspan="3">
                        <p>8 - Paciente</p>
                        <p><%=NomePaciente%></p>
                    </td>
                </tr>
                <tr>
                    <td>
                        <p>9 - Peso(Kg)</p>
                        <p><%=Peso%></p>
                    </td>
                    <td>
                        <p>10 - Altura(Cm)</p>
                        <p><%=Altura%></p>
                    </td>
                    <td>
                        <p>11 - Superficie Corporal</p>
                        <p><%=SuperficieCorporal%></p>
                    </td>
                    <td>
                        <p>12 - Idade</p>
                        <p><%=IdadePaciente%></p>
                    </td>
                    <td>
                        <p>13 - Sexo</p>
                        <p><%=Sexo%></p>
                    </td>
                </tr>
        </tbody>
        </table>

        <table>
            <thead>
                <tr>
                    <th colspan="3">
                        Dados do Profissional Solicitante
                    </th>
                </tr>
                
            </thead>
        <tbody>
                <tr>
                    <td>
                        <p>14 - Nome do Profissional Solicitante</p>
                        <p><%=NomeProfissional%></p>
                    </td>
                    <td>
                        <p>15 - Telefone</p>
                        <p><%=Telefone%></p>
                    </td>
                    <td>
                        <p>16 - E-mail</p>
                        <p><%=Email%></p>
                    </td>
                </tr>
        </tbody>
        </table>

        <table>
            <thead>
                <tr>
                    <th colspan="6">
                        Diagnóstico Oncológico
                    </th>
                </tr>
                
            </thead>
        <tbody>
                <tr>
                    <td>
                        <p>17 - Data do Diagnóstico</p>
                        <p><%=DataDiagnostico%></p>
                    </td>
                    <td>
                        <p>18 - CID 10 Principal</p>
                        <p><%=Cid1%></p>
                    </td>
                    <td>
                        <p>19 - CID 10 (2)</p>
                        <p><%=Cid2%></p>
                    </td>
                    <td>
                        <p>20 - CID 10 (3)</p>
                        <p><%=Cid3%></p>
                    </td>
                    <td>
                        <p>21 - CID 10 (4)</p>
                        <p><%=Cid4%></p>
                    </td>
                    <td rowspan="2" style="width: 40%;">
                        <p>26 - Plano Terapêutico</p>
                        <p><%=PlanoTerapeutico%></p>
                    </td>
                </tr>
                <tr>
                    <td>
                        <p>22 - Estadiamento</p>
                        <p><%=Estadiamento%></p>
                    </td>
                    <td>
                        <p>23 - Tipo de Quimioterapia</p>
                        <p><%=TipoQuimioterapia%></p>
                    </td>
                    <td>
                        <p>24 - Finalidade</p>
                        <p><%=Finalidade%></p>
                    </td>
                    <td colspan="2">
                        <p>25 - ECOG</p>
                        <p><%=ECOG%></p>
                    </td>
                </tr>
                <tr>
                    <td colspan="5" style="height: 20mm;">
                        <p>27 - Diagnostico Cito/Histopatógico</p>
                        <p><%=DiagnosticoCitoHistopatologico%></p>
                    </td>
                    <td colspan="1" style="height: 20mm;">
                        <p>28 - Informações Relevantes</p>
                        <p><%=InfoRelevante%></p>
                    </td>
                </tr>
        </tbody>
        </table>

        <table>
            <thead>
                <tr>
                    <th colspan="7">
                        Medicamentos e drogas solicitadas
                    </th>
                    <th class="head" colspan="2">
                        Tratamentos Anteriores
                    </th>
                </tr>
                
            </thead>
        <tbody>
                <tr>
                    <td rowspan="4">
                        <p>29 -Data Prevista para Administração</p>
                        <%=DataAdministracao%>
                    </td>
                    <td rowspan="4">
                        <p>30 - Tabela</p>
                        <p><%=TabelaID%></p>
                    </td>
                    <td rowspan="4">
                        <p>31 - Código do Medicamento</p>
                        <p><%=CodigoMedicamento%></p>
                    </td>
                    <td rowspan="4">
                        <p>32 - Descrição</p>
                        <p><%=Descricao%></p>
                    </td>
                    <td rowspan="4">
                        <p>33 - Doses</p>
                        <p><%=DosagemMedicamento%></p>
                    </td>
                    <td rowspan="4">
                        <p>34 - Via Adm</p>
                        <p><%=ViaADM%></p>
                    </td>
                    <td rowspan="4">
                        <p>35 - Frequência</p>
                        <p><%=Frequencia%></p>
                    </td>
                    <td style="width: 25mm;">
                        <p>36 - Cirurgia</p>
                        <p><%=Cirurgia%></p>
                    </td>
                </tr>
                <tr>
                    <td>
                        <p>37 - Data da Realização</p>
                        <p><%=DataRealizacao%></p>
                    </td>
                </tr>
                <tr>
                    <td>
                        <p>38 - Área irradiada</p>
                        <p><%=AreaIrradiada%></p>
                    </td>
                </tr>
                <tr>
                    <td>
                        <p>39 - Data da Aplicação</p>
                        <p><%=DataAplicacao%></p>
                    </td>
                </tr>
                <tr>
                    <td colspan="9">
                        <p>40 - Observação / Justificativa</p>
                        <p><%=Observacoes%></p>
                    </td>
                </tr>
                <tr>
                    <td>
                        <p>41 - Número de Ciclos Previstos</p>
                        <p><%=NumeroCicloPrevisto%></p>
                    </td>
                    <td>
                        <p>42 - Ciclos Atual</p>
                        <p><%=CicloAtual%></p>
                    </td>
                    <td>
                        <p>43 - Intervalo entre Ciclos(em dias)</p>
                        <p><%=IntervaloEntreCiclos%></p>
                    </td>
                    <td>
                        <p>44 - Data da Solicitação</p>
                        <p><%=DataSolicitacao%></p>
                    </td>
                    <td colspan="2">
                        <p>44 - Assinatura do Profissional Solicitante</p>
                        <p><%=AssinaturaProfissionalSolicitante%></p>
                    </td> 
                    <td colspan="2">
                        <p>45 - Assinatura do Responsável pela Autorização</p>
                        <p><%=AssinaturaResponsavelAutorizacao%></p>
                    </td>
                </tr>
        </tbody>     
    </table>
</html>
<script type="text/javascript">
    print();
    <%
    if TipoExibicao="Pedido" then
        %>
        window.opener.pront('timeline.asp?PacienteID=<%= PacienteID %>&Tipo=|Pedido|');
        <%
    End If
    %>
</script>