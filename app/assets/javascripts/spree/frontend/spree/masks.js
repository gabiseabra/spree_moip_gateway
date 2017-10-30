$(function () {
  masks = {
    cpf: {
      mask: '999.999.999-99',
      placeholder: "000.000.000-00"
    },
    cnpj: {
      mask: '99.999.999/9999-99',
      placeholder: "00.000.000/0000-00"
    }
  }
  $.extend($.inputmask.defaults.aliases, masks)

  function phoneMask() {
    value = this.value.replace(/[^\d]/g, "");
    mask = ""
    if(value.length == 11) {
      mask = "(99) 99999-9999";
    } else {
      mask = "(99) 9999-9999[9]";
    }
    $(this).inputmask({ mask: mask, greedy: false });
  }

  function taxDocumentMask(e) {
    input = $(this).find("input").eq(0)
    switch(e.target.value) {
      case "cpf": input.inputmask("cpf"); break;
      case "cnpj": input.inputmask("cnpj"); break;
    }
  }

  $(".tax-document").each(function() {
    $(this).find("select").eq(0)
      .change(taxDocumentMask.bind(this))
      .trigger("change")
  })

  $(".cpf, .cnpj").each(function() {
    $this = $(this)
    type = $this.is(".cpf") ? "cpf" : "cnpj"
    if($this.is("input")) $this.inputmask(type)
    else $this.text($.inputmask.format($this.text().trim(), masks[type]))
  })
  $("input.date").inputmask("dd/mm/yyyy")
  $("input[type=tel]")
    .on("input, keyup", phoneMask)
    .trigger("input")
})
