/* Version 2.0 */
/*	SWFObject v2.0 rc2 <http://code.google.com/p/swfobject/>
	Copyright (c) 2007 Geoff Stearns, Michael Williams, and Bobby van der Sluis
	This software is released under the MIT License <http://www.opensource.org/licenses/mit-license.php>
*/
var flaDetect=function(){var _1=[];var _2=[];var _3=null;var _4=null;var _5=false;var _6=false;var ua=function(){var _8=typeof document.getElementById!="undefined"&&typeof document.getElementsByTagName!="undefined"&&typeof document.createElement!="undefined"&&typeof document.appendChild!="undefined"&&typeof document.replaceChild!="undefined"&&typeof document.removeChild!="undefined"&&typeof document.cloneNode!="undefined";var _9=[0,0,0];var d=null;if(typeof navigator.plugins!="undefined"&&typeof navigator.plugins["Shockwave Flash"]=="object"){d=navigator.plugins["Shockwave Flash"].description;if(d){d=d.replace(/^.*\s+(\S+\s+\S+$)/,"$1");_9[0]=parseInt(d.replace(/^(.*)\..*$/,"$1"),10);_9[1]=parseInt(d.replace(/^.*\.(.*)\s.*$/,"$1"),10);_9[2]=/r/.test(d)?parseInt(d.replace(/^.*r(.*)$/,"$1"),10):0;}}else{if(typeof window.ActiveXObject!="undefined"){var a=null;var _c=false;try{a=new ActiveXObject("ShockwaveFlash.ShockwaveFlash.7");}catch(e){try{a=new ActiveXObject("ShockwaveFlash.ShockwaveFlash.6");_9=[6,0,21];a.AllowScriptAccess="always";}catch(e){if(_9[0]==6){_c=true;}}if(!_c){try{a=new ActiveXObject("ShockwaveFlash.ShockwaveFlash");}catch(e){}}}if(!_c&&a){try{d=a.GetVariable("$version");if(d){d=d.split(" ")[1].split(",");_9=[parseInt(d[0],10),parseInt(d[1],10),parseInt(d[2],10)];}}catch(e){}}}}var u=navigator.userAgent.toLowerCase();var p=navigator.platform.toLowerCase();var _f=/webkit/.test(u);var _10=_f?parseFloat(u.replace(/^.*webkit\/(\d+(\.\d+)?).*$/,"$1")):0;var ie=false;var win=p?/win/.test(p):/win/.test(u);var mac=p?/mac/.test(p):/mac/.test(u);/*@cc_on ie=true;@if(@_win32)win=true;@elif(@_mac)mac=true;@end@*/return {w3cdom:_8,playerVersion:_9,webkit:_f,webkitVersion:_10,ie:ie,win:win,mac:mac};}();var _14=function(){if(!ua.w3cdom){return;}addDomLoadEvent(main);if(ua.ie&&ua.win){try{document.write("<scr"+"ipt id=__ie_ondomload defer=true src=//:></scr"+"ipt>");var s=document.getElementById("__ie_ondomload");if(s){s.onreadystatechange=function(){if(this.readyState=="complete"){this.parentNode.removeChild(this);callDomLoadFunctions();}};}}catch(e){}}if(ua.webkit&&typeof document.readyState!="undefined"){_3=setInterval(function(){if(/loaded|complete/.test(document.readyState)){callDomLoadFunctions();}},10);}if(typeof document.addEventListener!="undefined"){document.addEventListener("DOMContentLoaded",callDomLoadFunctions,null);}addLoadEvent(callDomLoadFunctions);}();function callDomLoadFunctions(){if(_5){return;}if(ua.ie&&ua.win){var s=document.createElement("span");try{var t=document.getElementsByTagName("body")[0].appendChild(s);t.parentNode.removeChild(t);}catch(e){return;}}_5=true;if(_3){clearInterval(_3);_3=null;}var dl=_1.length;for(var i=0;i<dl;i++){_1[i]();}}function addDomLoadEvent(fn){if(_5){fn();}else{_1[_1.length]=fn;}}function addLoadEvent(fn){if(typeof window.addEventListener!="undefined"){window.addEventListener("load",fn,false);}else{if(typeof document.addEventListener!="undefined"){document.addEventListener("load",fn,false);}else{if(typeof window.attachEvent!="undefined"){window.attachEvent("onload",fn);}else{if(typeof window.onload=="function"){var _1c=window.onload;window.onload=function(){_1c();fn();};}else{window.onload=fn;}}}}}function main(){var rl=_2.length;for(var i=0;i<rl;i++){var id=_2[i].id;if(ua.playerVersion[0]>0){var obj=document.getElementById(id);if(obj){_2[i].width=obj.getAttribute("width")?obj.getAttribute("width"):"0";_2[i].height=obj.getAttribute("height")?obj.getAttribute("height"):"0";if(hasPlayerVersion(_2[i].swfVersion)){if(ua.webkit&&ua.webkitVersion<312){fixParams(obj);}}else{if(_2[i].expressInstall&&!_6&&hasPlayerVersion([6,0,65])&&(ua.win||ua.mac)){showExpressInstall(_2[i]);}else{displayAltContent(obj);}}}}createCSS("#"+id,"visibility:visible");}}function fixParams(obj){var _22=obj.getElementsByTagName("object")[0];if(_22){var e=document.createElement("embed");var a=_22.attributes;if(a){var al=a.length;for(var i=0;i<al;i++){if(a[i].nodeName.toLowerCase()=="data"){e.setAttribute("src",a[i].nodeValue);}else{e.setAttribute(a[i].nodeName,a[i].nodeValue);}}}var c=_22.childNodes;if(c){var cl=c.length;for(var j=0;j<cl;j++){if(c[j].nodeType==1&&c[j].nodeName.toLowerCase()=="param"){e.setAttribute(c[j].getAttribute("name"),c[j].getAttribute("value"));}}}obj.parentNode.replaceChild(e,obj);}}function fixObjectLeaks(id){if(ua.ie&&ua.win&&hasPlayerVersion([8,0,0])){window.attachEvent("onunload",function(){var obj=document.getElementById(id);for(var i in obj){if(typeof obj[i]=="function"){obj[i]=function(){};}}obj.parentNode.removeChild(obj);});}}function showExpressInstall(_2d){_6=true;var obj=document.getElementById(_2d.id);if(obj){if(_2d.altContentId){var ac=document.getElementById(_2d.altContentId);if(ac){_4=ac;}}else{_4=abstractAltContent(obj);}if(!(/%$/.test(_2d.width))&&parseInt(_2d.width,10)<310){_2d.width="310";}if(!(/%$/.test(_2d.height))&&parseInt(_2d.height,10)<137){_2d.height="137";}var pt=ua.ie&&ua.win?"ActiveX":"PlugIn";document.title=document.title.slice(0,47)+" - Flash Player Installation";var dt=document.title;var fv="MMredirectURL="+window.location+"&MMplayerType="+pt+"&MMdoctitle="+dt;var _33=_2d.id;if(ua.ie&&ua.win&&obj.readyState!=4){var _34=document.createElement("div");_33+="SWFObjectNew";_34.setAttribute("id",_33);obj.parentNode.insertBefore(_34,obj);obj.style.display="none";window.attachEvent("onload",function(){obj.parentNode.removeChild(obj);});}createSWF({data:_2d.expressInstall,id:"SWFObjectExprInst",width:_2d.width,height:_2d.height},{flashvars:fv},_33);}}function displayAltContent(obj){if(ua.ie&&ua.win&&obj.readyState!=4){var el=document.createElement("div");obj.parentNode.insertBefore(el,obj);el.parentNode.replaceChild(abstractAltContent(obj),el);obj.style.display="none";window.attachEvent("onload",function(){obj.parentNode.removeChild(obj);});}else{obj.parentNode.replaceChild(abstractAltContent(obj),obj);}}function abstractAltContent(obj){var ac=document.createElement("div");if(ua.win&&ua.ie){ac.innerHTML=obj.innerHTML;}else{var _39=obj.getElementsByTagName("object")[0];if(_39){var c=_39.childNodes;if(c){var cl=c.length;for(var i=0;i<cl;i++){if(!(c[i].nodeType==1&&c[i].nodeName.toLowerCase()=="param")&&!(c[i].nodeType==8)){ac.appendChild(c[i].cloneNode(true));}}}}}return ac;}function createSWF(_3d,_3e,id){var r;var el=document.getElementById(id);if(typeof _3d.id=="undefined"){_3d.id=id;}if(ua.ie&&ua.win){var att="";for(var i in _3d){if(_3d[i]!=Object.prototype[i]){if(i=="data"){_3e.movie=_3d[i];}else{if(i.toLowerCase()=="styleclass"){att+=" class=\""+_3d[i]+"\"";}else{if(i!="classid"){att+=" "+i+"=\""+_3d[i]+"\"";}}}}}var par="";for(var j in _3e){if(_3e[j]!=Object.prototype[j]){par+="<param name=\""+j+"\" value=\""+_3e[j]+"\" />";}}el.outerHTML="<object classid=\"clsid:D27CDB6E-AE6D-11cf-96B8-444553540000\""+att+">"+par+"</object>";fixObjectLeaks(_3d.id);r=document.getElementById(_3d.id);}else{if(ua.webkit&&ua.webkitVersion<312){var e=document.createElement("embed");e.setAttribute("type","application/x-shockwave-flash");for(var k in _3d){if(_3d[k]!=Object.prototype[k]){if(k=="data"){e.setAttribute("src",_3d[k]);}else{if(k.toLowerCase()=="styleclass"){e.setAttribute("class",_3d[k]);}else{if(k!="classid"){e.setAttribute(k,_3d[k]);}}}}}for(var l in _3e){if(_3e[l]!=Object.prototype[l]){if(l!="movie"){e.setAttribute(l,_3e[l]);}}}el.parentNode.replaceChild(e,el);r=e;}else{var o=document.createElement("object");o.setAttribute("type","application/x-shockwave-flash");for(var m in _3d){if(_3d[m]!=Object.prototype[m]){if(m.toLowerCase()=="styleclass"){o.setAttribute("class",_3d[m]);}else{if(m!="classid"){o.setAttribute(m,_3d[m]);}}}}for(var n in _3e){if(_3e[n]!=Object.prototype[n]&&n!="movie"){createObjParam(o,n,_3e[n]);}}el.parentNode.replaceChild(o,el);r=o;}}return r;}function createObjParam(el,_4d,_4e){var p=document.createElement("param");p.setAttribute("name",_4d);p.setAttribute("value",_4e);el.appendChild(p);}function hasPlayerVersion(rv){return (ua.playerVersion[0]>rv[0]||(ua.playerVersion[0]==rv[0]&&ua.playerVersion[1]>rv[1])||(ua.playerVersion[0]==rv[0]&&ua.playerVersion[1]==rv[1]&&ua.playerVersion[2]>=rv[2]))?true:false;}function createCSS(sel,_52){if(ua.ie&&ua.mac){return;}var h=document.getElementsByTagName("head")[0];var s=document.createElement("style");s.setAttribute("type","text/css");s.setAttribute("media","screen");if(!(ua.ie&&ua.win)&&typeof document.createTextNode!="undefined"){s.appendChild(document.createTextNode(sel+" {"+_52+"}"));}h.appendChild(s);if(ua.ie&&ua.win&&typeof document.styleSheets!="undefined"&&document.styleSheets.length>0){var ls=document.styleSheets[document.styleSheets.length-1];if(typeof ls.addRule=="object"){ls.addRule(sel,_52);}}}return {registerObject:function(_56,_57,_58){if(!ua.w3cdom||!_56||!_57){return;}var _59={};_59.id=_56;var v=_57.split(".");_59.swfVersion=[parseInt(v[0],10),parseInt(v[1],10),parseInt(v[2],10)];_59.expressInstall=_58?_58:false;_2[_2.length]=_59;createCSS("#"+_56,"visibility:hidden");},getObjectById:function(_5b){var r=null;if(ua.w3cdom&&_5){var o=document.getElementById(_5b);if(o){var n=o.getElementsByTagName("object")[0];if(!n||(n&&typeof o.SetVariable!="undefined")){r=o;}else{if(typeof n.SetVariable!="undefined"){r=n;}}}}return r;},embedSWF:function(_5f,_60,_61,_62,_63,_64,_65,_66,_67){if(!ua.w3cdom||!_5f||!_60||!_61||!_62||!_63){return;}_61+="";_62+="";if(hasPlayerVersion(_63.split("."))){createCSS("#"+_60,"visibility:hidden");var att=(typeof _67=="object")?_67:{};att.data=_5f;att.width=_61;att.height=_62;var par=(typeof _66=="object")?_66:{};if(typeof _65=="object"){for(var i in _65){if(_65[i]!=Object.prototype[i]){if(typeof par.flashvars!="undefined"){par.flashvars+="&"+i+"="+_65[i];}else{par.flashvars=i+"="+_65[i];}}}}addDomLoadEvent(function(){createSWF(att,par,_60);createCSS("#"+_60,"visibility:visible");});}else{if(_64&&!_6&&hasPlayerVersion([6,0,65])&&(ua.win||ua.mac)){createCSS("#"+_60,"visibility:hidden");addDomLoadEvent(function(){var _6b={};_6b.id=_6b.altContentId=_60;_6b.width=_61;_6b.height=_62;_6b.expressInstall=_64;showExpressInstall(_6b);createCSS("#"+_60,"visibility:visible");});}}},getFlashPlayerVersion:function(){return {major:ua.playerVersion[0],minor:ua.playerVersion[1],release:ua.playerVersion[2]};},hasFlashPlayerVersion:function(_6c){return hasPlayerVersion(_6c.split("."));},createSWF:function(_6d,_6e,_6f){if(ua.w3cdom&&_5){return createSWF(_6d,_6e,_6f);}else{return undefined;}},createCSS:function(sel,_71){if(ua.w3cdom){createCSS(sel,_71);}},addDomLoadEvent:addDomLoadEvent,addLoadEvent:addLoadEvent,getQueryParamValue:function(_72){var q=document.location.search||document.location.hash;if(_72==null){return q;}if(q){var _74=q.substring(1).split("&");for(var i=0;i<_74.length;i++){if(_74[i].substring(0,_74[i].indexOf("="))==_72){return _74[i].substring((_74[i].indexOf("=")+1));}}}return "";},expressInstallCallback:function(){if(_6&&_4){var obj=document.getElementById("SWFObjectExprInst");if(obj){obj.parentNode.replaceChild(_4,obj);_4=null;_6=false;}}}};}();

