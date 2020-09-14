<!--#include file="connect.asp"-->
<%
I = req("I")
Tipo = req("Tipo")
soAtivo = req("soAtivo")

if soAtivo <> "" then
    if soAtivo = "off" then
        db.execute("UPDATE protocolos SET Ativo='' WHERE id="&I)
    else
        db.execute("UPDATE protocolos SET Ativo='on' WHERE id="&I)
    end if
    response.end
end if


if Tipo="Regra" then
    SexoRegra = ref("SexoRegra")
    SexoValor = ref("SexoValor")
    PesoRegra = ref("PesoRegra")
    PesoValor = ref("PesoValor")
    AlturaRegra = ref("AlturaRegra")
    AlturaValor = ref("AlturaValor")
    IdadeRegra = ref("IdadeRegra")
    IdadeValor = ref("IdadeValor")
    ConvenioRegra = ref("ConvenioRegra")
    ConvenioValor = ref("ConvenioValor")
    CidRegra = ref("CidRegra")
    CidValor = ref("CidValor")
    db.execute("UPDATE protocolos SET SexoRegra = '"&SexoRegra&"', SexoValor = '"&SexoValor&"', PesoRegra = '"&PesoRegra&"', PesoValor = "&treatvalzero(PesoValor)&", AlturaRegra = '"&AlturaRegra&"', AlturaValor = "&treatvalzero(AlturaValor)&", IdadeRegra = '"&IdadeRegra&"', IdadeValor = "&treatvalzero(IdadeValor)&", ConvenioRegra = '"&ConvenioRegra&"', ConvenioValor = '"&ConvenioValor&"', CidRegra = '"&CidRegra&"', CidValor = '"&CidValor&"' WHERE id="&I)

else

    NomeProtocolo = ref("NomeProtocolo")
    GrupoID = ref("GrupoID")
    Procedimentos = ref("Procedimentos")
    Referencia = ref("Referencia")
    NCiclos = ref("NCiclos")
    AUC = ref("AUC")
    Marcacao = ref("Marcacao")
    MaxDias = ref("MaxDias")
    Periodicidade = ref("Periodicidade")
    Duracao = ref("Duracao")
    Ativo = ref("Ativo")

    db.execute("UPDATE protocolos SET NomeProtocolo = '"&NomeProtocolo&"', GrupoID = "&GrupoID&", Procedimentos = '"&Procedimentos&"', Referencia = '"&Referencia&"', NCiclos = "&treatvalzero(NCiclos)&", AUC = "&treatvalzero(AUC)&", Marcacao = "&treatvalzero(Marcacao)&", MaxDias = "&treatvalzero(MaxDias)&", Periodicidade = "&treatvalzero(Periodicidade)&", Duracao = "&treatvalzero(Duracao)&", Ativo = '"&Ativo&"', sysActive = 1 WHERE id="&I)

    set getKits = db.execute("SELECT * FROM protocoloskits WHERE ProtocoloID="&I)
    while not getKits.eof
        KitID = getKits("id")
        db.execute("UPDATE protocoloskits SET KitID="&treatvalzero(ref("Kit_"&KitID))&", sysActive=1 WHERE id="&KitID)
    getKits.movenext
    wend
    getKits.close
    set getKits=nothing

    set getMedicamentos = db.execute("SELECT * FROM protocolosmedicamentos WHERE ProtocoloID="&I)
    while not getMedicamentos.eof
        MedicamentoID = getMedicamentos("id")

        db.execute("UPDATE protocolosmedicamentos SET Medicamento="&treatvalzero(ref("Medicamento_"&MedicamentoID))&" , Dose="&treatvalzero(ref("Dose_"&MedicamentoID))&" , Dias='"&ref("Dias_"&MedicamentoID)&"', Ciclos='"&ref("Ciclos_"&MedicamentoID)&"', Obs='"&ref("Obs_"&MedicamentoID)&"', DiluenteID="&treatvalzero(ref("DiluenteID_"&MedicamentoID))&", QtdDiluente="&treatvalzero(ref("QtdDiluente_"&MedicamentoID))&", ReconstituinteID="&treatvalzero(ref("ReconstituinteID_"&MedicamentoID))&", QtdReconstituinte="&treatvalzero(ref("QtdReconstituinte_"&MedicamentoID))&", sysActive=1 WHERE id="&MedicamentoID)
    getMedicamentos.movenext
    wend
    getMedicamentos.close
    set getMedicamentos=nothing

end if
%>

new PNotify({
    title: 'Sucesso!',
    text: 'Protocolo Salvo',
    type: 'success',
    delay:1000
});
