using Repository.Domain.Interface;
using Repository.Domain.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Repository.Infraestructure.Queries;
using Microsoft.Extensions.Logging;
using System.Drawing.Imaging;

using DocumentFormat.OpenXml;
using DocumentFormat.OpenXml.Packaging;
using DocumentFormat.OpenXml.Spreadsheet;
using Common.Google.Storage;
using System.IO;
using Microsoft.AspNetCore.Mvc;
using System.Data;

namespace Reports.API.Application.Services
{
  public class ExcelService : IExcelService {

    private readonly IStorageService _cloudStorage;
     public ExcelService(IStorageService cloudStorage){
        _cloudStorage = cloudStorage ?? throw new ArgumentNullException(nameof(cloudStorage));
     }
    public string CrearExcel(DataSet dts, string path){
        DataTable dt_ = (dts.Tables.Count > 0 ? dts.Tables[0] : null);
        string filepath = "";
        MemoryStream memoryStream = new MemoryStream();
        SpreadsheetDocument spreadsheetDocument = SpreadsheetDocument.
            Create(memoryStream, SpreadsheetDocumentType.Workbook);

        WorkbookPart workbookpart = spreadsheetDocument.AddWorkbookPart();
        workbookpart.Workbook = new Workbook();

        WorksheetPart worksheetPart = workbookpart.AddNewPart<WorksheetPart>();
        worksheetPart.Worksheet = new Worksheet(new SheetData());

        Sheets sheets = spreadsheetDocument.WorkbookPart.Workbook.
            AppendChild<Sheets>(new Sheets());

        Sheet sheet = new Sheet()
        {
            Id = spreadsheetDocument.WorkbookPart.
            GetIdOfPart(worksheetPart),
            SheetId = 1,
            Name = "Reporte"
        };
        sheets.Append(sheet);

        SheetData data = worksheetPart.Worksheet.GetFirstChild<SheetData>();

        Row header = new Row();
        header.RowIndex = (UInt32)1;

        foreach (DataColumn column in dt_.Columns){
            Cell headerCell = createTextCell(dt_.Columns.IndexOf(column) + 1, 1, column.ColumnName);
            header.AppendChild(headerCell);
        }
        data.AppendChild(header);

        DataRow contentRow;
        for (int i = 0; i < dt_.Rows.Count; i++){
            contentRow = dt_.Rows[i];
            data.AppendChild(createContentRow(contentRow, i + 2));
        }

        //Procesar Formato archivo
        if(true){
            for(int i = 0;i<data.Count();i++) {
                    celdaInicio = ObtenerCeldasAgrupacion(,);
                    ws.Range(celdaIncio, celdaFin).Merge();
                }
        }

        spreadsheetDocument.Close();
        memoryStream.Seek(0, SeekOrigin.Begin);

        Task.Run(async () => await _cloudStorage.UploadFileAsync(memoryStream, path));
        filepath = $"https://storage.googleapis.com/goldenstarweb/" + path;
        //using (FileStream file = new FileStream("report.xlsx", FileMode.Create, System.IO.FileAccess.Write))
        //memoryStream.WriteTo(file);
        return filepath;
      }

        private string getColumnName(int columnIndex){
            int dividend = columnIndex;
            string columnName = String.Empty;
            int modifier;

            while (dividend > 0){
                modifier = (dividend - 1) % 26;
                columnName =Convert.ToChar(65 + modifier).ToString() + columnName;
                dividend = (int)((dividend - modifier) / 26);
            }
            return columnName;
        }

        private Cell createTextCell(int columnIndex,int rowIndex, object cellValue){
            Cell cell = new Cell();
            cell.DataType = CellValues.InlineString;
            cell.CellReference = getColumnName(columnIndex) + rowIndex;
            InlineString inlineString = new InlineString();
            Text t = new Text();
            t.Text = cellValue.ToString();
            inlineString.AppendChild(t);
            cell.AppendChild(inlineString);
            return cell;
        }

