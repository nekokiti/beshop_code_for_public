#concernにmoduleとして置けば良い様な気がするので時間が有る時検討
class LineClient
  require 'json'
  require 'cgi'
  require 'logger'
  END_POINT = "https://api.line.me"
  REPLY_URL = '/v2/bot/message/reply'
  PUSH_URL = '/v2/bot/message/push'

  def initialize(channel_access_token, proxy = nil)
    @channel_access_token = channel_access_token
    @proxy = proxy
  end

  def reply(replyToken, messages)# {{{
    return messages if Rails.env.test?

    body = {
      "replyToken" => replyToken,
      "messages" => messages
    }
    post_json_for_message_api(body, REPLY_URL)
  end# }}}

  def push(user_id, messages)# {{{
    return messages if Rails.env.test?

    body = {
      "to" => user_id,
      "messages" => messages
    }
    post_json_for_message_api(body, PUSH_URL)
  end# }}}

  def reply_stump(replyToken)# {{{
      messages = [
      {
          "type": "imagemap",
          "baseUrl": "https://kuroidog.sakura.ne.jp/images/talk_search_test/menu",
          "altText": "this is an imagemap",
          "baseSize": {
              "height": 1040,
              "width": 1040
          },
          "actions": [
              {
                  "type": "message",
                  "text": "order:packageId=2000017&stickerId=693279",
                  "area": {
                      "x": 0,
                      "y": 0,
                      "width": 520,
                      "height": 1040
                  }
              },
              {
                  "type": "message",
                  "text": "order:packageId=2000017&stickerId=693280",
                  "area": {
                      "x": 520,
                      "y": 0,
                      "width": 520,
                      "height": 1040
                  }
              }
          ]
       }
    ]
    body = {
      "replyToken" => replyToken ,
      "messages" => messages
    }
    post('/v2/bot/message/reply', body.to_json)
  end# }}}

  def template_message(replyToken, gotten_products, tag)# {{{
    #image = product.image_path
    #name = product.name
    #uri = product.url
    #text = product.description
    messages = Array.new
    gotten_products.each do |product|
      #product_name = CGI.escape(product.name)
      #paypal_url = 'https://talk-search-development.herokuapp.com/payments/new?item=' + product_name + '&price=' + gotten_product.product.price.to_s
      #puts paypal_url
      item = {
      "type": "template",
      "altText": "this is a buttons template",
      "template": {
          "type": "buttons",
          "thumbnailImageUrl": product.image_path_url,
          "title": product.name,
          "text": product.description,
          "actions": [
              {
                "type": "uri",
                "label": "Show Web Site",
                "uri": product.url
              },
              {
                "type": "postback",
                "label": "AddCart",
                "data": "action=" + WebhookUtility::ADD_CART + "&product_id=" + product.id.to_s
              },
              {
                "type": "postback",
                "label": "Other",
                "data": "action=" + WebhookUtility::TAGPRODUCTS + "&product_id=" + gotten_products.last.id.to_s + "&tag=" + tag
              }
          ]
        }
      }
      messages.push(item)
    end
    #Rails.logger.debug("#{messages.inspect}")

    body = {
      "replyToken" => replyToken ,
      "messages" => messages
    }
    post('/v2/bot/message/reply', body.to_json)
  end# }}}

  def imagemap_message(replyToken, url)# {{{
      messages = [
      {
          "type": "imagemap",
          "baseUrl": "https://kuroidog.sakura.ne.jp/images/talk_search_test/cashier",
          "altText": "this is an imagemap",
          "baseSize": {
              "height": 1040,
              "width": 1040
          },
          "video": {
            "originalContentUrl": "https://be-shop-test.s3.amazonaws.com/uploads/product/movie_path/1/SampleVideo_360x240_1mb.mp4",
            "previewImageUrl": "https://be-shop-test.s3.amazonaws.com/uploads/product/movie_path/1/thumb_SampleVideo_360x240_1mb.jpg",
            "area": {
              "x": 0,
              "y": 0,
              "width": 1040,
              "height": 585
            },
            "externalLink": {
              "linkUri": "https://example.com/see_more.html",
              "label": "See More"
            }
        },
          "actions": [
              {
                  "type": "uri",
                  "linkUri": url,
                  "area": {
                      "x": 0,
                      "y": 586,
                      "width": 1040,
                      "height": 454
                  }
              }
          ]
       }
    ]
    body = {
      "replyToken" => replyToken,
      "messages" => messages
    }
    post_json_for_message_api(body, REPLY_URL)

  end# }}}

    def get_user_profile(user_id)# {{{
      api_helper = ApiHelper.new(@proxy, END_POINT)
      api_helper.request_uri = "/v2/bot/profile/#{user_id}"
      api_helper.headers = {
        "Authorization"=> "Bearer #{@channel_access_token}"
      }
      res = api_helper.get
      return res
    end# }}}

  private

=begin
    def post(path, data)# {{{
      client = Faraday.new(:url => END_POINT) do |conn|
        conn.request :json
        conn.response :json, :content_type => /\bjson$/
        conn.adapter Faraday.default_adapter
        conn.proxy @proxy
      end
  
      res = client.post do |request|
        request.url path
        request.headers = {
          "Content-type"=> 'application/json',
          "Authorization"=> "Bearer #{@channel_access_token}"
        }
        request.body = data
      end
      res
    end# }}}
=end

    def post_json_for_message_api(body, url)# {{{
      if Rails.env == 'production' || Rails.env == 'development'
        api_helper = ApiHelper.new(@proxy, END_POINT)
        api_helper.request_uri = url
        api_helper.headers = {
          "Content-type"=> 'application/json',
          "Authorization"=> "Bearer #{@channel_access_token}"
        }
        api_helper.params = body.to_json
        res = api_helper.post
        return res
      else 
        return body
      end
    end# }}}

end
