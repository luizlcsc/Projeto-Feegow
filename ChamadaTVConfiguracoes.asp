<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->
<div class="app" style="padding-top: 11px;">
<i style="text-align: center; margin: 30px;" class="far fa-spin fa-spinner"></i>
</div>

<script src="https://cdnjs.cloudflare.com/ajax/libs/vue/2.5.16/vue.min.js"></script>

<script type="text/javascript">

    <% 
    versao = "settings"
    licencaID = replace(session("Banco"),"clinic","")

    if recursoAdicional(1) = 4 then    
        SQLTV = "SELECT ct.id FROM cliniccentral.chamadas_tv ct WHERE ct.LicencaID="&licencaID
        set validaSQLTV = db.execute(SQLTV)
        if validaSQLTV.eof then         
            db_execute("INSERT INTO cliniccentral.chamadas_tv(LicencaID, Diretorio, ChamadaRecepcao, TemplateID, BipID, Imagens, Intervalo, Opcoes, Ativo, Obs, Cor1, Cor2, Cor3, CorFundo, Logo, Video) VALUES ("&licencaID&", NULL, b'0', 1, 1, NULL, 15, '[""NomeLocal"",""ChamadaPorVoz"",""PreConsulta"",""PosConsulta"",""UltimasSenhas"",""videoMudo""]', 1, NULL, 'ff0000', 'ffffff', 'df5640', 'b4ebf0', NULL, NULL)")
        end if    
    
        validaVersaoSQL = "SELECT ctvt.versao FROM cliniccentral.chamadas_tv ctv LEFT JOIN cliniccentral.chamadas_tv_templates ctvt ON ctvt.id=ctv.TemplateID WHERE ctv.LicencaID="&licencaID

        set validaVersao = db.execute(validaVersaoSQL)
        if not validaVersao.eof then 
            if validaVersao("versao") = 2 then
                versao = "settingsV2"
            end if
        end if
        %>

        getUrl("tvcall/<%=versao%>", {}, function(data) {
            $(".app").hide();
            $(".app").html(data);
            $(".app").fadeIn('slow');
        });

    <%else%>
        $(".app").html("Verificar se recurso está ativado");
    <%end if%>
</script>

