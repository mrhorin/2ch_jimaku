class BbsDbView extends BaseView
	# bbsDb BbsDbインスタンス
	# clickedBbs 選択された掲示板

	constructor: (bbsDb) ->
		@bbsDb = bbsDb

	# 掲示板一覧を描画
	printBbs: ->
		# sectionを空に
		@sectionToEmpty()

		$.each @bbsDb.bbsList, (index, value) =>
			$("section").append(
				$("<div class=\"bbs\">"+
					@bbsDb.bbsList[index]["name"]+
				"</div>").click  =>
					@clickedBbs =
						"name": @bbsDb.bbsList[index]["name"]
						"url": @bbsDb.bbsList[index]["url"]
			)
		# 偶数行の背景を緑色に
		$(".bbs:odd").addClass("odd")
		$(".bbs:even").addClass("even")
		# 一番上へスクロール
		$("#top-most").get(0).scrollIntoView(true)