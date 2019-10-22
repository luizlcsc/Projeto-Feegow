<!-- PEGA USUARIO LOGADO NO WINDOWS -->
<form name="Form">
    <input type="text" name="usuario" value="" readonly="readonly">
</form>

<script type="text/javascript">
if (window.DOMParser)
{ // Firefox, Chrome, Opera, etc.
    parser=new DOMParser();
    xmlDoc=parser.parseFromString(xml,"text/xml");
}
else // Internet Explorer
{
    xmlDoc=new ActiveXObject("Microsoft.XMLDOM");
    xmlDoc.async=false;
    xmlDoc.loadXML(xml); 
}</script>