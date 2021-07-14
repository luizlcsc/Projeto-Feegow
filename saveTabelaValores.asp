<!--#include file="connect.asp"-->
<!--#include file="Classes/Logs.asp"-->
<!--#include file="Classes/JSON.asp"-->
<%
ProcedimentoID  = ref("ProcedimentoID")
TabelaID        = ref("TabelaID")
Valor           = ref("Valor")
ItemID          = ref("ItemID")
ProdutoID       = ref("ProdutoID")
Atuacao         = ref("Atuacao")
msg  = "new PNotify({     title: 'SUCESSO!',     text: 'Regra Aplicada Com sucesso.',     type: 'success',     delay: 3000 });"
Action     =  ref("Action")

 if Action = "buscarValorTabela" then
TabelaID = ref("tabela")

   set HorariosSQL = db.execute("SELECT DISTINCT p.id, p.NomeProcedimento, p.Valor, ptv.TabelaID AS tabela , ptv.Valor AS valorTabela, ptv.tabelabase as tabelabase,    p.TipoProcedimentoID,TipoProcedimento , ptv.itemID  from procedimentos p LEFT JOIN TiposProcedimentos ON TiposProcedimentos.id = p.TipoProcedimentoID  LEFT JOIN procedimentostabelasvalores ptv on (ptv.ProcedimentoID=p.id)  WHERE sysActive=1 and ativo='on' AND  ptv.TabelaID='"&TabelaID&"' order by NomeProcedimento")
   response.write(recordToJSON(HorariosSQL))
   end if   


if Action = "procedimentos" then

sqlTabelaValores = "SELECT COUNT(id) AS Total FROM procedimentostabelasvalores WhERE ProcedimentoID ="&ProcedimentoID&" AND TabelaID="&TabelaID               
set result = db.execute(sqlTabelaValores)
   set   Total = result("Total")
      if Total = "0"  then
      sqlInsert = "insert into procedimentostabelasvalores (ProcedimentoID, TabelaID, Valor , ItemID, tabelaBase) VALUES ("& ProcedimentoID &", "& TabelaID &", "&Valor&" , '"&ItemID&"' , '"&Atuacao&"')"          
      'responsse.write(sqlInsert)
      db.execute(sqlInsert)
         else
      sqlUpdate = "update procedimentostabelasvalores set TabelaID="&TabelaID&" ,Valor="&Valor&" , ItemID='"&ItemID&"' , tabelaBase='"&Atuacao&"' WHERE ProcedimentoID="&ProcedimentoID&" AND TabelaID="&TabelaID
      'response.write(sqlUpdate)
      db.execute(sqlUpdate)

   end if        
   result.movenext            
   result.close
set result=nothing

elseif Action = "Produtos" then
sqlTabelaValores = "SELECT COUNT(id) AS Total FROM procedimentostabelasvalores WHERE TabelaID ='"&TabelaID&"' AND ItemID='"&ItemID&"'"               
set result = db.execute(sqlTabelaValores)
   set   Total = result("Total")
      if Total = "0" then
      sqlInsert = "insert into procedimentostabelasvalores (ProcedimentoID, TabelaID, Valor , ItemID, tabelabase) VALUES ("& ProcedimentoID &", "& TabelaID &", "&Valor&" , '"&ItemID&"' , '"&Atuacao&"')"          
      db.execute(sqlInsert)
      'response.write(sqlInsert)
      else
      sqlUpdate = "update procedimentostabelasvalores set TabelaID="&TabelaID&" ,Valor="& Valor&" , ItemID='"&ItemID&"' , tabelaBase='"&Atuacao&"' WHERE ItemID='"&ItemID&"' AND TabelaID="&TabelaID 
      'response.write(sqlUpdate)
      db.execute(sqlUpdate)
   
   end if        
   result.movenext            
   result.close


   Else

End If


if Action = "BuscarProdutos" then
   
   TabelaBase = ref("tabela")

   set HorariosSQL = db.execute("SELECT * , prod.id as id    ,procedime.Valor as Valor , procedime.itemID as itemID  FROM produtos AS prod    LEFT JOIN procedimentostabelasvalores AS procedime ON (procedime.ItemID = prod.id)WHERE prod.sysActive = 1    AND prod.TipoProduto IN(1,2,3,4,5) OR prod.TipoProduto IN(5) AND  procedime.TabelaID= "&TabelaBase&" ")
   response.write(recordToJSON(HorariosSQL))

 end if 


if Action = "BuscarBase" then
TabelaBase = ref("tabela")

   set HorariosSQL = db.execute("SELECT  prod.id as id ,proc.PrecoPFB as PFB , proc.InicioVigencia as dataInicio , proc.FimVigencia AS dataFim   FROM produtos AS prod   LEFT JOIN produtosvalores AS proc ON (proc.ProdutoID = prod.id)    LEFT JOIN procedimentostabelasvalores AS procedime ON (procedime.ItemID = prod.id) WHERE  (CURDATE() BETWEEN proc.InicioVigencia AND proc.FimVigencia )   AND   proc.TabelaID ="&TabelaBase&" AND proc.Ativo = 1")
   response.write(recordToJSON(HorariosSQL))

 end if 


 if Action = "BuscarValorProduto" then
TabelaBase = ref("tabela")

   set HorariosSQL = db.execute("SELECT * from procedimentostabelasvalores WHERE  TabelaID ="&TabelaBase)
   response.write(recordToJSON(HorariosSQL))

 end if



 if Action = "produtoInicial" then
 sql = "SELECT Atuacao , tabelabase from procedimentostabelas WHERE  id ="&TabelaID
 'response.write(sql)
set HorariosSQL = db.execute(sql)
  response.write(recordToJSON(HorariosSQL))
  end if


 %>

 