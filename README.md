# midjourney_app

A new Flutter project.

## ADDING YOUR OWN MIDJOURNEY SERVER

To create your own Midjourney server, refer to this link https://www.youtube.com/watch?v=mcOF8ihGI1A

1. Create a `config` folder on the root
2. Add a `app_config.json` file.
3. Add the following:

```
{
"TOKEN": <YOUR_DISCORD_ACCESS_TOKEN>,
"APPLICATION_ID": <YOUR_DISCORD_APPLICATION_ID>,
"GUILD_ID": <YOUR_DISCORD_GUILD_ID>,
"CHANNEL_ID": <YOUR_DISCORD_CHANNEL_ID>,
"VERSION": <YOUR_DISCORD_VERSION>,
"ID": <YOUR_DISCORD_ID>,
"GUMROAD_ACCESS_TOKEN": <YOUR_GUMROAD_ACCESS_TOKEN>,
"GUMROAD_PRODUCT_ID": <YOUR_GUMROAD_PRODUCT_ID>,
}
```

4. To get these values, open your server in discord web and make sure to open your inspect element > network.
5. Type `/imagine <your prompt>` in Discord. Look for the `interactions` network call and get the values from the payload.