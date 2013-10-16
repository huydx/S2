$ ->
  color_class = ["golden-tainoi", "puerto-rico", "atlantis", "light-coral", "downy", "empress", "turquoise"]

  $(".slide-box").css(opacity: 0).each (i) ->
    num = Math.floor Math.random() * color_class.length

    $(this)
      .addClass(color_class[num])
      .delay(500*i).animate opacity: 1, 1500



