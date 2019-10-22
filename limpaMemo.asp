<%
function limpaMemo(txt)
	limpaMemo = txt&" "
	if left(limpaMemo, 1)="{" then
		spl = split(limpaMemo, "\fs2")
		if len(limpaMemo)-len(spl(0))>4 then
			limpamemo = right( limpaMemo, len(limpaMemo)-len(spl(0))-5 )
		end if
	end if
	limpaMemo = replace(replace(replace(replace(replace(replace(replace(replace(limpaMemo, "\f0", "&nbsp;&nbsp;&nbsp;"), "\f1", "&nbsp;&nbsp;&nbsp;"), "{\pntext\f2\'B7\tab}", "&bull;"), "\bullet", "&bull;"), "\f3", ""), "\qc", ""), "\fs24", ""), "\fs20", "")
	limpamemo = replace(replace(replace(replace(replace(replace(replace(limpamemo, "\pard", ""), "\box", ""), "\brdrs", ""), "brdrw20", ""), "brsp20", ""), "\qj", ""), "\b0", "")
	limpaMemo = replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(limpaMemo, "\'e2", "&acirc;"), "\'aa", "a."), "\'ca", "&Ecirc;"), "\'c3", "&Atilde;"), "\'c7", "&Ccedil;"), "\'f3", "&oacute;"), "\'d3", "&Oacute;"), "\'cd", "&Iacute;"), "\'ea", "&ecirc;"), "\'e1", "&aacute;"), "\'f5", "&otilde;"), "\'ba", "&ordf;"), "\'c9", "&Eacute;"), "\'e7", "&ccedil;"), "\'ed", "&iacute;"), "\par", "<br />"), "\'e0", "&agrave;"), "\'fa", "&uacute;"), "\'d5", "&Otilde;"), "\'e3", "&atilde;"), "\'e9", "&eacute;"), "\'f4", "&ocirc;"), "\'c2", "&Atilde;"), "\'da", "&Uacute;"), "\'d4", "&Ocirc;"), "\'c1", "&Aacute;"), "\'b4", "")
	zerados = "\hyphpar0,\s2,\sl360,\slmult1,\tx0,\ul,\keepn,\sa200,\ltrpar,\fs28,\fs16,\qr,\f4,\sl360,\2b0,\fs17,\sb100,\sa100,\sb180,\sb90,\sa90,\sl330,\slmult0,\kerning0,\kerning1,\fs18,\lang22,\lang2070,\i0,\none,\i,\nowidctlpar,\cf1,\fs21,\sl276,\cf0,\fs22,\b"
	splz = split(zerados, ",")
	for i=0 to ubound(splz)
		limpamemo = replace(limpamemo, splz(i), "")
	next
	
	limpaMemo = replace(limpaMemo, "\tab", "&nbsp;&nbsp;&nbsp;")
	limpaMemo = replace(replace(replace(limpaMemo, "\f2", ""), "lang1046", ""), "lang1033", "")
	limpaMemo = replace(limpamemo, "\", "")

	limpaMemo = replace(limpaMemo, "'", "''")
	if len(limpamemo)>6 then
		limpamemo = left(limpamemo, len(limpamemo)-6)
	end if
end function
%>