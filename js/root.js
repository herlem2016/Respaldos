/*Utilerías*/
function GetDom(obj){
	if(typeof(obj)=="string"){
		obj= document.getElementById(obj);
	}
	return obj;
}

function CrearDom(tag,contenido,decode){
	var nuevo_dom= document.createElement(tag);
	if(decode){
		nuevo_dom.innerHTML=decodeHTMLEntities(contenido);
	}else{
		nuevo_dom.innerHTML=contenido;
	}
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
	_ROOT_SYSTEM.dom_contenedor=dom_contenedor;
	dom_contenedor= GetDom(dom_contenedor);
	$.post(url,{seccion:"generic",op:"ObtenerVista",vista:vista},function(xmlresp){		
		dom_contenedor.appendChild(_ROOT_SYSTEM.ProcesarVista(url,xmlresp));	
	});
}

_ROOT_SYSTEM.ProcesarVista= function(url,xmlinfo){
	var nuevo_dom= CrearDom("section",$($(xmlinfo).find("Layout > html")[0]).html(),true);
	nuevo_dom.className="present";
	var jscript= CrearDom("script",$($(xmlinfo).find("Layout > javascript")[0]).html());	
	document.head.appendChild(jscript);
	var fcss= CrearDom("style",$($(xmlinfo).find("Layout > css")[0]).html());
	document.head.appendChild(fcss);
	var unidadesUI=$(nuevo_dom).find("div[nel-ui]");
	var tiposUI=[];
	for(var i=0;i<unidadesUI.length;i++){		
		tiposUI[i]=unidadesUI[i].getAttribute("nel-ui");
	}
	if(tiposUI.length>0){
		$.post(url,{seccion:"generic",op:"ObtenerComponentes",componentes:tiposUI.join(",")},function(xmlresp){
			for(var i=0;i<unidadesUI.length;i++){
				_ROOT_SYSTEM.ResolverUnaUnidadUI(unidadesUI[i],$(xmlresp).find("Layout > UnidadUI[tipoUnidadUI=" + unidadesUI[i].getAttribute("nel-ui") +"]")[0]);				
			}	
		});	
	}
	return nuevo_dom;
}

_ROOT_SYSTEM.ResolverUnaUnidadUI= function(unidadUI,xmlUnidadUI){
	eval("var data=" + unidadUI.getAttribute('data')+ ";");
	if(data){
		unidadUI.appendChild(_ROOT_SYSTEM.ProcesarUnaUnidadUI(xmlUnidadUI,data));
	}else{
		$.post({url:"logic/controlador.aspx?opx=" + unidadUI.getAttribute("opx"), succes:function(xdata,xqr){
			unidadUI.appendChild(_ROOT_SYSTEM.ProcesarUnaUnidadUI(xmlUnidadUI,xdata));
		}});
	}
}

_ROOT_SYSTEM.ProcesarUnaUnidadUI= function(xmlUnidadUI, data){
	var style=GetVal(xmlUnidadUI,"css");if(style) document.head.appendChild(CrearDom("style",style));
	var script=GetVal(xmlUnidadUI,"javascript");if(script) document.head.appendChild(CrearDom("script",script));
	var nuevo_dom= document.createElement("div");	
	nuevo_dom.className= GetVal(xmlUnidadUI,"class");	
	nuevo_dom.innerHTML=GetVal(xmlUnidadUI,"innerHTML",true);
	var subitem;	
	try{
		eval("Constructor_" + xmlUnidadUI.getAttribute("tipoUnidadUI") + "(nuevo_dom,data);");
		for(var subitem in data){
			for(var property in data[subitem]){
				try{
					console.log(subitem+"."+property + ":" + data[subitem][property]);
					//if(typeof(data[subitem][property])=="function"){
					//	var fn_=data[subitem][property];
					//	$(nuevo_dom).find("[node_ui=" + subitem + "]")[0][property]=function(){fn_(this,nuevo_dom);};
					//}else{
					var node_ui=$(nuevo_dom).find("[node_ui=" + subitem + "]")[0];
					if(node_ui){node_ui[property]=data[subitem][property];}
					//}
				}catch(e){console.log(e.message);}
			}
		}
	}catch(e){
		alert(e.message);
	}	
	data.componentBase=nuevo_dom;
	var wrap=$(xmlUnidadUI).children("wrap");		
	if(wrap.length>0) _ROOT_SYSTEM.ProcesarRepeticionItem(nuevo_dom.children[0],data,xmlUnidadUI);	
	
	return nuevo_dom;
}


