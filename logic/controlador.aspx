<%@ Page Language="C#"%>
<%@ Import Namespace="System.Data"%>
<%@ Import Namespace="System.Xml"%>
<%@ Import Namespace="System.Xml.Linq"%>
<%@ Import Namespace="System.IO"%>
<%@ Import Namespace="System.Net"%>
<%@ Import Namespace="System.Globalization"%>
<%@ Import Namespace="Server"%>
<%@ Import Namespace="NPOI.XSSF.UserModel"%>
<%@ Import Namespace="iTextSharp.text"%>
<%@ Import Namespace="System.Drawing"%>
<%@ Import Namespace="QRCoder"%>



<script runat="server">

    Modelo oModelo = new Modelo(HttpContext.Current.Server.MapPath("~") + "logic/dbo.xml",true);

    XSSFWorkbook wb;
    XSSFSheet sh;

    protected void Page_Load(object sender, EventArgs e){
        Response.Clear();
        Response.ContentType = "text/xml";		
		
        string op = Request["op"], seccion=Request["seccion"];string opx=Request["opx"];
		if(opx!=null){
			GenerarOperacionCX_DB();
		}else if(op !=null && seccion != null) {            
            switch (op)
            {
                case "CerrarSesiones": CerrarSesiones();break;
                case "ValidarSesion": ValidarSesion();break;
                case "IniciarSesion": IniciarSesion();break;
                case "CerrarSesion": CerrarSesion();break;
                case "EnviarNotificacion": EnviarNotificacion_HTTP();break;			
                case "GenerarOperacionCX_DB": GenerarOperacionCX_DB();break;			
                case "opx": GenerarOperacionCX_DB();break;			
				case "Guardar": GuardarObject();break;
                default:{
						DataSet ds;
					
						ds=oModelo.GenerarOperacionCX(op, seccion, null, true);
                        if(ds!=null && ds.Tables.Count>0 && ds.Tables[0].Rows.Count > 0 && ds.Tables[0].Columns.Contains("xmldoc")){
                            Response.Write(ds.Tables[0].Rows[0]["xmldoc"]);
                        }else{                            
                            ds.WriteXml(Response.OutputStream);
                        }
						Notificar(ds);														
					
                    }
                    break;
            }
        }else {
            Response.Write("<mensaje>No se recibieron parametros op y sección.</mensaje>");
        }
    }
	
	public void GuardarObject(){
        DataSet ds= oModelo.GenerarOperacionCX("ObtenerEstructuraTable","generic",new object[,]{{ "In table", "inTable",1,false,"bool", 0}},true);
        object [,] parametros= null;
		string propiedades="", propiedad="",coma="",contenido="";string tipo="";int longitud;
		if(ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0){
			parametros= new object[ds.Tables[0].Rows.Count,6];
			for(int i=0; i<ds.Tables[0].Rows.Count; i++){
				tipo=ds.Tables[0].Rows[i]["tipo"].ToString();
				propiedad=ds.Tables[0].Rows[i]["propiedad"].ToString();
				parametros[i,0]=propiedad;
				parametros[i,1]=propiedad;	
				if(propiedad=="css"||propiedad=="html"||propiedad=="innerHTML"||propiedad=="jscript"||propiedad=="javascript"||(propiedad.Contains("sql")&&tipo=="text")){
					contenido=HttpUtility.UrlDecode(Request[propiedad]);					
				}else{
					contenido=Request[propiedad];
				}
				parametros[i,2]=contenido;
				parametros[i,3]=bool.Parse(ds.Tables[0].Rows[i]["requerido"].ToString());
				parametros[i,4]=(tipo=="css"||tipo=="html"||tipo=="jscript"||tipo=="sql"?"string":tipo);
				longitud=Int32.Parse(ds.Tables[0].Rows[i]["longitud"].ToString());
				parametros[i,5]=longitud;
				//Response.Write(ds.Tables[0].Rows[i]["propiedad"] + ": Tipo=>" + tipo + " size=> " + longitud);
				propiedades+= coma + ds.Tables[0].Rows[i]["propiedad"];
				coma=",";				
			}
			
			var sparams= new object[1,6];
			sparams[0,0]="parametros";
			sparams[0,1]="parametros";
			sparams[0,2]=propiedades;
			sparams[0,3]=true;
			sparams[0,4]="string";
			sparams[0,5]=4000;
			ds=oModelo.GenerarOperacionCX("Guardar", "generic", sparams,true);
			
			//ds.WriteXml(Response.OutputStream);
			if(ds.Tables[0].Columns.Contains("sql_query")){
				ds=oModelo.GenerarOperacionCX("place", "generic", parametros,true,ds.Tables[0].Rows[0]["sql_query"].ToString());
				ds.WriteXml(Response.OutputStream);
			}								
		}	
    }
	
    public void GenerarOperacionCX_DB(){
        DataSet ds= oModelo.GenerarOperacionCX("ObtenerParametrosPre","generic",null,true);
        object [,] parametros= null;
        if(ds!=null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0){
            if(ds.Tables.Count > 1 && ds.Tables[1].Rows.Count > 0){
                parametros= new object[ds.Tables[1].Rows.Count,6];
                for(int i=0; i<ds.Tables[1].Rows.Count; i++){
                    parametros[i,0]=ds.Tables[1].Rows[i]["leyenda"];
                    parametros[i,1]=ds.Tables[1].Rows[i]["nombre"];
                    parametros[i,2]=Request[ds.Tables[1].Rows[i]["nombre"].ToString()];
                    parametros[i,3]=bool.Parse(ds.Tables[1].Rows[i]["requerido"].ToString());
                    parametros[i,4]=ds.Tables[1].Rows[i]["tipo"].ToString();
                    parametros[i,5]=Int32.Parse(ds.Tables[1].Rows[i]["longitud"].ToString());
                }
            }
			if(ds.Tables[0].Columns.Contains("sql_query")){
				ds=oModelo.GenerarOperacionCX("place", "generic", parametros,true,ds.Tables[0].Rows[0]["sql_query"].ToString());
				Notificar(ds);
			}														
			ds.WriteXml(Response.OutputStream);
        }
    }
	
	public void ProcesarPagoBanco(){
		DataSet ds=oModelo.GenerarOperacionCX("PagoPorSistema", "aportaciones",null,true);
		ds.WriteXml(Response.OutputStream);
	}
	
	public void CargarPublicaciones(){
		DataSet ds=oModelo.GenerarOperacionCX("cargar", "comunicados", new object[,]{
		{"Clave de fraccionamiento", "s_fraccionamiento", Session["s_fraccionamiento"],true,"int", 0}							
		,{"sesion_inactiva", "sesion_inactiva", Session["s_usuario"],true,"int", 0}
		,{"Usuario", "s_usuario", Session["s_usuario"],true,"int", 0}}, true);
		XmlDocument doc= new XmlDocument();
		doc.LoadXml(ds.GetXml());
		var nodeReader = new XmlNodeReader(doc);
        nodeReader.MoveToContent();
        XDocument xmldoc = XDocument.Load(nodeReader);
		var query =
            from elems in xmldoc.Descendants("Encuesta").Union(xmldoc.Descendants("Comunicado"))
            let fecha = DateTime.ParseExact(elems.Element("fecha").Value,"dd/MM/yyyy",CultureInfo.InvariantCulture) 
			where elems.Element("fecha") != null
            orderby fecha descending
            select elems;
			
		var newXdoc = new XDocument(new XElement("NewDataSet", query));	
		newXdoc.Save(Response.OutputStream);
	}
	
	public void GuardarCorreoOficial(){
		DataSet ds= new DataSet();
		try{
			XmlDocument doc = new XmlDocument();
			string path_p= HttpContext.Current.Server.MapPath("~") + "src-img/fraccionamientos/_" + Session["s_fraccionamiento"] + "/email-notificacion.xml";
			string path_d= HttpContext.Current.Server.MapPath("~") + "EmailPlantillas/email-notificacion.xml";
			if(File.Exists(path_p)){
				doc.Load(path_p);
			}else{				
				doc.Load(path_d);
			}
			XmlNode root = doc.DocumentElement;
			root.Attributes["remitente"].Value=Request["email"];
			root.Attributes["usuario"].Value=Request["email"];
			root.Attributes["clave"].Value=Request["dato"];
			root.SelectSingleNode("//destinatarios/bcc").InnerText=Request["email"];
			doc.Save(path_p);
			Util.agregarCampoValor("mensaje", "Guardado correctamente.", ds);
		}catch(Exception ex){
			Util.agregarCampoValor("mensaje", ex.Message, ds);
		}
		ds.WriteXml(Response.OutputStream);
	}
	
	public void ObtenerDatosFracc(){
		DataSet ds;
		ds=oModelo.GenerarOperacionCX("ObtenerDatosFracc", "fraccionamientos", new object[,]{
		{"Clave de fraccionamiento", "f_fraccionamiento", Request["f_fraccionamiento"],true,"int", 0}}, true);
        ds.WriteXml(Response.OutputStream);
	}
	
    public void ActivarDesactivarUsuario() {
        int a = 0;Int32.TryParse(Request["usuario"], out a);
        CerrarSesiones(a);
        DataSet ds=oModelo.GenerarOperacionCX("ActivarDesactivarUsuario", "usuarios", new object[,]{
        {"Clave de fraccionamiento", "s_fraccionamiento", Session["s_fraccionamiento"],true,"int", 0}
        ,{"sesion_inactiva", "sesion_inactiva", Session["s_usuario"],true,"int", 0}
        ,{"Usuario", "s_usuario", Session["s_usuario"],true,"int", 0}}, true);
        Notificar(ds);
        ds.WriteXml(Response.OutputStream);
    }

    public void ObtenerComprobante() {
        DataSet ds=oModelo.GenerarOperacionCX("ObtenerAdjuntoDeposito", "aportaciones",new object[,]{
                        { "Clave", "clave", Request["deposito"],true,"int", 0}
						,{"Clave de fraccionamiento", "s_fraccionamiento", Session["s_fraccionamiento"],true,"int", 0}}, true);
        if (ds.Tables[0].Columns.Contains("estatus")){
            if (ds.Tables[0].Rows.Count>0){
                Response.Redirect("/src-img/fraccionamientos/_" + Session["s_fraccionamiento"] + "/depositos_banco/_" + Request["deposito"] + "/" + ds.Tables[0].Rows[0]["nombre_archivo"].ToString());
            }else{
                Response.Write("<mensaje>No se encontró archivo..</mensaje>");
            }
        }
    }

    public void GenerarRecibo() {
        try{
			string path_pi= "src-img/fraccionamientos/_" + Session["s_fraccionamiento"] + "/bg-recibo.jpg";
			string path_di= "formatos/bg-recibo.jpg";string path_ci;
			path_ci=(File.Exists(HttpContext.Current.Server.MapPath("~") + path_pi)?path_pi:path_di);
			
            iTextSharp.text.Image img = iTextSharp.text.Image.GetInstance(HttpContext.Current.Server.MapPath("~") + path_ci);			
            img.ScalePercent(60);
            img.Alignment = iTextSharp.text.Image.UNDERLYING;
            img.SetAbsolutePosition(0, 0);
						
            if (Session["s_usuario"] != null || Request.IsLocal) {
                DataSet ds=oModelo.GenerarOperacionCX("ObtenerRecibo","aportaciones", new object[,]{
					{"Clave de fraccionamiento", "s_fraccionamiento", Request["s_fraccionamiento"],true,"int", 0}
					,{"Path logo", "path_logo", HttpContext.Current.Server.MapPath("~") + "/src-img/fraccionamientos/_" + Request["s_fraccionamiento"] + "/logo.jpg",true,"string", 200}
				}, true);
				
				string path_p= "src-img/fraccionamientos/_" + Session["s_fraccionamiento"] + "/recibo_caida.html";
				string path_d= "formatos//recibo_caida.html";string path_c;
				path_c=(File.Exists(HttpContext.Current.Server.MapPath("~") + path_p)?path_p:path_d);
								
				QRCodeGenerator qrGenerator = new QRCodeGenerator();
				QRCodeData qrCodeData = qrGenerator.CreateQrCode(ds.Tables[0].Rows[0]["folio"].ToString(), QRCodeGenerator.ECCLevel.Q);
				QRCode qrCode = new QRCode(qrCodeData);
				Bitmap qr = qrCode.GetGraphic(20);
				MemoryStream ms = new MemoryStream();
				qr.Save(ms, System.Drawing.Imaging.ImageFormat.Jpeg);
				System.Drawing.Image imgqr= System.Drawing.Image.FromStream(ms); 
				
				iTextSharp.text.Image imgi=iTextSharp.text.Image.GetInstance(imgqr, System.Drawing.Imaging.ImageFormat.Jpeg);
				imgi.ScalePercent(16);
				imgi.SetAbsolutePosition(485,229);
			
				Util.ResponderPDF(Util.HtmlToPDF(path_c,ds,false,img,PageSize.HALFLETTER,true,imgi));
				               
            }
        }catch(Exception e){
            Response.Write("Error. " + e.Message);
        }
    }

    public void GuardaClaveAcceso() {
        DataSet ds = new DataSet();
        try{
            var plainTextBytes = System.Text.Encoding.UTF8.GetBytes(Request["clave"]);
            string token= System.Convert.ToBase64String(plainTextBytes);
            ds=oModelo.GenerarOperacionCX("GuardaClaveAcceso", Request["seccion"], new object[,] {
			{ "Clave de visita", "clave", Request["clave"],true,"int", 0},{ "Token", "token", token,true,"string", 50},
			{"Clave de fraccionamiento", "s_fraccionamiento", Session["s_fraccionamiento"],true,"int", 0}}, true);
        }catch (Exception e) {
            ds=Util.agregarCampoValor("estatus", "-1",ds);
            ds=Util.agregarCampoValor("mensaje", e.Message,ds);
        }
        ds.WriteXml(Response.OutputStream);
    }

    public void Notificar(DataSet ds) {
        if (ds.Tables.Count>0 && ds.Tables[ds.Tables.Count-1].Columns.Contains("notificar")) {
            DataRow dr = ds.Tables[ds.Tables.Count-1].Rows[0];
            try {
                EnviarNotificacion(
                    dr["para"].ToString()//Obligatorio
                    ,ds.Tables[ds.Tables.Count-1].Columns.Contains("titulo")?dr["titulo"].ToString():null
                    ,ds.Tables[ds.Tables.Count-1].Columns.Contains("mensaje")?dr["mensaje"].ToString():null
                    ,ds.Tables[ds.Tables.Count-1].Columns.Contains("clave")?dr["clave"].ToString():null
                    ,ds.Tables[ds.Tables.Count-1].Columns.Contains("dato")?dr["dato"].ToString():null
                    ,ds.Tables[ds.Tables.Count-1].Columns.Contains("contenido")?dr["contenido"].ToString():null
                );
            } catch (Exception e1) { }
        }
    }

    public void RegistrarUsuario() {
        oModelo.GenerarOperacionCX("RegistrarUsuario", "usuarios", null, true).WriteXml(Response.OutputStream);
    }
	
	
    public void RecuperarAcceso() {
        oModelo.GenerarOperacionCX("RecuperarAcceso", "seguridad", null, true).WriteXml(Response.OutputStream);
    }

    public void ActivarAplicacion() {
        DataSet ds = new DataSet();
        try{
            if (Request["codigoActivacion"] != null)
            {
                byte[] data = System.Convert.FromBase64String(Request["codigoActivacion"]);
                string claveFracc = System.Text.ASCIIEncoding.ASCII.GetString(data);
                int i_clavefracc = 0;
                if (Int32.TryParse(claveFracc, out i_clavefracc))
                {
                    ds = oModelo.GenerarOperacionCX("ValidarEstatusCuenta", "seguridad", new object[,] { { "Clave de fraccionamiento", "s_fraccionamiento", i_clavefracc, true, "int", 0 } }, true);
					Session["s_fraccionamiento"] = (int)ds.Tables[2].Rows[0]["clave"];
					Session["s_nfracc"]=ds.Tables[2].Rows[0]["Nombre"];
					Session["s_fdomicilio"]=ds.Tables[2].Rows[0]["domicilio"];
                }
                else
                {
                    ds = Util.agregarCampoValor("estatus", "-1", ds);
                    ds = Util.agregarCampoValor("mensaje", "Por favor vuelva a intentar.", ds);
                }
            }else{
                ds = Util.agregarCampoValor("estatus", "-1", ds);
                ds = Util.agregarCampoValor("mensaje", "No se recibió la clave de activación.", ds);
            }

        }catch (Exception e) {
            ds = Util.agregarCampoValor("estatus", "-1", ds);
            ds = Util.agregarCampoValor("mensaje", "No se encontró la clave de activación.", ds);
        }
        ds.WriteXml(Response.OutputStream);
    }


    public void GuardarInfoInicial() {
        Response.ContentType = "text/html";
        bool continuar = true;
        string mensaje = "";
        try{
            if(Request.Files["logof"].ContentLength==0){
                continuar = false;
                mensaje += "- Logo ";
            }

            if (Request.Files["domiciliosxls"].ContentLength==0 && Request["f-regdom"]=="plantilla") {
                continuar = false;
                mensaje += " - Layout";
            }
            if (!continuar) {
                Response.Write("<script>alert('Falta lo siguiente: " + mensaje + "');<" + "/script>");
            }else{
                string ext = Util.ObtenerExtensionArchivoPost(Request.Files["logof"]);
                string root = Server.MapPath("~/src-img");
                DataSet ds = oModelo.GenerarOperacionCX("RegistrarDomicilio", "fraccionamientos", new object[,] {{ "Extensión de logo", "extlogo",ext,false,"string", 30},
				{ "Clave de fraccionamiento", "s_fraccionamiento", Session["sx_fracc"],true,"int", 0},
				{ "Tipo de registro", "f_regdom", Request["f-regdom"],true,"string", 30}
				}, true);
                if (ds.Tables[0].Rows[0]["estatus"].ToString() == "1") {
                    System.IO.Directory.CreateDirectory(root + "/fraccionamientos/_" + Session["sx_fracc"].ToString() );
                    Request.Files["logof"].SaveAs(root + "/fraccionamientos/_" + Session["sx_fracc"].ToString() + "/" + "logo" + ext);					
                    string pathXLS = root + "/fraccionamientos/_" + Session["sx_fracc"].ToString() + "/" + "domicilios.xlsx";
                    if(Request["f-regdom"]=="plantilla"){
						Request.Files["domiciliosxls"].SaveAs(pathXLS);
						using (var fs = new FileStream(pathXLS, FileMode.Open, FileAccess.Read))
						{
							wb = new XSSFWorkbook(fs);
							ds= oModelo.ObtenerTablas("ap_domicilios", "RegistroInicial");
							if (wb.NumberOfSheets>0) {
								sh = (XSSFSheet)wb.GetSheetAt(0);
								if (sh.GetRow(0).Cells.Count > 6) {
									int i = 1; while (sh.GetRow(i) != null) {
										try {
											ds.Tables["domicilios"].Rows.Add(
											sh.GetRow(i).Cells[0], 
											sh.GetRow(i).Cells[1],
											sh.GetRow(i).Cells[2],
											sh.GetRow(i).Cells[3], 
											sh.GetRow(i).Cells[4], 
											sh.GetRow(i).Cells[5], 
											sh.GetRow(i).Cells[6]);
										}
										catch (Exception e) { 
											Response.Write(i + ":" + e.Message);
										}
										i++;
									}
								}
							}   
							ds=oModelo.GenerarOperacionCX("RegistroInicial", "ap_domicilios", new object[,] {{ "Clave de fraccionamiento", "s_fraccionamiento", Session["sx_fracc"],true,"int", 0},{ "Usuario", "s_usuario", Session["sx_user"],true,"int", 0}}, true,null,ds);
						}		
					}
					ds.WriteXml(Response.OutputStream);
					//Response.Write("<script>alert('Guardado correctamente');window.parent.location.href=window.parent.location.href<" + "/script>");						
                }else {
                    Response.Write("<script>alert(\"" + ds.Tables[0].Rows[0]["mensaje"] + "\");<" + "/script>");
                }
            }
        }catch (Exception e) {
            Response.Write("<script>alert(\"" + e.Message + "\");<" + "/script>");
        }
    }

    public void CargaMasivaCuotas() {
        Response.ContentType = "text/html";
        bool continuar = true;
        string mensaje = "";
        DataSet ds = new DataSet();
        try{
            if(Request.Files["exlscuot"].ContentLength==0){
                continuar = true;
                mensaje += "Archivo de cuotas ";
            }

            if (!continuar) {
                Response.Write("<script>alert('Falta lo siguiente: " + mensaje + "');<" + "/script>");
            }else{
                string root = Server.MapPath("~/src-img");

                System.IO.Directory.CreateDirectory(root + "/fraccionamientos/_" + Session["s_fraccionamiento"].ToString() );
                string pathXLS = root + "/fraccionamientos/_" + Session["s_fraccionamiento"].ToString() + "/" + "cuotas.xlsx";
                Request.Files["exlscuot"].SaveAs(pathXLS);
                try {
                    using (var fs = new FileStream(pathXLS, FileMode.Open, FileAccess.Read))
                    {
                        wb = new XSSFWorkbook(fs);
                        ds= oModelo.ObtenerTablas("aportaciones", "CargaMasivaPagos");
                        if (wb.NumberOfSheets>0) {
                            sh = (XSSFSheet)wb.GetSheetAt(0);
                            if (sh.GetRow(0).Cells.Count >= 13) {
                                int i = 1; while(sh.GetRow(i)!=null) {
                                    try
                                    {
                                        ds.Tables["cuotas"].Rows.Add(sh.GetRow(i).Cells[0], sh.GetRow(i).Cells[1], sh.GetRow(i).Cells[2], sh.GetRow(i).Cells[3], sh.GetRow(i).Cells[5], sh.GetRow(i).Cells[6], sh.GetRow(i).Cells[4],sh.GetRow(i).Cells[7], sh.GetRow(i).Cells[8], sh.GetRow(i).Cells[9], sh.GetRow(i).Cells[10], sh.GetRow(i).Cells[11], sh.GetRow(i).Cells[12], sh.GetRow(i).Cells[20]);
                                    }
                                    catch (Exception e) {
                                        int a = 0;
                                    }
                                    i++;
                                }
                            }
                        }
                        ds=oModelo.GenerarOperacionCX("CargaMasivaPagos", "aportaciones", new object[,] {{ "Clave de fraccionamiento", "s_fraccionamiento", Session["s_fraccionamiento"],true,"int", 0},{ "Usuario", "s_usuario", Session["s_usuario"],true,"int", 0}}, false,null,ds);
						
                    }
                    if(ds.Tables[0].Rows[0]["estatus"].ToString() == "1"){
                        Response.Write("<script>alert('Guardado correctamente');<" + "/script>");
                    }else {
                        Response.Write("<script>alert(\"" + ds.Tables[0].Rows[0]["mensaje"].ToString() + "\");<" + "/script>");
                    }

                }catch (Exception e) {
                    Response.Write("<script>alert(\"" + e.Message + "\");<" + "/script>");
                }
            }
        }catch (Exception e) {
            Response.Write("<script>alert(\"" + e.Message + "\");<" + "/script>");
        }
    }



    public void ValidarSesion() {
        Response.Write("<mensaje>" + (Session["clave_usuario"]!=null?"Aun activa" + Session["clave_usuario"] :"Se terminó la sesión") + "</mensaje>");
    }

    public void RegistrarFracc() {
		Session.Abandon();
        DataSet ds=oModelo.GenerarOperacionCX("Registrar", "fraccionamientos", null, true);
        if (ds.Tables[0].Columns.Contains("estatus")){
            ds.WriteXml(Response.OutputStream);
        }
    }

    public void ObtenerPlanes() {
        oModelo.GenerarOperacionCX("ObtenerPlanes", "licencias", null, true).WriteXml(Response.OutputStream);
    }

    public void IniciarSesion() {
        DataSet ds = oModelo.GenerarOperacionCX("IniciarSesion", "seguridad",null, true);
        int clave_usuario;
        if (ds.Tables[0].Columns.Contains("clave")) {
            int TimeOut= 20;//Valor por default del timeout 20 min
            int.TryParse(ConfigurationManager.AppSettings.Get("TimeOut"),out TimeOut);//Valor seleccionado por el usuario.
            Session.Timeout = TimeOut;
            clave_usuario = (int)ds.Tables[0].Rows[0]["clave"];
			if((int)ds.Tables[0].Rows[0]["estatus"]==1){
				Session["s_usuario"] = clave_usuario;
				Session["s_fraccionamiento"] = (int)ds.Tables[0].Rows[0]["fraccionamiento"];
				Session["s_nfracc"]=ds.Tables[0].Rows[0]["s_nfracc"];
				Session["s_email"] = ds.Tables[0].Rows[0]["correo"];
				Session["s_nombre"] = ds.Tables[0].Rows[0]["nombre"];
				Session["s_fdomicilio"] = ds.Tables[0].Rows[0]["fdomicilio"];
			}else if((int)ds.Tables[0].Rows[0]["estatus"]==2){
				Session["sx_user"]= clave_usuario;
				Session["sx_fracc"]= (int)ds.Tables[0].Rows[0]["fraccionamiento"];
				Session["s_nfracc"]=ds.Tables[0].Rows[0]["s_nfracc"];
				Session["s_email"] = ds.Tables[0].Rows[0]["correo"];
				Session["s_nombre"] = ds.Tables[0].Rows[0]["nombre"];
				Session["s_fdomicilio"] = ds.Tables[0].Rows[0]["fdomicilio"];
				
			} 
			List<Fraccionamientos.Global.UnaSesion> sesiones = (List<Fraccionamientos.Global.UnaSesion>)(Application["sesiones"]);
			sesiones.Add(new Fraccionamientos.Global.UnaSesion(clave_usuario,Session));				
			ds=Util.agregarCampoValor("SessionID", Session.SessionID,ds);
        }		
        ds.WriteXml(Response.OutputStream);
    }

    public void CerrarSesion() {
        try
        {
            Session.Abandon();
            Response.Write("<Table><estatus>1</estatus><mensaje>Cesión cerrada</mensaje></Table>");
        }
        catch (Exception e) {
            Response.Write("<Table><estatus>-1</estatus><mensaje>Error</mensaje></Table>");
        }
    }

    public void CerrarSesiones() {
        if (Request["clave"]!=null){
            int clave_usuario;
            Int32.TryParse(Request["clave"],out clave_usuario);
            int k=CerrarSesiones(clave_usuario);
            Response.Write("<xml><estatus>1</estatus><mensaje>" + k + " coincidencias.</mensaje></xml>");
        }else {
            Response.Write("<xml><estatus>-1</estatus><mensaje>Faltó clave</mensaje></xml>");
        }
    }

    public int CerrarSesiones(int clave_usuario) {
        List<Fraccionamientos.Global.UnaSesion> sesiones = (List<Fraccionamientos.Global.UnaSesion>)(Application["sesiones"]);
        int k = 0;
        for(int i= 0;i < sesiones.Count;i++){
            Fraccionamientos.Global.UnaSesion sesion = sesiones[i];
            if (sesion.clave == clave_usuario) {
                sesion.sesion.Clear();
                sesion.sesion.Abandon();
                sesiones.Remove(sesion);
                k++;
            }
        }
        return k;
    }

    public void ObtenerInforme() {
        DataSet ds = new DataSet();
        DataTable dt;
        ds=oModelo.GenerarOperacionCX("ObtenerInforme", "transparencia", new object[,] {
                    { "Usuario", "s_usuario", Session["s_usuario"],true,"int", 0}
                    ,{ "Clave de fraccionamiento", "s_fraccionamiento", Session["s_fraccionamiento"],true,"int", 0}
         }, true);
		 
		 try{
        if (ds.Tables[0].Columns.Contains("query")){
            string path = ds.Tables[0].Rows[0]["path"].ToString();
            ds=oModelo.GenerarOperacionCX("place", "transparencia", new object[,] {
                    { "Usuario", "usuario", Session["s_usuario"],true,"int", 0}                    
                    ,{ "Logo de Fraccionamiento", "map_path", Server.MapPath("~"),true,"string", 300}
                    ,{ "Clave de fraccionamiento", "s_fraccionamiento", Session["s_fraccionamiento"],true,"int", 0}
                    ,{ "Fecha inicio", "fecha1_", Request["fecha1"],false,"string", 20}
                    ,{ "Fecha final", "fecha2_", Request["fecha2"],false,"string", 20}
                    ,{ "Param 1", "p1", Request["p1"],false,"string", 50}
                    ,{ "Param 2", "p2", Request["p2"],false,"string", 50}
                    ,{ "Param 3", "p3", Request["p3"],false,"string", 50}
            },true,ds.Tables[0].Rows[0]["query"].ToString());
			if(ds.Tables[0].Columns.Contains("estatus")){
				ds.WriteXml(Response.OutputStream);			
			}else{
				if (Request["xls"]=="true"){
					try {
						wb = new XSSFWorkbook();
						for (int n = 0; n < ds.Tables.Count; n++){
							dt = ds.Tables[n];
							wb.CreateSheet(dt.TableName);
							sh = (XSSFSheet)wb.GetSheetAt(n);
							NPOI.SS.UserModel.IRow r = sh.CreateRow(0);
							for (int j = 0; j < dt.Columns.Count; j++) {
								NPOI.SS.UserModel.ICell cell = r.CreateCell(j);
								cell.SetCellValue(dt.Columns[j].ColumnName);
							}
							for(int i= 0;i < dt.Rows.Count;i++){
								r = sh.CreateRow(i+1);
								for (int j = 0; j < dt.Columns.Count; j++){
									NPOI.SS.UserModel.ICell cell = r.CreateCell(j);
									cell.SetCellValue(dt.Rows[i][j].ToString());
								}
							}
						}
						HttpResponse Response = HttpContext.Current.Response;
						Response.Clear();
						Response.ContentType = "application/xlsx";
						Response.AddHeader("Content-Disposition", "attachment; filename=Reporte.xlsx");
						wb.Write(Response.OutputStream);
						wb.Close();
					}catch (Exception e){
						Response.Write("Error. " + e.Message);
					}
				}else if (Request["pdf"]=="true"){
					try{
						string path_di= "formatos/bg1.jpg";
						iTextSharp.text.Image img = null;
						if(File.Exists(HttpContext.Current.Server.MapPath("~") + path_di)){						
							img = iTextSharp.text.Image.GetInstance(HttpContext.Current.Server.MapPath("~") + path_di);			
							img.ScalePercent(48);
							img.Alignment = iTextSharp.text.Image.UNDERLYING;
							img.SetAbsolutePosition(0, 750);					
						}
						Util.ResponderPDF(Util.HtmlToPDF(path, ds,true,img));	
					}catch (Exception e){
						Response.Write("Error. " + e.Message);
					}
				} else if (Request["grafica"] == "1") {
					ds.WriteXml(Response.OutputStream);
				} else if (Request["tabla"] == "1") {
					StringBuilder sb = new StringBuilder("");
					for (int i = 0; i < ds.Tables.Count; i++){
						dt = ds.Tables[i];
						sb.Append("<table class='color resultados'><thead><tr>");
						foreach (DataColumn columna in dt.Columns){
							sb.Append("<th>" + columna.ColumnName + "</th>");
						}
						sb.Append("</tr></thead><tbody>");
						foreach (DataRow row in dt.Rows)
						{
							sb.Append("<tr>");
							for (int j = 0; j < dt.Columns.Count; j++)
							{
								if(j+1==dt.Columns.Count){
									sb.Append("<td style='text-align:right;'>" + row[j].ToString() + "</td>");
								}else{
									sb.Append("<td>" + row[j].ToString() + "</td>");
								}
							}
							sb.Append("</tr>");
						}
						sb.Append("</tbody></table>");
					}
					Response.clear();
					Response.ContentType = "text/html";
					Response.Write(sb);
				}
			}			
        }else{
			ds.WriteXml(Response.OutputStream);
		}
	}catch(Exception e){}
	
    }


    public string MapeoSeccion(string seccion) {
        string mapeo = seccion;
        switch (seccion) {
            case "tiposgastos": mapeo = "clasusuario";break;
            case "regen_tiposgastos": mapeo = "regegresos";break;
            case "regen_egrepro": mapeo = "regegresos";break;
            case "inmuebles": mapeo = "clasusuario";break;
            case "solicitudes_seg": mapeo = "solicitudes";break;
        }
        return mapeo;
    }

    public void GuardarArchivo(string mapsec) {
        DataSet ds = new DataSet();string ext = "";
        string f = "vImage";
        byte[] stream=null;
        try
        {
            if (Request["base64"] != null){
                ext = "." +Request["ext"];
                stream = Convert.FromBase64String(Request[f]);
            }else{
                ext = Util.ObtenerExtensionArchivoPost(Request.Files[f]);
            }
            ds=oModelo.GenerarOperacionCX("GuardarArchivo_", mapsec,  new object[,] {{ "Extensión de imagen", "extension", ext,true,"string", 99} ,{ "Usuario", "s_usuario", Session["s_usuario"],true,"int", 0},{ "Clave de fraccionamiento", "s_fraccionamiento", Session["s_fraccionamiento"],true,"int", 0}}, true);
            if (ds.Tables[0].Rows[0]["estatus"].ToString() == "1"){
                int clave = (int)ds.Tables[0].Rows[0]["clave"];
                string extant = "";
                if(ds.Tables[0].Columns.Contains("extant")){
                    extant =ds.Tables[0].Rows[0]["extant"].ToString();
                    if (System.IO.File.Exists(Server.MapPath("~/src-img") + "/fraccionamientos/_" + Session["s_fraccionamiento"] + "/" + Request["catalogo"] + "/" + "_" + Request["claveItem"] + "/" + "_" + clave + extant)) {
                        System.IO.File.Delete(Server.MapPath("~/src-img") + "/fraccionamientos/_" + Session["s_fraccionamiento"] + "/" + Request["catalogo"] + "/" + "_" + Request["claveItem"] + "/" + "_" + clave + extant);
                    }
                }
                if (!System.IO.Directory.Exists(Server.MapPath("~/src-img") + "/fraccionamientos/_" + Session["s_fraccionamiento"] + "/" + Request["catalogo"])) System.IO.Directory.CreateDirectory(Server.MapPath("~/src-img") + "/fraccionamientos/_" + Session["s_fraccionamiento"] +  "/" + Request["catalogo"]);
                if (!System.IO.Directory.Exists(Server.MapPath("~/src-img") + "/fraccionamientos/_" + Session["s_fraccionamiento"] + "/" + Request["catalogo"] + "/" + "_" + Request["claveItem"])) System.IO.Directory.CreateDirectory(Server.MapPath("~/src-img") + "/fraccionamientos/_" + Session["s_fraccionamiento"] +  "/" + Request["catalogo"] + "/" + "_" + Request["claveItem"]);
                string path = Server.MapPath("~/src-img") + "/fraccionamientos/_" + Session["s_fraccionamiento"] + "/" + Request["catalogo"] + "/" + "_" + Request["claveItem"] + "/" + "_" + clave + ext;
                if(Request["base64"] != null){
                    if (ext.ToLower().Contains("png") || ext.ToLower().Contains("jpeg") || ext.ToLower().Contains("jpeg")) {
                        File.WriteAllBytes(path,stream);
                    }else{
                        System.IO.FileStream strm = new FileStream(path, FileMode.CreateNew);
                        System.IO.BinaryWriter writer =new BinaryWriter(strm);
                        writer.Write(stream, 0, stream.Length);
                        writer.Close();
                    }
                }else {
                    Request.Files[f].SaveAs(path);
                }
                if (ext.ToLower().Contains("png") || ext.ToLower().Contains("jpeg") || ext.ToLower().Contains("jpeg") || ext.ToLower().Contains("gif") || ext.ToLower().Contains(".tiff")) {
                    try
                    {
                        Util.OptimizaImagen(path);
                    }catch(Exception e) { }
                }
            }
        }
        catch (Exception e) {
            ds = new DataSet();
            ds=Util.agregarCampoValor("estatus", "-1",ds);
            ds=Util.agregarCampoValor("mensaje", e.Message,ds);
        }
        ds.WriteXml(Response.OutputStream);
    }

    public void EliminarItem(string mapsec) {
        DataSet ds = new DataSet();
        try{
            ds=oModelo.GenerarOperacionCX("EliminarItem", mapsec, new object[,] {
                        { "Clave de fraccionamiento", "s_fraccionamiento", Session["s_fraccionamiento"],true,"int", 0}
                        ,{ "Usuario", "s_usuario", Session["s_usuario"],true,"int", 0}}, true);
            if (ds.Tables[0].Rows[0]["estatus"].ToString() == "1"){
                if (System.IO.Directory.Exists(Server.MapPath("~/src-img") + "/fraccionamientos/" + Session["s_fraccionamiento"] +  "/" + mapsec + "/" + "_" + Request["claveItem"]))
                    System.IO.Directory.Delete(Server.MapPath("~/src-img") + "/fraccionamientos/" + Session["s_fraccionamiento"] +  "/" + mapsec + "/" + "_" + Request["claveItem"],true);
            }
        }catch (Exception e) {
            ds=Util.agregarCampoValor("estatus", "-1",ds);
            ds=Util.agregarCampoValor("mensaje", e.Message,ds);
        }
        ds.WriteXml(Response.OutputStream);
    }

    public void EliminarImgTexto() {
        DataSet ds = new DataSet();
        try{
            ds=oModelo.GenerarOperacionCX("EliminarImgTexto", Request["seccion"], new object[,] {
                        { "Clave de fraccionamiento", "s_fraccionamiento", Session["s_fraccionamiento"],true,"int", 0}
                        ,{ "Usuario", "s_usuario", Session["s_usuario"],true,"int", 0}}, true);
            if (ds.Tables[0].Rows[0]["estatus"].ToString() == "1"){
                string ext = "",path="";
                if(ds.Tables[0].Columns.Contains("ext")){
                    ext=ds.Tables[0].Rows[0]["ext"].ToString();
                    path = Server.MapPath("~/src-img") + "/" + Request["catalogo"] + "/" + "_" + Request["claveItem"] + "/" + "_" + Request["indice"] + ext;
                    if (System.IO.File.Exists(path)) {
                        System.IO.File.Delete(path);
                    }
                }
            }
        }catch (Exception e) {
            ds=Util.agregarCampoValor("estatus", "-1",ds);
            ds=Util.agregarCampoValor("mensaje", e.Message,ds);
        }
        ds.WriteXml(Response.OutputStream);
    }

    public void EnviarNotificacion_HTTP(){
        Response.Write(EnviarNotificacion("FRA_" + Request["fracc"],Request["titulo"],Request["mensaje"],Request["modulo"].ToString(),Request["dato"], Request["contenido"]));
    }

    public string EnviarNotificacion(string para,string titulo, string mensaje,string clave, string dato, string contenido)
    {
        var result = "-1";
        try
        {
            var webAddr = "https://fcm.googleapis.com/fcm/send";
            var httpWebRequest = (HttpWebRequest)WebRequest.Create(webAddr);
            httpWebRequest.ContentType = "application/json";
            httpWebRequest.Headers.Add(HttpRequestHeader.Authorization, "key=AIzaSyAPnaN3CleOEQ1Q6ot420w4uDJJL5Sss9A");
            httpWebRequest.Method = "POST";
            string strNJson = "";
            using (var streamWriter = new StreamWriter(httpWebRequest.GetRequestStream())){
                strNJson="{\"to\":\"/topics/"+ para + "\"" + (titulo!=null? ",\"notification\":{\"title\":\"" + titulo + "\",\"body\":\"" + mensaje + "\",\"sound\":\"timbre1.mp3\",\"click_action\":\"FCM_PLUGIN_ACTIVITY\"}":"") + ",\"data\":{\"content-available\": \"1\"," + (clave!=null? "\"modulo\":\"" + clave + "\"":"") + (dato!=null || contenido!=null?",":"")+ (dato!=null? "\"dato\":\"" + dato + "\"":"") + (contenido!=null?",\"contenidovoz\":\"http://bolsadetrabajo.encomunidad.mx/intranet/Modulos/Capacitacion/CursosNegocio/notavoz.mp3?op=ObtenerNotaVozSlide&nota=" + Server.UrlEncode(contenido) + "\"":"")+"},\"android\":{\"priority\":\"high\",\"content-available\":1},\"priority\":\"high\",\"content_available\":true}";
                streamWriter.Write(strNJson);
                streamWriter.Flush();
            }
            var httpResponse = (HttpWebResponse)httpWebRequest.GetResponse();
            using (var streamReader = new StreamReader(httpResponse.GetResponseStream()))
            {
                result = streamReader.ReadToEnd();
            }
            result="<xml><result>" +result + "</result>" + strNJson + "</xml>";
        }
        catch (Exception e) {
            result="<xml>" + e.Message + "</xml>";
        }
        return result;
    }
	
    </script>

