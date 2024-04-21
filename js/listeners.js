window.onload = function(event) {
      cont = document.getElementsByClassname("uk-card")[0];
      //if (screen.width < 850) {
      if (navigator.userAgentData.mobile) {
        cont.style.width = '100%';
        cont.style.marginLeft = '0px';
        cont.style.marginRight = '0px';
        cont.style.fontSize = '42px';
      } else {
        cont.style.width = '75%';
        cont.style.marginLeft = 'auto';
        cont.style.marginRight = 'auto';
        cont.style.fontSize = '16px';
      }
    };