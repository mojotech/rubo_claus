# From https://github.com/jnunemaker/httparty/blob/master/lib/httparty/cookie_hash.rb

class HTTParty::CookieHash < Hash #:nodoc:
  include RuboClaus
  
  CLIENT_COOKIES = %w(path expires domain path secure httponly)

  define_function :add_cookies do
    clauses(
      clause([String], proc { |s| ... }),
      clause([Hash], proc { |h| merge!(h) }),
      catch_all(proc { raise "add_cookies only takes a Hash or a String" })
    )
  end
  
  ##  Ruby originally implemented in jnunemaker/httparty
  #
  #  def add_cookies(value)
  #    case value
  #    when Hash
  #      merge!(value)
  #    when String
  #      ...
  #    else
  #      raise "add_cookies only takes a Hash or a String"
  #    end
  #  end

  def to_cookie_string
    reject { |k, v| CLIENT_COOKIES.include?(k.to_s.downcase) }.collect { |k, v| "#{k}=#{v}" }.join("; ")
  end
end
