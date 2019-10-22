<?php
header('Content-Type: application/xml; charset=ISO-8859-1');
?>
<?xml version="1.0" encoding="ISO-8859-1"?>
<ans:mensagemTISS xsi:schemaLocation="http://www.ans.gov.br/padroes/tiss/schemas tissV3_02_00.xsd" xmlns:ans="http://www.ans.gov.br/padroes/tiss/schemas" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	<ans:cabecalho>
		<ans:identificacaoTransacao>
			<ans:tipoTransacao>ENVIO_LOTE_GUIAS</ans:tipoTransacao>
			<ans:sequencialTransacao>1</ans:sequencialTransacao>
			<ans:dataRegistroTransacao>2015-03-27</ans:dataRegistroTransacao>
			<ans:horaRegistroTransacao>16:45:58</ans:horaRegistroTransacao>
		</ans:identificacaoTransacao>
		<ans:origem>
			<ans:identificacaoPrestador>
				<ans:codigoPrestadorNaOperadora>7788547</ans:codigoPrestadorNaOperadora>
			</ans:identificacaoPrestador>
		</ans:origem>
		<ans:destino>
			<ans:registroANS>393321</ans:registroANS>
		</ans:destino>
		<ans:versaoPadrao>3.02.00</ans:versaoPadrao>
	</ans:cabecalho>

</ans:mensagemTISS>