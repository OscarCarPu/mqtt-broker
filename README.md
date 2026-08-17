# mqtt-broker

A self-hosted [Eclipse Mosquitto](https://mosquitto.org/) MQTT broker for
microcontrollers and home-lab IoT devices, plus a web UI for inspecting traffic.
Everything runs via Docker Compose.

## Services

| Service        | Image                        | Port(s)        | Description                          |
| -------------- | ---------------------------- | -------------- | ------------------------------------ |
| `mosquitto`    | `eclipse-mosquitto:2.0`      | `1883`, `9001` | The MQTT broker (MQTT + WebSockets)  |
| `mosquitto-ui` | `smeagolworms4/mqtt-explorer`| `4000`         | MQTT Explorer web UI                 |

The broker requires authentication (`allow_anonymous false`), persists messages
to `mosquitto/data/`, and logs to `mosquitto/log/`. Access is governed by the
ACL in `mosquitto/config/acl`, loaded via `acl_file`.

## Requirements

- [Docker](https://docs.docker.com/get-docker/) with the Compose plugin

## Getting started

```sh
cp .env.example .env                       # then fill in MQTT_PASSWORD
make up                                    # start the broker and UI
make create-password USER=web-ui PASS=...  # same password as in .env
```

Then open the UI at <http://localhost:4000>.

Credentials are never committed. `.env` holds the password the web UI connects
with, and compose feeds it to the UI through `INITIAL_CONFIG`, which seeds
`mqtt-explorer/config/settings.json` on first start only — the UI owns that file
afterwards. Both `.env` and the two files listed under
[Runtime state](#runtime-state) are gitignored.

## Users and access

Every user needs a password (`make create-password`) **and** an entry in
`mosquitto/config/acl`. A user missing from the ACL authenticates fine but is
denied every topic, which looks like a silently broken client.

| User             | Access                                                              |
| ---------------- | ------------------------------------------------------------------- |
| `esp32-watchdog` | write `watchdog/ping`                                               |
| `lab-watchdog`   | read `watchdog/ping`, write `events/uptime/lab`, `events/uptime/watchdog` |
| `web-ui`         | read `#` and `$SYS/#` (read-only view for the web UI)               |

The first two serve [mutual-watchdog](https://github.com/OscarCarPu/mutual-watchdog).
Note that `#` does not match `$SYS`, so broker stats need their own rule.

## Access

- MQTT: `mqtt://localhost:1883`
- WebSockets: `ws://localhost:9001`
- UI: `http://localhost:4000`

## Commands

| Command                                     | Description                     |
| ------------------------------------------- | ------------------------------- |
| `make up`                                   | Start the broker and UI         |
| `make down`                                 | Stop and remove the containers  |
| `make restart`                              | Restart all services            |
| `make logs`                                 | Follow the broker logs          |
| `make ps`                                   | Show service status             |
| `make create-password USER=user PASS=pass`  | Create or update a user         |
| `make delete-password USER=user`            | Remove a user                   |
| `make list-users`                           | List users in the password file |

## Configuration

- `mosquitto/config/mosquitto.conf` — broker settings (listeners, auth, ACL, persistence, logging, limits)
- `mosquitto/config/acl` — per-user topic access rules
- `.env` — web UI credentials, copied from `.env.example` (gitignored)

`mosquitto/config/` is mounted read-only at `/etc/mosquitto`, deliberately
outside `/mosquitto`: the image entrypoint runs
`chown -R mosquitto:mosquitto /mosquitto` on every start, so config kept in there
stops being owned by the host user and git can no longer check it out. Anything
the broker must write stays under `/mosquitto`.

### Runtime state

These are written by the services, not by git, and are gitignored. A fresh clone
starts without them; `make up` creates an empty `passwd` and the UI seeds its own
`settings.json`.

- `mosquitto/secrets/passwd` — password hashes (managed via `make create-password`)
- `mqtt-explorer/config/settings.json` — saved UI connections, rewritten by the UI
  on every change and containing the broker password in plain text
