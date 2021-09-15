<!--#include file="connect.asp"-->

<%
if req("addProc")="1" then
    %>
    <%= quickfield("simpleSelect", "ProcedimentoAdicionar", "Selecione o procedimento a anexar", 12, "", "select id, NomeProcedimento from procedimentos where sysActive=1 order by NomeProcedimento", "NomeProcedimento", " onchange='confAddProc($(this).val())'") %>
    <%
end if


if req("confAddProc")<>"" then
    db_execute("insert into tissprocedimentosanexos (AssociacaoID,ConvenioID, ProcedimentoPrincipalID, ProcedimentoAnexoID, sysUser) values (NULLIF('"&req("AssociacaoID")&"',''),"& req("ConvenioID") &", "& req("ProcedimentoID") &", "& req("confAddProc") &", "&session("User")&")")
end if

if req("xProcAnexo")<>"" then
    db_execute("delete from tissprocedimentosanexos where id="& req("xProcAnexo"))
end if

if req("eProcAnexo")<>"" then
    ProcAnexoID = req("eProcAnexo")


    sql = "UPDATE tissprocedimentosanexos SET ValorPadrao="&treatvalnull(req("ValorPadrao"))&",Valor="&treatvalnull(req("Valor"))&","&_
          "QuantidadeCH="&treatValNULLFormat(req("QuantidadeCH"),4)&","&_
          "CustoOperacional="&treatValNULLFormat(req("CustoOperacional"),4)&","&_
          "Coeficiente="&treatValNULLFormat(req("Coeficiente"),4)&","&_
          "Porte='"&req("Porte")&"',"&_
          "Calculo=NULLIF('"&(req("Calculo"))&"',''),"&_
          "Planos=NULLIF('"&(req("Plano"))&"',''),"&_
          "ValorFilme="&treatValNULLFormat(req("ValorFilme"),4)&",QuantidadeFilme="&treatValNULLFormat(req("QuantidadeFilme"),4)&","&_
          "ValorUCO="&treatValNULLFormat(req("ValorUCO"),4)&",ValorCH="&treatValNULLFormat(req("ValorCH"),4)&",Codigo='"&req("Codigo")&"', Descricao='"&req("Descricao")&"' WHERE id="&ProcAnexoID

    db_execute(sql)
end if

