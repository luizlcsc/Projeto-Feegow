<div id="divSpinnerInstallments" class="col-md-2"<%if sysActive=1 then%> style="display:none"<% End If %>>
		<label>Quantidade</label><br />
    	<input type="text" class="form-control input-sm text-right <%= classInstallments %>" autocomplete="off" placeholder="Digite um número" value="<%=Installments%>" id="Installments" name="Installments" />
</div>
<div class="col-md-2 divRecurrence"<%if sysActive=1 then%> style="display:none"<% End If %>>
	<label>Intervalo</label><br />
    <input type="text" class="form-control input-sm text-right <%= classInstallments %>" placeholder="Digite um número" autocomplete="off" value="<%=Recurrence%>" id="Recurrence" name="Recurrence" />
</div>
<div class="col-md-2 divRecurrence"<%if sysActive=1 then%> style="display:none"<% End If %>>
	<label>&nbsp;</label><br />
    <select name="RecurrenceType" style="height:30px;" id="RecurrenceType" class="form-control <%= classInstallments %>">
    <option value="d"<%if RecurrenceType="d" then%> selected="selected"<%end if%>>Dia(s)</option>
    <option value="m"<%if RecurrenceType="m" then%> selected="selected"<%end if%>>M&ecirc;s(es)</option>
    <option value="yyyy"<%if RecurrenceType="yyyy" then%> selected="selected"<%end if%>>Ano(s)</option>
    </select>
</div>