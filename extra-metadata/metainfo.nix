final: prev:
let
  lib = import ./lib.nix { pkgs = prev; };
in
{
  discord = lib.addAppstreamMetainfo prev.discord {
    id = "com.discordapp.Discord";
    launchable = "discord.desktop";
    developer = "Discord Inc.";
    developerId = "com.discord";
    description = [
      ''
        Discord is great for playing games and chilling with friends, or even building a worldwide community.
        Customize your own space to talk, play, and hang out.
      ''
    ];
  };

  slack = lib.addAppstreamMetainfo prev.slack {
    id = "com.slack.Slack";
    launchable = "slack.desktop";
    developer = "Slack Technologies Inc.";
    developerId = "com.slack";
    description = [
      ''
        Slack brings team communication and collaboration into one place so you can get more work done, whether you belong to a large enterprise or a small business.
        Tick off your to-do list and make progress on your projects by bringing the right people, conversations, tools and information you need together.
        Slack is available on any device, so you can find and access your team and your work whether you’re at your desk or on the go.
      ''
      ''
        Scientifically proven (or at least rumoured) to make your working life simpler, more pleasant and more productive.
        We hope you’ll give Slack a try. 
      ''
    ];
  };

  spotify = lib.addAppstreamMetainfo prev.spotify {
    id = "com.spotify.Client";
    launchable = "spotify.desktop";
    developer = "Spotify";
    developerId = "com.spotify";
    description = [
      ''
        Access all of your favorite music, discover new songs, and share music online with your friends - all in one place.
        Create shared playlists or share individual songs with your Facebook friends with just a click of a button.
        Follow your favorite artists or friends to know what they are listening to, and then save the songs to your own playlists.
        Spotify is the best way to have access to millions of songs and all the latest hits.
      ''
    ];
  };
}
