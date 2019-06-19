/*!
 * jQuery.extendext 0.1.2
 *
 * Copyright 2014-2016 Damien "Mistic" Sorel (http://www.strangeplanet.fr)
 * Licensed under MIT (http://opensource.org/licenses/MIT)
 *
 * Based on jQuery.extend by jQuery Foundation, Inc. and other contributors
 */
!function(a,b){"function"==typeof define&&define.amd?define(["jquery"],b):"object"==typeof module&&module.exports?module.exports=b(require("jquery")):b(a.jQuery)}(this,function($){"use strict";$.extendext=function(){var a,b,c,d,e,f,g=arguments[0]||{},h=1,i=arguments.length,j=!1,k="default";for("boolean"==typeof g&&(j=g,g=arguments[h++]||{}),"string"==typeof g&&(k=g.toLowerCase(),"concat"!==k&&"replace"!==k&&"extend"!==k&&(k="default"),g=arguments[h++]||{}),"object"==typeof g||$.isFunction(g)||(g={}),h===i&&(g=this,h--);h<i;h++)if(null!==(a=arguments[h]))if($.isArray(a)&&"default"!==k)switch(f=g&&$.isArray(g)?g:[],k){case"concat":g=f.concat($.extend(j,[],a));break;case"replace":g=$.extend(j,[],a);break;case"extend":a.forEach(function(a,b){if("object"==typeof a){var c=$.isArray(a)?[]:{};f[b]=$.extendext(j,k,f[b]||c,a)}else f.indexOf(a)===-1&&f.push(a)}),g=f}else for(b in a)c=g[b],d=a[b],g!==d&&(j&&d&&($.isPlainObject(d)||(e=$.isArray(d)))?(e?(e=!1,f=c&&$.isArray(c)?c:[]):f=c&&$.isPlainObject(c)?c:{},g[b]=$.extendext(j,k,f,d)):void 0!==d&&(g[b]=d));return g}});