<%

    string op = Request["op"], seccion=Request["seccion"];
    switch (op) {
        case "PresentarPagador":
            Response.Clear();
            Response.ContentType = "text/html";
            DataSet ds=oModelo.GenerarOperacionCX("ObtenerResumenPago", "aportaciones", new object[,]{
             { "Clave de fraccionamiento", "s_fraccionamiento", Session["s_fraccionamiento"]==null?Request["fracc"]:Session["s_fraccionamiento"],true,"int", 0}
            ,{ "Usuario", "s_usuario", Session["s_usuario"]==null?Request["usuario"]:Session["s_usuario"],true,"int", 0}}, true);

%>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no"/>
    <script src="../ui/mobile/safra/md5.js"></script>    
    <title>SAFRA::PAGO</title>
    <link href="css/terceros.css" rel="stylesheet" />
   
</head>
<body onload="IniPay();">
    <h2>SAFRA-PAYU</h2>
    <%  
        if ((int)ds.Tables[0].Rows[0]["estatus"] == 1) {
            string descripcion = "Condominio:" + ds.Tables[0].Rows[0]["nombre"]+ "," + ds.Tables[0].Rows[0]["fdomicilio"] + "; A cuenta de: " + ds.Tables[0].Rows[0]["sdomicilio"] + "; Conceptos: ";
            string coma = "";
            for (int i=0;i<ds.Tables[1].Rows.Count;i++) { descripcion += coma + ds.Tables[1].Rows[i]["nombre"] + " $ " + ((decimal)ds.Tables[1].Rows[i]["cuota"]).ToString("n2");coma = ", ";  }
     %> 
    <script>
        function IniPay() {            
            document.getElementById("referenceCode").value = "c:<%=Request["c"]%>-f:<%=Session["s_fraccionamiento"]==null?Request["fracc"]:Session["s_fraccionamiento"]%>-d:<%=ds.Tables[0].Rows[0]["domicilio"]%>-usu:<%=Session["s_usuario"]==null?Request["usuario"]:Session["s_usuario"]%>";
            var signature = document.getElementById("signature");
            var cadena = document.getElementById("apiKey").value + "~" +
            document.getElementById("merchantId").value + "~" +
            document.getElementById("referenceCode").value + "~" +
            document.getElementById("amount").value + "~" +
            document.getElementById("currency").value;
            signature.value = CryptoJS.MD5(cadena);                       
        }
    </script>
    <div class="leyenda"><p>Por favor espere, se esta estableciendo comunicación con PAYU para procesar su pago.</p></div>    

    <form method="post" action="https://sandbox.checkout.payulatam.com/ppp-web-gateway-payu/" style="display:none;" id="frm">
       <input name="merchantId"    type="hidden"  value="<%=ds.Tables[0].Rows[0]["merchantId"]%>"  id="merchantId" />
        <input name="accountId"     type="hidden"  value="<%=ds.Tables[0].Rows[0]["accountId"]%>" />
        <input name="ApiKey"     type="hidden"  value="<%=ds.Tables[0].Rows[0]["ApiKey"]%>" id="apiKey"/>
        <input name="description"   type="hidden"  id="description" value="<%=descripcion %>"/>
        <input name="referenceCode" type="hidden"  id="referenceCode" />
        <input name="amount"        type="hidden"  id="amount" value="<%=((decimal)ds.Tables[0].Rows[0]["total"]).ToString("0.00") %>"/>
        <input name="tax"           type="hidden"  value="0"  />
        <input name="taxReturnBase" type="hidden"  value="0" />
        <input name="currency"      type="hidden"  value="MXN" id="currency" />
        <input name="signature"     type="hidden"  value="" id="signature" />
        <input name="test"          type="hidden"  value="1" />
        <input name="buyerEmail"    type="hidden"  value="<%=Session["s_email"] %>"/>
      <input name="confirmationUrl"  type="hidden"  value="http://safra.softronel.com.mx/logic/controlador.aspx?op=RegistrarPagoPayU&seccion=aportaciones" />
    </form>
    <button class="aceptar" onclick="document.getElementById('frm').submit();">Continuar</button>      
    <%} else { %>
        <h4>Por el monmento no podemos procesar su pago, intente mas tarde, por favor.</h4>
        <h4><%=ds.Tables[0].Rows[0]["mensaje"] %></h4>
    <%} %>
</body>
</html>
<%
            break;
        case "Finalizar":
        Response.Clear();
        Response.ContentType = "text/html";
%>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <meta name="viewport" content="width=device-width, height=device-height" />    
    <title>SAFRA::PAYU</title>
</head>
<body>
   
</body>
</html>            
<%
            break;
    }
%>

