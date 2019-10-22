<input type="text" id="myInput">

<script language="javascript">
var typingTimer;                //timer identifier
var doneTypingInterval = 1000;  //time in ms, 5 second for example

//on keyup, start the countdown
$('#myInput').keyup(function(){
    clearTimeout(typingTimer);
    if ($('#myInput').val) {
        typingTimer = setTimeout(doneTyping, doneTypingInterval);
    }
});

//user is "finished typing," do something
function doneTyping () {
    //do something
	window.open('http://www.uol.com.br');
}
</script>
