#CarrierWave.configure do |config|
#  config.ftp_host = "clients.chimpchamp.com"
#  config.ftp_port = 21
#  config.ftp_user = "clients"
#  config.ftp_passwd = "U)Jxs;T0fMoZ_$bz$d"
#  config.ftp_folder = "/public_html/cross-channel"
#  config.ftp_url = "http://clients.chimpchamp.com/cross-channel"
#end


CarrierWave.configure do |config|
  config.fog_credentials = {
      provider: "AWS",
      aws_access_key_id: "AKIAIHPYSUU5NHZJDAQA",
      aws_secret_access_key: "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"
  }
  config.fog_directory = "MyTesting"
end