# #get-thread->.thread->#get-thread->play->.thread
# の順にいくと自動更新が止まらない問題
# #play押しまくると更新インターバルが増え続ける問題
$ ->
	# スレッド一覧ボタンが押された時
	$("#get-thread").click ->
		# 掲示板の処理系インスタンス
		bbs = new Bbs($("#url").val())
		# 掲示板の表示系インスタンス
		bbsView = new BbsView(bbs)
		# スレッド一覧を描画
		bbsView.printSubject()

		# スレッドが選択された時
		$(".thread").click =>
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

			# 自動更新用タイマー
			resLoadTimer = null
			air.Introspector.Console.log(res)

			# 自動更新ONボタン
			$("#play").click =>
				alert "play"
				# 自動更新ON
				thread.loadOn()
				# 7秒毎に更新
				resLoadTimer = setInterval =>
					res = thread.getRes()
					if res
						threadView.printRes(res)
				, 7000

			# 自動更新OFFボタン
			$("#pause,#get-thread,.thread").click =>
				alert "pause"
				# 自動更新ON
				thread.loadOff()
				# タイマー停止
				clearInterval(resLoadTimer)