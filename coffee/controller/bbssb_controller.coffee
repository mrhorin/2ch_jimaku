class window.BbsDbController
	# bbsDb
	# bbsDbView BbsDbViewインスタンスはBbsDbインスタンスを保持

	constructor: (bbsDb, bbsDbView) ->
		@bbsDb = bbsDb
		@bbsDbView = bbsDbView
		# 掲示板一覧を取得
		@bbsDb.selectBbs()
		# 掲示板一覧を描画
		@bbsDbView.printBbs(@bbsDb.bbsList)
		# 掲示板一覧にイベントリスナーをつける
		@addBbsListListener(@bbsDb.bbsList)

	# 掲示板一覧にイベントリスナーをつける
	addBbsListListener: (bbsList) =>
		$.each bbsList, (index, value) =>
			# window.air.Introspector.Console.log(bbsList)
			id = window.document.getElementById(bbsList[index]["id"])
			id.addEventListener "contextmenu", @showContextMenu(bbsList[index]["id"])
			id.addEventListener "click", @clickBbsHandler(bbsList[index]["url"])

	# 右クリックで表示されるコンテキストメニューハンドラ
	showContextMenu: (id) =>
		(event) =>
			# コンテキストメニューを生成
		    contextMenu = new air.NativeMenu()
		    event.preventDefault()
		    # 削除コンテキストメニューアイテムを追加
		    deleteBbs = contextMenu.addItem(new air.NativeMenuItem("削除"))
		    deleteBbs.addEventListener(window.air.Event.SELECT, @deleteBbsHandler(id))
	    	contextMenu.display(window.nativeWindow.stage, event.clientX, event.clientY)

	# 掲示板削除が選択された時のハンドラ
	deleteBbsHandler: (id) =>
		(event) =>
			# 掲示板を削除
			@bbsDb.deleteBbs(id)
			# sectionを空に
			@bbsDbView.sectionToEmpty()
			# 掲示板一覧を取得
			@bbsDb.selectBbs()
			# 掲示板一覧を描画
			@bbsDbView.printBbs(@bbsDb.bbsList)
			# 掲示板一覧にイベントリスナーをつける
			@addBbsListListener(@bbsDb.bbsList)

	# 掲示板クリックハンドラ
	clickBbsHandler: (url) =>
		(event) =>
			$("#url").val(url)
			# スレッド一覧ボタンを有効化
			$("#get-thread").attr('disabled', false)
			$("#get-thread").trigger("click")