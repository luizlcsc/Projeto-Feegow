<!--#include file="connect.asp"-->

<%
inputStringList = ref("inputs")
inputList = split(inputStringList, ", ")

listProfissionalId = array()
listExecutadoProcedimento = array()
for each key in inputList
	ReDim Preserve listProfissionalId(UBound(listProfissionalId) + 1)
	listProfissionalId(UBound(listProfissionalId)) = ref("ProfissionalID"&key)

	ReDim Preserve listExecutadoProcedimento(UBound(listExecutadoProcedimento) + 1)

	executado = "N"
	if ref("Executado"&key) <> "" Then
		executado = ref("Executado"&key)
	end If

	listExecutadoProcedimento(UBound(listExecutadoProcedimento)) = executado
next

stringProcedimentosExecutados = Join(listExecutadoProcedimento, ",")
achouProcedimento = InStr(stringProcedimentosExecutados, "N")

Set myDict = Server.CreateObject("Scripting.Dictionary")
For Each elem In listProfissionalId
    If Not myDict.Exists(elem) Then
		myDict.Add elem, elem
	end if
Next
%>

<%
if req("ReciboID") <> "" then
ReciboID =req("ReciboID")

sqlrepasse = "select "&_
            " r.NumeroRPS,"&_
            " r.RepasseIDS,"&_
            " r.Cnpj,"&_
            " r.Nome,"&_
            " r.InvoiceID,"&_
            " r.ContaCredito,"&_
            " r.RPS,"&_
            " r.Valor,"&_
            " r.Auto,"&_
            " r.Texto, "&_
            " r.PacienteID "&_
            " FROM recibos as r WHERE r.id="&ReciboID
set ReciboSQL = db.execute(sqlrepasse)
if not ReciboSQL.eof then
    if ReciboSQL("Texto")&""="" then
    NumeroRps = ReciboSQL("NumeroRPS")
    repasseIds = ReciboSQL("RepasseIDS")
    Cnpj = ReciboSQL("Cnpj")
    RPS = ReciboSQL("RPS")
    RepasseNome = ReciboSQL("Nome")
    RepasseInvoiceID = ReciboSQL("InvoiceID")
    ValorEmpresa = ReciboSQL("Valor")
    ContaCredito = ReciboSQL("ContaCredito")
    PacienteID =  ReciboSQL("PacienteID")
    Auto =  ReciboSQL("Auto")
    profissionalExecutanteId="0"
    ModeloColuna="RPSModelo"

    if isnull(ContaCredito) then
        ContaCredito="0"
    end if

        if ContaCredito="0" then
            if Auto then
                ModeloColuna="RecibosIntegrados"
                profissionalExecutanteId=""
            end if
            %>
        <script>
                getUrl("ifrReciboIntegrado.asp", {ReciboID:'<%=ReciboID%>',NumeroRps:'<%=NumeroRps%>', RepasseIds:'',Cnpj:'<%=Cnpj%>', RPS: '<%=RPS%>' ,NomeRecibo:'<%=RepasseNome%>', ModeloColuna:'<%=RPSModelo%>', I:'<%=RepasseInvoiceID%>', ProfissionalID: '<%=profissionalExecutanteId%>', ValorRecibo:'<%=ValorEmpresa%>', PacienteID:'<%=PacienteID%>'});
        </script>
            <%
        else
            if isnull(ContaCredito) then
                AssociacaoID = ""
                ContaID = ""
            else
                ContaSplit = split(ContaCredito, "_")
                AssociacaoID = ContaSplit(0)
                ContaID = ContaSplit(1)
            end if
             %>
        <script>
                getUrl("ifrReciboIntegrado.asp", {ReciboID:'<%=ReciboID%>',NumeroRps:'<%=NumeroRps%>', RepasseIds:'<%=repasseIds%>',Cnpj:'<%=Cnpj%>', RPS: '<%=RPS%>' ,NomeRecibo:'<%=RepasseNome%>', ModeloColuna:'ReciboHonorarioMedico', I:'<%=RepasseInvoiceID%>', ProfissionalID: '<%=ContaID%>', AssociacaoID: '<%=AssociacaoID%>' , tipoProfissionalSelecionado:'<%=AssociacaoID%>' , ValorRecibo:'<%=ValorEmpresa%>', PacienteID:'<%=PacienteID%>'});
        </script>

            <%
        end if

    end if
