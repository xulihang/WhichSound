﻿B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=7.8
@EndOfDesignText@
Sub Class_Globals
	Private sql1 As SQL
	'Private ser As B4XSerializator
End Sub

'Initializes the store and sets the store file.
Public Sub Initialize (Dir As String, FileName As String)

	If sql1.IsInitialized Then sql1.Close
#if B4J
	sql1.InitializeSQLite(Dir, FileName, True)
#else
	sql1.Initialize(Dir, FileName, True)
#end if
	sql1.ExecNonQuery("PRAGMA journal_mode = wal")
End Sub

Public Sub Put(heads As List, data As List)
	sql1.ExecNonQuery("CREATE VIRTUAL TABLE IF NOT EXISTS idx USING fts4("&getColumns(heads)&")")
	sql1.BeginTransaction
	For Each row As List In data
		sql1.ExecNonQuery2("INSERT INTO idx VALUES("&getPlaceHolder(heads)&")", row)
	Next
	sql1.TransactionSuccessful
End Sub

Sub getColumns(keys As List) As String
	Dim sb As StringBuilder
	sb.Initialize
	For i=0 To keys.Size-1
		sb.Append(keys.Get(i))
		If i<>keys.Size-1 Then
			sb.Append(", ")
		End If
	Next
	sb.Append(", notindexed=raw")
	Log(sb.ToString)
	Return sb.ToString
End Sub

Sub getPlaceHolder(keys As List) As String
	Dim sb As StringBuilder
	sb.Initialize
	For i=0 To keys.Size-1
		sb.Append("?")
		If i<>keys.Size-1 Then
			sb.Append(", ")
		End If
	Next
	Return sb.ToString
End Sub

'Closes the store.
Public Sub Close
	sql1.Close
End Sub

'Tests whether a key is available in the store.
Public Sub size As Int
	Dim rs As ResultSet = sql1.ExecQuery("SELECT count(rowid) FROM idx")
	Return rs.GetInt2(0)
End Sub
	
Sub getWordsForAll(text As String) As List
	Dim words As List
	words.Initialize
	words.AddAll(LanguageUtils.TokenizedList(text,"en"))
	words.AddAll(LanguageUtils.TokenizedList(text,"zh"))
	LanguageUtils.removeCharacters(words)
	LanguageUtils.removeMultiBytesWords(words)
	Return words
End Sub

Sub getQuery(words As List,operator As String) As String
	Utils.removeDuplicated(words)
	Dim sb As StringBuilder
	sb.Initialize
	For index =0 To words.Size-1
		Dim word As String=words.Get(index)
		If word.Trim<>"" Then
			sb.Append(word)
			If index<>words.Size-1 Then
				sb.Append(" "&operator&" ") ' AND OR NOT
			End If
		End If
	Next
	Return sb.ToString
End Sub

Public Sub GetDetail(rowid As Int) As String
	Dim rs As ResultSet = sql1.ExecQuery("SELECT raw FROM idx WHERE rowid = "&rowid)
	Return rs.GetString2(0)
End Sub

Public Sub GetMatchedListAsync(text As String,page As Int) As List
	'Dim maxLength As Int=text.Length*2
	Dim sqlStr As String
	Dim operator As String
	Dim words As List
	words.Initialize
	operator="AND"
	If text.StartsWith($"""$) And text.EndsWith($"""$) Then
		words.Add(text.ToLowerCase)
	Else
		words=getWordsForAll(text.ToLowerCase)
	End If
	text=getQuery(words,operator)
	
	sqlStr="SELECT raw, word, rowid, quote(matchinfo(idx)) as rank FROM idx WHERE content MATCH '"&text&"' ORDER BY rank DESC LIMIT 15 OFFSET "&((page-1)*15)
	Log(sqlStr)
	Dim rs As ResultSet = sql1.ExecQuery2(sqlStr, Null)

	Dim resultList As List
	resultList.Initialize
	Do While rs.NextRow
		Dim result As Map
		result.Initialize
		Dim Hightlight As String
		Hightlight=getHightlight(Utils.cleanedEntry(rs.GetString2(0)),words)
		Dim word As String=rs.GetString2(1)
		result.Put("highlight",Hightlight)
		result.Put("word",word)
		result.Put("rowid",rs.GetInt2(2))
		resultList.Add(result)
	Loop
	rs.Close
	Return resultList
End Sub


Sub getHightlight(text As String,words As List) As String
	If words.Size=1 Then
		Dim word As String = words.Get(0)
		If word.StartsWith($"""$) And word.EndsWith($"""$) Then
			words.Clear
			words.Add(word.SubString2(1,word.Length-1))
		End If
	End If
	Dim sb As StringBuilder
	sb.Initialize
	For Each line As String In Regex.Split(CRLF,text)
		Dim textSegments As List
		textSegments=splitByStrs(words,line)
		If textSegments.Size=1 Then
			Continue
		End If
		For Each textSegment As String In textSegments
			If words.IndexOf(textSegment.ToLowerCase)<>-1 Then
				sb.Append("<em>").Append(textSegment).Append("</em>")
			Else
				sb.Append(textSegment)
			End If
		Next
		Exit
	Next
	Return sb.ToString
End Sub

Sub splitByStrs(words As List,text As String) As List
	For Each str As String In words
		Dim matcher As Matcher
		matcher=Regex.Matcher(str.ToLowerCase,text.ToLowerCase)
		Dim offset As Int=0
		Do While matcher.Find
			Dim startIndex,endIndex As Int
			startIndex=matcher.GetStart(0)+offset
			endIndex=matcher.GetEnd(0)+offset
			text=text.SubString2(0,endIndex)&"<--->"&text.SubString2(endIndex,text.Length)
			text=text.SubString2(0,startIndex)&"<--->"&text.SubString2(startIndex,text.Length)
			offset=offset+"<--->".Length*2
		Loop
	Next
	Dim result As List
	result.Initialize
	For Each str As String In Regex.Split("<--->",text)
		result.Add(str)
	Next
	Return result
End Sub