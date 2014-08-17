class window.BbsView extends BaseView
	# url コンストラクタで取得した掲示板TOPのURL
	# subjects コンストラクタで取得したスレッド一覧
	# clickedThread クリックされたスレタイとスレ番号

	# 【引数】Bbsインスタンス
	constructor: (bbs, db) ->
		@subjects = bbs.subjects
		@url = bbs.url

	# スレッドタイトル一覧を描画
	printSubject: =>
		# sectionを空に
		@sectionToEmpty()
		section = window.viewerObj.html.window.document.getElementById("section")
		$.each @subjects, (index, value) =>
			$(section).append(
				$("<div class=\"thread\">"+
					@subjects[index]["title"]+
				"</div>").click  =>
					@clickedThread =
						"title": @subjects[index]["title"]
						"number": @subjects[index]["number"]
					window.viewerObj.clickThreadHandler()
			)
		# 一番上へスクロール
		topMost = window.viewerObj.html.window.document.getElementById("top-most")
		# window.air.Introspector.Console.log(topMost)
		$(topMost)[0].scrollIntoView(true)