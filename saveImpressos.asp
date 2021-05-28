<!--#include file="connect.asp"-->
<%
camposrecibo = ref("CamposRecibos")
odemcampos = ref("Ordem")
camposvisiveis = ref("Visiveis")
if req("Tipo")="RecibosIntegrados" or req("Tipo")="RecibosIntegradosAPagar" then
    'configuração modelo - salvar campos que podem ser visiveis
    spcampos = Split(camposrecibo, "|")
    spordem = Split(odemcampos, "|")
    spcamposvisiveis = Split(camposvisiveis, "|")
    sqlvar = "select rcm.Nome, rc.* from recibo_campos rc join cliniccentral.recibo_campos_modelo rcm on rc.campoId = rcm.id where  rc.tipo='"&req("Tipo")&"'"
    set exec = db.execute(sqlvar)
    if not exec.eof then
        'db_execute("update recibo_campos set exibir='N',ordem=20 where sysUser="&session("User")&" and tipo='"&req("Tipo")&"'")
        for i=0 to Ubound(spcampos)
            if(spcampos(i)<>"")then
                sqlup = "update recibo_campos set exibir='"&spcamposvisiveis(i)&"',ordem="&spordem(i)&" where  campoId="&spcampos(i)&" and tipo='"&req("Tipo")&"'"
                'response.write(sqlup)
                db_execute(sqlup)
            end if
        next
    end if
end if

if req("Tipo")="Timbrado" then
	sql = "Cabecalho='"&refhtml("Cabecalho")&"', Rodape='"&refhtml("Rodape")&"'"
elseif req("Tipo")="Propostas" then
	sql = "CabecalhoProposta='"&refhtml("CabecalhoProposta")&"', RodapeProposta='"&refhtml("RodapeProposta")&"', ItensProposta='"&refhtml("ItensProposta")&"'"
else
	sql = req("Tipo")&"='"&refhtml(""&req("Tipo")&"")&"'"
end if

set reg = db.execute("select * from Impressos")
if reg.EOF then
	db_execute("insert into Impressos (Cabecalho) values ('')")
end if
db_execute("update Impressos set "&sql & " WHERE Executante IS NULL")

%>

new PNotify({
    sql: 'pacote=<%=ref("AgruparPacotes")%>, itens=<%=ref("AgruparItem")%>',
    title: 'Salvo com sucesso',
    text: 'Modelo de impresso salvo com sucesso.',
    type: 'success',
    delay: 1000
});