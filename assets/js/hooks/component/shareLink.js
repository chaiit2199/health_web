export default Copy = {
  ShareLink: {
    mounted() {
      let notification_success = document.querySelector(".notification_success");
      const src = window.location.href;
      this.el.addEventListener("click", (e) => {
        navigator.clipboard
          .writeText(src)
          .then(() => {
            notification_success.classList.add("active")

            setTimeout(() => {
              notification_success.classList.remove("active")
            }, 2000);
          });
      });

    }
  },
  SharePost: {
    mounted() {
      this.el.addEventListener("click", () => {
        const urlToShare = encodeURIComponent(window.location.href);
        let ShareUrl = ""
        if (this.el.dataset.flatform == "facebook") {
          ShareUrl = `https://www.facebook.com/sharer/sharer.php?u=${urlToShare}`;
        } else if (this.el.dataset.flatform == "linkedin") {
          ShareUrl = `https://www.linkedin.com/sharing/share-offsite/?url=${urlToShare}`;
        }
        window.open(ShareUrl, '_blank', 'width=600,height=400');
      })
    }
  }
}