        private Row createContentRow(DataRow dataRow, int rowIndex){
            Row row = new Row{RowIndex = (UInt32)rowIndex};
            for (int i = 0; i < dataRow.Table.Columns.Count; i++){
                Cell dataCell = createTextCell(i + 1, rowIndex, dataRow[i]);
                row.AppendChild(dataCell);
            }
            return row;
        }


    }
}


using Dapper;
using Microsoft.Data.SqlClient;
using Newtonsoft.Json.Linq;
using Reports.API.Application.Queries;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Threading.Tasks;

namespace Reports.API.Application.Queries
{
    public class ReportsQueries : IReportsQueries
    {
        private readonly string _connectionString;

        public ReportsQueries(string connectionString)
        {
            _connectionString = connectionString ?? throw new ArgumentNullException(nameof(connectionString));
        }

        public ReportResult GetReport(int idReport, JObject reportRequest)
        {
            try
            {
                var result = new ReportResult();
                using (var coneccion = new SqlConnection(_connectionString))
                {
                    //Abre la coneccion
                    coneccion.Open();
                    IEnumerable<ReporteParametro> parametros = coneccion.Query<ReporteParametro>(@"SELECT B.* FROM REL_Parametros_Reporte A INNER JOIN CAT_ReportesParametros B ON A.IdParametro=B.IdParametro WHERE IdReporte=@idReport", new { idReport });                    
                    string paramsFaltantes = "";
                    foreach (ReporteParametro rp in parametros){
                        if (rp.Obligatorio){
                            if (reportRequest[rp.Nombre] == null){
                                paramsFaltantes += paramsFaltantes + "," + rp.Nombre;
                            }
                        }
                    }
                    if(paramsFaltantes.Length==0){
                        Reporte reporte = coneccion.QueryFirstOrDefault<Reporte>(@"SELECT * FROM CAT_Reportes WHERE IdReporte=@idReport;", new { idReport });
                        var p = new DynamicParameters(); foreach (ReporteParametro rp in parametros){
                            p.Add( rp.Nombre, ObtenerValor(reportRequest, rp.Nombre, rp.IdTipoDato));
                        }
                        foreach (ReporteParametro rp in parametros){
                            string concatParam = ObtenerValor(reportRequest, rp.Nombre, rp.IdTipoDato).ToString();
                            if (rp.tieneMapeo) {
                                concatParam = coneccion.QueryFirstOrDefault<string>(rp.Mapeo, p);
                            }
                            reporte.Entregable = reporte.Entregable.Replace("@"+rp.Nombre, concatParam);
                        }
                        Validacion validacion = coneccion.QueryFirstOrDefault<Validacion>(reporte.ScriptValidacion, p);
                        DataSet data = null;
                        if (validacion.estatus)
                        {
                            try{
                                using (SqlCommand cmd = new SqlCommand(reporte.ScriptSQL, coneccion)){
                                    foreach (ReporteParametro rp in parametros){
                                        cmd.Parameters.Add(new SqlParameter( rp.Nombre, ObtenerValor(reportRequest, rp.Nombre, rp.IdTipoDato)));
                                    }
                                    SqlDataAdapter adapter = new SqlDataAdapter(cmd);
                                    result.data = new DataSet();
                                    adapter.Fill(result.data);
                                    result.reporte = reporte;
                                    result.parametros = parametros;
                                    result.estatus = true;
                                    result.message = "ok";
                                    result.Emails = ObtenerEmails(reporte.IdNotificacion);
                                    //Creando la coneccion
                                }
                            }
                            catch(Exception ex){
                                result.estatus = false;
                                result.message = ex.Message;
                            }
                        }
                        else
                        {
                            result.estatus = validacion.estatus;
                            result.message = validacion.message;
                            result.Emails = ObtenerEmails(reporte.IdNotificacion);
                        }
                    }
                    else {
                        result.estatus = false;
                        result.message = "No se tienen los parametros necesarios para procesar esta petición. Faltan: " + paramsFaltantes;
                    }
                    return result;

                }
            }
            catch (Exception er) {
                throw new Exception(er.StackTrace);
            }

        }

