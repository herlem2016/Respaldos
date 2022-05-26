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

var GetVal= function(nodo,subnodo,decode){
	var val="";
	var items=$(nodo).children(subnodo);
	if(items.length>0){
		if(decode){		
			val=decodeHTMLEntities($(items[0]).html());
		}else{
			val= $(items[0]).html();
		}
	}
	return val;
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
		dom_contenedor.appendChild(_ROOT_SYSTEM.ProcesarVista(xmlresp));	
	});
}

_ROOT_SYSTEM.ProcesarVista= function(xmlinfo){
	//alert((new XMLSerializer()).serializeToString(xmlinfo));
	var nuevo_dom= CrearDom("div",$(xmlinfo).find("Vista > template")[0]);
	var unidadesUI=$(nuevo_dom).find("ui[nel-ui]");
	for(var i=0;i<unidadesUI.length;i++){		
		_ROOT_SYSTEM.ResolverUnaUnidadUI(unidadesUI[i],$(xmlinfo).children("ui[indice=" + unidadesUI[i].getAttribute("nel-ui") +"]"));
	}
	return nuevo_dom;
}

_ROOT_SYSTEM.ResolverUnaUnidadUI= function(unidadUI,xmlUnidadUI){
	eval("var data=" + GetVal(xmlUnidadUI,'data',true)+";");
	if(data){
		if(data){
			unidadUI.appendChild(_ROOT_SYSTEM.ProcesarUnaUnidadUI(xmlUnidadUI,data));
		}else{
			var 
			$.post({url:"logic/controlador.aspx?opx=" + xmlUnidadUI.getAttribute("opx"), succes:function(xdata,xqr){
				unidadUI.appendChild(_ROOT_SYSTEM.ProcesarUnaUnidadUI(xmlUnidadUI,xdata));
			}});
		}
	}	
}

_ROOT_SYSTEM.ProcesarUnaUnidadUI= function(xmlUnidadUI, data){
	var style=GetVal(xmlUnidadUI,"css");if(style) document.head.appendChild(CrearDom("style",style));
	var script=GetVal(xmlUnidadUI,"javascript");if(script) document.head.appendChild(CrearDom("script",script));
	var nuevo_dom= document.createElement("div");
	nuevo_dom.className= GetVal(xmlUnidadUI,"class");	
	nuevo_dom.innerHTML=GetVal(xmlUnidadUI,"innerHTML",true);
	var wrap=xmlUnidadUI.children("wrap");	
	if(wrap.length>0) _ROOT_SYSTEM.ProcesarRepeticionItem(nuevo_dom.children[0],item_repeat,data,wrap);		
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


function _ROOT_SYSTEM.ProcesarRepeticionItem(container, data, xmlUnidadUI){
	if(data.length>0){
		var item_repeat=GetVal(xmlUnidadUI,"item_repeat",true);
		var wrap=GetVal(xmlUnidadUI,"wrap",true);	
		var nodowrap= document.createElement("div");
		nodowrap.innerHTML=wrap;	
		if(nodowrap.children[0]){
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
					nuevo_dom.appendChild(_ROOT_SYSTEM.ProcesarUnaUnidadUI($(xmlUnidadUI).children("Layout > ui")[0],data[n].items));
				}				
			}
		}
	}	
}

window.onload= function(){
	var url_base= document.body.getAttribute("url");
	var vistaInicial= document.body.getAttribute("vista");
	var contenedor= document.body.getAttribute("contenedor");
	_ROOT_SYSTEM.ConstruirUI(url_base,vistaInicial,contenedor);
}