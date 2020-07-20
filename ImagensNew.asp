<!--#include file="connect.asp"-->
<!--#include file="ProntCompartilhamento.asp"-->
<!--#include file="Classes/Arquivo.asp"-->
<%
    IF ref("valor") <> "" THEN
        db.execute("UPDATE arquivos SET Descricao = '"&ref("valor")&"' WHERE id = '"&ref("id")&"' ")

        %>
        new PNotify({
            title: '<i class="fa fa-save"></i>',
            text: 'Descrição alterada com sucesso.',
            type: 'success'
        });
        <%
        response.end
    END IF

ArquivoImagem = req("ArquivoImagem")
ImageRenderType = "download"

if req("PacienteID")<>"" and req("PacienteID")<>"0" then
    ImageRenderType = "redirect"
end if
%>
<style>
    :root {
      --width-main: 200px;
      --height-main: 200px;
    }

    .galery{
        display: flex;
        flex-wrap: wrap;
        padding-top: 25px;
        justify-content: center;
    }
    .galery-item,.galery-item-max{
        overflow: hidden;
        text-align: center;
        margin: 5px;
        background: #ffffff;
        border-radius: 5px;
        max-width: var(--width-main);
        min-width: var(--width-main);
        box-shadow: 1px 1px 5px #888888;
    }
    .galery-item-max{
        max-width: 100%;
        min-width: 100%;
    }

    .galery-item-max .galery-img {
            max-width: 100%;
            min-width: 100%;
            height:auto;
    }

    .galery-item .galery-img{
        height: var(--height-main);
        text-align: center;
        padding-bottom: 5px;
        display: flex;
        align-items: center;
    }
    .galery-item .galery-img img,.galery-item .galery-img span,.galery-item .galery-img a{
        margin: 0 auto;
        display: inline-block;
        max-height: var(--height-main);
    }
    .doc,.rtf{
        width: 120px;
    }

    .text-info{

        border: 1px solid #c7c7e5;
        padding: 2px 10px;
        color: #efe3ea !important;
        /*background: #f8f8f8;*/
        background: rgba(55,55,55,0.5);
    }

    .galery-item:hover .config{
            margin-top: -45px;
    }

    .galery-item:hover textarea{
        max-height: 45px;
        min-height: 45px
    }

    .config{
        z-index: 999;
        position: absolute;
        display: flex;
        width: var(--width-main);
        margin-top: -25px;
    }
    .config textarea{
        border:none;
        width: 100%;
        overflow: auto;
        max-height: 25px;
        min-height: 25px
    }

    [contenteditable]:focus {
        outline: 0px solid transparent;
    }

    .data-envio{
        background: rgba(13,13,13,0.5);
        display: block;
        width: 100%;
        padding: 5px;
    }
    .checkbox-custom input[type=checkbox]:checked + label:after, .checkbox-custom input[type=radio]:checked + label:after{
        color: #1c2730 !important;
    }
    .galery-data-envio{
        z-index: 999;
        position: absolute;
        text-align: right;
        color: #f4f4f4;
        width: var(--width-main);
    }

    .galery-item-max .galery-data-envio{
        position: static;
        text-align: left;
        width: 100%;
        height: auto;
    }

    .galery-item-max .data-envio{
        padding: 10px;
    }



    .galery-item .config-buttons {
           background: rgba(13,13,13,0.5);
           opacity: 0;
           transition: 0.9s;
           margin-top: 8px;
           padding: 5px;
    }

    .galery-item:hover .config-buttons {
        display: block;
        opacity: 1;
    }

    .multiselect.btn-default {
        background-color: #f0f0f0;
    }
</style>
<%

if ArquivoImagem="" then
    ArquivoImagem="Imagem"
end if

if ArquivoImagem="Imagem" then
%>
<div class="btn-group ib m20 pull-left ">
  <button type="button" class="btn btn-default hidden-xs" onclick="comparar()">
    <span class="fa fa-columns	"></span>
  </button>
  <div class="btn-group">
    <fieldset>
       <div class="btn-group">
      <button type="button" class="btn btn-default" data-toggle="dropdown" title="All Labels" onclick="comparar()" aria-expanded="false"><span>Comparar</span> </button></div>
    </fieldset>
  </div>
</div>
<%
end if
%>
<div class="btn-group ib m20 pull-left ">
  <button type="button" class="btn btn-default hidden-xs">
    <span class="fa fa-tag"></span>
  </button>
  <div class="btn-group">
    <fieldset>
       <div class="btn-group">
      <button type="button" class="multiselect dropdown-toggle btn btn-default" data-toggle="dropdown" title="All Labels" aria-expanded="false"><span class="filter-img">Imagens, Arquivos</span><b class="caret"></b></button>
        <ul class="multiselect-container dropdown-menu">
            <li>
                <a href="javascript:void(0)">
                    <label class="checkbox"><input type="checkbox" value="I" name="a" onchange="loadItens()" v-v="Imagens">Imagens</label>
                </a>
            <li>
            <li>
                <a href="javascript:void(0)">
                    <label class="checkbox"><input type="checkbox" value="A" name="a" onchange="loadItens()" v-v="Arquivos">Arquivos</label>
                </a>
            <li>
        </ul>
      </div>
    </fieldset>
  </div>
