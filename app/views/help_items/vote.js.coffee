$('.vote_button').remove()
$(".scrollable_frame").append("<div id='notice'>Спасибо за ваш участие в жизни проекта</div>")
setTimeout(
  -> $("#notice").slideUp()
  2000
)