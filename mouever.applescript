property evernotebook : missing value
property evertag : {}
property evernotetitle : ""
property filename : ""
property overwritecheck : true -- 同名のノートを確認なしに上書き保存するのであれば false
property finishalert : true -- Evernoteに投稿が完了したダイアログを表示しないのであれば false

-- github.css of Mou
script mougithubCSS
	property body : "margin:0;padding:0;font:13.34px helvetica,arial,freesans,clean,sans-serif;color:black;line-height:1.4em;background-color: #F8F8F8;"
	property h1 : "margin:0;padding:0;border:0;font-size:170%;border-top:4px solid #aaa;padding-top:.5em;margin-top:1.5em;"
	property h2 : "margin:0;padding:0;margin:1em 0;border:0;font-size:150%;margin-top:1.5em;border-top:4px solid #e0e0e0;padding-top:.5em;"
	property h3 : "margin:0;padding:0;margin:1em 0;border:0;margin-top:1em;"
	property h4 : "margin:0;padding:0;border:0;"
	property h5 : "margin:0;padding:0;border:0;"
	property h6 : "margin:0;padding:0;border:0;"
	property p : "margin:0;padding:0;margin:1em 0;line-height:1.5em;"
	property ul : "margin:0;padding:0;margin:1em 0 1em 2em;"
	property ol : "margin:0;padding:0;margin:1em 0 1em 2em;"
	property li : "margin:0;padding:0;margin-top:.5em;margin-bottom:.5em;"
	property em : "margin:0;padding:0;font-style: italic;font-weight: inherit;line-height: inherit;margin: 0;padding: 0;border: 0;font-family: inherit;"
	property strong : "margin:0;padding:0;font-style: inherit;font-weight: bold;margin: 0;padding: 0;border: 0;font-size: 100%;line-height: 1;font-family: inherit;"
	property a : "margin:0;padding:0;color:#4183c4;text-decoration:none;"
	property hr : "margin:0;padding:0;border:1px solid #ddd;"
	property blockquote : "margin:0;padding:0;margin:1em 0;border-left:5px solid #ddd;padding-left:.6em;color:#555;"
	property img : "margin:0;padding:0;border:0;max-width:100%;"
	property pre : "margin:0;padding:0;font:12px Monaco,monospace;margin:1em 0;font-size:12px;background-color:#eee;border:1px solid #ddd;padding:5px;line-height:1.5em;color:#444;overflow:auto;-webkit-box-shadow:rgba(0,0,0,0.07) 0 1px 2px inset;-webkit-border-radius:3px;-moz-border-radius:3px;border-radius:3px;"
	property code : "margin:0;padding:0;font:12px Monaco,monospace;font-size:12px;background-color:#f8f8ff;color:#444;padding:0 .2em;border:1px solid #dedede;"
	property table : "margin:0;padding:0;font-size:inherit;font:100%;margin:1em;"
	property thead : "margin:0;padding:0;"
	property tbody : "margin:0;padding:0;"
	property tr : "margin:0;padding:0;"
	property td : "margin:0;padding:0;border-bottom:1px solid #ddd;padding:.2em 1em;"
	
	(* 以下のCSSはちょっと特殊。

		・【divbody】いじらなくてもまず問題ない。主に背景色を引き伸ばすための設定がしてある
		・【h1first】文書の"最初"にh1タグ("# あいうえお"みたいなmarkdown)を使う場合に限り装飾を少しいじるための設定
		・【childul】【childol】いじらなくてもまず問題ないが、上のulやolとバランスが取れないならいじる
		・【childp】blockquoteタグ("> あいうえお"みたいなmarkdown)以下の文書の設定にあたる。たぶんこのままいじらなくてもいい。いじってもfont-sizeぐらい
		・【tth】thタグのcss。事情によりtthにしている。基本的には表に線をいれるときにいじればいい
		・【precode】preタグ("    あいうえお"みたいなmarkdown)以下のcodeタグに対する設定。ここは設定することがよくあるかも

	*)
	-- divbody。evernoteではbodyは排除されるので代わりにdivでラップ
	-- overflowを忘れないように。高さを拡張
	-- heightやwidthを100%で指定すると余計なスクロールができる。これで様子見
	property divbody : body & "position:absolute;top:0;right:0;left:0;bottom:0;padding:10px;overflow:auto;"
	
	-- h1:first-child。最初のh1タグだけCSSを変える場合に使う。全て同じなら "" だけにしとく
	property h1first : h1 & "margin-top:0;padding-top:.25em;border-top:none;"
	
	-- ul > ul, ol > ul
	property childul : ul & "margin-top:0;margin-bottom:0;"
	property childol : ol & "margin-top:0;margin-bottom:0;"
	
	-- blockquote > p
	property childp : p & "margin-bottom:0;font-size: 14px;"
	
	-- table > th
	property tth : "border-bottom:1px solid #bbb;padding:.2em 1em;"
	
	-- pre > code
	property precode : code & "padding:0;font-size:12px;background-color:#eee;border:none;"
