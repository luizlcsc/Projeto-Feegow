<!--#include file="connect.asp"-->
<!--#include file="ProntCompartilhamento.asp"-->
<%
' getConfig("NovaGaleria") = "1"

IF True THEN
            %>
      <div class="galery-ajax"></div>
      <script>
              fetch("ImagensNew.asp?ArquivoImagem=Arquivos&PacienteID=<%=req("PacienteID")%>&MovementID=<%=req("MovementID")%>&OrdemDeCompraID=<%=req("OrdemDeCompraID")%>")
              .then(data => data.text())
              .then(data => {
                 $(".galery-ajax").html(data);
                 $("[value='I']").parent().remove();
              });
             </script>
    <%
    response.end
END IF
%>


<div id="arquivos-content">
<div class="panel">
    <div class="panel-body">
        <table class="table table-striped table-bordered" width="100%">
        <thead>
	        <tr class="success">
    	        <th width="1%"></th>
                <th width="1%">Arquivo</th>
                <th>Descrição</th>
                <th>Tipo</th>
                <th width="5%" nowrap>Data de Envio</th>
                <th width="5%" nowrap>Validade</th>
                <th width="90px"></th>
            </tr>
        </thead>
        <tbody>
	        <%
	        if isnumeric(req("X")) and req("X")<>"" and req("X")<>"0" then
		        db_execute("delete from arquivos where id="&req("X"))
	        end if
	        if req("MovementID")<>"" then
	            sqlMov = " AND MovementID="&req("MovementID")
            else
                sqlMov = " AND MovementID is null"
	        end if
	        if req("tipoGuia")<>"" and req("guiaID")<>"" then
                sqlGuia = " AND TipoGuia='"&req("tipoGuia")&"' AND GuiaID="&req("guiaID")
	        end if
	        if req("ExameID")<>"" then
                sqlExame = " AND ExameID="&req("ExameID")
	        end if
            if req("OrdemDeCompraID")<>"" then
                sqlOrdemDeCompra = " AND OrdemDeCompraID="&req("OrdemDeCompraID")
	        end if
	        ' (provider <> 'S3' or provider is null) and
	        set arquivos = db.execute("select * from arquivos where Tipo='A' and PacienteID="&req("PacienteID")& sqlMov & sqlGuia & sqlExame & sqlOrdemDeCompra )
	        c=0
	        Caminho = "https://clinic7.feegow.com.br/uploads/"& replace(session("Banco"), "clinic", "") &"/Arquivos/"
	        while not arquivos.EOF
		        c=c+1
		        extensao = ""
		        if instr(arquivos("NomeArquivo"), ".")>0 then
			        spl = split(arquivos("NomeArquivo"), ".")
			        extensao = lcase(spl(1))
		        end if

                setOnclick= False
		        if isnull(arquivos("Provider")) then

                    fullFile = Caminho&arquivos("NomeArquivo")
                    fullFile = arqEx(arquivos("NomeArquivo"), "Arquivos")
                else
                    fullFile = "#"
                    setOnclick= True
                end if

                if extensao="jpg" or extensao="jpeg" or extensao="bmp" or extensao="gif" or extensao="png" or extensao="tiff" or extensao="tif" then
                    icone = fullFile
                else
                    if extensao="/" then
                        extensao="pdf"
                    end if
                    icone = "assets/img/"&extensao&".png"
                end if

                'verifica permissao de compartilhamento do arquivo
                'default pode ver, porém se não pertence ao CareTeam irá verificar a permissão do arquivo
                podever = true
                tipoCompartilhamento = 1
                if not autCareTeam(arquivos("sysUser"), req("PacienteID")) then
                    permissao = VerificaProntuarioCompartilhamento(arquivos("sysUser"),"Arquivos", arquivos("id"), lcase(session("table")))

                    if permissao <> "" then
                        permissaoSplit = split(permissao,"|")
                        podever = permissaoSplit(0)
                        tipoCompartilhamento = permissaoSplit(1)
                    end if
                end if

				if podever or ( cstr(session("User"))=arquivos("sysUser")&"") then
		        %>
                <tr>
        	        <td><img height="32" width="32" src="<%=icone%>" /></td>
                    <td><a target="_blank" <% if setOnclick then %>onclick="getFile('<%=arquivos("NomePasta")%>', '<%=arquivos("NomeArquivo")%>')" <% end if %> href="<%= fullFile %>" class="btn btn-info"><i class="far fa-download"></i></a></td>
                    <td><%=quickfield("text", "Desc"&arquivos("id"), "", 11, arquivos("Descricao"), " imgpac", "", " data-img-id='"&arquivos("id")&"'") %></td>
                    <td><%=quickfield("simpleSelect", "TipoArquivoID_"&arquivos("id"), "", 11, arquivos("TipoArquivoID"), " select * from tipoarquivo where sysActive=1 order by NomeArquivo", "NomeArquivo", " data-img-id='"&arquivos("id")&"'") %></td>
                    <td width="5%" nowrap><%=arquivos("DataHora")%></td>
                    <td width="5%" nowrap><%=quickField("datepicker", "Validade_"&arquivos("id"), "", 2, arquivos("Validade"), "", "", "") %></td>
                    <td>
					<div>
					<% if cstr(session("User"))=arquivos("sysUser")&"" then %>

					<div class="btn-group dropleft" >
						<a data-toggle="dropdown" class="btn btn-sm btn-warning dropdown-toggle" aria-haspopup="true" aria-expanded="false">
										<i class="far fa-share-alt"></i>
						</a>
						<ul class="dropdown-menu pull-right" role="menu" >
							<li  class="dropdown-item">
								<a <% if tipoCompartilhamento = 1  then %> class="compartilhamentoSelect" <% end if %> href="javascript:saveCompartilhamento(1,'Arquivos',<%=arquivos("id") %>,<%=session("idInTable") %>)" > <i class="far fa-users"></i> Publico </a>
							</li>
							<li class="dropdown-item">
								<a <% if tipoCompartilhamento = 2  then %> class="compartilhamentoSelect" <% end if %> href="javascript:saveCompartilhamento(2,'Arquivos',<%=arquivos("id") %>,<%=session("idInTable") %>)" ><i class="far fa-lock"></i> Privado</a>
							</li>
							<li class="dropdown-item">
								<a <% if tipoCompartilhamento = 3  then %> class="compartilhamentoSelect" <% end if %> href="javascript:compartilhamentoRestrito('Arquivos',<%=arquivos("id") %>,<%=session("idInTable") %>)" ><i class="far fa-eye-slash"></i> Restrito</a>
							</li>
								<li class="divider"></li>
							<li class="dropdown-item">
								<a href="javascript:saveCompartilhamento(0,'Arquivos',<%=arquivos("id") %>,<%=session("idInTable") %>)" > <i class="far fa-asterisk"></i> Padrão </a>
							</li>
						</ul>
					</div>
					<%end if%>


                    <%if aut("arquivosX") then%>
                        <button type="button" class="btn btn-sm btn-danger pull-right" title="Excluir Arquivo" onclick="if(confirm('Tem certeza de que deseja excluir este arquivo?'))atualizaArquivos(<%=arquivos("id")%>);">
                            <i class="far fa-trash icon-trash"></i>
                        </button>
                    <%end if%>
					</div>
                    </td>
                </tr>
		        <%
				end if
	        arquivos.movenext
	        wend
	        arquivos.close
	        set arquivos = nothing
	        %>
        </tbody>
        </table>

    </div>
</div>

<script type="text/javascript">
    $(".imgpac").change(function () {
        $.post("saveImgPac.asp?IMG=" + $(this).attr("data-img-id"), { Descricao: $(this).val() }, function (data) { eval(data) });
    })
    function openInNewTab(href) {
      Object.assign(document.createElement('a'), {
        target: '_blank',
        href,
      }).click();
    }

    function getFile(pasta, arquivo) {
        openInNewTab("https://app.feegow.com.br/file/downloadFile?folderName="+pasta+"&fileName="+arquivo+"&redir=true&tk="+localStorage.getItem("tk"))
    }

    function atualizaAlbum() {
        // $.get("Arquivos.asp?")
    }
</script>
</div>