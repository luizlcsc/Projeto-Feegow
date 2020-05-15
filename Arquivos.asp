﻿<!--#include file="connect.asp"-->
<!--#include file="ProntCompartilhamento.asp"-->
<%

IF getConfig("NovaGaleria") = "1" THEN
            %>
      <div class="galery-ajax"></div>
      <script>
              fetch("ImagensNew.asp?PacienteID=<%=req("PacienteID")%>&MovementID=<%=req("MovementID")%>")
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
                <th width="5%" nowrap>Data de Envio</th>
                <th width="90px"></th>
            </tr>
        </thead>
        <tbody>
	        <%
	        if isnumeric(request.QueryString("X")) and request.QueryString("X")<>"" and request.QueryString("X")<>"0" then
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
	        ' (provider <> 'S3' or provider is null) and
	        set arquivos = db.execute("select * from arquivos where Tipo='A' and PacienteID="&req("PacienteID")& sqlMov & sqlGuia & sqlExame )
	        c=0
	        Caminho = "https://clinic7.feegow.com.br/uploads/"& replace(session("Banco"), "clinic", "") &"/Arquivos/"
	        while not arquivos.EOF
		        c=c+1
		        extensao = ""
		        if instr(arquivos("NomeArquivo"), ".")>0 then
			        spl = split(arquivos("NomeArquivo"), ".")
			        extensao = lcase(spl(1))
		        end if
                fullFile = Caminho&arquivos("NomeArquivo")
                fullFile = arqEx(arquivos("NomeArquivo"), "Arquivos")

		        if extensao="jpg" or extensao="jpeg" or extensao="bmp" or extensao="gif" or extensao="png" then
			        icone = fullFile
		        else
		            if extensao="/" then
		                extensao="pdf"
		            end if
			        icone = "assets/img/"&extensao&".png"
		        end if

				'02/09/2019 Sanderson
				'verifica permissao de compartilhamento do arquivo
				permissao = VerificaProntuarioCompartilhamento(arquivos("sysUser"),"Arquivos", arquivos("id"))
				podever = true
				tipoCompartilhamento =1

				if permissao <> "" then
					permissaoSplit = split(permissao,"|")
					podever = permissaoSplit(0)
					tipoCompartilhamento = permissaoSplit(1)
				end if

				if podever or ( cstr(session("User"))=arquivos("sysUser")&"") then
		        %>
                <tr>
        	        <td><img height="32" width="32" src="<%=icone%>" /></td>
                    <td><a target="_blank" href="<%= fullFile %>" class="btn btn-info"><i class="fa fa-download"></i></a></td>
                    <td><%=quickfield("text", "Desc"&arquivos("id"), "", 11, arquivos("Descricao"), " imgpac", "", " data-img-id='"&arquivos("id")&"'") %></td>
                    <td width="5%" nowrap><%=arquivos("DataHora")%></td>
                    <td>
					<div>
					<% if cstr(session("User"))=arquivos("sysUser")&"" then %>

					<div class="btn-group dropleft" >
						<a data-toggle="dropdown" class="btn btn-sm btn-warning dropdown-toggle" aria-haspopup="true" aria-expanded="false">
										<i class="fa fa-share-alt"></i>
						</a>
						<ul class="dropdown-menu pull-right" role="menu" >
							<li  class="dropdown-item">
								<a <% if tipoCompartilhamento = 1  then %> class="compartilhamentoSelect" <% end if %> href="javascript:saveCompartilhamento(1,'Arquivos',<%=arquivos("id") %>,<%=session("idInTable") %>)" > <i class="fa fa-users"></i> Publico </a>
							</li>
							<li class="dropdown-item">
								<a <% if tipoCompartilhamento = 2  then %> class="compartilhamentoSelect" <% end if %> href="javascript:saveCompartilhamento(2,'Arquivos',<%=arquivos("id") %>,<%=session("idInTable") %>)" ><i class="fa fa-lock"></i> Privado</a>
							</li>
							<li class="dropdown-item">
								<a <% if tipoCompartilhamento = 3  then %> class="compartilhamentoSelect" <% end if %> href="javascript:compartilhamentoRestrito('Arquivos',<%=arquivos("id") %>,<%=session("idInTable") %>)" ><i class="fa fa-eye-slash"></i> Restrito</a>
							</li>
								<li class="divider"></li>
							<li class="dropdown-item">
								<a href="javascript:saveCompartilhamento(0,'Arquivos',<%=arquivos("id") %>,<%=session("idInTable") %>)" > <i class="fa fa-asterisk"></i> Padrão </a>
							</li>
						</ul>
					</div>
					<%end if%>


                    <%if aut("arquivosX") then%>
                        <button type="button" class="btn btn-sm btn-danger pull-right" title="Excluir Arquivo" onclick="if(confirm('Tem certeza de que deseja excluir este arquivo?'))atualizaArquivos(<%=arquivos("id")%>);">
                            <i class="fa fa-trash icon-trash"></i>
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

    function atualizaAlbum() {
        // $.get("Arquivos.asp?")
    }
</script>
</div>