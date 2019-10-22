<!--#include file="connect.asp"-->
<%
CampoID = req("CampoID")
FormPID = req("FormPID")

set pCampo = db.execute("select * from buicamposforms where id="&CampoID)
Rotulo = pCampo("RotuloCampo")
ValorPadrao = pCampo("ValorPadrao")
%>
<!DOCTYPE html>
<meta charset="utf-8">
<link rel="stylesheet" type="text/css" media="all" href="assets/css/curva.css" />
<body>
  <script src="assets/js/grafico.js"></script>
  <script>
  <%
  if FormPID="" or not isnumeric(FormPID) then
    %>
    var patientGrowth = '';
    <%
  else
  	%>
	var patientGrowth = [
	<%
	set vals = db.execute("select * from buicurva where FormPID="&FormPID&" and CampoID="&CampoID&" and not isnull(Meses) and not isnull(Valor) order by Meses")
	if not vals.EOF then
		set pac = db.execute("select id, Sexo from pacientes where id="&vals("PacienteID"))
		if not pac.eof then
			Sexo = pac("Sexo")
		end if
	end if
	while not vals.eof
	%>
		[<%=vals("Meses")%>, <%=replace(vals("Valor"), ",", ".")%>],
	<%
	vals.movenext
	wend
	vals.close
	set vals = nothing
	%>
	];
    <%
  end if
  
  if Sexo<>2 or isnull(Sexo) or Sexo="" or Sexo=0 then
  	Sexo=1
  end if
  Tabela = ValorPadrao&Sexo
  %>

var wfa_all_0_to_5_meta = {
    "lines": [ {
      "tag":"SD2",
      "name":"p 97"
    }, {
      "tag":"SD1",
      "name":"p 85"
    },{
      "tag":"SD0",
      "name":"p 50"
    }, {
      "tag":"SD1neg",
      "name":"p 15"
    }, {
      "tag":"SD2neg",
      "name":"p 3"
    }
	]
};

var wfa_boys_0_to_5_meta = {};
wfa_boys_0_to_5_meta.lines =  wfa_all_0_to_5_meta.lines.slice();
wfa_boys_0_to_5_meta.title = "<%=Rotulo%>";


var wfa_boys_0_to_5_zscores = [
<%
set c = db.execute("select * from curva."&Tabela)
while not c.eof
%>
{"Month":"<%=c("Month")%>","SD0":"<%=c("SD0")%>","SD1":"<%=c("SD1")%>","SD2":"<%=c("SD2")%>","SD3":"<%=c("SD3")%>","SD1neg":"<%=c("SD1neg")%>","SD2neg":"<%=c("SD2neg")%>","SD3neg":"<%=c("SD3neg")%>"},
<%
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

<script src="curva<%=ValorPadrao%>.asp"></script>
<script>
  var growthChart = display_growth_chart(patientGrowth, 'body' , 'wfa_boys_0_to_5');
  </script>
</body>
</html>