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
		Dim params As Map=req.ParameterMap
		Log(params)
		Dim ID,page,keyword As String
		ID=stringsToString(params.Get("id"))
		page=stringsToString(params.Get("page"))
		keyword=stringsToString(params.Get("keyword"))
		params.Remove("id")
		params.Remove("keyword")
		params.Remove("page")
		Dim categories As Map
		categories.Initialize
		For Each key As String In params.Keys
			categories.Put(key,stringsToString(params.Get(key)))
		Next
		resp.ContentType = "application/json"
		resp.CharacterEncoding="UTF-8"
		Dim db1 As DB
		If File.Exists(File.Combine(File.DirApp,"db"),ID&".db")=False Then
			resp.SendError("404","not exist")
			Return
		End If
		db1.Initialize(File.Combine(File.DirApp,"db"),ID&".db")
		Dim result As List=db1.GetMatchedListAsync(keyword,page,categories)
		Dim json As JSONGenerator
		json.Initialize2(result)
		'Log(json.ToString)
		resp.Write(json.ToString)
	Catch
		Log(LastException)
		resp.SendError(500,LastException)
	End Try
End Sub

Sub stringsToString(strs() As String) As String
	Try
		Return strs(0)
	Catch
		Log(LastException)
	End Try
	Return ""
End Sub