_ROOT_SYSTEM.ProcesarRepeticionItem= function(container, data, xmlUnidadUI){	
	if(data.length>0){
		var wrap=GetVal(xmlUnidadUI,"wrap",true);	
		var nodowrap= document.createElement("div");
		var _item_repeat=GetVal(xmlUnidadUI,"item_repeat",true);
		nodowrap.innerHTML=wrap;	
		if(nodowrap.children[0]){
			nodowrap= container.appendChild(nodowrap.children[0]);
			//var w=_item_repeat.match(/(?:^|\W)@(\w+)(?!\w)/g);
			var child,item_repeat,child,info;;
			for(var n=0; n<data.length;n++){
				if(data[n].info){
					info=data[n].info;
				}else{
					info=data[n];
				}
				item_repeat= _item_repeat;
				for(var campo in info){
					item_repeat=item_repeat.replace("@" + campo,info[campo]);
				}
				child= document.createElement("div");
				child.innerHTML=item_repeat;
				child=nodowrap.appendChild(child.children[0]);		
				if(data[n].click){
					eval("var fn_callback=" + data[n].click+";");	
					child.info=info;
					child.onclick=function(){fn_callback(this.info);}					
				}	
				var nextUnidadUI=$(xmlUnidadUI).find("Layout > UnidadUI")[0];	
				if(nextUnidadUI && data[n].items !=null && data[n].items.length>0){				
					//alert(new XMLSerializer().serializeToString(nextUnidadUI));				
					child.appendChild(_ROOT_SYSTEM.ProcesarUnaUnidadUI(nextUnidadUI,data[n].items));
				}				
			}
		}
	}	
}

_ROOT_SYSTEM.AddView= function(view){	
	dom_contenedor= GetDom(_ROOT_SYSTEM.dom_contenedor);
	$.post(_ROOT_SYSTEM.url_base,{seccion:"generic",op:"ObtenerVista",vista:view},function(xmlresp){		
		dom_contenedor.appendChild(_ROOT_SYSTEM.ProcesarVista(_ROOT_SYSTEM.url_base,xmlresp));
		Reveal.slide(Reveal.getSlides().length-1);
	});
}

function CrearPantalla(contenedor,callback){
	var slide= document.createElement("section");
	callback(slide);
	contenedor=(typeof(contenedor)=="string"?document.getElementById(contenedor):contenedor);
	contenedor.appendChild(slide);
	Reveal.slide(Reveal.getSlides().length-1);
}

//Formularios
var row_seleccionado=undefined;
var item_seleccionado=undefined;
var nuevo_editar=undefined;//0 Editar, 1 Nuevo;

