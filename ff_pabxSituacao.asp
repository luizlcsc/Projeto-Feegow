<%
set ram = db.execute("select Ramal,pabx_cod,pabx_pausa,pabx_logado from sys_users where id="& session("User"))

Ramal       = ram("Ramal")&""
pabx_cod    = ram("pabx_cod")&""
pabx_pausa  = ram("pabx_pausa")&""
pabx_logado = ram("pabx_logado")&""

session("Ramal") = Ramal
sessionClinicBase = session("banco")

if pabx_logado<>1 then
  pausaDisabled = "disabled"
end if

set vPausas = db.execute("select * from "&sessionClinicBase&".pabx_pausas")
pabxPausa_values = "<option value=''>Desativado</option>"
while not vPausas.eof

  pabx_pausas_id     = vPausas("id")
  pabx_pausas_nome   = vPausas("nome")
  pabx_pausas_tempo  = vPausas("tempo")
  pausaTempo = ""

  if cint(pabx_pausa) = cint(pabx_pausas_id) then
    inputSelected = "selected"
  else
    inputSelected = ""
  end if
  
  if pabx_pausas_tempo > 0 then
    pausaTempo = " | ("&pabx_pausas_tempo&" minutos)"
  end if

  pabxPausa_values = pabxPausa_values&"<option "&inputSelected&" value='"&pabx_pausas_id&"'>"&pabx_pausas_nome&pausaTempo&"</option>"

vPausas.movenext
wend
vPausas.close
set vPausas = nothing



if pabx_logado = 1 then
  logadoBtnTXT    = "CONECTADO"
  logadoBtnClass  = "btn-primary pabxLogin" 
else
  logadoBtnTXT = "DESCONECTADO"
  logadoBtnClass  = "" 
end if
%>
<div class="col-sm-6 col-xl-6">
  <div class="panel panel-tile text-center br-a br-grey">
    <div class="panel-body">
      <div class="row">
        <div class="col-sm-4">
            <input type="text" class="form-control text-center fs30" name="Ramal" id="Ramal" value="<%=pabx_cod%>" placeholder="-" />
          <h6 class="text-success">CÓDIGO</h6>
        </div>
        <div class="col-sm-4">
            <input type="text" class="form-control text-center fs30" name="Ramal" id="Ramal" value="<%= Ramal %>" placeholder="-" />
          <h6 class="text-success">RAMAL</h6>
        </div>
        <div class="col-sm-4">
            <select id="pabxPausa" class="form-control" <%=pausaDisabled%>>
            <%=pabxPausa_values%>
          </select>
          <h6 class="text-success">PAUSA</h6>
        </div>
      </div>
    </div>
    <div class="panel-footer br-t p12">
        <span class="fs11">
            <div class="row">
                <div class="col-xs-12">
                    <button id="pabxConn" class="btn btn-sm btn-block <%=logadoBtnClass%>"><%=logadoBtnTXT%></button>
                </div>
            </div>
        </span>
    </div>
  </div>
</div>
    
<script type="text/javascript">
    $("#Ramal").keyup(function () {
        $.get("saveRamal.asp?U=<%= session("User") %>&Ramal=" + $(this).val(), function (data) { eval(data) });
    });

    $("#pabxConn").click(function () {
      
      if($('#pabxConn').hasClass('pabxLogin')){
        //$(this).toggleClass('btn-primary').text('DESCONECTADO');
        $("#pabxConn")
        .removeClass("btn-primary pabxLogin")
        .text("DESCONECTADO");
        
        $.get("ff_futurofone.asp?ff_metodo=GetLoginAgenteLogoff&agente=3006");
        $("#pabxPausa").prop('disabled', 'disabled')
      } else {
        $("#pabxConn")
        .addClass("btn-primary pabxLogin")
        .text("CONECTADO");

        $.get("ff_futurofone.asp?ff_metodo=GetLoginAgente&agente=3006&ramal=3006&pausa=&senha=xxx");
        $('#pabxPausa').prop('disabled', false);
      }
      
    });

    $('#pabxPausa').change(function(event){
      var pabxPausaVal = event.currentTarget.value;
      $.get("ff_futurofone.asp?ff_metodo=GetLoginAgente&agente=3006&ramal=3006&pausa="+pabxPausaVal+"&senha=xxx");
    });
 
</script>