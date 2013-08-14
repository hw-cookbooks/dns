module CookbookDNS
  class << self
    def fog(credentials={})
      require 'fog'
      @fogs ||= Mash.new
      unless(@fogs[credentials[:provider]])
        @fogs[credentials[:provider]] = Fog::DNS.new(credentials)
      end
      @fogs[credentials[:provider]]
    end
  end
end