if session("Banco")="clinic3882" or session("Banco")="clinic100000" or session("Banco")="clinic105" or true then
    sqlConsultaAnexo = "select pa.*, proc.NomeProcedimento,proc.Codigo as 'CodigoProcedimento',pa.QuantidadeCH,pa.ValorFilme,pa.QuantidadeFilme,pa.ValorUCO,pa.ValorCH,CASE WHEN ValorPadrao = 1 THEN 'S' END as ValorPadraoTratado,ti.Contratados from tissprocedimentosanexos pa LEFT JOIN procedimentos proc ON proc.id=pa.ProcedimentoAnexoID LEFT JOIN tissprocedimentosvalores ti ON ti.id =  AssociacaoID WHERE COALESCE(AssociacaoID=NULLIF('"&req("AssociacaoID")&"',''), pa.ConvenioID = "&req("ConvenioID")&" AND pa.ProcedimentoPrincipalID="&req("ProcedimentoID")&")"

    set procAnexo = db.execute(sqlConsultaAnexo)

    if not procAnexo.eof then
        %>
        <style>.Porte select{padding: 6px;border-radius: 0px;    height: auto;}
            #ConvenioMateriaisProcedimentos .input-group-addon{
                display: none;
            }
        </style>

        <table class="table table-condensed table-bordered">
            <thead>
                <tr>
                    <th width="10%">Procedimento anexo</th>
                    <th >Descrição</th>
                    <th >Valor CH</th>
                    <th >Qtd. CH</th>
                    <th >Valor Filme</th>
                    <th >Qtd. Filme</th>
                    <th >Valor UCO</th>
                    <th >Custo Operacional</th>
                    <th >Valor</th>
                    <th >Coeficiente</th>
                    <th >Porte</th>
                    <th >Cálculo</th>
                    <th >Planos</th>
                    <th >Código</th>
                    <th width="1%"></th>
                    <th width="1%"></th>
                </tr>
            </thead>
            <tbody>
            <%
            while not procAnexo.eof

                Contratados = procAnexo("Contratados")

                PlaceholderCodigo="placeholder="""&procAnexo("CodigoProcedimento")&""""

                db.execute("SET @contratados  = NULLIF('"&Contratados&"','')")
                db.execute("SET @convenio     = "&procAnexo("ConvenioID"))
                db.execute("SET @procedimento = "&procAnexo("ProcedimentoAnexoID"))

                sql = " SELECT coalesce(tissprocedimentosvalores.QuantidadeCH)                                                  as PHPQuantidadeCH                                                               "&chr(13)&_
                      "       ,format(coalesce(tissprocedimentosvalores.CustoOperacional),4,'de_DE')                            as PHPCustoOperacional                                                           "&chr(13)&_
                      "       ,format(coalesce(tissprocedimentosvalores.ValorFilme,convenios.ValorFilme),4,'de_DE')             as PHPValorFilme                                                                 "&chr(13)&_
                      "       ,format(coalesce(tissprocedimentosvalores.QuantidadeFilme),4,'de_DE')                             as PHPQuantidadeFilme                                                            "&chr(13)&_
                      "       ,format(coalesce(tissprocedimentosvalores.ValorUCO,convenios.ValorUCO),4,'de_DE')                 as PHPValorUCO                                                                   "&chr(13)&_
                      "       ,format(coalesce(tissprocedimentosvalores.ValorCH,convenios.ValorCH),4,'de_DE')                   as PHPValorCH                                                                    "&chr(13)&_
                      "       ,format(coalesce(tissprocedimentosvalores.Valor),2,'de_DE')                                       as PHPValorFixo                                                                  "&chr(13)&_
                      "       ,format(coalesce(tissprocedimentosvalores.CoeficientePorte),2,'de_DE')                            as PHPCoeficientePorte                                                           "&chr(13)&_
                      "       ,coalesce(NULLIF(tissprocedimentostabela.Codigo,''),NULLIF(procedimentos.Codigo,''))              as PHPCodigo                                                                     "&chr(13)&_
                      "       ,coalesce(NULLIF(tissprocedimentostabela.Descricao,''),NULLIF(procedimentos.NomeProcedimento,'')) as PHPDescricao                                                                  "&chr(13)&_
                      "       ,tissprocedimentosvalores.Porte                                                                   as PHPPorte                                                                      "&chr(13)&_
                      " FROM convenios                                                                                                                                                                           "&chr(13)&_
                      "          JOIN procedimentos                           ON procedimentos.id                        = @procedimento                                                                         "&chr(13)&_
                      "          LEFT JOIN tissprocedimentosvalores           ON tissprocedimentosvalores.ProcedimentoID = procedimentos.id                                                                      "&chr(13)&_
                      "                                                      AND convenios.id                            = tissprocedimentosvalores.ConvenioID                                                   "&chr(13)&_
                      "          LEFT JOIN contratos                          ON @contratados like CONCAT('%|',contratos.id,'|%') AND tissprocedimentosvalores.contratados like CONCAT('%|',contratos.id,'|%')   "&chr(13)&_
                      "          LEFT JOIN cliniccentral.tabelasportesvalores ON tabelasportesvalores.Porte              = procedimentos.Porte                                                                   "&chr(13)&_
                      "                                                      AND tabelasportesvalores.TabelaPorteID      = coalesce(convenios.TabelaPorte)                                                       "&chr(13)&_
                      "          LEFT JOIN tissprocedimentostabela            ON tissprocedimentostabela.id              = tissprocedimentosvalores.ProcedimentoTabelaID                                         "&chr(13)&_
                      " WHERE convenios.id = @convenio;                                                                                                                                                          "

                 set PHolders = db.execute(sql)

                IF NOT PHolders.EOF THEN
                    PHPQuantidadeCH     = PHolders("PHPQuantidadeCH")
                    PHPCustoOperacional = PHolders("PHPCustoOperacional")
                    PHPValorFilme       = PHolders("PHPValorFilme")
                    PHPQuantidadeFilme  = PHolders("PHPQuantidadeFilme")
                    PHPValorUCO         = PHolders("PHPValorUCO")
                    PHPValorCH          = PHolders("PHPValorCH")
                    PHPValorFixo        = PHolders("PHPValorFixo")
                    PHPCodigo           = PHolders("PHPCodigo")
                    PHPCoeficiente      = PHolders("PHPCoeficientePorte")
                    PHPDescricao        = PHolders("PHPDescricao")
                    PHPPorte            = PHolders("PHPPorte")
                END IF

                descricao = procAnexo("Descricao")&""
                IF descricao = "" THEN
                    descricao = PHPDescricao
                END IF

                Porte = procAnexo("Porte")
                IF Porte = "" THEN
                    Porte = PHPPorte
                END IF

                Planos = procAnexo("Planos")
                %>
                <tr>
                    <td><%= procAnexo("NomeProcedimento") %></td>
                    <td><%=quickField("text", "DescricaoAnexo"&procAnexo("id"), "", 12, descricao, " input-sm Descricao ProcedimentoAnexoCampo ", "", "  ")%></td>
                    <td><%=quickField("currency", "ValorCH"&procAnexo("id")   , "", 12, procAnexo("ValorCH"), " input-sm ValorCH sql-mask-4-digits   ProcedimentoAnexoCampo", "", " placeHolder='"&PHPValorCH&"' ")%></td>
                    <td><%=quickField("currency", "QuantidadeCH"&procAnexo("id"), "", 12, procAnexo("QuantidadeCH"), " input-sm QuantidadeCH sql-mask-4-digits ProcedimentoAnexoCampo", "", " placeHolder='"&PHPQuantidadeCH&"' ")%></td>
                    <td><%=quickField("currency", "ValorFilme"&procAnexo("id"), "", 12, procAnexo("ValorFilme"), " input-sm ValorFilme sql-mask-4-digits ProcedimentoAnexoCampo", "", " placeHolder='"&PHPValorFilme&"' ")%></td>
                    <td><%=quickField("currency", "QuantidadeFilme"&procAnexo("id"), "", 12, procAnexo("QuantidadeFilme"), " input-sm sql-mask-4-digits QuantidadeFilme ProcedimentoAnexoCampo", "", " placeHolder='"&PHPQuantidadeFilme&"' ")%></td>
                    <td><%=quickField("currency", "ValorUCO"&procAnexo("id")  , "", 12, procAnexo("ValorUCO"), " input-sm ValorUCO sql-mask-4-digits  ProcedimentoAnexoCampo", "", " placeHolder='"&PHPValorUCO&"' ")%></td>
                    <td><%=quickField("currency", "CustoOperacional"&procAnexo("id"), "", 12, procAnexo("CustoOperacional")," input-sm CustoOperacional ProcedimentoAnexoCampo", "", " placeHolder='"&PHPCustoOperacional&"' ")%></td>
                    <td><%=quickField("currency", "ValorAnexo"&procAnexo("id"), "", 12, procAnexo("Valor")," input-sm Valor ProcedimentoAnexoCampo", "",  " placeHolder='"&PHPValorFixo&"' ")%></td>
                    <td><%=quickField("currency", "Coeficiente"&procAnexo("id"), "", 12, procAnexo("Coeficiente")," input-sm Coeficiente ProcedimentoAnexoCampo", "",  " placeHolder='"&PHPCoeficiente&"' ")%></td>
                    <td class="Porte"><%=quickField("simpleSelect", "Porte"&procAnexo("id"), "", 2,  Porte, "SELECT distinct Porte id,Porte  FROM cliniccentral.tabelasportesvalores", "Porte", " no-select2 ")%></td>
                    <td class="Calculo"><%=quickField("multiple", "ModoDeCalculo"&procAnexo("id"), "", 2, procAnexo("Calculo"), "select 'R$' id, 'R$' Descricao UNION ALL select 'CH', 'CH' UNION ALL SELECT 'UCO', 'UCO' UNION ALL SELECT 'PORTE', 'PORTE' UNION ALL SELECT 'FILME', 'FILME'", "Descricao", " semVazio no-select2")%></td>
                    <td class="Plano"><%=quickField("multiple", "Plano"&procAnexo("id"), "", 2, Planos, "SELECT *FROM conveniosplanos WHERE ConvenioID = "&req("ConvenioID"), "NomePlano", " semVazio no-select2")%></td>
                    <td><%=quickField("text", "ValorAnexo"&procAnexo("id"), "", 12, procAnexo("Codigo"), " input-sm Codigo ProcedimentoAnexoCampo consultarCentral", "", " placeHolder='"&PHPCodigo&"' ")%></td>
                    <td><%=quickField("simpleCheckbox", "Padrao"&procAnexo("id"), "Padrão", "1", procAnexo("ValorPadraoTratado"), " ValorPadrao ProcedimentoAnexoCampo ", "", "")%></td>
                    <td>
                        <input type="hidden" class="ProcAnexoID" value="<%=procAnexo("id")%>">
                        <button onclick="xProcAnexo(<%= procAnexo("id") %>)" type="button" class="btn btn-xs btn-danger"><i class="far fa-remove"></i></button>
                    </td>
                </tr>
                <%
            procAnexo.movenext
            wend
            procAnexo.close
            set procAnexo=nothing
            %>
            </tbody>
        </table>
        <%
    end if
end if
%>

<input type="hidden" name="E" value="E" />
<table width="100%" class="table table-striped">
    <thead>
        <tr>
            <th width="70%">Item</th>
            <th width="29%"></th>
            <th width="1%"></th>
        </tr>
     </thead>
     <tbody>
<%

I = req("I")'I é item de invoice, que puxa seu grupo
Add = req("Add")
Remove = req("Remove")
Numera = 0

'function linhaMaterial(id, ValorUnitario, Executado, DataExecucao, HoraExecucao, HoraFim, ProfissionalID, Desconto, Numera)
function linhaMaterial(id, ValorUnitario, ProdutoID, CD, TabelaProdutoID, CodigoProduto, RegistroANVISA, CodigoNoFabricante, AutorizacaoEmpresa, Quantidade, UnidadeMedidaID, Numera)
	if Quantidade<>"" and isnumeric(Quantidade) then Quantidade=formatnumber(Quantidade,2) end if
	'if ValorUnitario<>"" and not isnull(ValorUnitario) and isnumeric(ValorUnitario) then
    '    ValorUnitario=fn(ValorUnitario)
    'else
        if ProdutoID<>"" and req("ConvenioID")<>"" then
            set pval = db.execute("select pt.Valor from tissprodutostabela pt left join tissprodutosvalores pv on pt.id=pv.ProdutoTabelaID where pv.ConvenioID="&req("ConvenioID")&" and pt.ProdutoID="&ProdutoID)'!
            if not pval.eof then
                ValorUnitario = pval("Valor")
            end if
        end if
    'end if
	if not isnumeric(ProdutoID) or ProdutoID="" then ProdutoID=0 end if
	%>
    <tr><td>
      <div class="row">
		<div class="col-md-4"><%= selectInsert("Descri&ccedil;&atilde;o", "ProdutoID"&id, ProdutoID, "produtos", "NomeProduto", " onchange=""tissCompletaDados(5, this.value, "&id&");""", "required", "") %></div>
		<%
		call quickField("simpleSelect", "CD"&id, "CD", 2, CD, "select * from cliniccentral.tisscd order by id", "Descricao", " empty='empty' required='required' no-select2")
		call quickField("simpleSelect", "TabelaProdutoID"&id, "Tabela", 3, TabelaProdutoID, "select * from cliniccentral.tabelasprocedimentos where Ativo='S' and (Despesa=1 or Despesa is null) order by descricao", "descricao", " empty='' required='required' no-select2")
		call quickField("text", "CodigoProduto"&id, "C&oacute;digo do Item", 3, CodigoProduto, "", "", " required='required'")
		%>
      </div>
      <div class="row">
      	<%
		call quickField("text", "RegistroANVISA"&id, "Reg. ANVISA", 4, RegistroANVISA, "", "", "")
        call quickField("text", "CodigoNoFabricante"&id, "C&oacute;d. no Fab.", 4, CodigoNoFabricante, "", "", "")
        call quickField("text", "AutorizacaoEmpresa"&id, "N&deg; Aut. Func. Emp.", 4, AutorizacaoEmpresa, "", "", "")
        %>
       </div>
    </td>
    <td>
    	<%
        call quickField("text", "Quantidade"&id, "Quantidade", 6, Quantidade, " input-mask-brl input-sm", "", " required='required'")
        call quickField("simpleSelect", "UnidadeMedidaID"&id, "Unidade", 6, UnidadeMedidaID, "select * from cliniccentral.tissunidademedida order by descricao", "descricao", " empty='' required='required' no-select2")
		call quickField("currency", "ValorUnitario"&id, "Valor Unit.", 12, ValorUnitario, "", "", "")
		%>
    </div>
    </td>



	<td><button type="button" class="btn btn-danger btn-xs" onClick="Remove(<%=id%>);"><i class="far fa-remove"></i></button></td></tr>

