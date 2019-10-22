﻿    <div class="row">
        <form method="post" id="frmBuscaProduto">
            <%= quickfield("text", "BuscaProduto", "Buscar produto (nome ou código de barras)", 10, "",  "", "", " autocomplete='off' ")%>
            <div class="col-md-2">
                <button class="btn btn-primary btn-block mt20">Buscar</button>
            </div>
        </form>
    </div>
    <div class="row mt10">
        <div class="col-md-12" id="ResultadoBusca">

        </div>
    </div>
    <script type="text/javascript">
        $("#frmBuscaProduto").submit(function () {
            $.post('<%= "buscaProdutoLancto.asp?ItemInvoiceID="& ItemInvoiceID &"&ProdutoInvoiceID="& ProdutoInvoiceID &"&AtendimentoID="& AtendimentoID &"&CD="& req("CD") %>', $(this).serialize(), function (data) {
                $("#ResultadoBusca").html(data);
            });
            return false;
        });

        function Posicao(CD, ProdutoID){
            $.get('<%= "EstoquePosicao.asp?ItemInvoiceID="& ItemInvoiceID &"&ProdutoInvoiceID="& ProdutoInvoiceID &"&AtendimentoID="& AtendimentoID &"&CD="%>' + CD + '&I=' + ProdutoID, function (data) {
                $("#ResultadoBusca").html(data);
            });
        }
        $("#frmBuscaProduto").submit();
    </script>
