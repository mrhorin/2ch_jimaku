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
		$(".thread").click ->
			# スレッドインスタンスの作成
			thread = new Thread(bbsView.clickedThread, bbs.url)
			# スレッドを取得
			thread.getRes()
			threadView = new ThreadView(thread)
			threadView.printRes()
			# air.Introspector.Console.log(thread.res);