//Get current installed browser version
var flaInstalledVersion = flaDetect.getFlashPlayerVersion();

// Javascript code to detect mobile //
var uagent = navigator.userAgent.toLowerCase();
var mobile_browser  = false;	
var status 			= '';
var video_format 	= 'MP4';
var video_frames 	= 0;
	
function js_preg_match(search) {
	var res = false;
	var arrSearch = search.split("|");
	for(i = 0; i < arrSearch.length; i++) {
		if(uagent.search(arrSearch[i]) > -1)
			return true;
	}
	return res;
}

function detectMobile() {
	switch(true) {
		case  (uagent.search("iphone") > -1):
			status 			= 'Apple';
			mobile_browser  = true;
			break;
		case  (uagent.search("android") > -1):
			status = 'Android';
			mobile_browser  = true;
			//video_format 	= 'MP4';
			video_frames 	= 8.333;
			break;
		case  (uagent.search("opera mini") > -1):
			status 			= 'Opera';
			mobile_browser  = true;
			break;
		case  (uagent.search("blackberry") > -1):
			status 			= 'Blackberry';
			mobile_browser  = true;
			//video_format 	= '3GP';
			video_frames 	= 25;
			break;
		case  (js_preg_match("palm os|palm|hiptop|avantgo|fennec|plucker|xiino|blazer|elaine")):
			status 			= 'Palm';
			mobile_browser  = true;
			break;
		case  (js_preg_match("iris|3g_t|windows ce|opera mobi|windows ce; smartphone;|windows ce; iemobile")):
			status 			= 'Windows Smartphone';
			mobile_browser  = true;
			break;
		case  (js_preg_match("mini 9.5|vx1000|lge |m800|e860|u940|ux840|compal|wireless| mobi|ahong|lg380|lgku|lgu900|lg210|lg47|lg920|lg840|lg370|sam-r|mg50|s55|g83|t66|vx400|mk99|d615|d763|el370|sl900|mp500|samu3|samu4|vx10|xda_|samu5|samu6|samu7|samu9|a615|b832|m881|s920|n210|s700|c-810|_h797|mob-x|sk16d|848b|mowser|s580|r800|471x|v120|rim8|c500foma:|160x|x160|480x|x640|t503|w839|i250|sprint|w398samr810|m5252|c7100|mt126|x225|s5330|s820|htil-g1|fly v71|s302|-x113|novarra|k610i|-three|8325rc|8352rc|sanyo|vx54|c888|nx250|n120|mtk |c5588|s710|t880|c5005|i;458x|p404i|s210|c5100|teleca|s940|c500|s590|foma|samsu|vx8|vx9|a1000|_mms|myx|a700|gu1100|bc831|e300|ems100|me701|me702m-three|sd588|s800|8325rc|ac831|mw200|brew |d88|htc\/|htc_touch|355x|m50|km100|d736|p-9521|telco|sl74|ktouch|m4u\/|me702|8325rc|kddi|phone|lg |sonyericsson|samsung|240x|x320vx10|nokia|sony cmd|motorola|up.browser|up.link|mmp|symbian|smartphone|midp|wap|vodafone|o2|pocket|kindle|mobile|psp|treo")):
			status 			= 'Mobile matched on piped preg_match';
			mobile_browser  = true;
			break;
		case  (js_preg_match("text/vnd.wap.wml|application/vnd.wap.xhtml+xml")):
			status 			= 'Mobile matched on content accept header';
			mobile_browser  = true;
			break;
		default :
			status = 'Desktop / full capability browser';
	}	
}

