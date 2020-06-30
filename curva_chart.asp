
<div style="width:840px;height:449px;">
  <svg width="100%" height="100%" id="meucanvas" xmlns="http://www.w3.org/2000/svg">
    <defs>
      <pattern id="smallGrid" width="11" height="11" patternUnits="userSpaceOnUse">
        <path d="M 11 0 L 0 0 0 11" fill="none" stroke="gray" stroke-width="0.5"/>
      </pattern>
      <pattern id="grid" width="55" height="55" patternUnits="userSpaceOnUse">
        <rect width="55" height="55" fill="url(#smallGrid)"/>
        <path d="M 55 0 L 0 0 0 55" fill="none" stroke="gray" stroke-width="1"/>
      </pattern>
    </defs>

    <rect width="100%" height="100%" fill="url(#grid)" />
  </svg>
</div>


<!--#include file="connect.asp"-->
<%
idCurva = req("T")
PacienteID = req("P")
set cv = db.execute("select * from curva.curva_curvas where id="& idCurva)

Tipo = cv("TP")
Tabela = "curva_"& Tipo
Tipo = cv("TP")
Inicio = cv("Inicio")
Fim = cv("Fim")
Intervalo = cv("Intervalo")
sqlColunasNULL = cv("sqlColunasNULL")
Coluna = cv("Coluna")
arrayColunas = cv("arrayColunas")
%>
<!DOCTYPE html>
<meta charset="utf-8">
<link rel="stylesheet" type="text/css" media="all" href="assets/css/curva.css" />
<body>
  <script src="assets/js/grafico.js"></script>
  <script>
  <%
    '-> ABAIXO GERA A LINHA DE VALORES INPUTADOS
  set pac = db.execute("select id, Sexo, Nascimento from pacientes where id="& PacienteID)
  if not pac.eof then
    Sexo = pac("Sexo")
    Nascimento = pac("Nascimento")
  end if
  if Sexo&""="" OR Sexo=0 OR Nascimento&""="" then
      response.write("Para utilizar a curva de crescimento, informe o sexo do paciente no cadastro principal.")
      RESPONSE.END
  end if

	set vals = db.execute("select * from pacientescurva WHERE PacienteID="& PacienteID &" "& sqlColunasNULL &" ORDER BY Data")
	if vals.EOF then
    %>
    var patientGrowth = '';
    <%
  else
  	%>
    var patientGrowth = [
  	<%
    while not vals.eof
      Dias = datediff("d", Nascimento, vals("Data"))
      %>
        [<%= Dias %>, <%= replace(vals( Coluna ), ",", ".")%>],
      <%
    vals.movenext
    wend
    vals.close
    set vals = nothing
    %>
	];
    <%
  end if
  '<-
  


  %>

var wfa_all_0_to_5_meta = {
    "lines": [ <%= arrayColunas %>
	]
};

var wfa_boys_0_to_5_meta = {};
wfa_boys_0_to_5_meta.lines =  wfa_all_0_to_5_meta.lines.slice();
wfa_boys_0_to_5_meta.title = "<%=Rotulo%>";


var wfa_boys_0_to_5_zscores = [
<%
sql = "select * from curva."&Tabela&" WHERE NOT ISNULL("& Intervalo &") AND Sexo="& Sexo &" AND "& Intervalo&" BETWEEN "& Inicio &" AND "& Fim
'response.write( sql )
set c = db.execute( sql )
while not c.eof
  if Coluna="PerimetroCefalico" then
    %>
    {"Month":"<%=c(Intervalo)%>","SD0":"<%=c("SD0")%>","SD1":"<%=c("SD1")%>","SD2":"<%=c("SD2")%>","SD3":"<%=c("SD3")%>","SD1neg":"<%=c("SD1neg")%>","SD2neg":"<%=c("SD2neg")%>","SD3neg":"<%=c("SD3neg")%>"},
    <%
  else
    %>
    {"Month":"<%=c(Intervalo)%>","SD0":"<%=c("SD0")%>","SD2":"<%=c("SD2")%>","SD3":"<%=c("SD3")%>","SD2neg":"<%=c("SD2neg")%>","SD3neg":"<%=c("SD3neg")%>"},
    <%
  end if
c.movenext
wend
c.close
set c=nothing
%>
];

var wfa_boys_0_to_5 = {
  "meta" : wfa_boys_0_to_5_meta,
  "data" : wfa_boys_0_to_5_zscores
};
</script>

<script type="text/javascript" src="curva<%= Tipo %>.asp"></script>
<script>
  let xxMin = 0;
  <% if idCurva = 3 then %>
    xxMin = 180;
  <% elseif  idCurva = 4 then %>
    xxMin = 731;
  <% end if  %>
  var growthChart = display_growth_chart(patientGrowth, '#meucanvas' , 'wfa_boys_0_to_5',null,xxMin);
  </script>
</body>
</html>