// Placeholder manifest file.
// the installer will append this file to the app vendored assets here: vendor/assets/javascripts/spree/frontend/all.js'
(function ($) {
  if('payment' in $) {
    $.payment.cards.unshift(
      {
        type: "elo",
        luhn: true,
        format: /(\d{1,4})/g,
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
        format: /(\d{1,4})/g,
        patterns: [38,60],
        length: [13,16,19],
        cvcLength: [3]
      }
    )
  }
})(jQuery)