function VerCatalogo(uiItem, contenedor, callback){
	console.log("Ver catalogo");
	var sobject= uiItem.getAttribute("concepto");
	var visibles= uiItem.getAttribute("visibles").split(",");
	_conceptoActual=sobject;
	contenedor= (typeof(contenedor)=="object"?contenedor:document.getElementById(contenedor));
	item_seleccionado=undefined;
	var filtros={};if(uiItem.relacion){
		filtros[uiItem.relacion.getAttribute("campo_ref")]=GetVal(uiItem.formulario.opciones.nodoXml,"indice");
	}
	ObtenerConsulta(sobject,filtros,function (xmlDoc) {
		var titulo= document.createElement("h1");
		titulo.innerHTML= (uiItem.formulario?GetVal(uiItem.formulario.opciones.nodoXml,"descripcion") + " &rarr; ":"") + sobject;
		contenedor.appendChild(titulo);
		var headers= $(xmlDoc).find("Response Entidad Campo");
		$.each(visibles,function(index,campo){
			visibles[index]= "Response Entidad Campo[propiedad='" + campo +"']";
		});
		if(visibles.length>0){
			for(var i=0; i<headers.length;i++){
				headers= $(xmlDoc).find(visibles.join(","));
			}
		}
		var datos= $(xmlDoc).find("Items item");
		var headerT= document.createElement("thead");headerT.innerHTML="";		
		var bodyT= document.createElement("tbody");bodyT.innerHTML="";
		var table=document.createElement("table");
		table.className="table table-striped table-sm";
		table.appendChild(headerT);
		table.appendChild(bodyT);
		contenedor.appendChild(table);
        for(var i=0; i<headers.length;i++){
			if(!headers[i].getAttribute("hide")){
				var th=CrearDom("th",headers[i].getAttribute("propiedad"));
				th.setAttribute("scope","col");
				headerT.appendChild(th);
			}
		}
		for(var i=0; i<datos.length;i++){
			var tr= document.createElement("tr");
			tr.onclick=SeleccionarItem;
			for(var j=0;j<headers.length;j++){
				if(!headers[j].getAttribute("hide")){
					var td= CrearDom("td",GetVal(datos[i],headers[j].getAttribute("propiedad")));
					td.setAttribute("scope","row");
					tr.appendChild(td);
					
					MarcarItem(datos[i],tr,callback,sobject);
					
					if(headers[j].id==true){
						tr.idItem=GetVal(datos[i],headers[j].getAttribute("propiedad"));
					}
				}
			}
			bodyT.appendChild(tr);
		}
    });	
}

function MostrarForm(concepto,idForm,nodoXml,es_editar, indiceEdit){
	$.post(_ROOT_SYSTEM.url_base,{op:"ObtenerEstructuraTable",seccion:"generic",sobject: concepto}, function (xmlConcepto) {		
		var campos= $(xmlConcepto).find("Entidad > Campo");
		var _form_dom=(typeof(idForm)=="object"? idForm: document.getElementById(idForm));		
		_form_dom.innerHTML="";
		if(_form_dom.tagName.toLowerCase()!="form"){
			form_dom=CrearDom("form");
			_form_dom.appendChild(form_dom);
		}
		form_dom.opciones={esEdit:es_editar,indiceEdit:indiceEdit,nodoXml:nodoXml};
		form_dom.innerHTML="";
		form_dom.style.display="block";
		var item=ObtenerItemForm("isEdit_","isEdit_","hidden",null,null,es_editar);
		form_dom.appendChild(item);
		for(var i=0;i<campos.length;i++){
			if(!campos[i].aux){
				item=ObtenerItemForm(campos[i].getAttribute("propiedad"), campos[i].getAttribute("propiedad"), campos[i].getAttribute("tipo"),nodoXml,campos[i]);
				form_dom.appendChild(item);
				if(item.callback) item.callback();
			}
		}	
		
		$.post(_ROOT_SYSTEM.url_base,{op:"RelacionesEstructuraTable",seccion:"generic",sobject: concepto}, function (xmlRelaciones) {	
			var relaciones= $(xmlRelaciones).find("Entidad > Relacion");
			var wrap= document.createElement("div");
			wrap.className="list-group";
			form_dom.appendChild(wrap);
			for(var i=0;i<relaciones.length;i++){				
				item= CrearDom("a");
				item.className="list-group-item list-group-item-action";
				item.setAttribute("concepto",relaciones[i].getAttribute("tabla_ref"));
				item.setAttribute("visibles","indice,descripcion");
				item.onclick=function(){AddCatalogoReveal(this);}
				item.innerHTML=relaciones[i].getAttribute("propiedad");
				item.formulario= form_dom;
				item.relacion=relaciones[i];
				wrap.appendChild(item);				
			}
		});			
	});
}

function EliminarItem(indice){
	if(indice){
		$.post(_ROOT_SYSTEM.url_base,{op:"Eliminar",seccion:"generic",sobject:_conceptoActual,indice:indice}, function (xmlDoc) {
			if (GetVal(xmlDoc, "estatus") == 1) {
				tipo="success";
				/*VerCatalogo(row_seleccionado,function(){
					document.getElementById("contenedorTablas").style.display="block";
					document.getElementById("forms").style.display="none"; 				
				});*/           
				frm.reset();            
			}else{
				tipo="danger";
			}
			MostrarMensajes(GetVal(xmlDoc, "mensaje"));
		});
	}else{
		MostrarMensajes("Debe seleccionar primero un registro","success");
	}
}

