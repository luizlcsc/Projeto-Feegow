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
<div id="pagar" style="display:none; background-color:#fff; border:#ccc 1px solid; width:900px; position:<%=posModalPagar%>; top:100px; left:20px; z-index:10000; box-shadow:#000000 15px;-webkit-box-shadow: 0px 0px 10px 0px rgba(0,0,0,0.48);
-moz-box-shadow: 0px 0px 10px 0px rgba(0,0,0,0.48);
box-shadow: 0px 0px 10px 0px rgba(0,0,0,0.48); border-radius:5px;">
	Carregando...
</div>
