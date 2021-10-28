<!--#include file="connect.asp"-->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<!-- Bootstrap -->
<link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/3.4.1/css/bootstrap.min.css" integrity="sha384-HSMxcRTRxnN+Bdg0JdbxYKrThecOKuH5zCYotlSAcp1+c8xmyTe9GYg1l9a69psu" crossorigin="anonymous">
<link rel="stylesheet" type="text/css" media="all" href="assets/css/tiss.css" />
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title><% if session("banco") = "clinic10402" then %>Solicitação<% else %>Guia<% end if %> de SP/SADT</title>
</head>
<style type="text/css">
.bg-secondary{
    background-color: #ccc;
}
.bg-red{
    background-color: red;
}
.pl10{
    padding-left: 10px;
}
.pr10{
    padding-right: 10px;
}
.border-bottom{
    border-bottom: solid 1px #ccc;
}
.cabecalho{
    width:100%;
    height:100px;
    margin-bottom:5px;
    border: solid 1px #000;
}
.conteudo{
    width: 100%;
}
.bloco{
    width:100%;
    float:left;
    margin-top:5px;
    margin-bottom:5px;
    border: solid 1px #000;
}
.titulo-cd{
    width: 100%;
    padding-left:5px;
    padding-top:2px;
    padding-bottom:2px;
    color: rgba(79, 79, 79, 0.7);
}
@media print {
    .bloco {
        /* page-break-inside: avoid; */
    }
}
</style>

<%
set DadosCabecalho = db.execute("SELECT p.NomePaciente, p.idImportado Prontuario, "&_
                                " pd.Descricao CIDPrincipal, c.NomeConvenio, "&_
                                " prof.NomeProfissional, "&_
                                " a.id TipoAtendimentoID, a.Descricao TipoAtendimento, "&_
                                " g.AtendimentoID, COALESCE (g.NGuiaOperadora, g.NGuiaPrestador) Guia, g.CodigoNaOperadora, g.IndicacaoClinica, g.NumeroCarteira NumeroMatricula, g.senha Senha, g.ValidadeCarteira FROM tissguiasadt g "&_
                                " LEFT JOIN pacientes p ON p.id = g.PacienteID "&_
                                " LEFT JOIN pacientesdiagnosticos pd ON pd.PacienteID = p.id "&_
                                " LEFT JOIN convenios c ON c.id = g.ConvenioID "&_
                                " LEFT JOIN tisstipoatendimento a ON a.id = g.TipoAtendimentoID "&_
                                " LEFT JOIN tissprofissionaissadt pg ON pg.GuiaID = g.id "&_
                                " LEFT JOIN profissionais prof ON COALESCE (prof.id = pg.ProfissionalID, prof.id = g.ProfissionalSolicitanteID) "&_
                                " WHERE g.id="&req("I")&_
                                " GROUP BY p.id")
NomePaciente = ""
Prontuario = ""
CIDPrincipal = ""
NomeConvenio = ""
NomeProfissional = ""
TipoAtendimentoID = ""
TipoAtendimento = ""
AtendimentoID = ""
Guia = ""
CodigoNaOperadora = ""
IndicacaoClinica = ""
NumeroMatricula = ""
Senha = ""
ValidadeCarteira = ""

if not DadosCabecalho.eof then
    NomePaciente = DadosCabecalho("NomePaciente")&""
    Prontuario = DadosCabecalho("Prontuario")&""
    CIDPrincipal = DadosCabecalho("CIDPrincipal")&""
    NomeConvenio = DadosCabecalho("NomeConvenio")&""
    NomeProfissional = DadosCabecalho("NomeProfissional")&""
    TipoAtendimentoID = DadosCabecalho("TipoAtendimentoID")&""
    TipoAtendimento = DadosCabecalho("TipoAtendimento")&""
    AtendimentoID = DadosCabecalho("AtendimentoID")&""
    Guia = DadosCabecalho("Guia")&""
    CodigoNaOperadora = DadosCabecalho("CodigoNaOperadora")&""
    IndicacaoClinica = DadosCabecalho("IndicacaoClinica")&""
    NumeroMatricula = DadosCabecalho("NumeroMatricula")&""
    Senha = DadosCabecalho("Senha")&""
    ValidadeCarteira = DadosCabecalho("ValidadeCarteira")&""
end if

