Geocoder.configure(
  # geocoding options
  # :http_headers => { "User-Agent" => "luiz.chaves@ifpb.edu.br" },
  # :timeout      => 5,           # geocoding service timeout (secs)
  # :lookup       => :nominatim,     # name of geocoding service (symbol) :bing, :nominatim, :google, yahoo???
  # :language     => :en,         # ISO-639 language code
  # :use_https    => false,       # use HTTPS for lookup requests? (if supported)
  # :http_proxy   => nil,         # HTTP proxy server (user:pass@host:port)
  # :https_proxy  => nil,         # HTTPS proxy server (user:pass@host:port)
  # :api_key      => nil,         # API key for geocoding service
  # :api_key      => "AuSUjfLMUib7DP_u3AV5V8S17haW-IbGJ2f6KQACIQ6VxaIXGSTec_-MPEMq0Whz", # bing 
  # :cache        => nil,         # cache object (must respond to #[], #[]=, and #keys)
  # :cache_prefix => "geocoder:", # prefix (string) to use for all cache keys

  # exceptions that should not be rescued by default
  # (if you want to implement custom error handling);
  # supports SocketError and TimeoutError
  # :always_raise => [],

  # calculation options
  # :units     => :mi,       # :km for kilometers or :mi for miles
  # :distances => :linear    # :spherical or :linear
)