        public string ValidarParametros(int idReport, JObject reportRequest) {
            using (var coneccion = new SqlConnection(_connectionString))
            {
                //Abre la coneccion
                coneccion.Open();
                IEnumerable<ReporteParametro> parametros = coneccion.Query<ReporteParametro>(@"SELECT B.* FROM REL_Parametros_Reporte A INNER JOIN CAT_ReportesParametros B ON A.IdParametro=B.IdParametro WHERE IdReporte=@idReport", new { idReport });
                string paramsFaltantes = "";
                foreach (ReporteParametro rp in parametros)
                {
                    if (rp.Obligatorio)
                    {
                        if (reportRequest[rp.Nombre] == null)
                        {
                            paramsFaltantes += paramsFaltantes.Length>0? ",":"" + rp.Nombre;
                        }
                    }
                }
                return paramsFaltantes;

            }
        }

        public List<string> ObtenerEmails(int idNotificacion)
        {
            using (var coneccion = new SqlConnection(_connectionString))
            {
                //Abre la coneccion
                coneccion.Open();
                IEnumerable<string> parametros = coneccion.Query<string>(@"Select CONCAT(cu.Email,',',ne.Extras) AS Emails from CAT_NotificacionesEmail ne inner join CAT_Usuarios cu ON ne.IdUsuario = cu.IDUsuario where ne.IdNotificacion = @idNotificacion", new { idNotificacion });

                var emails = parametros.FirstOrDefault().Split(",");

                return emails.ToList();

            }
        }

        private object ObtenerValor(JObject obj, string nombre, int tipo)
        {
            switch (tipo) {
                case 1: return (int)obj[nombre];
                case 2: return (string)obj[nombre];
                case 3: return (bool)obj[nombre];
                case 4: return (string)obj[nombre];
                default: return null;
            }
        }

        public class Validacion {
            public bool estatus { get; set; }
            public string message { get; set; }
        }
        public class ReportResult{
            public Reporte reporte { get; set; }
            public bool estatus { get; set; }
            public string message { get; set; }
            public IEnumerable<ReporteParametro> parametros { get; set; }
            public DataSet data { get; set; }
            public List<string> Emails { get; set; }
        }

        public class Reporte {
            public int IdReporte { set; get; }
            public string Nombre { set; get; }
            public string Descripcion { set; get; }
            public string Entregable { set; get; }
            public string ScriptValidacion { set; get; }
            public string ScriptSQL { set; get; }
            public bool Estatus { set; get; }
            public int IdNotificacion { get; set; }
        }

        public class ReporteParametro
        {
            public int IdReporte { set; get; }
            public int IdParametro { set; get; }
            public string Nombre { set; get; }
            public string Descripcion { set; get; }
            public int IdTipoDato { set; get; }
            public bool Obligatorio { set; get; }
            public string Val_Default { set; get; }
            public bool tieneMapeo { set; get; }
            public string Mapeo { set; get; }
        }


    }
}


using Newtonsoft.Json.Linq;
using Reports.API.Application.Queries;
using Reports.API.Application.Services.Email;
using Reports.API.Application.Services.Email.Resources;
using Repository.Domain.Model;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Threading;
using System.Threading.Tasks;

namespace Reports.API.Application.Services
{
    public class ReportsService : IReportsService
    {
        //readonly ReportsContext ReportsContext;
        private readonly IReportsQueries _ReportsQueries;
        private readonly IExcelService _excelService;
        private readonly IPDFService _pdfService;
        private readonly IEmailService _emailService;
        public ReportsService(IReportsQueries ReportsQueries, IExcelService ExcelService, IPDFService pdfService, IEmailService emailService)
        {
            _ReportsQueries = ReportsQueries ?? throw new ArgumentNullException(nameof(ReportsQueries));
            _excelService = ExcelService ?? throw new ArgumentNullException(nameof(ExcelService));
            _pdfService = pdfService ?? throw new ArgumentNullException(nameof(pdfService));
            _emailService = emailService ?? throw new ArgumentNullException(nameof(emailService));
        }

