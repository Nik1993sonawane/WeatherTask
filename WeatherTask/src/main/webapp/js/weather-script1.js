

      document.querySelectorAll(".text3 img, .text4 img").forEach((icon) => {
	    icon.addEventListener("click", () => {
	    icon.previousElementSibling.focus();
	  });
	});