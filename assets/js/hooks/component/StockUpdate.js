
export default StockUpdate = {
  StockUpdate: {
    updated() {
      console.log(this.el);
      this.el.classList.add('highlight');
      console.log("------------------");
      setTimeout(() => {
        this.el.classList.remove('highlight');
      }, "1000");
      
    }
  }
};

