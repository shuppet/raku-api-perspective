use API::Perspective;

my $api = API::Perspective.new(:api-key(%*ENV<PERSPECTIVE_API_KEY>));

say $api.suggest-score(:model(MODEL::TOXICITY), :value(0.20), :comment("that wasn't very cash money of you, homie"));

