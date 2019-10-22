<!--#include file="connect.asp"-->
<head>
  <link type="text/css" rel="stylesheet" href="assets/js/qtip/jquery.qtip.css" />
  <link rel="shortcut icon" href="icon_clinic.png" type="image/x-icon" />
  <link rel="stylesheet" href="assets/css/font-awesome.min.css" />

  <link href="assets/css/coreBoot.css" rel="stylesheet" type="text/css" />

  <script type="text/javascript" src="assets/js/jquery.min.js"></script>
  <script type="text/javascript" src="ckeditornew/ckeditor.js"></script>
  <script src="ckeditornew/adapters/jquery.js"></script>
  <link rel="stylesheet" type="text/css" href="assets/skin/default_skin/css/fgw.css">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">

</head>
<body>
<div class="container">
  <div class="row">
      <div class="col-md-12 pt20">


<%
response.Charset="utf-8"

LicencaID= replace(req("L"),"AAAW-","") / 987
Licenca = "clinic"&LicencaID
AtestadoID = req("I") /99999

set LicencaSQL = db.execute("SELECT id FROM cliniccentral.licencas WHERE id="&LicencaID)

if LicencaSQL.eof then
  erro = 1
else
  AtestadoID = replace(AtestadoID,",",".")
  if req("Validar")="1" then
    db_execute("update "&Licenca&".pacientesatestados SET ValidadoEm=NOW() WHERE ValidadoEm IS NULL AND id='"&AtestadoID&"'")
  end if
  set AtestadoSQL = db.execute("SELECT a.*,p.NomePaciente FROM "&Licenca&".pacientesatestados a LEFT JOIN pacientes p ON p.id = a.PacienteID WHERE a.id='"&AtestadoID&"'")

  if AtestadoSQL.eof then
        erro=1
  else
      if not isnull(AtestadoSQL("ValidadoEm")) then
          ValidadoEm = AtestadoSQL("ValidadoEm")

          %>
          <div class="alert alert-danger">
              <em>Atenção!</em> Atestado validado em <%=ValidadoEm%>.
          </div>
          <%
      else
      %>
          <div class="alert alert-success">
              <em>Sucesso!</em> Atestado válido.
          </div>

            <div class="row">
                <div class="col-md-offset-4 col-md-4 col-xs-12">
                    <form action="">
                        <input type="hidden" name="Validar" value="1">
                        <input type="hidden" name="I" value="<%=req("I")%>">
                        <input type="hidden" name="L" value="<%=req("L")%>">
                        <input type="hidden" name="F" value="<%=req("F")%>">
                      <button class="btn btn-primary btn-lg btn-block mb20" id="btnValidar">VALIDAR ATESTADO!</button>
                    </form>
                </div>
            </div>

      <%
      end if
      %>
      <div class="panel">
          <div class="panel-heading">
              <%=AtestadoSQL("Titulo")%>
          </div>
          <div class="panel-body">
                <h3>Paciente: <%=AtestadoSQL("NomePaciente")%></h3>
                <h4>Data: <%=AtestadoSQL("Data")%></h4>
              <%=AtestadoSQL("Atestado")%>
          </div>
      </div>
      <%

  end if
end if

if erro=1 then
  %>
  <div class="alert alert-warning">
      <em>Atenção!</em> Nenhum atestado localizado.
  </div>
  <%
end if
%>
      </div>
  </div>
</div>
</body>