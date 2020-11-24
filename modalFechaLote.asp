<!--#include file="connect.asp"-->
<form method="post" action="" name="frmModal" id="frmModal">
<%
set ult = db.execute("select Lote from tisslotes order by Lote desc limit 1")
if ult.eof then
	Lote=1
else
	Lote = ult("Lote")+1
end if

ConvenioID=req("ConvenioID")

set ConvenioSQL = db.execute("SELECT DiasRecebimento, DataRecebimentoEspecifico FROM convenios WHERE id="&treatvalzero(ConvenioID))

if not ConvenioSQL.eof then
    DiasRecebimento=ConvenioSQL("DiasRecebimento")
    DataRecebimentoEspecifico=ConvenioSQL("DataRecebimentoEspecifico")

	DateFormat = split(date(), "/")
	Dia = cint(DateFormat(0))

	if DataRecebimentoEspecifico&"" <> "" AND  DataRecebimentoEspecifico > Dia then
		Dia = DataRecebimentoEspecifico
		Mes = DateFormat(1)
		Ano = DateFormat(2)
		if isDate(Dia&"/"&Mes&"/"&Ano) then
			DataPrevisao = Dia&"/"&Mes&"/"&Ano
		end if
	else
		Dia = DataRecebimentoEspecifico
		if DateFormat(1) = 12 then
			Mes = 1
		else 
			Mes = DateFormat(1) + 1
		end if
		Ano = DateFormat(2)
		if isDate(Dia&"/"&Mes&"/"&Ano) then
			DataPrevisao = Dia&"/"&Mes&"/"&Ano
		end if
	end if

    if DiasRecebimento&"" <> "" then
        if isnumeric(DiasRecebimento) then
            DataPrevisao = DateAdd("d", DiasRecebimento, date())
        end if
    end if
end if

%>
	<div class="modal-header">
    	<h4>Fechar Lote</h4>
    </div>
    <div class="modal-body">
    	<div class="row">
           	<%=quickfield("text", "Lote", "N&deg; do Lote", 2, Lote, "text-right", "", "")%>
        	<div class="col-md-3">
            	<label>Refer&ecirc;ncia</label><br />
            	<select class="form-control" name="Mes">
                	<%
					c=0
					while c<12
						c=c+1
						%><option value="<%=c%>"<%if c=month(date()) then%> selected="selected"<%end if%>><%=monthname(c)%></option><%
					wend
					%>
                </select>
            </div>
            <div class="col-md-2">
            	<label>&nbsp;</label><br />
            	<select name="Ano" class="form-control">
                	<%
					c=year(date())-1
					while c<year(date())+2
						%><option value="<%=c%>"<%if c=year(date()) then%> selected="selected"<%end if%>><%=c%></option><%
						c=c+1
					wend
					%>
                </select>
            </div>
            <div class="col-md-4">
            	<label>Ordenar por</label><br />
            	<select name="Ordem" class="form-control">
					<option value="Data">Data do Preenchimento</option>
					<option value="Numero">N&uacute;mero da Guia</option>
					<option value="Paciente">Nome do Paciente</option>
					<option value="Solicitacao">Data da Solicitação</option>
                </select>
            </div>
            <div class="col-md-4">
                <label for="LoteObs">Observações</label>
                <textarea name="Obs" id="LoteObs" class="form-control"></textarea>
            </div>

            <%=quickfield("datepicker", "PrevisaoRecebimento", "Previsão de recebimento ", 3, DataPrevisao, "", "", "")%>

        </div>
    </div>
<div class="modal-footer">
	<button class="btn btn-success btn-sm"><i class="fa fa-save"></i> Fechar este Lote de Guias</button>
    <button class="btn btn-sm btn-default" data-dismiss="modal">
    	<i class="fa fa-remove"></i> Cancelar</button>
    </button>
</div>
</form>
<script language="javascript">
<!--#include file="jQueryFunctions.asp"-->
$("#frmModal").submit(function(){
	$.ajax({
		   type:"POST",
		   url:"saveLote.asp?Acao=Inserir&T=<%=request.QueryString("T")%>&ConvenioID=<%=request.QueryString("ConvenioID")%>",
		   data:$("#frmModal, #guias").serialize(),
		   success:function(data){
			   eval(data);
		   }
		   });
	return false;
});
</script>