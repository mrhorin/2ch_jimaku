# 字幕ウィンドウの初期化
initialize = ->
    jimakuSubject = document.getElementById("jimaku-subject")
    jimakuSubject.addEventListener("mousedown", onMoveJimaku, true)

# 字幕の移動
onMoveJimaku = (event) ->
	window.nativeWindow.startMove()

$ ->
	# スレッド一覧ボタンが押された時
	$("#get-thread").click ->
		# 自動更新ONボタンを無効化
		$("#play").attr('disabled', true)
		# 掲示板の処理系インスタンスを生成
		bbs = new Bbs($("#url").val())
		# 掲示板の表示系インスタンスを生成
		bbsView = new BbsView(bbs)
		# スレッド一覧を描画
		bbsView.printSubject()

		# スレッドが押された時
		$(".thread").click =>
			# 自動更新ONボタンを有効化
			$("#play").attr('disabled', false)
			$("#play").removeAttr('disabled')

			# スレッドの処理系インスタンスの生成
			thread = new Thread(bbsView.clickedThread, bbs.url)
			# スレッドの表示系インスタンスを生成
			threadView = new ThreadView()
			# sectionタグを空に
			threadView.sectionToEmpty()
			# レスを取得
			res = thread.getRes()
			# レスを表示
			threadView.printRes(res)
			# ThreadControllerを生成
			threadController = new ThreadController(thread, threadView)

			# 字幕の表示系インスタンスを生成
			jimaku = new JimakuView(air, "../haml/jimaku.html")
			# 字幕を生成
			jimaku.create()
			jimaku.activate()
			air.Introspector.Console.log(jimaku)
			# doc = jimaku.jimaku.document.getElementById("jimaku-subject")
			# doc.addEventListener 'mousedown',(e)=>
			# 	# window.nativeWindow.startMove()
			# 	alert "okok"
			# , true

			# 自動更新ONボタン
			$("#play").click =>
				if !thread.resLoadFlag
					# 自動更新ON
					thread.resLoadFlag = true
					threadController.resLoadOn()
					$("#play").addClass("on")

			# 自動更新OFFボタン
			$("#pause,#get-thread").click =>
				if thread.resLoadFlag
					# 自動更新OFF
					thread.resLoadFlag = false
					threadController.resLoadOff()
					$("#play").removeClass("on")
