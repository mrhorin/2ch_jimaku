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

		# スレッドが選択された時
		$(".thread").click =>
			# 自動更新ONボタンを有効化
			$("#play").attr('disabled', false)
			$("#play").removeAttr('disabled')
			# スレッドインスタンスの生成
			thread = new Thread(bbsView.clickedThread, bbs.url)
			# スレッドビューインスタンスを生成
			threadView = new ThreadView()
			# sectionタグを空に
			threadView.sectionToEmpty()
			# レスを取得
			res = thread.getRes()
			# レスを表示
			threadView.printRes(res)
			# ThreadControllerを生成
			threadController = new ThreadController(thread, threadView)

			air.Introspector.Console.log(res)

			# 自動更新ONボタン
			$("#play").click =>
				if !thread.resLoadFlag
					# 自動更新ON
					thread.resLoadFlag = true
					threadController.resLoadOn()

			# 自動更新OFFボタン
			$("#pause,#get-thread").click =>
				if thread.resLoadFlag
					# 自動更新OFF
					thread.resLoadFlag = false
					threadController.resLoadOff()