class window.BbsView extends BaseView
	# url 掲示板のURL
	# subjects 掲示板のスレッド一覧
	# clickedThread クリックされたスレ情報

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
					alert @clickedThread["title"]
			)
		# 偶数行の背景を緑色に
		$(".thread:odd").css("background-color", "#B1FF8E")