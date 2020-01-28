B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=StaticCode
Version=6.51
@EndOfDesignText@
'Static code module
Sub Process_Globals

End Sub

Sub cleanedEntry(entry As String) As String
	entry=Regex.Replace($"<span class="DC">.*?</span>"$,entry,"")
	entry=Regex.Replace("<.*?>",entry,CRLF)
	entry=entry.Replace("\n","")
	entry=entry.Replace("■","")
	Dim matcher As Matcher
	matcher=Regex.Matcher(CRLF&CRLF,entry)
	Do While matcher.Find
		entry=Regex.Replace(CRLF&CRLF,entry,CRLF)
		matcher=Regex.Matcher(CRLF&CRLF,entry)
	Loop
	Return entry
End Sub

Sub UUID As String
	Dim jo As JavaObject
	Return jo.InitializeStatic("java.util.UUID").RunMethod("randomUUID", Null)
End Sub

Sub UniqueID As String
	Dim su As StringUtils
	Dim md5 As MessageDigest
	Dim result As String=su.EncodeBase64(md5.GetMessageDigest(UUID.GetBytes("UTF-8"),"MD5"))
	result=result.Replace("\","")
	result=result.Replace("/","")
	result=result.Replace("+","")
	result=result.Replace("=","")
	Return result
End Sub

Sub removeDuplicated(source As List)
	Dim newList As List
	newList.Initialize
	For Each item As Object In source
		If newList.IndexOf(item)=-1 Then
			newList.Add(item)
		End If
	Next
	source.Clear
	source.AddAll(newList)
End Sub

Sub splitByStrs(strs() As String,text As String) As List
	For Each str As String In strs
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

Sub LanguageHasSpace(lang As String) As Boolean
	Dim languagesWithoutSpaceList As List
	languagesWithoutSpaceList=File.ReadList(File.DirAssets,"languagesWithoutSpace.txt")
	For Each code As String In languagesWithoutSpaceList
		If lang.ToLowerCase.StartsWith(code) Then
			Return False
		End If
	Next
	Return True
End Sub

Sub isChinese(text As String) As Boolean
	Dim jo As JavaObject
	jo=Me
	Return jo.RunMethod("isChinese",Array As String(text))
End Sub

#If JAVA

private static boolean isChinese(char c) {

    Character.UnicodeBlock ub = Character.UnicodeBlock.of(c);

    if (ub == Character.UnicodeBlock.CJK_UNIFIED_IDEOGRAPHS || ub == Character.UnicodeBlock.CJK_COMPATIBILITY_IDEOGRAPHS

            || ub == Character.UnicodeBlock.CJK_UNIFIED_IDEOGRAPHS_EXTENSION_A || ub == Character.UnicodeBlock.CJK_UNIFIED_IDEOGRAPHS_EXTENSION_B

            || ub == Character.UnicodeBlock.CJK_SYMBOLS_AND_PUNCTUATION || ub == Character.UnicodeBlock.HALFWIDTH_AND_FULLWIDTH_FORMS

            || ub == Character.UnicodeBlock.GENERAL_PUNCTUATION) {

        return true;

    }

    return false;

}



// 完整的判断中文汉字和符号

public static boolean isChinese(String strName) {

    char[] ch = strName.toCharArray();

    for (int i = 0; i < ch.length; i++) {

        char c = ch[i];

        if (isChinese(c)) {

            return true;

        }

    }

    return false;

}
#End If