if (flaInstalledVersion['major'] < 1)
	detectMobile();
//mobile_browser  = true;	
//alert(mobile_browser + ' :: ' + status);
// Javascript code to detect mobile End//

var lc_name;
var showURL;
var objWidth;
var objHeight;
var curSpot=0;
var ThisURL=''; // should be found at the beginning
var OddcastDomain='http://vhss-d.oddcast.com';

var agt=navigator.userAgent.toLowerCase();
var is_nav  = ((agt.indexOf('mozilla')!=-1) && (agt.indexOf('spoofer')==-1)
            && (agt.indexOf('compatible') == -1) && (agt.indexOf('opera')==-1)
            && (agt.indexOf('webtv')==-1) && (agt.indexOf('hotjava')==-1));
var is_ie     = ((agt.indexOf("msie") != -1) && (agt.indexOf("opera") == -1));
var is_win   = ( (agt.indexOf("win")!=-1) || (agt.indexOf("16bit")!=-1) );
var is_mac    = (agt.indexOf("mac")!=-1);

var JSGroup = is_ie&&is_win?1:2;


function getURLParam( name ){  

	name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");  
	var regexS = "[\\?&]"+name+"=([^&#]*)";  
	var regex = new RegExp( regexS );  
	var results = regex.exec( ThisURL );
	if( results == null )    
		return '';  
	else    
		return results[1];
}

function getThisURL(){
	arr = document.getElementsByTagName("script");
	for(i=0;i<arr.length;i++){
		if(arr[i].src && arr[i].src.match(/vhost_embed_functions.*\.php(\?.*)?$/)){
			ThisURL = arr[i].src;
			break;
		}
	}
}

getThisURL();

var followCursorFlag = getURLParam('followCursor');
var JSFlag = getURLParam('js');
var accId = getURLParam('acc');

function goToShow(showId, firstslide, forcePlayback){
	var newRegExp = new RegExp("\/ss%3D[0-9]{1,}\/","g");
	showURL = showURL.replace(newRegExp,"/ss%3D"+showId+"/");

	var newRegExp = new RegExp("\/sl%3D[0-9]{1,}%","g");
	showURL = showURL.replace(newRegExp,"\/sl%3D0%");

	if(forcePlayback>0){
		showURL = showURL+"&playOnLoad=1";
	}

	if(JSGroup==1){
		vh_mc.LoadMovie(0,showURL);
	}else{
		useFlashLC("loadMovie", showURL+"~_level0");
	}
	vh_mc = null;
}

function goToWorkshop(spot){

	document.onmousemove = null;

	if(curSpot==spot){
		return;
	}

	var newRegExp = new RegExp("ss%3D","g");
	tempShowURL = showURL.replace(newRegExp,"sp%3D"+spot+"%26ss%3D");

	var newRegExp = new RegExp("&acc=","g");
	tempShowURL = tempShowURL.replace(newRegExp,"&stretch=1&acc=");

	var newRegExp = new RegExp("getshow","g");
	tempShowURL = tempShowURL.replace(newRegExp,"getworkshop");

	if(JSGroup==1){
		if(!vh_mc) return;
		vh_mc.LoadMovie(0,tempShowURL);
	}else{
		useFlashLC("loadMovie", tempShowURL+"~_level0");
	}
	vh_mc = null;

	curSpot = spot;
}

function loadExtraJS(JS_URL){
	var head = document.getElementsByTagName('head')[0];
	var elementOverLay = document.createElement('script');
	elementOverLay.src = JS_URL;
	elementOverLay.type = 'text/javascript';
	head.appendChild(elementOverLay);	
}

function domainOfPage() {
	domainName = document.location.hostname;
	if(domainName.length<=0)
		domainName = 'not_found';
	return domainName;
}


var fname = 'AC_VHost_Embed_'+accId;

window[fname] = function() {
	AC_VHost_Embed (accId,arguments[0], arguments[1], arguments[2], arguments[3], arguments[4], arguments[5], arguments[6], arguments[7], arguments[8], arguments[9], arguments[10], arguments[11]);
}

