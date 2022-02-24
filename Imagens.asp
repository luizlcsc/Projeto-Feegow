<!--#include file="connect.asp"-->
<!--#include file="ProntCompartilhamento.asp"-->
<!--#include file="Classes/Arquivo.asp"-->
<%
	if isnumeric(req("X")) and req("X")<>"" and req("X")<>"0" then
		db_execute("update arquivos set sysActive=-1 where id="&req("X"))
	end if
	'getConfig("NovaGaleria")
	IF true THEN
        %>
          <script>
          function getImagensPaciente(onlyRefresh = false, fileType = "I"){
              const uploaderSetado = $(".galery-ajax").length > 0;

            if(uploaderSetado && onlyRefresh === false){
                return;
            }

            if(fileType=="A"){
                fileType="Arquivos"
            }else{
                fileType="Imagens"
            }
            
            if(!uploaderSetado){
                $("#ImagensPaciente").prepend("<div class='galery-ajax'></div>");
            }

            fetch(`ImagensNew.asp?ArquivoImagem=${fileType}&PacienteID=<%=req("PacienteID")%>`)
              .then(data => data.text())
              .then(data => {
                 $(".galery-ajax").html(data);
              });

          }

            function callUpload(response, tipo){
                if(!tipo){
                    tipo = getSelected()[0];
                }

               getImagensPaciente(true, tipo);
            }

            getImagensPaciente(false);
        </script>
        <%
    END IF
%>


<% IF false THEN %>
<div class="row">
	<div class="col-md-4 pull-right">
    	<button type="button" id="btnComparar" class="btn btn-sm btn-info">Comparar imagens</button>
    </div>
