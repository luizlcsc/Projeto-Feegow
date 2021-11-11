<!--#include file="connect.asp"-->
<!--#include file="ProntCompartilhamento.asp"-->
<!--#include file="Classes/Arquivo.asp"-->
<!--#include file="Classes/Json.asp"-->
<%
    if req("rotateAngle")&""<>"" then
        qImagemUpdateSQL = "UPDATE arquivos SET imgRotate="&req("rotateAngle")&" WHERE id="&req("I")
        db.execute(qImagemUpdateSQL) 
        response.end()
    end if
    IF ref("valor") <> "" THEN
        db.execute("UPDATE arquivos SET Descricao = '"&ref("valor")&"' WHERE id = '"&ref("id")&"' ")

        %>
        new PNotify({
            title: '<i class="far fa-save"></i>',
            text: 'Descrição alterada com sucesso.',
            type: 'success'
        });
        <%
        response.end
    END IF

ArquivoImagem = req("ArquivoImagem")
ImageRenderType = "download"
PacienteID=req("PacienteID")

if PacienteID<>"" and PacienteID<>"0" then
    'ImageRenderType = "redirect"
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
        box-shadow: 0 3px 18px rgba(0,0,0,0.1);
    }
    .galery-item-max{
        max-width: 100%;
        min-width: 100%;
    }

    .galery-item-max .galery-img {
            max-width: 100%;
            min-width: 100%;
            height:100vh;
    }

    .galery-item .galery-img{
        height: var(--height-main);
        text-align: center;
        padding-bottom: 8px;
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
        background: rgba(85,85,85,0.5);
        
        border-bottom-right-radius: 8px;
        border-bottom-left-radius: 8px;
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
        background: rgba(85,85,85,0.5);
        display: block;
        width: 100%;
        padding: 5px;
        border-top-right-radius: 8px;
        border-top-left-radius: 8px;
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
    <span class="far fa-columns	"></span>
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
    <span class="far fa-tag"></span>
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
        <i class="far fa-circle-o-notch fa-spin"></i>
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

            let isImage = true
            let extension = item.NomeArquivo.substr(item.NomeArquivo.lastIndexOf('.') + 1).toLowerCase();
            let link = '';
            let formato = 'a';
            if(['png','gif','jpeg','jpg'].includes(extension)){
                formato = 'span';
                link = item.thumbnailLink?item.thumbnailLink+'&dimension=thumb':item.ArquivoLink+'&dimension=full';
            }

            let baseLink = "https://cdn.feegow.com/icons/";

            if(['docx','doc','rtf'].includes(extension)){
                link = baseLink + 'doc.png';
                isImage=false;
            }

            if(['pdf'].includes(extension)){
                link = baseLink + 'pdf.png';
                isImage=false;

            }
            // if(['png'].includes(extension)){
            //     link = 'png.png';
            // }
            if(['mp4'].includes(extension)){
                link = baseLink + 'pdf.png';
                isImage=false;
            }
            if(['xml'].includes(extension)){
                // link = 'xml.png';
            }

            if(['txt'].includes(extension)){
                link = baseLink + 'txt.png';
                isImage=false;
            }

            if(['pptx'].includes(extension)){
                link = baseLink + 'ppt.png';
                isImage=false;
            }

            if(['csv'].includes(extension)){
                link = baseLink + 'csv.png';
                isImage=false;
            }

            if(['xlsx','xls'].includes(extension)){
                link = baseLink + 'xls.png';
                isImage=false;
            }

            // if(['jpg','jpeg'].includes(extension)){
            //     link = 'jpg.png';
            // }

            if(['mp3'].includes(extension)){
                link = baseLink + 'mp3.png';
                isImage=false;
            }
            if(['mp4'].includes(extension)){
                link = baseLink + 'mp4.png';
                isImage=false;
            }
            if(['txt'].includes(extension)){
                link = baseLink + 'txt.png';
                isImage=false;
            }

            item.link = link;
            item.isImage = isImage;
            item.extension = extension;
            item.formato = formato;
    }

    function loadItens(){
        let b = itens.filter(item => {
            return getSelected().includes(item.Tipo);
        }).map((item) => {
                processaItem(item);
                let renderType = 'download';

                let cacheControl="1";

                
                if(!item.isImage){
                    renderType="redirect";
                    cacheControl = Math.floor(Date.now() / 1000);
                }else{
                    // item.ArquivoLink = item.ArquivoLink.replace('redirect','download')
                }

                return `<div class="galery-item" id="item${item.id}">
                             <div class="galery-data-envio">
                                <small class="pull-right data-envio">Em ${moment(item.DataHora).format('DD/MM/YYYY H:mm:ss')}</small><br/>
                                <div class="config-buttons">
                                    <small class="pull-left">
                                        <div class="bs-component">
                                         <div class="checkbox-custom mb5">
                                           <input type="checkbox" class="comparar" name="comparar[${item.id}]" value="${item.id}" id="comparar${item.id}">
                                           <label for="comparar${item.id}">&nbsp</label>
                                         </div>
                                       </div>
                                    </small>

                                    <button class="btn btn-xs btn-alert btn-sensitive-action" title="Copiar link" onclick="CopyToClipboard('${item.ArquivoLink}')">
                                        <i class="far fa-copy"></i>
                                    </button>
                                    <a class="btn btn-xs btn-alert btn-sensitive-action" href="javascript:modalTipo(${item.id})" title="Cadastrar tipo de imagem">
                                                              <i class="far fa-cog"></i>
                                    </a>
                                    <a class="btn btn-xs btn-alert btn-sensitive-action" href="javascript:expandItem(${item.id})" title="Abrir Imagem Separadamente">
                                                              <i class="far fa-expand icon-external-link"></i>
                                    </a>
                                    <a class="btn btn-xs btn-alert btn-sensitive-action" href="${item.ArquivoLink}&dimension=full&rotate=${item.imgRotate}" target="_blank" title="Abrir Imagem em outra aba">
                                                              <i class="far fa-external-link icon-external-link"></i>
                                    </a>
                                    <a class="btn btn-xs btn-alert btn-sensitive-action" href="javascript:r90_1('${item.NomeArquivo}', '${item.id}', ${item.imgRotate})" title="Girar 90°">
                                            <i class="far fa-rotate-right"></i>
                                    </a>
                                    <!--<a class="btn btn-xs btn-alert btn-sensitive-action" href="javascript:MaisInfo('')" title="Mais informações">
                                                        <i class="far fa-info-circle"></i>
                                    </a>-->
                                    <a class="hidden btn btn-xs btn-alert btn-sensitive-action" href="#" title="Editar Imagem" onclick="return launchEditor('image1', '${item.ArquivoLink}');">
                                                        <i class="far fa-pencil icon-pencil"></i>
                                    </a>
                                    <a class="btn btn-xs btn-danger btn-sensitive-action" href="javascript:if(confirm('Tem certeza de que deseja excluir esta imagem?'))atualizaAlbum(${item.id});" id="excluir" title="Excluir Imagem">
                                        <i class="far fa-trash icon-trash"></i>
                                    </a>
                                </div>

                             </div>
                             <div class="galery-img sensitive-data">
                                <${item.formato} href="${item.ArquivoLink}" target="_blank">
                                    <img
                                        loading=lazy
                                        src="${item.link}"
                                        data-id="${item.id}"
                                        class="${item.extension} img-responsive"
                                        title="${item.Descricao}"
                                        onload="$(this).css('transform','rotate(${item.imgRotate}deg)');"
                                    >
                                </a>
                             </div>
                             <div class="config">
                                <textarea class="galery-description text-info border-edit imgpac" name="Desc${item.id}" onchange="changeDescription(${item.id},this)" data-img-id="${item.id}">${item.NovaDescricao}</textarea>
                             </div>
                       </div>`;
             });

             document.getElementById("galery").innerHTML =b.join("");
    }



    function expandItem(id){
         let item = itens.find(item => item.id == id);
         let boxImageRotate = false;
         
         if (item.imgRotate>0){
            boxImageRotate = `
                onload="$(this)
                    .css({
                        'max-width' : '100vh',
                        'max-height' : '100vw',
                        'transform' : 'translatex(calc(50vw - 50%)) translatey(calc(50vh - 50%)) rotate(${item.imgRotate}deg)'
                    });"         
             `;
         }

         let html = `
         <div class="galery-item-max">
            <div class="galery-data-envio">
             <div class="data-envio">
            <div class="pull-right">
                <a class="btn btn-xs btn-danger" onclick="$('.galery-item-max').remove()" id="excluir" title="Excluir Imagem">
                    <i class="far fa-times icon-trash"></i>
                </a>
            </div>
Em ${moment(item.DataHora).format('DD/MM/YYYY H:mm:ss')}<br/> ${item.NovaDescricao}
</div>
          </div>
          <div class="galery-img">
            <img
                loading=lazy
                src="${item.ArquivoLink}&dimension=full"
                data-id="${item.id}"
                class="${item.extension} img-responsive"
                title="${item.Descricao}"
                ${boxImageRotate}
            >
        </div>
    </div>`;


        $(".max-width").html(html);
        $(window).scrollTop($('.max-width').offset().top - 120)
    }

    function modalTipo(id){

        let tipos = '<%= recordToJSON(db.execute("select * from tipos_de_arquivos where sysActive=1")) %>' ;
        let preset = false
        $.get(`imagemTipoAtual.asp?id=${id}` )
            .done(  function (data) {
                data = JSON.parse(data)
                if(data.length > 0){
                    preset = data[0]
                }
                tipos = JSON.parse(tipos)
                console.log(preset)
                let modal = `
                    <div id='configTipo' class="modal fade" tabindex="-1" role="dialog">
                        <div class="modal-dialog" role="document">
                            <div class="modal-content">
                            <div class="modal-header">
                                <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                                <h4 class="modal-title">Configurar tipo de arquivo</h4>
                            </div>
                            <div class="modal-body">
                                <div class='row'>
                                    <div class="form-group col-md-6">
                                        <label for="NomeArquivo">Tipo de Arquivo</label>
                                        <select name="tipos" class="form-control" id="tipos">
                                            <option>Selecionar tipo</option>
                                            ${ tipos.map(tipo=>{
                                                return `<option ${(preset?(preset.TipoArquivoID == tipo.id?'selected':''):'')} value='${tipo.id}'>${tipo.NomeArquivo}</option>`
                                            }).join('')}
                                        </select>
                                    </div>
                                    <div class="form-group col-md-6">
                                        <label for="validade">Validade</label>
                                        <%=quickfield("datepicker", "validade", "", 12, "", "", "", " data-id='' ")%>
                                    </div>
                                </div>
                            </div>
                            <div class="modal-footer">
                                <button type="button" class="btn btn-success" onClick='saveTipo(${id})'><i class="far fa-save"></i> Salvar</button>
                            </div>
                            </div><!-- /.modal-content -->
                        </div><!-- /.modal-dialog -->
                    </div><!-- /.modal -->`

            $('.galery-item').parent().append(modal)
            if(preset){
                $("#validade").val(preset.validade)
            }
            $("#validade").mask("99/99/9999");
            $('#configTipo').modal('toggle')
        })
    }

    function saveTipo(id){
        let tipo= $('#tipos').val()
        let validade  = $('#validade').val()
        validade = validade.split('/').reverse().join('-')

        if(tipo){
            $.get(`imagemTipoSave.asp?id=${id}&tipo=${tipo}&validade=${validade}` )
            .done(function(data) {
                $('#configTipo').modal('toggle')
            })
        }else{
            $('#configTipo').modal('toggle')
        }
    }
    let ConfigPacienteID      = '<%=PacienteID%>';
    let ConfigMovementID      = '<%=req("MovementID")%>';
    let ConfigLaudoID         = '<%=req("LaudoID")%>';
    let ConfigOrdemDeCompraID = '<%=req("OrdemDeCompraID")%>';
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

    if(ConfigOrdemDeCompraID > 0){
        valorConsulta = ConfigOrdemDeCompraID;
        typeSearch = 'OrdemDeCompraID'
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
            let imgRotate = item.imgRotate;
            
            
            html += `<div class="galery-item-max" style="width: ${quantidade}%;max-width: ${quantidade}%;min-width: ${quantidade}%">
                                <div class="galery-data-envio">
                                 <div class="data-envio">
                                <div class="pull-right">
                                    <a class="btn btn-xs btn-danger" onclick="$('.galery-item-max').remove()" id="excluir" title="Excluir Imagem">
                                        <i class="far fa-times icon-trash"></i>
                                    </a>
                                </div>
                    Em ${moment(item.DataHora).format('DD/MM/YYYY H:mm:ss')}<br/> ${item.NovaDescricao}
                    </div>
                              </div>
                              <div class="galery-img">
                                <img
                                    loading=lazy
                                    src="${item.ArquivoLink}&dimension=full"
                                    width="100%"
                                    height="100%"
                                    data-id="${item.id}"
                                    class="${item.extension} img-responsive"
                                    title="lost_typewritter.jpg"
                                    style="transform: rotate(${imgRotate}deg);"
                                >
                              </div>
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

    function r90_1(f, id, rotate){
        let rotateAngle = $("img[data-id="+id+"]").attr("rotateAngle");
        if(!rotateAngle){
            rotateAngle = rotate;
        }
        rotateAngle = Number(rotateAngle) + 90;
        $("img[data-id="+id+"]").css('transform','rotate(' + rotateAngle + 'deg)');
        $("img[data-id="+id+"]").attr('rotateAngle',rotateAngle);
        if (rotateAngle>270) {
            rotateAngle=0
        }
        $.ajax({
            type:`GET`,
            url:`ImagensNew.asp?rotateAngle=`+rotateAngle+`&I=`+id,
            
        });
    }

function atualizaAlbum(X){
    var item = `item`+X;
    $.ajax({
		type:"POST",
		url:"Imagens.asp?PacienteID=<%=req("I")%>&X="+X,
		success:function(data){
			//$("#galery").html(data);
            $("#"+item).hide();
		}
	});
    
}

function CopyToClipboard(value) {
  var tempInput = document.createElement("input");
  tempInput.value = value;
  document.body.appendChild(tempInput);
  tempInput.select();
  document.execCommand("copy");
  document.body.removeChild(tempInput);

  showMessageDialog("para a área de transferência.", "success", "Link copiado!", 5000);
}

</script>