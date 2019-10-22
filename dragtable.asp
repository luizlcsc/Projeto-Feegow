<style type="text/css">


/* tables still need 'cellspacing="0"' in the markup */
table {
	border-collapse: collapse;
	border-spacing: 0;
}

/* add some styling to the table, padding etc*/
table thead th{
	padding:3px 10px;
	border-bottom:1px solid #000000;
	background:#CCCCCC;
	background-size: 50%;
}
table tbody td{
	padding:3px 10px;
	white-space: no
}
table tbody tr:nth-of-type(2n+1) td{
	background:#7AA6DC;
}

tfoot td{
	background: #ccc;
}
#three tbody tr:nth-of-type(2n+1) td{
	background:#82CE76;
}
.drag{
	background:#CCCCCC !important;
	color:#cCCCCC;
}

.dragtable-drag-handle{
	height:.5em;
	width: 5px;
	float: right;
	background:green;
}

.tablewrapper{
	position: relative;
	overflow: scroll;
	width: 400px;
	margin: 3em;
}
.tablewrapper table{
	width: 100%;
}
.test3{
	/*border-right: 5px solid red !important;*/
}

	</style>
	
	<script type="text/javascript" src="assets/js/jquery-1.7.2.js"></script>
    <script type="text/javascript" src="assets/js/jquery-ui.min.js"></script>
    

    <script type="text/javascript" src="assets/js/jquery.dragtable.js"></script>
    <link rel="stylesheet" href="assets/css/dragtable-default.css" type="text/css" />
   

<script type="text/javascript">
$(document).ready(function(){
$('table').each(function(){
	
		$(this).dragtable({
		placeholder: 'dragtable-col-placeholder test3',
		items: 'thead th:not( .notdraggable ):not( :has( .dragtable-drag-handle ) ), .dragtable-drag-handle',
		scroll: true
	});
	
	
})
	$('a.order').click(function(){

		console.log($('#one').dragtable('order'));
		return false;
	});
	$('a.setorder').click(function(){
		$('#one').dragtable('order',["first_name", "id", "last_name", "phone_number", "salary" , "color"])
	})
});
	
</script>
