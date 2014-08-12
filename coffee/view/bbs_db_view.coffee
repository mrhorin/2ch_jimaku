class BbsDbView extends BaseView
	# bbsDb BbsDbインスタンス
	# clickedBbs 選択された掲示板

	constructor: (bbsDb) ->
		@bbsDb = bbsDb

	# 掲示板一覧を描画
	printBbs: =>
		# sectionを空に
		@sectionToEmpty()
		# 掲示板一覧
		bbs = @bbsDb.bbsList
		$.each bbs, (index, value) =>
			# 掲示板タイトルを描画
			$("section").append(
				$("<div class=\"bbs\" id=\""+bbs[index]["id"]+"\">"+
					bbs[index]["name"]+
				"</div>"
				).click  =>
					@clickedBbs =
						"name": bbs[index]["name"]
						"url": bbs[index]["url"]
			)
			# コンテキストメニューリスナー
			id = window.document.getElementById(bbs[index]["id"])
			id.addEventListener("contextmenu", @showContextMenu(bbs[index]["id"]))
		# 偶数行の背景を緑色、奇数行を白色に
		$(".bbs:odd").addClass("odd")
		$(".bbs:even").addClass("even")
		# 一番上へスクロール
		$("#top-most").get(0).scrollIntoView(true)

	# 右クリックで表示されるコンテキストメニューハンドラ
	showContextMenu: (id) =>
		(event) =>
			# コンテキストメニューを生成
		    contextMenu = new air.NativeMenu()
		    # 削除用掲示板ID
		    @deleteId = id
		    event.preventDefault()
		    # 削除コンテキストメニューアイテムを追加
		    deleteBbs = contextMenu.addItem(new air.NativeMenuItem("削除"))
		    deleteBbs.addEventListener(window.air.Event.SELECT, @deleteBbs)
	    	contextMenu.display(window.nativeWindow.stage, event.clientX, event.clientY)
			# window.air.Introspector.Console.log(nMenu)

	deleteBbs: =>
		alert "aaa"
		# bbsDb = new window.BbsDb()
		# bbsDb.deleteBbs(@deleteId)