/*
 * jQCloud Plugin for jQuery
 *
 * Version 0.1.5
 *
 * Copyright 2011, Luca Ongaro
 * Licensed under the MIT license.
 *
 * Date: Tue Mar 1 11:09:37 +0100 2011
 */
(function(a){a.fn.jQCloud=function(c,f){var e=this;var d=e.attr("id");e.addClass("jqcloud");var b=function(){var h=function(p,n){var m=function(r,q){if(Math.abs(2*r.offsetLeft+r.offsetWidth-2*q.offsetLeft-q.offsetWidth)<r.offsetWidth+q.offsetWidth){if(Math.abs(2*r.offsetTop+r.offsetHeight-2*q.offsetTop-q.offsetHeight)<r.offsetHeight+q.offsetHeight){return true}}return false};var o=0;for(o=0;o<n.length;o++){if(m(p,n[o])){return true}}return false};c.sort(function(n,m){if(n.weight<m.weight){return 1}else{if(n.weight>m.weight){return -1}else{return 0}}});var j=2;var g=[];var i=e.width()/e.height();var l=e.width()/2;var k=e.height()/2;a.each(c,function(s,m){var q=d+"_word_"+s;var u="#"+q;var p=6.28*Math.random();var t=0;var r=Math.round((m.weight-c[c.length-1].weight)/(c[0].weight-c[c.length-1].weight)*9)+1;var x=m.url!==undefined?"<a href='"+m.url+"'>"+m.text+"</a></span>":m.text;e.append("<span id='"+q+"' class='w"+r+"' title='"+(m.title||"")+"'>"+x+"</span>");var n=a(u).width();var w=a(u).height();var o=l-n/2;var v=k-w/2;a(u).css("position","absolute");a(u).css("left",o+"px");a(u).css("top",v+"px");while(h(document.getElementById(q),g)){t+=j;p+=(s%2===0?1:-1)*j;o=l+(t*Math.cos(p)-(n/2))*i;v=k+t*Math.sin(p)-(w/2);a(u).css("left",o+"px");a(u).css("top",v+"px")}g.push(document.getElementById(q))});if(typeof f==="function"){f.call(this)}};setTimeout(function(){b()},100);return this}})(jQuery);