<%
end function

if ref("E")="" then
	str = "db"
else
	str = ref("str")
end if


if isnumeric(Remove) and Remove<>"" then
	str = replace(str, "|"&Remove&"|", "")
end if

'response.Write(ref("str"))

contaParalela = 0
if str="db" then
    if 0 then
	    set pitem = db.execute("select * from tissprocedimentosvalores where ConvenioID="&req("ConvenioID")&" and ProcedimentoID="&req("ProcedimentoID"))
	    if not pitem.EOF then
		    AssociacaoID = pitem("id")
		    set itens = db.execute("select pp.id as ppid, pp.*, pv.*, pt.*, p.CD, p.RegistroANVISA, p.AutorizacaoEmpresa, p.ApresentacaoUnidade, p.Codigo as CodigoNoFabricante from tissprodutosprocedimentos as pp left join tissprodutosvalores as pv on pv.id=pp.ProdutoValorID left join tissprodutostabela as pt on pt.id=pv.ProdutoTabelaID left join produtos as p on p.id=pt.ProdutoID where pp.AssociacaoID="&AssociacaoID)
		    while not itens.eof
			    Numera = Numera+1
			    call( linhaMaterial(itens("ppid"), itens("Valor"), itens("ProdutoID"), itens("CD"), itens("TabelaID"), itens("Codigo"), itens("RegistroANVISA"), itens("CodigoNoFabricante"), itens("AutorizacaoEmpresa"), itens("Quantidade"), itens("ApresentacaoUnidade"), Numera) )
			    newstr = newstr&"|"&itens("ppid")&"|"
		    itens.movenext
		    wend
		    itens.close
		    set itens = nothing
	    end if
    else
        set pp = db.execute("select pp.* from tissprodutosprocedimentos pp LEFT JOIN tissprocedimentosvalores pcv ON pcv.id=pp.AssociacaoID WHERE pcv.ConvenioID="&req("ConvenioID")&" AND pcv.ProcedimentoID="& req("ProcedimentoID"))
        while not pp.EOF
            PPID = pp("id")
            ProdutoTabelaID = pp("ProdutoTabelaID")
            Quantidade = pp("Quantidade")
            if not isnull(ProdutoTabelaID) then
                set pt = db.execute("select pt.Valor, pt.ProdutoID, p.CD, pt.TabelaID, pt.Codigo, p.RegistroANVISA, p.AutorizacaoEmpresa, p.ApresentacaoUnidade, p.Codigo CodigoNoFabricante from tissprodutostabela pt LEFT JOIN produtos p ON p.id=pt.ProdutoID WHERE pt.id="& ProdutoTabelaID)
                if not pt.eof then
                    Valor = pt("Valor")
                    ProdutoID = pt("ProdutoID")
                    CD = pt("CD")
                    TabelaID = pt("TabelaID")
                    Codigo = pt("Codigo")
                    RegistroANVISA = pt("RegistroANVISA")
                    AutorizacaoEmpresa = pt("AutorizacaoEmpresa")
                    ApresentacaoUnidade = pt("ApresentacaoUnidade")
                    CodigoNoFabricante = pt("CodigoNoFabricante")
                end if
                set pv = db.execute("select pv.Valor from tissprodutosvalores pv WHERE pv.ConvenioID="& req("ConvenioID")&" AND pv.ProdutoTabelaID="& ProdutoTabelaID)
                'se tem pv, troca o valor
                if not pv.eof then
                    Valor = pv("Valor")
                end if
			    Numera = Numera+1
			    call( linhaMaterial( ppid, Valor, ProdutoID, CD, TabelaID, Codigo, RegistroANVISA, CodigoNoFabricante, AutorizacaoEmpresa, Quantidade, ApresentacaoUnidade, Numera ) )
			    newstr = newstr&"|"& ppid &"|"
            end if
        pp.movenext
        wend
        pp.close
        set pp=nothing


    end if
