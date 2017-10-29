// Placeholder manifest file.
// the installer will append this file to the app vendored assets here: vendor/assets/javascripts/spree/frontend/all.js'
(function ($) {
  if('payment' in $) {
    $.payment.cards.unshift(
      {
        type: "elo",
        luhn: true,
        format: /^((((636368)|(438935)|(504175)|(451416)|(636297))\d{0,10})|((5067)|(4576)|(4011))\d{0,12})$/,
        patterns: [
          636368,438935,504175,451416,509048,509067,
          509049,509069,509050,509074,509068,509040,
          509045,509051,509046,509066,509047,509042,
          509052,509043,509064,509040,36297, 5067,
          4576,4011
        ],
        length: [16],
        cvcLength: [3]
      },
      {
        type: "hipercard",
        luhn: false,
        format: /^(606282\d{10}(\d{3})?)|(3841\d{15})$/,
        patterns: [38,60],
        length: [13,16,19],
        cvcLength: [3]
      }
    )
  }
})(jQuery)
