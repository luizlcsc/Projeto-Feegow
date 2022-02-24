<link href="assets/css/core-screen.css" rel="stylesheet" media="screen" type="text/css" />
<link href="assets/css/core.css" rel="stylesheet" media="print" type="text/css" />
<%
response.Charset="utf-8"
%>
<!--#include file="connect.asp"-->
<a style="position:fixed; background-color:#0CF; color:#FFF; right:14px; z-index:10000000; text-decoration:none; padding:5px;" href="#" onclick="print()" class="print" rel="areaImpressao">
	<img src="assets/img/printer.png" border="0" alt="IMPRIMIR" title="IMPRIMIR" align="absmiddle"> <strong>IMPRIMIR</strong>
</a>
<div id="areaImpressao">
<%
set reg=db.execute("select * from recibos where id="&req("ReciboID"))
if not reg.EOF then
	Recibo = reg("Texto")
end if

        set getImpressos = db.execute("select * from Impressos")
        if not getImpressos.EOF then
            Cabecalho = getImpressos("Cabecalho")
            Rodape = getImpressos("Rodape")
            set timb = db.execute("select * from papeltimbrado where sysActive=1 AND profissionais like '%|ALL|%'")
            if not timb.eof then
                Cabecalho = timb("Cabecalho")
                Rodape = timb("Rodape")
            end if
            if lcase(session("table"))="profissionais" then
                set timb = db.execute("select * from papeltimbrado where sysActive=1 AND profissionais like '%|"&session("idInTable")&"|%'")
                if not timb.eof then
                    Cabecalho = timb("Cabecalho")
                    Rodape = timb("Rodape")
                end if
            end if
        end if
        Cabecalho = unscapeOutput(Cabecalho)
        Rodape = unscapeOutput(Rodape)
%>
<table width="100%" height="100%" cellpadding="0" cellspacing="0" border="0">
	<tr>
    	<td>
            <%= Cabecalho %>
        </td>
    </tr>
    <tr>
    	<td height="99%">
            <%= Recibo %>
        </td>
    </tr>
    <tr>
    	<td>
            <%= Rodape %>
		</td>
    </tr>
</table>
</div>