else
	spl = split(str, "|")
	for i=0 to ubound(spl)
		if spl(i)<>"" then
			if ccur(spl(i))<contaParalela then
				contaParalela = ccur(spl(i))
			end if
			Numera = Numera+1
			call( linhaMaterial(spl(i), ref("ValorUnitario"&spl(i)), ref("ProdutoID"&spl(i)), ref("CD"&spl(i)), ref("TabelaProdutoID"&spl(i)), ref("CodigoProduto"&spl(i)), ref("RegistroANVISA"&spl(i)), ref("CodigoNoFabricante"&spl(i)), ref("AutorizacaoEmpresa"&spl(i)), ref("Quantidade"&spl(i)), ref("UnidadeMedidaID"&spl(i)), Numera) )
			newstr = newstr&"|"&spl(i)&"|"
		end if
	next
end if

if isnumeric(Add) and Add<>"" then
	if ccur(Add)>0 then
		c=0
		while c<ccur(Add)
			c=c+1
			contaParalela = contaParalela-1
			Numera = Numera+1
			call( linhaMaterial(contaParalela, "", "", "", "", "", "", "", "", "", "", Numera) )
			newstr = newstr&"|"&contaParalela&"|"
		wend
	end if
end if
%>
    </tbody>
    <tfoot>
      <tr>
    	<td colspan="6"><%=Numera%> itens</td>
        <td colspan="2"><%if c>1 then%><button type="button" class="btn btn-danger btn-block btn-xs" onClick="removeItem('Grupo', <%=ItemID%>); $('#modal-table').modal('hide');"><i class="far fa-remove"></i> Remover Todos</button><%end if%></td>
      </tr>
    </tfoot>
