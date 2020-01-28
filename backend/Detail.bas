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
	Try
		Dim id,rowid As String
		id=req.GetParameter("id")
		rowid=req.GetParameter("rowid")
		resp.ContentType = "text/html"
		resp.CharacterEncoding="UTF-8"
		Dim db1 As DB
		If File.Exists(File.Combine(File.DirApp,"db"),id&".db")=False Then
			resp.SendError("404","not exist")
			Return
		End If
		db1.Initialize(File.Combine(File.DirApp,"db"),id&".db")
		
		Dim sb As StringBuilder
		sb.Initialize
		sb.Append(head(id))
		sb.Append(db1.GetDetail(rowid).Replace("\n",""))
		sb.Append(tail)
		resp.Write(sb.ToString)
	Catch
		Log(LastException)
		resp.SendError(500,LastException)
	End Try
End Sub


Sub head(id As String) As String
	Return $"<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="zh-CN" lang="zh-CN">
  <head>
    <meta name="viewport" content="width=device-width, initial-scale=1" />    
    <meta http-equiv="content-type" content="text/html; charset=utf-8" />
    <link href="/${id}.css" rel="stylesheet">
	<title>Detail</title></head>
  <body><p>"$
End Sub

Sub tail As String
	Return $"  </p></body>
</html>"$
End Sub