        public async Task<GenericResponse> GetReport(int idReport, string format,bool iswait, JObject reportRequest){
            try {
                ProcesarReporte p = new ProcesarReporte(_ReportsQueries,_excelService,_pdfService, idReport, format, iswait, reportRequest, _emailService);
                if(p.ParametrosCompletos()){
                    if (iswait) {
                        p.ExecuteReport();
                        if (p.estatus) { 
                            return new GenericResponse { status = true, message = "Éxito al procesar petición.", o = new URL { url = p.url } };
                        }else { 
                           return new GenericResponse { status = false, message = p.mensaje }; 
                        }
                    }
                    else {
                        Thread t = new Thread(new ThreadStart(p.ExecuteReport));
                        t.Start();
                        return new GenericResponse { status = true, message = "El proceso se comenzó a ejecutar, cuando finalice se le notificará por E-mail." };
                    }
                }else {
                    return new GenericResponse { status = false, message = "No se puede procesar la solicitud. Faltan los siguientes datos: " + p.mensaje };
                }
            }
            catch(Exception e){
                return new GenericResponse {status=false,message="Error al procesar petición.", technic_message=e.Message };
            }
        }
        public class ProcesarReporte {
            public string url = ""; 
            public string mensaje = "";
            public bool estatus=true;
            int idReport; string format; JObject reportRequest;IReportsQueries _reportQueries;int it = 0; bool iswait=false;IExcelService excelService;IPDFService pdfService; IEmailService emailServic;
            public ProcesarReporte(IReportsQueries rq,IExcelService es,IPDFService _pdf, int _idReport, string _format,bool _iswait,  JObject _reportRequest, IEmailService _em) {
                this.idReport = _idReport;
                this.format = _format;
                this.reportRequest = _reportRequest;
                this._reportQueries = rq;
                this.iswait = _iswait;
                this.excelService = es;
                this.pdfService = _pdf;
                this.emailServic = _em;
            }
            public void ExecuteReport(){
                if(format=="xlsx"||format=="pdf"){
                    ReportsQueries.ReportResult reportResult= this._reportQueries.GetReport(this.idReport, reportRequest);
                    if (reportResult.estatus)
                    {
                        if (format == "xlsx"){
                            this.url = excelService.CrearExcel(reportResult.data, $"media/Reports/Empresas/Legales/{reportResult.reporte.Entregable}.xlsx");
                        }else if (format == "pdf"){
                            //this.url = await pdfService.CrearPDF(reportResult.data, $"media/reports/empresas/{1}/{idReport}_report.pdf");
                        }
                        if(!this.iswait)
                            emailServic.SendEmailDynamic(new EmailRequest { EmailDestino = reportResult.Emails, Contenido = this.url, Asunto = reportResult.reporte.Nombre, Alert = true });
                    }
                    else
                        if (!this.iswait)
                        emailServic.SendEmailDynamic(new EmailRequest { EmailDestino = reportResult.Emails, Contenido = "Se encontro error " + reportResult.message, Asunto = reportResult.reporte.Nombre, Alert = false });
                }
                else{
                    this.estatus = false;
                    this.mensaje="No éxiste el formato ingresado: " + format + ", por favor verifique.";                   
                }
                /*while (this.it < 21) {
                    try{
                        using StreamWriter file = new StreamWriter("ReportsLogThread.txt", append: true);
                        await file.WriteLineAsync("Line: " + this.it);
                    } catch (Exception ex) {
                        Console.WriteLine("Exception: " + ex.InnerException.ToString());
                    }
                    Console.WriteLine("Line: " + this.it++);
                    Thread.Sleep(1000);
                }*/

                //Enviar Correo. (ReportResult or url dependiendo del esttus.)
                
                
            }

            internal bool ParametrosCompletos(){
                this.mensaje = this._reportQueries.ValidarParametros(this.idReport, reportRequest);
                return this.mensaje.Length == 0;
            }
        }
        public class URL {
            public string url { get; set; }
        }
    }
}
