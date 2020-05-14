<!--#include file="connect.asp"-->
<%
I = req("I")
Tipo = req("Tipo")
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
    Ciclos = ref("Ciclos")
    AUC = ref("AUC")
    Marcacao = ref("Marcacao")
    Periodo = ref("Periodo")
    Duracao = ref("Duracao")
    DuracaoTempo = ref("DuracaoTempo")
    Ativo = ref("Ativo")
    sysActive = ref("sysActive")

    db.execute("UPDATE protocolos SET NomeProtocolo = '"&NomeProtocolo&"', GrupoID = "&GrupoID&", Procedimentos = '"&Procedimentos&"', Referencia = '"&Referencia&"', Ciclos = "&treatvalzero(Ciclos)&", AUC = "&treatvalzero(AUC)&", Marcacao = "&treatvalzero(Marcacao)&", Periodo = "&treatvalzero(Periodo)&", Duracao = "&treatvalzero(Duracao)&", DuracaoTempo = '"&DuracaoTempo&"', Ativo = '"&Ativo&"', sysActive = 1 WHERE id="&I)
end if
%>

new PNotify({
    title: 'Sucesso!',
    text: 'Protocolo Salvo',
    type: 'success',
    delay:1000
});
