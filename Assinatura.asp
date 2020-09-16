<!-- #include file = "connect.asp" -->
<!-- #include file = "UploadFuncoes.asp" -->

<%
ProfissionalID = req("ProfissionalID")
if req("X")="S" then
    db.execute("update profissionais set Assinatura='' where id="& ProfissionalID)
end if
%>