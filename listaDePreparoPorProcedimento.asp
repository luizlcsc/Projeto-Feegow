<!--#include file="connect.asp"-->
<!--#include file="Classes/Json.asp"-->
<meta charset="UTF-8">
<style>
    *{font-family: Calibri;}
</style>
<body>
   <div class="modal-body" id="areaImpressao" >
<%
    if req("procedimento") = "" then %>
              <h3>Este procedimento não possui preparo.</h3>
              <script>    print();</script>
    <%
    response.end
    end if

    set procedimentosPreparo = db.execute(" SELECT sys_preparos.Descricao,TextoPreparo,procedimentos.NomeProcedimento,Tipo,coalesce(CombinacaoID,0) as CombinacaoID  ,Horas,Dias,Inicio,Fim FROM procedimentos                  "&chr(13)&_
                                          " LEFT JOIN procedimentospreparofrase ON procedimentos.id = procedimentospreparofrase.ProcedimentoID"&chr(13)&_
                                          " LEFT JOIN sys_preparos ON sys_preparos.id = procedimentospreparofrase.PreparoID"&chr(13)&_
                                          " WHERE procedimentos.id = "&req("procedimento")&" AND (ExcecaoID = 0 or ExcecaoID IS NULL);")

    IF  procedimentosPreparo.EOF THEN %>
        <h3>Este procedimento não possui preparo.</h3>
        <script>    print();</script>
    <%
    response.end
    END IF

    textoPreparo = procedimentosPreparo("TextoPreparo")

    'response.write(textoPreparo)
    'response.write()
    'response.endtextoPreparo
%>
  </div>
</body>
<script>
    let preparos = <%=recordToJSON(procedimentosPreparo) %>;

    let html = `<h3 style="text-align: center">Lista de Preparos do Procedimento "${preparos[0].NomeProcedimento}"</h3>`;
    html += "<%=replaceTags(textoPreparo, req("PacienteId"), session("UserID"), session("UnidadeID"))%>"
    let enumsTipos = {Texto:1,Intervalo: 2,Dia:3,Hora:4};

    let enumsCombinacao = {Default: 0,MaiorQue: 1,MenorQue: 2};

    let combinacoes = {};

    combinacoes[enumsTipos.Texto] = {};
    combinacoes[enumsTipos.Intervalo] = {};
    combinacoes[enumsTipos.Dia] = {};
    combinacoes[enumsTipos.Hora] = {};

    combinacoes[enumsTipos.Texto][enumsCombinacao.Default] = (obj) => {
        return `${obj.Descricao}`;
    };
    combinacoes[enumsTipos.Intervalo][enumsCombinacao.Default] = (obj) => {
        return `${obj.Descricao} com valor entre: ${obj.Inicio} e ${obj.Fim}`;
    };
    combinacoes[enumsTipos.Dia][enumsCombinacao.MaiorQue] = (obj) => {
        return `${obj.Descricao} com valor maior que: ${obj.Dias} dia(s)`;
    };
    combinacoes[enumsTipos.Dia][enumsCombinacao.MenorQue] = (obj) => {
        return `${obj.Descricao} com valor menor que: ${obj.Dias} dia(s)`;
    };
    combinacoes[enumsTipos.Hora][enumsCombinacao.MaiorQue] = (obj) => {
            return `${obj.Descricao} com valor maior que: ${obj.Horas} hora(s)`;
    };
    combinacoes[enumsTipos.Hora][enumsCombinacao.MenorQue] = (obj) => {
        return `${obj.Descricao} com valor menor que: ${obj.Horas} horas(s)`;
    };

    combinacoes[enumsTipos.Texto][enumsCombinacao.MaiorQue]     = combinacoes[enumsTipos.Texto][enumsCombinacao.Default];
    combinacoes[enumsTipos.Texto][enumsCombinacao.MenorQue]     = combinacoes[enumsTipos.Texto][enumsCombinacao.Default];
    combinacoes[enumsTipos.Intervalo][enumsCombinacao.MaiorQue] = combinacoes[enumsTipos.Intervalo][enumsCombinacao.Default];
    combinacoes[enumsTipos.Intervalo][enumsCombinacao.MenorQue] = combinacoes[enumsTipos.Intervalo][enumsCombinacao.Default];

    preparos.forEach((item) => {
        let result = combinacoes[item.Tipo] && combinacoes[item.Tipo][item.CombinacaoID] && combinacoes[item.Tipo][item.CombinacaoID](item);
        html += `<p>${result}</p>`;
    });

    document.getElementById("areaImpressao").innerHTML = html;
    print();
</script>