<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!--#include file="jwt/build/jwt.all.asp" -->

<script language="javascript" runat="server">
function getJwt(){
  var token = new jwt.WebToken('{"licenseId": <%=replace(session("Banco"),"clinic","")%>, "userId": <%=session("User")%>, "datetime": "<%=now()%> <%=time()%>"}', '{"typ":"JWT", "alg":"HS256"}');
  var signed = token.serialize("F33G0W$@CL1N1Cm3ASFASFADFFQ144134ywiuhjsdg");
  return signed;
}

</script>
<script>
	localStorage.setItem("tk", "<%=GetJwt()%>");
</script>