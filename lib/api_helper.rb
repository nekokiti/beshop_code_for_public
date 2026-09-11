class ApiHelper

  attr_accessor :request_uri
  attr_accessor :params
  attr_accessor :headers

  def initialize(proxy = nil, end_point)
    @client = Faraday.new(url: end_point, proxy: proxy) do |conn|
      conn.request :json
      conn.response :json, :content_type => /\bjson$/
      conn.adapter Faraday.default_adapter
      #conn.proxy proxy
    end
  end

  def get
    response = @client.get do |req|
      req.url @request_uri, @params
      req.headers = @headers unless @headers.nil?
    end
    return response
  end

  def post
    response = @client.post do |req|
      req.url @request_uri
      req.headers = @headers
      req.body = @params
    end
    return response
  end

  # for test
  def line_confirm_response_mock
    hash = {
      body: {
        "returnCode"=>"0000",
        "returnMessage"=>"Success.",
        "info"=>{
          "transactionId"=>"test_txn_id",
          "orderId"=>"56e603c9-5ea9-471c-8304-7e0f63aa659e",
          "payInfo"=>[
            {"method"=>"BALANCE", "amount"=>900},
            {"method"=>"DISCOUNT", "amount"=>100}
          ]
        }
      }
    }
    Struct.new(*(hash.keys)).new(*(hash.values))
  end
end
