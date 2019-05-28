# TikTak
Fast and lightweight web scheduler.

## Work Flow
Setup a schedule and a callback URL, get called back once the schedule is met.

## REST API
### `PUT /schedule/<schedule id>`
Creates or updates a schedule.

#### Example
```
PUT /schedule/run_every_hour HTTP/1.1
Host: localhost:8080
Content-Type: application/json

{
	"cron": "* 0 * * * *",
	"callback_url": "http://requestbin.fullcontact.com/qv3oe4qv"
}
```
#### Parameters
| Name | Description | Example |
| --- | --- | --- |
| cron | 6-7 fields Cron expression  | `"* 0 * * * *"` to run every round hour |
| date | ISO 8601 date | `"2022-12-18T15:00:00.00Z"` to run at the next FIFA World Cup |
| delay | Delay in seconds | `60` to run in 1 minute  |
| callback_url | The callback URL | https://my-service.com/my-endpoint |
| priority | Priority between 1-10, where 1 is the highest priority. Defaulted to 5.  | 5 |

### `DELETE /schedule/<schedule id>`
Deletes a schedule.
 
```
DELETE /schedule/my_not_so_wanted_schedule_id HTTP/1.1
Host: localhost:8080
```

## Docker
#### Quick Start using Compose
```
docker-compose up -d
```

#### Running from the Command Line 
https://hub.docker.com/r/conduitmobilernd/tiktak
```
docker run -e "TIKTAK_CONCURRENCY_LIMIT=10" -e "TIKTAK_REPO_DATABASE=postgres" -e "TIKTAK_REPO_USERNAME=postgres" -e "TIKTAK_REPO_PASSWORD=postgres" -e "TIKTAK_REPO_HOSTNAME=postgres" conduitmobilernd/tiktak
``` 

#### Environment Variables
| Name | Description | Example |
| --- | --- | --- |
| TIKTAK_CONCURRENCY_LIMIT | The max number of concurrent requests to provided callbacks  | `10` |
| TIKTAK_REPO_DATABASE | Postgres database name  | `postgres` |
| TIKTAK_REPO_USERNAME | Postgres username  | `postgres` |
| TIKTAK_REPO_PASSWORD | Postgres password  | `postgres` |
| TIKTAK_REPO_HOSTNAME | Postgres host name  | `172.20.0.5` |

## Setup a Development Environment
```
# Setup Postgres in /config/dev.exs
...
...

# Get dependencies
mix deps.get

# Run DB migration process
mix ecto.create && mix ecto.migrate

# Run Application
iex -S mix
```

## Future Work / NTH
- Cluster support
- Get/Query API
- Authentication
- Nice interface


## License
[The MIT License](/LICENSE)
