unit class API::Perspective;

use Cro::HTTP::Client;

=begin pod
=head1 NAME

API::Perspective - Interface to Google's Perspective API

=head1 DESCRIPTION
...
=head1 SYNOPSIS

    use API::Perspective;

    my $api = API::Perspective.new(:api-key(%*ENV<PERSPECTIVE_API_KEY>));

    my MODEL @models = TOXICITY, SPAM;

    my $result = $api.analyze(:@models, :comment("hello my friend"));

    say @models Z=> $result<attributeScores>{@models}.map: *<summaryScore><value>;

=head1 EXPORTED SYMBOLS

=head2 MODEL

C<MODEL> is an enumeration of all known analysis models on the Perspective API.

=end pod

enum MODEL is export (
        <TOXICITY SEVERE_TOXICITY TOXICITY_FAST IDENTITY_ATTACK
        INSULT PROFANITY SEXUALLY_EXPLICIT THREAT FLIRTATION
        ATTACK_ON_AUTHOR ATTACK_ON_COMMENTER INCOHERENT INFLAMMATORY
        LIKELY_TO_REJECT OBSCENE SPAM UNSUBSTANTIAL>
);

=begin pod
=head1 PROPERTIES

=end pod
has $.api-key;
has $.api-base = 'https://commentanalyzer.googleapis.com/';
has $.api-version = 'v1alpha1';
has $.language = 'en';

has $.http-client = Cro::HTTP::Client.new(content-type => 'application/json', http => '1.1');

=begin pod
=head1 METHODS
=head2 analyze
B<Named Arguments>: C<$comment>, C<MODEL @models>

Submit a C<$comment> to the API for analysis, also specify the C<MODEL @models> you would like to use
=end pod
method analyze(:$comment, :@models where {all(|$_) ~~ MODEL}) {
    my $analysis = await $!http-client.post(
        $.api-base ~ $.api-version ~ "/comments:analyze?key={$.api-key}",
        body => {
            comment => {
                text => $comment
            },
            languages => [$.language],
            requestedAttributes => %( @models.map: * => {} )
        }
    );

    return await $analysis.body;
}

=begin pod
=head2 suggest-score
B<Named Arguments>: C<$comment>, C<MODEL $model>, C<$value>

Suggests a score C<$value> for C<$comment> using the model C<$model>. See L</MODEL>
=end pod
method suggest-score(:$comment, MODEL :$model, :$value) {
    my $suggestion = await $!http-client.post(
        $.api-base ~ $.api-version ~ "/comments:suggestscore?key={$.api-key}",
        body => {
            comment => {
                text => $comment
            },
            languages => [$.language],
            attributeScores => {
                $model => {
                    summaryScore => {
                        value => $value
                    },
                },
            },
            clientToken => "API::Perspective-" ~ (10000..99999).rand.Int.Str;
        },
    );

    return await $suggestion.body;
}
