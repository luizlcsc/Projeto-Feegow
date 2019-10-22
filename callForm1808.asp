<%
'on error resume next
FormID = Id
set getForm = db.execute("select * from buiforms where id="& ModeloID )
if not getForm.eof then
%>
<div class="panel-heading">
    <span class="panel-title">
    <i class="fa fa-bar-chart"></i> <%=getForm("Nome") %>
        <code id="nomeProfissionalPreen"></code>
    </span>
    <span class="panel-controls">
        <button class="btn btn-primary btn-sm btn-save-form" type="button" onclick="saveForm(0)"><i class="fa fa-save"></i> <span class="btn-save-form-text">Salvar</span></button>
        <button class="btn btn-default btn-sm" type="button" onclick="fechar()"><i class="fa fa-remove"></i> Fechar</button>
    </span>
</div>
         <div class="panel-menu nomePacientePreen text-center"></div>
<div class="panel-body p25" id="iProntCont">
    <br />
   
    <%
    if getForm("Versao")=1 then
	    %>
        <!--#include file="callOldForm.asp"-->
        <%
    else
        if session("Banco")="clinic3494" then
            if getForm("useHTML") then
                %>
                <!--#include file="callHTMLForm.asp"-->
                <%
            else
	            %>
                <!--#include file="callNewForm.asp"-->
                <%
            end if
        else
	    %>
        <!--#include file="callNewForm.asp"-->
        <%
        end if
    end if
    %>
</div>
<div class="panel-footer text-right">
    <%if session("Banco")="clinic100000" or session("Banco")="clinic105" or session("Banco")="clinic2803" then %>
    <button type="button" class="btn btn-alert" onclick="window.open('LogsForm.asp?m=<%=req("m") %>&p=<%=req("p") %>')"><i class="fa fa-history"></i> Logs</button>
    <%end if %>
    <button class="btn btn-info" type="button" onclick="saveForm('P')"><i class="fa fa-print"></i> Imprimir</button>
    <button class="btn btn-primary btn-save-form" type="button" onclick="saveForm(0)"><i class="fa fa-save"></i> <span class="btn-save-form-text">Salvar</span></button>
</div>
<%else %>
    Este modelo de formulário foi apagado.
<%end if


urlPost = "saveNewForm.asp?A='+A+'&t="&req("t")&"&p="&req("p")&"&m="&req("m")&"&i="&req("i")
%>
<script type="text/javascript">
/*
    function saveForm(A) {
        var $form = $('.tbl');
        var dados = {
            <%
            set pcampos = db.execute("select id, TipoCampoID from buicamposforms where FormID="&req("m"))
            while not pcampos.eof
                select case pcampos("TipoCampoID")
                    case 1, 2, 6
                        postVal = "$('#input_"& pcampos("id")&"').val()"
                    case 8
                        postVal = "$('#input_"& pcampos("id")&"').html()"
                    case 4
                        postVal = "$('.campoCheck[name=input_"& pcampos("id") &"]:checked').map(function() { return $(this).val().toString(); } ).get().join("","")"
                    case 5
                        postVal = "$('.campoInput[name=input_"& pcampos("id") &"]:checked').val()"
                    case 9
                        postVal = "$('.tbl').serialize()"
                    case else
                        postVal= ""
                end select
                if postVal<>"" then
                    %>
                    input_<%=pcampos("id")%>: <%=postVal%>,
                    <%
                end if
            pcampos.movenext
            wend
            pcampos.close
            set pcampos=nothing
            %>
        };

        dados = $form.serialize() + '&' + $.param(dados);

        $.ajax({
            type: 'POST',
            url: '<%=urlPost%>',
            data: dados,

            success: function (data) {
                eval(data);
            }
        });

    }
*/

    function saveForm(A) {
        var $btnSave = $(".btn-save-form"),
            $btnSaveText = $btnSave.find(".btn-save-form-text");

        $btnSaveText.html("Salvando");
        $btnSave.attr("disabled", true);
        $.post('<%=urlPost%>', $(".campoInput, .campoCheck, .tbl, #ProfissionaisLaudar").serialize(), function(data){
            $btnSave.attr("disabled", false);
            $btnSaveText.html("Salvar");
            eval(data);
        });
    }
    function alt(){
        $("#Alterado").val('S');
        $.post("formsLog.asp?m=<%=req("m")%>&p=<%=req("p")%>&i=<%=req("i")%>", $(".campoInput, .campoCheck, .tbl").serialize(), function(data){
            
        });
    }
    $(".campoCheck, .campoInput").change(function(){
        alt();
    });

    function fechar(){
        if($("#Alterado").val()=="S"){
            if(confirm("ATENÇÂO: Você não salvou este formulário. Tem certeza de que deseja fechar sem salvar?")){
                $("#modal-form").magnificPopup("close");
            }
        }else{
            $("#modal-form").magnificPopup("close");
        }
    }
</script>