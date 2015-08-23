require 'open-uri'
require 'nokogiri'
require 'httparty'

class Phlox::Drchrono::Login < Phlox::Drchrono::Base

  include HTTParty

  class << self

    def get_access_token
      return "#{@token_type} #{@access_token}" if @access_token.present? && @expires_at > Time.now
      if @access_token.present?
        url = "#{Phlox.drchrono_site}/o/token/?refresh_token=#{@refresh_token}&grant_type=refresh_token&client_id=#{Phlox.drchrono_client_id}&client_secret=#{Phlox.drchrono_client_secret}"
      else
        auth_code = authorize(Phlox.drchrono_system_user,Phlox.drchrono_system_password)
        url = "#{Phlox.drchrono_site}/o/token/?code=#{auth_code}&grant_type=authorization_code&redirect_uri=#{Phlox.drchrono_redirect_uri}&client_id=#{Phlox.drchrono_client_id}&client_secret=#{Phlox.drchrono_client_secret}"
      end
      json = JSON.parse(post(url, :headers => { 'Content-Type' => 'application/json' }).response.body)
      @token_type = json["token_type"]
      @access_token = json["access_token"]
      @refresh_token = json["refresh_token"]
      @expires_at = Time.now + json["expires_in"].to_i
      return "#{@token_type} #{@access_token}"
    end

    private

    def authorize(username, password)
      login_url, form_fields = *get_login_form_fields("#{Phlox.drchrono_site}/o/authorize/?redirect_uri=#{Phlox.drchrono_redirect_uri}&response_type=code&client_id=#{Phlox.drchrono_client_id}")

      form_fields['username'] = username
      form_fields['password'] = password

      authorize_url, form_fields = do_login(login_url, form_fields)
      code = do_authorize(authorize_url, form_fields)
      code
    end

    def do_authorize(url, fields)
      return $1 if auth_code = url =~ /\?code=(\w+)$/
      fields['allow'] = 'Authorize'
      @http_response = post(url, body: fields, headers: headers.merge('Referer' => url), no_follow: true).response
    rescue HTTParty::RedirectionTooDeep => e
      @http_response = e.response
      location = @http_response.header['location']
      location =~ /\?code=(\w+)$/
      $1
    end

    def do_login(url, fields)
      @http_response = post(post_url(url), body: fields, headers: headers.merge('Referer' => url), no_follow: true).response
    rescue HTTParty::RedirectionTooDeep => e
      @http_response = e.response
      do_after_login(@http_response.header['location'])
    end

    def do_after_login(url)
      @http_response = get(url, headers: headers.merge('Referer' => url), no_follow: true).response
      doc = Nokogiri::HTML(@http_response.body)
      form = doc.css('form').select{|form| form.css('input').map{|elem| elem.attr('name')}.include?("redirect_uri")}.first
      if form.present?
        [url, extract_form_fields_from_form(form)]
      else
        [url, {'allow' => 'Authorize'}]
      end
    rescue HTTParty::RedirectionTooDeep => e
      @http_response = e.response
      do_after_login(@http_response.header['location'])
    end

    def get_login_form_fields(url)
      @http_response = get(url, headers: headers.merge('Referer' => url), no_follow: true).response
      doc = Nokogiri::HTML(@http_response.body)
      form = doc.css('form').first
      [url, extract_form_fields_from_form(form)]
    rescue HTTParty::RedirectionTooDeep => e
      @http_response = e.response
      get_login_form_fields(@http_response.header['location'])
    end

    def extract_form_fields_from_form(form)
      hash = {}
      form.css('input').each { |elem| hash[elem.attr('name')] = elem.attr('value') }
      hash
    end

    def headers
      {
        "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1309.0 Safari/537.17",
        "Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
        "Connection" => "keep-alive",
        "Cookie" => construct_request_cookie
      }
    end

    def construct_request_cookie
      if cookies.length > 1
        cookies.join('; ')
      else
        ''
      end
    end

    def cookies
      @_authorization_http_cookie ||= {}
      if @http_response != nil
        str = @http_response.header['set-cookie']
        if (str != nil) && (str.strip != '')
          strs = str.gsub(/(expires=\w{3}[\d|\w|\ |\-\,]+\d{2}:\d{2}:\d{2}\ \w+;)/i, '').split(',')
          strs = strs.map(&:strip).map { |s| s =~ /([\_\w\d]+)=([\d\w]+)\;/i; [$1, $2] }.map do |i|
            @_authorization_http_cookie[i[0]] = i[1]
          end
        end
      end
      @_authorization_http_cookie.map { |k,v| "#{k}=#{v}" }
    end

    def post_url(url)
      uri = URI.parse(url)
      "#{uri.scheme}://#{uri.host}#{uri.path}"
    end
  end
end
