.PHONY: up down restart logs ps create-password

up: # start the broker and UI in the background
	@docker compose up -d

down: # stop and remove the containers
	@docker compose down

restart: # restart all services
	@docker compose restart

logs: # follow the broker logs
	@docker compose logs -f

ps: # show the status of the services
	@docker compose ps

create-password: # create a new user usage: make create-password USER=user PASS=PASS
	@if [ -z "$(USER)" ] || [ -z "$(PASS)" ]; then \
		echo "USER and PASS are required"; \
		exit 1; \
	fi
	@echo "Creating user $(USER) with password $(PASS)"
	@docker compose exec mosquitto mosquitto_passwd -b /mosquitto/config/passwd $(USER) $(PASS)
	@docker compose restart mosquitto
	@echo "User $(USER) created with password $(PASS)"
