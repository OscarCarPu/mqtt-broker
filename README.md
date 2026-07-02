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
ACL in `mosquitto/config/acl`.

## Requirements

- [Docker](https://docs.docker.com/get-docker/) with the Compose plugin

## Getting started

```sh
make up                                  # start the broker and UI
make create-password USER=admin PASS=... # create the first user
```

Then open the UI at <http://localhost:4000>.

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
| `make create-password USER=user PASS=PASS`  | Create a new user               |

## Configuration

- `mosquitto/config/mosquitto.conf` — broker settings (listeners, auth, persistence, logging, limits)
- `mosquitto/config/acl` — per-user topic access rules
- `mosquitto/config/passwd` — hashed credentials (managed via `make create-password`)
- `mqtt-explorer/config/settings.json` — saved connections for the web UI
