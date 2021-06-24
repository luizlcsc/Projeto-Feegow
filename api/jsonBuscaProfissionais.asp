<!--#include file="../connect.asp"-->
<!--#include file="../Classes/Json.asp"-->
<%
lat = req("Lat")
lng = req("Lng")
raioBusca = req("raioBusca")
limitarProfissionais = req("limitarProfissionais")&""

if isnumeric(raioBusca) then
    raioBusca = ccur(raioBusca)
end if

sql = "SELECT id, IF(ISNULL(NomeSocial) OR NomeSocial='', NomeProfissional, NomeSocial) NomeProfissional, "&_
      "  ROUND(( 3959 * acos( cos( radians("&lat&") ) "&_
      "        * cos( radians( SUBSTRING_INDEX(Coordenadas,',',1) ) ) "&_
      "        * cos( radians( SUBSTRING_INDEX(Coordenadas,',',-1) ) - radians("&lng&") ) "&_
      "        + sin( radians("&lat&") ) "&_
      "        * sin( radians( SUBSTRING_INDEX(Coordenadas,',',1) ) ) ) ),2) AS Distance "&_
      " FROM profissionais "&_
      " WHERE sysActive=1 "&limitarProfissionais&_
      " HAVING distance < "&treatvalzero(raioBusca)&" "&_
      " ORDER BY distance ASC "

set ProfissionaisdesSQL = db.execute(sql)
responseJson(recordToJSON(ProfissionaisdesSQL))
%>