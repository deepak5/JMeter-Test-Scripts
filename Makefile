all: simple/card.json simple/paypal.json simple/redirect_when_not_logged_in.json

simple/card.json: HAR/card.json
	./transform.js HAR/card.json > simple/card.json

simple/paypal.json: HAR/paypal.json
	./transform.js HAR/paypal.json > simple/paypal.json

simple/redirect_when_not_logged_in.json: HAR/redirect_when_not_logged_in.json
	./transform.js HAR/redirect_when_not_logged_in.json > simple/redirect_when_not_logged_in.json

clean:
	rm simple/*