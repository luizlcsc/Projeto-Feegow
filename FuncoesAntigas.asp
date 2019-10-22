<%
function SepDat(DataJunta)
                if isnumeric(DataJunta) and len(DataJunta)=8 then
				DataSeparada=right(DataJunta,2)&"/"&mid(DataJunta,5,2)&"/"&left(DataJunta,4)
				DataSeparadaEn=mid(DataJunta,5,2)&"/"&right(DataJunta,2)&"/"&left(DataJunta,4)
				SepDat=DataSeparada
				end if
end function
function ExiVal(ValExiAtu)
				if isnull(ValExiAtu) then
				ValExiAtu="0"
				end if
				if ccur("1,00")=100 then
				ExiVal=replace(ValExiAtu,",","@")
				ExiVal=replace(Exival,".",",")
				ExiVal=replace(Exival,"@",".")
				else
				ExiVal=ValExiAtu
				end if
end function
function DatDate(DataJunta)
                if isnumeric(DataJunta) and len(DataJunta)=8 then
				DataSeparada=right(DataJunta,2)&"/"&mid(DataJunta,5,2)&"/"&left(DataJunta,4)
				DataSeparadaEn=mid(DataJunta,5,2)&"/"&right(DataJunta,2)&"/"&left(DataJunta,4)
					if day("01/02/2000")=1 then
					DatDate=DataSeparada
					else
					DatDate=DataSeparadaEn
					end if
				end if
end function
function JunDat(DataSeparada)
				if isdate(DataSeparada) then
				varDt = DataSeparada
				ValFunDat = split(varDt,"/")
				c=1
					for r = 0 to uBound(ValFunDat) 
						if c=1 then rfDia=ccur(ValFunDat(r)) end if
						if c=2 then rfMes=ccur(ValFunDat(r)) end if
					c=c+1
					rfAno=year(DataSeparada)
					next
					if rfDia<10 then rfDia="0"&rfDia end if
					if rfMes<10 then rfMes="0"&rfMes end if
				JunDat="'"&rfAno&rfMes&rfDia&"'"
				else
				JunDat="null"
				end if
end function
function JunDatSp(DataSeparada)
				if isdate(DataSeparada) then
				varDt = DataSeparada
				ValFunDat = split(varDt,"/")
				c=1
					for r = 0 to uBound(ValFunDat) 
						if c=1 then rfDia=ccur(ValFunDat(r)) end if
						if c=2 then rfMes=ccur(ValFunDat(r)) end if
					c=c+1
					rfAno=year(DataSeparada)
					next
					if rfDia<10 then rfDia="0"&rfDia end if
					if rfMes<10 then rfMes="0"&rfMes end if
				JunDatSp=rfAno&rfMes&rfDia
				else
				JunDatSp=""
				end if
end function
%>