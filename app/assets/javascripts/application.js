// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require jquery-ui
//= require jquery.timepicker.js
//= require bootstrap-sprockets
//= require turbolinks
//= require_tree .

$.datepicker.setDefaults({
  monthNames: [ "1月","2月","3月","4月","5月","6月",
  "7月","8月","9月","10月","11月","12月" ],
  dayNamesMin: [ "日","月","火","水","木","金","土" ],
  firstDay: 1,
  // dateFormat: "yy月mm日dd",
  showMonthAfterYear: true,
  yearSuffix: "年"
});

$(document).on('turbolinks:load', function() {
  if($('#company_reserve_form').length > 0) {
    $('.timepicker').timepicker({
      'timeFormat': 'G:i',
      'step': '60',
      'minTime': '8:00am',
      'maxTime': '11:00pm',
      'showDuration': false,
      'scrollDefault': 'now'
    });
    $( ".datepicker" ).datepicker({ dateFormat: 'yy-mm-dd' });

    change_form_state($('#company_reserve_enable_flg_1').is(':checked') ? 1 : 2)
    $('.company_reserve').on('change', function (e) {
      const kind = $(this).val()
      // $(".reserve_" + (kind == 2 ? 'a' : 'b') + " input").val('')
      change_form_state(kind)
    })
  }

  function change_form_state (kind) {
    $('.reserve_a input').prop('disabled', kind == 2)
    $('.reserve_b input').prop('disabled', kind == 1)
  }
})