var isOverlay = false;
var globalOverlayString = '';
function AC_VHost_Embed (accountID, height, width, bgcolor, firstslide, loading, ss, sl, transparent, minimal, embedId, flashVersion, overlayStr, embedName, forcePlayer) {
			if(mobile_browser) {
					
				var bg = OddcastDomain+'/images/Play.gif';
				
				var topMargin   =  Math.ceil((height - 70) / 2);
				var leftMargin  =  Math.ceil((width - 70) / 2);
				var contentDir  = '/ccs2/vhss/';
				var hostContent = 'http://content.oddcast.com/vhss';
				var account = new String(accId);
				var hashContent = hex_md5(account.valueOf()).substring(0,3); 
				var assetPath= hostContent + contentDir+'user/'+hashContent+'/'+accountID+'/video/';
				//var videoPath= assetPath + 'video_'+ss+'.'+video_format.toLowerCase()+ '?rand=' + Math.random();
				var showthumb= (sl>0)?sl:ss; //studio has sl set when show plays
				var jpg      = assetPath + 'video_'+showthumb+'.jpg'+ '?rand=' + Math.random();
				
				var VHSS_HTTP_URL 	= 'http://vhss.oddcast.com';
				var videoPath		= OddcastDomain + '/vhost_embed_video.php?acc='+accountID+'&sc='+ss+'&sl='+sl+'&rand=' + Math.random();

				document.write('<div style="background-image: url('+jpg+');background-size:100% 100%;background-repeat: no-repeat;width:'+width+'px;height:'+height+'px;"> \n');
				document.write('<a href="'+videoPath+'"><img style="position: relative;top:'+topMargin+'px;left:'+leftMargin+'px;border:0px;" width="70" height="70" src="'+bg+'" /> </a> \n');
				document.write('</div> \n');
			} else {
				flashVersion 	=  (flashVersion =='' || typeof flashVersion == 'undefined' || flashVersion < 9) ? 9 : flashVersion;
				objWidth		= width;
				objHeight		= height;
				lc_name 		= '1410964735';
				embedId 		= embedId==''?'nothing':embedId;
				embedName 		= (embedName =='' || typeof embedName == 'undefined') ? 'VHSS' : embedName;
				
				if (transparent ==1){
					bgcolor = '';
				}
				
				// flash 9
				xmlScr			= (flashVersion>8) ? 'playScene' : 'getshow';
				player			= (flashVersion>8) ? 'vhss_v5' : 'vhss_v3';
				player			= (forcePlayer =='' || typeof forcePlayer == 'undefined') ? player : forcePlayer;
				PlayerServer		= (flashVersion>8) ? 'http://content.oddcast.com/vhss' : 'http://vhss-d.oddcast.com';
				
				domString 		= '&pageDomain='+domainOfPage();
			
				emb			= (overlayStr && overlayStr != "_OVERLAYSTR_") ? 9 : 8;
					
				playScene 		= 'http%3A%2F%2Fvhss-d.oddcast.com%2Fphp%2F'+xmlScr+'%2Facc%3D'+accountID+'%2Fss%3D'+ss+'%2Fsl%3D'+sl;
				playScene		= playScene + (flashVersion<9 ? '%3Fembedid%3D'+embedId : '');	// appends embedid if less than flash 9
				
				url 			= PlayerServer+'/'+player+'.swf?doc='+playScene+'&acc='+accountID+'&bgcolor=0x'+bgcolor+domString+'&lc_name='+lc_name+'&fv='+flashVersion+'&is_ie='+(JSGroup==1?1:0)+(followCursorFlag>0?'&followCursor='+followCursorFlag:'')+'&emb='+emb;
				url			= url + (flashVersion>8 ? '&embedid='+embedId : '');	// appends embedid if it's flash 9
				
				showURL 		= url;
				loading 		= 1; // done after request not to allow admin not to have a loader
				
				expressInstallUrl	= OddcastDomain+'/expressInstall.swf';
			
				if (overlayStr && overlayStr != "_OVERLAYSTR_"){
					globalOverlayString = overlayStr;
					loadExtraJS(OddcastDomain+'/admin/includes/vhss_embedOverlayFunctions.js');
					isOverlay = true;
				}
			
				if(flashVersion>8){
					flashVersionStr = flashVersion+'.0.115';
				}else{
					flashVersionStr = flashVersion+'.0.0';
				}
				
				var vhssFlashDiv = 'vhssFlashDiv' + ss + sl;
				
				if (isOverlay) {
					//check if there is HTML structure, bug fix for IE
					var checkelement =  document.getElementById("divVHSS");
					if (typeof(checkelement) != 'undefined' && checkelement != null)
					{	
						document.getElementById("divVHSS").innerHTML = "<div id='" + vhssFlashDiv + "'></div>";
					}
				} else {
					document.write("<div id='" + vhssFlashDiv + "'></div>");
				}
				
				var vhostFlashvars = {};
				var vhostFlashParams = {
					scale: 'noborder',
					bgcolor: bgcolor,
					quality: 'high',
					name: embedName,
					allowscriptaccess: 'always',
					swliveconnect: 'true'
				};
				if (transparent ==1)
					vhostFlashParams.wmode = 'transparent';
				
				var vhostFlashAttributes = { id: embedName };
				
				vhostSwfobject.embedSWF(url, vhssFlashDiv, width, height, flashVersionStr, expressInstallUrl, vhostFlashvars, vhostFlashParams, vhostFlashAttributes);
				
				if( !vhostSwfobject.hasFlashPlayerVersion('6.0.65') )
					vhostSwfobject.createSWF( { data: url, width: width, height: height, id: embedName }, vhostFlashParams, vhssFlashDiv);
			
				
				SWFFormFix(embedName);
			}
}

if (navigator.appName && navigator.appName.indexOf("Microsoft") != -1 && navigator.userAgent.indexOf("Windows") != -1 && navigator.userAgent.indexOf("Windows 3.1") == -1) {
	document.write('<SCRIPT LANGUAGE=VBScript\> \n');
	document.write('on error resume next \n');
	document.write('Sub VHSS_FSCommand(ByVal command, ByVal args)\n');
	document.write('  call VHSS_DoFSCommand(command, args)\n');
	document.write('end sub\n');
	document.write('</SCRIPT\> \n');
}

if(JSFlag>0){	
	loadExtraJS(OddcastDomain+'/admin/includes/vhss_api_v2.js');
			
	//if(!is_mac){
		loadExtraJS(OddcastDomain+'/admin/includes/vhss_api_cursor_'+(JSGroup==1?'pcie':'other')+'.js');
	//}
}

