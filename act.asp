<!--#include file="connect.asp"-->
<%
idColuna = req("IDCol")
spl = split(idColuna, "_")
FormPreenchidoID = req("FPID")
tipoForm = req("tipoForm")
FormID = req("FormID")

CampoID = spl(0)
Coluna = spl(1)
ModeloID = spl(2)
'

if tipoForm = "PrevisaoParto" then
    DUM = 0
    SemanasUS = 0
    DiasUS = 0
    DPUS = 0
    PesoInicial = 0
    set getCampo = db.execute("SELECT id, InformacaoCampo FROM buicamposforms WHERE InformacaoCampo IN (18, 19, 20, 21, 22, 23, 24) AND FormID="&FormID)
    while not getCampo.eof
        Select Case getCampo("InformacaoCampo")
          case 18
            DUM = ref("input_"&getCampo("id"))
          case 20
            SemanasUS = ref("input_"&getCampo("id"))
          case 21
            DiasUS = ref("input_"&getCampo("id"))
          case 22
            DPUS = ref("input_"&getCampo("id"))
          case 24
            PesoInicial = ref("input_"&getCampo("id"))
        End Select
    getCampo.movenext
    wend
    getCampo.close
    set getCampo = nothing


    if Coluna="4" then
        if isnumeric(PesoInicial) then
            PesoInicial = ccur(PesoInicial)
        else
            PesoInicial = 0
        end if
        set valAnt = db.execute("select c"&Coluna&" from buitabelasvalores WHERE CampoID="& CampoID &" AND FormPreenchidoID="& FormPreenchidoID &" ORDER BY id DESC LIMIT 1")
        if valAnt.eof then
            PesoAnterior = PesoInicial
        else
            PesoAnterior = valAnt("c"&Coluna)&""
        end if
        if isnumeric(PesoAnterior) then
            PesoAnterior = ccur(PesoAnterior)
        else
            PesoAnterior = 0
        end if
        PesoAtual = ref( CampoID &"_4_"& ModeloID )
        if isnumeric(PesoAtual) then
            PesoAtual = ccur(PesoAtual)
        else
            PesoAtual = 0
        end if
        GanhoPeriodo = PesoAtual - PesoAnterior
        GanhoGestacao = PesoAtual - PesoInicial

       %>
        $("#<%= CampoID &"_7_"& ModeloID %>").val("<%= formatnumber(GanhoPeriodo, 3) %>");
        $("#<%= CampoID &"_8_"& ModeloID %>").val("<%= formatnumber(GanhoGestacao, 3) %>");
        <%
    elseif Coluna="5" then

        %>
        var peso = $("#<%= CampoID &"_4_"& ModeloID %>").val().replace(",", ".");
        var altura = $("#<%= CampoID &"_5_"& ModeloID %>").val().replace(",",".");

        var imc = peso / (altura * altura)
        if(!isNaN(imc) && imc < Number.POSITIVE_INFINITY){
            $("#<%= CampoID &"_6_"& ModeloID %>").val(imc.toFixed(2));
        }
        <%

    elseif Coluna=1 then
        DataAtual = ref(CampoID &"_1_"& ModeloID)
        DataInicial = DUM
        if DataInicial&""<>"" then
            Semanas = datediff("w", DataInicial, DataAtual)
            Dias = datediff("d", DataInicial, DataAtual) mod 7
            TotalDias = Semanas&" | "&Dias
        end if

        if DPUS&""<>"" then
            DiasSemanasUS = ((SemanasUS * 7) + DiasUS)
            DifData = datediff("d", DPUS, DataAtual)
            DifSemanas = int(((DiasSemanasUS + DifData) / 7))
            DifDias = (DiasSemanasUS + DifData) mod 7
            TotalDif = DifSemanas&" | "&DifDias
        end if

        %>
        $("#<%= CampoID &"_2_"& ModeloID %>").val("<%= TotalDias %>");
        $("#<%= CampoID &"_3_"& ModeloID %>").val("<%= TotalDif %>");
        <%
    end if
elseif tipoForm = "CalculoIMC" then
    %>
    var peso = $("#<%= CampoID &"_2_"& ModeloID %>").val().replace(",", ".");
    var altura = $("#<%= CampoID &"_3_"& ModeloID %>").val().replace(",",".");

    var imc = peso / (altura * altura)
    if(!isNaN(imc) && imc < Number.POSITIVE_INFINITY){
        $("#<%= CampoID &"_4_"& ModeloID %>").val(imc.toFixed(2));
    }
    <%
    set valAnt = db.execute("select c2 from buitabelasvalores WHERE CampoID="& CampoID &" AND FormPreenchidoID="& FormPreenchidoID &" ORDER BY id DESC LIMIT 1")
    if valAnt.eof then
        PesoAnterior = 0
    else
        PesoAnterior = valAnt("c2")&""
    end if
    if isnumeric(PesoAnterior) then
        PesoAnterior = ccur(PesoAnterior)
    else
        PesoAnterior = 0
    end if
    PesoAtual = ref( CampoID &"_2_"& ModeloID )
    if isnumeric(PesoAtual) then
        PesoAtual = ccur(PesoAtual)
    else
        PesoAtual = 0
    end if
    GanhoPeriodo = PesoAtual - PesoAnterior
    %>
    $("#<%= CampoID &"_5_"& ModeloID %>").val("<%= formatnumber(GanhoPeriodo, 2) %>");
    <%
end if
%>