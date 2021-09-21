<!--#include file="connect.asp"-->
<%
set reg = db.execute("select * from recibos where Texto like '"&refhtml("TextoRecibo")&"' and PacienteID="&req("I"))
if reg.EOF then
	'db_execute("insert into recibos (Nome, Emitente, Data, Valor, Texto, Servicos, PacienteID, sysUser, ImpressoEm) values ('"&ref("NomeRecibo")&"', '"&ref("EmitenteRecibo")&"', '"&mydate(ref("DataRecibo"))&"', '"&treatVal(ref("ValorRecibo"))&"', '"&ref("TextoRecibo")&"', '"&ref("ServicosRecibo")&"', '"&req("I")&"', "&session("User")&", now())")
	db_execute("insert into recibos (Nome, Emitente, Data, Valor, Texto, Servicos, PacienteID, sysUser, ImpressoEm) values ('"&ref("NomeRecibo")&"', '"&ref("EmitenteRecibo")&"', '"&mydate(ref("DataRecibo"))&"', '"&treatVal(ref("ValorRecibo"))&"', '"&refhtml("TextoRecibo")&"', '"&ref("ServicosRecibo")&"', '"&req("I")&"', "&session("User")&", now())")
	set reg = db.execute("select * from recibos where PacienteID="&req("I")&" order by id desc LIMIT 1")
end if
%>
<div class="modal-body">
    <div class="row">
        <div class="col-md-10">
        <%
			src="Recibo.asp?ReciboID="&reg("id")
		%>
        <iframe width="100%" height="600px" src="<%=src%>" id="ImpressaoRecibo" name="ImpressaoRecibo" frameborder="0"></iframe>
        </div>
        <div class="col-md-2">
            <button class="btn btn-sm btn-success btn-block" data-dismiss="modal">
                <i class="far fa-remove"></i>
                Fechar
            </button>
        </div>
    </div>
</div>
<div class="modal-footer no-margin-top">
	
	    
</div>