end if

%>
<script>

        gtag('event', 'recibo_impresso', {
            'event_category': 'recibos',
            'event_label': "Recibos > Imprimir",
        });

        function setIframeSrc() {
        var s = "relatorio.asp?TipoRel=ImprimeRecibo&Imprimiu=1&I=<%= req("ReciboID") %>";
        var iframe1 = document.getElementById('iframe1');
        iframe1.src = s;
        // if (window.stop) {
        //     window.stop();
        // } else {
        //     document.execCommand('Stop'); // MSIE
        // }
        }
        setTimeout(setIframeSrc, 600);
</script>
	<iframe id="iframe1" width="100%" height="500"  frameborder="0"></iframe>
	<% response.end %>
<% elseif (myDict.Count <= 1) or (myDict.Count <= 1 and achouProcedimento = "0") then %>
	<iframe width="100%" height="500" src="relatorio.asp?Imprimiu=1&TipoRel=ifrReciboIntegrado&I=<%= req("I") %>" frameborder="0"></iframe>
	<% response.end %>
<% end if %>

<script>
$(".close", $("#modal-components")).click();
</script>
<div class="modal-header">
	<h1 class="lighter blue">Impressão de Recibo</h1>
</div>
<div class="modal-body">
    <p>Selecione abaixo qual executante deseja visualizar no recibo.</p>
    <div class="main-impressao">
        <% For Each element In myDict.items() %>
            <div>
                <label class="radio-custom radio-primary">
                    <input type="radio" class="ace" id="profisionalId<%=myDict.item(element)%>" name="profisionalId" onclick="relatorio(this)" value="<%=myDict.item(element)%>" /><label for="profisionalId<%=myDict.item(element)%>">
                    <%
                    val = myDict.item(element)

                    if val&"" = "" then
                        response.write("Não executado")
                    elseif instr(val, "_")>0 then
                        response.write(accountName("", val))
                    end if
                    %>
                    </label></label>
            </div>
        <% next %>
        <div>
            <label class="radio-custom radio-primary">
                <input type="radio" class="ace" id="profisionalId0" name="profisionalId" onclick="relatorio(this)" value="0" /><label for="profisionalId0"> Todos</label></label>
        </div>
	</div>
    <div class="naoprocessado">

    </div>
	<iframe style="display:none;" id="iframeprint"></iframe>
</div>

<script>



$("#modal-table").modal();

profissionalList = document.querySelectorAll("[id^=ProfissionalID]")[0];


function validaExecutante() {
    $("#profisionalId").parent().parent().show()
    if(!($('.checkbox-executado:not(:checked)').length > 0)){
        $("#profisionalId").parent().parent().hide()
    }
}

function listarNaoExecutado() {
  var procedimentos = [];
  $('[data-id]:not(.div-execucao)').each((key,tag) =>{
       let keyProcedimentoAdicionado = $(tag).attr("data-id");
       let tagProcedimento = $(tag).find('select[data-resource="procedimentos"] option:selected');
       let executado = $(tag).find('.checkbox-executado').prop('checked');
       let valor = $('#sub'+keyProcedimentoAdicionado).html();
       let tagProfissional = $('#row2_'+keyProcedimentoAdicionado+' select[id^="ProfissionalID"] option:selected');

  	 if(keyProcedimentoAdicionado >= 0 && (!executado)){
  		procedimentos.push({
  			 key: keyProcedimentoAdicionado,
  			 procedimento: tagProcedimento.html() + ` (${valor})`
  		 });
  	 }
  });

  var selectProfissionais = $('select[id^="ProfissionalID"]').html();

  checkboxes = procedimentos.map((item) => {
      return `
      <div>
          <label class="checkbox-custom checkbox-primary">
              <input type="checkbox" checked class="ace" name="procedimentoNaoExecutado" id="procedimentoNaoExecutado_${item.key}"
              value="${item.key}" /><label for="procedimentoNaoExecutado_${item.key}">${item.procedimento}</label></label>
      </div>
      `;
  }).join("\n");


  html = `      <div class="row">
                    <div class="col-md-6">
                        <h3>Profissionais</h3>
                        <select class="form-control" id="profissinalParaProcedimentoNaoExecutado" >
                            ${selectProfissionais}
                        </select>
                    </div>
                    <div class="col-md-6">
                        <h3>Procedimentos</h3>
                        ${checkboxes}
                    </div>
                </div>
                <div  class="row">
                    <div class="col-md-6 text-left">
                        <button class="btn btn-default" type="button" onclick='$(".main-impressao").show();$(".naoprocessado").html("");'>Voltar</button>
                    </div>
                    <div class="col-md-6 text-right">
                        <button class="btn btn-success" type="button"  onclick="relatorio(this)" value="Gerar">Gerar</button>
                    </div>
                </div>
`;
    return html;
}

