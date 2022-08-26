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

_ROOT_SYSTEM.ConstruirUI= function(url,vista,dom_contenedor){
	dom_contenedor= GetDom(dom_contenedor);
	$.post(url,{seccion:"generic",op:"ObtenerUI",vista:vista},function(xmlresp){
		dom_contenedor.appendChild(_ROOT_SYSTEM.ProcesarArbolUnidadesUI(xmlresp));		
	});
}

_ROOT_SYSTEM.ProcesarArbolUnidadesUI= function(xmlinfo){
	var nuevo_dom;
	var unidadesUI=$(xmlinfo).find("ui > unidadUI");
	if(unidadesUI.length==0){
		nuevo_dom=_ROOT_SYSTEM.ResolverUnaUnidadUI(xmlinfo);
	}else{
		nuevo_dom= document.createElement("div");
		for(var i=0;i<unidadesUI.length;i++){
			nuevo_dom.appendChild(_ROOT_SYSTEM.ProcesarArbolUnidadesUI(unidadesUI[i]));
		}
	}
	return nuevo_dom;
}

_ROOT_SYSTEM.CargarInfoUnidadUI= function(sdiv_repeat, opx){
	$.post({url:"logic/controlador.aspx?op=GenerarOperacionCX_DB&seccion=generic&opx=" + opx, succes:function(data,xqr){ eval("Fn_Repeat_" + sdiv_repeat + "_" + opx + "(data,xqr,$('#" + sdiv_repeat + "'));"); }});
}

_ROOT_SYSTEM.ResolverUnaUnidadUI= function(xmlUnidadUI){
	var unTipoUI=$(xmlUnidadUI).find("tipoUnidadUI")[0];
	var style=GetValAttr(unTipoUI,"css");if(style) document.head.appendChild(CrearDom("style",style));
	var script=GetValAttr(unTipoUI,"javascript");if(script) document.head.appendChild(CrearDom("script",script));
	var nuevo_dom= document.createElement("div");
	nuevo_dom.className= GetValAttr(unTipoUI,"class");	
	nuevo_dom.innerHTML=decodeHTMLEntities(GetValAttr(unTipoUI,"innerHTML"));
	var item_repeat=GetValAttr(unTipoUI,"item_repeat"),wrap=GetValAttr(unTipoUI,"wrap");
	eval("var data=" + decodeHTMLEntities(xmlUnidadUI.getAttribute('data'))+";");
	if(item_repeat){
		if(data) ProcesarRepeticionItem(nuevo_dom.children[0],item_repeat,data,wrap);
		else{
			$.post({url:"logic/controlador.aspx?opx=" + xmlUnidadUI.getAttribute("opx"), succes:function(xdata,xqr){
				ProcesarRepeticionItem(nuevo_dom.children[0],item_repeat,xdata,wrap);
			}});
		}
	}
	//Obtenemos las propiedades del TipoUI
	/*var propiedades=$(unTipoUI).find("propiedad");
	for(var i=0;i<propiedades.length;i++){
		$.each($(nuevo_dom).find("[em-id='" + propiedades[i].getAttribute("descripcion") + "']"), function(index,obj){
			obj.innerHTML=propiedades[i].children[0].getAttribute("valor");
		});
	}
	
	if(unTipoUI.getAttribute("es_recargable_db")=="1"){
		var opx1= xmlUnidadUI.getAttribute("opx_rec_db");	
		if(opx1){
			document.head.appendChild(CrearDom("script","var Fn_Repeat_" + unTipoUI.getAttribute("obj_recargable_db") + "_" + opx1 + "=" + (xmlUnidadUI.getAttribute("callback_rec_db")?xmlUnidadUI.getAttribute("callback_rec_db"):"function{}") ));
			nuevo_dom.append(CrearDom("script","_ROOT_SYSTEM.CargarInfoUnidadUI('" + unTipoUI.getAttribute("obj_recargable_db") + "','" + opx1 + "');"));
		}
	}*/
	
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


function ProcesarRepeticionItem(container, _item_repeat, data,wrap){
	if(data.length>0){	
		var nodowrap= document.createElement("div");
		nodowrap.innerHTML=wrap;	
		nodowrap= container.appendChild(nodowrap.children[0]);
		var w=_item_repeat.match(/(?:^|\W)@(\w+)(?!\w)/g);
		var child,item_repeat,child;
		for(var n=0; n<data.length;n++){
			item_repeat= _item_repeat;
			for(var i=0;i<w.length;i++){
				var w_i=w[i].substring(w[i].indexOf("@"),w[i].length).trim();
				item_repeat=item_repeat.replace(w_i,data[n][w_i]);
			}
			child= document.createElement("div");
			child.innerHTML=item_repeat;
			child=nodowrap.appendChild(child.children[0]);
			if(data[n].items !=null && data[n].items.length>0){				
				ProcesarRepeticionItem(child,_item_repeat,data[n].items,wrap);
			}
		}
	}	
}
/*
function ProcesarRepeticionItem(container, dom_model, xml_data,wrap,enable_wrap){	
	var nodos=$(xml_data).child(".item");
	var nodowrap=container;
	if(nodos.length>0){		
		if(!enable_wrap){
			wrap=container.outerHTML;
			nodowrap=container;
		}else{
			nodowrap= document.createElement("div");
			nodowrap.innerHTML=wrap;
			container.appendChild(nodowrap.firstChild);
			var nodos_cont=container.children;
			if(nodos_cont.length>0){
				container=$(nodowrap).find(".container")[0];
				if(!container){
					container=nodos_cont[nodos_cont.length-1];
				}
			}
		}
		var w=item_repeat.match(/(?:^|\W)@(\w+)(?!\w)/g);
		var child,item_repeat,child;
		for(var n=0; n<nodos.length;n++){
			item_repeat= dom_model;
			for(var i=0;i<w.length;i++){
				item_repeat=item_repeat.replace(w[i],GetValor(nodos[n],w[i]));
			}
			child= document.createElement("div");
			child.innerHTML=item_repeat;
			nodowrap.appendChild(child.firstChild);
			if($(nodos[i]).child("item")>0){				
				ProcesarRepeticionItem(wrap, child.firstChild,dom_model, nodos[i],true);
			}
		}
	}	
}*/

window.onload= function(){
	var url_base= document.body.getAttribute("url");
	var vistaInicial= document.body.getAttribute("vista");
	var contenedor= document.body.getAttribute("contenedor");
	_ROOT_SYSTEM.ConstruirUI(url_base,vistaInicial,contenedor);
}