</div>
<div class="row-fluid">
<br>
    <ul class="ace-thumbnails pn mn" id="mix-container">
	<%
	set imagens = db.execute("select * from arquivos where Tipo='I' and PacienteID="&req("PacienteID")&" ORDER BY DataHora DESC")
	c=0

	while not imagens.EOF
		c=c+1

        Caminho = "/uploads/"& replace(session("Banco"), "clinic", "") &"/Imagens/"

        if session("Banco")="clinic5568" and cdate(imagens("DataHora"))<cdate("01/08/2018") then
            Caminho = "http://clinic5.feegow.com.br/san-lazaro/"
			fullFile = Caminho&imagens("NomeArquivo")
        elseif session("Banco")="clinic5272" and cdate(imagens("DataHora"))<cdate("25/11/2018") then
            Caminho = "https://clinic.feegow.com.br/sani/"
			'fullFile = Caminho&imagens("NomeArquivo")
			set fs=Server.CreateObject("Scripting.FileSystemObject")
            if fs.FileExists("E:\uploads\"& replace(session("Banco"), "clinic", "") &"\Imagens\"& imagens("NomeArquivo")) then
                fullFile = "https://clinic7.feegow.com.br/uploads/"& replace(session("Banco"), "clinic", "") &"/Imagens/"& imagens("NomeArquivo")
            else
                fullFile = Caminho&imagens("NomeArquivo")
            end if
            set fs=nothing

		else
		   ' Caminho = arqEx(imagens("NomeArquivo"), "Imagens")
		   ' CaminhoInicial = "https://clinic7.feegow.com.br"
		   ' IF InStr(Caminho, ".com.br")=0 THEN
		   '     Caminho = CaminhoInicial&Caminho
		   ' END IF
			fullFile = getFileUrl(imagens("NomeArquivo"), "Imagens")
        end if


        'verifica permissao de compartilhamento do arquivo
        'default pode ver, porém se não pertence ao CareTeam irá verificar a permissão do arquivo
        podever = true
        tipoCompartilhamento = 1
        if not autCareTeam(imagens("sysUser"), req("PacienteID")) then
            permissao = VerificaProntuarioCompartilhamento(imagens("sysUser"),"Imagens", imagens("id"))
            if permissao <> "" then
                permissaoSplit = split(permissao,"|")
                podever = permissaoSplit(0)
                tipoCompartilhamento = permissaoSplit(1)
            end if
        end if

        if podever or (cstr(session("User"))=imagens("sysUser")&"") then

        if 1=2 then
		%>...
        <li>
            <a href="<%= fullFile %>" title="<%=imagens("Descricao") %>" data-rel="colorbox">
                <img alt="150x150" height="150" src="<%= fullFile %>" id="image<%=c%>" />
                <div class="tags">
                    <span class="label-holder">
                        <span class="label label-info arrowed-in"> <%= imagens("DataHora") %> <i class="far fa-time icon-time"></i></span>
                    </span>
                </div>
            </a>
                    <div class="col-md-2">
                        <label><input class="ace" name="comparar" value="<%="|"&fullFile&"|"%>" type="checkbox" /><span class="lbl"></span></label>

                    </div>


            <div class="tools tools-top">

                <a href="#" title="Editar Imagem" onclick="return launchEditor('image<%=c%>', '<%= fullFile %>');">
                    <i class="far fa-pencil icon-pencil"></i>
                </a>

                <a href="<%= fullFile %>" target="_blank" title="Abrir Imagem Separadamente">
                    <i class="far fa-external-link icon-external-link"></i>
                </a>

                <a href="#" class="hide" title="Duplicar Imagem" onclick="duplicate('<%=imagens("NomeArquivo")%>');">
                   <i class="far fa-paste icon-paste"></i>
                </a>

                <a href="javascript:if(confirm('Tem certeza de que deseja excluir esta imagem?'))atualizaAlbum(<%=imagens("id")%>);" id="excluir" title="Excluir Imagem">
                    <i class="far fa-trash icon-trash"></i>
                </a>
            </div>

        </li>

		<%
        end if
        %>
        <li class="mix col-xs-12 col-md-4">
                <div class="panel pn pbn mb5">
            <div class="tools">
                

                <%if instr(imagens("NomeArquivo"), ".pdf")=0 then%>
                <a class="btn btn-xs btn-alert" href="#" title="Editar Imagem" onclick="return launchEditor('image<%=c%>', '<%=fullFile%>');">
                    <i class="far fa-pencil icon-pencil"></i>
                </a>

                <a class="btn btn-xs btn-alert" href="<%= fullFile %>" target="_blank" title="Abrir Imagem Separadamente">
                    <i class="far fa-external-link icon-external-link"></i>
                </a>

                <a class="btn btn-xs btn-alert"  href="javascript:r90('<%= imagens("NomeArquivo") %>', '<%= imagens("id") %>')" title="Girar 90&deg;">
                    <i class="far fa-rotate-right"></i>
                </a>
                <a class="btn btn-xs btn-alert" href="javascript:MaisInfo('<%= imagens("NomeArquivo") %>')" title="Mais informações">
                    <i class="far fa-info-circle"></i>
                </a>
                <%end if%>
                <a class="btn btn-xs btn-danger pull-right" href="javascript:if(confirm('Tem certeza de que deseja excluir esta imagem?'))atualizaAlbum(<%=imagens("id")%>);" id="excluir" title="Excluir Imagem">
                    <i class="far fa-trash icon-trash"></i>
                </a>
                
                <% if cstr(session("User"))=imagens("sysUser")&"" then %>
                <div class="btn-group dropup" >
                    <a data-toggle="dropdown" title="Compartilhamento de arquivos" class="btn btn-xs btn-alert dropdown-toggle" aria-haspopup="true" aria-expanded="false">
                                    <i class="far fa-share-alt"></i>
                    </a>
                    <ul class="dropdown-menu pull-left" role="menu"  >
                        <li  class="dropdown-item">
                            <a <% if tipoCompartilhamento = 1  then %> class="compartilhamentoSelect" <% end if %> href="javascript:saveCompartilhamento(1,'Imagens',<%=imagens("id") %>,<%=session("idInTable") %>)" > <i class="far fa-users"></i> Publico </a>
                        </li>
                        <li class="dropdown-item">
                            <a <% if tipoCompartilhamento = 2  then %> class="compartilhamentoSelect" <% end if %> href="javascript:saveCompartilhamento(2,'Imagens',<%=imagens("id") %>,<%=session("idInTable") %>)" ><i class="far fa-lock"></i> Privado</a>
                        </li>
                        <li class="dropdown-item">
                            <a <% if tipoCompartilhamento = 3  then %> class="compartilhamentoSelect" <% end if %> href="javascript:compartilhamentoRestrito('Imagens',<%=imagens("id") %>,<%=session("idInTable") %>)" ><i class="far fa-eye-slash"></i> Restrito</a>
                        </li>
                            <li class="divider"></li>
                        <li class="dropdown-item">
                            <a href="javascript:saveCompartilhamento(0,'Imagens',<%=imagens("id") %>,<%=session("idInTable") %>)" > <i class="far fa-asterisk"></i> Padrão </a>
                        </li>
                    </ul>
                </div>
                <%end if%>

            </div>
            <%
            if instr(imagens("NomeArquivo"), ".pdf")>0 then%>
                <a target="_blank" href="<%= fullFile %>" style="min-height: 190px; padding-top: 70px" class="btn btn-info btn-block"><i class="far fa-file"></i> PDF</a>
            <%else%>
                <a href="<%= fullFile %>" title="<%=imagens("Descricao") %>" data-rel="colorbox">
                        <img data-id="<%= imagens("id") %>" alt="150x150" height="190" width="100%" style="object-fit:cover!important; height:190px!important" class="img-responsible img-thumbnail" src="<%= fullFile %>?time=<%=time()%>" data-src="<%= fullFile %>" id="image<%=c%>" />
                </a>
            <%end if%>
            <div class="tools tools-b">
                <div class="input-group">
                <%if instr(imagens("NomeArquivo"), ".pdf")=0 then%>
                    <span class="input-group-addon pn" style="vertical-align:top">
                        <div class="checkbox-custom checkbox-primary mn pn">
                            <input type="checkbox" name="comparar" value="<%="|"&fullFile&"|"%>" id="chk<%=imagens("id") %>" /><label for="chk<%=imagens("id") %>"></label>
                        </div>
                    </span>
                <%end if%>
                    <input type="text" name="<%="Desc"&imagens("id")%>" id="<%="Desc"&imagens("id")%>" value="<%=imagens("Descricao")%>" class="form-control input-sm mn imgpac" data-img-id="<%=imagens("id")%>">
                </div>
            </div>
                    </div>
                    <div class="text-center" style="position: inherit;"><div class="label label-primary">Em <%=imagens("DataHora")%></div></div>
        </li>
        <%
        end if

	imagens.movenext
	wend
	imagens.close
	set imagens = nothing
	%>

</ul><!-- PAGE CONTENT ENDS -->
</div>
<% END IF %>
<script type="text/javascript">

function MaisInfo(img) {
  $.get("https://clinic.feegow.com.br/feegow_components/api/ImagemMetadados/get",{url:img},function(data) {
        if(data){
            alert("Resolução: "+data["0"]+"x"+data["1"]+"\nNúmero de bits: "+data["bits"]);
        }else{
            alert("Informações indisponíveis.");
        }
  })
}

	jQuery(function($) {
var colorbox_params = {
reposition:true,
scalePhotos:true,
scrolling:false,
previous:'<i class="far fa-arrow-left icon-arrow-left"></i>',
next:'<i class="far fa-arrow-right icon-arrow-right"></i>',
close:'&times;',
current:'{current} of {total}',
maxWidth:'100%',
maxHeight:'100%',
onOpen:function(){
	document.body.style.overflow = 'hidden';
},
onClosed:function(){
	document.body.style.overflow = 'auto';
},
onComplete:function(){
	$.colorbox.resize();
}
};

$('.ace-thumbnails [data-rel="colorbox"]').colorbox(colorbox_params);
$("#cboxLoadingGraphic").append("<i class='icon-spinner orange'></i>");//let's add a custom loading icon

/**$(window).on('resize.colorbox', function() {
try {
	//this function has been changed in recent versions of colorbox, so it won't work
	$.fn.colorbox.load();//to redraw the current frame
} catch(e){}
});*/
})

$("#btnComparar").click(function(){
	$.ajax({
		type:"POST",
		url:"comparar.asp",
		data:$("#frmComparar").serialize(),
		success:function(data){
			$("#comparar").html(data);
			$("#modal-comparar").modal("show");
		}
	});
});

$(".imgpac").change(function(){
    $.post("saveImgPac.asp?IMG="+$(this).attr("data-img-id"), {Descricao:$(this).val()}, function(data){eval(data)});
})
</script>