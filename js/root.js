/*Utilerías*/
function GetDom(obj){
	if(typeof(obj)=="string"){
		obj= document.getElementById(obj);
	}
	return obj;
}

function CrearDom(tag,contenido){
	var nuevo_dom= document.createElement(tag);
	nuevo_dom.innerHTML=contenido;
	return nuevo_dom;
}

var GetVal= function(nodo,tag_nombre){
	return $($(nodo).find(tag_nombre)[0]).text();
}

function decodeHTMLEntities(text) {
    var entities = [
        ['amp', '&'],
        ['apos', '\''],
        ['#x27', '\''],
        ['#x2F', '/'],
        ['#39', '\''],
        ['#47', '/'],
        ['lt', '<'],
        ['gt', '>'],
        ['nbsp', ' '],
        ['quot', '"']
    ];

    for (var i = 0, max = entities.length; i < max; ++i) 
        text = text.replace(new RegExp('&'+entities[i][0]+';', 'g'), entities[i][1]);

    return text;
}
/**/

_ROOT_SYSTEM= function(){}

_ROOT_SYSTEM.ConstruirUI= function(url,proyecto,dom_contenedor){
	dom_contenedor= GetDom(dom_contenedor);
	$.post(url,{seccion:"generic",op:"ObtenerUI",proyecto:proyecto},function(xmlresp){
		dom_contenedor.appendChild(_ROOT_SYSTEM.ProcesarArbolUnidadesUI(xmlresp));		
	});
}

_ROOT_SYSTEM.ProcesarArbolUnidadesUI= function(xmlinfo){
	var nuevo_dom;
	var unidadesUI=$(xmlinfo).find("> NewDataSet > Table");
	if(unidadesUI.length==0){
		nuevo_dom=_ROOT_SYSTEM.ResolverUnaUnidadUI(xmlinfo);
	}else {
		nuevo_dom= document.createElement("div");
		for(var i=0;i<unidadesUI.length;i++){
			nuevo_dom.appendChild(_ROOT_SYSTEM.ProcesarArbolUnidadesUI(unidadesUI[i]));
		}
	}
	return nuevo_dom;
}

_ROOT_SYSTEM.ResolverUnaUnidadUI= function(xmlUnidadUI){
	var style=GetVal(xmlUnidadUI,"css");if(style.length>0) document.head.appendChild(CrearDom("style",style));
	var script=GetVal(xmlUnidadUI,"javascript");if(script.length>0) document.head.appendChild(CrearDom("script",script.length>0?script:""));
	var nuevo_dom= document.createElement("div");	
	nuevo_dom.className= GetVal(xmlUnidadUI,"class");
	nuevo_dom.innerHTML=decodeHTMLEntities(GetVal(xmlUnidadUI,"innerHTML"));
	/*nuevo_dom.style= GetVal(xmlinfo,"evento");
	var atributos=$(xmlinfo).find(" > atributo");
	for(var i=0;i<atributos.length;i++){
		nuevo_dom.setAttribute(GetVal(atributos[i],"nombre"),GetVal(atributos[i],"valor"));
	}
	var eventos=$(xmlinfo).find(" > eventos");
	for(var i=0;i<eventos.length;i++){
		nuevo_dom.addEventListener(GetVal(eventos[i],"evento"),GetVal(eventos[i],"metodo"));
	}*/
	return nuevo_dom;
}


window.onload= function(){
	var url_base= document.body.getAttribute("url");
	var proyecto= document.body.getAttribute("proyecto");
	var contenedor= document.body.getAttribute("contenedor");
	_ROOT_SYSTEM.ConstruirUI(url_base,proyecto,contenedor);
}