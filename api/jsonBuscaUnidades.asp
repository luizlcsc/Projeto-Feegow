<!--#include file="../connect.asp"-->
<!--#include file="../Classes/Json.asp"-->
<%
lat = req("Lat")
lng = req("Lng")
unidadeId = req("UnidadeID")

sql = "SELECT u.id, u.NomeFantasia, u.Bairro ,"&_
      "  ROUND(( 3959 * acos( cos( radians("&lat&") ) "&_
      "        * cos( radians( u.Latitude ) ) "&_
      "        * cos( radians( u.Longitude ) - radians("&lng&") ) "&_
      "        + sin( radians("&lat&") ) "&_
      "        * sin( radians( u.Latitude ) ) ) ),2) AS Distance "&_
      "  "&_
      " FROM sys_financialcompanyunits u "&_
      " WHERE u.sysActive=1 "&_
      " HAVING distance < 10 "&_
      " ORDER BY distance ASC "&_
      " LIMIT 4 "

set UnidadesSQL = db.execute(sql)

responseJson(recordToJSON(UnidadesSQL))
%>