for (key in profissionalList.options ) {
	if(profissionalList.options[key].value == undefined){
		continue;
	}

    elementInputRadio = document.getElementById(`profisionalId${profissionalList.options[key].value}`)

	if(elementInputRadio == null){
		continue;
	}

	listProfissionalReciboRadioLabel = document.querySelectorAll(`input[id='profisionalId${profissionalList.options[key].value}'`)
	for (key2 in listProfissionalReciboRadioLabel) {
		if (listProfissionalReciboRadioLabel[key2].nextSibling == undefined) {
			continue;
		}

		listProfissionalReciboRadioLabel[key2].nextSibling.textContent = profissionalList.options[key].text;
		if(profissionalList.options[key].value == "") {
			listProfissionalReciboRadioLabel[key2].nextSibling.textContent = "Não executado"
		}
	}
}


relatorio = (self) => {


    if(self.value === ""){
        $(".naoprocessado").html(listarNaoExecutado());
        $(".main-impressao").hide();
        return ;
    }
	let pro = (self.value == "") ? "N" : "S";

	var profissionalSelecionado = self.value.substr(2);
	var tipoProfissionalSelecionado = self.value.substr(0,1);

	let procedimentosStr = "";
    let profissionalParaNaoProcessado = "";
	if(self.value === "Gerar"){
        pro = "X";
        profissionalSelecionado = "";
        profissionalParaNaoProcessado = $("#profissinalParaProcedimentoNaoExecutado").val().substr(2);
        tipoProfissionalSelecionado   = $("#profissinalParaProcedimentoNaoExecutado").val().substr(0,1);
        procedimentos = [];
        $("[name=procedimentoNaoExecutado]:checked").each((key,item) => {
            procedimentos.push($(item).val());
        });

        procedimentosStr = procedimentos.join(",");
    }

    var url = `relatorio.asp?TipoRel=ifrReciboIntegrado&Imprimiu=1&I=<%=req("I")%>&tipoProfissionalSelecionado=${tipoProfissionalSelecionado}&profissionalSelecionado=${profissionalSelecionado}&executouProcedimento=${pro}&procedimentos=${procedimentosStr}&profissionalParaNaoProcessado=${profissionalParaNaoProcessado}`;

	if(profissionalSelecionado=="0"){
        url = `relatorio.asp?TipoRel=ifrReciboIntegrado&Imprimiu=1&I=<%=req("I")%>`;
	}

	fetch(url,
		{
			method: "post"
		})    .then(response => {
					response.text().then((content) => {
						const regex = /<body>(.*?)<\/body>/sgmiu;
						let result = content.match(regex);

						var link = document.createElement('link');
						link.setAttribute('rel', 'stylesheet');
						link.setAttribute('type', 'text/css');
						link.setAttribute('href', 'css/bootstrap.min.css');

						document.getElementById('iframeprint').contentWindow.document.head.appendChild(link);

						setTimeout( () => {
							document.getElementById('iframeprint').contentWindow.document.body.innerHTML = content;
							document.getElementById('iframeprint').contentWindow.focus() ;
							document.getElementById('iframeprint').contentWindow.print() ;
						}, 100);

					}).catch((errorText) => {

					});
				});
}
validaExecutante();
</script>

