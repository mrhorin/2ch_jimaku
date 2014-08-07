class window.BbsView extends BaseView
	# url 掲示板TOPのURL
	# subjects スレッド一覧
	# clickedThread クリックされたスレタイとスレ番号

	# 【引数】Bbsインスタンス
	constructor: (bbs) ->
		@subjects = bbs.subjects
		@url = bbs.url

	# スレッドタイトル一覧を描画
	printSubject: =>
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
		$(".thread:odd").css("background-color", "#B1FF8E")