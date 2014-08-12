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

		$.each @subjects, (index, value) =>
			$("section").append(
				$("<div class=\"thread\">"+
					@subjects[index]["title"]+
				"</div>").click  =>
					@clickedThread =
						"title": @subjects[index]["title"]
						"number": @subjects[index]["number"]
			)
		# 偶数行の背景を緑色に
		$(".thread:odd").addClass("odd")
		$(".thread:even").addClass("even")
		# 一番上へスクロール
		$("#top-most").get(0).scrollIntoView(true)