set ExibeTabelaSQL = db.execute("SELECT GROUP_CONCAT(CD1) CD1, GROUP_CONCAT(CD2) CD2, GROUP_CONCAT(CD3) CD3, GROUP_CONCAT(CD7) CD7, GROUP_CONCAT(CD8) CD8, GROUP_CONCAT(CD9) CD9 FROM( "&_
                            "  SELECT COUNT(ga.CD) CD1, NULL 'CD2', NULL 'CD3', NULL 'CD7', NULL 'CD8', NULL 'CD9' "&_
                            "  FROM tissguiaanexa ga "&_
                            "  LEFT JOIN tissunidademedida um ON um.id = ga.UnidadeMedidaID "&_
                            "  WHERE ga.GuiaID="&req("I")&" AND ga.CD = 1 "&_
                            "  UNION ALL "&_
                            "  SELECT NULL, COUNT(ga.CD) CD2, NULL, NULL, NULL, NULL "&_
                            "  FROM tissguiaanexa ga "&_
                            "  LEFT JOIN tissunidademedida um ON um.id = ga.UnidadeMedidaID "&_
                            "  WHERE ga.GuiaID="&req("I")&" AND ga.CD = 2 "&_
                            "  UNION ALL "&_
                            "  SELECT NULL, NULL, COUNT(ga.CD), NULL, NULL, NULL "&_
                            "  FROM tissguiaanexa ga "&_
                            "  LEFT JOIN tissunidademedida um ON um.id = ga.UnidadeMedidaID "&_
                            "  WHERE ga.GuiaID="&req("I")&" AND ga.CD = 3 "&_
                            "  UNION ALL  "&_
                            "  SELECT NULL, NULL, NULL, COUNT(ga.CD), NULL, NULL "&_
                            "  FROM tissguiaanexa ga "&_
                            "  LEFT JOIN tissunidademedida um ON um.id = ga.UnidadeMedidaID "&_
                            "  WHERE ga.GuiaID="&req("I")&" AND ga.CD = 7 "&_
                            "  UNION ALL "&_
                            "  SELECT NULL, NULL, NULL, NULL, COUNT(ga.CD), NULL "&_
                            "  FROM tissguiaanexa ga "&_
                            "  LEFT JOIN tissunidademedida um ON um.id = ga.UnidadeMedidaID "&_
                            "  WHERE ga.GuiaID="&req("I")&" AND ga.CD = 8 "&_
                            "  UNION ALL "&_
                            "  SELECT NULL, NULL, NULL, NULL, NULL, COUNT(ga.CD) "&_
                            "  FROM tissguiaanexa ga "&_
                            "  LEFT JOIN tissunidademedida um ON um.id = ga.UnidadeMedidaID "&_
                            "  WHERE ga.GuiaID="&req("I")&" AND ga.CD = 9 "&_
                            " ) t")

ExibeGases = false
ExibeMedicamentos = false
ExibeMateriais = false
ExibeTaxas = false
ExibeOPME = false

if not ExibeTabelaSQL.eof then
    if ExibeTabelaSQL("CD1") then
        ExibeGases = true
    end if
    if ExibeTabelaSQL("CD2") then
        ExibeMedicamentos = true
    end if
    if ExibeTabelaSQL("CD3") or ExibeTabelaSQL("CD9") then
        ExibeMateriais = true
    end if
    if ExibeTabelaSQL("CD7") then
        ExibeTaxas = true
    end if
    if ExibeTabelaSQL("CD8") then
        ExibeOPME = true
    end if
