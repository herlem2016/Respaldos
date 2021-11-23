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

var GetValAttr= function(nodo,attr){
	return $(nodo).attr(attr);
}

function decodeHTMLEntities(text) {
	if(text){
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
	}

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
	var unidadesUI=$(xmlinfo).find("ui > unidadUI");
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

_ROOT_SYSTEM.CargarInfoUnidadUI= function(sdiv_repeat, opx){
	$.post({sdiv_repeat:sdiv_repeat,url:"logic/controlador.aspx?op=ObtenerOPX&seccion=generic&opx=" + opx, succes:function(data,xqr){ eval("Fn_Repeat_" + sdiv_repeat + "_" + opx + "(data,xqr,$('#" + sdiv_repeat + "'));"); }});
}

_ROOT_SYSTEM.ResolverUnaUnidadUI= function(xmlUnidadUI){
	var unTipoUI=$(xmlUnidadUI).find("tipoUnidadUI")[0];
	var style=GetValAttr(unTipoUI,"css");if(style) document.head.appendChild(CrearDom("style",style));
	var script=GetValAttr(unTipoUI,"javascript");if(script) document.head.appendChild(CrearDom("script",script));
	var nuevo_dom= document.createElement("div");	
	nuevo_dom.className= GetValAttr(unTipoUI,"class");
	nuevo_dom.innerHTML=decodeHTMLEntities(GetValAttr(unTipoUI,"innerHTML"));
	//Obtenemos las propiedades del TipoUI
	var propiedades=$(unTipoUI).find("propiedad");
	for(var i=0;i<propiedades.length;i++){
		$.each($(nuevo_dom).find("[em-id='" + propiedades[i].getAttribute("descripcion") + "']"), function(index,obj){
			obj.innerHTML=propiedades[i].children[0].getAttribute("valor");
		});
	}
	if(unTipoUI.getAttribute("es_recargable_db")=="1"){
		var opx1= xmlUnidadUI.getAttribute("opx_rec_db");	
		document.head.appendChild(CrearDom("script","var Fn_Repeat_" + this.div_repeat + "_" + opx1 + "=" + xmlUnidadUI.getAttribute("callback_rec_db")));
		nuevo_dom.append(CrearDom("script","_ROOT_SYSTEM.CargarInfoUnidadUI('" + unTipoUI.getAttribute("obj_recargable_db") + "','" + (opx1?opx1:"0") + "');"));
	}
	

	/*nuevo_dom.style= GetValAttr(xmlinfo,"evento");
	var atributos=$(xmlinfo).find(" > atributo");
	for(var i=0;i<atributos.length;i++){
		nuevo_dom.setAttribute(GetValAttr(atributos[i],"nombre"),GetValtAtr(atributos[i],"valor"));
	}
	var eventos=$(xmlinfo).find(" > eventos");
	for(var i=0;i<eventos.length;i++){
		nuevo_dom.addEventListener(GetValAttr(eventos[i],"evento"),GetValAttr(eventos[i],"metodo"));
	}*/


	return nuevo_dom;
}


window.onload= function(){
	var url_base= document.body.getAttribute("url");
	var proyecto= document.body.getAttribute("proyecto");
	var contenedor= document.body.getAttribute("contenedor");
	_ROOT_SYSTEM.ConstruirUI(url_base,proyecto,contenedor);
}