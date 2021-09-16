<style>
        .slinha td {
            background-color: #fff !important;
            border-top: #fff 2px solid !important;
        }

        .ulinha {
            background-color: #f7f7f7 !important;
        }

            .ulinha td {
                border-top: #ccc 2px groove !important;
                background-color: #f7f7f7 !important;
            }

        .detalheMetodo {
            display: none;
        }
        /*
    .table-fixed thead {
      width: 97%;
    }
    .table-fixed tbody {
      height: 230px;
      overflow-y: auto;
      width: 100%;
    }
    .table-fixed thead, .table-fixed tbody, .table-fixed tr, .table-fixed td, .table-fixed th {
      display: block;
    }
    .table-fixed tbody td, .table-fixed thead > tr> th {
      float: left;
      border-bottom-width: 0;
      font-size:11px;
    }
    */
        .tbConta {
            height: 300px;
            overflow-y: scroll;
            width: 100%;
        }

        label {
            font-size: 10px !important;
        }

        input.ace[type="checkbox"] + .lbl, input.ace[type="radio"] + .lbl {
            line-height: inherit !important;
            min-height: inherit !important;
        }
</style>
<%
if posModalPagar="" then
    posModalPagar="absolute"
end if
%>
<div id="pagar" style=" position:<%=posModalPagar%>; " class="modal-pagar">
	Carregando...
</div>
