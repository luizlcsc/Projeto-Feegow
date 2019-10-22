<%
	set subCampos = db.execute("select c.*, f.LadoALado from buicamposforms c LEFT JOIN buiforms f on f.id=c.FormID where c.FormID="&I&" and c.GrupoID="&CampoID&" order by c.Ordem")
	while not subCampos.eof
	  TipoCampoID = subCampos("TipoCampoID")
	  RotuloCampo = subCampos("RotuloCampo")
	  Checado = subCampos("Checado")
	  CampoID = subCampos("id")
	  Texto = subCampos("Texto")
	  pTop = subCampos("pTop")
	  pLeft = subCampos("pLeft")
	  Colunas = subCampos("Colunas")
	  Linhas = subCampos("Linhas")
	  LadoALado = subCampos("LadoALado")
	  Ordem = subCampos("Ordem")
	  if UsarPreenchido="S" and (TipoCampoID<>13) then
	      ValorPadrao = f(""&CampoID&"")
	  else
		  ValorPadrao = subCampos("ValorPadrao")
	  end if
	  GrupoID = subCampos("GrupoID")
	  Largura = subCampos("Largura")
%><!--#include file="formsCompiladorSubcampoPreenchido.asp"--><%
	subCampos.movenext
	wend
	subCampos.close
	set subCampos=nothing
	%>