function VerEditarRegistro(){
	var idItem_= $("#bodyT tr.seleccionado")[0];
	if(idItem_ && idItem_.idItem){
		$.post(url + 'Negocio/controlador.aspx?op=ConsultarItem&seccion=' + estado_edit[row_seleccionado], {idItem:idItem_.idItem}, function (xmlDoc) {
			MostrarForm(xmlDoc);
		});
	}else{
		MostrarMensajes("Debe seleccionar primero un registro","success");
	}
}

function EditarRegistro(){
	var idItem_= $("#bodyT tr.seleccionado")[0];
	if(idItem_ && idItem_.idItem){
		$.post(url + 'Negocio/controlador.aspx?op=ConsultarItem&seccion=' + estado_edit[row_seleccionado], {idItem:idItem_.idItem}, function (xmlDoc) {
			if (GetVal(xmlDoc, "estatus") == 1) {
				tipo="success";
				/*VerCatalogo(row_seleccionado,function(){
					document.getElementById("contenedorTablas").style.display="block";
					document.getElementById("forms").style.display="none"; 				
				});    */       
				frm.reset();            
			}else{
				tipo="danger";
			}
			MostrarMensajes(GetVal(xmlDoc, "mensaje"));
		});
	}else{
		MostrarMensajes("Debe seleccionar primero un registro","success");
	}
}

function SeleccionarItem(){
	try{
		$(item_seleccionado).removeClass("seleccionado");
	}catch(e){}
	$(this).addClass("seleccionado");
	item_seleccionado=this;
}

function Guardar(frm,concepto,callback){
	var codes= $(frm).find("textarea[tipo=code]");
	for(var i=0; i<codes.length;i++){
		codes[i].value=encodeURIComponent(codes[i].parentNode.parentNode.editor.getDoc().getValue());
	}	
	var datos = $(frm).serializeArray();
	datos=$.grep(datos,function(field){
		return (field.value!=null && field.value!="null"); 
	});
	$.post('/logic/controlador.aspx?op=Guardar'+ '&seccion=generic&sobject=' + concepto, datos, function (xmlDoc) {
		if(callback) callback(xmlDoc);  
	});
}

function ObtenerItemForm(label,campo,tipo,nodoXml,datos,es_editar){
	var table_ref=datos?datos.getAttribute("tabla_ref"):null;
	var campo_ref;	
	var oTipo=ObtenerTipo(campo, tipo, table_ref);
	var itemForm=document.createElement('div');
	itemForm.className="form-floating";
	var contenido="", gindex="";	
	if(datos && datos.getAttribute("gindex")){
		gindex=datos.getAttribute("gindex");
	}
	if(oTipo.esCode){
			contenido= document.createElement("textarea");
			contenido.setAttribute("tipo","code");
			contenido.name=campo;
			var wrap= document.createElement("div");
			wrap.id='form-control-'+ campo + "-" + gindex;
			wrap.appendChild(contenido);
			itemForm.className='form-control';
			itemForm.innerHTML='<label data-bs-toggle="collapse" data-bs-target="#' + wrap.id+ '" class="label-field" style="display:block;cursor:pointer;" onclick="document.getElementById(\'' + wrap.id + '\').className=\'collapse\'">' + campo + ":" + oTipo.tipo + '</label>';			
			itemForm.appendChild(wrap);
			itemForm.campo=campo;
			itemForm.tipo=oTipo.tipo;
			itemForm.nodoXml=nodoXml;
			itemForm.callback=function(){
				this.editor=CodeMirror.fromTextArea(this.getElementsByTagName("textarea")[0],{
					mode: this.tipo,
					indentWithTabs: true,
					smartIndent: true,
					matchBrackets : true
				});
				var content=GetVal(this.nodoXml,this.campo,true);
				this.editor.getDoc().setValue(content);
			}
	}else{
		switch(oTipo.tipo){
			case "hidden": {
					contenido= '<input value="' + es_editar + '" type="hidden" class="form-control" name="' + campo + '" />';						  
					itemForm.innerHTML=contenido;
			}break;
			case "int": {
					contenido= '<input value="' + (nodoXml?GetVal(nodoXml,campo):"") + '" type="number" class="form-control" name="' + campo + '" id="' + campo + '" placeholder="' + label + '">'+
							  '<label for="floatingPassword">' + label + '</label>';
							  itemForm.innerHTML=contenido;
			}break;		
			case "string": {
					contenido= '<input value="' + (nodoXml?GetVal(nodoXml,campo):"") + '" type="text" class="form-control" name="' + campo + '" id="' + campo + '" placeholder="' + label + '">'+
						'<label for="floatingPassword">' + label + '</label>';
						 itemForm.innerHTML=contenido;
			}break;
			
			case "select": {			
				var filtros={};
				if(datos.filtros) eval('filtros=' + datos.filtros + '();');
				$.post(_ROOT_SYSTEM.url_base,{op:"ObtenerItems",seccion:"generic",concepto: table_ref}, function (xmlDoc) {	
				//$.post(datos.url,filtros, function(xmlDoc) {
					var items= $(xmlDoc).find("Response Items item");
					contenido= document.createElement("select");
					contenido.innerHTML="<option>Seleccione opción</option>";
					$(contenido).find("option")[0].value=null;
					contenido.className="form-control";
					contenido.name=campo;
					var item;
					for(var i=0;i<items.length;i++){
						item=document.createElement("option");
						item.innerHTML=GetVal(items[i],"descripcion");
						item.value=GetVal(items[i],datos.getAttribute("campo_ref"));
						if(GetVal(nodoXml,campo)==item.value){ 
							item.setAttribute("selected","selected");
						}
						contenido.appendChild(item);					
					}
					itemForm.appendChild(contenido);
					etiqueta=CrearDom('label',label);
					etiqueta.setAttribute('for',"floatingPassword");
					itemForm.appendChild(etiqueta);
				});
				
			}break;
				
		}	
	}
	return itemForm;
}