/* SWFObject v2.1 <http://code.google.com/p/swfobject/>
	Copyright (c) 2007-2008 Geoff Stearns, Michael Williams, and Bobby van der Sluis
	This software is released under the MIT License <http://www.opensource.org/licenses/mit-license.php>
	
	mikelee - 05/28/2009
	made some naming changes to avoid conflict with instances of swfobject on client side. specifically to swfobject itself and ids on elements created by swfobject.
	
*/
var vhostSwfobject=function(){var b="undefined",Q="object",n="Shockwave Flash",p="ShockwaveFlash.ShockwaveFlash",P="application/x-shockwave-flash",m="vhostSWFObjectExprInst",j=window,K=document,T=navigator,o=[],N=[],i=[],d=[],J,Z=null,M=null,l=null,e=false,A=false;var h=function(){var v=typeof K.getElementById!=b&&typeof K.getElementsByTagName!=b&&typeof K.createElement!=b,AC=[0,0,0],x=null;if(typeof T.plugins!=b&&typeof T.plugins[n]==Q){x=T.plugins[n].description;if(x&&!(typeof T.mimeTypes!=b&&T.mimeTypes[P]&&!T.mimeTypes[P].enabledPlugin)){x=x.replace(/^.*\s+(\S+\s+\S+$)/,"$1");AC[0]=parseInt(x.replace(/^(.*)\..*$/,"$1"),10);AC[1]=parseInt(x.replace(/^.*\.(.*)\s.*$/,"$1"),10);AC[2]=/r/.test(x)?parseInt(x.replace(/^.*r(.*)$/,"$1"),10):0}}else{if(typeof j.ActiveXObject!=b){var y=null,AB=false;try{y=new ActiveXObject(p+".7")}catch(t){try{y=new ActiveXObject(p+".6");AC=[6,0,21];y.AllowScriptAccess="always"}catch(t){if(AC[0]==6){AB=true}}if(!AB){try{y=new ActiveXObject(p)}catch(t){}}}if(!AB&&y){try{x=y.GetVariable("$version");if(x){x=x.split(" ")[1].split(",");AC=[parseInt(x[0],10),parseInt(x[1],10),parseInt(x[2],10)]}}catch(t){}}}}var AD=T.userAgent.toLowerCase(),r=T.platform.toLowerCase(),AA=/webkit/.test(AD)?parseFloat(AD.replace(/^.*webkit\/(\d+(\.\d+)?).*$/,"$1")):false,q=false,z=r?/win/.test(r):/win/.test(AD),w=r?/mac/.test(r):/mac/.test(AD);/*@cc_on q=true;@if(@_win32)z=true;@elif(@_mac)w=true;@end@*/return{w3cdom:v,pv:AC,webkit:AA,ie:q,win:z,mac:w}}();var L=function(){if(!h.w3cdom){return }f(H);if(h.ie&&h.win){try{K.write("<script id=__ie_ondomload defer=true src=//:><\/script>");J=C("vhost__ie_ondomload");if(J){I(J,"onreadystatechange",S)}}catch(q){}}if(h.webkit&&typeof K.readyState!=b){Z=setInterval(function(){if(/loaded|complete/.test(K.readyState)){E()}},10)}if(typeof K.addEventListener!=b){K.addEventListener("DOMContentLoaded",E,null)}R(E)}();function S(){if(J.readyState=="complete"){J.parentNode.removeChild(J);E()}}function E(){if(e){return }if(h.ie&&h.win){var v=a("span");try{var u=K.getElementsByTagName("body")[0].appendChild(v);u.parentNode.removeChild(u)}catch(w){return }}e=true;if(Z){clearInterval(Z);Z=null}var q=o.length;for(var r=0;r<q;r++){o[r]()}}function f(q){if(e){q()}else{o[o.length]=q}}function R(r){if(typeof j.addEventListener!=b){j.addEventListener("load",r,false)}else{if(typeof K.addEventListener!=b){K.addEventListener("load",r,false)}else{if(typeof j.attachEvent!=b){I(j,"onload",r)}else{if(typeof j.onload=="function"){var q=j.onload;j.onload=function(){q();r()}}else{j.onload=r}}}}}function H(){var t=N.length;for(var q=0;q<t;q++){var u=N[q].id;if(h.pv[0]>0){var r=C(u);if(r){N[q].width=r.getAttribute("width")?r.getAttribute("width"):"0";N[q].height=r.getAttribute("height")?r.getAttribute("height"):"0";if(c(N[q].swfVersion)){if(h.webkit&&h.webkit<312){Y(r)}W(u,true)}else{if(N[q].expressInstall&&!A&&c("6.0.65")&&(h.win||h.mac)){k(N[q])}else{O(r)}}}}else{W(u,true)}}}function Y(t){var q=t.getElementsByTagName(Q)[0];if(q){var w=a("embed"),y=q.attributes;if(y){var v=y.length;for(var u=0;u<v;u++){if(y[u].nodeName=="DATA"){w.setAttribute("src",y[u].nodeValue)}else{w.setAttribute(y[u].nodeName,y[u].nodeValue)}}}var x=q.childNodes;if(x){var z=x.length;for(var r=0;r<z;r++){if(x[r].nodeType==1&&x[r].nodeName=="PARAM"){w.setAttribute(x[r].getAttribute("name"),x[r].getAttribute("value"))}}}t.parentNode.replaceChild(w,t)}}function k(w){A=true;var u=C(w.id);if(u){if(w.altContentId){var y=C(w.altContentId);if(y){M=y;l=w.altContentId}}else{M=G(u)}if(!(/%$/.test(w.width))&&parseInt(w.width,10)<310){w.width="310"}if(!(/%$/.test(w.height))&&parseInt(w.height,10)<137){w.height="137"}K.title=K.title.slice(0,47)+" - Flash Player Installation";var z=h.ie&&h.win?"ActiveX":"PlugIn",q=K.title,r="MMredirectURL="+j.location+"&MMplayerType="+z+"&MMdoctitle="+q,x=w.id;if(h.ie&&h.win&&u.readyState!=4){var t=a("div");x+="SWFObjectNew";t.setAttribute("id",x);u.parentNode.insertBefore(t,u);u.style.display="none";var v=function(){u.parentNode.removeChild(u)};I(j,"onload",v)}U({data:w.expressInstall,id:m,width:w.width,height:w.height},{flashvars:r},x)}}function O(t){if(h.ie&&h.win&&t.readyState!=4){var r=a("div");t.parentNode.insertBefore(r,t);r.parentNode.replaceChild(G(t),r);t.style.display="none";var q=function(){t.parentNode.removeChild(t)};I(j,"onload",q)}else{t.parentNode.replaceChild(G(t),t)}}function G(v){var u=a("div");if(h.win&&h.ie){u.innerHTML=v.innerHTML}else{var r=v.getElementsByTagName(Q)[0];if(r){var w=r.childNodes;if(w){var q=w.length;for(var t=0;t<q;t++){if(!(w[t].nodeType==1&&w[t].nodeName=="PARAM")&&!(w[t].nodeType==8)){u.appendChild(w[t].cloneNode(true))}}}}}return u}function U(AG,AE,t){var q,v=C(t);if(v){if(typeof AG.id==b){AG.id=t}if(h.ie&&h.win){var AF="";for(var AB in AG){if(AG[AB]!=Object.prototype[AB]){if(AB.toLowerCase()=="data"){AE.movie=AG[AB]}else{if(AB.toLowerCase()=="styleclass"){AF+=' class="'+AG[AB]+'"'}else{if(AB.toLowerCase()!="classid"){AF+=" "+AB+'="'+AG[AB]+'"'}}}}}var AD="";for(var AA in AE){if(AE[AA]!=Object.prototype[AA]){AD+='<param name="'+AA+'" value="'+AE[AA]+'" />'}}v.outerHTML='<object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000"'+AF+">"+AD+"</object>";i[i.length]=AG.id;q=C(AG.id)}else{if(h.webkit&&h.webkit<312){var AC=a("embed");AC.setAttribute("type",P);for(var z in AG){if(AG[z]!=Object.prototype[z]){if(z.toLowerCase()=="data"){AC.setAttribute("src",AG[z])}else{if(z.toLowerCase()=="styleclass"){AC.setAttribute("class",AG[z])}else{if(z.toLowerCase()!="classid"){AC.setAttribute(z,AG[z])}}}}}for(var y in AE){if(AE[y]!=Object.prototype[y]){if(y.toLowerCase()!="movie"){AC.setAttribute(y,AE[y])}}}v.parentNode.replaceChild(AC,v);q=AC}else{var u=a(Q);u.setAttribute("type",P);for(var x in AG){if(AG[x]!=Object.prototype[x]){if(x.toLowerCase()=="styleclass"){u.setAttribute("class",AG[x])}else{if(x.toLowerCase()!="classid"){u.setAttribute(x,AG[x])}}}}for(var w in AE){if(AE[w]!=Object.prototype[w]&&w.toLowerCase()!="movie"){F(u,w,AE[w])}}v.parentNode.replaceChild(u,v);q=u}}}return q}function F(t,q,r){var u=a("param");u.setAttribute("name",q);u.setAttribute("value",r);t.appendChild(u)}function X(r){var q=C(r);if(q&&(q.nodeName=="OBJECT"||q.nodeName=="EMBED")){if(h.ie&&h.win){if(q.readyState==4){B(r)}else{j.attachEvent("onload",function(){B(r)})}}else{q.parentNode.removeChild(q)}}}function B(t){var r=C(t);if(r){for(var q in r){if(typeof r[q]=="function"){r[q]=null}}r.parentNode.removeChild(r)}}function C(t){var q=null;try{q=K.getElementById(t)}catch(r){}return q}function a(q){return K.createElement(q)}function I(t,q,r){t.attachEvent(q,r);d[d.length]=[t,q,r]}function c(t){var r=h.pv,q=t.split(".");q[0]=parseInt(q[0],10);q[1]=parseInt(q[1],10)||0;q[2]=parseInt(q[2],10)||0;return(r[0]>q[0]||(r[0]==q[0]&&r[1]>q[1])||(r[0]==q[0]&&r[1]==q[1]&&r[2]>=q[2]))?true:false}function V(v,r){if(h.ie&&h.mac){return }var u=K.getElementsByTagName("head")[0],t=a("style");t.setAttribute("type","text/css");t.setAttribute("media","screen");if(!(h.ie&&h.win)&&typeof K.createTextNode!=b){t.appendChild(K.createTextNode(v+" {"+r+"}"))}u.appendChild(t);if(h.ie&&h.win&&typeof K.styleSheets!=b&&K.styleSheets.length>0){var q=K.styleSheets[K.styleSheets.length-1];if(typeof q.addRule==Q){q.addRule(v,r)}}}function W(t,q){var r=q?"visible":"hidden";if(e&&C(t)){C(t).style.visibility=r}else{V("#"+t,"visibility:"+r)}}function g(s){var r=/[\\\"<>\.;]/;var q=r.exec(s)!=null;return q?encodeURIComponent(s):s}var D=function(){if(h.ie&&h.win){window.attachEvent("onunload",function(){var w=d.length;for(var v=0;v<w;v++){d[v][0].detachEvent(d[v][1],d[v][2])}var t=i.length;for(var u=0;u<t;u++){X(i[u])}for(var r in h){h[r]=null}h=null;for(var q in vhostSwfobject){vhostSwfobject[q]=null}vhostSwfobject=null})}}();return{registerObject:function(u,q,t){if(!h.w3cdom||!u||!q){return }var r={};r.id=u;r.swfVersion=q;r.expressInstall=t?t:false;N[N.length]=r;W(u,false)},getObjectById:function(v){var q=null;if(h.w3cdom){var t=C(v);if(t){var u=t.getElementsByTagName(Q)[0];if(!u||(u&&typeof t.SetVariable!=b)){q=t}else{if(typeof u.SetVariable!=b){q=u}}}}return q},embedSWF:function(x,AE,AB,AD,q,w,r,z,AC){if(!h.w3cdom||!x||!AE||!AB||!AD||!q){return }AB+="";AD+="";if(c(q)){W(AE,false);var AA={};if(AC&&typeof AC===Q){for(var v in AC){if(AC[v]!=Object.prototype[v]){AA[v]=AC[v]}}}AA.data=x;AA.width=AB;AA.height=AD;var y={};if(z&&typeof z===Q){for(var u in z){if(z[u]!=Object.prototype[u]){y[u]=z[u]}}}if(r&&typeof r===Q){for(var t in r){if(r[t]!=Object.prototype[t]){if(typeof y.flashvars!=b){y.flashvars+="&"+t+"="+r[t]}else{y.flashvars=t+"="+r[t]}}}}f(function(){U(AA,y,AE);if(AA.id==AE){W(AE,true)}})}else{if(w&&!A&&c("6.0.65")&&(h.win||h.mac)){A=true;W(AE,false);f(function(){var AF={};AF.id=AF.altContentId=AE;AF.width=AB;AF.height=AD;AF.expressInstall=w;k(AF)})}}},getFlashPlayerVersion:function(){return{major:h.pv[0],minor:h.pv[1],release:h.pv[2]}},hasFlashPlayerVersion:c,createSWF:function(t,r,q){if(h.w3cdom){return U(t,r,q)}else{return undefined}},removeSWF:function(q){if(h.w3cdom){X(q)}},createCSS:function(r,q){if(h.w3cdom){V(r,q)}},addDomLoadEvent:f,addLoadEvent:R,getQueryParamValue:function(v){var u=K.location.search||K.location.hash;if(v==null){return g(u)}if(u){var t=u.substring(1).split("&");for(var r=0;r<t.length;r++){if(t[r].substring(0,t[r].indexOf("="))==v){return g(t[r].substring((t[r].indexOf("=")+1)))}}}return""},expressInstallCallback:function(){if(A&&M){var q=C(m);if(q){q.parentNode.replaceChild(M,q);if(l){W(l,true);if(h.ie&&h.win){M.style.display="block"}}M=null;l=null;A=false}}}}}();


/**
 * mikelee 08/18/2008
 * I've removed the documentation and the autofix code to reduce size.
 * also modified not to use document.forms[name] syntax so we can proceed with forms that have no name.
 * go to http://www.teratechnologies.net/stevekamerman/index.php?category=8 for details about this script.
 *
 * SWFFormFix v2.1.0: SWF ExternalInterface() Form Fix - http://http://www.teratechnologies.net/stevekamerman/
 *
 * SWFFormFix is (c) 2007 Steve Kamerman and is released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 *
 * Project sponsored by Tera Technologies - http://www.teratechnologies.net/
 */

SWFFormFix = function(swfname){
	if(navigator.appName.toLowerCase() != "microsoft internet explorer")return false;
	var testnodename = "SWFFormFixTESTER";
	document.write('<div id="'+testnodename+'" onclick="SWFFormFixCallback(this,\''+swfname+'\');return false;" style="display:none">&nbsp;</div>');
	document.getElementById(testnodename).onclick();
}
SWFFormFixCallback = function (obj,swfname){
	var path = document;
	var error = false;
	var testnode = obj;
	while(obj = obj.parentNode){
		if(obj.nodeName.toLowerCase() == "form"){
				path = obj;
		}
	}
	testnode.parentNode.removeChild(testnode);
	if(error) return false;
	window[swfname]=path[swfname];
	return true;
}
/**********End SWFFormFix*************/

/**********START 7/12/2011 MD5 function  ,by lademi *************/
var hexcase = 0;   /* hex output format. 0 - lowercase; 1 - uppercase        */
var b64pad  = "";  /* base-64 pad character. "=" for strict RFC compliance   */

/*
 * These are the functions you'll usually want to call
 * They take string arguments and return either hex or base-64 encoded strings
 */
function hex_md5(s)    { return rstr2hex(rstr_md5(str2rstr_utf8(s))); }
function b64_md5(s)    { return rstr2b64(rstr_md5(str2rstr_utf8(s))); }
function any_md5(s, e) { return rstr2any(rstr_md5(str2rstr_utf8(s)), e); }
function hex_hmac_md5(k, d)
  { return rstr2hex(rstr_hmac_md5(str2rstr_utf8(k), str2rstr_utf8(d))); }
function b64_hmac_md5(k, d)
  { return rstr2b64(rstr_hmac_md5(str2rstr_utf8(k), str2rstr_utf8(d))); }
function any_hmac_md5(k, d, e)
  { return rstr2any(rstr_hmac_md5(str2rstr_utf8(k), str2rstr_utf8(d)), e); }

/*
 * Perform a simple self-test to see if the VM is working
 */
function md5_vm_test()
{
  return hex_md5("abc").toLowerCase() == "900150983cd24fb0d6963f7d28e17f72";
}

/*
 * Calculate the MD5 of a raw string
 */
function rstr_md5(s)
{
  return binl2rstr(binl_md5(rstr2binl(s), s.length * 8));
}

/*
 * Calculate the HMAC-MD5, of a key and some data (raw strings)
 */
function rstr_hmac_md5(key, data)
{
  var bkey = rstr2binl(key);
  if(bkey.length > 16) bkey = binl_md5(bkey, key.length * 8);

  var ipad = Array(16), opad = Array(16);
  for(var i = 0; i < 16; i++)
  {
    ipad[i] = bkey[i] ^ 0x36363636;
    opad[i] = bkey[i] ^ 0x5C5C5C5C;
  }

  var hash = binl_md5(ipad.concat(rstr2binl(data)), 512 + data.length * 8);
  return binl2rstr(binl_md5(opad.concat(hash), 512 + 128));
}

/*
 * Convert a raw string to a hex string
 */
function rstr2hex(input)
{
  try { hexcase } catch(e) { hexcase=0; }
  var hex_tab = hexcase ? "0123456789ABCDEF" : "0123456789abcdef";
  var output = "";
  var x;
  for(var i = 0; i < input.length; i++)
  {
    x = input.charCodeAt(i);
    output += hex_tab.charAt((x >>> 4) & 0x0F)
           +  hex_tab.charAt( x        & 0x0F);
  }
  return output;
}

/*
 * Convert a raw string to a base-64 string
 */
function rstr2b64(input)
{
  try { b64pad } catch(e) { b64pad=''; }
  var tab = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
  var output = "";
  var len = input.length;
  for(var i = 0; i < len; i += 3)
  {
    var triplet = (input.charCodeAt(i) << 16)
                | (i + 1 < len ? input.charCodeAt(i+1) << 8 : 0)
                | (i + 2 < len ? input.charCodeAt(i+2)      : 0);
    for(var j = 0; j < 4; j++)
    {
      if(i * 8 + j * 6 > input.length * 8) output += b64pad;
      else output += tab.charAt((triplet >>> 6*(3-j)) & 0x3F);
    }
  }
  return output;
}

/*
 * Convert a raw string to an arbitrary string encoding
 */
function rstr2any(input, encoding)
{
  var divisor = encoding.length;
  var i, j, q, x, quotient;

  /* Convert to an array of 16-bit big-endian values, forming the dividend */
  var dividend = Array(Math.ceil(input.length / 2));
  for(i = 0; i < dividend.length; i++)
  {
    dividend[i] = (input.charCodeAt(i * 2) << 8) | input.charCodeAt(i * 2 + 1);
  }

  /*
   * Repeatedly perform a long division. The binary array forms the dividend,
   * the length of the encoding is the divisor. Once computed, the quotient
   * forms the dividend for the next step. All remainders are stored for later
   * use.
   */
  var full_length = Math.ceil(input.length * 8 /
                                    (Math.log(encoding.length) / Math.log(2)));
  var remainders = Array(full_length);
  for(j = 0; j < full_length; j++)
  {
    quotient = Array();
    x = 0;
    for(i = 0; i < dividend.length; i++)
    {
      x = (x << 16) + dividend[i];
      q = Math.floor(x / divisor);
      x -= q * divisor;
      if(quotient.length > 0 || q > 0)
        quotient[quotient.length] = q;
    }
    remainders[j] = x;
    dividend = quotient;
  }

  /* Convert the remainders to the output string */
  var output = "";
  for(i = remainders.length - 1; i >= 0; i--)
    output += encoding.charAt(remainders[i]);

  return output;
}

/*
 * Encode a string as utf-8.
 * For efficiency, this assumes the input is valid utf-16.
 */
function str2rstr_utf8(input)
{
  var output = "";
  var i = -1;
  var x, y;

  while(++i < input.length)
  {
    /* Decode utf-16 surrogate pairs */
    x = input.charCodeAt(i);
    y = i + 1 < input.length ? input.charCodeAt(i + 1) : 0;
    if(0xD800 <= x && x <= 0xDBFF && 0xDC00 <= y && y <= 0xDFFF)
    {
      x = 0x10000 + ((x & 0x03FF) << 10) + (y & 0x03FF);
      i++;
    }

    /* Encode output as utf-8 */
    if(x <= 0x7F)
      output += String.fromCharCode(x);
    else if(x <= 0x7FF)
      output += String.fromCharCode(0xC0 | ((x >>> 6 ) & 0x1F),
                                    0x80 | ( x         & 0x3F));
    else if(x <= 0xFFFF)
      output += String.fromCharCode(0xE0 | ((x >>> 12) & 0x0F),
                                    0x80 | ((x >>> 6 ) & 0x3F),
                                    0x80 | ( x         & 0x3F));
    else if(x <= 0x1FFFFF)
      output += String.fromCharCode(0xF0 | ((x >>> 18) & 0x07),
                                    0x80 | ((x >>> 12) & 0x3F),
                                    0x80 | ((x >>> 6 ) & 0x3F),
                                    0x80 | ( x         & 0x3F));
  }
  return output;
}

/*
 * Encode a string as utf-16
 */
function str2rstr_utf16le(input)
{
  var output = "";
  for(var i = 0; i < input.length; i++)
    output += String.fromCharCode( input.charCodeAt(i)        & 0xFF,
                                  (input.charCodeAt(i) >>> 8) & 0xFF);
  return output;
}

function str2rstr_utf16be(input)
{
  var output = "";
  for(var i = 0; i < input.length; i++)
    output += String.fromCharCode((input.charCodeAt(i) >>> 8) & 0xFF,
                                   input.charCodeAt(i)        & 0xFF);
  return output;
}

/*
 * Convert a raw string to an array of little-endian words
 * Characters >255 have their high-byte silently ignored.
 */
function rstr2binl(input)
{
  var output = Array(input.length >> 2);
  for(var i = 0; i < output.length; i++)
    output[i] = 0;
  for(var i = 0; i < input.length * 8; i += 8)
    output[i>>5] |= (input.charCodeAt(i / 8) & 0xFF) << (i%32);
  return output;
}

/*
 * Convert an array of little-endian words to a string
 */
function binl2rstr(input)
{
  var output = "";
  for(var i = 0; i < input.length * 32; i += 8)
    output += String.fromCharCode((input[i>>5] >>> (i % 32)) & 0xFF);
  return output;
}

/*
 * Calculate the MD5 of an array of little-endian words, and a bit length.
 */
function binl_md5(x, len)
{
  /* append padding */
  x[len >> 5] |= 0x80 << ((len) % 32);
  x[(((len + 64) >>> 9) << 4) + 14] = len;

  var a =  1732584193;
  var b = -271733879;
  var c = -1732584194;
  var d =  271733878;

  for(var i = 0; i < x.length; i += 16)
  {
    var olda = a;
    var oldb = b;
    var oldc = c;
    var oldd = d;

    a = md5_ff(a, b, c, d, x[i+ 0], 7 , -680876936);
    d = md5_ff(d, a, b, c, x[i+ 1], 12, -389564586);
    c = md5_ff(c, d, a, b, x[i+ 2], 17,  606105819);
    b = md5_ff(b, c, d, a, x[i+ 3], 22, -1044525330);
    a = md5_ff(a, b, c, d, x[i+ 4], 7 , -176418897);
    d = md5_ff(d, a, b, c, x[i+ 5], 12,  1200080426);
    c = md5_ff(c, d, a, b, x[i+ 6], 17, -1473231341);
    b = md5_ff(b, c, d, a, x[i+ 7], 22, -45705983);
    a = md5_ff(a, b, c, d, x[i+ 8], 7 ,  1770035416);
    d = md5_ff(d, a, b, c, x[i+ 9], 12, -1958414417);
    c = md5_ff(c, d, a, b, x[i+10], 17, -42063);
    b = md5_ff(b, c, d, a, x[i+11], 22, -1990404162);
    a = md5_ff(a, b, c, d, x[i+12], 7 ,  1804603682);
    d = md5_ff(d, a, b, c, x[i+13], 12, -40341101);
    c = md5_ff(c, d, a, b, x[i+14], 17, -1502002290);
    b = md5_ff(b, c, d, a, x[i+15], 22,  1236535329);

    a = md5_gg(a, b, c, d, x[i+ 1], 5 , -165796510);
    d = md5_gg(d, a, b, c, x[i+ 6], 9 , -1069501632);
    c = md5_gg(c, d, a, b, x[i+11], 14,  643717713);
    b = md5_gg(b, c, d, a, x[i+ 0], 20, -373897302);
    a = md5_gg(a, b, c, d, x[i+ 5], 5 , -701558691);
    d = md5_gg(d, a, b, c, x[i+10], 9 ,  38016083);
    c = md5_gg(c, d, a, b, x[i+15], 14, -660478335);
    b = md5_gg(b, c, d, a, x[i+ 4], 20, -405537848);
    a = md5_gg(a, b, c, d, x[i+ 9], 5 ,  568446438);
    d = md5_gg(d, a, b, c, x[i+14], 9 , -1019803690);
    c = md5_gg(c, d, a, b, x[i+ 3], 14, -187363961);
    b = md5_gg(b, c, d, a, x[i+ 8], 20,  1163531501);
    a = md5_gg(a, b, c, d, x[i+13], 5 , -1444681467);
    d = md5_gg(d, a, b, c, x[i+ 2], 9 , -51403784);
    c = md5_gg(c, d, a, b, x[i+ 7], 14,  1735328473);
    b = md5_gg(b, c, d, a, x[i+12], 20, -1926607734);

    a = md5_hh(a, b, c, d, x[i+ 5], 4 , -378558);
    d = md5_hh(d, a, b, c, x[i+ 8], 11, -2022574463);
    c = md5_hh(c, d, a, b, x[i+11], 16,  1839030562);
    b = md5_hh(b, c, d, a, x[i+14], 23, -35309556);
    a = md5_hh(a, b, c, d, x[i+ 1], 4 , -1530992060);
    d = md5_hh(d, a, b, c, x[i+ 4], 11,  1272893353);
    c = md5_hh(c, d, a, b, x[i+ 7], 16, -155497632);
    b = md5_hh(b, c, d, a, x[i+10], 23, -1094730640);
    a = md5_hh(a, b, c, d, x[i+13], 4 ,  681279174);
    d = md5_hh(d, a, b, c, x[i+ 0], 11, -358537222);
    c = md5_hh(c, d, a, b, x[i+ 3], 16, -722521979);
    b = md5_hh(b, c, d, a, x[i+ 6], 23,  76029189);
    a = md5_hh(a, b, c, d, x[i+ 9], 4 , -640364487);
    d = md5_hh(d, a, b, c, x[i+12], 11, -421815835);
    c = md5_hh(c, d, a, b, x[i+15], 16,  530742520);
    b = md5_hh(b, c, d, a, x[i+ 2], 23, -995338651);

    a = md5_ii(a, b, c, d, x[i+ 0], 6 , -198630844);
    d = md5_ii(d, a, b, c, x[i+ 7], 10,  1126891415);
    c = md5_ii(c, d, a, b, x[i+14], 15, -1416354905);
    b = md5_ii(b, c, d, a, x[i+ 5], 21, -57434055);
    a = md5_ii(a, b, c, d, x[i+12], 6 ,  1700485571);
    d = md5_ii(d, a, b, c, x[i+ 3], 10, -1894986606);
    c = md5_ii(c, d, a, b, x[i+10], 15, -1051523);
    b = md5_ii(b, c, d, a, x[i+ 1], 21, -2054922799);
    a = md5_ii(a, b, c, d, x[i+ 8], 6 ,  1873313359);
    d = md5_ii(d, a, b, c, x[i+15], 10, -30611744);
    c = md5_ii(c, d, a, b, x[i+ 6], 15, -1560198380);
    b = md5_ii(b, c, d, a, x[i+13], 21,  1309151649);
    a = md5_ii(a, b, c, d, x[i+ 4], 6 , -145523070);
    d = md5_ii(d, a, b, c, x[i+11], 10, -1120210379);
    c = md5_ii(c, d, a, b, x[i+ 2], 15,  718787259);
    b = md5_ii(b, c, d, a, x[i+ 9], 21, -343485551);

    a = safe_add(a, olda);
    b = safe_add(b, oldb);
    c = safe_add(c, oldc);
    d = safe_add(d, oldd);
  }
  return Array(a, b, c, d);
}

/*
 * These functions implement the four basic operations the algorithm uses.
 */
function md5_cmn(q, a, b, x, s, t)
{
  return safe_add(bit_rol(safe_add(safe_add(a, q), safe_add(x, t)), s),b);
}
function md5_ff(a, b, c, d, x, s, t)
{
  return md5_cmn((b & c) | ((~b) & d), a, b, x, s, t);
}
function md5_gg(a, b, c, d, x, s, t)
{
  return md5_cmn((b & d) | (c & (~d)), a, b, x, s, t);
}
function md5_hh(a, b, c, d, x, s, t)
{
  return md5_cmn(b ^ c ^ d, a, b, x, s, t);
}
function md5_ii(a, b, c, d, x, s, t)
{
  return md5_cmn(c ^ (b | (~d)), a, b, x, s, t);
}

/*
 * Add integers, wrapping at 2^32. This uses 16-bit operations internally
 * to work around bugs in some JS interpreters.
 */
function safe_add(x, y)
{
  var lsw = (x & 0xFFFF) + (y & 0xFFFF);
  var msw = (x >> 16) + (y >> 16) + (lsw >> 16);
  return (msw << 16) | (lsw & 0xFFFF);
}

/*
 * Bitwise rotate a 32-bit number to the left.
 */
function bit_rol(num, cnt)
{
  return (num << cnt) | (num >>> (32 - cnt));
}
/********** END 7/12/2011 MD5 function *************/