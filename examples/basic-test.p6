use API::Perspective;

my $api = API::Perspective.new(:api-key(%*ENV<PERSPECTIVE_API_KEY>));

my MODEL @models = TOXICITY, SPAM;

my $result = $api.analyze(:@models, :comment("hello my friend"));

say @models Z=> $result<attributeScores>{@models}.map: *<summaryScore><value>;

