.PHONY: up down restart logs ps create-password delete-password list-users

up: # start the broker and UI in the background
	@test -f .env || echo "warning: no .env found, copy .env.example and fill it in"
	@test -f mosquitto/config/passwd || touch mosquitto/config/passwd
	@docker compose up -d

down: # stop and remove the containers
	@docker compose down

restart: # restart all services
	@docker compose restart

logs: # follow the broker logs
	@docker compose logs -f

ps: # show the status of the services
	@docker compose ps

create-password: # create or update a user, usage: make create-password USER=user PASS=pass
	@# USER comes from the environment on most shells, so require it explicitly
	@# rather than silently creating a user named after whoever ran make.
	@if [ "$(origin USER)" != "command line" ] || [ -z "$(PASS)" ]; then \
		echo "usage: make create-password USER=name PASS=secret"; \
		exit 1; \
	fi
	@docker compose exec -T mosquitto mosquitto_passwd -b /mosquitto/config/passwd '$(USER)' '$(PASS)'
	@docker compose restart mosquitto
	@echo "User $(USER) created. Add an entry for it in mosquitto/config/acl."

delete-password: # remove a user, usage: make delete-password USER=user
	@if [ "$(origin USER)" != "command line" ]; then \
		echo "usage: make delete-password USER=name"; \
		exit 1; \
	fi
	@docker compose exec -T mosquitto mosquitto_passwd -D /mosquitto/config/passwd '$(USER)'
	@docker compose restart mosquitto
	@echo "User $(USER) deleted. Remove its entry from mosquitto/config/acl too."

list-users: # list the users defined in the password file
	@cut -d: -f1 mosquitto/config/passwd
