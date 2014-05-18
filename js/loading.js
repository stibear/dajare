function getUrlVars()
{
    var vars = {}; 
    var param = location.search.substring(1).split('&');
    for(var i = 0; i < param.length; i++) {
        var keySearch = param[i].search(/=/);
        var key = '';
        if(keySearch != -1) key = param[i].slice(0, keySearch);
        var val = param[i].slice(param[i].indexOf('=', 0) + 1);
        if(key != '') vars[key] = decodeURI(val);
    } 
    return vars; 
}

function moreload() {
    var getparams = getUrlVars();
    var result;
    // クルクル画像を表示
    showLoadingImage();
    $.ajax({
        type: "GET",
        url: "dajare",
        dataType: "json",
	data: {
	    sent: getparams["sent"],
	    exp: getparams["exp"]
	},
        success: function(json){
	    result = JSON.stringify(json);
        },
        complete: function (json) { // finally
            hideLoadingImage();
	    showResult(result);
	    // alert(json);
        },
        error: function (XMLHttpRequest, textStatus, errorThrown){
	    alert("error!");
        }
    })
}
// クルクル画像表示
function showLoadingImage() {
    $("#loading").append('<img src="img/loading.gif">');
}
// クルクル画像消去
function hideLoadingImage() {
    // ゆっくり消すためにfadeout(500)を指定してますが、hide()とかでも良いです。
    $("#loading").fadeOut(500);
}

