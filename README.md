# Local Token Handler Deployment

The [Final SPA](https://github.com/gary-archer/oauth.websample.final) implements its OpenID Connect security using a [Token Handler](https://github.com/gary-archer/oauth.tokenhandler.docker).\
This design pattern requires extra components to support the SPA.

## Development Setup

A local token handler must be run in a sibling domain of the SPA, where domains are added to the hosts file.\
This ensures that SameSite cookies issued by the token handler work properly in browsers:

| Component | URL |
| --------- | --- |
| SPA | https://web.authsamples-dev.com/spa |
| OAuth Agent | https://localtokenhandler.authsamples-dev.com/oauth-agent |
| API Public URL | https://localtokenhandler.authsamples-dev.com/api |

## Build

The build script is called by the SPA's `build.sh` script to ensure that the token handler is ready to deploy.

## Deploy

The deploy script is called when the SPA's `deploy.sh` script is executed.\
The result is that the OAuth Agent API and an API Gateway with an OAuth Proxy run in Docker.
