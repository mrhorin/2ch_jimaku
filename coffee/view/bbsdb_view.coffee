class BbsDbView extends BaseView
	# clickedBbs 選択された掲示板
	# deleteId 削除する掲示板ID

	# constructor: (bbsDb) ->
	# 	@bbsDb = bbsDb

	# 掲示板一覧を描画
	printBbs: (bbsList) =>
		# sectionを空に
		@sectionToEmpty()
		$.each bbsList, (index, value) =>
			# 掲示板タイトルを描画
			$("section").append(
				$("<div class=\"bbs\" id=\""+bbsList[index]["id"]+"\">"+
					bbsList[index]["name"]+
				"</div>"
				).click  =>
					@clickedBbs =
						"name": bbsList[index]["name"]
						"url": bbsList[index]["url"]
			)
			# コンテキストメニューリスナー
			# id = window.document.getElementById(bbsList[index]["id"])
			# id.addEventListener("contextmenu", @contextHandler(bbsList[index]["id"]))
		# 偶数行の背景を緑色、奇数行を白色に
		$(".bbs:odd").addClass("odd")
		$(".bbs:even").addClass("even")
		# 一番上へスクロール
		$("#top-most").get(0).scrollIntoView(true)