function ObtenerTipo(campo, tipo, table_ref){
	var resp={esCode:false,tipo:tipo};
	if(!tipo){
		resp.tipo="string";
	}else if(table_ref && tipo!="rel"){
		resp.tipo="select";
	}else{
		var lengs=["html","css","javascript","sql"];
		for(var i=0;i<lengs.length;i++){
			if(new RegExp(lengs[i],"gi").test(campo)){
				resp.esCode=true;
				if(lengs[i]=="html"){
					resp.tipo="htmlmixed";
				}else{
					resp.tipo=lengs[i];
				}
				break;
			}
		}
	}
	return resp;
}
function MarcarItem(datai,itemUI, callback,concepto){	
	itemUI.datai=datai;
	if(GetVal(datai,"css")||GetVal(datai,"html")||GetVal(datai,"html")){
		itemUI.style.fontWeight="bold";
	}
	if(callback){
		callback(itemUI,datai);
	}
}


var _conceptoActual;
function ObtenerItems(concepto){
	ObtenerConsulta(concepto,{},function(data){
		var lista= $(".list-components")[0];
		lista.innerHTML="";
		data=$(data).find("Response Items item");
		var item;
		for(var i=0;i<data.length;i++){
			item=CrearDom("li",GetVal(data[i],"descripcion"));
			item.datai=data[i];
			if(GetVal(data[i],"css")||GetVal(data[i],"html")||GetVal(data[i],"innerHTML")){
				item.style.fontWeight="bold";
			}
			item.onclick=function(){
				var item=this;
				MostrarForm(concepto,$(".edit")[0],item.datai);			
			}
			lista.appendChild(item);
		}
	})
}

function AddCatalogoReveal(uiItem){
	CrearPantalla("views-control",function(parentNode){
		VerCatalogo(uiItem, parentNode, function(itemUI,datai){
			var descripcion= $(itemUI).find("td")[0].innerHTML;
			var link=GetVal(datai,"link");
			if(link) $(itemUI).find("td")[0].innerHTML="<a href='" + link + "' target='_blank'>" + descripcion + "</td>";
		});
	}); 
}

function ObtenerConsulta(concepto, filtros, callback){
	_conceptoActual=concepto;
	$.post("/logic/controlador.aspx?seccion=generic&op=ObtenerItems&concepto=" + concepto,filtros,callback);
}


