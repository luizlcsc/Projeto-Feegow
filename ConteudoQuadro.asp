<!--#include file="connect.asp"-->
	<table width="100%" border="0">
    	<tr>
        <%
		existemQuadros="N"
		set pUs=db.execute("select QuadrosAbertos from sys_users where id="&session("User"))
		if isnull(pUs("QuadrosAbertos")) then varCheck2=" " else varCheck2=pUs("QuadrosAbertos") end if
		valor2=split(varCheck2,", ")
		for i=0 to uBound(valor2)
			set pLoc=db.execute("select * from Locais where id = '"&valor2(i)&"'")
			if not pLoc.EOF then
			  if (instr(session("Unidades"), "|0|")>0 or instr(session("Unidades"), "|"&pLoc("UnidadeID")&"|")>0) then
				narr=1
				strInt=""
				while narr<8
					if isNull(pLoc("d"&narr)) or not isNumeric(pLoc("d"&narr)) then d=Intervalo else d=pLoc("d"&narr) end if
					strInt=strInt&","&d
					narr=narr+1
				wend
				existemQuadros="S"
				locUlt="U"&pLoc("id")
				chamaQuadros=chamaQuadros&"chamaQuadro('"&req("Data")&"', '"&pLoc("id")&"', '"&locUlt&"');"
				%>
                <td valign="top">
                    <div class="row">
                        <div class="clearfix form-actions no-padding no-margin">
                            <div class="col-xs-1"><button type="button" value="+" id="<%=pLoc("id")%>" onClick="Aba(this.id);" class="btn btn-xs btn-white"><i class="far fa-cog"></i></button>
                                <div class="caixaEdicao" id="aba<%=pLoc("id")%>" style="display:none">
									<!--#include file="conteudoAbaLocal.asp"-->
		                        </div>
                            </div>
                            <div class="col-xs-11"><%=uCase(pLoc("NomeLocal"))%>
                                <button type="button" value="FECHAR" onClick="location.href='?P=NovoQuadro&Pers=1&Rx=<%=pLoc("id")%>&Data=<%=req("Data")%>';" class="btn btn-xs btn-white">
                                <i class="far fa-remove"></i>
                                </button>
                            </div>
                            <div class="Quadro" id="q<%=pLoc("id")%>">
                            <%
                                LocalID=pLoc("id")
                                Horario=QuaDisDe
                                HorarioFinal=QuaDisA
                                'Intervalo=pqd("QuaDisIntervalo")
                            %>
	                        </div>
					    	<!--#include file="mioloGradeQuadro.asp"-->
		                </div>
            	    </div>
                </td>
        		<%
			  end if
			end if
		next
		if chamaQuadros<>"" then
			chamaQuadros=replace(chamaQuadros,locUlt,"S")
		end if
		%>
        </tr>
    </table>
