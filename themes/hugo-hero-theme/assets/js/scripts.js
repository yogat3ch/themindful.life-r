var body = document.querySelector('body')
var menuTrigger = document.querySelector('#toggle-main-menu-mobile');
var menuContainer = document.querySelector('#main-menu-mobile');
var header = document.querySelector(".header-absolute")

menuTrigger.onclick = function() {
    menuContainer.classList.toggle('open');
    menuTrigger.classList.toggle('is-active')
    body.classList.toggle('lock-scroll')
}
if (screen.width > 720) {
    menuTrigger.addEventListener("mouseover", mouseOver)
    header.addEventListener("mouseleave", mouseLeave)

    function mouseOver() {
        document.getElementById("main-menu").style.display = "block";
        document.getElementById("main-menu").style.transition = "all .25s ease-in-out 0;"
    }
    function mouseLeave() {
        document.getElementById("main-menu").style.display = "none";
    }   
}