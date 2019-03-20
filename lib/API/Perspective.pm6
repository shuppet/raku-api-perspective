unit class API::Perspective;

use Cro::HTTP::Client;

enum MODEL is export (
        <TOXICITY SEVERE_TOXICITY TOXICITY_FAST IDENTITY_ATTACK
        INSULT PROFANITY SEXUALLY_EXPLICIT THREAT FLIRTATION
        ATTACK_ON_AUTHOR ATTACK_ON_COMMENTER INCOHERENT INFLAMMATORY
        LIKELY_TO_REJECT OBSCENE SPAM UNSUBSTANTIAL>
);

has $.api-key;
has $.api-base = 'https://commentanalyzer.googleapis.com/';
has $.api-version = 'v1alpha1';
has $.language = 'en';

has $.http-client = Cro::HTTP::Client.new(content-type => 'application/json', http => '1.1');

method analyze(:$comment, MODEL :@models) {
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
