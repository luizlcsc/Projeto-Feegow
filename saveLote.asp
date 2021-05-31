<!--#include file="connect.asp"-->
<%
Acao = req("Acao")
Tipo = req("T")

if Acao="Inserir" then
	if not isnumeric(ref("Lote")) or ref("Lote")="" then
		erro = "N&uacute;mero do lote inv&aacute;lido."
	else
		set vca=db.execute("select * from tisslotes where Lote="&ref("Lote"))
		if not vca.eof then
			erro = "J&aacute; existe um lote com este n&uacute;mero."
		end if
	end if
	if erro<>"" then
		%>
        $.gritter.add({
            title: '<i class="fa fa-thumbs-down"></i> ERRO:',
            text: '<%=erro%>',
            class_name: 'gritter-error gritter-light'
        });
		<%
	else
		db_execute("insert into tisslotes (Lote, ConvenioID, Mes, Ano, Ordem, Tipo, sysUser,Observacoes,DataPrevisao) values ("&ref("Lote")&", "&req("ConvenioID")&", "&ref("Mes")&", "&ref("Ano")&", '"&ref("Ordem")&"', '"&Tipo&"', "&session("User")&", '"&ref("Obs")&"',"&mydatenull(ref("PrevisaoRecebimento"))&")")
		set pult = db.execute("select id from tisslotes where sysUser="&session("User")&" order by id desc limit 1")
		spl = split(ref("guia"), ", ")
		if Tipo="GuiaConsulta" then
			tabela = "tissguiaconsulta"
		elseif Tipo="GuiaSADT" then
			tabela = "tissguiasadt"
		elseif Tipo="GuiaHonorarios" then
			tabela = "tissguiahonorarios"
		end if
		for i=0 to ubound(spl)
		    loteSql = "update "&tabela&" set LoteID="&pult("id")&" where id="&spl(i)
			db_execute(loteSql)
		next
		%>

		
		gtag('event', 'fechamento_de_lote', {
			'event_category': 'lote',
			'event_label': "Tiss > Fechar lote > Salvar",
		});
		
        alert('O lote foi salvo com sucesso. Para gerar o arquivo XML, acesse o menu TISS -> Administrar Lotes.');
        location.href='./?P=tissfechalote&Pers=1';
		<%
	end if
elseif Acao="Update" then
    LoteID = ref("LoteID")
    Enviado = ref("Enviado")
    Protocolo = ref("Protocolo")
    NumeroNFSe = ref("NumeroNFSe")
    DataEnvio = mydatenull(ref("DataEnvio"))
    DataPrevisao = mydatenull(ref("DataPrevisao"))
    DataPrevisaoOriginal = mydatenull(ref("DataPrevisaoOriginal"))
    db_execute("update tisslotes set Protocolo='"&Protocolo&"', NumeroNFSe='"&NumeroNFSe&"', Enviado="&Enviado&" , DataEnvio="&DataEnvio&", DataPrevisao="&DataPrevisao&", DataPrevisaoOriginal="&DataPrevisaoOriginal&" where id="&LoteID)
    %>
           $.gritter.add({
            title: '<i class="fa fa-save"></i> Informações salvas com sucesso!',
            text: '',
            class_name: 'gritter-success gritter-light'
        });

    <%
end if
%>