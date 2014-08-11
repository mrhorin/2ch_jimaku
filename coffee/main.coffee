$ ->
	# スレッド一覧ボタン
	$("#get-thread").click ->
		# 自動更新ONボタンを無効化
		$("#play").attr('disabled', true)
		# 掲示板の処理系インスタンスを生成
		bbs = new Bbs($("#url").val())
		# 掲示板の表示系インスタンスを生成
		bbsView = new BbsView(bbs)
		# スレッド一覧を描画
		bbsView.printSubject()
		# air.Introspector.Console.log(window.nativeWindow)

		# スレッドが押された時
		$(".thread").click =>
			$("#pause").addClass("on")
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

			# 字幕の表示系インスタンスを生成
			jimakuView = new ThreadJimakuView(air, "../haml/jimaku.html")
			# 字幕を生成
			jimakuView.create()
			jimakuView.activate()

			# ThreadControllerを生成
			threadController = new ThreadController(thread, threadView, jimakuView)

			bbsDb = new Db(air)
			bbsDb.connect()
			bbsDb.create()
			# bbsDb.insertBbs("今からpeercastでゲーム実況配信", "http://jbbs.shitaraba.net/game/33090/")
			bbsDb.deleteBbs(4)
			bbsDb.selectBbs()

			# 自動更新ONボタン
			$("#play").click =>
				if !thread.resLoadFlag
					# 自動更新ON
					thread.resLoadFlag = true
					threadController.resLoadOn()
					$("#play").addClass("on")
					$("#pause").removeClass("on")

			# 自動更新OFFボタン
			$("#pause").click =>
				if thread.resLoadFlag
					# 自動更新OFF
					thread.resLoadFlag = false
					threadController.resLoadOff()
					$("#play").removeClass("on")
					$("#pause").addClass("on")

			# スレッド一覧ボタン
			$("#get-thread").click =>
				threadController.jimakuView.close()
				threadController.jimakuClockOff()
				if thread.resLoadFlag
					# 自動更新OFF
					thread.resLoadFlag = false
					threadController.resLoadOff()
					$("#play").removeClass("on")
					$("#pause").addClass("on")
				$("#air").removeClass("on")

			# Airボタン
			$("#air").click =>
				threadController.switchClassAir()
				if threadController.airFlag
					$("#air").addClass("on")
				else
					$("#air").removeClass("on")