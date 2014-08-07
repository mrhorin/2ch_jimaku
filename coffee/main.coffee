$ ->
	$("#get-thread").click ->
		# 掲示板インスタンス
		bbs = new Bbs($("#url").val())
		bbsView = new BbsView(bbs)
		bbsView.printSubject()

		$(".thread").click ->
			thread = new Thread(bbsView.clickedThread)