




/*
     FILE ARCHIVED ON 2:54:42 Jul 12, 2007 AND RETRIEVED FROM THE
     INTERNET ARCHIVE ON 21:06:20 Aug 7, 2011.
     JAVASCRIPT APPENDED BY WAYBACK MACHINE, COPYRIGHT INTERNET ARCHIVE.

     ALL OTHER CONTENT MAY ALSO BE PROTECTED BY COPYRIGHT (17 U.S.C.
     SECTION 108(a)(3)).
*/
// autocomplete and related changes 
// Copyright 2004 Leslie A. Hensley
// hensleyl@papermountain.org
// you have a license to do what ever you like with this code
// orginally from Avi Bryant 
// http://web.archive.org/web/20070712025442/http://www.cincomsmalltalk.com/userblogs/avi/blogView?entry=3268075684

if (navigator.userAgent.indexOf("Safari") > 0)
{
  isSafari = true;
  isMoz = false;
  isIE = false;
}
else if (navigator.product == "Gecko")
{
  isSafari = false;
  isMoz = true;
  isIE = false;
}
else
{
  isSafari = false;
  isMoz = false;
  isIE = true;
}
    
function liveUpdaterUri(uri)
{
    return liveUpdater(function() { return uri; }, function () {});
}

function liveUpdater(uriFunc, writeEle, postFunc)
{
    var request = false;
    var regex = /<hobixResponse>((.|\n)*)<\/hobixResponse>/;
    
    if (window.XMLHttpRequest) {
        request = new XMLHttpRequest();
    }
    
    function update()
    {
        if(request && request.readyState < 4)
            request.abort();
            
        if(!window.XMLHttpRequest)
            request = new ActiveXObject("Microsoft.XMLHTTP");
        
        request.onreadystatechange = processRequestChange;
        request.open("GET", uriFunc(), true);
        request.send(null);
        return false;
    }
    
    function processRequestChange()
    {
        if(request.readyState == 4)
        {
            var results = regex.exec(request.responseText);
            if(results)
            {
                text = results[1];
                text = text.replace( /\&gt;/g, '>' ).replace( /\&lt;/g, '<' ).replace( /\&quot;/g, '"' ).replace( /\&amp;/g, '&' )
                document.getElementById(writeEle).innerHTML = text;
                postFunc();
            }
        }
    }

    return update;
}

function liveTextilePreview(readEle, writeEle, uri)
{
    function constructUri()
    {
        var separator = "?";
        if(uri.indexOf("?") >= 0)
            separator = "&";
        return uri + separator + "s=" + encodeURIComponent(readEle.value);
    }
    
    var updater = liveUpdater(constructUri, writeEle, function() {});
    var timeout = false;
        
    if (timeout)
        window.clearTimeout(timeout);
    
    timeout = window.setTimeout(updater, 400);
}

/* Functions to handle browser incompatibilites */
function eventElement(event)
{
  if(isMoz)
  {
    return event.currentTarget;
  }
  else
  {
    return event.srcElement;
  }
}

function addKeyListener(element, listener)
{
  if (isSafari)
    element.addEventListener("keydown",listener,false);
  else if (isMoz)
    element.addEventListener("keypress",listener,false);
  else
    element.attachEvent("onkeydown",listener);
}

function addBlurListener(element, listener)
{
  if(isIE)
    element.attachEvent("onblur",listener);
  else
    element.addEventListener("blur", listener, false);
}   

function liveTimer() {
    var ele = document.getElementById( "liveTime" );
    if ( typeof( ele ) != 'undefined' )
    {
        var t=new Date();
        ele.innerHTML = (new Date()).strftime("<strong>%b %d</strong> <nobr>%H:%M</nobr>");
        if (typeof(timerOut) != 'undefined')
            window.clearTimeout(timerOut);
    
        timerOut = window.setTimeout(liveTimer, 50000);
    }
}

window.onload = function () {
    liveTimer();
}