</div>

<div class="clearfix"></div>
<div class='max-width' style="display: flex"></div>
<div class="galery" id="galery">
    <div class="fa-2x" style="text-align: center">
        <i class="fa fa-circle-o-notch fa-spin"></i>
    </div>
</div>

<script>

    var itens = [];

    function getSelected() {

          let tags = $("[name='a']:checked");
          if($("[name='a']:checked").length < 1){
              tags = $("[name='a']");
          }


          let descricoes = [];
          let result = tags.map(function() {
                descricoes.push($(this).attr("v-v"));
                return this.value;
          }).get();

            $(".filter-img").html(descricoes.join(", "));

          return result;
    }

    function processaItem(item){
            item.NovaDescricao = item.Descricao?item.Descricao:item.NomeArquivo;

            let extension = item.NomeArquivo.substr(item.NomeArquivo.lastIndexOf('.') + 1).toLowerCase();
            let link = '';
            let formato = 'a';
            if(['png','gif','jpeg','jpg'].includes(extension)){
                formato = 'span';
                link = item.thumbnailLink?item.thumbnailLink:item.ArquivoLink;
            }

            let baseLink = "https://cdn.feegow.com/icons/";

            if(['docx','doc','rtf'].includes(extension)){
                link = 'doc.png';
            }

            if(['pdf'].includes(extension)){
                link = 'pdf.png';
            }
            if(['mp4'].includes(extension)){
                link = 'pdf.png';
            }
            if(['xml'].includes(extension)){
                // link = 'xml.png';
            }

            if(['txt'].includes(extension)){
                link = 'txt.png';
            }

            if(['pptx'].includes(extension)){
                link = 'ppt.png';
            }

            if(['csv'].includes(extension)){
                link = 'csv.png';
            }

            if(['xlsx','xls'].includes(extension)){
                link = 'xls.png';
            }

            if(['jpg','jpeg'].includes(extension)){
                link = 'jpg.png';
            }

            if(['mp3'].includes(extension)){
                link = 'mp3.png';
            }
            if(['mp4'].includes(extension)){
                link = 'mp4.png';
            }
            if(['txt'].includes(extension)){
                link = 'txt.png';
            }

            item.link = baseLink + link;
            item.extension = extension;
            item.formato = formato;
    }

    function loadItens(){
        let b = itens.filter(item => {
            return getSelected().includes(item.Tipo);
        }).map((item) => {
                processaItem(item);
                return `<div class="galery-item">

                             <div class="galery-data-envio">
                                <small class="pull-right data-envio">Em ${moment(item.DataHora).format('DD/MM/YYYY H:mm:ss')}</small><br/>
                                <div class="config-buttons">
                                    <small class="pull-left"><div class="bs-component">
                                                                                         <div class="checkbox-custom mb5">
                                                                                           <input type="checkbox" class="comparar" name="comparar[${item.id}]" value="${item.id}" id="comparar${item.id}">
                                                                                           <label for="comparar${item.id}">&nbsp</label>
                                                                                         </div>
                                                                                       </div></small>

                                    <a class="btn btn-xs btn-alert" href="javascript:expandItem(${item.id})" title="Abrir Imagem Separadamente">
                                                              <i class="fa fa-expand icon-external-link"></i>
                                    </a>
                                    <a class="btn btn-xs btn-alert" href="${item.ArquivoLink.replace('redirect', '<%=ImageRenderType%>')}" target="_blank" title="Abrir Imagem Separadamente">
                                                              <i class="fa fa-external-link icon-external-link"></i>
                                    </a>
                                    <a class="btn btn-xs btn-alert" href="javascript:r90_1('${item.NomeArquivo}', '${item.id}')" title="Girar 90°">
                                            <i class="fa fa-rotate-right"></i>
                                    </a>
                                    <a class="btn btn-xs btn-alert" href="javascript:MaisInfo('${item.NomeArquivo}')" title="Mais informações">
                                                        <i class="fa fa-info-circle"></i>
                                    </a>
                                    <a class="btn btn-xs btn-alert" href="#" title="Editar Imagem" onclick="return launchEditor('image1', '${item.ArquivoLink}');">
                                                        <i class="fa fa-pencil icon-pencil"></i>
                                    </a>
                                    <a class="btn btn-xs btn-danger" href="javascript:if(confirm('Tem certeza de que deseja excluir esta imagem?'))atualizaAlbum(${item.id});" id="excluir" title="Excluir Imagem">
                                        <i class="fa fa-trash icon-trash"></i>
                                    </a>
                                </div>

                             </div>
                             <div class="galery-img"><${item.formato} href="${item.ArquivoLink}" target="_blank"><img src="${item.link}" data-id="${item.id}" class="${item.extension} img-responsive" title="${item.Descricao}"></a></div>
                             <div class="config">
                                <textarea class="galery-description text-info border-edit imgpac" name="Desc${item.id}" onchange="changeDescription(${item.id},this)" data-img-id="${item.id}">${item.NovaDescricao}</textarea>
                             </div>
                       </div>`;
             });

             document.getElementById("galery").innerHTML =b.join("");
    }

    function expandItem(id){
         let item = itens.find(item => item.id == id);
         let html = `
         <div class="galery-item-max">
            <div class="galery-data-envio">
             <div class="data-envio">
            <div class="pull-right">
                <a class="btn btn-xs btn-danger" onclick="$('.galery-item-max').remove()" id="excluir" title="Excluir Imagem">
                    <i class="fa fa-times icon-trash"></i>
                </a>
            </div>
Em ${moment(item.DataHora).format('DD/MM/YYYY H:mm:ss')}<br/> ${item.NovaDescricao}
</div>
          </div>
          <div class="galery-img"><img src="${item.ArquivoLink}" width="100%" height="100%" data-id="${item.id}" class="${item.extension} img-responsive" title="lost_typewritter.jpg"></div>
    </div>`;


        $(".max-width").html(html);
        $(window).scrollTop($('.max-width').offset().top - 120)
    }

    let ConfigPacienteID = '<%=request.QueryString("PacienteID")%>';
    let ConfigMovementID = '<%=request.QueryString("MovementID")%>';
    let ConfigLaudoID    = '<%=request.QueryString("LaudoID")%>';

    let valorConsulta = null;
    let typeDoc = "all";
    let typeSearch = null;

    if(ConfigPacienteID > 0){
        valorConsulta = ConfigPacienteID;
        typeSearch = 'PacienteID'
    }

    if(ConfigLaudoID > 0){
        valorConsulta = ConfigLaudoID;
        typeSearch = 'LaudoID'
    }

    if(ConfigMovementID > 0){
        valorConsulta = ConfigMovementID;
        typeSearch = 'MovementID'
    }

    if(!typeSearch){
        typeDoc="license_upload";
    }

    fetch(domain+'file/arquivos/'+typeSearch+'/'+valorConsulta+'/'+typeDoc+'/list?tk='+localStorage.getItem("tk"))
    .then((a) => a.json())
    .then( a =>{
            itens = a;
            reloadItens();
            loadItens();
    });

    function reloadItens(){
        $("[id-img-arquivos]").map((a,b) => {
            let _item = itens.find(item => item.id == $(b).attr("id-img-arquivos"));
                processaItem(_item);
               $(b).attr("src",_item.link);
               $(b).parent().attr("href",_item.ArquivoLink);
        })
    }

    function comparar(){
        html = "";
        let quantidade = 100/$(".comparar:checked").length;
        $(".comparar:checked").map((a,b) => {
            let item = itens.find(item => item.id == b.value);
            html += `<div class="galery-item-max" style="width: ${quantidade}%;max-width: ${quantidade}%;min-width: ${quantidade}%">
                                <div class="galery-data-envio">
                                 <div class="data-envio">
                                <div class="pull-right">
                                    <a class="btn btn-xs btn-danger" onclick="$('.galery-item-max').remove()" id="excluir" title="Excluir Imagem">
                                        <i class="fa fa-times icon-trash"></i>
                                    </a>
                                </div>
                    Em ${moment(item.DataHora).format('DD/MM/YYYY H:mm:ss')}<br/> ${item.NovaDescricao}
                    </div>
                              </div>
                              <div class="galery-img"><img src="${item.ArquivoLink}" width="100%" height="100%" data-id="${item.id}" class="${item.extension} img-responsive" title="lost_typewritter.jpg"></div>
                    </div>`;
        })

        $(".max-width").html(html);
    }

    function changeDescription(id,tag){
        let valor = tag.value;

        $.post("ImagensNew.asp", {id,valor}, function(data){
            eval(data);
        });
    }

    function r90_1(f, id){
         let rotateAngle = $("img[data-id="+id+"]").attr("rotateAngle");

         if(!rotateAngle){
             rotateAngle = 0;
         }
         rotateAngle = Number(rotateAngle) + 90;
         $("img[data-id="+id+"]").css('transform','rotate(' + rotateAngle + 'deg)');
         $("img[data-id="+id+"]").attr('rotateAngle',rotateAngle);
    }

</script>