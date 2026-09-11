# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
  $(document)
    .on 'turbolinks:load', ->
      original_text_for_product_price = $('#product_price').prev().text();
      if $('#product_has_size').prop('checked')
        $('#size_products').show();
      $('#product_has_size').change ->
        $('#size_products').toggle();
      $('#product_reduction_tax').change ->
        if $(this).prop('checked')
          $('#product_tax_free_flg').prop('checked', false);
      $('#product_tax_free_flg').change ->
        if $(this).prop('checked')
          $('#product_reduction_tax').prop('checked', false);
      $('#product_coupon_flg').change ->
        if $(this).prop('checked')
          $('#product_price').prev().text("割り引き価格*");
          $('#reduction_tax').hide();
          $('#tax_free_flg').hide();
          $('#has_size').hide();
          $('#size_products').hide();
        else
          $('#product_price').prev().text(original_text_for_product_price);
          $('#reduction_tax').show();
          $('#tax_free_flg').show();
          $('#has_size').show();
          if $('#product_has_size').prop('checked')
            $('#size_products').show();
      $('#sticons').children().click ->
        sticker_id  = $(this).attr('data-sticker')
        ### sticker_idは一意なのでそれを選択済みか否かを識別するための要素(画像)のIDとして使う
        そしてそれが存在したらその要素を削除し、存在しなければそれ自体を新たに作る
        この時、positionをareaのcoordsから動的に作成すると、そのareaの丁度良い位置に重なる事となる ###
        if `$("#" + sticker_id).length`
          $("#" + sticker_id).remove()
        else
          cords  = $(this).attr('coords')
          position = cords.split(',')
          $('map').after('<span id="' + sticker_id + '" style="left:' + position[0] + 'px; top:' + position[1] + 'px">選</span>')
