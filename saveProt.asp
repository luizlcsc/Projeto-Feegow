<!--#include file="connect.asp"-->
<%
FormID = req("FormID")
Salvar = req("Salvar")
set f = db.execute("select * from buiformspreenchidos where id="& FormID)
ModeloID = f("ModeloID")
T = req("T")
TipoCV = req("TipoCV")
LinCV = req("LinCV")
ColCV = req("Col")

if Salvar="1" then
   db.execute("UPDATE `buiformspreenchidos` SET sysActive=1 WHERE id="&FormID)
   db.execute("UPDATE `pacientesdiagnosticos` SET sysActive=1 WHERE FormID="&FormID)
   %>
    new PNotify({
        title: 'Atendimento salvo',
        text: '',
        sticky: true,
        type: 'success',
           delay: 5000
    });
    $("#divProtocolo").html();
    location.reload();

   <%
end if

if T="0" then
    set c = db.execute("select * from buicamposforms where FormID="& ModeloID)
    while not c.eof
        select case c("TipoCampoID")
            case 1, 2, 4, 5, 8, 16
                db.execute("update `_"& ModeloID &"` set `"& c("id") &"`='"& refHTML("Campo"& c("id")) &"' WHERE id="& FormID)
        end select
    c.movenext
    wend
    c.close
    set c = nothing

    set pc = db.execute("select * from pacientesciap where FormID="& FormID)
    while not pc.eof
        db.execute("update pacientesciap set DataEntrada="& mydatenull(ref("DataEntrada"&pc("id"))) &", DataSaida="& mydatenull(ref("DataSaida"&pc("id"))) &", Hospital='"& ref("Hospital"&pc("id")) &"' where id="& pc("id"))
    pc.movenext
    wend
    pc.close
    set pc = nothing

    set enc = db.execute("select * from protocolosencaminhamentos where FormID="& FormID)
    while not enc.eof
        db.execute("update protocolosencaminhamentos set Motivo='"& ref("Motivo"&enc("id")) &"', Obs='"& ref("Obs"&enc("id")) &"' where id="& enc("id"))
    enc.movenext
    wend
    enc.close
    set enc = nothing

    set m = db.execute("select id from memed_prescricoes where FormID="& FormID)
    while not m.eof
        upmed = "update memed_prescricoes set Dose='"& ref("Dose"& m("id")) &"', Apresentacao="& treatvalzero(ref("Apresentacao"& m("id"))) &", Via="& treatvalzero(ref("Via"& m("id"))) &", Frequencia='"& ref("Frequencia"& m("id")) &"', Duracao='"& ref("Duracao"& m("id")) &"', TempoTratamento='"& ref("TempoTratamento"& m("id")) &"', TipoTempo='"& ref("TipoTempo"& m("id")) &"', PosologiaMedicamento='"& ref("PosologiaMedicamento"& m("id")) &"' where id="& m("id")
    '    response.Write("//"& upmed )
        db.execute( upmed )
    m.movenext
    wend
    m.close
    set m=nothing

    set pp = db.execute("select id from protocolospedidos where FormID="& FormID)
    while not pp.eof
        uppp = "update protocolospedidos set Resultado='"& ref("Resultado"& pp("id")) &"' where id="& pp("id")
    '    response.Write("//"& uppp )
        db.execute( uppp )
    pp.movenext
    wend
    pp.close
    set pp=nothing
elseif T="cv" then
    TipoCV = req("TipoCV")
    LinCV = req("LinCV")
    CampoIDCV = req("CampoIDCV")
    ColCV = req("ColCV")
    Valor = ref("cv_"& TipoCV &"_"& CampoIDCV &"_"& LinCV &"_"& ColCV)
    set vca = db.execute("select id from buicvvalores where Tipo='"& TipoCV &"' and CampoID="& CampoIDCV &" and FormPID="& FormID &" and LinhaID="& LinCV &" and Coluna="& ColCV &"")
    if vca.eof then
        db.execute("insert into buicvvalores set Tipo='"& TipoCV &"', Valor='"& Valor &"', CampoID="& CampoIDCV &", FormPID="& FormID &", LinhaID="& LinCV &", Coluna="& ColCV &", sysUser="& session("User"))
    else
        db.execute("update buicvvalores set Valor='"& Valor &"', sysUser="& session("User") &" where id="& vca("id"))
    end if
end if
%>