
export default slide = {
  slide: {
    mounted() {
      var swiper = new Swiper(".post-slide", {
        loop: true,
        spaceBetween: 24,
        pagination: {
          el: ".pagination-banner",
          clickable: true,
        },
        autoplay: {
          delay: 5000,
        },
        breakpoints: {
          0: {
            slidesPerView: 1,
            spaceBetween: 24,
          },
          767: {
            slidesPerView: 3,
            spaceBetween: 24,
          },
        },
        speed: 1000,
        disableOnInteraction: true,
      });

    }
  },
};

