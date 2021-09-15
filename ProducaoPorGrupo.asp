<!--#include file="connect.asp"-->
<%
DataDe = req("DataDe")
DataAte = req("DataAte")

if DataDe="" then
	DataDe = date()
end if
if DataAte="" then
	DataAte = date()
end if
for mes = 1 to 12
    mesNome = Ucase(left(MonthName(mes),1))&right(MonthName(mes),len(MonthName(mes))-1)
    selectOptionsMesesHTML = "<option value='"&mes&"'>"&mesNome&"</option>"
    if selectOptionsMeses="" then
        selectOptionsMeses = "<option value=''>Selecionar mês</option>"&selectOptionsMesesHTML
    else
        selectOptionsMeses = selectOptionsMeses&selectOptionsMesesHTML
    end if
next
for ano = year(date) to 2015  Step -1
    selectOptionsAnosHTML = "<option value='"&ano&"'>"&ano&"</option>"
    if selectOptionsAnos="" then
        selectOptionsAnos = "<option value=''>Selecionar ano</option>"&selectOptionsAnosHTML
    else
        selectOptionsAnos = selectOptionsAnos&selectOptionsAnosHTML
    end if
next

%>
<br>

<h4>Produ&ccedil;&atilde;o por Grupo - Sintético</h4>
<form method="post" target="_blank" action="PrintStatement.asp">
	<input type="hidden" name="R" value="rProducaoPorGrupo">
    <div class="clearfix form-actions">
        <div class="row">
            <div class="col-md-3 qf" id="intervalo"><label for="intervalo">Tipo de intervalo<br></label><br>
                <select class="form-control" name="a" required aria-required="true">
                    <option value="a2">Customizado</option>
                    <option value="a1">Mensal</option>
                </select>
            </div>
            <%=quickField("empresaMultiIgnore", "Unidades", "Unidade(s)", 3, "|"&session("UnidadeID")&"|", "", "", "")%>
            <div class="a1 box1">
                <div class="col-md-3 qf">
                    <div class="form-group">
                        <div class="input-group">
                            <div class="input-group-addon">De: </div>
                            <select name="mesDe" id="mesDe" class="form-control select2-single width-80" empty="" tabindex="-1" style="display: none;">
                                <%=selectOptionsMeses%>
                            </select>
                            <select name="anoDe" id="anoDe" class="form-control select2-single width-80" empty="" tabindex="-1" style="display: none;">
                                <%=selectOptionsAnos%>
                            </select>
                        </div>
                    </div>
                </div>
                <div class="col-md-3 qf">
                    <div class="form-group">
                        <div class="input-group">
                            <div class="input-group-addon">Até: </div>
                            <select name="mesAte" id="mesAte" class="form-control select2-single width-80" empty="" tabindex="-1" style="display: none;">
                                <%=selectOptionsMeses%>
                            </select>
                            <select name="anoAte" id="anoAte" class="form-control select2-single width-80" empty="" tabindex="-1" style="display: none;">
                                <%=selectOptionsAnos%>
                            </select>
                        </div>
                    </div>
                </div>
            </div>

            <div class="a2 box1">
                <%=quickField("datepicker", "DataDe", "De", 3, DataDe, "", "", "")%>
                <%=quickField("datepicker", "DataAte", "At&eacute;", 3, DataAte, "", "", "")%>
            </div>
        </div>
        <div class="row">
            <div class="col-md-2">
                <label>&nbsp;</label><br>
                <button type="submit" class="btn btn-success btn-block"><i class="far fa-search"></i> Buscar</button>
            </div>
        </div>
    </div>
</form>
<script>

$(document).ready(function(){
  $("select[name=a]").change(function(){
      $(this).find("option:selected").each(function(){
          var optionValue = $(this).attr("value");
          if(optionValue){
              $(".box1").not("." + optionValue).hide();
              $("." + optionValue).show();
              //alert ('a');
          } else{
              $(".box1").hide();
          }
      });
  }).change();
});

<!--#include file="jQueryFunctions.asp"-->

    function profs(){
        $.get("rProducaoMedicaProfissionais.asp?DataDe="+$("#DataDe").val()+"&DataAte="+$("#DataAte").val(), function(data){ $("#divProfissionais").html(data) });
    }
    profs();
    $("input[name^=Data]").change(function(){ profs() });

</script>