end if
%>
<body>
    <table>
       <thead>
          <tr>
             <th>
                <div class="cabecalho">
                    <div style="float:left; width:80%;">
                        <div style="margin-botton:10%; height:70px;">
                            <div style="float:left; width:70%; height:60px; padding:2px;">
                                <strong>
                                    <%
                                    set conf = db.execute("select Logo, NomeEmpresa from sys_config")
                                    if not conf.EOF then
                                        if conf("Logo")&"" <> "" then
                                    %>
                                            <img src="<%=conf("Logo")%>" id='logo'/>
                                    <%
                                        else
                                            response.write(conf("NomeEmpresa"))
                                        end if
                                    end if
                                    %>
                                </strong>
                            </div>
                            <div style="float:right; width:30%; height:60px; padding:2px; text-align:right;">
                                <%
                                if isnumeric(req("I")) and req("I")<>"" then
                                    barcode = ccur(req("I"))+2222222222
                                %>
                                    <iframe frameborder="0" scrolling="no" width="100" height="60" src="CodBarras.asp?NumeroCodigo=<%=barcode%>&BPrint=hdn"></iframe> <br />
                                <%end if%>
                            </div>
                        </div>
                        <div style="float:left; width:50%; padding-left:2px; border-top: solid 1px #000;">
                            <div><span>Paciente:</span><br></div>
                            <div><span><strong><%=NomePaciente%></strong></span></div>
                        </div>
                        <div style="float:left; width:25%; padding-left:2px; border-left: solid 1px #000; border-top: solid 1px #000; border-right: solid 1px #000;">
                            <div><span>Convênio:</span><br></div>
                            <div><span><strong><%=NomeConvenio%></strong></span></div>
                        </div>
                        <div style="float:left; width:25%; padding-left:2px; border-top: solid 1px #000;">
                            <div><span>Usuário/Matricula:</span><br></div>
                            <div><span><strong><%=NumeroMatricula%></strong></span></div>
                        </div>
                    </div>
                    <div style="float:left; width:20%; height:95px; padding-left:2px; border-left: solid 1px #000;">
                        <div style="padding-top:5px; text-align:center; font-size: 12px"><span><strong>CONTA<br>PACIENTE</strong></span></div>
                        <div style="padding-top:5px; text-align:center;"><span><strong><%=CodigoNaOperadora%></strong></span></div>
                        <div style="clear:both; padding-top:5px;">
                            <div style="float:left; width:40%; text-align:right;">
                                <span>N° Atend.:</span>
                            </div>
                            <div style="float:left; width:60%; text-align:right; padding-right:10px;">
                                <span><strong><%=AtendimentoID%></strong></span>
                            </div>
                            <div style="float:left; width:40%; text-align:right;">
                                <span>N° IF:</span>
                            </div>
                            <div style="float:left; width:60%; text-align:right; padding-right:10px;">
                                <span><strong><%=req("I")%></strong></span>
                            </div>
                        </div>
                    </div>
                </div>
              </th>
           </tr>
         </thead>
         <tbody>
            <tr>
                <td>
                    <div class="conteudo">
                        <div style="float:left; width:100%; margin-top:5px; margin-bottom:5px; padding-left:2px; border: solid 1px #000;">
                            <div><span style="background-color: #ccc;">Prontuário:</span> &nbsp;&nbsp;<%=Prontuario%></div>
                            <div>
                                <div style="float:left; width:70%; padding-left:100px;"><span style="background-color: #ccc;">Médico:</span>&nbsp;<%=NomeProfissional%></div>
                                <div style="float:left; width:30%; padding-left:20px;">
                                    <div style="clear: both; width:100%;">
                                        <div style="float:left; width:30%; text-align:right;"><span style="background-color: #ccc;">Tipo Atend.:</span> </div>
                                        <div style="float:left; width:70%; padding-left:5px;"><%=TipoAtendimentoID%> - <%=TipoAtendimento%></div>
                                    </div>
                                    <div style="clear: both; width:100%;">
                                        <div style="float:left; width:30%; text-align:right;"><span style="background-color: #ccc;">Espec/Clínica:</span> </div>
                                        <div style="float:left; width:70%; padding-left:5px;"><%=IndicacaoClinica%></div>
                                    </div>
                                </div>
                            </div>
                            <div style="margin-bottom: 15px;">
                                <div style="float:left; width:7%;"><span style="background-color: #ccc;">CID Princ.:</span></div>
                                <div style="float:left; width:95%;"> <%=CIDPrincipal%></div>
                            </div>
                            <div>
                                <div style="float:left; width:30%;">
                                    <div style="float:left; width:10%;"><span style="background-color: #ccc;">Guia:</span></div>
                                    <div style="float:left; width:90%;"> <%=Guia%></div>
                                </div>
                                <div style="float:left; width:30%;">
                                    <div style="float:left; width:12%;"><span style="background-color: #ccc;">Senha:</span></div>
                                    <div style="float:left; width:88%;"> <%=Senha%></div>
                                </div>
                                <div style="float:left; width:40%;">
                                    <div style="float:left; width:17%;"><span style="background-color: #ccc;">Val. Carteira:</span></div>
                                    <div style="float:left; width:83%;"> <%=ValidadeCarteira%></div>
                                </div>
                            </div>
                        </div>
                        <% 
                        TotalGasesMedicinais = 0
                        TotalMateriais = 0
                        TotalOPME = 0
                        TotalMedicamentos = 0
                        TotalSuplemento = 0
                        TotalTaxasEAlugueis = 0

                        if ExibeGases <> false then%>
                            <div class="bloco">
                                <table padding-left="2px"  width="100%" tborder="0" cellpadding="0" cellspacing="0" style="-fs-table-paginate:paginate;">
                                    <thead style="display:table-header-group">
                                        <div class="bg-secondary titulo-cd"><strong>Gases Medicinais</strong></div>
                                        <tr class="bg-secondary">
                                            <th class="text-left pl10" width="5%">Seq.</th>
                                            <th class="text-left" width="10%">Código</th>
                                            <th class="text-left" width="35%">Descrição Gases Medicinais</th>
                                            <th class="text-left" width="10%">Data</th>
                                            <th class="text-left" width="10%">Unid.</th>
                                            <th class="text-right" width="10%">Qtde</th>
                                            <th class="text-right" width="10%">Vl Unit.</th>
                                            <th class="text-right pr10" width="10%">Vl Total</th>
                                        </tr>
                                    </thead>
                                    <%
                                    set CD1SQL = db.execute("SELECT ga.CD, ga.CodigoProduto, ga.Descricao, ga.`Data`, ga.Quantidade, ga.ValorUnitario, ga.ValorTotal, gs.GasesMedicinais TotalGasesMedicinais, "&_
                                                            " um.Descricao UnidadeDescricao "&_
                                                            " FROM tissguiaanexa ga "&_
                                                            " LEFT JOIN tissguiasadt gs ON gs.id = ga.GuiaID "&_
                                                            " LEFT JOIN tissunidademedida um ON um.id = ga.UnidadeMedidaID "&_
                                                            " WHERE ga.GuiaID="&req("I")&" AND ga.CD = 1")
                                    Seq = 1
                                    CodigoProduto = ""
                                    Descricao = ""
                                    Data = ""
                                    UnidadeDescricao = ""
                                    Quantidade = 0
                                    ValorUnitario = 0
                                    ValorTotal = 0
                                    TotalQuantidade = 0
                                    TotalGasesMedicinais = CD1SQL("TotalGasesMedicinais")&""

                                    while not CD1SQL.eof
                                        CodigoProduto = CD1SQL("CodigoProduto")&""
                                        Descricao = CD1SQL("Descricao")&""
                                        Data = CD1SQL("Data")&""
                                        UnidadeDescricao = CD1SQL("UnidadeDescricao")&""
                                        Quantidade = CD1SQL("Quantidade")&""
                                        ValorUnitario = CD1SQL("ValorUnitario")&""
                                        ValorTotal = CD1SQL("ValorTotal")&""
                                    %>
                                        <tbody>
                                            <tr class="border-bottom">
                                                <td class="text-left pl10" width="5%"><%=Seq%></td>
                                                <td class="text-left" width="10%"><%=CodigoProduto%></td>
                                                <td class="text-left" width="35%"><%=Descricao%></td>
                                                <td class="text-left" width="10%"><%=Data%></td>
                                                <td class="text-left" width="10%"><%=UnidadeDescricao%></td>
                                                <td class="text-right" width="10%"><%=formatnumber(Quantidade,2)%></td>
                                                <td class="text-right" width="10%"><%=formatnumber(ValorUnitario,2)%></td>
                                                <td class="text-right pr10" width="10%"><%=formatnumber(ValorTotal,2)%></td>
                                            </tr>
                                        <tbody>
                                    <%
                                    TotalQuantidade = TotalQuantidade + Quantidade
                                    Seq = Seq + 1
                                    CD1SQL.movenext
                                    wend
                                    CD1SQL.close
                                    set CD1SQL=nothing
                                    %>
                                    <tfoot>
                                        <tr>
                                            <td class="text-center" colspan="5" width="70%"><strong>Total de Gases</strong></td>
                                            <td class="text-right" width="10%"><strong><%=formatnumber(TotalQuantidade,2)%></strong></td>
                                            <td width="10%"></td>
                                            <td class="text-right pr10" width="10%"><strong><%=formatnumber(TotalGasesMedicinais, 2)%></strong></td>
                                        </tr>
                                    </tfoot>
                                </table>
                            </div>
                        <%
                        end if

                        if ExibeMateriais <> false then%>
                            <div class="bloco">
                                <table padding-left="2px"  width="100%" tborder="0" cellpadding="0" cellspacing="0" style="-fs-table-paginate:paginate;">
                                    <thead style="display:table-header-group">
                                        <div class="bg-secondary titulo-cd"><strong>Materiais</strong></div>
                                        <tr class="bg-secondary">
                                            <th class="text-left pl10" width="5%">Seq.</th>
                                            <th class="text-left" width="10%">Código</th>
                                            <th class="text-left" width="35%">Descrição Material</th>
                                            <th class="text-left" width="10%">Data</th>
                                            <th class="text-left" width="10%">Unid.</th>
                                            <th class="text-right" width="10%">Qtde</th>
                                            <th class="text-right" width="10%">Vl Unit.</th>
                                            <th class="text-right pr10" width="10%">Vl Total</th>
                                        </tr>
                                    </thead>
                                    <%
                                    set CD3SQL = db.execute("SELECT ga.CD, ga.CodigoProduto, ga.Descricao, ga.`Data`, ga.Quantidade, ga.ValorUnitario, ga.ValorTotal, gs.Materiais TotalMateriais, "&_
                                                " um.Descricao UnidadeDescricao "&_
                                                " FROM tissguiaanexa ga "&_
                                                " LEFT JOIN tissguiasadt gs ON gs.id = ga.GuiaID "&_
                                                " LEFT JOIN tissunidademedida um ON um.id = ga.UnidadeMedidaID "&_
                                                " WHERE ga.GuiaID="&req("I")&" AND ga.CD in (3,9)")
                                    Seq = 1
                                    CodigoProduto = ""
                                    Descricao = ""
                                    Data = ""
                                    UnidadeDescricao = ""
                                    Quantidade = 0
                                    ValorUnitario = 0
                                    ValorTotal = 0
                                    TotalQuantidade = 0
                                    TotalMateriais = CD3SQL("TotalMateriais")

                                    while not CD3SQL.eof
                                        CodigoProduto = CD3SQL("CodigoProduto")&""
                                        Descricao = CD3SQL("Descricao")&""
                                        Data = CD3SQL("Data")&""
                                        UnidadeDescricao = CD3SQL("UnidadeDescricao")&""
                                        Quantidade = CD3SQL("Quantidade")&""
                                        ValorUnitario = CD3SQL("ValorUnitario")&""
                                        ValorTotal = CD3SQL("ValorTotal")&""
                                    %>
                                        <tbody>
                                            <tr class="border-bottom">
                                                <td class="text-left pl10" width="5%"><%=Seq%></td>
                                                <td class="text-left" width="10%"><%=CodigoProduto%></td>
                                                <td class="text-left" width="35%"><%=Descricao%></td>
                                                <td class="text-left" width="10%"><%=Data%></td>
                                                <td class="text-left" width="10%"><%=UnidadeDescricao%></td>
                                                <td class="text-right" width="10%"><%=formatnumber(Quantidade,2)%></td>
                                                <td class="text-right" width="10%"><%=formatnumber(ValorUnitario,2)%></td>
                                                <td class="text-right pr10" width="10%"><%=formatnumber(ValorTotal,2)%></td>
                                            </tr>
                                        </tbody>
                                    <%
                                    TotalQuantidade = TotalQuantidade + Quantidade
                                    Seq = Seq + 1                     
                                    CD3SQL.movenext
                                    wend
                                    CD3SQL.close
                                    set CD3SQL=nothing
                                    %>
                                    <tfoot>
                                        <tr>
                                            <td class="text-center" colspan="5" width="70%"><strong>Total de Materiais</strong></td>
                                            <td class="text-right" width="10%"><strong><%=formatnumber(TotalQuantidade,2)%></strong></td>
                                            <td width="10%"></td>
                                            <td class="text-right pr10" width="10%"><strong><%=formatnumber(TotalMateriais, 2)%></strong></td>
                                        </tr>
                                    </tfoot>
                                </table>
                            </div>
                        <%
                        end if

                        if ExibeOPME <> false then
                        %>
                            <div class="bloco">
                                <table padding-left="2px"  width="100%" tborder="0" cellpadding="0" cellspacing="0" style="-fs-table-paginate:paginate;">
                                    <thead style="display:table-header-group">
                                        <div class="bg-secondary titulo-cd"><strong>OPME</strong></div>
                                        <tr class="bg-secondary">
                                            <th class="text-left pl10" width="5%">Seq.</th>
                                            <th class="text-left" width="10%">Código</th>
                                            <th class="text-left" width="35%">Descrição OPME</th>
                                            <th class="text-left" width="10%">Data</th>
                                            <th class="text-left" width="10%">Unid.</th>
                                            <th class="text-right" width="10%">Qtde</th>
                                            <th class="text-right" width="10%">Vl Unit.</th>
                                            <th class="text-right pr10" width="10%">Vl Total</th>
                                        </tr>
                                    </thead>
                                    <%                        
                                    set CD8SQL = db.execute("SELECT ga.CD, ga.CodigoProduto, ga.Descricao, ga.`Data`, ga.Quantidade, ga.ValorUnitario, ga.ValorTotal, gs.OPME TotalOPME, "&_
                                                " um.Descricao UnidadeDescricao "&_
                                                " FROM tissguiaanexa ga "&_
                                                " LEFT JOIN tissguiasadt gs ON gs.id = ga.GuiaID "&_
                                                " LEFT JOIN tissunidademedida um ON um.id = ga.UnidadeMedidaID "&_
                                                " WHERE ga.GuiaID="&req("I")&" AND ga.CD = 8")
                                    Seq = 1
                                    CodigoProduto = ""
                                    Descricao = ""
                                    Data = ""
                                    UnidadeDescricao = ""
                                    Quantidade = 0
                                    ValorUnitario = 0
                                    ValorTotal = 0
                                    TotalQuantidade = 0
                                    TotalOPME = CD8SQL("TotalOPME")

                                    while not CD8SQL.eof
                                        CodigoProduto = CD8SQL("CodigoProduto")&""
                                        Descricao = CD8SQL("Descricao")&""
                                        Data = CD8SQL("Data")&""
                                        UnidadeDescricao = CD8SQL("UnidadeDescricao")&""
                                        Quantidade = CD8SQL("Quantidade")&""
                                        ValorUnitario = CD8SQL("ValorUnitario")&""
                                        ValorTotal = CD8SQL("ValorTotal")&""
                                    %>
                                        <tbody>
                                            <tr class="border-bottom">
                                                <td class="text-left pl10" width="5%"><%=Seq%></td>
                                                <td class="text-left" width="10%"><%=CodigoProduto%></td>
                                                <td class="text-left" width="35%"><%=Descricao%></td>
                                                <td class="text-left" width="10%"><%=Data%></td>
                                                <td class="text-left" width="10%"><%=UnidadeDescricao%></td>
                                                <td class="text-right" width="10%"><%=formatnumber(Quantidade,2)%></td>
                                                <td class="text-right" width="10%"><%=formatnumber(ValorUnitario,2)%></td>
                                                <td class="text-right pr10" width="10%"><%=formatnumber(ValorTotal,2)%></td>
                                            </tr>
                                        <tbody>
                                    <%
                                    TotalQuantidade = TotalQuantidade + Quantidade
                                    Seq = Seq + 1
                                    CD8SQL.movenext
                                    wend
                                    CD8SQL.close
                                    set CD8SQL=nothing
                                    %>
                                    <tfoot>
                                        <tr>
                                            <td class="text-center" colspan="5" width="70%"><strong>Total de OPME</strong></td>
                                            <td class="text-right" width="10%"><strong><%=formatnumber(TotalQuantidade,2)%></strong></td>
                                            <td width="10%"></td>
                                            <td class="text-right pr10" width="10%"><strong><%=formatnumber(TotalOPME, 2)%></strong></td>
                                        </tr>
                                    </tfoot>
                                </table>
                            </div>
                        <%
                        end if

                        if ExibeMedicamentos <> false then
                        %>
                            <div class="bloco">
                                <table padding-left="2px"  width="100%" tborder="0" cellpadding="0" style="-fs-table-paginate:paginate;">
                                    <thead style="display:table-header-group">
                                        <div class="bg-secondary titulo-cd"><strong>Medicamentos</strong></div>
                                        <tr class="bg-secondary">
                                            <th class="text-left pl10" width="5%">Seq.</th>
                                            <th class="text-left" width="10%">Código</th>
                                            <th class="text-left" width="35%">Descrição Medicamentos</th>
                                            <th class="text-left" width="10%">Data</th>
                                            <th class="text-left" width="10%">Unid.</th>
                                            <th class="text-right" width="10%">Qtde</th>
                                            <th class="text-right" width="10%">Vl Unit.</th>
                                            <th class="text-right pr10" width="10%">Vl Total</th>
                                        </tr>
                                    </thead>                                    
                                    <%
                                    set CD2SQL = db.execute("SELECT ga.CD, ga.CodigoProduto, ga.Descricao, ga.`Data`, ga.Quantidade, ga.ValorUnitario, ga.ValorTotal, gs.Medicamentos TotalMedicamentos, "&_
                                                " um.Descricao UnidadeDescricao "&_
                                                " FROM tissguiaanexa ga "&_
                                                " LEFT JOIN tissguiasadt gs ON gs.id = ga.GuiaID "&_
                                                " LEFT JOIN tissunidademedida um ON um.id = ga.UnidadeMedidaID "&_
                                                " WHERE ga.GuiaID="&req("I")&" AND ga.CD = 2")
                                    Seq = 1
                                    CodigoProduto = ""
                                    Descricao = ""
                                    Data = ""
                                    UnidadeDescricao = ""
                                    Quantidade = 0
                                    ValorUnitario = 0
                                    ValorTotal = 0
                                    TotalQuantidade = 0
                                    TotalMedicamentos = CD2SQL("TotalMedicamentos")

                                    while not CD2SQL.eof
                                        CodigoProduto = CD2SQL("CodigoProduto")&""
                                        Descricao = CD2SQL("Descricao")&""
                                        Data = CD2SQL("Data")&""
                                        UnidadeDescricao = CD2SQL("UnidadeDescricao")&""
                                        Quantidade = CD2SQL("Quantidade")&""
                                        ValorUnitario = CD2SQL("ValorUnitario")&""
                                        ValorTotal = CD2SQL("ValorTotal")&""
                                    %>
                                        <tbody>
                                            <tr class="border-bottom">
                                                <td class="text-left pl10" width="5%"><%=Seq%></td>
                                                <td class="text-left" width="10%"><%=CodigoProduto%></td>
                                                <td class="text-left" width="35%"><%=Descricao%></td>
                                                <td class="text-left" width="10%"><%=Data%></td>
                                                <td class="text-left" width="10%"><%=UnidadeDescricao%></td>
                                                <td class="text-right" width="10%"><%=formatnumber(Quantidade,2)%></td>
                                                <td class="text-right" width="10%"><%=formatnumber(ValorUnitario,2)%></td>
                                                <td class="text-right pr10" width="10%"><%=formatnumber(ValorTotal,2)%></td>
                                            </tr>
                                        </tbody>
                                    <%
                                    TotalQuantidade = TotalQuantidade + Quantidade
                                    Seq = Seq + 1
                                    CD2SQL.movenext
                                    wend
                                    CD2SQL.close
                                    set CD2SQL=nothing
                                    %> 
                                    <tfoot>
                                        <tr>
                                            <td class="text-center" colspan="5" width="70%"><strong>Total de Medicamentos</strong></td>
                                            <td class="text-right" width="10%"><strong><%=formatnumber(TotalQuantidade,2)%></strong></td>
                                            <td width="10%"></td>
                                            <td class="text-right pr10" width="10%"><strong><%=formatnumber(TotalMedicamentos, 2)%></strong></td>
                                        </tr>
                                    </tfoot>
                                </table>
                            </div>
                        <%
                        end if
                        
                        if ExibeTaxas <> false then
                        %>
                            <div class="bloco">
                                <table padding-left="2px"  width="100%" tborder="0" cellpadding="0" cellspacing="0" style="-fs-table-paginate:paginate;">
                                    <thead style="display:table-header-group">
                                        <div class="bg-secondary titulo-cd"><strong>Taxas e Aluguel</strong></div>
                                        <tr class="bg-secondary">
                                            <th class="text-left pl10" width="5%">Seq.</th>
                                            <th class="text-left" width="10%">Código</th>
                                            <th class="text-left" width="35%">Descrição de Taxa e Aluguel</th>
                                            <th class="text-left" width="10%">Data</th>
                                            <th width="10%"></th>
                                            <th class="text-right" width="10%">Qtde</th>
                                            <th class="text-right" width="10%">Vl Unit.</th>
                                            <th class="text-right pr10" width="10%">Vl Total</th>
                                        </tr>
                                    </thead>
                                    <%
                                    set CD7SQL = db.execute("SELECT ga.CD, ga.CodigoProduto, ga.Descricao, ga.`Data`, ga.Quantidade, ga.ValorUnitario, ga.ValorTotal, gs.TaxasEAlugueis TotalTaxasEAlugueis, "&_
                                                " um.Descricao UnidadeDescricao "&_
                                                " FROM tissguiaanexa ga "&_
                                                " LEFT JOIN tissguiasadt gs ON gs.id = ga.GuiaID "&_
                                                " LEFT JOIN tissunidademedida um ON um.id = ga.UnidadeMedidaID "&_
                                                " WHERE ga.GuiaID="&req("I")&" AND ga.CD = 7")
                                    Seq = 1
                                    CodigoProduto = ""
                                    Descricao = ""
                                    Data = ""
                                    UnidadeDescricao = ""
                                    Quantidade = 0
                                    ValorUnitario = 0
                                    ValorTotal = 0
                                    TotalQuantidade = 0
                                    TotalTaxasEAlugueis = CD7SQL("TotalTaxasEAlugueis")

                                    while not CD7SQL.eof
                                        CodigoProduto = CD7SQL("CodigoProduto")&""
                                        Descricao = CD7SQL("Descricao")&""
                                        Data = CD7SQL("Data")&""
                                        UnidadeDescricao = CD7SQL("UnidadeDescricao")&""
                                        Quantidade = CD7SQL("Quantidade")&""
                                        ValorUnitario = CD7SQL("ValorUnitario")&""
                                        ValorTotal = CD7SQL("ValorTotal")&""
                                    %>
                                    <tbody>
                                        <tr class="border-bottom">
                                            <td class="text-left pl10" width="5%"><%=Seq%></td>
                                            <td class="text-left" width="10%"><%=CodigoProduto%></td>
                                            <td class="text-left" width="35%"><%=Descricao%></td>
                                            <td class="text-left" width="10%"><%=Data%></td>
                                            <td class="text-left" width="10%"><%=UnidadeDescricao%></td>
                                            <td class="text-right" width="10%"><%=formatnumber(Quantidade,2)%></td>
                                            <td class="text-right" width="10%"><%=formatnumber(ValorUnitario,2)%></td>
                                            <td class="text-right pr10" width="10%"><%=formatnumber(ValorTotal,2)%></td>
                                        </tr>
                                    </tbody>
                                    <%
                                    TotalQuantidade = TotalQuantidade + Quantidade
                                    Seq = Seq + 1
                                    CD7SQL.movenext
                                    wend
                                    CD7SQL.close
                                    set CD7SQL=nothing
                                    %>
                                    <tfoot>         
                                        <tr>
                                            <td class="text-center" colspan="5" width="70%"><strong>Total de Taxas</strong></td>
                                            <td class="text-right" width="10%"><strong><%=formatnumber(TotalQuantidade,2)%></strong></td>
                                            <td width="10%"></td>
                                            <td class="text-right pr10" width="10%"><strong><%=formatnumber(TotalTaxasEAlugueis, 2)%></strong></td>
                                        </tr>
                                    </tfoot>
                                </table>
                            </div>
                        <%
                        end if
                        %>
                        <div class="bloco">
                            <table padding-left="2px"  width="100%" tborder="0" cellpadding="0" cellspacing="0" style="-fs-table-paginate:paginate;">
                                <thead style="display:table-header-group">
                                    <div class="bg-secondary titulo-cd"><strong>Procedimentos</strong></div>
                                    <tr class="bg-secondary">
                                        <th class="text-left pl10" width="5%">Seq.</th>
                                        <th class="text-left" width="10%">Código</th>
                                        <th class="text-left" width="35%">Descrição</th>
                                        <th class="text-left" width="20%">Médico</th>
                                        <th class="text-left" width="5%">Data</th>
                                        <th class="text-right" width="5%">Qtd</th>
                                        <th class="text-right" width="10%">Vl Unit.</th>
                                        <th class="text-right pr10" width="10%">Vl Total</th>
                                    </tr>
                                </thead>
                                <%
                                set ProcSQL = db.execute("SELECT ps.codigoProcedimento Codigo, ps.Descricao, ps.`Data`, ps.Quantidade, ps.ValorUnitario, ps.ValorTotal, gs.Procedimentos TotalProcedimentos, gs.TotalGeral, p.NomeProfissional Medico "&_
                                                        " FROM tissprocedimentossadt ps "&_
                                                        " LEFT JOIN tissguiasadt gs ON gs.id = ps.GuiaID "&_
                                                        " LEFT JOIN profissionais p ON p.id = ps.ProfissionalID "&_
                                                        " WHERE GuiaID="&req("I"))

                                Codigo = ""
                                Descricao = ""
                                Medico = ""
                                Data = ""
                                UnidadeDescricao = ""
                                Quantidade = 0
                                ValorUnitario = 0
                                ValorTotal = 0
                                TotalQuantidade = 0
                                Seq = 1
                                TotalProcedimentos = ProcSQL("TotalProcedimentos")
                                TotalGeral = ProcSQL("TotalGeral")

                                while not ProcSQL.eof
                                    Codigo = ProcSQL("Codigo")
                                    Descricao = ProcSQL("Descricao")
                                    Medico = ProcSQL("Medico")
                                    Data = ProcSQL("Data")
                                    Quantidade = ProcSQL("Quantidade")
                                    ValorUnitario = ProcSQL("ValorUnitario")
                                    ValorTotal = ProcSQL("ValorTotal")
                                %>
                                    <tbody>
                                        <tr class="border-bottom">
                                            <td class="text-left pl10" width="5%"><%=Seq%></td>
                                            <td class="text-left" width="10%"><%=Codigo%></td>
                                            <td class="text-left" width="35%"><%=Descricao%></td>
                                            <td class="text-left" width="20%"><%=Medico%></td>
                                            <td class="text-left" width="5%"><%=Data%></td>
                                            <td class="text-right" width="5%"><%=formatnumber(Quantidade,2)%></td>
                                            <td class="text-right" width="10%"><%=formatnumber(ValorUnitario,2)%></td>
                                            <td class="text-right pr10" width="10%"><%=formatnumber(ValorTotal,2)%></td>
                                        </tr>
                                    </tbody>
                                <%
                                TotalQuantidade = TotalQuantidade + Quantidade
                                Seq = Seq + 1
                                ProcSQL.movenext
                                wend
                                ProcSQL.close
                                set ProcSQL=nothing
                                %> 
                                <tfoot>
                                    <tr>
                                        <td class="text-center" colspan="5" width="75%"><strong>Total de Procedimentos</strong></td>
                                        <td class="text-right" width="5%"><strong><%=formatnumber(TotalQuantidade,2)%></strong></td>
                                        <td width="10%"></td>
                                        <td class="text-right pr10" width="10%"><strong><%=formatnumber(TotalProcedimentos, 2)%></strong></td>
                                    </tr>
                                </tfoot>
                            </table>
                        </div>

                        <div class="bloco">
                            <table padding-left="2px"  width="100%" tborder="0" cellpadding="0" cellspacing="0" style="-fs-table-paginate:paginate;">
                                <tbody>
                                    <tr class="bg-secondary">
                                        <td class="text-right pr10" colspan="7" width="90%"><strong>Total Geral:</strong></td>
                                        <td class="text-right pr10" width="10%"><strong><%=formatnumber(TotalGeral,2)%></strong></td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>                
               </td>
            </tr>
        </tbody>
    </table>
</body>
</html>
<script type="text/javascript">
    window.print();
	window.addEventListener("afterprint", function(event) { window.close(); });
	window.onafterprint();
</script>

<!-- jQuery (necessary for Bootstrap's JavaScript plugins) -->
<script src="https://code.jquery.com/jquery-1.12.4.min.js" integrity="sha384-nvAa0+6Qg9clwYCGGPpDQLVpLNn0fRaROjHqs13t4Ggj3Ez50XnGQqc/r8MhnRDZ" crossorigin="anonymous"></script>
<!-- Include all compiled plugins (below), or include individual files as needed -->
<script src="https://stackpath.bootstrapcdn.com/bootstrap/3.4.1/js/bootstrap.min.js" integrity="sha384-aJ21OjlMXNL5UyIl/XNwTMqvzeRMZH2w8c5cRVpzpU8Y5bApTppSuUkhZXN0VxHd" crossorigin="anonymous"></script>