.PHONY: create-password 

create-password: # create a new user usage: make create-password USER=user PASS=PASS
	@if [ -z "$(USER)" ] || [ -z "$(PASS)" ]; then \
		echo "USER and PASS are required"; \
		exit 1; \
	fi
	@echo "Creating user $(USER) with password $(PASS)"
	@docker compose exec mosquitto mosquitto_passwd -b /mosquitto/config/passwd $(USER) $(PASS)
	@docker compose restart mosquitto
	@echo "User $(USER) created with password $(PASS)"

