var body = document.querySelector('body');
var menuTrigger = document.querySelector('#toggle-main-menu-mobile');
var menuContainer = document.querySelector('#main-menu-mobile');
var header = document.querySelector(".header-absolute");

menuTrigger.onclick = function() {
    menuContainer.classList.toggle('open');
    menuTrigger.classList.toggle('is-active')
    body.classList.toggle('lock-scroll')
};
if (screen.width > 992) {
    menuTrigger.addEventListener("mouseover", mouseOver)
    header.addEventListener("mouseleave", mouseLeave)

    function mouseOver() {
        $(".main-menu").addClass("rollOut");
    }
    function mouseLeave() {
        $(".main-menu").removeClass("rollOut")
    }   
};
// Add Read more functionality
var _reveal = id => {
    var el = $(id);
    if (el.hasClass("invisible")) {
        el.toggleClass("invisible")
        el.show(1000)
    } else {
        el.toggleClass("invisible")
        el.hide(1000)
    }
    
};
// Make header sticky
var sticky = new Sticky('.header');
$(window).on("scroll", function(){
    var scrollTop = $(window).scrollTop()
    console.log(scrollTop)
    if (scrollTop > 1 ) {
        $(".header").addClass("is-sticky")
    } else if (scrollTop < 1) {
        $(".header").removeClass("is-sticky")
    }
})




    


// //Get the button:
// scrolltop = document.getElementById("myBtn");

// // When the user scrolls down 20px from the top of the document, show the button
// window.onscroll = function() {scrollFunction()};

// function scrollFunction() {
//   if (document.body.scrollTop > 20 || document.documentElement.scrollTop > 20) {
//     scrolltop.style.display = "block";
//   } else {
//     scrolltop.style.display = "none";
//   }
// }

// // When the user clicks on the button, scroll to the top of the document
// function topFunction() {
//   document.body.scrollTop = 0; // For Safari
//   document.documentElement.scrollTop = 0; // For Chrome, Firefox, IE and Opera
// }