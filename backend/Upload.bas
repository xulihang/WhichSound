B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=7.8
@EndOfDesignText@
'Handler class
Sub Class_Globals
	
End Sub

Public Sub Initialize
	
End Sub

Sub Handle(req As ServletRequest, resp As ServletResponse)
	If File.Exists(File.DirApp,"db")=False Then
		File.MakeDir(File.DirApp,"db")
	End If
	If File.Exists(File.DirApp,"xlsx")=False Then
		File.MakeDir(File.DirApp,"xlsx")
	End If
	If req.Method <> "POST" Then
		resp.SendError(500, "method not supported.")
		Return
	End If
	resp.ContentType = "application/json"
	resp.CharacterEncoding="UTF-8"
	Dim parts As Map = req.GetMultipartData(Main.TempDir, 50*1000*1000*1000) 'byte
	Dim filePart As Part = parts.Get("upload")
	Dim css As Part = parts.Get("css")
	Dim id As String= Utils.UniqueID
	If filePart.SubmittedFilename.ToLowerCase.EndsWith(".xlsx") Then
		File.Copy(filePart.TempFile,"",File.Combine(File.DirApp,"xlsx"),id&".xlsx")
	Else
		resp.Write("unsupported file")
		Return
	End If
	If css.GetValue("UTF-8")<>"" Then
		File.WriteString(File.Combine(File.DirApp,"www"),id&".css",css.GetValue("UTF-8"))
	End If
	File.Delete("", filePart.TempFile)
	Dim data As List
	data.Initialize
	Dim wb As PoiWorkbook
	wb.InitializeExisting(File.Combine(File.DirApp,"xlsx"),id&".xlsx","")
	Dim sheet1 As PoiSheet
	sheet1 = wb.GetSheet(0)
	Dim heads As List
	For Each row As PoiRow In sheet1.Rows
		If row.RowNumber=0 Then
			heads=row.Cells
			Continue
		End If
		data.Add(row.Cells)
	Next
	Dim db1 As DB
	db1.Initialize(File.Combine(File.DirApp,"db"),id&".db")
	db1.Put(heads,data)
	resp.Write(id)
End Sub
