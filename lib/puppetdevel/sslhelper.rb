module PuppetDevel
  module SSLHelper
    def self.disable_verify_peer
      @prev_setting = OpenSSL::SSL.send(:remove_const, :VERIFY_PEER)
      OpenSSL::SSL.const_set(:VERIFY_PEER, OpenSSL::SSL::VERIFY_NONE)
    end

    def self.restore_openssl_settings
      OpenSSL::SSL.send(:remove_const, :VERIFY_PEER)
      OpenSSL::SSL.const_set(:VERIFY_PEER, @prev_setting)
    end
  end
end