end script

script EvernoteAPI
	
	(* ノートブック *)
	
	--ノートブックが存在するかどうか
	on findNotebook(ename)
		tell application "Evernote"
			set bool to false
			if (notebook named ename exists) then set bool to true
			return bool
		end tell
	end findNotebook
	
	--ノートブック新規作成
	on createNotebook(ename)
		tell application "Evernote"
			if (not my findNotebook(ename)) then
				make notebook with properties {name:ename}
				return true
			end if
			return false
		end tell
	end createNotebook
	
	--ノートブック名変更
	on renameNotebook(oname, rename)
		tell application "Evernote"
			if (my findNotebook(oname)) and (not (my findNotebook(rename))) then
				set name of notebook oname to rename
				return true
			end if
			return false
		end tell
	end renameNotebook
	
	--ノートブック削除
	on deleteNotebook(ename)
		tell application "Evernote"
			if (my findNotebook(ename)) then
				delete notebook ename
				return true
			end if
			return false
		end tell
	end deleteNotebook
	
	--指定した文字列のノートブックを取得
	on getNotebook(ename)
		tell application "Evernote"
			if (not my findNotebook(ename)) then return my getDefaultNotebook()
			repeat with elem in my getNotebookList(false)
				if (ename = elem's name as text) then return elem
			end repeat
		end tell
	end getNotebook
	
	--ノートブック名のリスト名を取得
	on getNotebookList(bool)
		tell application "Evernote"
			set booklist to {}
			if (bool) then
				repeat with elem in every notebook
					set booklist's end to elem's name as text
				end repeat
			else
				set booklist to every notebook
			end if
			return booklist
		end tell
	end getNotebookList
	
	--デフォルトノートブック取得
	on getDefaultNotebook()
		tell application "Evernote"
			set defaultname to "（規定のノートブック）"
			repeat with elem in my getNotebookList(false)
				if (default of elem) then
					set defaultname to elem
					return defaultname
				end if
			end repeat
			return defaultname
		end tell
	end getDefaultNotebook
	
	(* タグ *)
	
	--タグが存在するかどうか
	on findTag(name)
		tell application "Evernote"
			set bool to false
			if (tag named name exists) then set bool to true
			return bool
		end tell
	end findTag
	
	--タグ新規作成
	on createTag(name)
		tell application "Evernote"
			set success to {}
			if (class of name = text) then set name to {name}
			repeat with elem in name
				if (not my findTag(elem)) then
					make tag with properties {name:elem}
					set success's end to elem as text
				end if
			end repeat
			return success
		end tell
	end createTag
	
	--タグ名前変更
	on renameTag(oname, rename)
		tell application "Evernote"
			if (my findTag(oname)) and (not my findTag(rename)) then
				set name of tag oname to rename
				return true
			end if
			return false
		end tell
	end renameTag
	
	--タグ削除
	on deleteTag(name)
		tell application "Evernote"
			if (my findTag(name)) then
				delete tag name
				return true
			end if
			return false
		end tell
	end deleteTag
	
	--タグ割り当て
	on assignTag(enote, ltag)
		tell application "Evernote"
			assign ltag to enote
		end tell
	end assignTag
	
	--タグ割り当て解除
	on unnasignTag(enote, ltag)
		tell application "Evernote"
			unassign ltag from enote
		end tell
	end unnasignTag
	
	--タグリストを取得
	on getTagList(bool)
		tell application "Evernote"
			set taglist to {}
			
			if (bool) then
				repeat with elem in every tag
					set taglist's end to my getParentTag(elem, elem's name as text)
				end repeat
			else
				set taglist to every tag
			end if
			
			return taglist
		end tell
	end getTagList
	on getParentTag(ltag, txt)
		tell application "Evernote"
			set parenttag to ltag's parent
			
			if (not parenttag = missing value) then
				my getParentTag(parenttag, (parenttag's name as text) & " > " & txt)
			else
				return txt
			end if
		end tell
	end getParentTag
	
	-- リスト中のタグ名に対するタグをリストで返す
	on getTag(taglist)
		set ltag to {}
		repeat with elemx in taglist
			repeat with elemy in my EvernoteAPI's getTagList(false)
				if (my split(elemx, " > ")'s last item = elemy's name as text) then
					set ltag's end to elemy
				end if
			end repeat
		end repeat
		return ltag
	end getTag
	
	(* ノート *)
	
	on createNote(notebookname, notetitle, ltag, content, way)
		tell application "Evernote"
			if (way = "text") then
				set enote to create note title notetitle with text content notebook notebookname
			else if (way = "html") then
				set enote to create note title notetitle with html content notebook notebookname
			else if (way = "url") then
				set enote to create note title notetitle from url content notebook notebookname
			else if (way = "file") then
				set enote to create note title notetitle from file content notebook notebookname
			else
				return false
			end if
			
			if (class of ltag = note) or (class of ltag = list) and ((count ltag) > 0) then
				my assignTag(enote, ltag)
			end if
			
			return true
		end tell
	end createNote
	
	-- ノートの上書き
	on overwritenote(writenote, htmldata, notebookname, etag, modifi)
		tell application "Evernote"
			set writenote's HTML content to htmldata
			my moveNote(writenote, notebookname)
			set writenote's tags to etag
			set writenote's modification date to modifi
			return true
		end tell
	end overwritenote
	
	-- 指定したノート名のノートを取得してリストで返す
	-- ※完全一致で検出させるためにfind notes txtだけで返さない
	on getNote(txt)
		tell application "Evernote"
			set ret to {}
			set notelist to my getNoteList(txt)
			repeat with elem in notelist
				if (txt = elem's title as text) then set ret's end to elem
			end repeat
			return ret
		end tell
	end getNote
	
	--ノート名前変更
	--ノート削除
	
	--指定した文字列を含んだタイトルを持つノートをリストで返す
	on getNoteList(txt)
		tell application "Evernote"
			return find notes txt
		end tell
	end getNoteList
	
	-- 使わんな
	-- on deleteNote()
	-- end deleteNote
	
	on moveNote(moveNote, tonotebook)
		tell application "Evernote"
			move moveNote to tonotebook
		end tell
	end moveNote
	
end script

-- 文章中から特定の文字と指定した文字を置換
on replace(txt, findstr, substr)
	set temp to AppleScript's text item delimiters
	set AppleScript's text item delimiters to findstr
	set retList to every text item of txt
	set AppleScript's text item delimiters to substr
	set retList to retList as string
	set AppleScript's text item delimiters to temp
	return retList
end replace

-- 文章を区切ってそのリストを返す
on split(txt, delimiter)
	set temp to AppleScript's text item delimiters
	set AppleScript's text item delimiters to delimiter
	set retList to every text item of txt
	set AppleScript's text item delimiters to temp
	return retList
end split

--指定した文字を挟んでリストを結合
on bind(listhtml, bindstr)
	set temp to AppleScript's text item delimiters
	set AppleScript's text item delimiters to bindstr
	set retList to listhtml as text
	set AppleScript's text item delimiters to temp
	return retList
end bind

-- http://www.script-factory.net/XModules/index.html
on value_of(an_object, a_label)
	return (make_with(a_label))'s value_of(an_object)
end value_of
on make_with(a_label)
	return run script "
on value_of(an_object)
return " & a_label & " of an_object
end value
return me"
end make_with

-- mougithubCSS専用のhtmlにcssを割り当て
on subhtml(html)
	-- ul > ul, ol > ul
	repeat with elem in {"ul", "ol"}
		set html to split(html, "<" & elem & ">")
		set len to count html
		
		repeat with i from 2 to len
			if (not html's item (i - 1)'s last word = ">") then
				set html's item i to "<" & elem & " style=\"" & value_of(mougithubCSS, "child" & elem) & "\">" & html's item i
			else
				set html's item i to "<" & elem & ">" & html's item i
			end if
		end repeat
		
		set html to bind(html, "")
	end repeat
	
	-- pre > code
	set html to split(html, "<pre>")
	set len to count html
	repeat with i from 2 to len
		set temp to split(html's item i, "</pre>")
		set temp's item 1 to replace(temp's item 1, "<code>", "<code style=\"" & value_of(mougithubCSS, "precode") & "\">")
		set temp to bind(temp, "</pre>")
		set html's item i to temp
	end repeat
	set html to bind(html, "<pre>")
	
	-- blockquote
	set html to split(html, "<blockquote>")
	set len to count html
	repeat with i from 2 to len
		set temp to split(html's item i, "</blockquote>")
		set temp's item 1 to replace(temp's item 1, "<p>", "<p style=\"" & value_of(mougithubCSS, "childp") & "\">")
		set temp to bind(temp, "</blockquote>")
		set html's item i to temp
	end repeat
	set html to bind(html, "<blockquote>")
	
	-- h1
	set html to split(html, "</h1>")
	if (html's item 1's item 2 = "h" and html's item 1's item 3 = "1") then
		if (html's item 1's item 4 = ">") then
			set html's item 1 to replace(html's item 1 as text, "<h1>", "<h1 style=\"" & value_of(mougithubCSS, "h1first") & "\">")
		else
			set html's item 1 to replace(html's item 1 as text, "<h1", "<h1 style=\"" & value_of(mougithubCSS, "h1first") & "\"")
		end if
	end if
	set html to bind(html, "</h1>")
	
	-- td
	set html to replace(html, "<td" & space, "<td style=\"" & value_of(mougithubCSS, "td") & "\" ")
	-- th
	set html to replace(html, "<th" & space, "<th style=\"" & value_of(mougithubCSS, "tth") & "\" ")
	set html to replace(html, "<th>", "<th style=\"" & value_of(mougithubCSS, "tth") & "\">")
	
	-- Eのみ
	repeat with elem in {"h1", "h2", "h3", "h4", "h5", "h6", "p", "ul", "ol", "li", "em", "strong", "a", "hr", "blockquote", "img", "pre", "code", "table", "thead", "tbody", "tr", "td"}
		set html to replace(html, "<" & elem & ">", "<" & elem & " style=\"" & value_of(mougithubCSS, elem) & "\">")
	end repeat
	
	-- body
	set html to "<div style=\"" & value_of(mougithubCSS, "divbody") & "\">" & return & html & return & "</div>"
	
	return html
end subhtml

-- ソート
on qsort(alist, begin, theend)
	if ((count alist) = 0) then return
	
	set i to 0
	set j to 0
	set pivot to 0
	set temp to 0
	
	script wrap
		property refer : alist
	end script
	
	set pivot to wrap's refer's item (round ((begin + theend) / 2))
	set i to begin
	set j to theend
	
	repeat
		repeat while wrap's refer's item i < pivot
			set i to i + 1
		end repeat
		repeat while wrap's refer's item j > pivot
			set j to j - 1
		end repeat
		if (i ≥ j) then exit repeat
		
		set temp to wrap's refer's item i
		set wrap's refer's item i to alist's item j
		set wrap's refer's item j to temp
		
		set i to i + 1
		set j to j - 1
	end repeat
	
	if (begin < (i - 1)) then
		my qsort(wrap's refer, begin, i - 1)
	end if
	if ((j + 1) < theend) then
		my qsort(wrap's refer, j + 1, theend)
	end if
end qsort

-- GUIスクリプティングが無効なら、有効にすることを勧めるメッセージを出力する
-- http://d.hatena.ne.jp/zariganitosh/20090218/1235018953
on check()
	tell application "System Events"
		if UI elements enabled is false then
			tell application "System Preferences"
				activate
				set current pane to pane "com.apple.preference.universalaccess"
				set msg to "GUIスクリプティングが利用可能になっていません。
\"補助装置にアクセスできるようにする\" にチェックを入れて続けますか？"
				display dialog msg buttons {"キャンセル", "チェックを入れて続ける"} with icon note
			end tell
			set UI elements enabled to true
			delay 1
			tell application "System Preferences" to quit
			delay 1
		end if
	end tell
end check

on maindialog()
	tell application "Mou"
		activate
		set ltag to {}
		repeat with elem in evertag
			set ltag's end to elem's name as text
		end repeat
		
		set ret to display dialog ("投稿先ノートブック : " & evernotebook's name as text) & return & "タグ : " & my bind(ltag, ",") & return & return & "ノートタイトル : " default answer evernotetitle buttons {"中止", "設定", "投稿"} default button 3 with icon 2
		set retbtn to ret's button returned
		set rettxt to ret's text returned as text
		
		if (retbtn = "中止") then
			--中止
			return
		else if (retbtn = "設定") then
			--設定
			my settingdialog()
		else if (retbtn = "投稿") then
			if (rettxt = "") then
				display dialog "ノートタイトルが入力されていません" buttons {"OK"} default button 1
				my maindialog()
			else
				set evernotetitle to rettxt
				my postnote()
			end if
		end if
	end tell
end maindialog

on settingdialog()
	tell application "Mou"
		activate
		
		set ret to display dialog "ノートブックとタグを設定します" buttons {"戻る", "ノートブックの設定", "タグの設定"} default button 1 with icon 2
		set ret to ret's button returned
		
		if (ret = "戻る") then
			my maindialog()
		else if (ret = "ノートブックの設定") then
			my settingdialognote()
		else if (ret = "タグの設定") then
			my settingdialogtag()
		end if
	end tell
end settingdialog

on settingdialognote()
	tell application "Mou"
		activate
		
		set lst to my EvernoteAPI's getNotebookList(true)
		my qsort(lst, 1, count lst)
		set ret to choose from list lst with prompt "投稿先ノートブックを選択してください : " OK button name "決定" cancel button name "戻る"
		if (class of ret = list) then
			set evernotebook to my EvernoteAPI's getNotebook(ret's item 1 as text)
			my maindialog()
		else
			my settingdialog()
		end if
	end tell
end settingdialognote

on settingdialogtag()
	tell application "Mou"
		activate
		
		set lst to my EvernoteAPI's getTagList(true)
		if ((count lst) = 0) then
			set lst to {"タグがありません"}
		else
			my qsort(lst, 1, count lst)
		end if
		
		set ret to choose from list lst with prompt "タグを選択してください
(shiftキーやcmdキーで複数可) :" OK button name "決定" cancel button name "戻る" with multiple selections allowed
		if (class of ret = list) then
			set evertag to EvernoteAPI's getTag(ret)
			my maindialog()
		else
			my settingdialog()
		end if
	end tell
end settingdialogtag

on postnote()
	tell application "System Events"
		tell process "Mou"
			
			-- htmlをコピー
			set temp to the clipboard
			set htmldata to ""
			click menu item "Copy HTML" of menu "Actions" of menu bar item "Actions" of menu bar 1
			delay 1
			set htmldata to the clipboard
			set the clipboard to temp
			set htmldata to my subhtml(htmldata)
			
			--上書き確認
			set rettxt to "新規保存"
			set enotes to my EvernoteAPI's getNote(evernotetitle)
			set len to count enotes
			if (len = 1) then
				if (overwritecheck) then
					set ret to display dialog "Evernoteに同名のノートが存在しますがどうしますか？" buttons {"名前を変更", "上書保存", "新規保存"} default button 2 with icon 2
					set rettxt to ret's button returned as text
				else
					set rettxt to "上書き保存"
				end if
			else if (len > 1) then
				set ret to display dialog "Evernoteに同名のノートが複数存在しますがどうしますか？" buttons {"名前を変更", "新規保存"} default button 2 with icon 2
				set rettxt to ret's button returned as text
			end if
			
			if (rettxt = "新規保存") then
				set res to my EvernoteAPI's createNote(evernotebook, evernotetitle, evertag, htmldata, "html")
			else if (rettxt = "上書保存") then
				set res to my EvernoteAPI's overwritenote(enotes's item 1, htmldata, evernotebook, evertag, current date)
			else if (rettxt = "名前を変更") then
				return my maindialog()
			end if
			
			-- 投稿完了のダイアログ。邪魔なら消しても問題ない
			if (res and finishalert) then
				display dialog "完了" buttons {"OK"} default button 1 with icon 2
			end if
		end tell
	end tell
end postnote

--初期化
on run
	check()
	
	tell application "Mou"
		activate
	end tell
	tell application "System Events"
		tell process "Mou"
			-- テキストエリア
			set src to window 1's splitter group 1's scroll area 1's text area 1's value
			
			-- property初期化
			set winname to my split(window 1's name as text, ".")
			if ((count winname) > 1) then set winname's last item to ""
			set winname to my bind(winname, "")
			if (not filename = winname) then
				set evernotebook to my EvernoteAPI's getDefaultNotebook()
				set evernotetitle to winname
				set filename to winname
				set evertag to {}
			end if
			
			if (not src = "") then
				my maindialog()
			else -- 未入力であればなにもしない
				display dialog "テキストが入力されていません。" buttons {"OK"} default button 1 with icon 2
			end if
		end tell
	end tell
end run