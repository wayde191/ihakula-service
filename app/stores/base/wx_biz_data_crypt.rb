# encoding: utf-8
require 'openssl'
require 'base64'
require 'json'


class WXBizDataCrypt
  attr_accessor :app_id, :session_key

  def initialize(app_id, session_key)
    @app_id = app_id
    @session_key = session_key
  end

  def decrypt(encrypted_data, iv)
    session_key = Base64.decode64(@session_key)
    encrypted_data= Base64.decode64(encrypted_data)
    iv = Base64.decode64(iv)

    cipher = OpenSSL::Cipher::AES128.new(:CBC)
    cipher.decrypt
    cipher.key = session_key
    cipher.iv = iv
    cipher.padding = 0

    decrypted_plain_text = cipher.update(encrypted_data) + cipher.final

    File.open('/tmp/000' + session_key + '.json', 'a+') { |file| file.write(decrypted_plain_text) }

    decrypted_plain_text = decrypted_plain_text.strip.gsub(/[\u0000-\u001F\u2028\u2029]/, '')
    last_letter = decrypted_plain_text[decrypted_plain_text.length - 1]
    if last_letter != '}'
      bracket_index = (0 ... decrypted_plain_text.length).find_all { |i| decrypted_plain_text[i,1] == '}' }
      last_bracket_index = bracket_index[bracket_index.length - 1]
      decrypted_plain_text = decrypted_plain_text[0, last_bracket_index + 1]
    end

    decrypted = JSON.parse(decrypted_plain_text)
    raise('Invalid Buffer') if decrypted['watermark']['appid'] != @app_id

    decrypted
  end
end
