<!--#include file="connect.asp"-->
<select class="chosen-select" id="Numeros">
	<option value="1">Um</option>
	<option value="2">Dois</option>
	<option value="3">Três</option>
	<option value="4">Quatro</option>
</select>

<script>
$(document).ready(function(e) {
	$("input").keyup(function(){
		alert('i');
	});
});
</script>