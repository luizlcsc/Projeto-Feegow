<!--#include file="connect.asp"-->
<form method="post" action="" name="frmModal" id="frmModal">
<div class="modal-header">
    <h4>Fun&ccedil;&otilde;es para Repasse - <%=Titulo%></h4>
</div>
<div class="modal-body">
    <div class="row">
	    <div class="col-md-2">

            <div class="btn-group">
            <button class="btn btn-sm btn-primary dropdown-toggle" data-toggle="dropdown"><i class="far fa-plus"></i> Adicionar <i class="far fa-angle-down icon-on-right"></i></button>
            <ul class="dropdown-menu dropdown-danger">
            <li><a href="javascript:adicionaItem('Adicionar', 0, 'F')">Fun&ccedil;&atilde;o ou regra</a></li>
            <li><a href="javascript:adicionaItem('Adicionar', 0, 'M')">Material ou medicamento</a></li>
            <li id="divMedkit"><a href="javascript:adicionaItem('Adicionar', 0, 'K')"><i class="far fa-medkit"></i> Materiais vinculados ao procedimento, caso haja</a></li>
            <li id="divEstoque"><a href="javascript:adicionaItem('Adicionar', 0, 'Q')"><i class="far fa-medkit"></i> Materiais baixados no estoque</a></li>
            <li id="divUsers"><a href="javascript:adicionaItem('Adicionar', 0, 'E')"><i class="far fa-users"></i> Equipe vinculada ao procedimento, caso haja</a></li>
            </ul>
            </div>

        </div>
    </div>

    <div class="row" id="FuncoesRateio">
        <%server.Execute("FuncoesRateio.asp")%>
    </div>
</div>