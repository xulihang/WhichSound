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
		Dim ID,page,keyword As String
		ID=req.GetParameter("id")
		page=req.GetParameter("page")
		keyword=req.GetParameter("keyword")
		resp.ContentType = "application/json"
		resp.CharacterEncoding="UTF-8"
		Dim db1 As DB
		If File.Exists(File.Combine(File.DirApp,"db"),ID&".db")=False Then
			resp.SendError("404","not exist")
			Return
		End If
		db1.Initialize(File.Combine(File.DirApp,"db"),ID&".db")
		Dim result As List=db1.GetMatchedListAsync(keyword,page)
		Dim json As JSONGenerator
		json.Initialize2(result)
		'Log(json.ToString)
		resp.Write(json.ToString)
	Catch
		Log(LastException)
		resp.SendError(500,LastException)
	End Try
End Sub