</table>

<input type="hidden" name="str" value="<%=newstr%>" />
<script type="text/javascript">
function atualizarLinha(arg) {
    var $linha = $(arg).parents("tr");
    var Valor = $linha.find(".Valor").val();
    var Codigo = $linha.find(".Codigo").val();
    var ProcedimentoID = $linha.find(".ProcAnexoID").val();
    var Descricao = $linha.find(".Descricao").val();

    var QuantidadeCH     = $linha.find(".QuantidadeCH").val();
    var ValorFilme       = $linha.find(".ValorFilme").val();
    var QuantidadeFilme  = $linha.find(".QuantidadeFilme").val();
    var ValorUCO         = $linha.find(".ValorUCO").val();
    var ValorCH          = $linha.find(".ValorCH").val();
    var CustoOperacional = $linha.find(".CustoOperacional").val();
    var Coeficiente      = $linha.find(".Coeficiente").val();
    var Porte            = $linha.find(".Porte select").val();
    var Calculo          = $linha.find(".Calculo select").val()
    var Plano            = $linha.find(".Plano select").val()
    var ValorPadrao      = $linha.find(".ValorPadrao").is(":checked")?"1":"0";

    $.get("ConvenioMateriaisProcedimentos.asp?eProcAnexo="+ ProcedimentoID
            +"&Codigo="+Codigo
            +"&QuantidadeCH="+QuantidadeCH
            +"&ValorFilme="+ValorFilme
            +"&QuantidadeFilme="+QuantidadeFilme
            +"&ValorUCO="+ValorUCO
            +"&ValorCH="+ValorCH
            +"&Descricao="+Descricao
            +"&Valor="+Valor
            +"&ValorPadrao="+ValorPadrao
            +"&CustoOperacional="+CustoOperacional
            +"&Coeficiente="+Coeficiente
            +"&Plano="+(Plano?Plano:'')
            +"&Porte="+Porte
            +"&Calculo="+(Calculo?Calculo:'')
            +"&ConvenioID=<%=req("ConvenioID")%>&ProcedimentoID=<%=req("ProcedimentoID")%>", function(data){
        //$("#ConvenioMateriaisProcedimentos").html(data);
    });
}
$(".ProcedimentoAnexoCampo,.Plano select,.Porte select,.Calculo select").change((arg) => {
    atualizarLinha(arg.target)
});

function confAddProc(ProcedimentoID) {
    $.get("ConvenioMateriaisProcedimentos.asp?confAddProc="+ ProcedimentoID +"&ConvenioID=<%=req("ConvenioID")%>&ProcedimentoID=<%=req("ProcedimentoID")%>&AssociacaoID=<%=req("AssociacaoID")%>", function(data){
        $("#ConvenioMateriaisProcedimentos").html(data);
    });
}
function xProcAnexo(ProcedimentoID) {

    $.get("ConvenioMateriaisProcedimentos.asp?xProcAnexo="+ ProcedimentoID +"&ConvenioID=<%=req("ConvenioID")%>&ProcedimentoID=<%=req("ProcedimentoID")%>&AssociacaoID=<%=req("AssociacaoID")%>", function(data){
        $("#ConvenioMateriaisProcedimentos").html(data);
    });
}

<!--#include file="jQueryFunctions.asp"-->
</script>