function showResult(result) {
    $("#main").append("<div id=\"tagcloud\" style=\"overflow: hidden;\" onmouseover=\"onMouseCloud();\" onmouseout=\"offMouseCloud();\" onmousemove=\"mouseHandler(event);\" />\n\
<div id=\"tagcloudInner\" style=\"position:relative;\"></div>\n\
</div>\n\
<script type=\"text/javascript\">\n\
<!--\n\
var cloudSize = 600; // px クラウドサイズ(縦横共通) カラムの幅(width)と同じ値を設定してください。\n\
var maxTagNum = 200; // タグの最大表示件数 -1:全件表示\n\
var darkColor = 0; // 最も手前にあるときの文字の暗さ 0～255\n\
var lightColor = 216; // 最も 奥 にあるときの文字の明るさ 0～255\n\
var linkColor = \"#FF6600\"; // タグにマウスが乗った時の色\n\
var maxFont = 144; // px 使用回数最多のタグのフォントサイズ\n\
var minFont = 144; // px 使用回数最少のタグのフォントサイズ\n\
var rewriteSec = 10; // 再描画間隔(ミリ秒)\n\
var maxVelocity = 2000; // 1周にかかるおよそのミリ秒数\n\
var attenuation = 0.95; // 減衰率 (0～1) マウスオーバーしていないときの速度の減衰率\n\
var perspective = 0.50; // 遠近率 (0～1) 遠くなったときのフォントサイズ比率\n\
var initrthv = 1.50; // 初期回転軸角速度（0～）\n\
var wordKey = \"word\";\n\
var wordKeyAnc = wordKey + \"Anc\";\n\
var tagcloudArea = \"tagcloudInner\";\n\
document.getElementById(\"tagcloud\").style.width=cloudSize+\"px\";\n\
document.getElementById(\"tagcloud\").style.height=cloudSize+\"px\";\n\
var cloudWidth = cloudSize;\n\
var cloudHeight = cloudSize;\n\
var cloudRad = cloudSize/2*0.8; // タグクラウド領域半径\n\
var dx = 1/Math.sqrt(2); // 初期回転軸方向 単位法線\n\
var dy = 1/Math.sqrt(2); // 初期回転軸方向 単位法線\n\
var rvconst = 2 * Math.PI * rewriteSec / maxVelocity; // 回転角速度\n\
var rthv = initrthv * rvconst; // 回転軸角速度（0～）\n\
var isOnMouseCloud = false;\n\
var mouseX = 0;\n\
var mouseY = 0;\n\
var isOnAnc = false;\n\
var tagNameList = " + result + ";\n\
//tagNameList.shift();\n\
var tagLinkList = tagNameList;\n\
//tagLinkList.shift();\n\
var tagNumList = tagNameList;\n\
//tagNumList.shift();\n\
var posi = new Array();\n\
var dtag = new Array();\n\
var atag = new Array();\n\
var minCount = 0;\n\
var maxCount = 0;\n\
mouseCheck();\n\
drowCloud();\n\
function drowCloud()\n\
{\n\
if (tagNumList.length==0) return;\n\
if (maxTagNum>0 && tagNumList.length>maxTagNum)\n\
{\n\
tagNameList.splice(maxTagNum, tagNameList.length-maxTagNum);\n\
tagLinkList.splice(maxTagNum, tagLinkList.length-maxTagNum);\n\
tagNumList.splice (maxTagNum, tagNumList.length -maxTagNum);\n\
}\n\
minCount = tagNumList[0];\n\
maxCount = tagNumList[0];\n\
for (i=1;i<tagNameList.length-1;i++)\n\
{\n\
if (minCount > tagNumList[i]) minCount = tagNumList[i];\n\
else if (maxCount < tagNumList[i]) maxCount = tagNumList[i];\n\
}\n\
if (minCount==maxCount) {minCount-=0.5; maxCount+=0.5;}\n\
var cntsqrX = Math.ceil(Math.sqrt(tagNameList.length));\n\
var cntsqrY = cntsqrX;\n\
if (cntsqrX*(cntsqrY+1)<=tagNameList.length)\n\
{\n\
cntsqrY += 1;\n\
}\n\
for (i=0;i<tagNameList.length;i++)\n\
{\n\
var sfont = (maxFont-minFont)/(Math.log(maxCount)-Math.log(minCount))*(Math.log(tagNumList[i])-Math.log(minCount)) + minFont;\n\
posi[i] = new Position(tagNameList[i], tagLinkList[i], sfont);\n\
}\n\
// シャッフル\n\
posi.sort(function(a,b) {return Math.random()-0.5;});\n\
// 初期位置\n\
var tagcnt=0;\n\
var forExit=false;\n\
for (i=0;i<cntsqrX;i++)\n\
{\n\
var x = (i+0.5)/cntsqrX;\n\
for (j=0;j<cntsqrY;j++)\n\
{\n\
var y = (j+0.5)/cntsqrY;\n\
var rndth = 2*Math.acos(Math.sqrt(1-x));\n\
var rndfi = 2*Math.PI*y;\n\
var sinth = Math.sin(rndth);\n\
posi[tagcnt].x=sinth*Math.cos(rndfi);\n\
posi[tagcnt].y=sinth*Math.sin(rndfi);\n\
posi[tagcnt].z=Math.cos(rndth);\n\
tagcnt++;\n\
if (tagcnt >= posi.length)\n\
{\n\
forExit=true;\n\
break;\n\
}\n\
}\n\
if (forExit) break;\n\
}\n\
var I=\"\";\n\
for (i=0;i<posi.length;i++)\n\
{\n\
I += posi[i].getInitHTML(i);\n\
}\n\
document.getElementById(tagcloudArea).innerHTML = I;\n\
for (i=0;i<posi.length;i++)\n\
{\n\
posi[i].width = document.getElementById(wordKey+i).offsetWidth;\n\
posi[i].height = document.getElementById(wordKey+i).offsetHeight;\n\
dtag[i] = document.getElementById(wordKey + i);\n\
atag[i] = document.getElementById(wordKeyAnc + i);\n\
}\n\
rotateLoop();\n\
}\n\
////////////////////////////////////////////////////////////////\n\
function rotateLoop()\n\
{\n\
if (isOnMouseCloud)\n\
{\n\
var dx1 = (mouseX - cloudWidth /2) / cloudRad;\n\
var dy1 = (mouseY - cloudHeight/2) / cloudRad;\n\
dx1 = Math.max(-1,Math.min(1,dx1));\n\
dy1 = Math.max(-1,Math.min(1,dy1));\n\
var rlength = Math.sqrt(dx1*dx1+dy1*dy1);\n\
if (rlength>0.001)\n\
{\n\
dx= dy1/rlength; // マウスのx位置はy軸に影響\n\
dy=-dx1/rlength; // マウスのy位置はx軸に影響\n\
rthv = rlength*rvconst;\n\
}\n\
}\n\
else\n\
{\n\
rthv *= attenuation;\n\
}\n\
var cosr = Math.cos(rthv);\n\
var sinr = Math.sin(rthv);\n\
var cost = 1-cosr;\n\
// 座標変換\n\
for (i=0,len=posi.length;i<len;i++)\n\
{\n\
var dxcost = dx*cost;\n\
var dxdycost = dxcost*dy;\n\
var dxsinr = dx*sinr;\n\
var dysinr = dy*sinr;\n\
var x1=(dx*dxcost +cosr)*posi[i].x+ dxdycost *posi[i].y+dysinr *posi[i].z;\n\
var y1= dxdycost *posi[i].x+(dy*dy*cost+cosr)*posi[i].y-dxsinr *posi[i].z;\n\
var z1=- dysinr *posi[i].x+ dxsinr *posi[i].y+ cosr*posi[i].z;\n\
posi[i].x=x1;\n\
posi[i].y=y1;\n\
posi[i].z=z1;\n\
}\n\
// 奥から表示するために簡易ソート\n\
for (i=0,len=posi.length-1;i<len;i++)\n\
{\n\
if (posi[i].z > posi[i+1].z) {\n\
var t = posi[i];\n\
posi[i] = posi[i+1];\n\
posi[i+1] = t;\n\
}\n\
}\n\
// 再描画\n\
for (i=0,len=posi.length;i<len;i++)\n\
{\n\
posi[i].updateHTML(i);\n\
}\n\
setTimeout('rotateLoop()',rewriteSec);\n\
}\n\
function mouseCheck()\n\
{\n\
if (isOnAnc==true) offMouseCloud();\n\
setTimeout('mouseCheck()',1500);\n\
}\n\
function onMouseCloud()\n\
{\n\
isOnMouseCloud=true;\n\
};\n\
function offMouseCloud ()\n\
{\n\
isOnMouseCloud=false;\n\
};\n\
function mouseHandler (event)\n\
{\n\
if (!event) event = window.event;\n\
var mox;\n\
var moy;\n\
if (document.all) { // for IE\n\
mox = event.offsetX;\n\
moy = event.offsetY;\n\
} else {\n\
mox = event.layerX;\n\
moy = event.layerY;\n\
}\n\
var elem;\n\
if (event.target) { // Firefox\n\
elem = event.target;\n\
}\n\
else if (window.event.srcElement) { // IE\n\
elem = window.event.srcElement;\n\
}\n\
if (elem.name)\n\
{\n\
var id = Number(elem.name.substring(wordKeyAnc.length));\n\
var w = posi[id].width;\n\
var h = posi[id].height;\n\
mouseX = Math.floor( mox + posi[id].x * cloudRad+cloudWidth /2 - w/2);\n\
mouseY = Math.floor( moy + posi[id].y * cloudRad+cloudHeight/2 - h/2);\n\
isOnAnc=true;\n\
}\n\
else\n\
{\n\
mouseX = mox;\n\
mouseY = moy;\n\
isOnAnc=false;\n\
}\n\
};\n\
function onMouseAnc (event)\n\
{\n\
if (!event) event = window.event;\n\
var elem;\n\
if (event.target) { // Firefox\n\
elem = event.target;\n\
}\n\
else if (window.event.srcElement) { // IE\n\
elem = window.event.srcElement;\n\
}\n\
if (elem.name)\n\
{\n\
var id = Number(elem.name.substring(wordKeyAnc.length));\n\
posi[id].onMouse();\n\
}\n\
};\n\
function offMouseAnc(event)\n\
{\n\
if (!event) event = window.event;\n\
var elem;\n\
if (event.target) { // Firefox\n\
elem = event.target;\n\
}\n\
else if (window.event.srcElement) { // IE\n\
elem = window.event.srcElement;\n\
}\n\
if (elem.name)\n\
{\n\
var id = Number(elem.name.substring(wordKeyAnc.length));\n\
posi[id].offMouse();\n\
}\n\
for (i=0,len=posi.length;i<len;i++)\n\
{\n\
posi[i].offMouse();\n\
}\n\
}\n\
function getStyleW(id)\n\
{\n\
return getStyle(wordKey + id);\n\
}\n\
function getStyle(name)\n\
{\n\
var element = document.getElementById(name);\n\
return (element.currentStyle || document.defaultView.getComputedStyle(element, ''));\n\
}\n\
//// Positionクラス\n\
function Position(tag, link, f)\n\
{\n\
this.tag=tag;\n\
this.link=link;\n\
this.f=f; // font\n\
this.x=0;\n\
this.y=0;\n\
this.z=0;\n\
this.isOnMouse=false;\n\
this.onMouse = function() {\n\
this.isOnMouse=true;\n\
};\n\
this.offMouse = function() {\n\
this.isOnMouse=false;\n\
};\n\
this.getInitHTML = function(id) {\n\
return this.getHTMLInner(id, -10000, -10000, 12);\n\
};\n\
this.getHTMLInner = function(id , left, top, sfont) {\n\
var clr = Math.round(lightColor-(this.z+1)/2*(lightColor-darkColor));\n\
var clrs = clr.toString(16); // 16進数文字列に変換\n\
clrs = \"#\" + clrs+clrs+clrs;\n\
var I = \"<div id='\" + wordKey + id +\n\
\"' style='position:absolute;text-align:center;vertical-align:middle;left:\" + left +\n\
\"px;top:\" + top + \"px;font-size:\" + sfont + \"px;white-space:nowrap;font-weight:bold;'>\" +\n\
\"<a href='\" + this.link + \"' name='\" + wordKeyAnc + id + \"' id='\" + wordKeyAnc + id +\n\
\"' style='text-decoration: none;color:\" + clrs +\n\
\"' onmouseover='onMouseAnc(event);' onmouseout='offMouseAnc(event);'>\" +\n\
this.tag + \"</a></div>\";\n\
return I;\n\
};\n\
this.updateHTML = function(id) {\n\
var left =(this.x*cloudRad+cloudWidth /2)-this.width /2;\n\
var top =(this.y*cloudRad+cloudHeight/2)-this.height/2;\n\
var sfont=this.f*((this.z+1)/2*(1-perspective)+perspective);\n\
dtag[id].style.left= left + \"px\";\n\
dtag[id].style.top = top + \"px\";\n\
dtag[id].style.fontSize= sfont + \"px\";\n\
if (atag[id].href != this.link) {\n\
atag[id].href = this.link;\n\
atag[id].innerText = this.tag;\n\
}\n\
var clrs = \"\";\n\
if (this.isOnMouse) {\n\
clrs = linkColor;\n\
}\n\
else {\n\
var clr = Math.round(lightColor-(this.z+1)/2*(lightColor-darkColor));\n\
clrs = clr.toString(16); // 16進数文字列に変換\n\
clrs = \"#\" + clrs+clrs+clrs;\n\
}\n\
atag[id].style.color = clrs;\n\
this.width = dtag[id].offsetWidth;\n\
this.height = dtag[id].offsetHeight;\n\
};\n\
}\n\
// -->\n\
");
}
