$ ->
  $(".youtube")
    .mouseover ->
      $(this).attr("src", "/assets/youtube-hover.png")
    .mouseout ->
      $(this).attr("src", "/assets/youtube.png")
